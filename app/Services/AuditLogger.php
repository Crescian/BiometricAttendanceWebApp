<?php

namespace App\Services;

use App\Models\User;
use Carbon\Carbon;
use DateTimeInterface;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Throwable;

/**
 * Writes the audit trail (audit_logs).
 *
 * Every entry records who (actor snapshot), what (event, target, before/after values), when (UTC,
 * microseconds), where (IP, user agent, route, request id) and the outcome. Entries are chained:
 * hash = sha256(prev_hash | canonical row), so any later edit, deletion or reordering is detected
 * by verify(). Inserts are serialized with a transaction-scoped advisory lock so the chain never forks.
 * Secrets (passwords, tokens) are redacted before anything is stored.
 */
class AuditLogger
{
    public const GENESIS_HASH = '0000000000000000000000000000000000000000000000000000000000000000';

    private const LOCK_KEY = 731045201;

    private const REDACTED = '[REDACTED]';

    private const SECRET_KEY_PATTERN = '/pass(word)?|secret|token|api[_-]?key|authorization|cookie/i';

    /** Columns covered by the hash, in this order. */
    private const HASHED_COLUMNS = [
        'id', 'occurred_at', 'actor_id', 'actor_name', 'actor_email', 'actor_role',
        'event', 'category', 'action', 'outcome', 'auditable_type', 'auditable_id',
        'description', 'old_values', 'new_values', 'metadata',
        'ip_address', 'user_agent', 'http_method', 'route', 'url', 'request_id', 'session_hash',
    ];

    private const JSON_COLUMNS = ['old_values', 'new_values', 'metadata'];

    /** Model class basename => [event prefix, label] */
    private const MODELS = [
        'User' => ['user', 'User'],
        'EmployeeManagement' => ['employee', 'Employee'],
        'Department' => ['department', 'Department'],
        'Company' => ['company', 'Company'],
        'BusinessUnit' => ['business_unit', 'Business unit'],
        'CustomDate' => ['holiday', 'Holiday / rest day'],
        'Schedule' => ['schedule', 'Schedule'],
        'Overtime' => ['overtime', 'Overtime'],
        'Leave' => ['leave', 'Leave'],
        'CertificateOfAttendance' => ['certificate', 'Certificate of attendance'],
        'ScheduleAdjustment' => ['schedule_adjustment', 'Schedule adjustment'],
        'AttendanceRecord' => ['attendance_record', 'Attendance record'],
        'BiometricHistoryList' => ['biometric_import', 'Biometric import'],
    ];

    /** Attributes that change on every save and say nothing about the business change. */
    private const IGNORED_ATTRIBUTES = ['updated_at', 'created_at', 'last_seen_at'];

    /**
     * Record one audit entry.
     *
     * $o keys (all optional): category, action, outcome (success|failure|denied), target (Model or
     * [type, id]), description, old, new, metadata, actor (User|null to force "no user"), actor_email,
     * occurred_at and context (legacy import only).
     *
     * Returns the new entry id, or null when it could not be stored (then it is in the fallback log).
     */
    public static function record(string $event, array $o = []): ?int
    {
        $row = self::buildRow($event, $o);

        if (app()->bound('request')) {
            request()->attributes->set('audit.recorded', true);
        }

        try {
            return self::insertChained($row);
        } catch (Throwable $e) {
            Log::channel('audit_fallback')->critical('Audit entry could not be stored in audit_logs', [
                'error' => $e->getMessage(),
                'entry' => $row,
            ]);
            Log::error('AuditLogger: write failed, entry kept in audit-fallback log: '.$e->getMessage());

            return null;
        }
    }

    /**
     * Created / updated / deleted on an Auditable model, with before/after values of what changed.
     */
    public static function modelEvent(Model $model, string $kind): void
    {
        [$prefix, $label] = self::MODELS[class_basename($model)] ?? [Str::snake(class_basename($model)), class_basename($model)];

        $old = [];
        $new = [];
        if ($kind === 'created') {
            $new = self::withoutIgnored($model->getAttributes());
        } elseif ($kind === 'deleted') {
            $old = self::withoutIgnored($model->getOriginal());
        } else {
            $new = self::withoutIgnored($model->getChanges());
            if (! $new) {
                return; // only timestamps changed
            }
            $old = array_intersect_key($model->getOriginal(), $new);
        }

        $event = "{$prefix}.{$kind}";
        $action = rtrim($kind, 'd'); // create / update / delete
        $category = 'data';

        // An approval-status change is the approval itself, not a generic edit
        $statusField = array_key_exists('approval_status', $new) ? 'approval_status' : (array_key_exists('status', $new) ? 'status' : null);
        if ($kind === 'updated' && $statusField && in_array($prefix, ['overtime', 'leave', 'certificate', 'schedule_adjustment'], true)) {
            $to = strtolower((string) $new[$statusField]);
            [$event, $action] = match ($to) {
                'approved' => ["{$prefix}.approved", 'approve'],
                'cancelled', 'rejected' => ["{$prefix}.cancelled", 'cancel'],
                'pending' => ["{$prefix}.reopened", 'reopen'],
                default => [$event, $action],
            };
            $category = 'approval';
        }

        $verb = ['created' => 'Created', 'updated' => 'Updated', 'deleted' => 'Deleted'][$kind];
        $verb = match ($action) { 'approve' => 'Approved', 'cancel' => 'Cancelled', 'reopen' => 'Reopened', default => $verb };

        self::record($event, [
            'category' => $category,
            'action' => $action,
            'target' => $model,
            'description' => "{$verb} {$label} ".self::recordLabel($model).self::changeSummary($old, $new, $kind),
            'old' => $old ?: null,
            'new' => $new ?: null,
        ]);
    }

    /**
     * Walk the whole chain. Returns ['ok' => bool, 'checked' => int, 'broken_id' => ?int, 'reason' => ?string].
     */
    public static function verify(): array
    {
        $expectedPrev = self::GENESIS_HASH;
        $checked = 0;

        foreach (DB::table('audit_logs')->lazyById(1000, 'id') as $row) {
            $row = (array) $row;

            if (! hash_equals($expectedPrev, (string) $row['prev_hash'])) {
                return ['ok' => false, 'checked' => $checked, 'broken_id' => (int) $row['id'],
                    'reason' => 'The entry before it is missing or was changed (chain link does not match).'];
            }
            if (! hash_equals(self::hashFor($row['prev_hash'], $row), (string) $row['hash'])) {
                return ['ok' => false, 'checked' => $checked, 'broken_id' => (int) $row['id'],
                    'reason' => 'This entry was changed after it was written (hash does not match).'];
            }

            $expectedPrev = $row['hash'];
            $checked++;
        }

        return ['ok' => true, 'checked' => $checked, 'broken_id' => null, 'reason' => null];
    }

    public static function hashFor(string $prevHash, array $row): string
    {
        return hash('sha256', $prevHash.'|'.self::canonical($row));
    }

    /** Stable text form of the hashed columns, identical whether built at write time or read back. */
    public static function canonical(array $row): string
    {
        $data = [];
        foreach (self::HASHED_COLUMNS as $column) {
            $value = $row[$column] ?? null;

            if ($column === 'occurred_at') {
                $value = Carbon::parse($value)->setTimezone('UTC')->format('Y-m-d\TH:i:s.u\Z');
            } elseif (in_array($column, ['id', 'actor_id'], true)) {
                $value = $value === null ? null : (int) $value;
            } elseif (in_array($column, self::JSON_COLUMNS, true)) {
                $value = is_string($value) ? json_decode($value, true) : $value;
                $value = $value === null ? null : self::sortKeys($value);
            } else {
                $value = $value === null ? null : (string) $value;
            }

            $data[$column] = $value;
        }

        return json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
    }

    // ------------------------------------------------------------------------------------------

    private static function buildRow(string $event, array $o): array
    {
        $request = app()->bound('request') ? request() : null;
        // A routed request is HTTP (also when dispatched through the kernel from a test); otherwise CLI
        $http = $request && $request->route() !== null;

        $actor = array_key_exists('actor', $o) ? $o['actor'] : Auth::user();
        $target = $o['target'] ?? null;
        [$targetType, $targetId] = $target instanceof Model
            ? [class_basename($target), $target->getKey()]
            : (is_array($target) ? [$target[0] ?? null, $target[1] ?? null] : [null, null]);

        $session = $http && $request->hasSession() ? $request->session()->getId() : null;

        $row = [
            'occurred_at' => isset($o['occurred_at'])
                ? Carbon::parse($o['occurred_at'])->setTimezone('UTC')->format('Y-m-d\TH:i:s.u\Z')
                : now()->setTimezone('UTC')->format('Y-m-d\TH:i:s.u\Z'),
            'actor_id' => $actor instanceof User ? $actor->getKey() : null,
            'actor_name' => $actor instanceof User ? $actor->name : null,
            'actor_email' => $actor instanceof User ? $actor->email : ($o['actor_email'] ?? null),
            'actor_role' => $actor instanceof User ? $actor->role : null,
            'event' => $event,
            'category' => $o['category'] ?? self::categoryFor($event),
            'action' => $o['action'] ?? Str::afterLast($event, '.'),
            'outcome' => $o['outcome'] ?? 'success',
            'auditable_type' => $targetType,
            'auditable_id' => $targetId === null ? null : (string) $targetId,
            'description' => isset($o['description']) ? Str::limit((string) $o['description'], 1000) : null,
            'old_values' => self::clean($o['old'] ?? null),
            'new_values' => self::clean($o['new'] ?? null),
            'metadata' => self::clean($o['metadata'] ?? null),
            'ip_address' => $http ? $request->ip() : null,
            'user_agent' => $http ? Str::limit((string) $request->userAgent(), 500, '') : 'cli',
            'http_method' => $http ? $request->method() : 'CLI',
            'route' => $http ? ($request->route()?->getName() ?? $request->route()?->uri() ?? $request->path()) : self::consoleCommand(),
            'url' => $http ? Str::limit($request->url(), 1000, '') : null,
            'request_id' => $http ? ($request->attributes->get('request_id') ?? self::assignRequestId($request)) : null,
            'session_hash' => $session ? hash('sha256', $session) : null,
        ];

        // Legacy import only: keep where the original event came from
        $context = array_intersect_key($o['context'] ?? [], array_flip(['ip_address', 'user_agent', 'http_method', 'route']));

        return array_merge($row, $context);
    }

    private static function insertChained(array $row): int
    {
        return DB::transaction(function () use ($row) {
            DB::select('SELECT pg_advisory_xact_lock(?)', [self::LOCK_KEY]);

            $prev = DB::table('audit_logs')->orderByDesc('id')->value('hash') ?? self::GENESIS_HASH;
            $row['id'] = (int) DB::selectOne("SELECT nextval('audit_logs_id_seq') AS id")->id;
            $row['prev_hash'] = $prev;
            $row['hash'] = self::hashFor($prev, $row);

            foreach (self::JSON_COLUMNS as $column) {
                $row[$column] = $row[$column] === null
                    ? null
                    : json_encode($row[$column], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            }

            DB::table('audit_logs')->insert($row);

            return $row['id'];
        });
    }

    /** Redact secrets and normalize values so they read back from jsonb exactly as hashed. */
    private static function clean($value)
    {
        if ($value === null || $value === []) {
            return null;
        }

        $value = self::redact(self::plain($value));

        // Round-trip once: what jsonb gives back is what gets hashed
        return self::sortKeys(json_decode(json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), true));
    }

    private static function plain($value)
    {
        if ($value instanceof DateTimeInterface) {
            return Carbon::instance($value)->format('Y-m-d H:i:s');
        }
        if ($value instanceof Model) {
            return $value->getAttributes();
        }
        if ($value instanceof \Illuminate\Contracts\Support\Arrayable) {
            $value = $value->toArray();
        }
        if (is_array($value)) {
            return array_map([self::class, 'plain'], $value);
        }
        if (is_float($value)) {
            return (string) $value;
        }
        if (is_resource($value) || is_object($value)) {
            return (string) (is_object($value) && method_exists($value, '__toString') ? $value : get_debug_type($value));
        }

        return $value;
    }

    private static function redact($value)
    {
        if (! is_array($value)) {
            return $value;
        }
        foreach ($value as $key => $item) {
            $value[$key] = is_string($key) && preg_match(self::SECRET_KEY_PATTERN, $key)
                ? self::REDACTED
                : self::redact($item);
        }

        return $value;
    }

    private static function sortKeys($value)
    {
        if (! is_array($value)) {
            return $value;
        }
        if (! array_is_list($value)) {
            ksort($value, SORT_STRING);
        }

        return array_map([self::class, 'sortKeys'], $value);
    }

    private static function withoutIgnored(array $attributes): array
    {
        return array_diff_key($attributes, array_flip(self::IGNORED_ATTRIBUTES));
    }

    private static function recordLabel(Model $model): string
    {
        foreach (['employee_name', 'name', 'title', 'department_name', 'unique_id'] as $field) {
            $value = $model->getAttribute($field);
            if (is_string($value) && trim($value) !== '') {
                return '#'.$model->getKey().' ('.Str::limit(trim($value), 60).')';
            }
        }

        return '#'.$model->getKey();
    }

    private static function changeSummary(array $old, array $new, string $kind): string
    {
        if ($kind !== 'updated') {
            return '';
        }
        $parts = [];
        foreach (array_slice(array_keys($new), 0, 4) as $field) {
            $from = preg_match(self::SECRET_KEY_PATTERN, $field) ? self::REDACTED : self::short($old[$field] ?? null);
            $to = preg_match(self::SECRET_KEY_PATTERN, $field) ? self::REDACTED : self::short($new[$field]);
            $parts[] = "{$field}: {$from} → {$to}";
        }
        $more = count($new) > 4 ? ' (+'.(count($new) - 4).' more)' : '';

        return ': '.implode('; ', $parts).$more;
    }

    private static function short($value): string
    {
        if ($value === null || $value === '') {
            return '∅';
        }
        if (is_bool($value)) {
            return $value ? 'true' : 'false';
        }
        if ($value instanceof DateTimeInterface) {
            return $value->format('Y-m-d H:i:s');
        }

        return Str::limit(is_scalar($value) ? (string) $value : json_encode($value), 40);
    }

    private static function categoryFor(string $event): string
    {
        $prefix = Str::before($event, '.');

        return match (true) {
            $prefix === 'auth' => 'auth',
            $prefix === 'access' => 'access',
            $prefix === 'audit' => 'security',
            $prefix === 'import' || $prefix === 'biometric_import' => 'import',
            $prefix === 'report' || $prefix === 'payroll' => 'report',
            in_array($prefix, ['user', 'department', 'company', 'business_unit', 'holiday', 'schedule'], true) => 'admin',
            Str::endsWith($event, ['.approved', '.cancelled', '.bulk_approved', '.reopened']) => 'approval',
            default => 'data',
        };
    }

    private static function assignRequestId($request): string
    {
        $id = (string) Str::uuid();
        $request->attributes->set('request_id', $id);

        return $id;
    }

    private static function consoleCommand(): string
    {
        $argv = $_SERVER['argv'] ?? [];

        return Str::limit('artisan '.implode(' ', array_slice($argv, 1, 2)), 255, '');
    }
}

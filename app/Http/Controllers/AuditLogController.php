<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Services\AuditLogger;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Yajra\DataTables\Facades\DataTables;

/**
 * Audit Log (admin only). Read-only: entries can be listed, inspected, exported and verified,
 * never edited. Opening the page, opening an entry, exporting and verifying are themselves audited.
 */
class AuditLogController extends Controller
{
    public const CATEGORIES = ['auth', 'access', 'approval', 'data', 'import', 'report', 'admin', 'security'];

    public function index()
    {
        AuditLogger::record('audit.viewed', [
            'category' => 'security',
            'action' => 'view',
            'description' => 'Opened the Audit Log',
        ]);

        $since = now()->subDay();

        return view('audit_log', [
            'stats' => [
                'today' => AuditLog::where('occurred_at', '>=', now()->startOfDay())->count(),
                'failed_logins' => AuditLog::where('event', 'auth.login.failed')->where('occurred_at', '>=', $since)->count(),
                'denied' => AuditLog::where('outcome', 'denied')->where('occurred_at', '>=', $since)->count(),
                'total' => AuditLog::count(),
            ],
            'actors' => AuditLog::whereNotNull('actor_id')
                ->select('actor_id', DB::raw('MAX(actor_name) AS actor_name'), DB::raw('MAX(actor_email) AS actor_email'))
                ->groupBy('actor_id')
                ->orderBy('actor_name')
                ->get(),
            'categories' => self::CATEGORIES,
            'fallbackEntries' => $this->fallbackEntries(),
        ]);
    }

    /** Server-side DataTables feed. */
    public function data(Request $request)
    {
        $query = $this->filtered($request)->select([
            'id', 'occurred_at', 'actor_id', 'actor_name', 'actor_email', 'actor_role', 'event', 'category',
            'action', 'outcome', 'auditable_type', 'auditable_id', 'description', 'ip_address', 'request_id',
        ]);

        return DataTables::eloquent($query)
            ->editColumn('occurred_at', fn (AuditLog $log) => $log->occurred_at->toIso8601String())
            ->orderColumn('occurred_at', fn ($q, $dir) => $q->orderBy('occurred_at', $dir)->orderBy('id', $dir))
            ->make(true);
    }

    /** One entry in full (before/after values, metadata, request context, hashes). */
    public function show($id)
    {
        $log = AuditLog::findOrFail($id);

        AuditLogger::record('audit.entry_viewed', [
            'category' => 'security',
            'action' => 'view',
            'target' => ['AuditLog', $log->id],
            'description' => "Viewed audit entry #{$log->id} ({$log->event})",
        ]);

        return response()->json(['success' => true, 'data' => $log]);
    }

    /**
     * CSV export of the current filter. The last line carries the row count and a SHA-256 of
     * everything above it, so a reviewer can tell if the file was edited after export.
     */
    public function export(Request $request)
    {
        $query = $this->filtered($request)->orderBy('id');
        $count = (clone $query)->count();
        $filters = $this->filterSummary($request);

        AuditLogger::record('audit.exported', [
            'category' => 'security',
            'action' => 'export',
            'description' => "Exported {$count} audit entries to CSV",
            'metadata' => ['rows' => $count, 'filters' => $filters],
        ]);

        $filename = 'audit-log-'.now()->format('Ymd-His').'.csv';
        $columns = ['id', 'occurred_at_utc', 'actor_id', 'actor_name', 'actor_email', 'actor_role', 'event', 'category',
            'action', 'outcome', 'auditable_type', 'auditable_id', 'description', 'old_values', 'new_values', 'metadata',
            'ip_address', 'user_agent', 'http_method', 'route', 'url', 'request_id', 'session_hash', 'prev_hash', 'hash'];

        return response()->streamDownload(function () use ($query, $columns, $count) {
            $hash = hash_init('sha256');
            $out = fopen('php://output', 'w');
            $write = function (array $fields) use ($out, $hash) {
                $line = $this->csvLine($fields);
                hash_update($hash, $line);
                fwrite($out, $line);
            };

            $write($columns);
            foreach ($query->lazyById(1000, 'id') as $log) {
                $write([
                    $log->id,
                    $log->occurred_at->setTimezone('UTC')->format('Y-m-d\TH:i:s.u\Z'),
                    $log->actor_id, $log->actor_name, $log->actor_email, $log->actor_role,
                    $log->event, $log->category, $log->action, $log->outcome,
                    $log->auditable_type, $log->auditable_id, $log->description,
                    $log->old_values ? json_encode($log->old_values, JSON_UNESCAPED_UNICODE) : '',
                    $log->new_values ? json_encode($log->new_values, JSON_UNESCAPED_UNICODE) : '',
                    $log->metadata ? json_encode($log->metadata, JSON_UNESCAPED_UNICODE) : '',
                    $log->ip_address, $log->user_agent, $log->http_method, $log->route, $log->url,
                    $log->request_id, $log->session_hash, $log->prev_hash, $log->hash,
                ]);
            }

            fwrite($out, $this->csvLine(['# rows', $count, 'sha256 of all lines above', hash_final($hash)]));
            fclose($out);
        }, $filename, ['Content-Type' => 'text/csv; charset=UTF-8']);
    }

    /** Re-checks the whole hash chain. */
    public function verify()
    {
        $result = AuditLogger::verify();

        AuditLogger::record('audit.integrity_verified', [
            'category' => 'security',
            'action' => 'verify',
            'outcome' => $result['ok'] ? 'success' : 'failure',
            'description' => $result['ok']
                ? "Audit log integrity verified: {$result['checked']} entries intact"
                : "Audit log integrity check FAILED at entry #{$result['broken_id']}: {$result['reason']}",
            'metadata' => $result,
        ]);

        return response()->json(['success' => true] + $result);
    }

    // ------------------------------------------------------------------------------------------

    private function filtered(Request $request)
    {
        $query = AuditLog::query();

        if ($request->filled('from')) {
            $query->where('occurred_at', '>=', Carbon::parse($request->input('from'))->startOfDay());
        }
        if ($request->filled('to')) {
            $query->where('occurred_at', '<=', Carbon::parse($request->input('to'))->endOfDay());
        }
        if ($request->filled('actor_id')) {
            $query->where('actor_id', (int) $request->input('actor_id'));
        }
        if ($request->filled('category') && in_array($request->input('category'), self::CATEGORIES, true)) {
            $query->where('category', $request->input('category'));
        }
        if ($request->filled('outcome') && in_array($request->input('outcome'), ['success', 'failure', 'denied'], true)) {
            $query->where('outcome', $request->input('outcome'));
        }
        if ($request->filled('request_id')) {
            $query->where('request_id', $request->input('request_id'));
        }
        if ($request->filled('q')) {
            $term = '%'.mb_strtolower($request->input('q')).'%';
            $query->where(function ($q) use ($term) {
                $q->whereRaw('LOWER(description) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(event) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(actor_name) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(actor_email) LIKE ?', [$term])
                    ->orWhere('ip_address', 'LIKE', $term)
                    ->orWhere('auditable_id', $request->input('q'));
            });
        }

        return $query;
    }

    private function filterSummary(Request $request): array
    {
        return array_filter($request->only(['from', 'to', 'actor_id', 'category', 'outcome', 'request_id', 'q']), fn ($v) => $v !== null && $v !== '');
    }

    private function csvLine(array $fields): string
    {
        $buffer = fopen('php://temp', 'r+');
        fputcsv($buffer, array_map(fn ($v) => $v === null ? '' : (string) $v, $fields));
        rewind($buffer);
        $line = stream_get_contents($buffer);
        fclose($buffer);

        return $line;
    }

    /** Entries that could not be written to the table and sit in the fallback log. */
    private function fallbackEntries(): int
    {
        $count = 0;
        foreach (File::glob(storage_path('logs/audit-fallback*.log')) as $file) {
            $count += substr_count((string) File::get($file), 'Audit entry could not be stored');
        }

        return $count;
    }
}

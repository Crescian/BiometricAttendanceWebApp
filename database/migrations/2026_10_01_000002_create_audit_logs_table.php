<?php

use App\Models\User;
use App\Services\AuditLogger;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Append-only, hash-chained audit trail. Replaces the old "User Log" (attendance_logs), whose
 * rows are carried over as legacy auth entries. Both tables are then protected by triggers that
 * reject UPDATE, DELETE and TRUNCATE.
 */
return new class extends Migration
{
    public function up()
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->timestampTz('occurred_at', 6);
            $table->unsignedBigInteger('actor_id')->nullable();
            $table->string('actor_name')->nullable();
            $table->string('actor_email')->nullable();
            $table->string('actor_role', 50)->nullable();
            $table->string('event', 100);
            $table->string('category', 30);
            $table->string('action', 50);
            $table->string('outcome', 20);
            $table->string('auditable_type', 100)->nullable();
            $table->string('auditable_id', 100)->nullable();
            $table->text('description')->nullable();
            $table->jsonb('old_values')->nullable();
            $table->jsonb('new_values')->nullable();
            $table->jsonb('metadata')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->string('http_method', 10)->nullable();
            $table->string('route')->nullable();
            $table->text('url')->nullable();
            $table->uuid('request_id')->nullable();
            $table->char('session_hash', 64)->nullable();
            $table->char('prev_hash', 64);
            $table->char('hash', 64)->unique();

            $table->index('occurred_at');
            $table->index('actor_id');
            $table->index('event');
            $table->index('category');
            $table->index(['auditable_type', 'auditable_id']);
            $table->index('request_id');
        });

        DB::unprepared(<<<'SQL'
            CREATE OR REPLACE FUNCTION audit_reject_change() RETURNS trigger AS $$
            BEGIN
                RAISE EXCEPTION 'Audit records are append-only: % on % is not allowed', TG_OP, TG_TABLE_NAME
                    USING ERRCODE = 'insufficient_privilege';
            END;
            $$ LANGUAGE plpgsql;
        SQL);

        // Carry the old User Log over, oldest first, as the start of the chain
        $users = User::all()->keyBy('id');
        $legacy = DB::table('attendance_logs')->orderBy('timestamp')->orderBy('id')->get();
        foreach ($legacy as $log) {
            [$event, $outcome, $verb] = match ($log->action) {
                'login' => ['auth.login.success', 'success', 'Signed in'],
                'logout' => ['auth.logout', 'success', 'Signed out'],
                'failed_login' => ['auth.login.failed', 'failure', 'Failed sign-in attempt'],
                default => ['auth.'.str_replace(' ', '_', (string) $log->action), 'success', (string) $log->action],
            };
            $user = $users[$log->user_id] ?? null;

            AuditLogger::record($event, [
                'category' => 'auth',
                'action' => $log->action ?: 'unknown',
                'outcome' => $outcome,
                'actor' => $user,
                'description' => $verb.' (carried over from the old User Log)',
                'metadata' => [
                    'legacy' => true,
                    'legacy_id' => $log->id,
                    'note' => 'Actor name/role as of the migration; original log stored only the user id.',
                ],
                'occurred_at' => $log->timestamp ?? $log->created_at,
                'context' => [
                    'ip_address' => $log->ip_address,
                    'user_agent' => null,
                    'http_method' => null,
                    'route' => 'legacy.user_log',
                ],
            ]);
        }

        DB::unprepared(<<<'SQL'
            CREATE TRIGGER audit_logs_append_only
                BEFORE UPDATE OR DELETE ON audit_logs
                FOR EACH ROW EXECUTE FUNCTION audit_reject_change();
            CREATE TRIGGER audit_logs_no_truncate
                BEFORE TRUNCATE ON audit_logs
                FOR EACH STATEMENT EXECUTE FUNCTION audit_reject_change();

            CREATE TRIGGER attendance_logs_append_only
                BEFORE UPDATE OR DELETE ON attendance_logs
                FOR EACH ROW EXECUTE FUNCTION audit_reject_change();
            CREATE TRIGGER attendance_logs_no_truncate
                BEFORE TRUNCATE ON attendance_logs
                FOR EACH STATEMENT EXECUTE FUNCTION audit_reject_change();
        SQL);
    }

    public function down()
    {
        // Only a database superuser can run this; the app's role cannot drop these triggers.
        DB::unprepared(<<<'SQL'
            DROP TRIGGER IF EXISTS attendance_logs_no_truncate ON attendance_logs;
            DROP TRIGGER IF EXISTS attendance_logs_append_only ON attendance_logs;
            DROP TRIGGER IF EXISTS audit_logs_no_truncate ON audit_logs;
            DROP TRIGGER IF EXISTS audit_logs_append_only ON audit_logs;
        SQL);
        Schema::dropIfExists('audit_logs');
        DB::unprepared('DROP FUNCTION IF EXISTS audit_reject_change()');
    }
};

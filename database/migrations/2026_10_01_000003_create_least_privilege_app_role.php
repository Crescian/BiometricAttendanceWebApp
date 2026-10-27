<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Least-privilege login role for the application (config database.app_role).
 *
 * - Normal read/write (incl. TRUNCATE, used by the employee import) on the app's tables.
 * - audit_logs: INSERT and SELECT only. attendance_logs (old User Log): SELECT only.
 * - Not the owner of any table, so it cannot ALTER tables or DISABLE the append-only triggers.
 * - Tables created by future migrations (run as the owner) get the same normal grants.
 *
 * Must run as the owner/superuser (the pgsql_admin connection).
 */
return new class extends Migration
{
    public function up()
    {
        $role = config('database.app_role.username');
        $password = config('database.app_role.password');

        if (! $role || ! $password) {
            throw new RuntimeException('Set DB_APP_USERNAME and DB_APP_PASSWORD before running this migration.');
        }

        $pdo = DB::getPdo();
        $ident = '"'.str_replace('"', '""', $role).'"';
        $owner = DB::selectOne('SELECT current_user AS name')->name;
        $ownerIdent = '"'.str_replace('"', '""', $owner).'"';
        $database = '"'.str_replace('"', '""', DB::selectOne('SELECT current_database() AS name')->name).'"';
        $exists = DB::selectOne('SELECT 1 AS found FROM pg_roles WHERE rolname = ?', [$role]);

        DB::unprepared(($exists ? 'ALTER' : 'CREATE')." ROLE {$ident} LOGIN PASSWORD ".$pdo->quote($password)
            .' NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS INHERIT');

        DB::unprepared(<<<SQL
            GRANT CONNECT ON DATABASE {$database} TO {$ident};
            GRANT USAGE ON SCHEMA public TO {$ident};

            GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public TO {$ident};
            GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO {$ident};

            REVOKE ALL ON audit_logs, attendance_logs FROM {$ident};
            GRANT SELECT, INSERT ON audit_logs TO {$ident};
            GRANT SELECT ON attendance_logs TO {$ident};

            ALTER DEFAULT PRIVILEGES FOR ROLE {$ownerIdent} IN SCHEMA public
                GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO {$ident};
            ALTER DEFAULT PRIVILEGES FOR ROLE {$ownerIdent} IN SCHEMA public
                GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO {$ident};
        SQL);
    }

    public function down()
    {
        $role = config('database.app_role.username');
        if (! $role || ! DB::selectOne('SELECT 1 AS found FROM pg_roles WHERE rolname = ?', [$role])) {
            return;
        }
        $ident = '"'.str_replace('"', '""', $role).'"';
        $ownerIdent = '"'.str_replace('"', '""', DB::selectOne('SELECT current_user AS name')->name).'"';

        DB::unprepared(<<<SQL
            ALTER DEFAULT PRIVILEGES FOR ROLE {$ownerIdent} IN SCHEMA public REVOKE ALL ON TABLES FROM {$ident};
            ALTER DEFAULT PRIVILEGES FOR ROLE {$ownerIdent} IN SCHEMA public REVOKE ALL ON SEQUENCES FROM {$ident};
            REVOKE ALL ON ALL TABLES IN SCHEMA public FROM {$ident};
            REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM {$ident};
            REVOKE ALL ON SCHEMA public FROM {$ident};
        SQL);
    }
};

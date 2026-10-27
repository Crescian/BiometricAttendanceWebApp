<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * One attendance record per employee per day. The payroll report now pulls every record in
 * the chosen period across imports, so a day uploaded more than once would be counted again.
 */
return new class extends Migration
{
    public function up()
    {
        // Of each duplicated employee-day keep the copy with approved overtime, then a manual
        // edit, then the latest import. Deleting the others cascades to their overtimes rows.
        $deleted = DB::delete("
            DELETE FROM attendance_records
            WHERE id IN (
                SELECT id FROM (
                    SELECT ar.id,
                           ROW_NUMBER() OVER (
                               PARTITION BY ar.employee_management_id, ar.record_date::date
                               ORDER BY EXISTS (
                                            SELECT 1 FROM overtimes o
                                            WHERE o.attendance_records_id = ar.id AND o.status = 'Approved'
                                        ) DESC,
                                        (COALESCE(ar.is_manual, false) OR ar.edited_at IS NOT NULL) DESC,
                                        ar.biometric_imports_id DESC NULLS LAST,
                                        ar.id DESC
                           ) AS keep_rank
                    FROM attendance_records ar
                ) ranked
                WHERE keep_rank > 1
            )
        ");
        Log::info("unique_attendance_record_per_employee_day: removed {$deleted} duplicate attendance records");

        DB::statement('DROP INDEX IF EXISTS attendance_records_employee_date_index');
        DB::statement('
            CREATE UNIQUE INDEX attendance_records_employee_date_unique
            ON attendance_records (employee_management_id, (record_date::date))
        ');
    }

    public function down()
    {
        // Removed duplicates are not restored (see backups/); only the index is reverted.
        DB::statement('DROP INDEX IF EXISTS attendance_records_employee_date_unique');
        DB::statement('
            CREATE INDEX IF NOT EXISTS attendance_records_employee_date_index
            ON attendance_records (employee_management_id, record_date)
        ');
    }
};

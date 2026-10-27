<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Give imports uploaded before payroll periods were recorded a default period: the first and last
 * day of their own attendance records (the same default an upload sets). An import without a
 * period covers no day, so deleting another import could never hand days over to it. Periods an
 * admin has set are left alone.
 */
return new class extends Migration
{
    public function up()
    {
        $filled = DB::update("
            UPDATE biometric_imports bi
            SET period_start = COALESCE(bi.period_start, r.min_date),
                period_end   = COALESCE(bi.period_end, r.max_date)
            FROM (
                SELECT biometric_imports_id, MIN(record_date)::date AS min_date, MAX(record_date)::date AS max_date
                FROM attendance_records
                WHERE biometric_imports_id IS NOT NULL
                GROUP BY biometric_imports_id
            ) r
            WHERE r.biometric_imports_id = bi.id
              AND (bi.period_start IS NULL OR bi.period_end IS NULL)
        ");
        Log::info("backfill_missing_import_periods: filled the payroll period of {$filled} import(s)");
    }

    public function down()
    {
        // The filled periods are indistinguishable from ones set later; nothing to undo.
    }
};

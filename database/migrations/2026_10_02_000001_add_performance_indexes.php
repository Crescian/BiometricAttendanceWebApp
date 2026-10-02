<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Indexes for the lookups that grow with the data: employees by name, and per-day / per-period
 * reads of attendance, overtime and schedule adjustments (DATE(record_date) matches
 * record_date::date, so these expression indexes serve both spellings).
 */
return new class extends Migration
{
    private const INDEXES = [
        'employee_management_employee_name_index' => 'employee_management (employee_name)',
        'attendance_records_record_day_index' => 'attendance_records ((record_date::date))',
        'overtimes_employee_record_day_index' => 'overtimes (employee_management_id, (record_date::date))',
        'overtimes_record_day_status_index' => 'overtimes ((record_date::date), status)',
        'schedule_adjustments_employee_record_day_index' => 'schedule_adjustments (employee_management_id, (record_date::date))',
    ];

    public function up()
    {
        foreach (self::INDEXES as $name => $definition) {
            DB::statement("CREATE INDEX IF NOT EXISTS {$name} ON {$definition}");
        }
    }

    public function down()
    {
        foreach (array_keys(self::INDEXES) as $name) {
            DB::statement("DROP INDEX IF EXISTS {$name}");
        }
    }
};

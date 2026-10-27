<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Employee master data fixes:
 * - department text must match departments.department_name, otherwise the employee is
 *   invisible to their department head (employees are filtered by that exact name);
 * - employees are matched to biometric punches by name, so the same person must not be
 *   registered twice.
 * The payroll formulas only look at the SECURITY / SG VESTA departments, which are unchanged.
 */
return new class extends Migration
{
    protected const RENAMED_DEPARTMENTS = [
        'PURCHARSING'             => 'PURCHASING',
        'SHIPMENT OPPERATIONS'    => 'SHIPMENT OPERATIONS',
        'WAREHOUSE AND LOGISTICS' => 'WAREHOUSE LOGISTICS',
    ];

    /** Later registrations of the same security guards; the lowest unique_id is kept. */
    protected const DUPLICATE_UNIQUE_IDS = [
        'SC-2025001-041', 'SC-2025001-046', // TAOC, JAYRICK (keeps -031)
        'SC-2025001-040', 'SC-2025001-043', // MORALES, BRYAN (keeps -032)
        'SC-2025001-037',                   // MONTEHERMOZO, IAN (keeps -034)
        'SC-2025001-042',                   // MARTEJA, LEEMARC LEONEL (keeps -036)
    ];

    /** Test entries "Marylen, Yuson". */
    protected const TEST_UNIQUE_IDS = ['001', '77777', '100000000'];

    public function up()
    {
        foreach (self::RENAMED_DEPARTMENTS as $wrong => $right) {
            DB::table('employee_management')->where('department', $wrong)->update(['department' => $right]);
            DB::table('overtimes')->where('department', $wrong)->update(['department' => $right]);
        }

        $mining = DB::table('companies')->where('name', 'Mining')->value('id');
        if (!DB::table('departments')->where('department_name', 'LABORATORY')->exists()) {
            DB::table('departments')->insert([
                'department_name' => 'LABORATORY',
                'company_id'      => $mining,
                'created_at'      => now(),
                'updated_at'      => now(),
            ]);
        }

        // Only rows with no history are removed; anything referenced would be blocked by
        // the foreign keys anyway (ON DELETE RESTRICT).
        $deleted = DB::table('employee_management')
            ->whereIn('unique_id', array_merge(self::DUPLICATE_UNIQUE_IDS, self::TEST_UNIQUE_IDS))
            ->where(function ($q) {
                $q->where('employee_name', 'Marylen, Yuson')
                  ->orWhereIn('unique_id', self::DUPLICATE_UNIQUE_IDS);
            })
            ->delete();

        Log::info("clean_up_departments_and_duplicate_employees: removed {$deleted} employees");
    }

    public function down()
    {
        // Data fix only; not reversible without mixing up employees whose department was
        // already spelled correctly. Restore from backups/ if needed.
    }
};

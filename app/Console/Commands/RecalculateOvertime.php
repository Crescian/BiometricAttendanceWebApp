<?php

namespace App\Console\Commands;

use App\Services\AuditLogger;
use App\Services\ComputationService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

/**
 * Re-derives the OT / ND fields of Pending overtime records with the overtime rules
 * (ComputationService), from each record's own punches (including any time edits).
 * Approved and Cancelled records are never changed.
 */
class RecalculateOvertime extends Command
{
    protected $signature = 'attendance:recalculate-ot {--import= : Only this biometric import id}';

    protected $description = 'Recalculate OT/ND on Pending overtime records with the current overtime rules';

    private const FIELDS = ['ord_ot', 'ord_nd', 'ord_nd_ot', 'rd', 'rd_ot', 'rd_nd', 'rd_nd_ot'];

    public function handle(ComputationService $computation): int
    {
        $nonWorkingDays = DB::table('custom_dates')->pluck('record_date')->map(fn ($d) => substr($d, 0, 10))->toArray();
        $employeeData = DB::table('employee_management')->get()->toArray();
        $employees = collect($employeeData);
        $hm = function ($hours) {
            $minutes = (int) round(($hours ?? 0) * 60);

            return sprintf('%02d:%02d', intdiv($minutes, 60), $minutes % 60);
        };

        $checked = $updated = 0;
        $changes = [];

        DB::table('overtimes')
            ->leftJoin('attendance_records', 'attendance_records.id', '=', 'overtimes.attendance_records_id')
            ->leftJoin('employee_management', 'employee_management.id', '=', 'overtimes.employee_management_id')
            ->where('overtimes.status', 'Pending')
            ->when($this->option('import'), fn ($q, $id) => $q->where('overtimes.biometric_imports_id', (int) $id))
            ->select('overtimes.*', 'attendance_records.leaves', 'employee_management.employee_name as master_name',
                'employee_management.department as master_department')
            ->orderBy('overtimes.id')
            ->chunk(200, function ($rows) use ($computation, $nonWorkingDays, $employeeData, $employees, $hm, &$checked, &$updated, &$changes) {
                foreach ($rows as $o) {
                    $checked++;
                    $row = [
                        'employee_name' => $o->master_name ?? $o->employee_name,
                        'employee_management_id' => $o->employee_management_id,
                        'record_date' => substr($o->record_date, 0, 10),
                        'earliest_time' => $o->earliest_time,
                        'latest_time' => $o->latest_time,
                        'department' => $o->master_department ?? $o->department,
                        'leaves' => $o->leaves,
                    ];

                    [$ordOt, $ordNd, $ordNdOt] = $computation->autocalculateOrd(
                        $row, $nonWorkingDays, $employeeData, null, null, $o->biometric_imports_id
                    );
                    $rd = $computation->autocalculateRdAndOvertime($row, $employees);

                    $new = [
                        'ord_ot' => $hm($ordOt), 'ord_nd' => $hm($ordNd), 'ord_nd_ot' => $hm($ordNdOt),
                        'rd' => $hm($rd['rd']), 'rd_ot' => $hm($rd['rd_ot']), 'rd_nd' => $hm($rd['rd_nd']), 'rd_nd_ot' => $hm($rd['rd_nd_ot']),
                    ];
                    $old = array_intersect_key((array) $o, array_flip(self::FIELDS));
                    $diff = array_diff_assoc($new, array_map('strval', $old));

                    if ($diff) {
                        DB::table('overtimes')->where('id', $o->id)->update($new + ['updated_at' => now()]);
                        $updated++;
                        if (count($changes) < 1000) {
                            $changes[$o->id] = ['old' => array_intersect_key($old, $diff), 'new' => $diff];
                        }
                    }
                }
            });

        AuditLogger::record('overtime.recalculated_bulk', [
            'category' => 'data',
            'action' => 'update',
            'description' => "Recalculated OT/ND on {$checked} Pending overtime records with the current rules: {$updated} changed",
            'metadata' => [
                'import' => $this->option('import'),
                'checked' => $checked,
                'updated' => $updated,
                'rules' => 'OT after schedule end (early arrival not counted); late beyond grace starts +1h; ND 22:00-06:00 to the minute; day OT under 1:00 = 0',
                'changes' => $changes,
            ],
        ]);

        $this->info("Checked {$checked} Pending overtime records: {$updated} changed. Approved/Cancelled records were not touched.");

        return self::SUCCESS;
    }
}

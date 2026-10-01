<?php

namespace App\Console\Commands;

use App\Services\AuditLogger;
use App\Services\ComputationService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

/**
 * Re-derives late / late_hours / late_minutes on overtime records from their punches and the
 * current schedules (ComputationService::lateAndUndertime). Run after correcting an employee's
 * schedule or a schedule adjustment so the Overtime page matches the reports.
 */
class RecalculateLate extends Command
{
    protected $signature = 'attendance:recalculate-late {--import= : Only this biometric import id}';

    protected $description = 'Recalculate Late on overtime records from punches and current schedules';

    public function handle(ComputationService $computation): int
    {
        $nonWorking = DB::table('custom_dates')->pluck('record_date')->map(fn ($d) => substr($d, 0, 10))->flip();
        $adjusted = DB::table('schedule_adjustments')->orderBy('id')->get(['employee_management_id', 'record_date', 'schedule'])
            ->mapWithKeys(fn ($a) => [$a->employee_management_id.'|'.substr($a->record_date, 0, 10) => $a->schedule]);

        $checked = $updated = $late = 0;
        $changedIds = [];

        DB::table('overtimes')
            ->leftJoin('employee_management', 'employee_management.id', '=', 'overtimes.employee_management_id')
            ->leftJoin('attendance_records', 'attendance_records.id', '=', 'overtimes.attendance_records_id')
            ->when($this->option('import'), fn ($q, $id) => $q->where('overtimes.biometric_imports_id', (int) $id))
            ->select('overtimes.id', 'overtimes.employee_management_id', 'overtimes.record_date', 'overtimes.earliest_time',
                'overtimes.latest_time', 'overtimes.late', 'overtimes.late_hours', 'overtimes.late_minutes',
                'employee_management.schedule', 'employee_management.department', 'attendance_records.leaves')
            ->orderBy('overtimes.id')
            ->chunk(500, function ($rows) use ($computation, $nonWorking, $adjusted, &$checked, &$updated, &$late, &$changedIds) {
                foreach ($rows as $r) {
                    $checked++;
                    $date = substr($r->record_date, 0, 10);
                    $minutes = (isset($nonWorking[$date]) || !empty($r->leaves)) ? 0 : $computation->lateAndUndertime(
                        $adjusted[$r->employee_management_id.'|'.$date] ?? $r->schedule, $r->earliest_time, $r->latest_time, $r->department
                    )['late_minutes'];

                    $new = ['late' => $minutes > 0, 'late_hours' => intdiv($minutes, 60), 'late_minutes' => $minutes % 60];
                    if ((bool) $r->late !== $new['late'] || (int) $r->late_hours !== $new['late_hours'] || (int) $r->late_minutes !== $new['late_minutes']) {
                        DB::table('overtimes')->where('id', $r->id)->update($new);
                        $updated++;
                        $changedIds[] = $r->id;
                    }
                    $late += $minutes > 0;
                }
            });

        AuditLogger::record('overtime.late_recalculated', [
            'category' => 'data',
            'action' => 'update',
            'description' => "Recalculated Late on {$checked} overtime records: {$updated} changed, {$late} late",
            'metadata' => ['import' => $this->option('import'), 'checked' => $checked, 'updated' => $updated,
                'late_records' => $late, 'changed_ids' => array_slice($changedIds, 0, 1000)],
        ]);

        $this->info("Checked {$checked} overtime records: {$updated} changed, {$late} late.");

        return self::SUCCESS;
    }
}

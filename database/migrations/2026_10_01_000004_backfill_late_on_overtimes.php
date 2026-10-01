<?php

use App\Services\AuditLogger;
use App\Services\ComputationService;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Fill in late / late_hours / late_minutes on existing overtime records. They were always written
 * as "not late"; new records get them from ComputationService::lateAndUndertime() (beyond the
 * 15-minute grace period, counted in full).
 */
return new class extends Migration
{
    public function up()
    {
        $computation = new ComputationService();
        $nonWorking = DB::table('custom_dates')->pluck('record_date')->map(fn ($d) => substr($d, 0, 10))->flip();
        $adjusted = DB::table('schedule_adjustments')->orderBy('id')->get(['employee_management_id', 'record_date', 'schedule'])
            ->mapWithKeys(fn ($a) => [$a->employee_management_id.'|'.substr($a->record_date, 0, 10) => $a->schedule]);

        $updated = 0;
        $late = 0;
        DB::table('overtimes')
            ->leftJoin('employee_management', 'employee_management.id', '=', 'overtimes.employee_management_id')
            ->leftJoin('attendance_records', 'attendance_records.id', '=', 'overtimes.attendance_records_id')
            ->select('overtimes.id', 'overtimes.employee_management_id', 'overtimes.record_date', 'overtimes.earliest_time',
                'overtimes.latest_time', 'overtimes.late', 'overtimes.late_hours', 'overtimes.late_minutes',
                'employee_management.schedule', 'employee_management.department', 'attendance_records.leaves')
            ->orderBy('overtimes.id')
            ->chunk(500, function ($rows) use ($computation, $nonWorking, $adjusted, &$updated, &$late) {
                foreach ($rows as $r) {
                    $date = substr($r->record_date, 0, 10);
                    $minutes = (isset($nonWorking[$date]) || !empty($r->leaves)) ? 0 : $computation->lateAndUndertime(
                        $adjusted[$r->employee_management_id.'|'.$date] ?? $r->schedule, $r->earliest_time, $r->latest_time, $r->department
                    )['late_minutes'];

                    $new = ['late' => $minutes > 0, 'late_hours' => intdiv($minutes, 60), 'late_minutes' => $minutes % 60];
                    if ((bool) $r->late !== $new['late'] || (int) $r->late_hours !== $new['late_hours'] || (int) $r->late_minutes !== $new['late_minutes']) {
                        DB::table('overtimes')->where('id', $r->id)->update($new);
                        $updated++;
                    }
                    $late += $minutes > 0;
                }
            });

        AuditLogger::record('overtime.late_backfilled', [
            'category' => 'data',
            'action' => 'update',
            'description' => "Recalculated Late on existing overtime records: {$updated} updated, {$late} now marked late "
                .'(beyond the 15-minute grace period, counted in full)',
            'metadata' => ['updated' => $updated, 'late_records' => $late, 'rule' => 'late = minutes after schedule start when > 15'],
        ]);
    }

    public function down()
    {
        // Values are derived from punches and schedules; nothing to restore.
    }
};

<?php

namespace App\Services;

use Carbon\Carbon;
use Carbon\CarbonPeriod;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Worksheet\Drawing;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

/**
 * VESTA security duty summary (security.xlsx). Port of security_report_generate()
 * in the retired compute_attendance.py, using the same hour rules so the numbers
 * match the reports HR and VESTA received before:
 *   - day cell / REG: elapsed hours per shift, no break deducted (12 for 7-19),
 *     after the 15-minute late rule
 *   - OT: 4 per full shift, otherwise worked - 8 (night-shift ND-OT counts as OT)
 *   - TOTAL HRS = REG + OT
 * All values are whole hours, as the old security_attendance columns were integers.
 */
class SecurityReportService
{
    public const DEPARTMENT = 'SECURITY';

    // Same list as ComputationService / AttendanceProcessor.
    protected const NIGHT_SHIFT_CODES = ['18-6', '19-7', '19-4', '20-5', '15-23', '15-24', '23-7', '23-8'];

    // Reliever punches starting at or after this hour count as night-shift relief.
    protected const NIGHT_RELIEF_FROM_HOUR = 15;

    protected const SIGNATORIES = [
        'B' => ['PREPARED BY:', 'SO KRISTIAN MILLAN', 'ADMIN'],
        'F' => ['NOTED BY:', 'SO MAC RENTON MILLAN', 'DETACHMENT COMMANDER'],
        'M' => ['CHECKED BY:', 'AMADOR CESARID', 'SECURITY MANAGER'],
        'S' => ['APPROVED BY:', 'ENGR. JAY EMMANUEL R. DELGRA', 'RESIDENT MANAGER'],
    ];

    public function __construct(protected ComputationService $computation)
    {
    }

    /**
     * Write the report for the payroll period $start..$end (records from any import).
     * Returns the number of guards included; when there are none, no file is written.
     */
    public function generate(string $start, string $end, string $path): int
    {
        if (file_exists($path)) {
            @unlink($path);
        }

        $shifts = $this->loadShifts($start, $end);
        if (empty($shifts)) {
            Log::info("SecurityReportService: no security attendance between {$start} and {$end}");
            return 0;
        }

        $days = iterator_to_array(CarbonPeriod::create($start, $end));

        $isReliever = fn($s) => $s['reliever'];
        $isNightRelief = fn($s) => $s['in_hour'] >= self::NIGHT_RELIEF_FROM_HOUR;

        $spreadsheet = new Spreadsheet();

        $day = $spreadsheet->getActiveSheet();
        $day->setTitle('Dayshift');
        $this->writeSheet($day, 'DAY SHIFT', $days, [
            [null, array_filter($shifts, fn($s) => !$isReliever($s) && !$s['night'])],
            ['DAY SHIFT RELIEVERS', array_filter($shifts, fn($s) => $isReliever($s) && !$isNightRelief($s))],
        ]);

        $night = $spreadsheet->createSheet();
        $night->setTitle('Nightshift');
        $this->writeSheet($night, 'NIGHT SHIFT', $days, [
            [null, array_filter($shifts, fn($s) => !$isReliever($s) && $s['night'])],
            ['RELIEVERS', array_filter($shifts, fn($s) => $isReliever($s) && $isNightRelief($s))],
        ]);

        (new Xlsx($spreadsheet))->save($path);

        $guards = count(array_unique(array_column($shifts, 'employee_management_id')));
        Log::info("SecurityReportService: wrote {$path}", ['guards' => $guards, 'period' => [$start, $end]]);

        return $guards;
    }

    /**
     * One entry per attendance record of a SECURITY employee in the period,
     * with the hour values of the old Python report.
     */
    protected function loadShifts(string $start, string $end): array
    {
        $query = DB::table('attendance_records as ar')
            ->join('employee_management as em', 'em.id', '=', 'ar.employee_management_id')
            ->whereRaw('DATE(ar.record_date) BETWEEN ? AND ?', [$start, $end])
            ->whereRaw('UPPER(TRIM(em.department)) = ?', [self::DEPARTMENT])
            ->orderBy('em.employee_name')
            ->orderBy('ar.record_date')
            ->select('ar.id', 'ar.employee_management_id', 'ar.record_date', 'ar.earliest_time', 'ar.latest_time',
                'em.employee_name', 'em.schedule', 'em.schedule_shift', 'em.relievers');

        $shifts = [];
        foreach ($query->get() as $r) {
            $in  = $this->computation->timeToSeconds($r->earliest_time);
            $out = $this->computation->timeToSeconds($r->latest_time);
            if ($in === $out) continue;

            [$hours, $ot] = $this->hours($in, $out, $r->schedule);

            $shifts[] = [
                'employee_management_id' => $r->employee_management_id,
                'employee_name'          => $r->employee_name,
                'record_date'            => substr($r->record_date, 0, 10),
                'in_hour'                => intdiv($in, 3600),
                'night'                  => $this->isNightShift($r->schedule_shift, $r->schedule),
                'reliever'               => filter_var($r->relievers, FILTER_VALIDATE_BOOLEAN),
                'hours'                  => $hours,
                'ot'                     => $ot,
            ];
        }

        return $shifts;
    }

    /**
     * [hours_worked, ot] for one shift, both whole hours.
     */
    protected function hours(int $in, int $out, ?string $schedule): array
    {
        // Late rule (hours only): in > schedule start + 15 min counts from start + 1h.
        $start = is_numeric($first = explode('-', (string) $schedule)[0]) ? (int) $first : null;
        $paidIn = $in;
        if ($start !== null && $in > $start * 3600 + 15 * 60 && abs($in - $start * 3600) < 12 * 3600) {
            $paidIn = ($start + 1) * 3600;
        }

        $elapsed = fn($from) => (($out > $from ? $out : $out + 86400) - $from) / 3600;
        $hoursWorked = (int) round($elapsed($paidIn));

        // OT uses the raw punch. Shift = whichever of 07:00 / 19:00 the punch-in is closest to.
        $worked  = $elapsed($in);
        $dayShift = abs($in - 7 * 3600) <= abs($in - 19 * 3600);
        $outAbs  = $out > $in ? $out : $out + 86400;

        $fullShift = $dayShift
            ? ($in <= 7 * 3600 + 15 * 60 && $outAbs >= 19 * 3600)
            : ($in <= 19 * 3600 && $outAbs >= 31 * 3600);

        $ot = $fullShift ? 4 : (int) round(max(0, $worked - 8));

        return [$hoursWorked, $ot];
    }

    protected function isNightShift(?string $scheduleShift, ?string $schedule): bool
    {
        if ($scheduleShift && stripos($scheduleShift, 'NIGHT') !== false) return true;
        if ($scheduleShift && stripos($scheduleShift, 'DAY') !== false) return false;

        return in_array(trim((string) $schedule), self::NIGHT_SHIFT_CODES, true);
    }

    /**
     * @param array $sections [[section title|null, shifts[]], ...]
     */
    protected function writeSheet(Worksheet $sheet, string $heading, array $days, array $sections): void
    {
        $col = fn(int $i) => Coordinate::stringFromColumnIndex($i);
        $firstDay  = 3;                        // column C
        $lastDay   = $firstDay + count($days) - 1;
        $daysCol   = $lastDay + 1;
        $regCol    = $lastDay + 2;
        $otCol     = $lastDay + 3;
        $totalCol  = $lastDay + 4;
        $signCol   = $lastDay + 5;
        $lastCol   = $col($signCol);

        $logo = public_path('image/vesta_security_header.png');
        if (file_exists($logo)) {
            $drawing = new Drawing();
            $drawing->setPath($logo);
            $drawing->setCoordinates('D1');
            $drawing->setWidth((int) round(27.9 * 37.7952755906));
            $drawing->setHeight((int) round(3.73 * 37.7952755906));
            $drawing->setWorksheet($sheet);
        }

        $sheet->mergeCells("A8:{$lastCol}8");
        $sheet->setCellValue('A8', $this->title($days));
        $sheet->getStyle('A8')->getFont()->setSize(14)->setBold(true);
        $sheet->getStyle('A8')->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

        $headers = array_merge(['#', $heading], array_map(fn($d) => $d->format('d'), $days),
            ['TOTAL DAYS', 'REG', 'OT', 'TOTAL HRS', 'SIGNATURE']);
        foreach ($headers as $i => $text) {
            $sheet->setCellValueExplicit($col($i + 1) . '9', $text, \PhpOffice\PhpSpreadsheet\Cell\DataType::TYPE_STRING);
        }
        $sheet->getRowDimension(9)->setRowHeight(41);
        $sheet->getColumnDimension('B')->setWidth(260 / 7);
        $sheet->getStyle("A9:{$lastCol}9")->getFont()->setBold(true);
        $sheet->getStyle("A9:{$lastCol}9")->getAlignment()->setWrapText(true);

        $row = 10;
        foreach ($sections as [$title, $shifts]) {
            if ($title !== null) {
                $row++; // blank row before the section
                $sheet->setCellValue("B{$row}", $title);
                $sheet->getStyle("B{$row}")->applyFromArray([
                    'font' => ['bold' => true],
                    'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'FFFF00']],
                ]);
                $row++;
            }

            $byEmployee = [];
            foreach ($shifts as $s) {
                $byEmployee[$s['employee_management_id']]['name'] = $s['employee_name'];
                $byEmployee[$s['employee_management_id']]['shifts'][] = $s;
            }

            $n = 0;
            foreach ($byEmployee as $emp) {
                $perDay = [];
                $reg = 0;
                $ot = 0;
                foreach ($emp['shifts'] as $s) {
                    $perDay[$s['record_date']] = ($perDay[$s['record_date']] ?? 0) + $s['hours'];
                    $reg += $s['hours'];
                    $ot  += $s['ot'];
                }

                $sheet->setCellValue("A{$row}", ++$n);
                $sheet->setCellValue("B{$row}", $emp['name']);
                foreach ($days as $i => $d) {
                    if (isset($perDay[$d->format('Y-m-d')])) {
                        $sheet->setCellValue($col($firstDay + $i) . $row, $perDay[$d->format('Y-m-d')]);
                    }
                }
                $sheet->setCellValue($col($daysCol) . $row, count($perDay));
                $sheet->setCellValue($col($regCol) . $row, $reg);
                $sheet->setCellValue($col($otCol) . $row, $ot);
                $sheet->setCellValue($col($totalCol) . $row, $reg + $ot);
                $row++;
            }
        }

        // One TOTAL row for the sheet: day columns and REG / OT / TOTAL HRS.
        $lastData = $row - 1;
        $sheet->setCellValue("B{$row}", 'TOTAL');
        foreach (array_merge(range($firstDay, $lastDay), [$regCol, $otCol, $totalCol]) as $c) {
            $sheet->setCellValue($col($c) . $row, "=SUM({$col($c)}10:{$col($c)}{$lastData})");
        }
        $sheet->getStyle("A{$row}:{$lastCol}{$row}")->getFont()->setBold(true);

        $sheet->getStyle("A9:{$lastCol}{$row}")->applyFromArray([
            'borders'   => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['rgb' => '000000']]],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
        ]);

        // Signatories: title, name, designation — 6 blank rows below the table.
        $row += 7;
        foreach (self::SIGNATORIES as $column => [$label, $name, $designation]) {
            $sheet->setCellValue("{$column}{$row}", $label);
            $sheet->setCellValue("{$column}" . ($row + 2), $name);
            $sheet->setCellValue("{$column}" . ($row + 4), $designation);
            foreach ([$row, $row + 2, $row + 4] as $r) {
                $sheet->getStyle("{$column}{$r}")->getFont()->setBold(true);
                $sheet->getStyle("{$column}{$r}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
            }
        }
    }

    /** "DUTY SUMMARY FOR THE MONTH OF August 10-26, 2026" (month repeated when the period spans two). */
    protected function title(array $days): string
    {
        if (empty($days)) return 'DUTY SUMMARY';

        /** @var Carbon $first */
        $first = reset($days);
        /** @var Carbon $last */
        $last = end($days);

        $to = $first->format('Y-m') === $last->format('Y-m') ? $last->format('d, Y') : $last->format('F d, Y');

        return 'DUTY SUMMARY FOR THE MONTH OF ' . $first->format('F d') . '-' . $to;
    }
}

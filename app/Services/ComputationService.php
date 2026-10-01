<?php

namespace App\Services;

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ComputationService
{
    /**
     * Calculate ordinary day (ORD) overtime, night differential, and ND-OT hours.
     * Returns [ord_ot_hours, ord_nd_hours, ord_nd_ot_hours]
     */
    public function autocalculateOrd($row, $non_working_days, $data, $engine, $conn, $biometric_imports_id): array
    {
        try {
            $record_date = substr($row['record_date'], 0, 10);

            $cleaned_nwd = array_map(fn($d) => trim(str_replace("'", "", $d)), $non_working_days);
            if (in_array($record_date, $cleaned_nwd)) {
                return [0, 0, 0];
            }

            if (!empty($row['leaves'])) {
                return [0, 0, 0];
            }

            $earliest = $row['earliest_time'] ?? null;
            $latest   = $row['latest_time']   ?? '00:00:00';

            if (!$earliest || $earliest === $latest) {
                return [0, 0, 0];
            }

            // Resolve schedule: check temp adjustments first, then employee master
            $employee_name = $row['employee_name'];
            $schedule = null;

            $tempMatch = DB::table('schedule_adjustments')
                ->join('employee_management', 'employee_management.id', '=', 'schedule_adjustments.employee_management_id')
                ->where('employee_management.employee_name', $employee_name)
                ->whereRaw("DATE(schedule_adjustments.record_date) = ?", [$record_date])
                ->value('schedule_adjustments.schedule');

            if ($tempMatch) {
                $schedule = $tempMatch;
            } else {
                foreach ($data as $d) {
                    $name = is_array($d) ? ($d['employee_name'] ?? null) : ($d->employee_name ?? null);
                    if ($name === $employee_name) {
                        $schedule = is_array($d) ? ($d['schedule'] ?? null) : ($d->schedule ?? null);
                        break;
                    }
                }
            }

            if (!$schedule) {
                return [0, 0, 0];
            }

            // SG Vesta security: auto-detect 7-19 vs 19-7 by earliest time proximity
            if (strtolower(trim($row['department'] ?? '')) === 'sg vesta') {
                $earSec = $this->timeToSeconds($earliest);
                $schedule = (abs($earSec - 7 * 3600) <= abs($earSec - 19 * 3600)) ? '7-19' : '19-7';
            }

            // Regular window = 8 worked hours + 1-hr break = 9 hours elapsed before OT starts;
            // schedules with no built-in break keep the flat 8-hour cutoff.
            $noBreakSchedules = ['15-23', '23-7'];
            $regularLimit = in_array($schedule, $noBreakSchedules) ? 8 * 3600 : 9 * 3600;

            $w = $this->otWindows($schedule, $earliest, $latest, $regularLimit);
            if ($w === null) {
                return [0, 0, 0];
            }

            return [
                round($w['ot'] / 3600, 2),
                round($w['regular_nd'] / 3600, 2),
                round($w['nd_ot'] / 3600, 2),
            ];

        } catch (\Exception $ex) {
            Log::error("autocalculateOrd error: {$ex->getMessage()}");
            return [0, 0, 0];
        }
    }

    /**
     * Calculate rest day (RD) base hours, RD-OT, RD-ND, and RD-ND-OT.
     * Only runs when record_date falls on a non-working day.
     * Returns ['rd', 'rd_ot', 'rd_nd', 'rd_nd_ot']
     */
    public function autocalculateRdAndOvertime(array $row, $data): array
    {
        $zero = ['rd' => 0, 'rd_ot' => 0, 'rd_nd' => 0, 'rd_nd_ot' => 0];

        try {
            $recordDate = substr($row['record_date'], 0, 10);

            if (!empty($row['leaves'])) {
                return $zero;
            }

            // Load non-working days from DB (not config)
            $nonWorkingDays = DB::table('custom_dates')
                ->pluck('record_date')
                ->map(fn($d) => substr($d, 0, 10))
                ->toArray();

            if (!in_array($recordDate, $nonWorkingDays)) {
                return $zero;
            }

            $employee_name = $row['employee_name'];
            $schedule = null;

            $tempMatch = DB::table('schedule_adjustments')
                ->join('employee_management', 'employee_management.id', '=', 'schedule_adjustments.employee_management_id')
                ->where('employee_management.employee_name', $employee_name)
                ->whereRaw("DATE(schedule_adjustments.record_date) = ?", [$recordDate])
                ->value('schedule_adjustments.schedule');

            if ($tempMatch) {
                $schedule = $tempMatch;
            } else {
                if ($data instanceof \Illuminate\Support\Collection) {
                    $emp = $data->firstWhere('employee_name', $employee_name);
                    $schedule = $emp->schedule ?? ($emp['schedule'] ?? null);
                } else {
                    foreach ((array)$data as $d) {
                        $name = is_array($d) ? ($d['employee_name'] ?? null) : ($d->employee_name ?? null);
                        if ($name === $employee_name) {
                            $schedule = is_array($d) ? ($d['schedule'] ?? null) : ($d->schedule ?? null);
                            break;
                        }
                    }
                }
            }

            if (!$schedule) {
                return $zero;
            }

            $earSec = $this->timeToSeconds($row['earliest_time'] ?? '00:00:00');
            $latSec = $this->timeToSeconds($row['latest_time']   ?? '00:00:00');

            if ($earSec === $latSec) {
                return $zero;
            }

            // SG Vesta auto-schedule
            if (strtolower(trim($row['department'] ?? '')) === 'sg vesta') {
                $schedule = (abs($earSec - 7 * 3600) <= abs($earSec - 19 * 3600)) ? '7-19' : '19-7';
            }

            // RD base hours by shift type
            $startHourOfDay = (int) (($earSec % 86400) / 3600);
            $dayShifts = ['7-16', '8-17', '7-19', '6-15', '9-15', '10-18', '10-16'];
            $rdHours   = 0;

            if (in_array($schedule, $dayShifts)) {
                $rdHours = 8;
            } elseif ($schedule === '15-24') {
                if ($startHourOfDay >= 15) $rdHours = 6;
            } elseif ($schedule === '23-8') {
                if ($startHourOfDay >= 23) $rdHours = 2;
            } elseif ($schedule === '23-7') {
                if ($startHourOfDay >= 23) $rdHours = 1;
            }

            // Beyond 9 hours is OT on a rest day (8 hrs regular + 1 hr break)
            $w = $this->otWindows($schedule, $row['earliest_time'] ?? null, $row['latest_time'] ?? null, 9 * 3600);
            if ($w === null) {
                return $zero;
            }

            return [
                'rd'       => round($rdHours, 2),
                'rd_ot'    => round($w['ot'] / 3600, 2),
                'rd_nd'    => round($w['regular_nd'] / 3600, 2),
                'rd_nd_ot' => round($w['nd_ot'] / 3600, 2),
            ];

        } catch (\Throwable $e) {
            Log::error("autocalculateRdAndOvertime error: {$e->getMessage()}");
            return $zero;
        }
    }

    /**
     * Insert or update an overtime record.
     * Converts float hours to HH:MM strings before persisting.
     */
    public function logOvertimeDb(
        $row,
        $ord_ot,
        $rd_ot,
        $ord_nd,
        $ord_nd_ot,
        $rd,
        $rd_nd,
        $rd_nd_ot,
        $total_non_working_days_present,
        $late,
        $late_hours,
        $late_minutes,
        $out_time_required,
        $type,
        $schedule,
        $status,
        $biometric_imports_id,
        $attendance_records_id,
        $schedule_shift,
        $update_target
    ) {
        $toHM = function ($hours) {
            if ($hours === null) return '00:00';
            $totalMinutes = (int) round($hours * 60);
            return sprintf('%02d:%02d', intdiv($totalMinutes, 60), $totalMinutes % 60);
        };

        $trimDays = fn($ts) => preg_replace('/^\d+\s+days?\s+/', '', trim((string)($ts ?? '')));

        $nameParts    = explode(',', $row['employee_name']);
        $last         = trim($nameParts[0] ?? '');
        $first        = trim($nameParts[1] ?? '');
        $employeeName = "$last, $first";

        $recordDate = $row['record_date'] ?? DB::table('attendance_records')
            ->where('id', $attendance_records_id)
            ->value('record_date');

        $earliest = $trimDays($row['earliest_time'] ?? '00:00:00');
        $latest   = $trimDays($row['latest_time']   ?? '00:00:00');

        $employee       = DB::table('employee_management')->where('employee_name', $row['employee_name'])->first();
        $id_str         = $employee->unique_id   ?? 'TMNG-000000-000';
        $department     = $employee->department  ?? null;
        $serial_number  = $employee->serial_number ?? null;
        $attendance_area = $row['Attendance Area'] ?? null;

        // Late is always derived from the punches and schedule (callers pass placeholders). No late
        // on rest days, holidays or leave days.
        $isNonWorking = DB::table('custom_dates')->whereRaw('DATE(record_date) = ?', [substr((string) $recordDate, 0, 10)])->exists();
        $lateMinutes = ($isNonWorking || !empty($row['leaves']))
            ? 0
            : $this->lateAndUndertime($schedule ?? ($employee->schedule ?? null), $earliest, $latest, $department)['late_minutes'];
        $late         = $lateMinutes > 0;
        $late_hours   = intdiv($lateMinutes, 60);
        $late_minutes = $lateMinutes % 60;

        $newEntry = [
            'unique_id'                      => $id_str,
            'first_name'                     => $first,
            'last_name'                      => $last,
            'employee_name'                  => $employeeName,
            'record_date'                    => $recordDate,
            'earliest_time'                  => $earliest,
            'latest_time'                    => $latest,
            'type'                           => $type,
            'department'                     => $department,
            'attendance_area'                => $attendance_area,
            'serial_number'                  => $serial_number,
            'schedule'                       => $schedule,
            'ord_ot'                         => $toHM($ord_ot),
            'rd_ot'                          => $toHM($rd_ot),
            'ord_nd'                         => $toHM($ord_nd),
            'ord_nd_ot'                      => $toHM($ord_nd_ot),
            'rd'                             => $toHM($rd),
            'rd_nd'                          => $toHM($rd_nd),
            'rd_nd_ot'                       => $toHM($rd_nd_ot),
            'total_non_working_days_present' => $total_non_working_days_present,
            'late'                           => $late,
            'late_hours'                     => $late_hours,
            'late_minutes'                   => $late_minutes,
            'out_time_required'              => $out_time_required,
            'status'                         => $status,
            'biometric_imports_id'           => $biometric_imports_id,
            'attendance_records_id'          => $attendance_records_id,
            'schedule_shift'                 => $schedule_shift,
            'employee_management_id'         => $row['employee_management_id'] ?? ($employee->id ?? null),
        ];

        DB::beginTransaction();
        try {
            $existing = DB::table('overtimes')
                ->where('employee_name', $employeeName)
                ->where('record_date', $recordDate)
                ->where('type', $type)
                ->where('biometric_imports_id', $biometric_imports_id)
                ->where('attendance_records_id', $attendance_records_id)
                ->first();

            if ($existing) {
                $existingId = $existing->id;

                if ($type === 'ord') {
                    if ($newEntry['ord_ot']    !== $existing->ord_ot
                     || $newEntry['ord_nd']    !== $existing->ord_nd
                     || $newEntry['ord_nd_ot'] !== $existing->ord_nd_ot) {
                        DB::table('overtimes')->where('id', $existingId)->update([
                            'ord_ot'         => $newEntry['ord_ot'],
                            'ord_nd'         => $newEntry['ord_nd'],
                            'ord_nd_ot'      => $newEntry['ord_nd_ot'],
                            'schedule_shift' => $schedule_shift,
                            'schedule'       => $schedule,
                        ]);
                    }
                } elseif ($type === 'rd') {
                    if ($update_target === 'rd') {
                        DB::table('overtimes')->where('id', $existingId)->update([
                            'rd'             => $newEntry['rd'],
                            'schedule_shift' => $schedule_shift,
                            'schedule'       => $schedule,
                        ]);
                    } elseif ($update_target === 'rd_ot') {
                        DB::table('overtimes')->where('id', $existingId)->update([
                            'rd_ot'          => $newEntry['rd_ot'],
                            'rd_nd'          => $newEntry['rd_nd'],
                            'rd_nd_ot'       => $newEntry['rd_nd_ot'],
                            'schedule_shift' => $schedule_shift,
                            'schedule'       => $schedule,
                        ]);
                    }
                }

                DB::commit();
                return $existingId;
            }

            $newId = DB::table('overtimes')->insertGetId(array_merge($newEntry, [
                'created_at' => now(),
                'updated_at' => now(),
            ]));

            DB::commit();
            return $newId;

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("logOvertimeDb insert failed: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Insert or update a security_attendance record.
     * Used for employees in the Security department.
     */
    public function logSecurityDb($row, $type, $hours, $biometric_imports_id, $attendance_records_id): void
    {
        try {
            $employeeName = (string)($row['employee_name'] ?? '');
            $recordDate   = substr($row['record_date'] ?? '', 0, 10);
            $earliestTime = (string)($row['earliest_time'] ?? '00:00:00');
            $latestTime   = (string)($row['latest_time']   ?? '00:00:00');

            if (!$recordDate) {
                Log::info("logSecurityDb: no record_date for {$employeeName}, skipping.");
                return;
            }

            $weekday = Carbon::parse($recordDate)->format('l');

            DB::beginTransaction();

            $employee = DB::table('employee_management')->where('employee_name', $employeeName)->first();
            if (!$employee) {
                Log::info("logSecurityDb: employee not found for {$employeeName}.");
                DB::rollBack();
                return;
            }

            $existing = DB::table('security_attendance')
                ->where('employee_management_id', $employee->id)
                ->where('record_date', $recordDate)
                ->where('earliest_time', $earliestTime)
                ->where('latest_time', $latestTime)
                ->where('biometric_imports_id', $biometric_imports_id)
                ->first();

            if ($existing) {
                $update = match ($type) {
                    'hours_worked' => ['hours_worked' => $hours],
                    'OT'           => ['ot' => $hours],
                    'ND'           => ['nd' => $hours],
                    default        => null,
                };
                if ($update) {
                    DB::table('security_attendance')->where('id', $existing->id)->update($update);
                }
            } else {
                $insert = [
                    'employee_management_id' => $employee->id,
                    'record_date'            => $recordDate,
                    'weekday'                => $weekday,
                    'earliest_time'          => $earliestTime,
                    'latest_time'            => $latestTime,
                    'biometric_imports_id'   => $biometric_imports_id,
                    'attendance_records_id'  => $attendance_records_id,
                    'created_at'             => now(),
                    'updated_at'             => now(),
                ];
                if ($type === 'hours_worked') $insert['hours_worked'] = $hours;
                elseif ($type === 'OT')       $insert['ot']           = $hours;
                elseif ($type === 'ND')       $insert['nd']           = $hours;

                DB::table('security_attendance')->insert($insert);
            }

            DB::commit();

        } catch (\Exception $ex) {
            DB::rollBack();
            Log::error("logSecurityDb failed for {$row['employee_name']}: {$ex->getMessage()}");
        }
    }

    /**
     * Day-to-night shift adjustment with snapshot preservation.
     *
     * 1. Saves the original overtime record to a JSON snapshot file before any changes.
     * 2. Builds full Carbon datetimes (date + time) so a crossing-midnight shift like
     *    19:00 → 07:00 produces a positive 12-hour duration instead of -12 hours.
     * 3. Calculates OT = max(total_duration - 8 standard hours, 0).
     * 4. Returns the adjusted schedule data and a reference key pointing to the snapshot.
     *
     * @param  array        $adjustmentData        Schedule adjustment row (id, record_date, schedule, earliest_time, latest_time, etc.)
     * @param  object|null  $originalOvertimeRecord Existing overtimes row for this attendance record (may be null)
     * @param  string       $snapshotPath          Absolute path to the JSON file where originals are appended
     * @return array        ['adjusted' => [...], 'snapshot_ref' => '...', 'original' => [...]]
     */
    public function adjustShiftWithSnapshot(
        array   $adjustmentData,
        ?object $originalOvertimeRecord,
        string  $snapshotPath
    ): array {
        $nightShifts   = ['18-6', '19-7', '19-4', '20-5', '15-23', '15-24', '23-7', '23-8'];
        $standardHours = 8;

        $newSchedule  = $adjustmentData['schedule']       ?? null;
        $recordDate   = substr($adjustmentData['record_date'] ?? '', 0, 10);
        $earliestTime = $adjustmentData['earliest_time']  ?? null;
        $latestTime   = $adjustmentData['latest_time']    ?? null;

        if (!$newSchedule || !$recordDate) {
            return ['error' => 'Missing schedule or record_date'];
        }

        // ── Step 1: Preserve original data ──────────────────────────────────────
        $snapshotRef  = 'SNAP-' . ($adjustmentData['attendance_records_id'] ?? 'new') . '-' . time();
        $originalData = [
            'ref'                    => $snapshotRef,
            'saved_at'               => now()->toIso8601String(),
            'adjustment_id'          => $adjustmentData['id']                   ?? null,
            'attendance_records_id'  => $adjustmentData['attendance_records_id'] ?? null,
            'employee_name'          => $adjustmentData['employee_name']         ?? null,
            'record_date'            => $recordDate,
            'original_schedule'      => $originalOvertimeRecord->schedule        ?? null,
            'original_earliest_time' => $originalOvertimeRecord->earliest_time   ?? null,
            'original_latest_time'   => $originalOvertimeRecord->latest_time     ?? null,
            'original_ot' => [
                'ord_ot'    => $originalOvertimeRecord->ord_ot    ?? '00:00',
                'ord_nd'    => $originalOvertimeRecord->ord_nd    ?? '00:00',
                'ord_nd_ot' => $originalOvertimeRecord->ord_nd_ot ?? '00:00',
                'rd'        => $originalOvertimeRecord->rd        ?? '00:00',
                'rd_ot'     => $originalOvertimeRecord->rd_ot     ?? '00:00',
                'rd_nd'     => $originalOvertimeRecord->rd_nd     ?? '00:00',
                'rd_nd_ot'  => $originalOvertimeRecord->rd_nd_ot  ?? '00:00',
            ],
        ];

        $existing   = file_exists($snapshotPath)
            ? (json_decode(file_get_contents($snapshotPath), true) ?? [])
            : [];
        $existing[] = $originalData;
        file_put_contents($snapshotPath, json_encode($existing, JSON_PRETTY_PRINT));

        // ── Step 2: Parse schedule start/end hours ───────────────────────────────
        [$startStr, $endStr] = explode('-', $newSchedule);
        $startHour = (int)$startStr;
        $endHour   = (int)$endStr;

        // ── Step 3: Full datetime so midnight-crossing gives a positive duration ─
        // e.g. 19-7: end 07:00 < start 19:00 → push end to next calendar day
        $startDt = Carbon::parse("{$recordDate} {$startHour}:00:00");
        $endDt   = Carbon::parse("{$recordDate} {$endHour}:00:00");
        if ($endDt->lte($startDt)) {
            $endDt->addDay();
        }

        // Use actual punch times when available for a more precise duration
        if ($earliestTime && $latestTime) {
            $punchIn  = Carbon::parse("{$recordDate} {$earliestTime}");
            $punchOut = Carbon::parse("{$recordDate} {$latestTime}");
            if ($punchOut->lte($punchIn)) {
                $punchOut->addDay(); // punch-out is on next calendar day
            }
            $durationSeconds = $punchIn->diffInSeconds($punchOut);
        } else {
            $durationSeconds = $startDt->diffInSeconds($endDt);
        }

        $durationHours = $durationSeconds / 3600;

        // ── Step 4: OT = total duration − standard 8 hours; zero when no excess ─
        $otHours         = max($durationHours - $standardHours, 0);
        $crossesMidnight = ($endHour < $startHour) || in_array($newSchedule, $nightShifts);

        $toHM = fn($h) => sprintf(
            '%02d:%02d',
            (int)floor($h),
            (int)round(($h - floor($h)) * 60)
        );

        return [
            'adjusted' => [
                'schedule'         => $newSchedule,
                'earliest_time'    => $earliestTime ?? sprintf('%02d:00:00', $startHour),
                'latest_time'      => $latestTime   ?? sprintf('%02d:00:00', $endHour),
                'duration_hours'   => round($durationHours, 2),
                'ot_hours'         => round($otHours, 2),
                'ot_formatted'     => $toHM($otHours),
                'crosses_midnight' => $crossesMidnight,
                'standard_hours'   => $standardHours,
            ],
            'snapshot_ref' => $snapshotRef,
            'original'     => $originalData['original_ot'],
        ];
    }

    /**
     * Recompute ORD/RD fields for one attendance_records row and sync its overtimes row.
     * Used after a manual add/edit of Time In / Time Out. The formulas themselves are
     * untouched — this only feeds the stored times through autocalculateOrd/Rd.
     */
    public function recomputeForAttendanceRecord(int $attendanceRecordId, int $biometricImportId): void
    {
        $record = DB::table('attendance_records as ar')
            ->join('employee_management as em', 'em.id', '=', 'ar.employee_management_id')
            ->where('ar.id', $attendanceRecordId)
            ->select('ar.*', 'em.employee_name', 'em.department', 'em.schedule', 'em.schedule_shift')
            ->first();

        if (!$record) return;

        $nonWorkingDays = DB::table('custom_dates')->pluck('record_date')->map(fn($d) => substr($d, 0, 10))->toArray();
        $employeeData   = DB::table('employee_management')->get()->toArray();

        $rowData = [
            'employee_name'          => $record->employee_name,
            'employee_management_id' => $record->employee_management_id,
            'record_date'            => substr($record->record_date, 0, 10),
            'earliest_time'          => $record->earliest_time,
            'latest_time'            => $record->latest_time,
            'department'             => $record->department ?? '',
            'leaves'                 => (bool) $record->leaves,
        ];

        [$ordOt, $ordNd, $ordNdOt] = $this->autocalculateOrd(
            $rowData, $nonWorkingDays, $employeeData, null, null, $biometricImportId
        );

        $rdResult = $this->autocalculateRdAndOvertime($rowData, collect($employeeData));

        $existing = DB::table('overtimes')
            ->where('attendance_records_id', $attendanceRecordId)
            ->where('biometric_imports_id', $biometricImportId)
            ->first();

        if ($existing) {
            // logOvertimeDb's update branch leaves times and RD fields alone, so update
            // every field here. Approval status is kept as-is.
            $toHM = function ($hours) {
                $m = (int) round(($hours ?? 0) * 60);
                return sprintf('%02d:%02d', intdiv($m, 60), $m % 60);
            };

            DB::table('overtimes')->where('id', $existing->id)->update([
                'earliest_time' => $record->earliest_time,
                'latest_time'   => $record->latest_time,
                'ord_ot'        => $toHM($ordOt),
                'ord_nd'        => $toHM($ordNd),
                'ord_nd_ot'     => $toHM($ordNdOt),
                'rd'            => $toHM($rdResult['rd']),
                'rd_ot'         => $toHM($rdResult['rd_ot']),
                'rd_nd'         => $toHM($rdResult['rd_nd']),
                'rd_nd_ot'      => $toHM($rdResult['rd_nd_ot']),
                'updated_at'    => now(),
            ]);
            return;
        }

        $this->logOvertimeDb(
            $rowData,
            $ordOt, $rdResult['rd_ot'], $ordNd, $ordNdOt,
            $rdResult['rd'], $rdResult['rd_nd'], $rdResult['rd_nd_ot'],
            0, false, 0, 0, null,
            'ord', $record->schedule ?? null,
            'Pending', $biometricImportId,
            $attendanceRecordId,
            $record->schedule_shift ?? null, 'ord'
        );
    }

    /** A day's OT (OT + ND-OT) below this is not counted as OT at all; at or above it counts in full. */
    public const OT_MINIMUM_SECONDS = 60 * 60;

    /**
     * Regular and OT windows for one day, to the minute (punch seconds are ignored).
     *
     * - Paid start: the schedule start when on time, early or within the 15-minute grace (arriving
     *   early adds nothing); when late beyond grace, schedule start + 1 hour, or the actual arrival
     *   if that is later.
     * - Regular window: paid start + $regularLimitSec. OT: from the end of the regular window to the
     *   last punch.
     * - ND: the exact minutes of each window inside 22:00-06:00 (midnight crossing handled).
     * - OT minimum: if OT + ND-OT is under 1 hour, both are 0; otherwise both count in full.
     *
     * Returns seconds ['regular_nd', 'ot', 'nd_ot'], or null without a usable schedule/punch pair.
     */
    public function otWindows(?string $schedule, ?string $earliest, ?string $latest, int $regularLimitSec): ?array
    {
        if (!$earliest || !$latest || !$schedule || !preg_match('/^\s*(\d{1,2})\s*-/', $schedule, $m)) {
            return null;
        }

        $earSec = $this->minuteSeconds($earliest);
        $latSec = $this->minuteSeconds($latest);
        if ($earSec === $latSec) {
            return null;
        }

        // Everything below is measured in seconds from the schedule start
        $startSec = ((int) $m[1] % 24) * 3600;
        $arrival = ($earSec - $startSec + 86400) % 86400;
        if ($arrival > 43200) {
            $arrival -= 86400; // arrived before the start
        }
        $span = $latSec >= $earSec ? $latSec - $earSec : $latSec + 86400 - $earSec;
        $out = $arrival + $span;

        $in = $arrival > self::GRACE_SECONDS ? max($arrival, 3600) : 0;
        $regularEnd = $in + $regularLimitSec;

        $ndOverlap = function (int $from, int $to) use ($startSec): int {
            if ($to <= $from) {
                return 0;
            }
            $total = 0;
            // ND windows 22:00-06:00 around the shift, expressed relative to the schedule start
            for ($day = -1; $day <= 2; $day++) {
                $ndStart = $day * 86400 + 22 * 3600 - $startSec;
                $ndEnd = $ndStart + 8 * 3600;
                $total += max(0, min($to, $ndEnd) - max($from, $ndStart));
            }

            return $total;
        };

        $regularNd = $ndOverlap($in, min($out, $regularEnd));
        $otTotal = max(0, $out - $regularEnd);
        $ndOt = $ndOverlap($regularEnd, $out);
        $ot = $otTotal - $ndOt;

        if ($otTotal < self::OT_MINIMUM_SECONDS) {
            $ot = $ndOt = 0;
        }

        return ['regular_nd' => $regularNd, 'ot' => $ot, 'nd_ot' => $ndOt];
    }

    /** Arriving up to this many seconds after the schedule start is not late. */
    public const GRACE_SECONDS = 15 * 60;

    /**
     * Late and undertime for one day, in whole minutes. Punch times are read to the minute only
     * (seconds are dropped: 15:57:09 counts as 15:57).
     *
     * - Late: minutes after the schedule start, counted in full (20 minutes late = 20) but only
     *   when beyond the 15-minute grace period; within the grace period it is 0.
     * - Undertime: every minute the last punch falls before the schedule end; no tolerance.
     *
     * Schedules are "start-end" hours (e.g. 7-16, 19-7 across midnight). SG Vesta picks 7-19 or
     * 19-7 from the first punch, as in autocalculateOrd(). Returns zeros when there is no usable
     * schedule or punch pair.
     */
    public function lateAndUndertime(?string $schedule, ?string $earliest, ?string $latest, ?string $department = null): array
    {
        $none = ['late_minutes' => 0, 'undertime_minutes' => 0, 'shift_minutes' => null, 'schedule' => null];
        if (!$earliest || !$latest || $earliest === $latest) {
            return $none;
        }

        $earSec = $this->minuteSeconds($earliest);
        $latSec = $this->minuteSeconds($latest);

        if (strtolower(trim((string) $department)) === 'sg vesta') {
            $schedule = abs($earSec - 7 * 3600) <= abs($earSec - 19 * 3600) ? '7-19' : '19-7';
        }
        if (!$schedule || !preg_match('/^\s*(\d{1,2})\s*-\s*(\d{1,2})/', $schedule, $m)) {
            return $none;
        }

        $startSec = ((int) $m[1] % 24) * 3600;
        $shiftSec = ((((int) $m[2] - (int) $m[1]) % 24 + 24) % 24 ?: 24) * 3600;

        // Position of the punches relative to the schedule start (early arrival is negative)
        $arrival = ($earSec - $startSec + 86400) % 86400;
        if ($arrival > 43200) {
            $arrival -= 86400;
        }
        $span = $latSec >= $earSec ? $latSec - $earSec : $latSec + 86400 - $earSec;
        $departure = $arrival + $span;

        $lateSec = $arrival > self::GRACE_SECONDS ? $arrival : 0;
        $undertimeSec = max($shiftSec - $departure, 0);

        return [
            'late_minutes' => intdiv($lateSec, 60),
            'undertime_minutes' => intdiv($undertimeSec, 60),
            'shift_minutes' => intdiv($shiftSec, 60), // scheduled start to end, break included
            'schedule' => $schedule,                    // after SG Vesta 7-19 / 19-7 detection
        ];
    }

    /** Seconds from midnight to the punch's minute (the seconds part is ignored). */
    public function minuteSeconds(?string $timeStr): int
    {
        $seconds = $this->timeToSeconds($timeStr);

        return $seconds - $seconds % 60;
    }

    /**
     * Convert a HH:MM:SS time string to total seconds from midnight.
     */
    public function timeToSeconds(?string $timeStr): int
    {
        if (!$timeStr) return 0;
        $parts = explode(':', $timeStr);
        return ((int)($parts[0] ?? 0)) * 3600
             + ((int)($parts[1] ?? 0)) * 60
             + ((int)($parts[2] ?? 0));
    }
}

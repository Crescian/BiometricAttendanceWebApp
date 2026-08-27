<?php

namespace App\Services;

use Carbon\Carbon;
use Carbon\CarbonInterval;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use PhpOffice\PhpSpreadsheet\IOFactory;
use App\Services\ComputationService;

class AttendanceProcessor
{
    /**
     * Main entrypoint porting convert_file -> perform_conversion
     *
     * @param string $filePath
     * @param string $outputDir
     * @param int $biometricImportsId
     * @return array
     */
    public function processFile(string $filePath, string $outputDir, int $biometricImportsId): array
    {
        Log::info('AttendanceProcessor: start', ['file' => $filePath, 'biometric' => $biometricImportsId]);

        // 1. load schedules and relievers
        $tempSched = $this->loadTempSchedules(); // [ 'Last, First' => [ 'YYYY-MM-DD' => '19-7', ... ], ... ]
        $employeeSchedules = $this->loadEmployeeSchedules(); // ['schedules'=>[], 'relievers'=>[]]

        // 2. read file (skip first row)
        $rows = $this->readAttendanceFile($filePath);
        if (empty($rows)) {
            return ['error' => 'No attendance rows found', 'log' => [], 'preview' => $this->makePreview($filePath)];
        }

        // 3. group by Personnel ID and sort punches
        $grouped = $this->groupByPersonnelId($rows);

        $processed = [];
        foreach ($grouped as $pid => $punchList) {
            $recs = $this->processPersonPunches($pid, $punchList, $tempSched, $employeeSchedules);
            foreach ($recs as $r) $processed[] = $r;
        }

        // 4. insert attendance_records and capture stats
        $stats = $this->insertAttendanceRecords($processed, $biometricImportsId);

        // 5. Optionally calculate hours/OT for new records (we implement a basic version here)
        $this->calculateHoursForBiometricImport($biometricImportsId);

        $preview = $this->makePreview($filePath);

        Log::info('AttendanceProcessor: finished', ['records' => count($processed), 'stats' => $stats]);

        return ['preview' => $preview, 'stats' => $stats];
    }

    /**
     * Load schedule_adjustments joined with employee_management → build map
     */
    protected function loadTempSchedules(): array
    {
        $rows = DB::select("
            SELECT sa.record_date, em.employee_name, sa.schedule
            FROM schedule_adjustments sa
            INNER JOIN employee_management em ON em.id = sa.employee_management_id
        ");

        $out = [];
        foreach ($rows as $r) {
            $name = trim($r->employee_name);
            $date = substr($r->record_date, 0, 10);
            $schedRaw = (string)$r->schedule;
            if (preg_match('/\b\d{1,2}-\d{1,2}\b/', $schedRaw, $m)) $sched = $m[0];
            else $sched = trim($schedRaw);
            $out[$name][$date] = $sched;
        }
        return $out;
    }

    /**
     * Load employee schedules + reliever flag
     */
    protected function loadEmployeeSchedules(): array
    {
        $rows = DB::select("SELECT employee_name, schedule, relievers FROM employee_management");
        $schedules = [];
        $relievers = [];
        foreach ($rows as $r) {
            $name = trim($r->employee_name);
            $schedules[$name] = trim((string)$r->schedule);
            $relievers[$name] = !empty($r->relievers);
        }
        return ['schedules' => $schedules, 'relievers' => $relievers];
    }

    /**
     * Read CSV or XLSX and skip first row. Map columns to expected fields.
     * The expected column order for CSV is:
     * 0 => Personnel ID, 1 => First Name, 2 => Last Name, 3 => Attendance time
     */
    protected function readAttendanceFile(string $filePath): array
    {
        $ext = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
        $rows = [];

        if (in_array($ext, ['xls', 'xlsx'])) {

            $spreadsheet = IOFactory::load($filePath);
            $sheet = $spreadsheet->getActiveSheet();

            $data = $sheet->toArray(null, true, true, true);

            // ❗ Skip first TWO rows:
            // Row 1 = "Transactions"
            // Row 2 = actual header row
            array_shift($data);
            array_shift($data);

            foreach ($data as $r) {

                // Stop if row is empty
                if (empty($r['A']) && empty($r['H'])) continue;

                $rows[] = [
                    'Personnel ID'          => $r['A'] ?? null,
                    'First Name'            => $r['B'] ?? null,
                    'Last Name'             => $r['C'] ?? null,
                    'Department Name'       => $r['D'] ?? null,
                    'Attendance Area'       => $r['E'] ?? null,
                    'Serial Number'         => $r['F'] ?? null,
                    'Attendance Point Name' => $r['G'] ?? null,
                    'Attendance time'       => $r['H'] ?? null,
                    'Verification Mode'     => $r['I'] ?? null,
                    'Attendance Photo'      => $r['J'] ?? null,
                    'Data Sources'          => $r['K'] ?? null,
                ];
            }

        } else {

            // CSV version (optional update: map same structure)
            if (($handle = fopen($filePath, 'r')) !== false) {

                // Skip 2 lines for CSV also
                $header1 = fgetcsv($handle);
                $header2 = fgetcsv($handle);

                while (($data = fgetcsv($handle)) !== false) {
                    $rows[] = [
                        'Personnel ID'          => $data[0] ?? null,
                        'First Name'            => $data[1] ?? null,
                        'Last Name'             => $data[2] ?? null,
                        'Department Name'       => $data[3] ?? null,
                        'Attendance Area'       => $data[4] ?? null,
                        'Serial Number'         => $data[5] ?? null,
                        'Attendance Point Name' => $data[6] ?? null,
                        'Attendance time'       => $data[7] ?? null,
                        'Verification Mode'     => $data[8] ?? null,
                        'Attendance Photo'      => $data[9] ?? null,
                        'Data Sources'          => $data[10] ?? null,
                    ];
                }

                fclose($handle);
            }
        }

        // Normalize Attendance time
        $clean = [];

        foreach ($rows as $r) {
            $at = trim($r['Attendance time'] ?? '');

            if ($at === '') continue;

            // Excel sample format: "8/11/2025 7:00"
            try {
                $dt = Carbon::createFromFormat('n/j/Y g:i', $at);
            } catch (\Exception $e) {
                try {
                    $dt = Carbon::parse($at);
                } catch (\Exception $e2) {
                    continue;
                }
            }

            $r['Attendance time'] = $dt;
            $clean[] = $r;
        }

        return $clean;
    }


    /**
     * Group rows by Personnel ID and sort by Attendance time asc
     */
    protected function groupByPersonnelId(array $rows): array
    {
        $g = [];
        foreach ($rows as $r) {
            $pid = (string)($r['Personnel ID'] ?? 'unknown');
            $g[$pid][] = $r;
        }
        foreach ($g as &$list) {
            usort($list, function($a, $b){
                return $a['Attendance time']->getTimestamp() <=> $b['Attendance time']->getTimestamp();
            });
        }
        return $g;
    }

    /**
     * Process punches of a single employee (reliever / night / day)
     * Returns list of simple records with fields compatible with attendance_records
     */
    protected function processPersonPunches($personId, array $punchList, array $tempSched, array $employeeSchedules): array
    {
        $schedules = $employeeSchedules['schedules'];
        $relievers = $employeeSchedules['relievers'];

        $first = $punchList[0] ?? null;
        if (!$first) return [];

        $firstName = trim($first['First Name'] ?? '');
        $lastName  = trim($first['Last Name'] ?? '');
        $employeeName = trim($lastName . ', ' . $firstName);

        $isReliever = $relievers[$employeeName] ?? false;
        $normalSchedule = $schedules[$employeeName] ?? null;

        // Carry biometric metadata from first punch (same for all punches of one person)
        $meta = [
            'Attendance Area'       => $first['Attendance Area']       ?? null,
            'Serial Number'         => $first['Serial Number']         ?? null,
            'Attendance Point Name' => $first['Attendance Point Name'] ?? null,
            'Verification Mode'     => $first['Verification Mode']     ?? null,
            'Attendance Photo'      => $first['Attendance Photo']      ?? null,
            'Data Sources'          => $first['Data Sources']          ?? null,
        ];

        // collect Carbon punches
        $punchTimes = array_map(fn($r) => $r['Attendance time'], $punchList);

        $records = [];
        // Reliever logic (paired evening + next day morning; else day pairing)
        if ($isReliever) {
            // group punches by date
            $byDate = [];
            foreach ($punchTimes as $t) {
                $byDate[$t->toDateString()][] = $t;
            }
            foreach ($byDate as $d => &$arr) sort($arr);
            foreach ($byDate as $dateKey => $dayPunches) {
                // look next day
                $nextDate = Carbon::parse($dateKey)->addDay()->toDateString();
                $nextPunches = $byDate[$nextDate] ?? [];
                // try pair evening + next day morning
                $evening = null;
                foreach ($dayPunches as $p) { if ($p->hour >= 12) { $evening = $p; break; } }
                $morning = null;
                foreach ($nextPunches as $p) { if ($p->hour < 12) { $morning = $p; break; } }

                if ($evening && $morning) {
                    $records[] = array_merge([
                        'employee_name' => $employeeName,
                        'record_date' => $evening->toDateString(),
                        'earliest_time' => $evening->format('H:i:s'),
                        'latest_time' => $morning->format('H:i:s'),
                        'Punch Time' => $evening->format('H:i:s') . ';' . $morning->format('H:i:s'),
                        'shift_type' => 'NIGHT',
                    ], $meta);
                    continue;
                }

                // else day pairing
                if (count($dayPunches) >= 2) {
                    $mor = $dayPunches[0];
                    $eve = end($dayPunches);
                    $records[] = array_merge([
                        'employee_name' => $employeeName,
                        'record_date' => $mor->toDateString(),
                        'earliest_time' => $mor->format('H:i:s'),
                        'latest_time' => $eve->format('H:i:s'),
                        'Punch Time' => $mor->format('H:i:s') . ';' . $eve->format('H:i:s'),
                        'shift_type' => 'DAY',
                    ], $meta);
                } elseif (count($dayPunches) === 1) {
                    $p = $dayPunches[0];
                    $records[] = array_merge([
                        'employee_name' => $employeeName,
                        'record_date' => $p->toDateString(),
                        'earliest_time' => $p->format('H:i:s'),
                        'latest_time' => $p->format('H:i:s'),
                        'Punch Time' => $p->format('H:i:s'),
                        'shift_type' => 'SINGLE',
                    ], $meta);
                }
            }
            return $records;
        }

        // Non-reliever: decide night-vs-day using codes (mirrors python nightShiftCodes)
        $nightShiftCodes = ["18-6","19-7","19-4","20-5","15-23","15-24","23-7","23-8"];
        $hasNightShift = false;
        $tempForEmployee = $tempSched[$employeeName] ?? [];
        if (!empty($tempForEmployee)) {
            foreach ($tempForEmployee as $d=>$sc) {
                if (in_array($sc, $nightShiftCodes)) { $hasNightShift = true; break; }
            }
        }
        if (!$hasNightShift && $normalSchedule && in_array($normalSchedule, $nightShiftCodes)) $hasNightShift = true;

        if ($hasNightShift) {
            // night pairing: find evening punches >= 14 and include punches within 12 hours
            $punches = $punchTimes;
            $used = array_fill(0, count($punches), false);
            foreach ($punches as $i => $p) {
                if ($p->hour >= 14 && !$used[$i]) {
                    $used[$i] = true;
                    $start = $p;
                    $endLimit = $p->copy()->addHours(12);
                    $set = [$p];
                    foreach ($punches as $j => $pj) {
                        if (!$used[$j] && $pj->gt($start) && $pj->lte($endLimit)) {
                            $used[$j] = true;
                            $set[] = $pj;
                        }
                    }
                    sort($set);
                    $ear = $set[0];
                    $lat = end($set);
                    $records[] = array_merge([
                        'employee_name' => $employeeName,
                        'record_date' => $ear->toDateString(),
                        'earliest_time' => $ear->format('H:i:s'),
                        'latest_time' => $lat->format('H:i:s'),
                        'Punch Time' => $ear->format('H:i:s') . ';' . $lat->format('H:i:s'),
                        'shift_type' => 'NIGHT',
                    ], $meta);
                }
            }
        } else {
            // Day shift: group by date -> earliest & latest
            $byDate = [];
            foreach ($punchTimes as $t) $byDate[$t->toDateString()][] = $t;
            foreach ($byDate as $d => $arr) {
                usort($arr, fn($a,$b) => $a->getTimestamp() <=> $b->getTimestamp());
                $ear = $arr[0];
                $lat = end($arr);
                $records[] = array_merge([
                    'employee_name' => $employeeName,
                    'record_date' => $ear->toDateString(),
                    'earliest_time' => $ear->format('H:i:s'),
                    'latest_time' => $lat->format('H:i:s'),
                    'Punch Time' => (count($arr) > 1) ? ($ear->format('H:i:s').';'.$lat->format('H:i:s')) : $ear->format('H:i:s'),
                    'shift_type' => 'DAY',
                ], $meta);
            }
        }

        return $records;
    }

    /**
     * Insert attendance_records with the duplicate checks used in Python
     */
    protected function insertAttendanceRecords(array $records, int $biometricImportsId): array
    {
        $stats = ['inserted' => 0, 'skipped_duplicate' => 0, 'skipped_same_time' => 0, 'skipped_no_emp' => 0];
        DB::beginTransaction();
        try {
            foreach ($records as $row) {
                $employeeName = $row['employee_name'] ?? null;
                if (!$employeeName) continue;

                $emp = DB::selectOne("SELECT id FROM employee_management WHERE employee_name = :name LIMIT 1", ['name' => $employeeName]);
                if (!$emp) { $stats['skipped_no_emp']++; continue; }
                $employee_management_id = $emp->id;

                $recordDate = $row['record_date'];
                if (strpos($recordDate, '/') !== false) {
                    [$m,$d,$y] = explode('/', $recordDate);
                    $recordDate = sprintf('%04d-%02d-%02d', $y, $m, $d);
                } else {
                    $recordDate = substr($recordDate,0,10);
                }

                $earliest = $row['earliest_time'] ?? '00:00:00';
                $latest   = $row['latest_time'] ?? '00:00:00';
                if ($earliest === $latest) { $stats['skipped_same_time']++; continue; }

                $weekday = Carbon::parse($recordDate)->format('l');

                $exists = DB::selectOne("
                    SELECT 1 FROM attendance_records
                    WHERE employee_management_id = :eid
                      AND record_date = :rdate
                      AND earliest_time = :et
                      AND latest_time = :lt
                      AND weekday = :wd
                      AND biometric_imports_id = :bid
                    LIMIT 1
                ", [
                    'eid' => $employee_management_id,
                    'rdate' => $recordDate,
                    'et' => $earliest,
                    'lt' => $latest,
                    'wd' => $weekday,
                    'bid'=> $biometricImportsId
                ]);
                if ($exists) { $stats['skipped_duplicate']++; continue; }

                $id = DB::table('attendance_records')->insertGetId([
                    'employee_management_id' => $employee_management_id,
                    'attendance_area' => $row['Attendance Area'] ?? null,
                    'attendance_point_name' => $row['Attendance Point Name'] ?? null,
                    'verification_mode' => $row['Verification Mode'] ?? null,
                    'attendance_photo' => $row['Attendance Photo'] ?? null,
                    'data_sources' => $row['Data Sources'] ?? null,
                    'record_date' => $recordDate,
                    'earliest_time' => $earliest,
                    'latest_time' => $latest,
                    'weekday' => $weekday,
                    'biometric_imports_id' => $biometricImportsId,
                    'created_at' => now(),
                    'updated_at' => now(),
                    'late' => false,
                    'late_hours' => 0,
                    'late_minutes' => 0,
                    'leaves' => false,
                ]);

                $stats['inserted']++;

                // After insert: optional hook to compute OT/ND per row
                // We'll compute summary OT for the biometric import later (calculateHoursForBiometricImport)
            }

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();
            Log::error('insertAttendanceRecords failed: '.$e->getMessage());
            return ['error' => $e->getMessage()];
        }

        return $stats;
    }

    /**
     * Calculate hours/OT/ND & log to overtimes/security — a controller to port calculate_hours_worked for a biometric_import_id
     *
     * This method iterates through attendance_records for the biometric import and computes:
     * - Hours Worked (basic)
     * - ORD OT and ND in a simplified but faithful way
     * - Inserts/updates into overtimes (avoids duplicates)
     * - Logs into security_attendance where department == 'Security'
     */
    protected function calculateHoursForBiometricImport(int $biometricImportsId)
    {
        // Load attendance_records joined with employee info for this biometric import
        $rows = DB::select("
            SELECT ar.*, em.employee_name, em.department, em.unique_id, em.basic_salary
            FROM attendance_records ar
            INNER JOIN employee_management em ON em.id = ar.employee_management_id
            WHERE ar.biometric_imports_id = :bid
        ", ['bid' => $biometricImportsId]);

        if (empty($rows)) return;

        // Preload custom_dates (non-working days)
        $customDates = DB::table('custom_dates')->pluck('record_date')->map(fn($d) => substr($d,0,10))->toArray();

        foreach ($rows as $r) {
            try {
                $record_date = substr($r->record_date, 0, 10);
                if (in_array($record_date, $customDates)) {
                    // Non-working: we still may log as RD if required by logic; skip hours
                    $hoursWorked = 0;
                } else {
                    // compute hours worked using earliest and latest times (handle overnight)
                    $earliest = $this->toSeconds($r->earliest_time);
                    $latest   = $this->toSeconds($r->latest_time);
                    if ($earliest === null || $latest === null) $hoursWorked = 0;
                    else {
                        if ($latest >= $earliest) $seconds = $latest - $earliest;
                        else $seconds = ($latest + 24*3600) - $earliest; // next day
                        $hours = max(($seconds / 3600.0) - 1.0, 0); // subtract 1 hour break (mirrors python default)
                        // some schedules do not subtract break (like 15-23 etc); for simplicity, check schedule briefly
                        $empSchedule = DB::table('employee_management')->where('employee_name', $r->employee_name)->value('schedule');
                        if (in_array($empSchedule, ['15-23','23-7'])) {
                            // do not subtract 1 hr
                            $hours = $seconds / 3600.0;
                        }
                        $hoursWorked = round($hours, 2);
                    }
                }

                // Insert/update security_attendance if department is Security
                if (strtolower(trim($r->department ?? '')) === 'security') {
                    $this->logSecurityAttendance($r, 'hours_worked', round($hoursWorked));
                }

                // compute OT and ND in a simplified manner:
                // - OT = hoursWorked - 8 (if > 8) ; ND = hours between 22:00 - 06:00 (even across midnight)
                $ord_ot = 0.0;
                if ($hoursWorked > 8) $ord_ot = $hoursWorked - 8.0;

                $nd_seconds = $this->secondsInNdWindow($r->earliest_time, $r->latest_time);
                $nd_hours = round($nd_seconds / 3600.0, 2);

                // RD detection (if record_date in custom_dates) - treat as RD
                $isRD = in_array($record_date, $customDates);

                // Insert into overtimes table or update existing (mimics log_overtime_to_db behavior)
                $this->logOrUpdateOvertime($r, [
                    'ord_ot' => $ord_ot,
                    'nd_hours' => $nd_hours,
                    'rd' => $isRD ? ($hoursWorked) : 0,
                    'biometric_imports_id' => $r->biometric_imports_id,
                    'attendance_records_id' => $r->id
                ]);

            } catch (\Throwable $e) {
                Log::error("calculateHoursForBiometricImport row failed: ".$e->getMessage());
            }
        }
    }

    /**
     * Convert 'HH:MM:SS' -> seconds or null
     */
    protected function toSeconds($timeStr)
    {
        if ($timeStr === null || $timeStr === '') return null;
        if (is_numeric($timeStr)) return (int)$timeStr;
        $parts = explode(':', $timeStr);
        if (count($parts) < 2) return null;
        $h = (int)$parts[0];
        $m = (int)$parts[1];
        $s = $parts[2] ?? 0;
        return $h*3600 + $m*60 + (int)$s;
    }

    /**
     * Calculate seconds between earliest and latest that fall into ND window (22:00-06:00)
     * Handles crossing midnight.
     */
    protected function secondsInNdWindow($earliestStr, $latestStr): int
    {
        $ear = $this->toSeconds($earliestStr); if ($ear === null) return 0;
        $lat = $this->toSeconds($latestStr); if ($lat === null) return 0;
        // create timeline from earliest to latest in seconds, allowing crossing midnight
        $segments = [];
        if ($lat >= $ear) {
            $segments[] = [$ear, $lat];
        } else {
            // crosses midnight
            $segments[] = [$ear, 24*3600];
            $segments[] = [0, $lat];
        }

        $ndStart = 22*3600;
        $ndEnd = 6*3600;

        $ndSeconds = 0;
        foreach ($segments as [$s,$e]) {
            // two ND windows possibly: [22:00..24:00] and [00:00..06:00]
            // overlap with [22:00..24:00]
            $overlap1 = max(0, min($e, 24*3600) - max($s, $ndStart));
            $overlap2 = max(0, min($e, $ndEnd) - max($s, 0)); // for 0..6
            $ndSeconds += $overlap1 + $overlap2;
        }
        return (int)$ndSeconds;
    }

    /**
     * Insert or update overtimes (mimics Python log_overtime_to_db)
     */
    protected function logOrUpdateOvertime($attendanceRow, array $computed)
    {
        $employeeName = $attendanceRow->employee_name ?? null;
        $recordDate = substr($attendanceRow->record_date,0,10);
        $type = 'ord'; // simplified; python varies type per context
        $biometric_imports_id = $computed['biometric_imports_id'] ?? $attendanceRow->biometric_imports_id;
        $attendance_records_id  = $computed['attendance_records_id'] ?? $attendanceRow->id;

        // check duplicate by employee_name, record_date, type, biometric_imports_id
        $exists = DB::selectOne("
            SELECT id, rd, rd_ot, rd_nd, rd_nd_ot FROM overtimes
            WHERE employee_name = :ename AND record_date = :rdate AND type = :type AND biometric_imports_id = :bid
            LIMIT 1
        ", ['ename' => $employeeName, 'rdate' => $recordDate, 'type' => $type, 'bid' => $biometric_imports_id]);

        $ord_ot = $computed['ord_ot'] ?? 0;
        $rd = $computed['rd'] ?? 0;
        $nd_hours = $computed['nd_hours'] ?? 0;

        if ($exists) {
            // If type ord and duplicate — skip (python: returns existing id). For RD we may update fields
            if ($type === 'ord') {
                Log::info("Overtime duplicate found for {$employeeName} {$recordDate} type ord — skipping insert");
                return $exists->id;
            } else {
                // update a few fields if changed (simplified)
                DB::table('overtimes')->where('id', $exists->id)->update([
                    'rd' => $rd,
                    'rd_ot' => $ord_ot,
                    'rd_nd' => $nd_hours,
                    'updated_at' => now()
                ]);
                return $exists->id;
            }
        }

        // insert new overtime record
        $emp = DB::table('employee_management')->where('employee_name', $employeeName)->first();
        $id = DB::table('overtimes')->insertGetId([
            'unique_id' => $attendanceRow->unique_id ?? 'TMNG-000000-000',
            'first_name' => explode(',', $employeeName)[1] ?? '',
            'last_name' => explode(',', $employeeName)[0] ?? '',
            'employee_name' => $employeeName,
            'record_date' => $recordDate,
            'earliest_time' => $attendanceRow->earliest_time,
            'latest_time' => $attendanceRow->latest_time,
            'type' => $type,
            'department' => $attendanceRow->department ?? null,
            'attendance_area' => $attendanceRow->attendance_area ?? null,
            'serial_number' => $attendanceRow->serial_number ?? null,
            'schedule' => $emp->schedule ?? null,
            'schedule_shift' => $emp->schedule_shift ?? null,
            'ord_ot' => $this->formatHoursForDb($ord_ot),
            'ord_nd' => '00:00',
            'ord_nd_ot' => '00:00',
            'rd' => $this->formatHoursForDb($rd),
            'rd_ot' => '00:00',
            'rd_nd' => $this->formatHoursForDb($nd_hours),
            'rd_nd_ot' => '00:00',
            'total_non_working_days_present' => 0,
            'late' => $attendanceRow->late ?? false,
            'late_hours' => $attendanceRow->late_hours ?? 0,
            'late_minutes' => $attendanceRow->late_minutes ?? 0,
            'out_time_required' => null,
            'status' => 'Pending',
            'biometric_imports_id' => $biometric_imports_id,
            'attendance_records_id' => $attendance_records_id,
            'created_at' => now(),
            'updated_at' => now()
        ]);

        return $id;
    }

    protected function formatHoursForDb($hoursFloat)
    {
        $totalMinutes = (int) round($hoursFloat * 60);
        return sprintf('%02d:%02d', intdiv($totalMinutes, 60), $totalMinutes % 60);
    }

    /**
     * Logs or updates security_attendance (mimics python log_security_db)
     */
    protected function logSecurityAttendance($attendanceRow, $type, $hours, $biometric_imports_id = null, $attendance_records_id = null)
    {
        // get employee management id
        $empId = DB::table('employee_management')->where('employee_name', $attendanceRow->employee_name)->value('id');
        if (!$empId) return;

        $record_date = substr($attendanceRow->record_date,0,10);
        $earliest = $attendanceRow->earliest_time;
        $latest = $attendanceRow->latest_time;

        $existing = DB::table('security_attendance')->where([
            ['employee_management_id', $empId],
            ['record_date', $record_date],
            ['earliest_time', $earliest],
            ['latest_time', $latest],
            ['biometric_imports_id', $biometric_imports_id ?? $attendanceRow->biometric_imports_id],
        ])->first();

        if ($existing) {
            if ($type === 'hours_worked') {
                DB::table('security_attendance')->where('id', $existing->id)->update(['hours_worked' => $hours, 'updated_at' => now()]);
            } elseif ($type === 'OT') {
                DB::table('security_attendance')->where('id', $existing->id)->update(['ot' => $hours, 'updated_at' => now()]);
            } elseif ($type === 'ND') {
                DB::table('security_attendance')->where('id', $existing->id)->update(['nd' => $hours, 'updated_at' => now()]);
            }
        } else {
            $data = [
                'employee_management_id' => $empId,
                'record_date' => $record_date,
                'weekday' => Carbon::parse($record_date)->format('l'),
                'earliest_time' => $earliest,
                'latest_time' => $latest,
                'biometric_imports_id' => $biometric_imports_id ?? $attendanceRow->biometric_imports_id,
                'attendance_records_id' => $attendance_records_id ?? $attendanceRow->id,
                'created_at' => now(),
                'updated_at' => now()
            ];
            if ($type === 'hours_worked') $data['hours_worked'] = $hours;
            if ($type === 'OT') $data['ot'] = $hours;
            if ($type === 'ND') $data['nd'] = $hours;
            DB::table('security_attendance')->insert($data);
        }
    }

    /**
     * Generate the payroll CSV (public/python/payroll file.csv) from all attendance_records
     * for a given biometric import. Computes ORD, RD, ND, LH, SH hours per employee.
     */
    public function generatePayrollReport(int $biometricImportsId): array
    {
        $rows = DB::select("
            SELECT ar.*, em.employee_name, em.department, em.unique_id, em.basic_salary, em.schedule
            FROM attendance_records ar
            INNER JOIN employee_management em ON em.id = ar.employee_management_id
            WHERE ar.biometric_imports_id = :bid
            ORDER BY em.employee_name, ar.record_date
        ", ['bid' => $biometricImportsId]);

        if (empty($rows)) {
            return ['error' => 'No attendance records found for this biometric import'];
        }

        $nonWorkingDays = DB::table('custom_dates')
            ->pluck('record_date')
            ->map(fn($d) => substr($d, 0, 10))
            ->toArray();

        $holidayMap = DB::table('custom_dates')
            ->get()
            ->keyBy(fn($r) => substr($r->record_date, 0, 10));

        $employeeData    = DB::table('employee_management')->get()->toArray();
        $computation     = new ComputationService();
        $summaries       = [];

        foreach ($rows as $r) {
            $empName    = $r->employee_name;
            $recordDate = substr($r->record_date, 0, 10);

            if (!isset($summaries[$empName])) {
                $summaries[$empName] = [
                    'id' => $r->unique_id, 'name' => $empName, 'basic' => $r->basic_salary ?? 0,
                    'hours_worked' => 0, 'total_regular_days' => 0, 'total_non_working_days' => 0,
                    'ord_ot' => 0, 'ord_nd' => 0, 'ord_nd_ot' => 0,
                    'rd' => 0, 'rd_ot' => 0, 'rd_nd' => 0, 'rd_nd_ot' => 0,
                    'lh' => 0, 'lh_ot' => 0, 'lh_nd' => 0, 'lh_nd_ot' => 0,
                    'sh' => 0, 'sh_ot' => 0, 'sh_nd' => 0, 'sh_nd_ot' => 0,
                ];
            }

            $holiday      = $holidayMap[$recordDate] ?? null;
            $isNonWorking = in_array($recordDate, $nonWorkingDays);
            $holidayType  = $holiday->holiday_type ?? null;

            if ($isNonWorking) {
                $summaries[$empName]['total_non_working_days']++;
            } else {
                $summaries[$empName]['total_regular_days']++;
            }

            // Hours worked (subtract 1-hour break for non-security schedules)
            $ear = $this->toSeconds($r->earliest_time);
            $lat = $this->toSeconds($r->latest_time);
            if ($ear !== null && $lat !== null && $ear !== $lat) {
                $secs = $lat >= $ear ? $lat - $ear : ($lat + 86400) - $ear;
                $noBreakSchedules = ['15-23', '23-7'];
                $break = in_array($r->schedule ?? '', $noBreakSchedules) ? 0 : 3600;
                $summaries[$empName]['hours_worked'] += max(($secs - $break) / 3600, 0);
            }

            $rowArr = (array)$r;

            if (!$isNonWorking) {
                [$ordOt, $ordNd, $ordNdOt] = $computation->autocalculateOrd(
                    $rowArr, $nonWorkingDays, $employeeData, null, null, $biometricImportsId
                );
                $summaries[$empName]['ord_ot']    += $ordOt;
                $summaries[$empName]['ord_nd']    += $ordNd;
                $summaries[$empName]['ord_nd_ot'] += $ordNdOt;
            } else {
                $rd = $computation->autocalculateRdAndOvertime($rowArr, collect($employeeData));

                if (in_array($holidayType, ['Regular Holiday', 'Legal Holiday'])) {
                    $summaries[$empName]['lh']    += $rd['rd'];
                    $summaries[$empName]['lh_ot'] += $rd['rd_ot'];
                    $summaries[$empName]['lh_nd'] += $rd['rd_nd'];
                    $summaries[$empName]['lh_nd_ot'] += $rd['rd_nd_ot'];
                } elseif ($holidayType === 'Special Non-Working Holiday') {
                    $summaries[$empName]['sh']    += $rd['rd'];
                    $summaries[$empName]['sh_ot'] += $rd['rd_ot'];
                    $summaries[$empName]['sh_nd'] += $rd['rd_nd'];
                    $summaries[$empName]['sh_nd_ot'] += $rd['rd_nd_ot'];
                } else {
                    $summaries[$empName]['rd']    += $rd['rd'];
                    $summaries[$empName]['rd_ot'] += $rd['rd_ot'];
                    $summaries[$empName]['rd_nd'] += $rd['rd_nd'];
                    $summaries[$empName]['rd_nd_ot'] += $rd['rd_nd_ot'];
                }
            }
        }

        // Write payroll CSV
        $outputPath = public_path('python/payroll file.csv');
        $dir = dirname($outputPath);
        if (!is_dir($dir)) {
            mkdir($dir, 0755, true);
        }

        $fp = fopen($outputPath, 'w');
        fputcsv($fp, [
            'ID', 'Name', 'Basic', 'Hours Worked',
            'Total Regular Working Days Present', 'Total Non-Working Days Present',
            'Ord-OT', 'Ord-ND', 'Ord-ND-OT', 'RegNDExcess',
            'RD', 'RD-OT', 'RD-ND', 'RD-ND-OT', 'Sun-ND-Excess',
            'SH', 'SH-OT', 'SH-ND', 'SH-ND-OT', 'SH-ND-Excess',
            'LH', 'LH-OT', 'LH-ND', 'LH-ND-OT', 'LH-ND-Excess',
            'SH-RD', 'SH-RD-OT', 'SH-RD-ND', 'SH-RD-ND-OT', 'SH-RD-ND-Excess',
            'LH-RD', 'LH-RD-OT', 'LH-RD-ND', 'LH-RD-ND-OT', 'LH-RD-ND-Excess',
            'DH', 'DH-OT', 'DH-ND', 'DH-ND-OT', 'DH-ND-Excess',
            'DH-RD', 'DH-RD-OT', 'DH-RD-ND', 'DH-RD-ND-OT',
        ]);

        foreach ($summaries as $emp) {
            fputcsv($fp, [
                $emp['id'],
                $emp['name'],
                $emp['basic'],
                round($emp['hours_worked'], 2),
                $emp['total_regular_days'],
                $emp['total_non_working_days'],
                $this->formatHoursForDb($emp['ord_ot']),
                $this->formatHoursForDb($emp['ord_nd']),
                $this->formatHoursForDb($emp['ord_nd_ot']),
                '00:00',
                $this->formatHoursForDb($emp['rd']),
                $this->formatHoursForDb($emp['rd_ot']),
                $this->formatHoursForDb($emp['rd_nd']),
                $this->formatHoursForDb($emp['rd_nd_ot']),
                '00:00',
                $this->formatHoursForDb($emp['sh']),
                $this->formatHoursForDb($emp['sh_ot']),
                $this->formatHoursForDb($emp['sh_nd']),
                $this->formatHoursForDb($emp['sh_nd_ot']),
                '00:00',
                $this->formatHoursForDb($emp['lh']),
                $this->formatHoursForDb($emp['lh_ot']),
                $this->formatHoursForDb($emp['lh_nd']),
                $this->formatHoursForDb($emp['lh_nd_ot']),
                '00:00',
                '00:00', '00:00', '00:00', '00:00', '00:00',
                '00:00', '00:00', '00:00', '00:00', '00:00',
                '00:00', '00:00', '00:00', '00:00', '00:00',
                '00:00', '00:00', '00:00', '00:00',
            ]);
        }

        fclose($fp);

        Log::info("generatePayrollReport: wrote {$outputPath}", ['employees' => count($summaries)]);

        return ['stats' => ['employees' => count($summaries), 'output' => $outputPath]];
    }

    /**
     * Process attendance_certificates.json: insert or remove attendance_records
     * for each certificate entry (action = 'add' | 'remove').
     */
    public function finalizeCertificates(string $certificatesPath, string $overtimeLogsPath, string $outputDir): array
    {
        if (!file_exists($certificatesPath)) {
            return ['error' => 'attendance_certificates.json not found'];
        }

        $certificates = json_decode(file_get_contents($certificatesPath), true);
        if (!is_array($certificates)) {
            return ['error' => 'attendance_certificates.json is invalid or empty'];
        }

        $biometricImportId = DB::table('biometric_imports')
            ->where('status', 'load')
            ->value('id');

        $stats = ['processed' => 0, 'skipped' => 0, 'errors' => 0];

        foreach ($certificates as $cert) {
            try {
                $action        = $cert['action'] ?? 'add';
                $lastName      = strtoupper(trim($cert['Last Name'] ?? ''));
                $firstName     = strtoupper(trim($cert['First Name'] ?? ''));
                $employeeName  = "$lastName, $firstName";
                $recordDate    = $cert['record_date'] ?? null;

                if (!$recordDate || !$lastName || !$firstName) {
                    $stats['skipped']++;
                    continue;
                }

                $emp = DB::table('employee_management')
                    ->where('employee_name', $employeeName)
                    ->first();

                if (!$emp) {
                    Log::warning("finalizeCertificates: employee not found [{$employeeName}]");
                    $stats['skipped']++;
                    continue;
                }

                if ($action === 'add') {
                    $exists = DB::table('attendance_records')
                        ->where('employee_management_id', $emp->id)
                        ->where('record_date', $recordDate)
                        ->exists();

                    if (!$exists) {
                        DB::table('attendance_records')->insert([
                            'employee_management_id' => $emp->id,
                            'record_date'            => $recordDate,
                            'earliest_time'          => $cert['Earliest Time'] ?? null,
                            'latest_time'            => $cert['Latest Time']   ?? null,
                            'weekday'                => Carbon::parse($recordDate)->format('l'),
                            'biometric_imports_id'   => $biometricImportId,
                            'late'                   => $cert['late']         ?? false,
                            'late_hours'             => $cert['late_hours']   ?? 0,
                            'late_minutes'           => $cert['late_minutes'] ?? 0,
                            'leaves'                 => false,
                            'created_at'             => now(),
                            'updated_at'             => now(),
                        ]);
                    }

                } elseif ($action === 'remove') {
                    DB::table('attendance_records')
                        ->where('employee_management_id', $emp->id)
                        ->where('record_date', $recordDate)
                        ->delete();

                    DB::table('overtimes')
                        ->where('employee_name', $employeeName)
                        ->where('record_date', $recordDate)
                        ->where('biometric_imports_id', $biometricImportId)
                        ->delete();
                }

                $stats['processed']++;

            } catch (\Throwable $e) {
                Log::error("finalizeCertificates row error: " . $e->getMessage());
                $stats['errors']++;
            }
        }

        Log::info('finalizeCertificates complete', $stats);
        return ['stats' => $stats];
    }

    /**
     * Return file preview (first N chars)
     */
    protected function makePreview(string $filePath, int $maxChars = 2000): string
    {
        try {
            $ext = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
            if (in_array($ext, ['xls','xlsx'])) return '(XLSX uploaded; preview omitted)';
            $s = file_get_contents($filePath);
            return substr($s, 0, $maxChars);
        } catch (\Exception $e) {
            return '';
        }
    }

    /**
     * Load attendance_records joined with employee_management for a biometric_import_id
     */
    public function loadDataFromDb(int $biometricImportsId)
    {
        $df = DB::select("
            SELECT ar.id, ar.employee_management_id, em.employee_name, em.department, em.unique_id, em.basic_salary,
                   ar.record_date, ar.earliest_time, ar.latest_time, ar.weekday, ar.biometric_imports_id, ar.leaves
            FROM attendance_records ar
            INNER JOIN employee_management em ON em.id = ar.employee_management_id
            WHERE ar.biometric_imports_id = :bid
        ", ['bid' => $biometricImportsId]);

        $empAll = DB::select("SELECT * FROM employee_management");

        return [$df, $empAll];
    }

    /**
     * Calculate and insert standard non-working days (Sundays + fixed PH holidays) similar to python calculate_total_non_workingdays
     *
     * @param int|null $year
     */
    public function calculateTotalNonWorkingDays(int $year = null)
    {
        if ($year === null) $year = Carbon::now()->year;

        // 1. Sundays
        $date = Carbon::createFromDate($year, 1, 1);
        $sundays = [];
        // move to first sunday
        $date->addDays((7 - $date->dayOfWeek) % 7);
        while ($date->year == $year) {
            $sundays[] = $date->toDateString();
            $date->addWeek();
        }

        $holidays = [
            "{$year}-01-01" => ["New Year's Day", "Regular Holiday"],
            "{$year}-04-17" => ["Maundy Thursday", "Regular Holiday"],
            "{$year}-04-18" => ["Good Friday", "Regular Holiday"],
            "{$year}-04-09" => ["Araw ng Kagitingan (Day of Valor)", "Regular Holiday"],
            "{$year}-05-01" => ["Labor Day", "Regular Holiday"],
            "{$year}-06-06" => ["Eid’l Adha", "Regular Holiday"],
            "{$year}-06-12" => ["Independence Day", "Regular Holiday"],
            "{$year}-08-25" => ["National Heroes Day", "Regular Holiday"],
            "{$year}-11-30" => ["Bonifacio Day", "Regular Holiday"],
            "{$year}-12-25" => ["Christmas Day", "Regular Holiday"],
            "{$year}-12-30" => ["Rizal Day", "Regular Holiday"],
            "{$year}-01-29" => ["Chinese New Year", "Special Non-Working Holiday"],
            "{$year}-04-19" => ["Black Saturday", "Special Non-Working Holiday"],
            "{$year}-08-21" => ["Ninoy Aquino Day", "Special Non-Working Holiday"],
            "{$year}-10-31" => ["All Saints’ Eve", "Special Non-Working Holiday"],
            "{$year}-11-01" => ["All Saints’ Day", "Special Non-Working Holiday"],
            "{$year}-12-08" => ["Feast of the Immaculate Conception", "Special Non-Working Holiday"],
            "{$year}-12-24" => ["Christmas Eve", "Special Non-Working Holiday"],
            "{$year}-12-31" => ["Last Day of the Year", "Special Non-Working Holiday"],
        ];

        DB::beginTransaction();
        try {
            foreach ($sundays as $s) {
                $exists = DB::table('custom_dates')->where('record_date', $s)->where('title', 'Sunday Rest Day')->first();
                if (!$exists) {
                    DB::table('custom_dates')->insert([
                        'record_date' => $s,
                        'title' => 'Sunday Rest Day',
                        'holiday_type' => 'Rest Day',
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }
            }
            foreach ($holidays as $d => $meta) {
                [$title, $type] = $meta;
                $wkday = Carbon::parse($d)->dayOfWeek;
                $title2 = $wkday == Carbon::SUNDAY ? "$title (Falls on Rest Day)" : $title;
                $exists = DB::table('custom_dates')->where('record_date', $d)->where('title', $title2)->first();
                if (!$exists) {
                    DB::table('custom_dates')->insert([
                        'record_date' => $d,
                        'title' => $title2,
                        'holiday_type' => $type,
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }
            }
            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();
            Log::error('calculateTotalNonWorkingDays failed: '.$e->getMessage());
        }
    }
}

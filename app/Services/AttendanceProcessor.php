<?php

namespace App\Services;

use Carbon\Carbon;
use Carbon\CarbonInterval;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use App\Services\ComputationService;
use App\Services\SecurityReportService;

class AttendanceProcessor
{
    /**
     * Philippine public holidays per year (date => [title, custom_dates.holiday_type]).
     * Movable holidays differ every year, so each year needs its own list from the yearly proclamation.
     * Eid'l Fitr / Eid'l Adha are proclaimed separately; add them via the dashboard once announced.
     */
    public const PUBLIC_HOLIDAYS = [
        2025 => [
            '2025-01-01' => ["New Year's Day", 'Regular Holiday'],
            '2025-04-17' => ['Maundy Thursday', 'Regular Holiday'],
            '2025-04-18' => ['Good Friday', 'Regular Holiday'],
            '2025-04-09' => ['Araw ng Kagitingan (Day of Valor)', 'Regular Holiday'],
            '2025-05-01' => ['Labor Day', 'Regular Holiday'],
            '2025-06-06' => ['Eid’l Adha', 'Regular Holiday'],
            '2025-06-12' => ['Independence Day', 'Regular Holiday'],
            '2025-08-25' => ['National Heroes Day', 'Regular Holiday'],
            '2025-11-30' => ['Bonifacio Day', 'Regular Holiday'],
            '2025-12-25' => ['Christmas Day', 'Regular Holiday'],
            '2025-12-30' => ['Rizal Day', 'Regular Holiday'],
            '2025-01-29' => ['Chinese New Year', 'Special Non-Working Holiday'],
            '2025-04-19' => ['Black Saturday', 'Special Non-Working Holiday'],
            '2025-08-21' => ['Ninoy Aquino Day', 'Special Non-Working Holiday'],
            '2025-10-31' => ['All Saints’ Eve', 'Special Non-Working Holiday'],
            '2025-11-01' => ['All Saints’ Day', 'Special Non-Working Holiday'],
            '2025-12-08' => ['Feast of the Immaculate Conception', 'Special Non-Working Holiday'],
            '2025-12-24' => ['Christmas Eve', 'Special Non-Working Holiday'],
            '2025-12-31' => ['Last Day of the Year', 'Special Non-Working Holiday'],
        ],
        // Proclamation No. 1006, s. 2025
        2026 => [
            '2026-01-01' => ["New Year's Day", 'Regular Holiday'],
            '2026-04-02' => ['Maundy Thursday', 'Regular Holiday'],
            '2026-04-03' => ['Good Friday', 'Regular Holiday'],
            '2026-04-09' => ['Araw ng Kagitingan (Day of Valor)', 'Regular Holiday'],
            '2026-05-01' => ['Labor Day', 'Regular Holiday'],
            '2026-06-12' => ['Independence Day', 'Regular Holiday'],
            '2026-08-31' => ['National Heroes Day', 'Regular Holiday'],
            '2026-11-30' => ['Bonifacio Day', 'Regular Holiday'],
            '2026-12-25' => ['Christmas Day', 'Regular Holiday'],
            '2026-12-30' => ['Rizal Day', 'Regular Holiday'],
            '2026-02-17' => ['Chinese New Year', 'Special Non-Working Holiday'],
            '2026-04-04' => ['Black Saturday', 'Special Non-Working Holiday'],
            '2026-08-21' => ['Ninoy Aquino Day', 'Special Non-Working Holiday'],
            '2026-11-01' => ['All Saints’ Day', 'Special Non-Working Holiday'],
            '2026-11-02' => ['All Souls’ Day', 'Special Non-Working Holiday'],
            '2026-12-08' => ['Feast of the Immaculate Conception', 'Special Non-Working Holiday'],
            '2026-12-24' => ['Christmas Eve', 'Special Non-Working Holiday'],
            '2026-12-31' => ['Last Day of the Year', 'Special Non-Working Holiday'],
        ],
    ];

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

        // 4b. default the batch's payroll period to its first/last punch date
        $this->setDefaultPeriod($biometricImportsId);

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

                // One record per employee per day across ALL imports: uploads may overlap,
                // and the first stored record (with any edits/leaves on it) is kept.
                $exists = DB::selectOne("
                    SELECT 1 FROM attendance_records
                    WHERE employee_management_id = :eid
                      AND DATE(record_date) = :rdate
                    LIMIT 1
                ", [
                    'eid' => $employee_management_id,
                    'rdate' => $recordDate,
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
     * Fill period_start / period_end on the batch from its attendance_records
     * when the admin has not set them yet.
     */
    protected function setDefaultPeriod(int $biometricImportsId): void
    {
        $range = DB::table('attendance_records')
            ->where('biometric_imports_id', $biometricImportsId)
            ->selectRaw('MIN(record_date)::date AS min_date, MAX(record_date)::date AS max_date')
            ->first();

        if (!$range || !$range->min_date) return;

        DB::table('biometric_imports')
            ->where('id', $biometricImportsId)
            ->whereNull('period_start')
            ->update(['period_start' => $range->min_date]);

        DB::table('biometric_imports')
            ->where('id', $biometricImportsId)
            ->whereNull('period_end')
            ->update(['period_end' => $range->max_date]);
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
        $computation  = new ComputationService();
        $employeeData = DB::table('employee_management')->get()->toArray();

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

                // OT / ND by the overtime rules (ComputationService), the same calculation used when
                // a time is edited or a record is approved, so the Overtime page starts out correct.
                $rowArr = (array) $r;
                [$ordOt, $ordNd, $ordNdOt] = $computation->autocalculateOrd(
                    $rowArr, $customDates, $employeeData, null, null, $r->biometric_imports_id
                );
                $rd = $computation->autocalculateRdAndOvertime($rowArr, collect($employeeData));

                // Insert into overtimes table or update existing (mimics log_overtime_to_db behavior)
                $this->logOrUpdateOvertime($r, [
                    'ord_ot' => $ordOt,
                    'ord_nd' => $ordNd,
                    'ord_nd_ot' => $ordNdOt,
                    'rd' => $rd['rd'],
                    'rd_ot' => $rd['rd_ot'],
                    'rd_nd' => $rd['rd_nd'],
                    'rd_nd_ot' => $rd['rd_nd_ot'],
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

        $hm = fn($key) => $this->formatHoursForDb($computed[$key] ?? 0);

        if ($exists) {
            // If type ord and duplicate — skip (python: returns existing id). For RD we may update fields
            if ($type === 'ord') {
                Log::info("Overtime duplicate found for {$employeeName} {$recordDate} type ord — skipping insert");
                return $exists->id;
            } else {
                // update a few fields if changed (simplified)
                DB::table('overtimes')->where('id', $exists->id)->update([
                    'rd' => $hm('rd'),
                    'rd_ot' => $hm('rd_ot'),
                    'rd_nd' => $hm('rd_nd'),
                    'rd_nd_ot' => $hm('rd_nd_ot'),
                    'updated_at' => now()
                ]);
                return $exists->id;
            }
        }

        // insert new overtime record
        $emp = DB::table('employee_management')->where('employee_name', $employeeName)->first();
        $isNonWorking = DB::table('custom_dates')->whereRaw('DATE(record_date) = ?', [$recordDate])->exists();
        $lateMinutes = ($isNonWorking || !empty($attendanceRow->leaves)) ? 0 : (new ComputationService())->lateAndUndertime(
            $emp->schedule ?? null, $attendanceRow->earliest_time, $attendanceRow->latest_time, $attendanceRow->department ?? ($emp->department ?? null)
        )['late_minutes'];
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
            'ord_ot' => $hm('ord_ot'),
            'ord_nd' => $hm('ord_nd'),
            'ord_nd_ot' => $hm('ord_nd_ot'),
            'rd' => $hm('rd'),
            'rd_ot' => $hm('rd_ot'),
            'rd_nd' => $hm('rd_nd'),
            'rd_nd_ot' => $hm('rd_nd_ot'),
            'total_non_working_days_present' => 0,
            'late' => $lateMinutes > 0,
            'late_hours' => intdiv($lateMinutes, 60),
            'late_minutes' => $lateMinutes % 60,
            'out_time_required' => null,
            'status' => 'Pending',
            'biometric_imports_id' => $biometric_imports_id,
            'attendance_records_id' => $attendance_records_id,
            'employee_management_id' => $attendanceRow->employee_management_id ?? ($emp->id ?? null),
            'created_at' => now(),
            'updated_at' => now()
        ]);

        return $id;
    }

    /** "HH:MM" (as stored on overtime records) to decimal hours. */
    protected function hmToHours($hm): float
    {
        if (!is_string($hm) || !preg_match('/^(\d+):(\d{2})/', trim($hm), $m)) {
            return is_numeric($hm) ? (float) $hm : 0.0;
        }

        return (int) $m[1] + (int) $m[2] / 60;
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
                'created_at' => now(),
                'updated_at' => now()
            ];
            if ($type === 'hours_worked') $data['hours_worked'] = $hours;
            if ($type === 'OT') $data['ot'] = $hours;
            if ($type === 'ND') $data['nd'] = $hours;
            DB::table('security_attendance')->insert($data);
        }
    }

    /** DTR colors (HR Daily Attendance template). */
    protected const DTR_FILL_REG = 'FFF2CC';
    protected const DTR_FILL_OT  = 'DDEBF7';
    protected const DTR_HEADER   = '002060';

    /** Hour buckets computed per attendance record (payroll columns and DTR rows). */
    protected const BUCKETS = [
        'hours_worked',
        'ord_ot', 'ord_nd', 'ord_nd_ot',
        'rd', 'rd_ot', 'rd_nd', 'rd_nd_ot',
        'lh', 'lh_ot', 'lh_nd', 'lh_nd_ot',
        'sh', 'sh_ot', 'sh_nd', 'sh_nd_ot',
    ];

    /** Regular hours per working day; anything beyond is OT and needs approval. */
    private const REGULAR_DAY_SECONDS = 8 * 3600;

    /**
     * Compute every attendance_record dated within the payroll period ($start..$end), from
     * any biometric import, into per-employee, per-date hour buckets. Shared by the payroll
     * file and the DTR so both always show the same numbers. Imports never store the same
     * employee/date twice (see insertAttendanceRecords), so no row is counted twice.
     *
     * Hours Worked holds regular hours only (8 max, less late and undertime). OT, rest-day and
     * holiday hours come from approved overtime records only.
     */
    protected function buildDailyBreakdown(string $start, string $end): array
    {
        $rows = DB::select("
            SELECT ar.*, em.employee_name, em.department, em.unique_id, em.basic_salary, em.schedule
            FROM attendance_records ar
            INNER JOIN employee_management em ON em.id = ar.employee_management_id
            WHERE DATE(ar.record_date) BETWEEN :start AND :end
            ORDER BY em.employee_name, ar.record_date
        ", ['start' => $start, 'end' => $end]);

        $nonWorkingDays = DB::table('custom_dates')
            ->pluck('record_date')
            ->map(fn($d) => substr($d, 0, 10))
            ->toArray();

        $holidayMap = DB::table('custom_dates')
            ->get()
            ->keyBy(fn($r) => substr($r->record_date, 0, 10));

        $employeeData = DB::table('employee_management')->get()->toArray();
        $computation  = new ComputationService();
        $employees    = [];

        // Schedule adjustments in the period, by employee and day (same source the OT calculation uses)
        $adjustedSchedules = DB::table('schedule_adjustments')
            ->whereRaw('DATE(record_date) BETWEEN ? AND ?', [$start, $end])
            ->orderBy('id')
            ->get(['employee_management_id', 'record_date', 'schedule'])
            ->mapWithKeys(fn($a) => [$a->employee_management_id . '|' . substr($a->record_date, 0, 10) => $a->schedule]);

        // OT, rest-day and holiday hours only count once approved: use the approved overtime
        // records' figures (as approved, including any time edits), keyed by attendance record.
        $approvedOt = DB::table('overtimes')
            ->where('status', 'Approved')
            ->whereRaw('DATE(record_date) BETWEEN ? AND ?', [$start, $end])
            ->orderBy('id')
            ->get(['attendance_records_id', 'employee_management_id', 'record_date',
                'ord_ot', 'ord_nd_ot', 'rd', 'rd_ot', 'rd_nd', 'rd_nd_ot']);
        $approvedByRecord = $approvedOt->whereNotNull('attendance_records_id')->keyBy('attendance_records_id');
        $approvedByEmpDay = $approvedOt->keyBy(fn($o) => $o->employee_management_id . '|' . substr($o->record_date, 0, 10));
        $hours = fn($hm) => $this->hmToHours($hm);

        foreach ($rows as $r) {
            $empName    = $r->employee_name;
            $recordDate = substr($r->record_date, 0, 10);

            if (!isset($employees[$empName])) {
                $employees[$empName] = [
                    'id' => $r->unique_id, 'name' => $empName, 'basic' => $r->basic_salary ?? 0,
                    'days' => [],
                ];
            }

            if (!isset($employees[$empName]['days'][$recordDate])) {
                $employees[$empName]['days'][$recordDate] = array_fill_keys(self::BUCKETS, 0)
                    + ['regular_days' => 0, 'non_working_days' => 0];
            }
            $day = &$employees[$empName]['days'][$recordDate];

            $holiday      = $holidayMap[$recordDate] ?? null;
            $isNonWorking = in_array($recordDate, $nonWorkingDays);
            $holidayType  = $holiday->holiday_type ?? null;

            if ($isNonWorking) {
                $day['non_working_days']++;
            } else {
                $day['regular_days']++;
            }

            $schedule = $adjustedSchedules[$r->employee_management_id . '|' . $recordDate] ?? $r->schedule;
            $onLeave  = !empty($r->leaves);
            $approved = $approvedByRecord[$r->id] ?? $approvedByEmpDay[$r->employee_management_id . '|' . $recordDate] ?? null;

            // Hours Worked = regular hours only, on working days: 8 (or the shift less its break,
            // if shorter) minus late (beyond grace, in full) and undertime (every minute).
            // Arriving early or staying late adds nothing here; that is OT, counted once approved.
            $ear = $this->toSeconds($r->earliest_time);
            $lat = $this->toSeconds($r->latest_time);
            if (!$isNonWorking && !$onLeave && $ear !== null && $lat !== null && $ear !== $lat) {
                $lu = $computation->lateAndUndertime($schedule, $r->earliest_time, $r->latest_time, $r->department ?? null);

                $noBreakSchedules = ['15-23', '23-7'];
                $break = in_array($lu['schedule'] ?? $schedule ?? '', $noBreakSchedules) ? 0 : 3600;

                if ($lu['shift_minutes'] !== null) {
                    $regular = min($lu['shift_minutes'] * 60 - $break, self::REGULAR_DAY_SECONDS)
                        - ($lu['late_minutes'] + $lu['undertime_minutes']) * 60;
                } else {
                    // No usable schedule: actual time less break, still capped at a regular day
                    $span    = $lat >= $ear ? $lat - $ear : ($lat + 86400) - $ear;
                    $regular = min($span - $break, self::REGULAR_DAY_SECONDS);
                }
                $day['hours_worked'] += max($regular, 0) / 3600;
            }

            if (!$isNonWorking) {
                // ND on regular hours is a premium on the regular day, not OT: always shown
                if (!$onLeave) {
                    [, $ordNd] = $computation->autocalculateOrd(
                        (array) $r, $nonWorkingDays, $employeeData, null, null, $r->biometric_imports_id
                    );
                    $day['ord_nd'] += $ordNd;
                }
                if ($approved) {
                    $day['ord_ot']    += $hours($approved->ord_ot);
                    $day['ord_nd_ot'] += $hours($approved->ord_nd_ot);
                }
            } elseif ($approved) {
                if (in_array($holidayType, ['Regular Holiday', 'Legal Holiday'])) {
                    $prefix = 'lh';
                } elseif ($holidayType === 'Special Non-Working Holiday') {
                    $prefix = 'sh';
                } else {
                    $prefix = 'rd';
                }

                $day[$prefix]            += $hours($approved->rd);
                $day["{$prefix}_ot"]     += $hours($approved->rd_ot);
                $day["{$prefix}_nd"]     += $hours($approved->rd_nd);
                $day["{$prefix}_nd_ot"]  += $hours($approved->rd_nd_ot);
            }
            unset($day);
        }

        $recordedDates = array_unique(array_map(fn($r) => substr($r->record_date, 0, 10), $rows));
        $missingDates  = [];
        foreach (\Carbon\CarbonPeriod::create($start, $end) as $d) {
            if (!in_array($d->toDateString(), $recordedDates)) {
                $missingDates[] = $d->toDateString();
            }
        }

        $importIds = array_values(array_unique(array_map(fn($r) => $r->biometric_imports_id, $rows)));

        return [
            'start'         => $start,
            'end'           => $end,
            'employees'     => $employees,
            'missing_dates' => $missingDates,
            'imports'       => DB::table('biometric_imports')->whereIn('id', $importIds)
                ->orderBy('id')->get(['id', 'title'])->toArray(),
        ];
    }

    /**
     * The report files in public/python are also tracked in git, so a checkout leaves them owned by the
     * host user and read-only for the web server. The directory itself is writable, so remove such a
     * file and let the writer create a fresh one instead of failing with "Permission denied".
     */
    private function replaceUnwritableOutput(string $path): void
    {
        if (is_file($path) && !is_writable($path)) {
            @unlink($path);
        }
    }

    /**
     * Generate the payroll CSV (public/python/payroll file.csv) and the DTR
     * (public/python/reportdtr.xlsx) for the payroll period $start..$end, from the same
     * daily breakdown. Records from every biometric import dated in the period are included.
     */
    public function generatePayrollReport(string $start, string $end): array
    {
        // Never leave a DTR from an earlier run downloadable if this run fails.
        $dtrPath = public_path('python/reportdtr.xlsx');
        if (file_exists($dtrPath)) {
            @unlink($dtrPath);
        }

        $breakdown = $this->buildDailyBreakdown($start, $end);

        if (empty($breakdown['employees'])) {
            return ['error' => "No attendance records found between {$start} and {$end}"];
        }

        $summaries = [];
        foreach ($breakdown['employees'] as $empName => $emp) {
            $summaries[$empName] = [
                'id' => $emp['id'], 'name' => $emp['name'], 'basic' => $emp['basic'],
                'total_regular_days' => 0, 'total_non_working_days' => 0,
            ] + array_fill_keys(self::BUCKETS, 0);

            foreach ($emp['days'] as $day) {
                $summaries[$empName]['total_regular_days']     += $day['regular_days'];
                $summaries[$empName]['total_non_working_days'] += $day['non_working_days'];
                foreach (self::BUCKETS as $bucket) {
                    $summaries[$empName][$bucket] += $day[$bucket];
                }
            }
        }

        // Write payroll CSV
        $outputPath = public_path('python/payroll file.csv');
        $dir = dirname($outputPath);
        if (!is_dir($dir)) {
            mkdir($dir, 0755, true);
        }

        $header = [
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
        ];

        $csvRows = [];
        foreach ($summaries as $emp) {
            $csvRows[] = [
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
            ];
        }

        $this->replaceUnwritableOutput($outputPath);
        $fp = fopen($outputPath, 'w');
        if ($fp === false) {
            throw new \RuntimeException("Cannot write {$outputPath}; check that the web server user can write to public/python.");
        }
        fputcsv($fp, $header);
        foreach ($csvRows as $row) {
            fputcsv($fp, $row);
        }
        fclose($fp);

        // Keep the downloadable "payroll file.xlsx" (served by download.payrollfile)
        // in sync with the CSV — it used to be a static leftover that never got regenerated.
        $xlsxPath = public_path('python/payroll file.xlsx');
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->fromArray($header, null, 'A1');
        $sheet->fromArray($csvRows, null, 'A2');
        $this->replaceUnwritableOutput($xlsxPath);
        (new \PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet))->save($xlsxPath);

        Log::info("generatePayrollReport: wrote {$outputPath} and {$xlsxPath}", ['employees' => count($summaries)]);

        $this->generateDtrReport($breakdown, $dtrPath);

        $securityPath   = public_path('python/security.xlsx');
        $securityGuards = app(SecurityReportService::class)
            ->generate($breakdown['start'], $breakdown['end'], $securityPath);

        return [
            'stats' => [
                'employees'      => count($summaries),
                'output'         => $outputPath,
                'dtr'            => $dtrPath,
                'security_guards' => $securityGuards,
                'period'         => ['start' => $breakdown['start'], 'end' => $breakdown['end']],
                'missing_dates'  => $breakdown['missing_dates'],
                'imports'        => $breakdown['imports'],
            ],
        ];
    }

    /**
     * Write the DTR (reportdtr.xlsx) in the layout of the old Python report_manual():
     * one block of row types per employee, one column per day of the payroll period.
     */
    protected function generateDtrReport(array $breakdown, string $path): void
    {
        // Row type => bucket. Combined holiday rows have no bucket (payroll writes 00:00 for them too).
        $rowTypes = [
            'Hours Worked' => 'hours_worked',
            'OT (Ordinary day)' => 'ord_ot',
            'SUNDAY Reg 8 hrs' => 'rd',
            'SPECIAL HOL. Reg 8 hrs' => 'sh',
            'SPECIAL HOL. + SUNDAY Reg 8 hrs' => null,
            'LEG. HOLIDAY Reg 8 hrs' => 'lh',
            'LEG. HOLIDAY + SUNDAY Reg 8 hrs' => null,
            'LEG. HOLIDAY + LEG. HOLIDAY Reg 8 hrs' => null,
            'LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY Reg 8 hrs' => null,
            'ND Reg 8 hrs' => 'ord_nd',
            'SUNDAY ND Reg 8 hrs' => 'rd_nd',
            'SPECIAL HOL. ND Reg 8 hrs' => 'sh_nd',
            'SPECIAL HOL. + SUNDAY ND Reg 8 hrs' => null,
            'LEG. HOLIDAY ND Reg 8 hrs' => 'lh_nd',
            'LEG. HOLIDAY + SUNDAY ND Reg 8 hrs' => null,
            'LEG. HOLIDAY + LEG. HOLIDAY ND Reg 8 hrs' => null,
            'LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY ND Reg 8 hrs' => null,
            'EX SUNDAY OT' => 'rd_ot',
            'EX SPECIAL HOL. OT' => 'sh_ot',
            'EX SPECIAL HOL. + SUNDAY OT' => null,
            'EX LEG. HOLIDAY OT' => 'lh_ot',
            'EX. LEG. HOLIDAY + SUNDAY OT' => null,
            'EX. LEG. HOLIDAY + LEG. HOLIDAY OT' => null,
            'EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY OT' => null,
            'EX. NDOT' => 'ord_nd_ot',
            'EX. SUNDAY NDOT' => 'rd_nd_ot',
            'EX. SPECIAL HOL. NDOT' => 'sh_nd_ot',
            'EX. SPECIAL HOL. + SUNDAY NDOT' => null,
            'EX. LEG. HOLIDAY NDOT' => 'lh_nd_ot',
            'EX. LEG. HOLIDAY + SUNDAY NDOT' => null,
            'EX. LEG. HOLIDAY + LEG. HOLIDAY NDOT' => null,
            'EX. LEG. HOLIDAY + LEG. HOLIDAY + SUNDAY NDOT' => null,
        ];

        // Type cell colors of the HR Daily Attendance template: OT rows light blue, regular-hour
        // rows cream; Sunday rows (and Hours Worked) in red font.
        $typeFill    = fn(string $type) => str_starts_with($type, 'EX') || $type === 'OT (Ordinary day)'
            ? self::DTR_FILL_OT
            : self::DTR_FILL_REG;
        $typeFontRed = fn(string $type) => $type === 'Hours Worked' || str_contains($type, 'SUNDAY');

        $dates = [];
        if ($breakdown['start'] && $breakdown['end']) {
            foreach (\Carbon\CarbonPeriod::create($breakdown['start'], $breakdown['end']) as $d) {
                $dates[] = $d;
            }
        }

        $col       = fn(int $i) => \PhpOffice\PhpSpreadsheet\Cell\Coordinate::stringFromColumnIndex($i);
        $firstDay  = 4;                                // column D
        $lastDay   = $firstDay + count($dates) - 1;
        $notesCol  = $lastDay + 1;
        $totalCol  = $lastDay + 2;
        $sproutCol = $lastDay + 3;
        $dayRange  = fn(int $row) => $col($firstDay) . $row . ':' . $col($lastDay) . $row;

        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Manual Report');

        $sheet->setCellValue('A1', "DTR — Payroll period {$breakdown['start']} to {$breakdown['end']}");
        $sheet->setCellValue($col($notesCol) . '1', 'ADJUSTMENTS');
        $sheet->setCellValue($col($totalCol) . '1', 'TOTAL');
        $sheet->setCellValue($col($sproutCol) . '1', 'Sprout');

        $sheet->setCellValue('A2', 'ID');
        $sheet->setCellValue('B2', 'NAME');
        $sheet->setCellValue('C2', 'Type');
        foreach ($dates as $i => $d) {
            // Explicit strings keep the leading zero on day numbers ("01").
            $sheet->setCellValueExplicit($col($firstDay + $i) . '2', $d->format('d'), \PhpOffice\PhpSpreadsheet\Cell\DataType::TYPE_STRING);
            $sheet->setCellValue($col($firstDay + $i) . '3', $d->format('D'));
        }
        $sheet->setCellValue($col($notesCol) . '2', 'Indicate as Notes/Comments the Date');
        $sheet->setCellValue($col($totalCol) . '2', 'HRS');
        $sheet->setCellValue($col($sproutCol) . '2', 'HRS');
        $sheet->getStyle('A1:' . $col($sproutCol) . '3')->applyFromArray([
            'fill'      => ['fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID, 'startColor' => ['rgb' => self::DTR_HEADER]],
            'font'      => ['bold' => true, 'color' => ['rgb' => 'FFFFFF']],
            'alignment' => [
                'horizontal' => \PhpOffice\PhpSpreadsheet\Style\Alignment::HORIZONTAL_CENTER,
                'vertical'   => \PhpOffice\PhpSpreadsheet\Style\Alignment::VERTICAL_CENTER,
                'wrapText'   => true,
            ],
        ]);
        $sheet->getRowDimension(2)->setRowHeight(45);

        $row = 4;
        foreach ($breakdown['employees'] as $emp) {
            $blockStart = $row;

            foreach ($rowTypes as $type => $bucket) {
                $sheet->setCellValueExplicit("A{$row}", (string) $emp['id'], \PhpOffice\PhpSpreadsheet\Cell\DataType::TYPE_STRING);
                $sheet->setCellValue("B{$row}", $emp['name']);
                $sheet->setCellValue("C{$row}", $type);
                $sheet->getStyle("C{$row}")->applyFromArray([
                    'fill' => ['fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID, 'startColor' => ['rgb' => $typeFill($type)]],
                    'font' => ['bold' => true, 'size' => 8, 'color' => ['rgb' => $typeFontRed($type) ? 'FF0000' : '000000']],
                ]);

                if ($bucket) {
                    foreach ($dates as $i => $d) {
                        $hours = $emp['days'][$d->format('Y-m-d')][$bucket] ?? 0;
                        if (round($hours, 2) != 0) {
                            $sheet->setCellValue($col($firstDay + $i) . $row, round($hours, 2));
                        }
                    }
                }

                $sheet->setCellValue($col($totalCol) . $row, '=SUM(' . $dayRange($row) . ')');
                $sheet->setCellValue(
                    $col($sproutCol) . $row,
                    $type === 'Hours Worked'
                        ? '=SUM(' . $dayRange($row) . ')'
                        : '=TEXT(SUM(' . $dayRange($row) . ')/24,"[hh]:mm")'
                );
                $row++;
            }

            // Closing row per employee: ID + NAME, blank Type, block total in a yellow TOTAL cell.
            $blockEnd = $row - 1;
            $sheet->setCellValueExplicit("A{$row}", (string) $emp['id'], \PhpOffice\PhpSpreadsheet\Cell\DataType::TYPE_STRING);
            $sheet->setCellValue("B{$row}", $emp['name']);
            $sheet->setCellValue($col($totalCol) . $row, '=SUM(' . $col($totalCol) . $blockStart . ':' . $col($totalCol) . $blockEnd . ')');
            $sheet->getStyle($col($totalCol) . $row)->applyFromArray([
                'fill' => ['fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID, 'startColor' => ['rgb' => 'FFFF00']],
                'font' => ['bold' => true],
            ]);
            $row++;
        }

        $lastRow = max($row - 1, 3);
        $sheet->getStyle('A1:' . $col($sproutCol) . $lastRow)->getBorders()->getAllBorders()
            ->setBorderStyle(\PhpOffice\PhpSpreadsheet\Style\Border::BORDER_THIN);
        $sheet->setAutoFilter("A3:C{$lastRow}");

        $sheet->getColumnDimension('A')->setWidth(18);
        $sheet->getColumnDimension('B')->setWidth(32);
        $sheet->getColumnDimension('C')->setWidth(42);
        $sheet->freezePane($col($firstDay) . '4');

        (new \PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet))->save($path);

        Log::info("generateDtrReport: wrote {$path}", [
            'employees' => count($breakdown['employees']),
            'period'    => [$breakdown['start'], $breakdown['end']],
        ]);
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

        $holidays = self::PUBLIC_HOLIDAYS[$year] ?? [];
        if (!$holidays) {
            Log::warning("calculateTotalNonWorkingDays: no public holiday list for {$year}; only Sundays were seeded.");
        }

        DB::beginTransaction();
        try {
            foreach ($sundays as $s) {
                $exists = DB::table('custom_dates')->where('record_date', $s)->where('title', 'Sunday Rest Day')->first();
                if (!$exists) {
                    DB::table('custom_dates')->insert([
                        'record_date' => $s,
                        'title' => 'Sunday Rest Day',
                        'holiday_type' => 'Rest Day',
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

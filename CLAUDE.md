# Attendance Management System — CLAUDE.md

## Stack
- **Framework:** Laravel 9.x (PHP 8.1+)
- **Database:** PostgreSQL
- **Frontend:** Blade templates, Yajra DataTables, Chart.js
- **Key packages:** `phpoffice/phpspreadsheet`, `league/csv`, `laravel/sanctum`

## Running the project
```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

## Architecture overview

### Services (core computation — no Python dependency)
| File | Purpose |
|------|---------|
| `app/Services/ComputationService.php` | ORD/RD/ND overtime calculation, DB insert/update for `overtimes` and `security_attendance` |
| `app/Services/AttendanceProcessor.php` | Biometric file ingestion (CSV/XLSX → `attendance_records`), payroll CSV generation, certificate finalization |

`ComputationService` has three public computation methods:
- `autocalculateOrd($row, $nonWorkingDays, $data, ...)` → `[ord_ot, ord_nd, ord_nd_ot]`
- `autocalculateRdAndOvertime(array $row, $data)` → `['rd', 'rd_ot', 'rd_nd', 'rd_nd_ot']`
- `logOvertimeDb(...)` — upserts an `overtimes` record with HH:MM formatted fields

`AttendanceProcessor` public methods:
- `processFile($filePath, $outputDir, $biometricImportsId)` — full biometric file pipeline
- `generatePayrollReport(int $biometricImportsId)` — writes `public/python/payroll file.csv`
- `finalizeCertificates($certificatesPath, $overtimeLogsPath, $outputDir)` — processes `attendance_certificates.json`

### Key models
| Model | Table | Notes |
|-------|-------|-------|
| `EmployeeManagement` | `employee_management` | `unique_id`, `schedule`, `department`, `relievers` |
| `AttendanceRecord` | `attendance_records` | `earliest_time`, `latest_time`, `biometric_imports_id` |
| `Overtime` | `overtimes` | All time fields stored as `HH:MM` strings |
| `BiometricHistoryList` | `biometric_imports` | `status='load'` marks the active import |
| `ScheduleAdjustment` | `schedule_adjustments` | Approval workflow; triggers OT recalculation |
| `CertificateOfAttendance` | `certificate_of_attendances` | Approval workflow |
| `CustomDate` | `custom_dates` | Holidays and rest days; drives RD/ORD split |
| `Csvimport` | `csvimports` | Payroll data after report generation |

### Controllers and what replaced Python
| Controller | Method | Was | Now |
|-----------|--------|-----|-----|
| `CsvimportController` | `uploadCSV()` | `autocompute_attendance.py` | `AttendanceProcessor::processFile()` |
| `CsvimportController` | `reportGeneration()` | `compute_attendance.py` | `AttendanceProcessor::generatePayrollReport()` |
| `CsvimportController` | `finalizeAttendanceCertificates()` | `attendance_manager.py` | `AttendanceProcessor::finalizeCertificates()` |
| `CsvimportController` | `runEditOt()` | `edit_ot.py` | `ComputationService` + DB update |
| `OvertimeController` | `updateTime()` | `edit_ot.py overtimes` | `ComputationService::autocalculateOrd/Rd` + `logOvertimeDb()` |
| `ScheduleAdjustmentController` | `approve()` | `edit_ot.py schedule_adjustment` | `ComputationService::autocalculateOrd/Rd` + `logOvertimeDb()` |

## Overtime calculation logic

### ORD (ordinary workday)
- Skip if date is in `custom_dates` or employee has `leaves = true`
- Resolve schedule from `schedule_adjustments` first, then `employee_management.schedule`
- **SG Vesta** department: auto-detect `7-19` vs `19-7` by earliest punch time proximity
- **Late rule:** if `earliest_time > schedule_start + 15min`, shift `in_time` to `schedule_start + 1h`
- Hourly loop from `in_time` to `out_time`:
  - First 8 hours = regular (`ord_nd` if 22:00–06:00)
  - After 8 hours = OT (`ord_ot` or `ord_nd_ot` if 22:00–06:00)

### RD (rest/non-working day)
- Only runs when `record_date` is in `custom_dates`
- Same schedule resolution and SG Vesta logic as ORD
- Base `rd` hours: 8 for day shifts; 6 / 2 / 1 for specific night shifts
- Hourly loop: first 9 hours = regular (8 + 1 break); after 9 = `rd_ot` or `rd_nd_ot`

### Holiday classification in payroll report
| `custom_dates.holiday_type` | Mapped to |
|-----------------------------|-----------|
| `Regular Holiday` / `Legal Holiday` | `lh_*` columns |
| `Special Non-Working Holiday` | `sh_*` columns |
| `Rest Day` (Sundays) | `rd_*` columns |

## Biometric import flow
1. Upload CSV/XLSX → `CsvimportController::uploadCSV()` → `AttendanceProcessor::processFile()`
2. File is stored at `storage/app/public/python/DailyAttendance.<ext>`
3. Punches grouped by Personnel ID, paired into earliest/latest per day
4. Night-shift employees (codes: `18-6`, `19-7`, etc.) use cross-midnight pairing
5. Records inserted into `attendance_records`; OT seeded into `overtimes`
6. `BiometricHistoryList` with `status='load'` controls which import is "active"

## Payroll report flow
1. `reportGeneration()` → `AttendanceProcessor::generatePayrollReport($biometricImportId)`
2. Writes `public/python/payroll file.csv`
3. `importCSV()` reads that CSV and populates `csvimports` table
4. `exportCsv()` allows downloading the final payroll data

## Role-based access
- `role:admin` — full access (organization settings, biometric data, CSV import)
- `role:user` — restricted to own department's overtime, leave, schedule adjustments

## Non-working days
- Loaded from `custom_dates` table (populated by `AttendanceProcessor::calculateTotalNonWorkingDays()`)
- Philippine public holidays hardcoded for the current year
- Custom holidays can be added via `CustomDateController`

## Important conventions
- All time fields (`ord_ot`, `rd`, `ord_nd`, etc.) are stored as `HH:MM` strings, not decimals
- `employee_name` format is always `"LAST, FIRST"` (uppercase)
- `biometric_imports_id` on every major table links records to a specific import batch
- Do **not** call `exec()` or shell Python — all computation is in `ComputationService` and `AttendanceProcessor`

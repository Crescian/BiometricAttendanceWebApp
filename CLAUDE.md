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
| `app/Services/AttendanceProcessor.php` | Biometric file ingestion (CSV/XLSX → `attendance_records`), payroll CSV generation |

`ComputationService` has three public computation methods:
- `autocalculateOrd($row, $nonWorkingDays, $data, ...)` → `[ord_ot, ord_nd, ord_nd_ot]`
- `autocalculateRdAndOvertime(array $row, $data)` → `['rd', 'rd_ot', 'rd_nd', 'rd_nd_ot']`
- `logOvertimeDb(...)` — upserts an `overtimes` record with HH:MM formatted fields

`AttendanceProcessor` public methods:
- `processFile($filePath, $outputDir, $biometricImportsId)` — full biometric file pipeline
- `generatePayrollReport(string $start, string $end)` — writes the payroll CSV/XLSX, DTR and security reports via `AttendanceProcessor::reportPath()`

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

## Imports share days: deleting one
- `attendance_records` holds **one row per employee per day across all imports** (unique index). A re-upload skips days that already exist, so the earlier import keeps them.
- Payroll and DTR are built **by date range** (`AttendanceProcessor::buildDailyBreakdown()`), not by import. An import's payroll can depend on days that are tagged with a different import.
- `BiometricHistoryListController::destroy()` (and `deletePreview()`, which reports the same outcome):
  - **Days inside another import's `period_start`–`period_end`** are re-tagged to that import, in every per-day table (`DAY_TABLES`). Unlocked imports are chosen first, then the loaded one, then the newest. A row with an `attendance_records_id` follows its attendance record rather than its own date.
  - The plan, the lock check and the changes run in one transaction that locks every `biometric_imports` row. The import row is deleted with a query-builder delete, so only the detailed audit entry is written.
  - **Days no other import covers** are deleted, along with their `overtimes`, `security_attendance` and `dtr_report` rows. Leaves, certificates and schedule adjustments attached to those records go with them through `attendance_records_id ON DELETE CASCADE`.
  - **Leaves, certificates, schedule adjustments and `csvimports`** are never deleted just for their import tag. Their `biometric_imports_id` FK is `SET NULL`. `csvimports` is kept on purpose as the record of what was paid.
  - **Locked imports:** a locked import can't be edited or deleted, and nothing is ever moved into one. The request returns a 423 error.
  - A delete is also refused if removing a day would cascade into a locked import's overtime, leaves, certificates or adjustments. Approval records that only a locked import would take are kept untagged instead of blocking the delete.
  - An upload's default payroll period is the file's first and last day, including days skipped because an earlier import already has them, so those days stay covered.
- Never delete per-day data by `biometric_imports_id` alone. Check whether another import's period covers that day first.

## Payroll report flow
1. `reportGeneration()` → `AttendanceProcessor::generatePayrollReport($biometricImportId)`
2. Writes `storage/app/reports/payroll file.csv` (plus `.xlsx`, `reportdtr.xlsx`, `security.xlsx`)
3. `importCSV()` reads that CSV and populates `csvimports` table
4. `exportCsv()` allows downloading the final payroll data

## Role-based access
- `role:admin` — full access (organization settings, biometric data, CSV import)
- `role:user` — restricted to own department's overtime, leave, schedule adjustments
- Report downloads (`download.payrollfile`, `download.reportdtr`, `download.convertedfile`) and the payroll export (`export.csv`) are admin-only. `download.security` also allows user id 7, the security account, matching the check in `report_generation.blade.php`.

## Non-working days
- Loaded from `custom_dates` table (populated by `AttendanceProcessor::calculateTotalNonWorkingDays()`)
- Philippine public holidays hardcoded for the current year
- Custom holidays can be added via `CustomDateController`

## Performance
- Upload and payroll generation must not query per row. `ComputationService::buildContext()` preloads employees by name, schedule adjustments and non-working days; pass it as the optional `$context` to `autocalculateOrd()` / `autocalculateRdAndOvertime()` when computing many rows. Single-row callers (Overtime page, schedule approval) omit it and query as before.
- Bulk writes go in chunks (`insert()` of 500), e.g. `insertAttendanceRecords()` and `flushOvertimes()`.
- Measured on a half-month file (8,994 attendance rows): upload 63 s → 6.4 s, payroll breakdown 4.3 s → 0.35 s, with identical results.

## Production settings (deploy checklist)
- `APP_ENV=production`, `APP_DEBUG=false` (debug pages leak stack traces and config).
- On every deploy, as www-data: `composer install --no-dev --optimize-autoloader`, `php artisan migrate --force`, `config:cache`, `route:cache`, `view:cache`.
- OPcache: `opcache.validate_timestamps=0` (restart PHP-FPM on deploy), `opcache.memory_consumption=192`.
- `CACHE_DRIVER=redis`, `SESSION_DRIVER=redis` (Redis runs as `attendance_redis`).
- PHP-FPM: size `pm.max_children` to the server's RAM (about 60 MB per worker; the default is 5). `max_execution_time` of 120 gives large uploads a safety margin.

## Important conventions
- All time fields (`ord_ot`, `rd`, `ord_nd`, etc.) are stored as `HH:MM` strings, not decimals
- `employee_name` format is always `"LAST, FIRST"` (uppercase)
- `biometric_imports_id` on every major table links records to a specific import batch
- Generated reports contain names and pay: write them only through `AttendanceProcessor::reportPath()` (`storage/app/reports`, outside the web root) and serve them through the logged-in `download.*` routes. Never write them under `public/`.
- Don't keep working state in JSON files under `public/`. The old Python-era JSON endpoints (`attendance_certificates.json`, `overtime_logs.json`, `employee_dates.json`) were removed. Certificates, overtime and schedules go through their database tables and approval workflows.
- Do **not** call `exec()` or shell Python — all computation is in `ComputationService` and `AttendanceProcessor`

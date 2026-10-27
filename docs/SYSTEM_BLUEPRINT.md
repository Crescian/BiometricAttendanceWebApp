# Attendance & Overtime System — Blueprint

How the system works end to end, from importing biometric punches to producing the payroll report.

- **Part A: Plain-language guide.** For HR, payroll and supervisors. No technical terms.
- **Part B: Technical blueprint.** For developers. Every calculation, with file and line references.
- Step-by-step rule flowcharts and a fully traced scenario are in `SYSTEM_BLUEPRINT_DETAILED.md`.

All behaviour below comes from the code as of 2026-09-24. File references look like `path:line`.


---

# Part A: Plain-language guide (non-technical)

This part explains, without technical terms, how the system turns fingerprint scans into a payroll report. It follows the order you use the system in: **prepare → import → review → generate report**.

---

## The big picture

```
  1. PREPARE            2. IMPORT               3. REVIEW                 4. REPORT
 ─────────────       ────────────────       ──────────────────       ──────────────────
 Employee list   →   Upload the           →   Supervisors fix      →   System recounts
 Holiday list        fingerprint file         missing days,             every day and
                     System builds each       schedules, OT             builds the
                     person's daily                                     payroll file
                     time-in / time-out
```

**The one idea to remember:** when you click *Generate Report*, the system **recounts everything from the daily time-in and time-out records**. The OT numbers shown on the approval screens are only a preview.

---

## Step 1: Prepare (before importing)

The system needs two lists to be correct before anything else.

### 1a. The employee list
For each employee, it holds:
- their **name**, written as `LAST NAME, FIRST NAME` (for example `DELA CRUZ, JUAN`)
- their **regular schedule**, written as start–end hours (for example `8-17` means 8:00 AM to 5:00 PM, and `19-7` means 7:00 PM to 7:00 AM the next morning)
- their **department**
- whether they are a **reliever** (someone who covers different shifts)

> ⚠️ The name must be spelled **exactly** the same as in the fingerprint machine. If it isn't, that person's attendance is silently skipped.

### 1b. The holiday and rest-day calendar
Every date on this list is treated as a **non-working day**. Each date has a type:

| Type | Report section it goes to |
|---|---|
| Regular / Legal Holiday | **LH** columns |
| Special Non-Working Holiday | **SH** columns |
| Rest Day (e.g. Sundays) | **RD** columns |

> ⚠️ The system does **not** add Sundays or holidays by itself. Anything missing from this list is treated as a normal workday.

---

## Step 2: Import the fingerprint file

The admin uploads the file from the fingerprint machine. It is simply a long list of scans: *who* scanned and *when*. The machine doesn't say whether a scan was a time-in or a time-out, so the system has to work that out.

As soon as the file is chosen, the system:
1. **Starts a new payroll period** and makes it the active one. Every screen then shows this period.
2. **Groups the scans** by employee, in time order.
3. **Turns scans into daily records** of one time-in and one time-out per shift, using one of three methods (below).
4. **Skips** records that can't be used, such as a day with only one scan.
5. **Makes a first guess of overtime** for the approval screens (see Step 3).

### How the system decides time-in and time-out

It picks **one method per employee** for the whole file:

```
Is the employee marked as a reliever?
   ├─ Yes → RELIEVER method
   └─ No  → Is their schedule a night schedule, or have they EVER had
            a night schedule adjustment on file?
               ├─ Yes → NIGHT method
               └─ No  → DAY method
```

Night schedules are: 18-6, 19-7, 19-4, 20-5, 15-23, 15-24, 23-7, 23-8.

#### DAY method (regular day workers)
- For each calendar date, the **first scan is time-in** and the **last scan is time-out**. Scans in between, like lunch breaks, are ignored.
- Example: scans at 7:52, 12:01, 12:58 and 17:05 become **in 7:52, out 17:05**.
- If a person scans only once that day (forgot to scan out), **the day is dropped**. They need to file a Certificate of Attendance.

#### NIGHT method (night-shift workers)
- A scan at **2:00 PM or later** is treated as the start of a shift.
- Every scan within the **next 12 hours** belongs to that shift. The last one is the time-out.
- The shift is dated on the day it **started**.
- Example: 7:02 PM Monday → 6:58 AM Tuesday becomes **Monday, in 19:02, out 06:58**.
- ⚠️ If the time-out is **more than 12 hours** after the time-in (e.g. 6:50 PM → 7:05 AM), it doesn't count as part of the shift and **the whole day is dropped**.
- ⚠️ Morning scans that don't belong to any shift are ignored.

#### RELIEVER method (people covering day or night shifts)
- For each day, the system looks for an **afternoon or evening scan (12:00 PM or later)** and a **morning scan (before 12:00 PM) the next day**.
  - If it finds both, it records an **overnight shift** from that evening to the next morning.
  - If it doesn't, it uses that day's first and last scan as a **day shift**.
- Example (correct): 7:00 PM Wednesday → 7:00 AM Thursday is an overnight shift.
- ⚠️ Example (wrong): a reliever who works **day shifts two days in a row** (Mon 7:55–5:02 PM, Tue 7:58–5:10 PM) gets a fake overnight shift from **Mon 5:02 PM to Tue 7:58 AM**.

---

## Step 3: How the system counts hours (the formula)

This same counting method is used for approvals and for the final report. For each daily record it goes through these checks in order.

### ① Which schedule applies that day?
- If a **schedule adjustment** exists for that person on that date, that schedule is used.
  - ⚠️ This applies even if the adjustment is still pending or was cancelled.
- Otherwise the employee's **regular schedule** is used.
- **Special case, SG Vesta guards:** the system picks the 7AM–7PM or the 7PM–7AM shift by whichever start time the guard's first scan is closer to.

### ② Were they late?
- There is a **15-minute grace period** after the schedule start.
- If time-in is later than that, the system counts the day as starting **exactly 1 hour after the schedule start**.

| Schedule 8-17 | Scanned in | Counted from |
|---|---|---|
| On time or early | 7:52 | 7:52 (early time counts) |
| Within grace | 8:15 | 8:15 |
| Late | 8:25 | **9:00** |
| Very late | 10:00 | **9:00** ⚠️ gains an hour |

### ③ The 9-hour rule: regular time vs overtime
- The first **9 hours** from time-in are regular (8 hours of work + 1 hour break).
- Everything **after 9 hours is overtime (OT)**.
- For the no-break schedules (15-23 and 23-7), OT starts after 8 hours.

### ④ Night differential (ND)
- Time between **10:00 PM and 6:00 AM** is night time.
- The system counts the day **in 1-hour blocks from time-in**. Each whole block is marked "night" or "not night" by the time it **starts**.
- This gives four possible kinds of time:

| | Before 9 hours | After 9 hours |
|---|---|---|
| **Day time** | Regular (no extra) | **OT** |
| **Night time** | **ND** | **ND-OT** |

### ⑤ Workday or non-working day?
- **Normal workday:** results go to **Ord-OT, Ord-ND, Ord-ND-OT**.
- **Date on the holiday/rest-day list:** results go to the RD, SH or LH columns (by holiday type), plus a **fixed base credit**:
  - **8 hours** for day schedules (7-16, 8-17, 7-19, 6-15, 9-15, 10-18, 10-16)
  - **6, 2 or 1 hours** for some evening and late-night schedules (15-24, 23-8, 23-7)
  - ⚠️ **0 hours** for most night schedules (18-6, 19-7, 20-5…)

### Quick examples
| Who | Schedule | In → Out | Result |
|---|---|---|---|
| Worked late | 8-17 | 7:58 → 8:10 PM | 9 regular hours end at 4:58 PM, so **OT = 3h 12m** |
| Came in late | 8-17 | 8:25 → 5:30 PM | Counted from 9:00, which is under 9 hours, so **no OT** |
| Night shift | 19-7 | 7:02 PM → 6:58 AM | **ND 6h, ND-OT 2h, OT 56m** |
| Worked a holiday | 8-17 | 8:00 → 5:00 PM (Special holiday) | **SH = 8h** base, no OT |

---

## Step 4: Review and corrections

After the import, supervisors and admins review the period. It helps to know **which actions actually change pay**.

| What you do | What the system does | Changes the payroll report? |
|---|---|---|
| **Certificate of Attendance** approved (for a missed or forgotten scan) | Adds the missing day with the times you entered, then counts it | ✅ **Yes** |
| **Schedule Adjustment** filed or approved (e.g. moved to night shift that day) | Recounts that day with the new schedule | ✅ **Yes**, even while still pending |
| **Add a holiday** | That date moves from workday to holiday | ✅ **Yes** |
| **Approve / Cancel OT** on the OT Approval page | Only changes the OT's status | ❌ **No**: cancelled OT is still paid |
| **Edit time-in/out** on the OT Approval page | Updates the preview on that page only | ❌ **No**: the report uses the original scans |
| **Leave** approved | Only changes the leave's status | ❌ **No** |

> The OT Approval page shows a **first guess** made during import. It uses a simpler formula with no late rule, so its numbers can differ slightly from the final report.

---

## Step 5: Generate the report

When the admin clicks **Generate Report**, the system goes through **every daily record in the active period**, one employee at a time:

1. Is the date a workday or a non-working day? It counts **days present** for each.
2. It adds up **Hours Worked** = time-out − time-in − 1-hour break. This uses the actual scans, with no late rule.
3. It applies the formula from Step 3 and adds up OT, ND and ND-OT for workdays, and the RD, SH or LH figures for non-working days.
4. It writes one line per employee to the **payroll file**, saves a copy in the system, and downloads it.

### What the main report columns mean
| Column | Meaning |
|---|---|
| Hours Worked | Total time on site minus 1-hour breaks |
| Regular / Non-Working Days Present | Number of days attended on workdays / on holidays and rest days |
| Ord-OT · Ord-ND · Ord-ND-OT | Workday overtime · night hours · night overtime |
| RD-* | The same, for rest days (Sundays) |
| SH-* | The same, for special non-working holidays |
| LH-* | The same, for regular/legal holidays |
| Excess, SH-RD, LH-RD, DH columns | ⚠️ Not calculated yet: always 00:00 |

> ⚠️ Wait for the report to finish before opening the downloaded files. The download starts after a fixed 1-second delay and may contain the **previous** report.

---

## A week in the life: example

**Period:** Mon Aug 18 – Sun Aug 24, 2025. Thursday Aug 21 is a Special Holiday.

### Juan, day worker (8-17)
| Day | Scans | What the system did | Counted |
|---|---|---|---|
| Mon | 7:52 → 5:05 PM | Normal day | OT 13 min |
| Tue | 8:25 → 5:30 PM | Late, counted from 9:00 | No OT |
| Wed | 7:58 → 8:10 PM | Stayed late | OT 3h 12m |
| Thu (holiday) | 8:00 → 5:00 PM | Holiday work | SH 8h |
| Fri | 8:03 only | Only one scan, **dropped** → COA filed and approved | Day restored, no OT |

**Report:** 4 workdays + 1 holiday, Hours Worked 43.5, **Ord-OT 3:25**, **SH 8:00**

### Maria, night worker (19-7)
| Night | Scans | What the system did | Counted |
|---|---|---|---|
| Mon | 7:02 PM → 6:58 AM | Normal night | ND 6h, ND-OT 2h, OT 56m |
| Tue | 6:50 PM → 7:05 AM | Over 12 hours, **dropped** → COA filed and approved | ND 5h, ND-OT 3h, OT 15m |
| Wed | 7:10 PM → 7:00 AM | Normal night (break scan ignored) | ND 6h, ND-OT 2h, OT 50m |
| Thu (holiday) | 7:00 PM → 7:00 AM | Holiday night; base credit **0** for 19-7 | SH-ND 6h, SH-ND-OT 2h, SH-OT 1h |
| Sat | 7:05 PM → 7:00 AM Sun | Dated Saturday, so counted as a normal workday | ND 6h, ND-OT 2h, OT 55m |

**Report:** 4 workdays + 1 holiday, Hours Worked 54.93, **Ord-OT 2:56**, **Ord-ND 23:00**, **Ord-ND-OT 9:00**, SH-OT 1:00, SH-ND 6:00, SH-ND-OT 2:00

### Pedro, reliever (regular schedule 8-17)
| Day | Scans | What the system did | Counted |
|---|---|---|---|
| Mon | 7:55 → 5:02 PM | ⚠️ Paired with Tuesday's 7:58 AM as a **fake overnight shift**, then treated as "late" and counted from 9:00 AM | ⚠️ ~14h of OT that he didn't work |
| Tue | 7:58 → 5:10 PM | Normal day | OT 12 min |
| Wed | 7:00 PM → 7:00 AM | Night cover. A **schedule adjustment to 19-7** was filed, so it's counted correctly | ND 6h, ND-OT 2h, OT 1h |
| Fri | 8:00 → 5:00 PM | Normal day | No OT |
| Sat | Leave approved | No effect on the report | – |

**Report:** Ord-OT 7:10, Ord-ND 6:00, Ord-ND-OT 10:00, of which about 14 hours come from the fake Monday record.

> Without the schedule adjustment on Wednesday, Pedro's night would be checked against his 8-17 schedule. The system would count him as "late" from 9:00 AM that morning, adding about **13 more hours** of false OT.

---

## Watch-outs and practical tips

| Watch out for | What to do |
|---|---|
| Names must match the fingerprint machine exactly | Check the import summary for skipped employees |
| Sundays and holidays aren't added automatically | Add them to the calendar **before** generating the report |
| One-scan days and night shifts over 12 hours are dropped | File a **Certificate of Attendance** |
| Night work by relievers or day-schedule staff | File a **Schedule Adjustment** for that date |
| Reliever day shifts on back-to-back days become fake nights | Check relievers' records manually. This needs a system fix. |
| One night schedule adjustment makes the system treat that person as a night worker **for every future import** | Avoid filing night adjustments for day staff, or report it for fixing |
| Cancelled OT and approved leave don't reduce pay | Correct the underlying record (scans, COA or schedule) instead |
| Very late arrivals are credited from start + 1 hour | Review heavy-lateness cases manually |
| Night-shift staff get no base credit on holidays and rest days | Check holiday pay for night staff |
| Downloads may show the previous report | Download again after generation finishes |

---

## Glossary
| Term | Meaning |
|---|---|
| **Scan / punch** | One fingerprint reading at the machine |
| **Time-in / time-out** | First and last scan of a shift |
| **Period / batch** | One uploaded fingerprint file. Only one is active at a time. |
| **OT** | Overtime: time beyond 9 hours from time-in |
| **ND** | Night differential: time between 10 PM and 6 AM |
| **ND-OT** | Overtime that happens during night hours |
| **RD / SH / LH** | Rest day / Special holiday / Legal (regular) holiday |
| **COA** | Certificate of Attendance: adds a missing day manually |
| **Schedule Adjustment** | Changes one person's schedule for one day |
| **Reliever** | An employee who covers different shifts |

---

# Part B: Technical blueprint


## 1. The system in one picture

```
 ┌──────────────────────┐   (0) Setup, done once or occasionally
 │ Employee master CSV  │──► employee_management   (name, schedule, dept, salary)
 │ Holidays / rest days │──► custom_dates          (date + holiday_type)
 └──────────────────────┘

 ┌──────────────────────┐   (1) IMPORT: admin uploads the biometric file
 │ Biometric CSV / XLSX │──► AttendanceProcessor::processFile()
 └──────────────────────┘        ├─► biometric_imports   (new batch, status = 'load')
                                 ├─► attendance_records  (1 row per employee per shift)
                                 └─► overtimes           (seeded OT, status = 'Pending')

                            (2) REVIEW / CORRECT: users and admins, per active batch
   OT Approval page        ──► approve/cancel OT; edit in/out times → RECALCULATE
   Schedule Adjustment     ──► file → approve → RECALCULATE with the new schedule
   Certificate of Attend.  ──► file → approve → creates attendance_record → CALCULATE
   Leaves                  ──► file → approve (status only, see §9)

                            (3) REPORT: admin clicks "Generate Report"
   generatePayrollReport() ──► recomputes EVERYTHING from attendance_records
                               ├─► public/python/payroll file.csv + .xlsx
   importCSV()             ──► csvimports table
   exportCsv()             ──► csv download for the user
```

Key idea: **there are three different places where OT gets calculated**, and they don't all use the same formula:

| # | When | Code | Formula used | Output |
|---|------|------|--------------|--------|
| A | Biometric upload | `AttendanceProcessor::calculateHoursForBiometricImport` (`app/Services/AttendanceProcessor.php:461`) | Simplified: span − 1h break − 8h | `overtimes` seed rows |
| B | Single-record edits and approvals | `ComputationService::autocalculateOrd` / `autocalculateRdAndOvertime` (`app/Services/ComputationService.php:15`, `:143`) | Full hourly-block engine | `overtimes` row update |
| C | Report generation | Same engine as B, run on every attendance record | Full hourly-block engine | payroll CSV/XLSX |

The **payroll report uses C only**. It never reads the `overtimes` table, so OT approval status has no effect on the report (see §10).

---

## 2. Core data (tables)

| Table (Model) | What one row means | Key columns |
|---|---|---|
| `employee_management` (`EmployeeManagement`) | One employee | `unique_id`, `employee_name` (`"LAST, FIRST"`), `schedule` (e.g. `8-17`), `department`, `basic_salary`, `relievers` |
| `biometric_imports` (`BiometricHistoryList`) | One uploaded biometric file, which is one payroll period | `title`, `status` (`load` = the active batch, only one at a time), `imported_by`, `total_rows` |
| `attendance_records` (`AttendanceRecord`) | One employee's shift on one date: first and last punch | `employee_management_id`, `record_date`, `earliest_time`, `latest_time`, `weekday`, `leaves`, `biometric_imports_id` |
| `overtimes` (`Overtime`) | Computed OT for one attendance record, with its approval status | `ord_ot`, `ord_nd`, `ord_nd_ot`, `rd`, `rd_ot`, `rd_nd`, `rd_nd_ot` (all `HH:MM` strings), `status` (`Pending`/`Approved`/`Cancelled`), `original_earliest_time`/`original_latest_time` |
| `custom_dates` (`CustomDate`) | A non-working day | `record_date`, `title`, `holiday_type` (`Rest Day`, `Regular Holiday`, `Legal Holiday`, `Special Non-Working Holiday`) |
| `schedule_adjustments` (`ScheduleAdjustment`) | A one-day schedule override for one employee | `schedule`, `record_date`, `approval_status`, `attendance_records_id` |
| `certificate_attendance` (`CertificateOfAttendance`) | A manual attendance claim for a day with no punches | `date`, `earliest_time`, `latest_time`, `approval_status` |
| `leaves` (`Leave`) | A leave request | `record_date`, `leave_type`, `with_pay`, `status` |
| `security_attendance` | Hours worked for the `Security` department | `hours_worked`, `ot`, `nd` |
| `csvimports` (`Csvimport`) | One employee's row in the final payroll report | 40+ payroll columns, `entry_date`, `generate_status` |

The **active batch** is whichever `biometric_imports` row has `status='load'` (`BiometricHistoryList::getLoadedRecordId()`). Almost every screen and action filters by it. Switching batches on the CSV Import page (`BiometricHistoryListController::toggleStatus`, `:15`) changes what every other page shows.

### Schedule codes
A schedule is `"START-END"` in 24h hours: `8-17` means 08:00–17:00, and `19-7` means 19:00 to 07:00 the next day.

| Group | Codes | Used for |
|---|---|---|
| Night shifts | `18-6`, `19-7`, `19-4`, `20-5`, `15-23`, `15-24`, `23-7`, `23-8` | Cross-midnight punch pairing at import |
| No-break schedules | `15-23`, `23-7` | No 1h lunch break is deducted (the 8h regular window is used instead of 9h) |
| RD "day shifts" (8h base) | `7-16`, `8-17`, `7-19`, `6-15`, `9-15`, `10-18`, `10-16` | RD base hours |

---

## 3. Phase 0: Setup

### 3.1 Employee master import
**Trigger:** Biometric Data page → upload employee CSV → `POST /biometricData` → `EmployeeManagementController::import` (`app/Http/Controllers/EmployeeManagementController.php:21`)

CSV columns: `unique_id, employee_name, basic_salary, schedule, report_to, department, status`
- **Truncates `employee_management` first**, which is a full replacement of the table.
- `schedule`: any letter `a` is stripped (e.g. `7-16a` → `7-16`).
- `department` is uppercased.

> ⚠️ Truncation gives every employee a new `id`, so existing `attendance_records` / `schedule_adjustments` / `leaves` rows that point to old `employee_management_id`s become orphaned. Re-import employees only between payroll periods.

### 3.2 Non-working days (`custom_dates`)
**Trigger:** Dashboard → add holiday → `POST /custom-dates/store` → `CustomDateController::store` (`:46`)

Every date in `custom_dates` counts as a non-working day. `holiday_type` then decides which report bucket the hours go to (see §8.3).

`AttendanceProcessor::calculateTotalNonWorkingDays()` (`:1013`) can seed all Sundays plus the hard-coded PH holidays, but **nothing in the app calls it**. Sundays and holidays have to be added through the UI or SQL, or they are treated as ordinary workdays.

---

## 4. Phase 1: Biometric import

**Trigger:** CSV Import page → select file → `POST /upload-csv` → `CsvimportController::uploadCSV` (`app/Http/Controllers/CsvimportController.php:86`)

The upload runs **as soon as the file is selected**. The "Upload" button that comes after that only saves the title and row count.

### Step 1: Create the batch
- All existing `biometric_imports` get `status='unload'`. A new row is created with `status='load'`.
- The file is saved as `storage/app/public/python/DailyAttendance.<ext>`.

### Step 2: Read the file (`readAttendanceFile`, `:103`)
- The **first 2 rows are skipped** (a "Transactions" title row and the header row).
- Column positions: `A` Personnel ID · `B` First Name · `C` Last Name · `D` Department · `E` Attendance Area · `F` Serial No · `G` Attendance Point · **`H` Attendance time** · `I` Verification · `J` Photo · `K` Data Source
- The attendance time is parsed as `n/j/Y g:i` (e.g. `8/11/2025 7:00`), with a generic date parser as fallback. Rows that fail to parse are dropped.

### Step 3: Group punches (`groupByPersonnelId`, `:200`)
Punches are grouped by Personnel ID and sorted by time. The employee name is built as `"LastName, FirstName"`, which **must exactly match** `employee_management.employee_name`. If it doesn't, the person is skipped (`skipped_no_emp`).

### Step 4: Pair punches into shifts (`processPersonPunches`, `:219`)
Three pairing modes, chosen per employee:

| Mode | When | Rule |
|---|---|---|
| **Reliever** | `employee_management.relievers` is truthy | For each date: if there's a punch ≥ 12:00 and a punch the **next** day < 12:00, pair them as a NIGHT shift. Otherwise use the day's first and last punch. A lone punch becomes a SINGLE. |
| **Night** | Employee's master schedule **or any** of their schedule adjustments is a night-shift code | Each unused punch at ≥ 14:00 starts a shift. Every later punch within 12h joins it. Shift = first to last punch, dated on the start day. |
| **Day** | Everyone else | Per calendar date: earliest punch = in, latest punch = out. |

### Step 5: Insert `attendance_records` (`insertAttendanceRecords`, `:370`)
A record is skipped when:
- the employee isn't found (`skipped_no_emp`)
- `earliest_time == latest_time`, i.e. only one punch (`skipped_same_time`)
- the identical row already exists in this batch (`skipped_duplicate`)

Inserted with `late=false`, `leaves=false`, `weekday` = day name.

### Step 6: Seed `overtimes` (Formula A, `calculateHoursForBiometricImport`, `:461`)
For every attendance record in the batch:

```
span        = latest − earliest            (+24h if latest < earliest)
hoursWorked = span − 1h                     (no deduction for 15-23 / 23-7)
            = 0 if the date is in custom_dates
ord_ot      = max(hoursWorked − 8, 0)
nd_hours    = exact minutes of the span inside 22:00–06:00   (secondsInNdWindow, :551)
```
An `overtimes` row is inserted with `type='ord'` and `status='Pending'`:
`ord_ot = ord_ot`, `rd = 0`, `rd_nd = nd_hours`, and every other field `00:00`.
If an `ord` row already exists for that employee, date and batch, nothing changes.

For the `Security` department, `security_attendance.hours_worked` = `round(hoursWorked)`.

> This seed is a **preview** for the OT Approval page. It ignores the late rule, schedule adjustments, SG Vesta detection and the ORD/RD split, and it puts ND hours into `rd_nd` even on workdays. Values are corrected only when a record is recalculated (§6).

---

## 5. The calculation engine (Formula B/C)

`app/Services/ComputationService.php`. This engine produces the numbers in the payroll report.

### 5.1 Shared preparation (ORD and RD)

1. **Resolve schedule**
   `schedule_adjustments.schedule` for that employee and date, if any row exists. **The approval status is not checked**, so Pending and Cancelled adjustments also apply. If there is none, `employee_management.schedule` is used. No schedule means a result of 0.
2. **SG Vesta override**
   If department = `SG VESTA`, the schedule is `7-19` when the first punch is closer to 07:00 than to 19:00. Otherwise it is `19-7`.
3. **Late rule**
   `start = first number of schedule`
   If `earliest > start:15`, then `in_time = start + 1h`. Otherwise `in_time = earliest`.
   Being more than 15 minutes late means the day is counted from one hour after the schedule start. Arriving early counts from the actual punch.
4. **Cross midnight**
   If `out ≤ in`, add 24h to `out`.

### 5.2 ORD: ordinary workday, `autocalculateOrd` (`:15`)
Runs only when the date is **not** in `custom_dates` and `leaves` is false.

```
regularLimit = 9h   (8 worked + 1 break)       — 8h for 15-23 / 23-7
walk from in_time to out_time in 1-hour blocks (the last block may be partial):
   isND = block START time is in 22:00–06:00
   if worked-so-far < regularLimit:  worked += block;  if isND → ord_nd += block
   else:                             if isND → ord_nd_ot += block  else → ord_ot += block
returns [ord_ot, ord_nd, ord_nd_ot] in decimal hours (2 dp)
```

### 5.3 RD: rest day or holiday, `autocalculateRdAndOvertime` (`:143`)
Runs only when the date **is** in `custom_dates`. The hourly walk is identical to ORD, with a fixed 9h regular limit (no no-break exception), and it produces `rd_nd`, `rd_ot`, `rd_nd_ot`.

`rd` is **not** the hours worked. It is a fixed base value that depends on the schedule:

| Schedule | `rd` |
|---|---|
| `7-16`, `8-17`, `7-19`, `6-15`, `9-15`, `10-18`, `10-16` | 8 |
| `15-24` and in_time hour ≥ 15 | 6 |
| `23-8` and in_time hour ≥ 23 | 2 |
| `23-7` and in_time hour ≥ 23 | 1 |
| anything else (e.g. `18-6`, `19-7`, `20-5`) | **0** |

### 5.4 Saving: `logOvertimeDb` (`:282`)
Decimal hours become `HH:MM` via `round(hours × 60)` minutes, e.g. `2.67 → "02:40"`. It finds the `overtimes` row by (name, date, type, batch, attendance_record_id):
- **Existing `ord` row:** only `ord_ot`, `ord_nd`, `ord_nd_ot`, `schedule`, `schedule_shift` are updated.
- **No row:** a new row is inserted with every field.

Every UI caller passes `type='ord'`. That means RD values from a recalculation are **not saved on existing rows**, except by `runEditOt`, which writes all fields directly.

### 5.5 Worked examples

**Ex 1: Regular day with OT.** Schedule `8-17`, punches 07:50 → 19:30, normal weekday.
- 07:50 ≤ 08:15, so not late and in = 07:50.
- Regular window of 9h ends at 16:50. Blocks 16:50–17:50, 17:50–18:50 and 18:50–19:30 are OT.
- **ord_ot = 2h40m → `02:40`**, ord_nd = 0.

**Ex 2: Late arrival.** Schedule `8-17`, punches 08:20 → 17:00.
- 08:20 > 08:15, so in = **09:00**. The span is 8h, under the 9h window.
- **ord_ot = 0.** In the report, Hours Worked still uses the real punches: 8h40m − 1h = 7.67h.

**Ex 3: Night shift.** Schedule `19-7`, punches 18:55 → 07:10 (next day).
- Blocks start at 18:55, 19:55, 20:55, 21:55, 22:55, 23:55, 00:55, 01:55, 02:55. That is the 9 regular hours.
  - ND blocks among them (start between 22:00 and 06:00): 22:55 through 02:55, so **ord_nd = 5h**.
  - The 21:55 block starts before 22:00, so none of its 55 ND minutes are counted (see the note below).
- OT blocks: 03:55, 04:55, 05:55 (ND) give **ord_nd_ot = 3h**. 06:55–07:10 (not ND) gives **ord_ot = 0:15**.
- ⚠️ This 12h15m shift could only reach the engine through a COA or an edit. Import pairing drops night shifts longer than 12h (see `SYSTEM_BLUEPRINT_DETAILED.md` §5).

**Ex 4: Sunday.** Schedule `8-17`, `custom_dates` has the date as `Rest Day`, punches 08:00 → 20:00.
- rd = 8 (day shift base). Regular window 08:00–17:00, then OT 17:00–20:00.
- **rd = `08:00`, rd_ot = `03:00`** → goes to the RD columns. With `Regular Holiday` it would go to LH, and with `Special Non-Working Holiday` to SH.

> **Note on precision:** each block is classified by its **start** time. A block that starts at 21:30 is counted as entirely non-ND even though 30 of its minutes fall after 22:00. Blocks are anchored to the punch-in time, not to clock hours.

### 5.6 Schedule-change helper: `adjustShiftWithSnapshot` (`:510`)
Used only when a schedule adjustment is approved:
- It appends the existing OT values to `storage/app/schedule_adjustment_snapshots.json` as an audit and undo trail.
- It computes `duration = punch-out − punch-in` (midnight-safe) and `ot = max(duration − 8, 0)`.
  - This `ot` value is only returned in the JSON response. The saved values come from §5.2/5.3.

---

## 6. Phase 2: Review and correction actions (what triggers a recalculation)

All actions below apply to the **active batch**.

| User action (page) | Route → method | Recalculates? | What changes |
|---|---|---|---|
| Approve OT (OT Approval) | `POST /overtime/{id}/approved` → `OvertimeController::approve` | No | `overtimes.status = Approved` |
| Cancel OT | `POST /overtime/{id}/cancelled` → `cancel` | No | `status = Cancelled` |
| Open or edit OT row | `GET /overtime/{id}` → `edit` | No | ⚠️ **also sets status = Approved** as a side effect |
| **Edit in/out time** (OT Approval) | `POST /overtime/{id}` → `OvertimeController::updateTime` (`:190`) | **Yes (B)** | Saves the originals once in `original_*_time`, stores the new times, runs ORD+RD, `logOvertimeDb` updates the ORD fields. `attendance_records` is **not** changed, so the report still uses the old punches. |
| Edit OT (legacy endpoint) | `POST /run-edit-ot` → `CsvimportController::runEditOt` (`:200`) | **Yes (B)** | Updates `attendance_records` times **and** all 7 OT fields |
| File schedule adjustment | `POST /scheduleAdjustment/store` | No | New row, `Pending`. It already affects the engine and the report (§5.1 step 1). |
| **Approve schedule adjustment** | `POST /scheduleAdjustment/{id}/approved` → `ScheduleAdjustmentController::approve` (`:104`) | **Yes (B)** | Snapshot saved, then ORD+RD with the new schedule, then `logOvertimeDb` |
| File certificate of attendance | `POST /certificate-attendance/store` | No | Row `Pending`. With employee = "all", rows are created directly as `Approved` **without** attendance records. |
| **Approve certificate** | `POST /certificateOfAttendance/{id}/approved` → `CertificateOfAttendanceController::approve` (`:45`) | **Yes (B)** | **Creates an `attendance_records` row** (`attendance_area='COA'`), so it counts in the report, then ORD+RD, then a new `overtimes` row |
| File / approve / cancel leave | `/leave/store`, `/leave/{id}/approved` | No | Status only (see §9) |
| Add holiday | `POST /custom-dates/store` | No immediate recalculation | Changes ORD↔RD classification the next time anything is calculated, including the report |
| Switch active batch | `POST /biometric-history-list/toggle-status` | No | Changes which batch every page and the report use |

Role scoping: `role:user` pages pass their department, so users only see their own department's rows. `role:admin` sees everything.

---

## 7. Phase 3: Report generation

**Trigger:** Report Generation page → "Start Report Generation" → modal → **Generate Report** → JS `GenerateCSVreportFiltered()` (`resources/views/report_generation.blade.php:331`).

The four-step "Overtime / Certificate / Schedule / Leaves" checklist in the modal is a **cosmetic timer**. It doesn't run anything.

Clicking Generate Report fires these in parallel:

1. `POST /report-generation` → `CsvimportController::reportGeneration` (`:150`) → **`AttendanceProcessor::generatePayrollReport(activeBatchId)`** (`:714`)
   - when it succeeds, the JS calls `POST /csv-import` → `importCSV` (`:415`)
2. After 1s (admin only): download `payroll file.xlsx` and `reportdtr.xlsx`. The user with id 7 gets `security.xlsx` instead.
3. `GET /export-csv` → `exportCsv` (`:648`) → downloads `csv_imports_.csv`

### 7.1 `generatePayrollReport`: the payroll formula
Loads every `attendance_records` row of the batch joined to `employee_management`, then for each row:

```
if date ∈ custom_dates:  Total Non-Working Days Present += 1
else:                    Total Regular Working Days Present += 1

Hours Worked += max(span − break, 0)          break = 1h, or 0 for 15-23 / 23-7
                                              (actual punches; no late rule; uses master schedule)

if date ∉ custom_dates:  Ord-OT, Ord-ND, Ord-ND-OT += autocalculateOrd(row)
else:                    r = autocalculateRdAndOvertime(row)
    holiday_type = 'Regular Holiday' | 'Legal Holiday'  → LH, LH-OT, LH-ND, LH-ND-OT += r
    holiday_type = 'Special Non-Working Holiday'        → SH, SH-OT, SH-ND, SH-ND-OT += r
    anything else ('Rest Day', …)                       → RD, RD-OT, RD-ND, RD-ND-OT += r
```
Totals are converted to `HH:MM`. `Hours Worked` stays decimal.

### 7.2 Output columns

| Column | Source |
|---|---|
| ID, Name, Basic | `employee_management.unique_id`, `employee_name`, `basic_salary` |
| Hours Worked | Σ (span − break) |
| Total Regular / Non-Working Days Present | counts of attendance records |
| Ord-OT, Ord-ND, Ord-ND-OT | ORD engine |
| RD, RD-OT, RD-ND, RD-ND-OT | RD engine on `Rest Day` dates |
| SH, SH-OT, SH-ND, SH-ND-OT | RD engine on Special holidays |
| LH, LH-OT, LH-ND, LH-ND-OT | RD engine on Regular/Legal holidays |
| RegNDExcess, Sun-ND-Excess, SH/LH-ND-Excess, **all SH-RD, LH-RD, DH, DH-RD** | **Always `00:00`**. Not implemented. |

Written to `public/python/payroll file.csv` and `payroll file.xlsx`.

### 7.3 `importCSV` → `csvimports`
- Deletes `csvimports` rows with `entry_date = today`.
- Reads `payroll file.csv` and inserts one row per employee, tagged with `biometric_imports_id`.

### 7.4 `exportCsv`
- Exports **all** `csvimports` rows (every batch, every date).
- Sets `generate_status = true` on all of them.

---

## 8. Quick reference

### 8.1 Glossary
| Code | Meaning |
|---|---|
| ORD | Ordinary working day (date not in `custom_dates`) |
| RD | Rest day or holiday (date in `custom_dates`) |
| OT | Overtime: time after the 9h window (8h work + 1h break) |
| ND | Night differential: time between 22:00 and 06:00 |
| ND-OT | Overtime that falls within ND hours |
| LH / SH | Legal (Regular) holiday / Special non-working holiday |
| COA | Certificate of Attendance: a manual attendance record |

### 8.2 Constants
| Constant | Value | Where |
|---|---|---|
| Late grace | 15 min after schedule start | ComputationService `:70`, `:208` |
| Late penalty | in_time = schedule start + 1h | same |
| Regular window | 9h (8h for `15-23`, `23-7`) | `:96–97`, `:236` |
| ND window | 22:00–06:00 | `:90–91`, `:234–235` |
| Night pairing window | punch ≥ 14:00, then up to 12h | AttendanceProcessor `:321–324` |
| Reliever pairing | evening ≥ 12:00 + next-day morning < 12:00 | `:262–264` |
| Break deduction in Hours Worked | 1h (0 for `15-23`, `23-7`) | `:771–772` |

### 8.3 Holiday type → report bucket
| `custom_dates.holiday_type` | Bucket |
|---|---|
| `Regular Holiday`, `Legal Holiday` | LH |
| `Special Non-Working Holiday` | SH |
| `Rest Day` or anything else | RD |

When a date has two `custom_dates` rows (e.g. a holiday that falls on a Sunday), whichever row loads last wins.

---

## 9. What does *not* affect the numbers

- **Leaves.** Approving a leave only changes `leaves.status`. `attendance_records.leaves` is never set to true anywhere, so the "skip if on leave" branches in the engine never trigger.
- **OT approval / cancellation.** The report recomputes from `attendance_records` and ignores `overtimes`, so a Cancelled OT is still paid in the report.
- **Time edits on the OT Approval page** (`updateTime`). These change `overtimes` only, not `attendance_records`, so the report uses the original punches.
- **Schedule adjustment status.** The engine applies an adjustment whether it's Pending, Approved or Cancelled.

---

## 10. Known gaps and risks found while mapping

These are behaviours worth confirming with the business owner. None of them has been changed.

1. **The report ignores approvals.** Cancelled OT still pays, and time corrections made through `updateTime` are lost in the report (see §9).
2. **The late rule can add hours.** Someone 2h late on `8-17` (in 10:00) gets in_time = 09:00, which credits an hour they weren't present. The rule replaces the in time with start + 1h regardless of how late the person was.
3. **Pending and cancelled schedule adjustments apply** (§5.1).
4. **Leaves never zero out a day** (§9).
5. **ND is decided per block start** (§5.5 note), so up to 59 ND minutes per shift can be missed or over-counted.
6. **RD base is 0 for most night schedules** (`18-6`, `19-7`, `20-5`, …).
7. **The seeded OT (Formula A) disagrees with the engine.** It puts ND in `rd_nd` on workdays, skips the late rule, and always leaves `rd = 0`. The OT Approval page shows these values until a record is recalculated.
8. **Recalculations don't save RD fields** on existing rows (`logOvertimeDb` with type `ord`), except through `runEditOt`.
9. **Report race conditions.** The file downloads fire after a fixed 1s delay and `export-csv` runs in parallel with generation, so the user can download the **previous** report. `reportdtr.xlsx` and `security.xlsx` are never regenerated. They are static files from 2025-08-27.
10. **Stale import at upload time.** The CSV Import page's "Upload" button calls `import.csv`, which loads the *previous* `payroll file.csv` into `csvimports` under the new batch id.
11. **`exportCsv` exports every batch**, not just the active one.
12. **`GET /overtime/{id}` approves the record** as a side effect.
13. **The employee import truncates the table**, which orphans existing foreign keys (§3.1).
14. **Sundays and PH holidays are not auto-seeded.** `calculateTotalNonWorkingDays()` is never called, and its holiday dates are hard-coded to 2025 dates.
15. **`finalizeCertificates` and `/finalize-attendance-certificates`** are legacy JSON-file flows that no page calls. Certificates now go through `CertificateOfAttendanceController::approve`.
16. **Header mismatch in `importCSV`.** It reads `SHNDExcess`, but the generated header is `SH-ND-Excess`, so the value is always null. It's also always `00:00` anyway.
17. **Night pairing drops shifts longer than 12h.** On a `19-7` schedule, arriving early and leaving on time loses the whole day. See the detailed doc §5.
18. **Reliever pairing turns consecutive day shifts into fake overnight shifts** (evening punch paired with the next morning's punch). See the detailed doc §6.
19. **Any night-code schedule adjustment ever filed** (any batch or status) switches the employee to night pairing for every day. See the detailed doc §3.

---

## 11. End-to-end checklist for one payroll period

1. *(if changed)* Upload the employee master CSV (Biometric Data page).
2. Make sure every Sunday and holiday in the period exists in `custom_dates` (Dashboard → holiday).
3. CSV Import → select the biometric file. This creates the batch, attendance records and the seeded OT.
4. Enter the title → Upload (saves the batch metadata).
5. Users and admins review:
   - OT Approval
   - Schedule Adjustments (file, then approve)
   - Certificates of Attendance (file, then approve; this adds attendance)
   - Leaves
6. Report Generation → Start → Generate Report. This produces the payroll CSV/XLSX and the `csvimports` rows and downloads the export.
7. Because of the race in §10.9, check that the downloaded file matches the period. If it doesn't, download it again from `/download/payroll-file`.

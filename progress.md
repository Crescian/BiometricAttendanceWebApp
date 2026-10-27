# Progress — 2026-10-01

Branch: `feature/audit-log-and-table-redesign` (commit `cc8b5fb`, based on `development`). **Committed locally, not pushed.**

---

## 1. Table redesign (all table pages)

One shared look, defined in `resources/views/components/approval-table-assets.blade.php`:
light header, compact rows (~34px, 12px text, 11px uppercase headers), initials avatars, small outlined row buttons,
search box + Export / Columns in the page header, "Rows per page" footer, +/- expand column on narrow screens.

Applied to: Overtime, Leaves, Certificates of Attendance, Schedule Adjustments, Attendance Records,
Employee Management, Organization Structure (tabs: Business Units / Companies / Departments),
User Management and the Audit Log.

Also on Organization Structure: removed a second jQuery copy that broke plugins, and Save no longer reloads the page.

## 2. Bulk approve

`resources/views/components/bulk-approve.blade.php` + `app/Http/Controllers/Concerns/BulkApprovesRecords.php`.
On the Pending tab of Leaves, Certificates and Schedule Adjustments (same as Overtime):

- tick rows → **Approve selected (N)**
- **Bulk approve** → all / by department / by employee / by date
- Certificates and schedule adjustments are approved one by one (each recalculates overtime); a failure skips that record only.

## 3. Dashboard

Fits on one screen: two rows that share the screen height, smaller fonts, charts fill their cards.
The same compact sizing was then applied to the table pages and headings of the form pages.

## 4. User Management

New columns: **User · Role · Department · Position · Status · Presence · Joined · Actions**.

- Department = the department(s) the user heads (the rule that limits what they see).
- Position: filled from the Ticketing directory on registration, editable.
- Status Active/Inactive: **inactive users can't sign in** and are signed out on their next page load.
- Presence: Online if active in the last 5 minutes (`TrackLastSeen` middleware).
- Edit and Activate/Deactivate actions; an admin can't deactivate or demote themselves.

## 5. Audit Log (replaces "User Log")

Built to the controls auditors check (ISO 27001 A.8.15, SOX ITGC, PCI DSS 10, PH Data Privacy Act).

| Control | How |
|---|---|
| Who / what / when / where / outcome | Every entry: actor snapshot, event, target record, before/after values, UTC time, IP, user agent, route, request id |
| Completeness | Model events on 13 models, explicit entries for bulk / import / report paths, sign-in (every failure reason) and sign-out, 401/403/419, file downloads, plus a safety net for any other change |
| Can't be edited or deleted | Database triggers reject UPDATE / DELETE / TRUNCATE (also on the old `attendance_logs`) |
| Tampering is detected | Hash chain; **Verify integrity** button and `php artisan audit:verify` (tested: an edited or deleted entry is caught) |
| No secrets stored | Passwords, tokens and keys are redacted |
| Never silently lost | If a write fails, the entry goes to `storage/logs/audit-fallback*.log` and the page shows a warning |
| Access | Admin only; opening the log, viewing an entry, exporting and verifying are logged too |
| Export | CSV with a final checksum line |
| Retention | Kept forever (no purge) |

The 180 old User Log rows were carried over. The old `/attendanceLogs/fetch` route (readable by any user) was removed.

## 6. Reports (DTR + payroll file)

Report **layout is unchanged** (HR: no added rows/columns). The LATE / UNDERTIME rows and columns that were added
for a while were removed again. What changed is the values:

- **Hours Worked = regular hours only:** 8.00 when on time (within the 15-minute grace) with no undertime;
  otherwise 8 − late − undertime. Early arrival and staying late don't add. 0 on rest days, holidays and leave days.
  12-hour shifts also count 8 regular hours.
- **Late:** full minutes after the schedule start, only when beyond the 15-minute grace (20 min late = 20).
- **Undertime:** every minute before the schedule end. Punches are read **to the minute** (seconds ignored).
- **OT, rest-day and holiday rows show only approved overtime**, with the figures as approved on the Overtime page.
  Example: approved 1:30 OT → Hours Worked 8, "OT (Ordinary day)" 1.5 (01:30), yellow TOTAL 9.5.
- ND on regular hours (night shifts) still shows without approval.
- Overtime page: Late / Late Hours / Late Minutes are filled in (they were always "Not Late").
  Recalculate after schedule changes: `php artisan attendance:recalculate-late`.

## 6b. Overtime page calculation (what gets approved)

One calculation (`ComputationService::otWindows`) used by import, time edits and approvals:

- **OT counts only after the schedule end**; arriving early is not OT.
- Late beyond grace → paid day starts 1 hour after the schedule start (or the actual arrival if later).
- Regular window 8 h + 1 h break (8 h for 15-23 / 23-7); OT is the time after it.
- **Night differential:** exact minutes inside 22:00–06:00 (was whole-hour blocks; the import never calculated it).
- **1-hour minimum:** a day's total OT (OT + ND-OT) under 1:00 = 0; 1:00 and up counts in full. Also for rest days/holidays.
- The 533 Pending records were recalculated (388 changed); Approved/Cancelled records untouched.
  Re-run after rule or schedule changes: `php artisan attendance:recalculate-ot`.

## 7. Fixes

- **Report generation "Permission denied"** on `public/python/payroll file.csv`: read-only report files are now replaced instead of failing.
- **Import showed an error after a successful upload** (`/csv-import` → 404 "File not found"): the import page no longer loads a stale payroll file; Report Generation does that after generating.
- `TrustProxies` no longer trusts every `X-Forwarded-For` header (clients could fake the recorded IP).

## 8. Database

| Migration | What |
|---|---|
| `2026_10_01_000001` | `users.position`, `users.active`, `users.last_seen_at` |
| `2026_10_01_000002` | `audit_logs` table, append-only triggers, old User Log carried over |
| `2026_10_01_000003` | least-privilege role `attendance_app` (INSERT/SELECT-only on the audit trail) |
| `2026_10_01_000004` | Late filled in on existing overtime records |

Imported data (imports, attendance, overtime, payroll) was wiped three times on request; employees, holidays and users were kept.
Backups (outside the repo): `~/projects/BiometricAttendanceWebApp-backups/`.

---

## Open items

| # | Item | Who |
|---|---|---|
| 1 | **Switch the app to `attendance_app`**: set `DB_USERNAME` / `DB_PASSWORD` in `.env` to the `DB_APP_*` values (tested, not switched yet) | Decision pending |
| 2 | **`.env` is tracked in git**, including past commits with the `postgres` password. Stop tracking it and change the password | Recommended |
| 3 | Stop tracking generated reports (`public/python/*.csv`, `*.xlsx`), which contain pay data | Recommended |
| 4 | Push the branch: `git push -u origin feature/audit-log-and-table-redesign` | When ready |
| 5 | Fix schedules for **MADARANG, ANGELICA MAY MEROY** and **MOLINO, MARTIN JR. MARCOS** (set to 7-16, work ~13:00–22:00), then run `attendance:recalculate-late` | HR |
| 6 | **Employee Data Import empties all attendance data** (`TRUNCATE employee_management … CASCADE` cascades to 7 tables) | Needs a fix |
| 7 | Restore (↺) button calls `handleRedo()`, which doesn't exist | Needs a fix |
| 8 | `/biometricData` route points to a missing view; table-data URLs return 500 when opened directly | Cleanup |
| 9 | `TICKETING_ORG_API_TOKEN` missing from `.env`, so User Management → Add "Find Person" can't search | Config |
| 10 | Real client IPs aren't visible: Docker Desktop NAT makes every request come from a `172.x.0.1` gateway | Infrastructure |
| 11 | PHP upload limit is 2 MB (`upload_max_filesize`); a full month's biometric file may exceed it | Config |
| 12 | Schedule adjustments of any status (even pending/cancelled) affect OT, grace and late | Policy decision |
| 13 | DONES, ALEXANDER MIANO: 2 OT records approved before the 1-hour rule (0:40, 0:28); under the rule both would be 0 | Decision pending |
| 14 | HR to confirm the new Hours Worked / approved-only OT values in the reports (layout unchanged) | HR |

## Process controls the company must own (for an audit)

- An audit-logging policy and a regular review of the Audit Log (e.g. weekly failed sign-ins and denied access)
- Server clocks synced with NTP
- Backups of the database, including `audit_logs`, kept per the retention policy
- Restricted holders of the `postgres` password (separate from app admins)
- A scheduled `php artisan audit:verify` with alerting on failure

<?php

namespace App\Http\Controllers;

use App\Services\AuditLogger;
use App\Models\BiometricHistoryList;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class BiometricHistoryListController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function toggleStatus(Request $request)
    {
        $id = $request->id;

        // Find the record by ID
        $record = BiometricHistoryList::findOrFail($id);

        // Determine the new status (toggle)
        $newStatus = $record->status === 'load' ? 'unload' : 'load';

        // If setting this one to 'load', unload all others first
        if ($newStatus === 'load') {
            $unloaded = BiometricHistoryList::where('status', 'load')->where('id', '<>', $record->id)->pluck('id')->all();
            BiometricHistoryList::where('status', 'load')->update(['status' => 'unload']);
            if ($unloaded) {
                AuditLogger::record('biometric_import.unloaded', [
                    'category' => 'import', 'action' => 'update', 'target' => $record,
                    'description' => 'Unloaded import(s) #'.implode(', #', $unloaded).' to load #'.$record->id,
                    'old' => ['status' => 'load'], 'new' => ['status' => 'unload'],
                    'metadata' => ['unloaded_ids' => $unloaded],
                ]);
            }
        }

        // Update the selected record
        $record->update(['status' => $newStatus]);

        return response()->json([
            'message' => 'Status toggled successfully.',
            'data' => $record
        ]);
    }

    /**
     * Per-day tables tagged with an import, and their date column. Attendance is stored once per
     * employee per day across imports and payroll is built by date range, so a day that falls in
     * another import's payroll period is handed to that import when this one is deleted.
     */
    private const DAY_TABLES = [
        'attendance_records' => 'record_date',
        'overtimes' => 'record_date',
        'security_attendance' => 'record_date',
        'dtr_report' => 'record_date',
        'leaves' => 'record_date',
        'certificate_attendance' => 'date',
        'schedule_adjustments' => 'record_date',
    ];

    /** Computed from the attendance: deleted for the days no other import covers. */
    private const DERIVED_TABLES = ['overtimes', 'security_attendance', 'dtr_report'];

    /**
     * Approval records: never deleted for their import tag (the FK sets it to NULL). Only those
     * attached to a deleted attendance record go, through attendance_records_id ON DELETE CASCADE.
     */
    private const WORKFLOW_TABLES = ['leaves', 'certificate_attendance', 'schedule_adjustments'];

    /** Tables whose rows can belong to an attendance record (attendance_records_id); they follow it. */
    private const ATTACHED_TABLES = ['overtimes', 'leaves', 'certificate_attendance', 'schedule_adjustments'];

    public function index()
    {
        $counts = fn (string $table, ?string $status = null) => DB::table($table)
            ->whereNotNull('biometric_imports_id')
            ->when($status, fn ($q) => $q->where('status', $status))
            ->groupBy('biometric_imports_id')
            ->selectRaw('biometric_imports_id, COUNT(*) AS total')
            ->pluck('total', 'biometric_imports_id');

        $attendance = $counts('attendance_records');
        $overtime = $counts('overtimes');
        $approvedOt = $counts('overtimes', 'Approved');

        $data = BiometricHistoryList::orderBy('created_at', 'desc')->get()->map(function ($import) use ($attendance, $overtime, $approvedOt) {
            $import->attendance_count = (int) ($attendance[$import->id] ?? 0);
            $import->overtime_count = (int) ($overtime[$import->id] ?? 0);
            $import->approved_ot_count = (int) ($approvedOt[$import->id] ?? 0);

            return $import;
        });

        return response()->json($data);
    }

    /** Admin: change an import's title or payroll period. The attendance data itself is not editable. */
    public function update(Request $request, $id)
    {
        $import = BiometricHistoryList::findOrFail($id);
        if ($locked = $this->lockedResponse($import)) {
            return $locked;
        }

        // Uniqueness only applies to a new title, so an import that shares an old default
        // title (e.g. "DailyAttendance.csv") can still have its period changed.
        $titleRules = ['required', 'string', 'max:100'];
        if (trim((string) $request->input('title')) !== trim((string) $import->title)) {
            $titleRules[] = Rule::unique('biometric_imports', 'title')->ignore($import->id);
        }

        $validated = $request->validate([
            'title' => $titleRules,
            'period_start' => ['nullable', 'date', 'required_with:period_end'],
            'period_end' => ['nullable', 'date', 'required_with:period_start', 'after_or_equal:period_start'],
        ], [
            'title.unique' => 'Another import already has this title.',
            'period_end.after_or_equal' => 'Payroll "to" must be on or after "from".',
        ]);

        $import->update($validated); // audited (before/after) by the Auditable trait

        return response()->json(['message' => 'Import updated.', 'data' => $import]);
    }

    /** Admin: what deleting this import would remove. */
    public function deletePreview($id)
    {
        $import = BiometricHistoryList::findOrFail($id);
        if ($locked = $this->lockedResponse($import)) {
            return $locked;
        }

        $plan = $this->deletionPlan($import->id);
        if ($blocked = $this->lockedTargetResponse($plan)) {
            return $blocked;
        }

        return response()->json([
            'import' => $import,
            'moved' => $plan['moved'],
            'deleted' => $plan['deleted'],
            'kept' => $plan['kept'],
            'approved_overtime' => $plan['approved_overtime'],
            'is_loaded' => $import->status === 'load',
            'next_loaded' => $import->status === 'load' ? $this->nextToLoad($import->id) : null,
        ]);
    }

    /**
     * Admin: delete an import. The title must be typed back as confirmation. Days inside another
     * import's payroll period are handed to that import; the rest of its attendance and computed
     * data is deleted; approval records not attached to a deleted day are kept, untagged.
     * If it was the loaded import, the newest remaining one is loaded.
     */
    public function destroy(Request $request, $id)
    {
        $import = BiometricHistoryList::findOrFail($id);
        $request->validate(['confirm_title' => ['required', 'string']]);
        if (trim($request->input('confirm_title')) !== trim((string) $import->title)) {
            return response()->json(['message' => 'The title you typed does not match this import.'], 422);
        }

        $result = DB::transaction(function () use ($import) {
            $id = $import->id;

            // Hold every import row until commit, so no import can be locked or have its period
            // changed between working out where the days go and moving them.
            BiometricHistoryList::lockForUpdate()->pluck('id');
            $import->refresh();
            if ($locked = $this->lockedResponse($import)) {
                return $locked;
            }
            $plan = $this->deletionPlan($id);
            if ($blocked = $this->lockedTargetResponse($plan)) {
                return $blocked;
            }

            $snapshot = $import->getAttributes();
            $next = $import->status === 'load' ? $this->nextToLoad($id) : null;

            // 1. Hand covered days over first, so the deletes below cannot cascade into them.
            $moved = [];
            foreach (array_keys(self::DAY_TABLES) as $table) {
                // The target is worked out once per row, then applied.
                $sql = "UPDATE {$table} AS u SET biometric_imports_id = t.target
                        FROM (SELECT x.id, {$this->targetImportSql($table)} AS target
                              FROM {$table} x WHERE x.biometric_imports_id = ?) t
                        WHERE u.id = t.id AND t.target IS NOT NULL";
                $moved[$table] = DB::update($sql, $this->bindId($sql, $id));
            }

            // 2. What is still tagged with the import is on days no other import needs.
            foreach (self::DERIVED_TABLES as $table) {
                DB::table($table)->where('biometric_imports_id', $id)->delete();
            }
            DB::table('attendance_records')->where('biometric_imports_id', $id)->delete();

            // 3. Remaining approval records and payroll rows are untagged by their SET NULL keys.
            // A query-builder delete, so the Auditable model event doesn't log it a second time.
            DB::table('biometric_imports')->where('id', $id)->delete();

            if ($next) {
                BiometricHistoryList::find($next['id'])?->update(['status' => 'load']);
            }

            $moved = array_filter($moved);
            $total = array_sum($plan['deleted']);
            $movedTotal = array_sum($moved);
            $approvedOt = $plan['approved_overtime'];
            // Inside the transaction: if the audit entry can't be written, nothing is deleted.
            AuditLogger::record('biometric_import.deleted_with_data', [
                'category' => 'import',
                'action' => 'delete',
                'target' => ['BiometricHistoryList', $id],
                'description' => "Deleted import #{$id} \"{$snapshot['title']}\" with {$total} related records"
                    .($approvedOt ? " (including {$approvedOt} approved overtime)" : '')
                    .($movedTotal ? "; {$movedTotal} records on days in other imports' periods were moved to them" : '')
                    .($next ? "; import #{$next['id']} is now loaded" : ''),
                'old' => $snapshot,
                'metadata' => [
                    'deleted' => $plan['deleted'],
                    'moved' => $moved,
                    'moved_to' => $plan['moved'],
                    'kept_untagged' => $plan['kept'],
                    'approved_overtime_deleted' => $approvedOt,
                    'was_loaded' => $import->status === 'load',
                    'now_loaded' => $next['id'] ?? null,
                ],
            ]);

            return [
                'message' => 'Import deleted.',
                'deleted' => $plan['deleted'],
                'total' => $total,
                'moved_total' => $movedTotal,
                'now_loaded' => $next,
            ];
        });

        return $result instanceof \Illuminate\Http\JsonResponse ? $result : response()->json($result);
    }

    /** Locked (paid) imports are read-only, as in AttendanceRecordController::activeBatch(). */
    private function lockedResponse(BiometricHistoryList $import)
    {
        return !empty($import->is_locked)
            ? response()->json(['message' => 'This import is locked and cannot be changed.'], 423)
            : null;
    }

    /**
     * Days are never handed to a locked import, so a locked batch is never changed. A locked import
     * is only picked when no unlocked one covers the day (or it owns the attached attendance record),
     * and deleting the day instead would take it out of that locked payroll, so the delete is refused.
     */
    private function lockedTargetResponse(array $plan)
    {
        $quote = fn ($titles) => implode(', ', array_map(fn ($t) => "\"{$t}\"", $titles));

        $locked = array_filter($plan['moved'], fn ($target) => $target['is_locked']);
        if ($locked) {
            return response()->json([
                'message' => 'Some days of this import are in the payroll period of locked import '
                    .$quote(array_column($locked, 'title')).'. Unlock it or change its period first.',
            ], 423);
        }

        // Deleting a day also removes the overtime, leaves, certificates and adjustments attached to
        // it, whichever import they belong to; a locked import's rows must not go that way either.
        if ($plan['locked_cascade']) {
            return response()->json([
                'message' => 'Deleting this import would remove records that belong to locked import '
                    .$quote($plan['locked_cascade']).'. Unlock it first.',
            ], 423);
        }

        return null;
    }

    /**
     * SQL for the import whose payroll period covers the date {$dateExpr}, other than the one being
     * deleted (its id is the `?`). Unlocked imports first, then the loaded one, then the newest.
     */
    private function coveringImportSql(string $dateExpr, bool $unlockedOnly = false): string
    {
        $unlocked = $unlockedOnly ? 'AND NOT COALESCE(bi.is_locked, false)' : '';

        return "(SELECT bi.id FROM biometric_imports bi
                 WHERE bi.id <> ? AND ({$dateExpr})::date BETWEEN bi.period_start AND bi.period_end {$unlocked}
                 ORDER BY COALESCE(bi.is_locked, false), (bi.status = 'load') DESC, bi.id DESC LIMIT 1)";
    }

    /**
     * SQL for the import a row of {$table} (alias x) goes to, or NULL when it is deleted. A row
     * attached to an attendance record follows that record, whatever its own date: the record stays
     * with its import, or (if it is the deleted import's) goes to the import covering its day.
     */
    private function targetImportSql(string $table): string
    {
        // Approval records (leaves, certificates, adjustments) are never handed to a locked import:
        // where only a locked one would take them they are kept untagged instead, which changes no
        // payroll figure (they apply by employee and day). So they never block a delete.
        $workflow = in_array($table, self::WORKFLOW_TABLES, true);
        $ownDay = $this->coveringImportSql('x.'.self::DAY_TABLES[$table], $workflow);
        if (!in_array($table, self::ATTACHED_TABLES, true)) {
            return $ownDay;
        }
        $recordsImport = $workflow
            ? "(CASE WHEN (SELECT COALESCE(bi.is_locked, false) FROM biometric_imports bi WHERE bi.id = ar.biometric_imports_id)
                     THEN NULL ELSE ar.biometric_imports_id END)"
            : 'ar.biometric_imports_id';

        return "(CASE WHEN x.attendance_records_id IS NULL THEN {$ownDay}
                 ELSE (SELECT CASE WHEN ar.biometric_imports_id = ? THEN {$this->coveringImportSql('ar.record_date', $workflow)}
                                   WHEN ar.biometric_imports_id IS NOT NULL THEN {$recordsImport}
                                   ELSE {$ownDay} END
                       FROM attendance_records ar WHERE ar.id = x.attendance_records_id)
                 END)";
    }

    /** Every `?` in these queries is the deleted import's id. */
    private function bindId(string $sql, int $id): array
    {
        return array_fill(0, substr_count($sql, '?'), $id);
    }

    /**
     * What deleting an import does, by table: rows moved to each covering import, rows deleted
     * (including those that cascade from deleted attendance records) and rows kept but untagged.
     */
    private function deletionPlan(int $id): array
    {
        $movedByImport = [];
        $uncovered = [];
        $approvedOt = 0;
        foreach (array_keys(self::DAY_TABLES) as $table) {
            $approved = $table === 'overtimes' ? "COUNT(*) FILTER (WHERE x.status = 'Approved')" : '0';
            $sql = "SELECT {$this->targetImportSql($table)} AS target, COUNT(*) AS n, {$approved} AS approved
                    FROM {$table} x WHERE x.biometric_imports_id = ? GROUP BY target";
            $uncovered[$table] = 0;
            foreach (DB::select($sql, $this->bindId($sql, $id)) as $row) {
                if ($row->target === null) {
                    $uncovered[$table] = (int) $row->n;
                    $approvedOt += (int) $row->approved;
                } else {
                    $movedByImport[$row->target] = ($movedByImport[$row->target] ?? 0) + (int) $row->n;
                }
            }
        }

        // The deleted import's attendance records on uncovered days; rows attached to them cascade,
        // whichever import they are tagged with.
        $doomed = "SELECT ar.id FROM attendance_records ar
                   WHERE ar.biometric_imports_id = ? AND {$this->coveringImportSql('ar.record_date')} IS NULL";

        $deleted = [];
        foreach (array_merge(['attendance_records'], self::DERIVED_TABLES) as $table) {
            $deleted[$table] = $uncovered[$table];
        }
        $sql = "SELECT COUNT(*) AS n, COUNT(*) FILTER (WHERE x.status = 'Approved') AS approved
                FROM overtimes x WHERE x.biometric_imports_id IS DISTINCT FROM ? AND x.attendance_records_id IN ({$doomed})";
        $otherOt = DB::selectOne($sql, $this->bindId($sql, $id));
        $deleted['overtimes'] += (int) $otherOt->n;
        $approvedOt += (int) $otherOt->approved;

        $kept = [];
        foreach (self::WORKFLOW_TABLES as $table) {
            $sql = "SELECT COUNT(*) AS n, COUNT(*) FILTER (WHERE x.biometric_imports_id = ?) AS own
                    FROM {$table} x WHERE x.attendance_records_id IN ({$doomed})";
            $cascaded = DB::selectOne($sql, $this->bindId($sql, $id));
            $deleted[$table] = (int) $cascaded->n;
            $kept[$table] = $uncovered[$table] - (int) $cascaded->own;
        }
        $kept['csvimports'] = DB::table('csvimports')->where('biometric_imports_id', $id)->count();

        $lockedCascade = [];
        foreach (self::ATTACHED_TABLES as $table) {
            $sql = "SELECT DISTINCT bi.title FROM {$table} x
                    JOIN biometric_imports bi ON bi.id = x.biometric_imports_id
                    WHERE bi.id <> ? AND COALESCE(bi.is_locked, false) AND x.attendance_records_id IN ({$doomed})";
            foreach (DB::select($sql, $this->bindId($sql, $id)) as $row) {
                $lockedCascade[$row->title] = true;
            }
        }

        $targets = BiometricHistoryList::whereIn('id', array_keys($movedByImport))->orderBy('id')->get();
        $moved = $targets->map(fn ($t) => [
            'id' => $t->id,
            'title' => $t->title,
            'is_locked' => !empty($t->is_locked),
            'total' => $movedByImport[$t->id],
        ])->values()->all();

        return [
            'moved' => $moved,
            'deleted' => array_filter($deleted),
            'kept' => array_filter($kept),
            'approved_overtime' => $approvedOt,
            'locked_cascade' => array_keys($lockedCascade),
        ];
    }

    private function nextToLoad(int $exceptId): ?array
    {
        $next = BiometricHistoryList::where('id', '<>', $exceptId)->orderByDesc('created_at')->orderByDesc('id')->first();

        return $next ? ['id' => $next->id, 'title' => $next->title] : null;
    }
    
    public function getLoadedRecord()
    {
        $record = BiometricHistoryList::where('status', 'load')->first();

        if ($record) {
            return response()->json([
                'id' => $record->id,
                'data' => $record
            ]);
        }

        return response()->json([
            'message' => 'No record with status "load" found.'
        ], 404);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $request->validate([
            'period_start' => 'nullable|date',
            'period_end'   => 'nullable|date|after_or_equal:period_start',
        ]);

        // Only overwrite the period when the admin supplied one; otherwise keep
        // the default set from the punch dates during upload.
        $period = array_filter($request->only('period_start', 'period_end'));

        // The upload (AttendanceProcessor::processFile()) creates the import row and its attendance;
        // "Import Now" only fills in the details the user entered. Without that id the upload did
        // not finish (e.g. the file was rejected as too large), and creating a row here would leave
        // an empty import loaded in place of the real one.
        if (!$request->filled('id')) {
            return response()->json([
                'message' => 'No uploaded file for this import. Upload the biometric file first.',
            ], 422);
        }

        $record = BiometricHistoryList::findOrFail($request->id);
        $record->update([
            'title' => $request->title,
            'imported_by' => $request->imported_by,
            'total_rows' => $request->total_rows,
        ] + $period);

        return response()->json([
            'message' => 'Biometric import record updated successfully.',
            'id' => $record->id,
            'data' => $record
        ], 200);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\BiometricHistoryList  $biometricHistoryList
     * @return \Illuminate\Http\Response
     */
    public function show(BiometricHistoryList $biometricHistoryList)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\BiometricHistoryList  $biometricHistoryList
     * @return \Illuminate\Http\Response
     */
    public function edit(BiometricHistoryList $biometricHistoryList)
    {
        //
    }
}

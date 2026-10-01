<?php

namespace App\Http\Controllers;

use App\Services\AuditLogger;
use App\Models\Department;
use App\Models\Overtime;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Yajra\DataTables\Facades\DataTables;
use App\Models\BiometricHistoryList;
use App\Services\ComputationService;
use Illuminate\Support\Facades\DB;

class OvertimeController extends Controller
{
    protected $biometricHistoryList;

    public function __construct(BiometricHistoryList $biometricHistoryList)
    {
        $this->biometricHistoryList = $biometricHistoryList;
    }
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */

    // public function index(Request $request)
    // {
    //     if ($request->ajax()) {
    //         // Fetch all columns and order by unique_id in ascending order
    //         $data = Overtime::select('*')
    //             ->where('status', 'Pending')
    //             ->orderBy('unique_id', 'asc');

    //         return DataTables::of($data)
    //             ->make(true);
    //     }

    //     return view('overtime.fetch');
    // }
    public function getOvertimeStatusSummary()
    {
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

        // Group by status and count, filtered by biometric_imports_id
        $statusSummary = Overtime::where('biometric_imports_id', $biometricImportId)
            ->select('status')
            ->selectRaw('COUNT(*) as total')
            ->groupBy('status')
            ->get();

        // Prepare chart labels and data
        $labels = $statusSummary->pluck('status');
        $data = $statusSummary->pluck('total');

        return response()->json([
            'labels' => $labels,
            'data' => $data
        ]);
    }

    public function index(Request $request)
    {
        if ($request->ajax()) {
            // Get request parameters
            $status      = $request->get('status', 'Pending');
            $userRole    = $request->get('userRole', 'user'); // default 'user'
            $department  = $request->get('department');
            $biometricId = $this->biometricHistoryList->getLoadedRecordId();

            // Build query
            $data = Overtime::query()
                // Filter by status if not 'all'
                ->when($status !== 'all', fn($q) => $q->where('status', $status))
                // Always filter by biometric import ID if available
                ->when($biometricId, fn($q) => $q->where('biometric_imports_id', $biometricId));

            // Filter by department only if userRole is 'user'
            if ($userRole === 'user' && $department) {
                $data->where('department', $department);
            }

            // Order by first name
            $data->orderBy('first_name', 'asc');

            // Return results for DataTables
            return DataTables::of($data)->make(true);
        }
        return view('overtime.fetch');
    }

    /**
     * Restrict a query to the departments the current user heads (admins see everything).
     */
    protected function restrictToOwnDepartments($query)
    {
        if ((Auth::user()->role ?? '') !== 'admin') {
            $query->whereIn('department', Department::where('department_head', Auth::id())->pluck('department_name'));
        }

        return $query;
    }

    /**
     * Pending overtime of the loaded import that the current user may approve —
     * the same rows the Overtime page's Pending tab lists.
     */
    protected function pendingScope()
    {
        return $this->restrictToOwnDepartments(
            Overtime::where('status', 'Pending')
                ->where('biometric_imports_id', $this->biometricHistoryList->getLoadedRecordId())
        );
    }

    /**
     * Approve several overtime records at once (Overtime page, "Approve selected").
     * Only rows that are still Pending change; a department head can only approve
     * overtime of the departments they head.
     */
    public function bulkApprove(Request $request)
    {
        $validated = $request->validate([
            'ids'   => ['required', 'array', 'min:1', 'max:500'],
            'ids.*' => ['integer'],
        ]);
        $ids = array_values(array_unique($validated['ids']));

        $query = $this->restrictToOwnDepartments(
            Overtime::whereIn('id', $ids)->where('status', 'Pending')
        );

        $approvedIds = (clone $query)->pluck('id');
        $approved = DB::transaction(fn () => $query->update(['status' => 'Approved', 'updated_at' => now()]));
        $skipped  = count($ids) - $approved;

        AuditLogger::record('overtime.bulk_approved', [
            'category' => 'approval',
            'action' => 'approve',
            'outcome' => $approved > 0 ? 'success' : 'failure',
            'description' => "Bulk approved {$approved} overtime ".($approved === 1 ? 'record' : 'records')
                ." (selected {$approvedIds->count()} of ".count($ids).' requested)',
            'old' => ['status' => 'Pending'],
            'new' => ['status' => 'Approved'],
            'metadata' => ['mode' => 'selected', 'approved_ids' => $approvedIds->all(), 'requested_ids' => $ids, 'skipped' => $skipped],
        ]);

        return response()->json([
            'success'  => true,
            'approved' => $approved,
            'skipped'  => $skipped,
            'message'  => "{$approved} overtime " . ($approved === 1 ? 'record' : 'records') . ' approved.'
                . ($skipped > 0 ? " {$skipped} skipped (no longer pending or outside your departments)." : ''),
        ]);
    }

    /**
     * Choices for "Bulk approve": pending counts per department, per employee and per date.
     */
    public function bulkOptions()
    {
        $departments = $this->pendingScope()
            ->select('department as value', DB::raw('COUNT(*) as count'))
            ->groupBy('department')
            ->orderBy('department')
            ->get();

        $employees = $this->pendingScope()
            ->select('employee_name as value', 'department', DB::raw('COUNT(*) as count'))
            ->groupBy('employee_name', 'department')
            ->orderBy('employee_name')
            ->get();

        $dates = $this->pendingScope()
            ->select(DB::raw("TO_CHAR(record_date, 'YYYY-MM-DD') as value"), DB::raw('COUNT(*) as count'))
            ->groupBy(DB::raw("TO_CHAR(record_date, 'YYYY-MM-DD')"))
            ->orderBy('value')
            ->get();

        return response()->json([
            'success'     => true,
            'total'       => $this->pendingScope()->count(),
            'departments' => $departments,
            'employees'   => $employees,
            'dates'       => $dates,
        ]);
    }

    /**
     * Approve every pending overtime of one department, one employee or one date,
     * or all of it (within the loaded import and the user's own departments).
     */
    public function bulkApproveBy(Request $request)
    {
        $validated = $request->validate([
            'by'    => ['required', 'in:all,department,employee,date'],
            'value' => ['required_unless:by,all', 'nullable', 'string', 'max:255'],
        ]);
        if ($validated['by'] === 'date') {
            $request->validate(['value' => ['date_format:Y-m-d']]);
        }

        $query = $this->pendingScope();
        match ($validated['by']) {
            'all'        => null,
            'department' => $query->where('department', $validated['value']),
            'employee'   => $query->where('employee_name', $validated['value']),
            'date'       => $query->whereDate('record_date', $validated['value']),
        };

        $approvedIds = (clone $query)->pluck('id');
        $approved = DB::transaction(fn () => $query->update(['status' => 'Approved', 'updated_at' => now()]));

        AuditLogger::record('overtime.bulk_approved', [
            'category' => 'approval',
            'action' => 'approve',
            'outcome' => $approved > 0 ? 'success' : 'failure',
            'description' => "Bulk approved {$approved} overtime ".($approved === 1 ? 'record' : 'records')
                .' by '.$validated['by'].($validated['by'] !== 'all' ? ' "'.$validated['value'].'"' : ''),
            'old' => ['status' => 'Pending'],
            'new' => ['status' => 'Approved'],
            'metadata' => ['mode' => $validated['by'], 'value' => $validated['value'] ?? null, 'approved_ids' => $approvedIds->all()],
        ]);

        return response()->json([
            'success'  => true,
            'approved' => $approved,
            'message'  => $approved > 0
                ? "{$approved} overtime " . ($approved === 1 ? 'record' : 'records') . ' approved.'
                : 'There was no pending overtime to approve for this choice.',
        ]);
    }

    public function approve($id)
    {
        try {
            // Find the overtime record
            $overtime = Overtime::findOrFail($id);

            // Update the status
            $overtime->status = 'Approved';
            $overtime->save();

            return response()->json([
                'success' => true,
                'message' => 'Overtime has been approved successfully.',
                'data' => $overtime
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to approve overtime.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function cancel($id)
    {
        try {
            // Find the overtime record
            $overtime = Overtime::findOrFail($id);

            // Update the status
            $overtime->status = 'Cancelled';
            $overtime->save();

            return response()->json([
                'success' => true,
                'message' => 'Overtime has been cancelled successfully.',
                'data' => $overtime
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to cancel overtime.',
                'error' => $e->getMessage()
            ], 500);
        }
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
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Overtime  $overtime
     * @return \Illuminate\Http\Response
     */
    public function show(Overtime $overtime)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Overtime  $overtime
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        // Fetch the overtime by ID
        $overtime = Overtime::findOrFail($id);

        // Update the status
        $overtime->status = 'Approved';
        $overtime->save();

        // Return the overtime details as JSON
        return response()->json($overtime);
    }

    public function updateTime(Request $request, $id)
    {
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();
        $overtime = Overtime::find($id);

        if (!$overtime) {
            return response()->json(['success' => false, 'message' => 'Overtime record not found'], 404);
        }

        // Validate request inputs
        // $request->validate([
        //     'earliest_time' => 'required|date_format:H:i',
        //     'latest_time' => 'required|date_format:H:i',
        // ]);

        $otFields = ['ord_ot', 'ord_nd', 'ord_nd_ot', 'rd', 'rd_ot', 'rd_nd', 'rd_nd_ot', 'late', 'late_hours', 'late_minutes'];
        $otBefore = collect($overtime->getAttributes())->only($otFields)->all();

        // If original times are empty, store them first before updating
        if (empty($overtime->original_earliest_time)) {
            $overtime->original_earliest_time = $overtime->earliest_time ?? $request->earliest_time;
        }

        if (empty($overtime->original_latest_time)) {
            $overtime->original_latest_time = $overtime->latest_time ?? $request->latest_time;
        }

        // Update with new values
        $overtime->earliest_time = $request->earliest_time;
        $overtime->latest_time   = $request->latest_time;

        $overtime->save();

        // Recalculate overtime using ComputationService (replaces edit_ot.py)
        $computation    = app(ComputationService::class);
        $nonWorkingDays = DB::table('custom_dates')->pluck('record_date')->map(fn($d) => substr($d, 0, 10))->toArray();
        $employeeData   = DB::table('employee_management')->get()->toArray();

        $rowData = [
            'employee_name'          => $overtime->employee_name,
            'employee_management_id' => null,
            'record_date'            => substr($overtime->record_date, 0, 10),
            'earliest_time'          => $overtime->earliest_time,
            'latest_time'            => $overtime->latest_time,
            'department'             => $overtime->department ?? '',
            'leaves'                 => false,
        ];

        [$ordOt, $ordNd, $ordNdOt] = $computation->autocalculateOrd(
            $rowData, $nonWorkingDays, $employeeData, null, null, $biometricImportId
        );

        $rdResult = $computation->autocalculateRdAndOvertime($rowData, collect($employeeData));

        $computation->logOvertimeDb(
            $rowData,
            $ordOt, $rdResult['rd_ot'], $ordNd, $ordNdOt,
            $rdResult['rd'], $rdResult['rd_nd'], $rdResult['rd_nd_ot'],
            0, false, 0, 0, null,
            'ord', $overtime->schedule ?? null,
            $overtime->status ?? 'Pending',
            $biometricImportId,
            $overtime->attendance_records_id ?? null,
            $overtime->schedule_shift ?? null,
            'ord'
        );

        // The recalculation writes through the query builder, so record its result explicitly
        $otAfter = collect((array) DB::table('overtimes')->where('id', $overtime->id)->first())->only($otFields)->all();
        $changedAfter = array_diff_assoc(array_map('strval', $otAfter), array_map('strval', $otBefore));
        AuditLogger::record('overtime.recalculated', [
            'category' => 'data',
            'action' => 'update',
            'target' => $overtime,
            'description' => "Recalculated overtime #{$overtime->id} ({$overtime->employee_name}, ".substr($overtime->record_date, 0, 10)
                .") after time edit to {$overtime->earliest_time}–{$overtime->latest_time}",
            'old' => array_intersect_key($otBefore, $changedAfter) ?: null,
            'new' => $changedAfter ?: null,
            'metadata' => ['earliest_time' => $overtime->earliest_time, 'latest_time' => $overtime->latest_time],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Time updated successfully',
            'data' => [
                'id'                     => $overtime->id,
                'original_earliest_time' => $overtime->original_earliest_time,
                'original_latest_time'   => $overtime->original_latest_time,
                'earliest_time'          => $overtime->earliest_time,
                'latest_time'            => $overtime->latest_time,
            ],
        ]);
    }

    


    public function getOvertimeCounts(Request $request)
    {
        $userRole = $request->get('userRole', 'user'); // get user role from AJAX
        $department = $request->get('department', null); // get department name
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();


        // Base query
        $query = Overtime::query();

        // 👤 If user, filter by department
        if ($userRole === 'user' && $department) {
            $query->where('department', $department);
        }

        if (!empty($biometricImportId)) {
            $query->where('biometric_imports_id', $biometricImportId);
        }
        // 🧮 Count by status
        $counts = [
            'pending'   => (clone $query)->where('status', 'Pending')->count(),
            'approved'  => (clone $query)->where('status', 'Approved')->count(),
            'cancelled' => (clone $query)->where('status', 'Cancelled')->count(),
        ];

        return response()->json($counts);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Overtime  $overtime
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Overtime $overtime)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Overtime  $overtime
     * @return \Illuminate\Http\Response
     */
    public function destroy(Overtime $overtime)
    {
        //
    }
}

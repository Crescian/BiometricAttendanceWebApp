<?php

namespace App\Http\Controllers;

use App\Models\Overtime;
use Illuminate\Http\Request;
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

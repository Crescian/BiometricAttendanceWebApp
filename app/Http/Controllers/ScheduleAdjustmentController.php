<?php

namespace App\Http\Controllers;

use App\Models\ScheduleAdjustment;
use Illuminate\Http\Request;
use Yajra\DataTables\Facades\DataTables;
use Carbon\Carbon;
use App\Models\BiometricHistoryList;
use App\Models\AttendanceRecord;
use App\Models\EmployeeManagement;
use App\Services\ComputationService;
use Illuminate\Support\Facades\DB;

class ScheduleAdjustmentController extends Controller
{
    protected $biometricHistoryList;

    public function __construct(BiometricHistoryList $biometricHistoryList)
    {
        $this->biometricHistoryList = $biometricHistoryList;
    }

    public function getScheduleAdjustmentSummary()
    {
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

        // Group by approval_status and count each group (filtered by biometric_imports_id)
        $statusSummary = ScheduleAdjustment::where('biometric_imports_id', $biometricImportId)
            ->select('approval_status')
            ->selectRaw('COUNT(*) as total')
            ->groupBy('approval_status')
            ->get();

        // Prepare chart labels and data
        $labels = $statusSummary->pluck('approval_status');
        $data = $statusSummary->pluck('total');

        return response()->json([
            'labels' => $labels,
            'data' => $data
        ]);
    }

    // public function approve($id)
    // {
    //     try {
    //         $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();
    //         $ScheduleAdjustment = ScheduleAdjustment::findOrFail($id);

    //         $userId = $ScheduleAdjustment->users_id;  // <-- adjust name if needed
    //         $date = $ScheduleAdjustment->record_date; // <-- include date filter

    //         // 🔎 Check if the user already has a ScheduleAdjustment for this date
    //         $existing = ScheduleAdjustment::where('users_id', $userId)
    //             ->where('record_date', $date)
    //             ->first();

    //         if ($existing) {
    //             // Existing record found for same user & date
    //             if (in_array($existing->approval_status, ['Pending', 'Approved'])) {
    //                 return response()->json([
    //                     'success' => false,
    //                     'message' => "A Schedule Adjustment already exists for this user on {$date} with status: {$existing->approval_status}",
    //                 ], 400);
    //             }

    //             // If Cancelled → allow overwrite
    //         }

    //         // 🟢 Approve
    //         $ScheduleAdjustment->approval_status = 'Approved';
    //         $ScheduleAdjustment->save();

    //         // Python Script Execution
    //         $scriptPath = escapeshellarg(storage_path('app/public/python/edit_ot.py'));
    //         $biometricId = escapeshellarg($biometricImportId);
    //         $attendanceRecordsId = escapeshellarg($ScheduleAdjustment->attendance_records_id);

    //         $command = "python {$scriptPath} {$biometricId} {$attendanceRecordsId} schedule_adjustment";

    //         exec($command . ' 2>&1', $output, $returnVar);

    //         if ($returnVar !== 0) {
    //             throw new \Exception("Python script failed: " . implode("\n", $output));
    //         }

    //         return response()->json([
    //             'success' => true,
    //             'message' => 'Schedule Adjustment has been approved successfully.',
    //             'data' => $attendanceRecordsId
    //         ]);

    //     } catch (\Exception $e) {

    //         return response()->json([
    //             'success' => false,
    //             'message' => 'Failed to approve ScheduleAdjustment.',
    //             'error' => $e->getMessage()
    //         ], 500);
    //     }
    // }

    public function approve($id)
    {
        try {
            $biometricImportId  = $this->biometricHistoryList->getLoadedRecordId();
            $scheduleAdjustment = ScheduleAdjustment::findOrFail($id);

            $scheduleAdjustment->approval_status = 'Approved';
            $scheduleAdjustment->save();

            $attendanceRecord = DB::table('attendance_records')
                ->where('id', $scheduleAdjustment->attendance_records_id)
                ->first();

            $snapshotResult = null;

            if ($attendanceRecord) {
                $emp = DB::table('employee_management')
                    ->where('id', $attendanceRecord->employee_management_id)
                    ->first();

                $computation    = app(ComputationService::class);
                $nonWorkingDays = DB::table('custom_dates')
                    ->pluck('record_date')
                    ->map(fn($d) => substr($d, 0, 10))
                    ->toArray();
                $employeeData   = DB::table('employee_management')->get()->toArray();

                // ── Snapshot + midnight-safe OT for any shift change ────────────
                // Look up the existing overtime record so we can preserve its values
                // before recalculating with the new schedule.
                $originalOt = DB::table('overtimes')
                    ->where('attendance_records_id', $scheduleAdjustment->attendance_records_id)
                    ->where('biometric_imports_id', $biometricImportId)
                    ->first();

                $snapshotPath   = storage_path('app/schedule_adjustment_snapshots.json');
                $adjustmentData = array_merge((array)$scheduleAdjustment->toArray(), [
                    'employee_name' => $emp->employee_name ?? '',
                    'earliest_time' => $attendanceRecord->earliest_time,
                    'latest_time'   => $attendanceRecord->latest_time,
                ]);

                $snapshotResult = $computation->adjustShiftWithSnapshot(
                    $adjustmentData,
                    $originalOt,
                    $snapshotPath
                );

                // Use the midnight-corrected times returned by adjustShiftWithSnapshot
                // so the downstream autocalculate methods receive proper in/out values.
                $adjustedEarliest = $snapshotResult['adjusted']['earliest_time'];
                $adjustedLatest   = $snapshotResult['adjusted']['latest_time'];

                // ── Full ND/RD breakdown using corrected times ───────────────────
                $rowData = [
                    'employee_name'          => $emp->employee_name ?? '',
                    'employee_management_id' => $attendanceRecord->employee_management_id,
                    'record_date'            => substr($attendanceRecord->record_date, 0, 10),
                    'earliest_time'          => $adjustedEarliest,
                    'latest_time'            => $adjustedLatest,
                    'department'             => $emp->department ?? '',
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
                    'ord', $scheduleAdjustment->schedule ?? null,
                    'Pending', $biometricImportId,
                    $scheduleAdjustment->attendance_records_id,
                    null, 'ord'
                );
            }

            return response()->json([
                'success'      => true,
                'message'      => 'ScheduleAdjustment has been approved successfully.',
                'data'         => $scheduleAdjustment->attendance_records_id,
                'adjusted'     => $snapshotResult['adjusted']     ?? null,
                'snapshot_ref' => $snapshotResult['snapshot_ref'] ?? null,
                'original_ot'  => $snapshotResult['original']     ?? null,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to approve ScheduleAdjustment.',
                'error'   => $e->getMessage(),
            ], 500);
        }
    }

    public function cancel($id)
    {
        try {
            // Find the ScheduleAdjustment record
            $ScheduleAdjustment = ScheduleAdjustment::findOrFail($id);

            // Update the status
            $ScheduleAdjustment->approval_status = 'Cancelled';
            $ScheduleAdjustment->save();

            return response()->json([
                'success' => true,
                'message' => 'ScheduleAdjustment has been cancelled successfully.',
                'data' => $ScheduleAdjustment
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to cancel ScheduleAdjustment.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            $status = $request->get('status', 'Pending');
            $userRole = $request->get('userRole');
            $department = $request->get('department');
            $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

            $data = ScheduleAdjustment::join('employee_management', 'employee_management.id', '=', 'schedule_adjustments.employee_management_id')
                ->select([
                    'schedule_adjustments.id',
                    'employee_management.employee_name',
                    'employee_management.department',
                    'employee_management.report_to',
                    'schedule_adjustments.schedule',
                    'schedule_adjustments.earliest_time',
                    'schedule_adjustments.latest_time',
                    'schedule_adjustments.others',
                    'schedule_adjustments.reason',
                    'schedule_adjustments.record_date',
                    'schedule_adjustments.approval_status'
                ])
                ->when($status !== 'all', function ($query) use ($status) {
                    $query->where('schedule_adjustments.approval_status', $status);
                })
                // ✅ Filter by biometric_imports_id
                ->when($biometricImportId, function ($query) use ($biometricImportId) {
                    $query->where('biometric_imports_id', $biometricImportId);
                })
                ->when($userRole === 'user' && $department, function ($query) use ($department) {
                    $query->where('employee_management.department', $department);
                })
                ->orderBy('employee_management.employee_name', 'asc');

            return DataTables::of($data)->make(true);
        }

        return view('schedule_adjustment');
    }


    public function getScheduleAdjustmentCounts(Request $request)
    {
        $userRole = $request->get('userRole');
        $department = $request->get('department');
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

        $query = ScheduleAdjustment::join(
            'employee_management',
            'employee_management.id',
            '=',
            'schedule_adjustments.employee_management_id'
        );

        // ✅ Apply department filter only if user is a normal user
        if ($userRole === 'user' && $department) {
            $query->where('employee_management.department', $department);
        }
        if (!empty($biometricImportId)) {
            $query->where('biometric_imports_id', $biometricImportId);
        }

        $counts = [
            'pending'   => (clone $query)->where('schedule_adjustments.approval_status', 'Pending')->count(),
            'approved'  => (clone $query)->where('schedule_adjustments.approval_status', 'Approved')->count(),
            'cancelled' => (clone $query)->where('schedule_adjustments.approval_status', 'Cancelled')->count(),
        ];

        return response()->json($counts);
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
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

        $request->validate([
            'attendanceArray' => 'required|array',
            'attendanceArray.*.employee_management_id' => 'required|integer',
            'attendanceArray.*.record_date' => 'required|date',
            'attendanceArray.*.schedule' => 'required|string',
            'attendanceArray.*.others' => 'nullable|string',
            'attendanceArray.*.reason' => 'nullable|string',
            'attendanceArray.*.approval_status' => 'nullable|string'
        ]);

        $createdRecords = 0;
        $skippedRecords = [];

        foreach ($request->attendanceArray as $attendance) {

            $employeeId = $attendance['employee_management_id'];
            $recordDate = $attendance['record_date'];

            // Check if record exists with Pending or Approved
            $exists = ScheduleAdjustment::where('employee_management_id', $employeeId)
                ->where('record_date', $recordDate)
                ->where('biometric_imports_id', $biometricImportId)
                ->whereIn('approval_status', ['Pending', 'Approved'])
                ->exists();

            if ($exists) {
                // Add to skipped array
                $employee = EmployeeManagement::find($employeeId);
                $skippedRecords[] = [
                    'employee_id' => $employeeId,
                    'employee_name' => $employee->employee_name ?? 'Unknown',
                    'record_date' => $recordDate,
                ];
                continue; // Skip creation
            }

            // Find AttendanceRecord if exists
            $attendanceRecord = AttendanceRecord::where('employee_management_id', $employeeId)
                ->where('record_date', $recordDate)
                ->first();

            $attendanceRecordId = $attendanceRecord ? $attendanceRecord->id : null;

            // Create ScheduleAdjustment
            ScheduleAdjustment::create([
                'employee_management_id' => $employeeId,
                'schedule' => $attendance['schedule'],
                'others' => $attendance['others'] ?? null,
                'reason' => $attendance['reason'] ?? null,
                'record_date' => $recordDate,
                'weekday' => \Carbon\Carbon::parse($recordDate)->format('l'),
                'approval_status' => $attendance['approval_status'] ?? 'Pending',
                'biometric_imports_id' => $biometricImportId,
                'attendance_records_id' => $attendanceRecordId,
            ]);

            $createdRecords++;
        }

        return response()->json([
            'message' => count($skippedRecords) > 0
                ? 'Attendance records added, but some were skipped.'
                : 'All attendance records added successfully.',
            'created_count' => $createdRecords,
            'skipped' => $skippedRecords ?? [] // always include, even if empty
        ], 200); // explicit HTTP status code

    }

    // public function store(Request $request)
    // {
    //     $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

    //     $request->validate([
    //         'attendanceArray' => 'required|array',
    //         'attendanceArray.*.employee_management_id' => 'required|integer',
    //         'attendanceArray.*.record_date' => [
    //             'required',
    //             'date',
    //             function ($attribute, $value, $fail) use ($request, $biometricImportId) {
    //                 $index = explode('.', $attribute)[1]; // get index
    //                 $employeeId = $request->attendanceArray[$index]['employee_management_id'];

    //                 $exists = ScheduleAdjustment::where('employee_management_id', $employeeId)
    //                     ->where('record_date', $value)
    //                     ->where('biometric_imports_id', $biometricImportId)
    //                     ->whereIn('approval_status', ['Pending', 'Approved']) // Only consider these statuses
    //                     ->exists();

    //                 if ($exists) {
    //                     $fail("Attendance for employee ID {$employeeId} on {$value} already exists.");
    //                 }
    //             }
    //         ],
    //     ]);

    //     foreach ($request->attendanceArray as $attendance) {
    //         // 🔹 Find AttendanceRecord by record_date + employee_management_id
    //         $attendanceRecord = AttendanceRecord::where('employee_management_id', $attendance['employee_management_id'])
    //             ->where('record_date', $attendance['record_date'])
    //             ->first();

    //         $attendanceRecordId = $attendanceRecord ? $attendanceRecord->id : null;

    //         // 🔹 Create ScheduleAdjustment and link the AttendanceRecord ID
    //         ScheduleAdjustment::create([
    //             'employee_management_id' => $attendance['employee_management_id'],
    //             'schedule' => $attendance['schedule'],
    //             'others' => $attendance['others'] ?? null,
    //             'reason' => $attendance['reason'] ?? null,
    //             'record_date' => $attendance['record_date'],
    //             'weekday' => \Carbon\Carbon::parse($attendance['record_date'])->format('l'),
    //             'approval_status' => $attendance['approval_status'] ?? 'Pending',
    //             'biometric_imports_id' => $biometricImportId,
    //             'attendance_records_id' => $attendanceRecordId, // ✅ Save the found ID
    //         ]);
    //     }

    //     return response()->json(['message' => 'Attendance records saved successfully']);
    // }

    // public function store(Request $request)
    // {
    //     $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();
    //     $request->validate([
    //         'attendanceArray' => 'required|array',
    //         'attendanceArray.*.employee_management_id' => 'required|integer',
    //         'attendanceArray.*.record_date' => [
    //             'required',
    //             'date',
    //             function ($attribute, $value, $fail) use ($request) {
    //                 $index = explode('.', $attribute)[1]; // get index
    //                 $employeeId = $request->attendanceArray[$index]['employee_management_id'];

    //                 $exists = ScheduleAdjustment::where('employee_management_id', $employeeId)
    //                     ->where('record_date', $value)
    //                     ->exists();

    //                 if ($exists) {
    //                     $fail("Attendance for employee ID {$employeeId} on {$value} already exists.");
    //                 }
    //             }
    //         ],
    //     ]);

    //     foreach ($request->attendanceArray as $attendance) {
    //         ScheduleAdjustment::create([
    //             'employee_management_id' => $attendance['employee_management_id'],
    //             'schedule' => $attendance['schedule'],
    //             'others' => $attendance['others'] ?? null,
    //             'reason' => $attendance['reason'] ?? null,
    //             'record_date' => $attendance['record_date'],
    //             'weekday' => \Carbon\Carbon::parse($attendance['record_date'])->format('l'),
    //             'approval_status' => $attendance['approval_status'] ?? 'Pending',
    //             'biometric_imports_id' => $biometricImportId,
    //         ]);
    //     }

    //     return response()->json(['message' => 'Attendance records saved successfully']);
    // }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\ScheduleAdjustment  $ScheduleAdjustment
     * @return \Illuminate\Http\Response
     */
    public function show(ScheduleAdjustment $ScheduleAdjustment)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\ScheduleAdjustment  $ScheduleAdjustment
     * @return \Illuminate\Http\Response
     */
    public function edit(ScheduleAdjustment $ScheduleAdjustment)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\ScheduleAdjustment  $ScheduleAdjustment
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, ScheduleAdjustment $ScheduleAdjustment)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\ScheduleAdjustment  $ScheduleAdjustment
     * @return \Illuminate\Http\Response
     */
    public function destroy(ScheduleAdjustment $ScheduleAdjustment)
    {
        //
    }
}

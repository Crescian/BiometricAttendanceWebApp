<?php

namespace App\Http\Controllers;

use App\Models\BiometricHistoryList;
use App\Models\AttendanceRecord;
use App\Services\ComputationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Yajra\DataTables\Facades\DataTables;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class AttendanceRecordController extends Controller
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
    public function getAttendanceSummary()
    {
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

        // Fetch attendance records filtered by biometric_imports_id
        $attendanceData = AttendanceRecord::where('biometric_imports_id', $biometricImportId)
            ->get()
            ->groupBy(function ($record) {
                // Format date (Y-m-d only)
                return Carbon::parse($record->record_date)->toDateString();
            })
            ->map(function ($group, $date) {
                return [
                    'record_date' => $date,
                    'total_present' => $group->count(),
                ];
            })
            ->values()
            ->toArray();

        // Extract labels (dates) and data (counts)
        $labels = array_column($attendanceData, 'record_date');
        $data = array_column($attendanceData, 'total_present');

        return response()->json([
            'labels' => $labels,
            'data' => $data,
        ]);
    }


    /**
     * Show attendance graph view
     */
    public function showAttendanceGraph()
    {
        return view('attendance.graph');
    }
    public function index(Request $request)
    {
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();
        if ($request->ajax()) {
            $userRole = $request->get('userRole');
            $department = $request->get('department');

            // 🔹 Build query with join to employee_management
            $data = AttendanceRecord::join(
                    'employee_management',
                    'employee_management.id',
                    '=',
                    'attendance_records.employee_management_id'
                )
                ->select(
                    'attendance_records.id',
                    'employee_management.employee_name',
                    'employee_management.department',
                    'employee_management.report_to',
                    'employee_management.schedule_shift',
                    'attendance_records.attendance_area',
                    'attendance_records.attendance_point_name',
                    'attendance_records.verification_mode',
                    'attendance_records.attendance_photo',
                    'attendance_records.data_sources',
                    'attendance_records.record_date',
                    'attendance_records.earliest_time',
                    'attendance_records.latest_time',
                    'attendance_records.weekday',
                    'attendance_records.leaves',
                    'attendance_records.is_manual',
                    'attendance_records.original_earliest_time',
                    'attendance_records.original_latest_time',
                    'attendance_records.edited_by',
                    'attendance_records.edited_at',
                    'attendance_records.created_at'
                )
                // ✅ Filter by currently loaded Biometric Import ID
                ->where('attendance_records.biometric_imports_id', $biometricImportId)
                ->orderBy('attendance_records.record_date', 'desc');

            // ✅ Apply department filter if user is not admin
            if ($userRole === 'user' && $department) {
                $data->where('employee_management.department', $department);
            }

            // ✅ Return data as DataTable JSON
            return DataTables::of($data)
                ->filterColumn('employee_name', function ($query, $keyword) {
                    $query->whereRaw('LOWER(employee_management.employee_name) LIKE ?', ["%{$keyword}%"]);
                })
                ->filterColumn('department', function ($query, $keyword) {
                    $query->whereRaw('LOWER(employee_management.department) LIKE ?', ["%{$keyword}%"]);
                })
                ->filterColumn('report_to', function ($query, $keyword) {
                    $query->whereRaw('LOWER(employee_management.report_to) LIKE ?', ["%{$keyword}%"]);
                })
                ->filterColumn('schedule_shift', function ($query, $keyword) {
                    $query->whereRaw('LOWER(employee_management.schedule_shift) LIKE ?', ["%{$keyword}%"]);
                })
                ->make(true);
        }

        return view('attendanceRecord.fetch');
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
    public function store(Request $request, ComputationService $computation)
    {
        $batch = $this->activeBatch();
        if (is_string($batch)) {
            return response()->json(['success' => false, 'message' => $batch], 422);
        }

        $start = substr($batch->period_start, 0, 10);
        $end   = substr($batch->period_end, 0, 10);

        $v = $request->validate([
            'employee_management_id' => 'required|integer|exists:employee_management,id',
            'record_date'            => "required|date|after_or_equal:$start|before_or_equal:$end",
            'earliest_time'          => 'required|date_format:H:i',
            'latest_time'            => 'required|date_format:H:i|different:earliest_time',
        ], [
            'record_date.after_or_equal'  => "Date must be within the payroll period ($start to $end).",
            'record_date.before_or_equal' => "Date must be within the payroll period ($start to $end).",
            'latest_time.different'       => 'Time Out must be different from Time In.',
        ]);

        $recordDate = Carbon::parse($v['record_date'])->toDateString();

        // One record per employee per day across all imports (unique index), otherwise payroll
        // counts the day twice.
        $exists = AttendanceRecord::where('employee_management_id', $v['employee_management_id'])
            ->whereRaw('DATE(record_date) = ?', [$recordDate])
            ->exists();

        if ($exists) {
            return response()->json([
                'success' => false,
                'message' => 'An attendance record already exists for this employee on this date. Edit it instead.',
            ], 422);
        }

        $record = DB::transaction(function () use ($v, $recordDate, $batch, $computation) {
            // Stored exactly like a biometric row so the payroll formula treats it the same.
            $record = AttendanceRecord::create([
                'employee_management_id' => $v['employee_management_id'],
                'biometric_imports_id'   => $batch->id,
                'record_date'            => $recordDate,
                'earliest_time'          => $v['earliest_time'] . ':00',
                'latest_time'            => $v['latest_time'] . ':00',
                'weekday'                => Carbon::parse($recordDate)->format('l'),
                'attendance_area'        => 'MANUAL',
                'data_sources'           => 'Manual Entry',
                'late'                   => false,
                'late_hours'             => 0,
                'late_minutes'           => 0,
                'leaves'                 => false,
                'is_manual'              => true,
                'edited_by'              => Auth::user()->name ?? null,
                'edited_at'              => now(),
            ]);

            $computation->recomputeForAttendanceRecord($record->id, $batch->id);

            return $record;
        });

        return response()->json([
            'success' => true,
            'message' => 'Attendance record added.',
            'data'    => $record,
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\AttendanceRecord  $attendanceRecord
     * @return \Illuminate\Http\Response
     */
    public function show(AttendanceRecord $attendanceRecord)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\AttendanceRecord  $attendanceRecord
     * @return \Illuminate\Http\Response
     */
    public function edit(AttendanceRecord $attendanceRecord)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\AttendanceRecord  $attendanceRecord
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id, ComputationService $computation)
    {
        $batch = $this->activeBatch();
        if (is_string($batch)) {
            return response()->json(['success' => false, 'message' => $batch], 422);
        }

        $record = AttendanceRecord::where('id', $id)
            ->where('biometric_imports_id', $batch->id)
            ->first();

        if (!$record) {
            return response()->json([
                'success' => false,
                'message' => 'Attendance record not found in the active biometric import.',
            ], 404);
        }

        $recordDate = substr($record->record_date, 0, 10);
        $start      = substr($batch->period_start, 0, 10);
        $end        = substr($batch->period_end, 0, 10);

        if ($recordDate < $start || $recordDate > $end) {
            return response()->json([
                'success' => false,
                'message' => "Record date is outside the payroll period ($start to $end).",
            ], 422);
        }

        $v = $request->validate([
            'earliest_time' => 'required|date_format:H:i',
            'latest_time'   => 'required|date_format:H:i|different:earliest_time',
        ], [
            'latest_time.different' => 'Time Out must be different from Time In.',
        ]);

        DB::transaction(function () use ($record, $v, $batch, $computation) {
            // Keep the first-seen punches so the edit can always be traced back.
            if ($record->original_earliest_time === null && $record->original_latest_time === null) {
                $record->original_earliest_time = $record->earliest_time;
                $record->original_latest_time   = $record->latest_time;
            }

            $record->earliest_time = $v['earliest_time'] . ':00';
            $record->latest_time   = $v['latest_time'] . ':00';
            $record->edited_by     = Auth::user()->name ?? null;
            $record->edited_at     = now();
            $record->save();

            $computation->recomputeForAttendanceRecord($record->id, $batch->id);
        });

        return response()->json([
            'success' => true,
            'message' => 'Attendance record updated.',
            'data'    => $record,
        ]);
    }

    /**
     * The active (status='load') batch, or an error message when manual entries
     * are not allowed against it.
     */
    private function activeBatch()
    {
        $batch = BiometricHistoryList::where('status', 'load')->first();

        if (!$batch) {
            return 'No active biometric import. Load one on the CSV Import page first.';
        }
        if (!empty($batch->is_locked)) {
            return 'The active biometric import is locked.';
        }
        if (!$batch->period_start || !$batch->period_end) {
            return 'The active biometric import has no payroll period set.';
        }

        return $batch;
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\AttendanceRecord  $attendanceRecord
     * @return \Illuminate\Http\Response
     */
    public function destroy(AttendanceRecord $attendanceRecord)
    {
        //
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\BiometricHistoryList;
use App\Models\AttendanceRecord;
use Illuminate\Http\Request;
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
    public function store(Request $request)
    {
        //
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
    public function update(Request $request, AttendanceRecord $attendanceRecord)
    {
        //
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

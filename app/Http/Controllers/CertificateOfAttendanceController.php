<?php

namespace App\Http\Controllers;

use App\Models\AttendanceRecord;
use App\Models\EmployeeManagement;
use App\Models\CertificateOfAttendance;
use App\Services\ComputationService;
use Illuminate\Http\Request;
use Yajra\DataTables\Facades\DataTables;
use Carbon\Carbon;
use App\Models\BiometricHistoryList;
use Illuminate\Support\Facades\DB;


class CertificateOfAttendanceController extends Controller
{
    protected $biometricHistoryList;

    public function __construct(BiometricHistoryList $biometricHistoryList)
    {
        $this->biometricHistoryList = $biometricHistoryList;
    }
    public function getCertificateAttendanceSummary()
    {
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

        // Fetch and group by approval_status, filtered by biometric_imports_id
        $statusSummary = CertificateOfAttendance::where('biometric_imports_id', $biometricImportId)
            ->select('approval_status')
            ->selectRaw('COUNT(*) as total')
            ->groupBy('approval_status')
            ->get();

        // Prepare chart data
        $labels = $statusSummary->pluck('approval_status');
        $data = $statusSummary->pluck('total');

        return response()->json([
            'labels' => $labels,
            'data' => $data
        ]);
    }

    public function approve($id)
    {
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

        try {
            $coa = CertificateOfAttendance::findOrFail($id);

            // Update COA approval status
            $coa->approval_status = 'Approved';
            $coa->save();

            // ✅ Create AttendanceRecord now
            $attendanceRecord = AttendanceRecord::create([
                'employee_management_id' => $coa->employee_management_id,
                'biometric_imports_id'   => $biometricImportId,
                'record_date'            => $coa->date,
                'earliest_time'          => $coa->earliest_time,
                'latest_time'            => $coa->latest_time,
                'attendance_area'        => 'COA',
                'weekday'                => $coa->weekday,
                'late'                   => false,
                'late_hours'             => 0,
                'late_minutes'           => 0,
                'leaves'                 => false,
            ]);

            // ✅ Update the COA with the generated AttendanceRecord ID
            $coa->attendance_records_id = $attendanceRecord->id;
            $coa->save();

            // Compute overtime via ComputationService (replaces attendance_manager.py exec)
            $emp = DB::table('employee_management')
                ->where('id', $coa->employee_management_id)
                ->first();

            $computation    = app(ComputationService::class);
            $nonWorkingDays = DB::table('custom_dates')
                ->pluck('record_date')
                ->map(fn($d) => substr($d, 0, 10))
                ->toArray();
            $employeeData = DB::table('employee_management')->get()->toArray();

            $rowData = [
                'employee_name'          => $emp->employee_name ?? '',
                'employee_management_id' => $coa->employee_management_id,
                'record_date'            => substr($coa->date, 0, 10),
                'earliest_time'          => $coa->earliest_time,
                'latest_time'            => $coa->latest_time,
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
                'ord', $emp->schedule ?? null,
                'Pending', $biometricImportId,
                $attendanceRecord->id,
                null, 'ord'
            );

            return response()->json([
                'success' => true,
                'message' => 'Certificate of Attendance approved and AttendanceRecord created.',
                'data' => $coa
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to approve Certificate of Attendance.',
                'error' => $e->getMessage()
            ], 500);
        }
    }


    public function cancel($id)
    {
        try {
            // Find the CertificateOfAttendance record
            $CertificateOfAttendance = CertificateOfAttendance::findOrFail($id);

            // Update the status
            $CertificateOfAttendance->approval_status = 'Cancelled';
            $CertificateOfAttendance->save();

            return response()->json([
                'success' => true,
                'message' => 'CertificateOfAttendance has been cancelled successfully.',
                'data' => $CertificateOfAttendance
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to cancel CertificateOfAttendance.',
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

            $data = CertificateOfAttendance::join(
                    'employee_management',
                    'employee_management.id',
                    '=',
                    'certificate_attendance.employee_management_id'
                )
                ->select(
                    'certificate_attendance.id',
                    'employee_management.employee_name',
                    'employee_management.department',
                    'employee_management.report_to',
                    'employee_management.schedule',
                    'certificate_attendance.earliest_time',
                    'certificate_attendance.latest_time',
                    'certificate_attendance.others',
                    'certificate_attendance.reason',
                    'certificate_attendance.date',
                    'certificate_attendance.approval_status'
                )
                ->where('certificate_attendance.approval_status', $status)
                ->orderBy('employee_management.employee_name', 'asc');

            // ✅ Apply biometric_imports_id filter only if it has a value
            if (!empty($biometricImportId)) {
                $data->where('certificate_attendance.biometric_imports_id', $biometricImportId);
            }

            // ✅ Apply department filter if user is not admin
            if ($userRole === 'user' && $department) {
                $data->where('employee_management.department', $department);
            }

            return DataTables::of($data)
                ->filterColumn('employee_name', function($query, $keyword) {
                    $query->whereRaw('LOWER(employee_management.employee_name) LIKE ?', ["%{$keyword}%"]);
                })
                ->filterColumn('department', function($query, $keyword) {
                    $query->whereRaw('LOWER(employee_management.department) LIKE ?', ["%{$keyword}%"]);
                })
                ->filterColumn('report_to', function($query, $keyword) {
                    $query->whereRaw('LOWER(employee_management.report_to) LIKE ?', ["%{$keyword}%"]);
                })
                ->filterColumn('schedule', function($query, $keyword) {
                    $query->whereRaw('LOWER(employee_management.schedule) LIKE ?', ["%{$keyword}%"]);
                })
                ->make(true);
        }

        return view('certificateOfAttendance.fetch');
    }


    public function getCertificateOfAttendanceCounts(Request $request)
    {
        $userRole = $request->get('userRole');
        $department = $request->get('department');
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

        $query = CertificateOfAttendance::join(
            'employee_management',
            'employee_management.id',
            '=',
            'certificate_attendance.employee_management_id'
        );

        // ✅ Apply department filter only if user is not admin
        if ($userRole === 'user' && $department) {
            $query->where('employee_management.department', $department);
        }

        if (!empty($biometricImportId)) {
            $query->where('biometric_imports_id', $biometricImportId);
        }

        $counts = [
            'pending' => (clone $query)->where('certificate_attendance.approval_status', 'Pending')->count(),
            'approved' => (clone $query)->where('certificate_attendance.approval_status', 'Approved')->count(),
            'cancelled' => (clone $query)->where('certificate_attendance.approval_status', 'Cancelled')->count(),
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
            'attendanceArray.*.employee_management_id' => 'required',
            'attendanceArray.*.date' => 'required|date',
            'attendanceArray.*.earliest_time' => 'required|string',
            'attendanceArray.*.latest_time' => 'required|string',
            'attendanceArray.*.others' => 'nullable|string',
            'attendanceArray.*.reason' => 'nullable|string',
            'attendanceArray.*.weekday' => 'required|string',
            'attendanceArray.*.attendance_area' => 'nullable|string'
        ]);

        DB::beginTransaction();

        try {
            $existingRecords = [];
            $createdRecords = 0;

            foreach ($request->attendanceArray as $attendance) {

                // ✅ Case: All Employees
                if ($attendance['employee_management_id'] === 'all') {
                    $employees = EmployeeManagement::all();

                    foreach ($employees as $employee) {
                        $alreadyExists = CertificateOfAttendance::where('employee_management_id', $employee->id)
                            ->where('date', $attendance['date'])
                            ->where('biometric_imports_id', $biometricImportId)
                            ->whereIn('approval_status', ['Pending', 'Approved']) // Only consider these statuses
                            ->exists();

                        if ($alreadyExists) {
                            $existingRecords[] = [
                                'employee_id' => $employee->id,
                                'employee_name' => $employee->employee_name ?? 'Unknown',
                                'date' => $attendance['date'],
                            ];
                            continue;
                        }

                        // ✅ Create CertificateOfAttendance using new record ID
                            $certificateOfAttendance = CertificateOfAttendance::create([
                            'employee_management_id' => $employee->id,
                            'earliest_time' => $attendance['earliest_time'] ?? '00:00',
                            'latest_time' => $attendance['latest_time'] ?? '00:00',
                            'others' => $attendance['others'] ?? null,
                            'reason' => $attendance['reason'] ?? null,
                            'date' => $attendance['date'],
                            'weekday' => Carbon::parse($attendance['date'])->format('l'),
                            'approval_status' => 'Approved',
                            'biometric_imports_id' => $biometricImportId,
                            'is_cutoff' => filter_var($attendance['is_cutoff'] ?? false, FILTER_VALIDATE_BOOLEAN), // ✅ boolean
                        ]);

                        $createdRecords++;
                    }
                }

                // ✅ Case: Single Employee
                else {
                    $employee = EmployeeManagement::find($attendance['employee_management_id']);
                    $alreadyExists = CertificateOfAttendance::where('employee_management_id',  $attendance['employee_management_id'])
                        ->where('date', $attendance['date'])
                        ->where('biometric_imports_id', $biometricImportId)
                        ->whereIn('approval_status', ['Pending', 'Approved']) // Only consider these statuses
                        ->exists();

                    if ($alreadyExists) {
                        $existingRecords[] = [
                            'employee_id' =>  $attendance['employee_management_id'],
                            'employee_name' => $employee->employee_name ?? 'Unknown',
                            'date' => $attendance['date'],
                        ];
                        continue;
                    }

                    // ✅ Create CertificateOfAttendance using AttendanceRecord ID
                    $certificateOfAttendance = CertificateOfAttendance::create([
                        'employee_management_id' => $attendance['employee_management_id'],
                        'earliest_time' => $attendance['earliest_time'],
                        'latest_time' => $attendance['latest_time'],
                        'others' => $attendance['others'] ?? null,
                        'reason' => $attendance['reason'] ?? null,
                        'date' => $attendance['date'],
                        'weekday' => Carbon::parse($attendance['date'])->format('l'),
                        'approval_status' => 'Pending',
                        'biometric_imports_id' => $biometricImportId,
                        'is_cutoff' => filter_var($attendance['is_cutoff'] ?? false, FILTER_VALIDATE_BOOLEAN), // ✅ boolean
                    ]);

                    $createdRecords++;
                }
            }

            DB::commit();

            return response()->json([
                'message' => count($existingRecords) > 0
                    ? "Attendance records added successfully, but some were skipped."
                    : "All attendance records added successfully.",
                'created_count' => $createdRecords,
                'skipped' => $existingRecords ?? []
            ], 200);


        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }


    // public function store(Request $request)
    // {
    //     $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();
    //     $request->validate([
    //         'attendanceArray' => 'required|array',
    //         'attendanceArray.*.employee_management_id' => 'required|integer',
    //         'attendanceArray.*.date' => [
    //             'required',
    //             'date',
    //             function ($attribute, $value, $fail) use ($request) {
    //                 $index = explode('.', $attribute)[1]; // get index
    //                 $employeeId = $request->attendanceArray[$index]['employee_management_id'];

    //                 $exists = CertificateOfAttendance::where('employee_management_id', $employeeId)
    //                     ->where('date', $value)
    //                     ->exists();

    //                 if ($exists) {
    //                     $fail("Attendance for employee ID {$employeeId} on {$value} already exists.");
    //                 }
    //             }
    //         ],
    //     ]);

    //     foreach ($request->attendanceArray as $attendance) {
    //         CertificateOfAttendance::create([
    //             'employee_management_id' => $attendance['employee_management_id'],
    //             'earliest_time' => $attendance['earliest_time'],
    //             'latest_time' => $attendance['latest_time'],
    //             'others' => $attendance['others'] ?? null,
    //             'reason' => $attendance['reason'] ?? null,
    //             'date' => $attendance['date'],
    //             'weekday' => \Carbon\Carbon::parse($attendance['date'])->format('l'),
    //             'approval_status' => $attendance['approval_status'] ?? 'Pending',
    //             'biometric_imports_id' => $biometricImportId,
    //         ]);
    //     }

    //     return response()->json(['message' => 'Attendance records saved successfully']);
    // }


    /**
     * Display the specified resource.
     *
     * @param  \App\Models\CertificateOfAttendance  $certificateOfAttendance
     * @return \Illuminate\Http\Response
     */
    public function show(CertificateOfAttendance $certificateOfAttendance)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\CertificateOfAttendance  $certificateOfAttendance
     * @return \Illuminate\Http\Response
     */
    public function edit(CertificateOfAttendance $certificateOfAttendance)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\CertificateOfAttendance  $certificateOfAttendance
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, CertificateOfAttendance $certificateOfAttendance)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\CertificateOfAttendance  $certificateOfAttendance
     * @return \Illuminate\Http\Response
     */
    public function destroy(CertificateOfAttendance $certificateOfAttendance)
    {
        //
    }
}

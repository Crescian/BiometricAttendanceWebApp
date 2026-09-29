<?php

namespace App\Http\Controllers;

use App\Models\AttendanceRecord;
use App\Models\BiometricHistoryList;
use App\Models\CertificateOfAttendance;
use App\Models\Department;
use App\Models\EmployeeManagement;
use App\Models\Leave;
use App\Models\Overtime;
use App\Models\ScheduleAdjustment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PageController extends Controller
{
    public function dashboard()
    {
        $myStuff = $this->myStuff();

        return view('dashboard', compact('myStuff'));
    }

    /**
     * "My Stuff" card: admins see the whole organization, department heads see the employees
     * of the departments they head. Always limited to the active (loaded) biometric import.
     */
    protected function myStuff(): array
    {
        $isAdmin     = Auth::user()->role === 'admin';
        $departments = $isAdmin
            ? collect()
            : Department::where('department_head', Auth::id())->orderBy('department_name')->pluck('department_name');

        $stuff = [
            'scope'           => $isAdmin ? 'All departments' : ($departments->isEmpty() ? 'No department assigned' : $departments->implode(', ')),
            'present'         => 0,
            'late'            => 0,
            'on_leave'        => 0,
            'pending'         => ['certificates' => 0, 'schedule_adjustments' => 0, 'overtimes' => 0, 'leaves' => 0],
            'pending_total'   => 0,
            'certificates'    => collect(),
            'clock_ins'       => collect(),
        ];

        $importId = BiometricHistoryList::where('status', 'load')->value('id');
        if (!$importId || (!$isAdmin && $departments->isEmpty())) {
            return $stuff;
        }

        $employeeIds = $isAdmin ? null : EmployeeManagement::whereIn('department', $departments)->pluck('id');

        // Base query for a table: active import + (for department heads) their employees only.
        $scoped = function ($model, string $table) use ($importId, $employeeIds) {
            return $model::query()
                ->where("$table.biometric_imports_id", $importId)
                ->when($employeeIds !== null, fn ($q) => $q->whereIn("$table.employee_management_id", $employeeIds));
        };

        $stuff['present']  = $scoped(AttendanceRecord::class, 'attendance_records')->count();
        $stuff['late']     = $scoped(AttendanceRecord::class, 'attendance_records')->where('late', true)->count();
        $stuff['on_leave'] = $scoped(Leave::class, 'leaves')->whereRaw("LOWER(status) = 'approved'")->count();

        // Status values are stored with mixed case ('Pending' / 'pending').
        $stuff['pending'] = [
            'certificates'         => $scoped(CertificateOfAttendance::class, 'certificate_attendance')->whereRaw("LOWER(approval_status) = 'pending'")->count(),
            'schedule_adjustments' => $scoped(ScheduleAdjustment::class, 'schedule_adjustments')->whereRaw("LOWER(approval_status) = 'pending'")->count(),
            'overtimes'            => $scoped(Overtime::class, 'overtimes')->whereRaw("LOWER(status) = 'pending'")->count(),
            'leaves'               => $scoped(Leave::class, 'leaves')->whereRaw("LOWER(status) = 'pending'")->count(),
        ];
        $stuff['pending_total'] = array_sum($stuff['pending']);

        $stuff['certificates'] = $scoped(CertificateOfAttendance::class, 'certificate_attendance')
            ->leftJoin('employee_management', 'employee_management.id', '=', 'certificate_attendance.employee_management_id')
            ->orderByDesc('certificate_attendance.date')
            ->orderByDesc('certificate_attendance.id')
            ->limit(3)
            ->get(['certificate_attendance.date', 'certificate_attendance.approval_status', 'employee_management.employee_name']);

        $stuff['clock_ins'] = $scoped(AttendanceRecord::class, 'attendance_records')
            ->leftJoin('employee_management', 'employee_management.id', '=', 'attendance_records.employee_management_id')
            ->orderByDesc('attendance_records.record_date')
            ->orderByDesc('attendance_records.id')
            ->limit(3)
            ->get(['attendance_records.record_date', 'attendance_records.earliest_time', 'attendance_records.latest_time', 'employee_management.employee_name']);

        return $stuff;
    }

    public function employeeManagement()
    {
        return view('employee_management');
    }

    public function attendanceTracking()
    {
        return view('attendance_tracking');
    }

    public function reportGeneration()
    {
        // Prefill the payroll period with the active import's period; the admin can change it.
        $batch = BiometricHistoryList::where('status', 'load')->first();

        $period = [
            'start' => $batch && $batch->period_start ? substr($batch->period_start, 0, 10) : null,
            'end'   => $batch && $batch->period_end ? substr($batch->period_end, 0, 10) : null,
        ];

        return view('report_generation', compact('period'));
    }

    public function csvImport()
    {
        return view('csv_import');
    }

    public function otApproval()
    {
        return view('ot_approval');
    }

    public function biometricData()
    {
        return view('biometric_data');
    }
    public function certificateAttendance()
    {
        return view('certificate_attendance');
    }
    public function scheduleAdjustment()
    {
        return view('schedule_adjustment');
    }
    public function organizationStructure()
    {
        return view('organization_structure');
    }
    public function attendanceLog()
    {
        return view('attendance_log');
    }
    public function attendanceRecord()
    {
        $batch = BiometricHistoryList::where('status', 'load')->first();

        $period = [
            'start' => $batch && $batch->period_start ? substr($batch->period_start, 0, 10) : null,
            'end'   => $batch && $batch->period_end ? substr($batch->period_end, 0, 10) : null,
        ];

        return view('attendance_record', compact('period'));
    }
    public function leave()
    {
        return view('leave');
    }
}

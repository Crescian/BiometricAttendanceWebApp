<?php

namespace App\Http\Controllers;

use App\Models\BiometricHistoryList;
use Illuminate\Http\Request;

class PageController extends Controller
{
    public function dashboard()
    {
        return view('dashboard');
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

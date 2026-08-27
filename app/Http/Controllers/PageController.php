<?php

namespace App\Http\Controllers;

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
        return view('report_generation');
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
        return view('attendance_record');
    }
    public function leave()
    {
        return view('leave');
    }
}

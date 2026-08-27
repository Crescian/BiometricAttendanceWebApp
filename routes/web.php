<?php

use App\Http\Controllers\BiometricImportController;
use App\Http\Controllers\AttendanceRecordController;
use App\Http\Controllers\LeaveController;
use App\Http\Controllers\AttendanceLogController;
use App\Http\Controllers\ScheduleController;
use App\Http\Controllers\CompanyController;
use App\Http\Controllers\DepartmentController;
use App\Http\Controllers\BusinessUnitController;
use App\Http\Controllers\BiometricHistoryListController;
use App\Http\Controllers\CertificateOfAttendanceController;
use App\Http\Controllers\CustomDateController;
use App\Http\Controllers\OvertimeController;
use App\Http\Controllers\ScheduleAdjustmentController;
use App\Http\Controllers\PageController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\CsvimportController;
use App\Http\Controllers\EmployeeManagementController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('auth/login');
});
Route::middleware(['auth', 'verified'])->group(function () {
    // 🧍 User-only routes
    Route::get('/dashboard', [PageController::class, 'dashboard'])->name('dashboard');
    Route::get('/ot-approval', [PageController::class, 'otApproval'])->name('ot.approval');
    Route::get('/certificate-attendance', [PageController::class, 'certificateAttendance'])->name('certificate.attendance');
    Route::get('/schedule-adjustment', [PageController::class, 'scheduleAdjustment'])->name('schedule.adjustment');
    Route::get('/employee-management', [PageController::class, 'employeeManagement'])->name('employee.management');
    Route::get('/report-generation', [PageController::class, 'reportGeneration'])->name('report.generation');
    Route::get('/attendance-record', [PageController::class, 'attendanceRecord'])->name('attendance.record');
    Route::get('/leave', [PageController::class, 'leave'])->name('leave');
    // 🧑‍💼 Admin-only routes
    Route::middleware('role:admin')->group(function () {
        Route::get('/organization-structure', [PageController::class, 'organizationStructure'])->name('organization.structure');
        Route::get('/biometric-data', [PageController::class, 'biometricData'])->name('biometric.data');
        Route::get('/csv-import', [PageController::class, 'csvImport'])->name('csv.import');
        Route::get('/attendance-tracking', [PageController::class, 'attendanceTracking'])->name('attendance.tracking');
        Route::get('/attendance-log', [PageController::class, 'attendanceLog'])->name('attendance.log');
    });
});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    Route::post('/check-if-exists', [CsvimportController::class, 'checkCSV'])->name('upload.exist');
    Route::post('/csv-import', [CsvimportController::class, 'importCSV'])->name('import.csv');
    Route::post('/upload-csv', [CsvimportController::class, 'uploadCSV'])->name('upload.csv');
    Route::post('/get-entry-dates', [CsvimportController::class, 'getDistinctEntryDates'])->name('report.fetch');
    Route::get('/export-csv', [CsvimportController::class, 'exportCsv'])->name('export.csv');
    Route::post('/save-overtime-json', [CsvimportController::class, 'saveOvertimeJson'])->name('export.saveOvertimeJson');
    Route::post('/save-custom-holiday-json', [CsvimportController::class, 'saveCustomHolidayJson'])->name('export.saveCustomHolidayJson');

    Route::post('/append-employee-date', [CsvimportController::class, 'appendDate']);
    Route::post('/append-attendance-certificates', [CsvimportController::class, 'appendAttendanceCertificates']);
    Route::get('/employee-date/count', [CsvimportController::class, 'count']);
    Route::post('/report-generation', [CsvimportController::class, 'reportGeneration'])->name('report.generation');
    Route::post('/finalize-attendance-certificates', [CsvimportController::class, 'finalizeAttendanceCertificates'])->name('finalize.attendance.certificates');
    Route::post('/run-edit-ot', [CsvimportController::class, 'runEditOt']);

    Route::get('/employees', [EmployeeManagementController::class, 'index'])->name('employees.fetch');
    Route::get('/employees/{id}', [EmployeeManagementController::class, 'edit'])->name('employees.edit');
    Route::put('/employees/{id}', [EmployeeManagementController::class, 'update'])->name('employees.update');
    Route::post('/employeesStore', [EmployeeManagementController::class, 'store'])->name('employees.store');
    Route::delete('/employees/{id}', [EmployeeManagementController::class, 'destroy'])->name('employees.destroy');
    Route::post('/employees', [EmployeeManagementController::class, 'fetch'])->name('employees.fetchs');
    Route::get('/biometricData', [EmployeeManagementController::class, 'showImportForm'])->name('employee.import.form');
    Route::post('/biometricData', [EmployeeManagementController::class, 'import'])->name('employee.import');
    Route::post('/export-biometric-csv', [EmployeeManagementController::class, 'exportToCsv'])->name('employee.export.csv');
    Route::get('/fetch-uniqueids', [EmployeeManagementController::class, 'fetchEmployeeName'])->name('employee.fetch.employeename');

    Route::get('/overtime/status-summary', [OvertimeController::class, 'getOvertimeStatusSummary'])
        ->name('overtime.status.summary');
    Route::get('/overtime/counts', [OvertimeController::class, 'getOvertimeCounts'])->name('overtime.counts');
    Route::get('/overtime', [OvertimeController::class, 'index'])->name('overtime.fetch');
    Route::post('/overtime/{id}/approved', [OvertimeController::class, 'approve'])->name('overtime.approve');
    Route::post('/overtime/{id}/cancelled', [OvertimeController::class, 'cancel'])->name('overtime.cancel');
    Route::post('/overtime/{id}', [OvertimeController::class, 'updateTime'])->name('overtime.updateTime');
    Route::get('/overtime/{id}', [OvertimeController::class, 'edit'])->name('overtime.edit');

    Route::get('/certificate-attendance-summary', [CertificateOfAttendanceController::class, 'getCertificateAttendanceSummary']);
    Route::get('/certificateOfAttendance', [CertificateOfAttendanceController::class, 'index'])->name('certificateOfAttendance.fetch');
    Route::get('/certificateOfAttendance/counts', [CertificateOfAttendanceController::class, 'getCertificateOfAttendanceCounts'])->name('certificateOfAttendance.counts');
    Route::post('/certificate-attendance/store', [CertificateOfAttendanceController::class, 'store'])->name('certificateOfAttendance.store');
    Route::post('/certificateOfAttendance/{id}/approved', [CertificateOfAttendanceController::class, 'approve'])->name('certificateOfAttendance.approve');
    Route::post('/certificateOfAttendance/{id}/cancelled', [CertificateOfAttendanceController::class, 'cancel'])->name('certificateOfAttendance.cancel');

    Route::get('/schedule-adjustments/status-summary', [ScheduleAdjustmentController::class, 'getScheduleAdjustmentSummary'])
    ->name('schedule.status.summary');
    Route::get('/schedule-adjustment', [ScheduleAdjustmentController::class, 'index'])->name('schedule.adjustment');
    Route::get('/scheduleAdjustment/counts', [ScheduleAdjustmentController::class, 'getScheduleAdjustmentCounts'])->name('scheduleAdjustment.counts');
    Route::post('/scheduleAdjustment/store', [ScheduleAdjustmentController::class, 'store'])->name('scheduleAdjustment.store');
    Route::post('/scheduleAdjustment/{id}/approved', [ScheduleAdjustmentController::class, 'approve'])->name('scheduleAdjustment.approve');
    Route::post('/scheduleAdjustment/{id}/cancelled', [ScheduleAdjustmentController::class, 'cancel'])->name('scheduleAdjustment.cancel');

    Route::post('/custom-dates/store', [CustomDateController::class, 'store'])->name('custom-dates.store');
    Route::get('/custom-dates', [CustomDateController::class, 'index'])->name('custom-dates.index');

    Route::get('/biometric-history-list/fetch', [BiometricHistoryListController::class, 'index'])->name('biometric-history-list.fetch');
    Route::post('/biometric-history-list', [BiometricHistoryListController::class, 'store'])->name('biometric-history-list.store');
    Route::post('/biometric-history-list/toggle-status', [BiometricHistoryListController::class, 'toggleStatus'])
    ->name('biometric-history-list.toggle-status');

    Route::get('/company', [CompanyController::class, 'index'])->name('company.fetch');
    Route::post('/company', [CompanyController::class, 'store'])->name('company.store');
    Route::put('/company/{id}', [CompanyController::class, 'update'])->name('company.update');
    Route::delete('/company/{id}', [CompanyController::class, 'destroy'])->name('company.destroy');

    Route::get('/department/fetch', [DepartmentController::class, 'index'])->name('department.fetch');
    Route::get('/department/users', [DepartmentController::class, 'getUsers'])->name('department.getUsers');
    Route::post('/department', [DepartmentController::class, 'store'])->name('department.store');
    Route::put('/department/{id}', [DepartmentController::class, 'update'])->name('department.update');
    Route::delete('/department/{id}', [DepartmentController::class, 'destroy'])->name('department.destroy');
    Route::get('/department', [DepartmentController::class, 'getUserDepartment'])->name('department.getUserDepartment');

    Route::get('/business-unit', [BusinessUnitController::class, 'index'])->name('business-unit.fetch');
    Route::post('/business-unit', [BusinessUnitController::class, 'store'])->name('business-unit.store');
    Route::put('/business-unit/{id}', [BusinessUnitController::class, 'update'])->name('business-unit.update');
    Route::delete('/business-unit/{id}', [BusinessUnitController::class, 'destroy'])->name('business-unit.destroy');

    Route::get('/schedule', [ScheduleController::class, 'index'])->name('schedule.fetch');
    Route::post('/schedule/store', [ScheduleController::class, 'store'])->name('schedule.store');
    Route::delete('/schedule/delete/{id}', [ScheduleController::class, 'destroy'])->name('schedule.delete');

    Route::get('/attendanceLogs/fetch', [AttendanceLogController::class, 'fetch'])->name('attendanceLogs.fetch');

    Route::get('/leaves/status-summary', [LeaveController::class, 'getLeaveStatusSummary'])
    ->name('leaves.status.summary');
    Route::get('/leave/fetch', [LeaveController::class, 'index'])->name('leave.fetch');
    Route::post('/leave/store', [LeaveController::class, 'store'])->name('leave.store');
    Route::get('/leave/counts', [LeaveController::class, 'getLeavesCounts'])->name('leave.counts');
    Route::post('/leave/{id}/approved', [LeaveController::class, 'approve'])->name('leave.approve');
    Route::post('/leave/{id}/cancelled', [LeaveController::class, 'cancel'])->name('leave.cancel');

    Route::get('/attendance-record/fetch', [AttendanceRecordController::class, 'index'])->name('attendance-record.fetch');
    Route::get('/attendance/graph', [AttendanceRecordController::class, 'showAttendanceGraph'])->name('attendance.graph');
    Route::get('/attendance/summary', [AttendanceRecordController::class, 'getAttendanceSummary'])->name('attendance.summary');


    Route::get('/download/converted-file', function () {
        $path = public_path('python/ConvertedFile.csv'); // correct filename

        if (!file_exists($path)) {
            abort(404, 'File not found.');
        }

        return response()->download($path, 'ConvertedFile.csv', [
            'Content-Type' => 'text/csv',
        ]);
    })->name('download.convertedfile');


    Route::get('/download/payroll-file', function () {
        $path = public_path('python/payroll file.xlsx');

        if (!file_exists($path)) {
            abort(404, 'File not found.');
        }

        return response()->download($path, 'payroll file.xlsx', [
            'Content-Type' => 'text/xlsx',
        ]);
    })->name('download.payrollfile');


    Route::get('/download/report-dtr', function () {
        $path = public_path('python/reportdtr.xlsx');

        if (!file_exists($path)) {
            abort(404, 'File not found.');
        }

        return response()->download($path, 'reportdtr.xlsx', [
            'Content-Type' => 'text/xlsx',
        ]);
    })->name('download.reportdtr');

    Route::get('/download/security', function () {
        $path = public_path('python/security.xlsx');

        if (!file_exists($path)) {
            abort(404, 'File not found.');
        }

        return response()->download($path, 'security.xlsx', [
            'Content-Type' => 'text/xlsx',
        ]);
    })->name('download.security');

    // routes/web.php
    Route::post('/overtime_logs/approve', function(\Illuminate\Http\Request $request) {
        $payload = $request->all();
        $path    = public_path('overtime_logs.json');
        $json    = json_decode(file_get_contents($path), true);

        foreach ($json as &$item) {
            if ($item['id'] === $payload['id']
                && $item['record_date'] === $payload['date']
            ) {
                $item['approval_status'] = "true";
                break;
            }
        }

        file_put_contents($path, json_encode($json, JSON_PRETTY_PRINT));
        return response()->json(['success' => true]);
    });


    Route::post('/employee_dates/remove', [CsvimportController::class, 'removeEntry'])
        ->name('employee_dates.remove');
    });

require __DIR__.'/auth.php';

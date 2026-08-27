<?php

namespace App\Http\Controllers;

use App\Models\Csvimport;
use App\Models\BiometricHistoryList;
use App\Services\AttendanceProcessor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use League\Csv\Writer;
use PhpOffice\PhpSpreadsheet\IOFactory;
use SplTempFileObject;

class CsvimportController extends Controller
{
    protected $biometricHistoryList;

    public function __construct(BiometricHistoryList $biometricHistoryList)
    {
        $this->biometricHistoryList = $biometricHistoryList;
    }

    public function index()
    {
    }

    // public function uploadCSV(Request $request, AttendanceProcessor $processor)
    // {
    //     // Allow unlimited execution time (careful on production)
    //     set_time_limit(0);
    //     ini_set('max_execution_time', 0);

    //     $request->validate([
    //         'file' => 'required|mimes:csv,txt,xlsx,xls|max:5120',
    //     ]);

    //     $uploaded = $request->file('file');
    //     if (! $uploaded || ! $uploaded->isValid()) {
    //         return response()->json(['error' => 'Invalid file upload'], 422);
    //     }

    //     $ext = strtolower($uploaded->getClientOriginalExtension());
    //     $fileName = 'DailyAttendance.' . $ext;
    //     $path = $uploaded->storeAs('public/python', $fileName);

    //     $csvPath = storage_path("app/public/python/{$fileName}");
    //     $outputDir = public_path('python'); // keep parity with your python script output dir

    //     // Compute new biometric import id (same approach)
    //     $latestId = \App\Models\BiometricHistoryList::latest('id')->value('id') ?? 0;
    //     $biometricImportId = $latestId + 1;

    //     // small wait loop for file availability
    //     $attempts = 0;
    //     while (! file_exists($csvPath) && $attempts < 10) {
    //         usleep(50_000);
    //         $attempts++;
    //     }

    //     if (! file_exists($csvPath)) {
    //         return response()->json(['error' => 'Uploaded file not found on disk'], 500);
    //     }

    //     try {
    //         $result = $processor->processFile($csvPath, $outputDir, $biometricImportId);

    //         if (! empty($result['error'])) {
    //             return response()->json(['error' => $result['error'], 'log' => $result['log'] ?? null], 500);
    //         }

    //         return response()->json([
    //             'message' => 'File processed successfully',
    //             'preview' => $result['preview'] ?? null,
    //             'stats'   => $result['stats'] ?? null,
    //         ], 200);

    //     } catch (\Throwable $e) {
    //         Log::error('Attendance processing error: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
    //         return response()->json(['error' => 'Processing failed: '.$e->getMessage()], 500);
    //     }
    // }

    public function uploadCSV(Request $request, AttendanceProcessor $processor)
    {
        set_time_limit(0);
        ini_set('max_execution_time', 0);

        $request->validate([
            'file' => 'required|mimes:csv,txt,xlsx,xls|max:5120',
        ]);

        $uploadedFile = $request->file('file');
        if (!$uploadedFile || !$uploadedFile->isValid()) {
            return response()->json(['error' => 'Invalid file upload'], 422);
        }

        $extension = $uploadedFile->getClientOriginalExtension();
        $fileName  = 'DailyAttendance.' . $extension;
        $uploadedFile->storeAs('public/python', $fileName);

        $csvPath    = storage_path("app/public/python/{$fileName}");
        $outputDir  = public_path('python/');
        $latestId   = BiometricHistoryList::latest('id')->value('id') ?? 0;
        $biometricImportId = $latestId + 1;

        $attempts = 0;
        while (!file_exists($csvPath) && $attempts < 10) {
            usleep(50000);
            $attempts++;
        }

        if (!file_exists($csvPath)) {
            return response()->json(['error' => 'Uploaded file not found on disk'], 500);
        }

        try {
            $result = $processor->processFile($csvPath, $outputDir, $biometricImportId);

            if (!empty($result['error'])) {
                return response()->json(['error' => $result['error']], 500);
            }

            return response()->json([
                'message' => 'File processed successfully',
                'preview' => $result['preview'] ?? null,
                'stats'   => $result['stats']   ?? null,
            ], 200);

        } catch (\Throwable $e) {
            Log::error('Attendance processing error: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['error' => 'Processing failed: ' . $e->getMessage()], 500);
        }
    }

    public function reportGeneration(Request $request, AttendanceProcessor $processor)
    {
        set_time_limit(0);
        ini_set('max_execution_time', 0);

        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

        try {
            $result = $processor->generatePayrollReport($biometricImportId);

            if (!empty($result['error'])) {
                return response()->json(['error' => $result['error']], 500);
            }

            return response()->json([
                'message' => 'Report generated successfully',
                'stats'   => $result['stats'] ?? null,
            ], 200);

        } catch (\Throwable $e) {
            Log::error('Report generation error: ' . $e->getMessage());
            return response()->json(['error' => 'Report generation failed: ' . $e->getMessage()], 500);
        }
    }

    public function finalizeAttendanceCertificates(Request $request, AttendanceProcessor $processor)
    {
        $certificatesPath = public_path('attendance_certificates.json');
        $overtimeLogsPath = public_path('overtime_logs.json');
        $outputDir        = public_path('python/');

        try {
            $result = $processor->finalizeCertificates($certificatesPath, $overtimeLogsPath, $outputDir);

            if (!empty($result['error'])) {
                return response()->json(['error' => $result['error']], 500);
            }

            return response()->json([
                'message' => 'Attendance certificates finalized successfully',
                'stats'   => $result['stats'] ?? null,
            ], 200);

        } catch (\Throwable $e) {
            Log::error('Certificate finalization error: ' . $e->getMessage());
            return response()->json(['error' => 'Finalization failed: ' . $e->getMessage()], 500);
        }
    }

    public function runEditOt(Request $request)
    {
        $v = $request->validate([
            'id'          => 'required|string',
            'firstName'   => 'required|string',
            'lastName'    => 'required|string',
            'date'        => 'required|date',
            'originalIn'  => 'required|string',
            'originalOut' => 'required|string',
            'newIn'       => 'required|string',
            'newOut'      => 'required|string',
            'type'        => 'required|string',
        ]);

        $employeeName  = strtoupper($v['lastName']) . ', ' . strtoupper($v['firstName']);
        $recordDate    = \Carbon\Carbon::parse($v['date'])->toDateString();
        $biometricImportId = $this->biometricHistoryList->getLoadedRecordId();

        $emp = \DB::table('employee_management')
            ->where('unique_id', $v['id'])
            ->orWhere('employee_name', $employeeName)
            ->first();

        if (!$emp) {
            return response()->json(['error' => 'Employee not found'], 404);
        }

        // Update attendance record with new times
        \DB::table('attendance_records')
            ->where('employee_management_id', $emp->id)
            ->where('record_date', $recordDate)
            ->update([
                'earliest_time' => $v['newIn'],
                'latest_time'   => $v['newOut'],
                'updated_at'    => now(),
            ]);

        // Recalculate overtime using ComputationService
        $computation    = app(\App\Services\ComputationService::class);
        $nonWorkingDays = \DB::table('custom_dates')->pluck('record_date')->map(fn($d) => substr($d, 0, 10))->toArray();
        $employeeData   = \DB::table('employee_management')->get()->toArray();

        $rowData = [
            'employee_name'          => $employeeName,
            'employee_management_id' => $emp->id,
            'record_date'            => $recordDate,
            'earliest_time'          => $v['newIn'],
            'latest_time'            => $v['newOut'],
            'department'             => $emp->department ?? '',
            'leaves'                 => false,
        ];

        [$ordOt, $ordNd, $ordNdOt] = $computation->autocalculateOrd(
            $rowData, $nonWorkingDays, $employeeData, null, null, $biometricImportId
        );

        $rdResult = $computation->autocalculateRdAndOvertime($rowData, collect($employeeData));

        $hm = function ($h) {
            $m = (int) round($h * 60);
            return sprintf('%02d:%02d', intdiv($m, 60), $m % 60);
        };

        // Update the overtime record if one exists
        \DB::table('overtimes')
            ->where('employee_name', $employeeName)
            ->where('record_date', $recordDate)
            ->where('biometric_imports_id', $biometricImportId)
            ->update([
                'earliest_time' => $v['newIn'],
                'latest_time'   => $v['newOut'],
                'ord_ot'        => $hm($ordOt),
                'ord_nd'        => $hm($ordNd),
                'ord_nd_ot'     => $hm($ordNdOt),
                'rd'            => $hm($rdResult['rd']),
                'rd_ot'         => $hm($rdResult['rd_ot']),
                'rd_nd'         => $hm($rdResult['rd_nd']),
                'rd_nd_ot'      => $hm($rdResult['rd_nd_ot']),
                'updated_at'    => now(),
            ]);

        return response()->json([
            'message' => 'OK',
            'output'  => ['Overtime recalculated successfully'],
        ]);
    }


    public function saveOvertimeJson(Request $request)
    {
        // Validate that employee_dates is an array
        $request->validate([
            'employee_dates' => 'required|array'
        ]);

        // Flatten the array if needed (e.g., if nested arrays are within arrays)
        $flattenedArray = array_map(function ($entry) {
            // Convert MM/DD/YYYY to YYYY-MM-DD
            $originalDate = $entry[3];
            $date = \DateTime::createFromFormat('m/d/Y', $originalDate);
            $formattedDate = $date ? $date->format('Y-m-d') : $originalDate;
            return [
                $entry[0], // Type of OT
                strtoupper($entry[2]), // Last Name (uppercase)
                strtoupper($entry[1]), // First Name (uppercase)
                $formattedDate, // Date
                $entry[4], // Start Time
                $entry[5]  // End Time
            ];
        }, $request->employee_dates);

        // Convert to JSON
        $jsonData = json_encode($flattenedArray, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

        // Save to the same path as your custom holiday JSON
        Storage::disk('public')->put('python/employee_dates.json', $jsonData);

        return response()->json(['message' => 'Overtime records saved successfully!']);
    }

    public function appendDate(Request $request)
    {
        $file = public_path('employee_dates.json');

        $data = file_exists($file)
            ? (json_decode(file_get_contents($file), true) ?? [])
            : [];

        // Append the new entry
        $data[] = [
            $request->input('type'),
            strtoupper($request->input('lastName')),
            strtoupper($request->input('firstName')),
            $request->input('date'),
            $request->input('earliestTime'),
            $request->input('latestTime')
        ];

        // Save back to JSON file
        file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT));

        return response()->json(['success' => true]);
    }

    public function appendAttendanceCertificates(Request $request)
    {
        $file = public_path('attendance_certificates.json');

        // Load existing data
        $data = [];
        if (file_exists($file)) {
            $data = json_decode(file_get_contents($file), true);
        }

        // Append the new entry as an associative array (object in JSON)
        $data[] = [
            "id" => $request->input('id'),
            "First Name" => strtoupper($request->input('firstName')),
            "Last Name" => strtoupper($request->input('lastName')),
            "record_date" => $request->input('date'),
            "Earliest Time" => $request->input('earliestTime'),
            "Latest Time" => $request->input('latestTime'),
            "Department Name" => $request->input('departmentName'),
            "Attendance Area" => $request->input('attendanceArea'),
            "Serial Number" => $request->input('serialNumber'),
            "Schedule" => $request->input('schedule'),
            "Total Non-Working Days Present" => (int) $request->input('nonWorkingDays', 0),
            "late" => filter_var($request->input('late', false), FILTER_VALIDATE_BOOLEAN),
            "late_hours" => (int) $request->input('lateHours', 0),
            "late_minutes" => (int) $request->input('lateMinutes', 0),
            "out_time_required" => $request->input('outTimeRequired'),
            "action" => "add"
        ];

        // Save back to JSON file
        file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT));

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    public function count()
    {
        $file = public_path('employee_dates.json');

        if (!file_exists($file)) {
            return response()->json(['count' => 0]);
        }

        $data = json_decode(file_get_contents($file), true);
        $count = is_array($data) ? count($data) : 0;

        return response()->json(['count' => $count]);
    }

    public function saveCustomHolidayJson(Request $request)
    {
        // Validate the incoming data
        $request->validate([
            'custom_holiday' => 'required|array'
        ]);

        // Flatten the array using array_column
        $flattenedArray = array_column($request->custom_holiday, 0);

        // Convert the flattened array to JSON
        $jsonData = json_encode($flattenedArray, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

        // Save the JSON file in the storage/app/public/python folder
        Storage::disk('public')->put('python/custom_holiday.json', $jsonData);

        return response()->json(['message' => 'Custom Holiday records saved successfully!']);
    }
    public function importCSV(Request $request)
    {
        // Validate the request
        $request->validate([
            'biometric_imports_id' => 'required|integer',
        ]);

        // $biometric_imports_id = '5';

        // Get the current date
        $dates = now()->toDateString();

        // Delete existing data for today's date
        Csvimport::where('entry_date', $dates)->delete();

        // Path to the .csv file
        $path = public_path('python/payroll file.csv');

        // Check if the file exists
        if (!file_exists($path)) {
            return response()->json(['error' => 'File not found.'], 404);
        }

        // Read the file
        $csvData = array_map('str_getcsv', file($path));

        // Assuming the first row contains the header
        $header = array_shift($csvData);

        // Normalize headers to avoid invisible characters or BOM
        $header = array_map(function ($key) {
            return trim(preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $key));
        }, $header);

        // Combine header with data rows
        $jsonData = [];
        foreach ($csvData as $row) {
            $jsonData[] = array_combine($header, $row);
        }

        // Insert each row in $jsonData into the csvimports table
        foreach ($jsonData as $data) {
            $mappedData = [
                'entry_date' => $dates,
                'biometric_imports_id' => $request->biometric_imports_id, // 👈 Add this
                'basic' => $data['Basic'] ?? null,
                'dh' => $data['DH'] ?? null,
                'dh_nd' => $data['DH-ND'] ?? null,
                'dh_nd_excess' => $data['DH-ND-Excess'] ?? null,
                'dh_nd_ot' => $data['DH-ND-OT'] ?? null,
                'dh_ot' => $data['DH-OT'] ?? null,
                'dh_rd' => $data['DH-RD'] ?? null,
                'dh_rd_nd' => $data['DH-RD-ND'] ?? null,
                'dh_rd_nd_ot' => $data['DH-RD-ND-OT'] ?? null,
                'dh_rd_ot' => $data['DH-RD-OT'] ?? null,
                'hours_worked' => $data['Hours Worked'] ?? null,
                'id_number' => $data['ID'] ?? null,
                'lh' => $data['LH'] ?? null,
                'lh_nd' => $data['LH-ND'] ?? null,
                'lh_nd_excess' => $data['LH-ND-Excess'] ?? null,
                'lh_nd_ot' => $data['LH-ND-OT'] ?? null,
                'lh_ot' => $data['LH-OT'] ?? null,
                'lh_rd' => $data['LH-RD'] ?? null,
                'lh_rd_nd' => $data['LH-RD-ND'] ?? null,
                'lh_rd_nd_excess' => $data['LH-RD-ND-Excess'] ?? null,
                'lh_rd_nd_ot' => $data['LH-RD-ND-OT'] ?? null,
                'lh_rd_ot' => $data['LH-RD-OT'] ?? null,
                'name' => $data['Name'] ?? null,
                'ord_nd' => $data['Ord-ND'] ?? null,
                'ord_nd_ot' => $data['Ord-ND-OT'] ?? null,
                'ord_ot' => $data['Ord-OT'] ?? null,
                'rd' => $data['RD'] ?? null,
                'rd_nd' => $data['RD-ND'] ?? null,
                'rd_nd_ot' => $data['RD-ND-OT'] ?? null,
                'rd_ot' => $data['RD-OT'] ?? null,
                'reg_nd_excess' => $data['RegNDExcess'] ?? null,
                'sh' => $data['SH'] ?? null,
                'sh_nd' => $data['SH-ND'] ?? null,
                'sh_nd_excess' => $data['SHNDExcess'] ?? null,
                'sh_nd_ot' => $data['SH-ND-OT'] ?? null,
                'sh_ot' => $data['SH-OT'] ?? null,
                'sh_rd' => $data['SH-RD'] ?? null,
                'sh_rd_nd' => $data['SH-RD-ND'] ?? null,
                'sh_rd_nd_excess' => $data['SH-RD-ND-Excess'] ?? null,
                'sh_rd_nd_ot' => $data['SH-RD-ND-OT'] ?? null,
                'sh_rd_ot' => $data['SH-RD-OT'] ?? null,
                'sun_nd_excess' => $data['Sun-ND-Excess'] ?? null,
                'total_non_working_days_present' => $data['Total Non-Working Days Present'] ?? null,
                'total_regular_working_days_present' => $data['Total Regular Working Days Present'] ?? null,
            ];

            Csvimport::create($mappedData);
        }

        return response()->json([
            'message' => 'CSV imported successfully.',
            'id' => $request->biometric_imports_id
        ]);
    }

    // public function importCSV()
    // {
    //     // Get the current date
    //     $dates = now()->toDateString();

    //     // Delete existing data for today's date
    //     Csvimport::where('entry_date', $dates)->delete();

    //     // Path to the .csv file
    //     $path = public_path('python/payroll file.csv');

    //     // Check if the file exists
    //     if (!file_exists($path)) {
    //         return response()->json(['error' => 'File not found.'], 404);
    //     }

    //     // Read the file
    //     $csvData = array_map('str_getcsv', file($path));

    //     // Assuming the first row contains the header
    //     $header = array_shift($csvData);

    //     // Normalize headers to avoid issues like invisible characters or BOM
    //     $header = array_map(function ($key) {
    //         return trim(preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $key));
    //     }, $header);

    //     // Combine the header with data rows
    //     $jsonData = [];
    //     foreach ($csvData as $row) {
    //         $jsonData[] = array_combine($header, $row);
    //     }
    //     // Insert each row in $jsonData into the csvimports table
    //     foreach ($jsonData as $data) {

    //         // Map JSON keys to database columns
    //         // return $data;
    //         $mappedData = [
    //             'entry_date' => $dates, // Set current date
    //             'basic' => $data['Basic'] ?? null,
    //             'dh' => $data['DH'] ?? null,
    //             'dh_nd' => $data['DH-ND'] ?? null,
    //             'dh_nd_excess' => $data['DH-ND-Excess'] ?? null,
    //             'dh_nd_ot' => $data['DH-ND-OT'] ?? null,
    //             'dh_ot' => $data['DH-OT'] ?? null,
    //             'dh_rd' => $data['DH-RD'] ?? null,
    //             'dh_rd_nd' => $data['DH-RD-ND'] ?? null,
    //             'dh_rd_nd_ot' => $data['DH-RD-ND-OT'] ?? null,
    //             'dh_rd_ot' => $data['DH-RD-OT'] ?? null,
    //             'hours_worked' => $data['Hours Worked'] ?? null,
    //             'id_number' => $data['ID'] ?? null,
    //             'lh' => $data['LH'] ?? null,
    //             'lh_nd' => $data['LH-ND'] ?? null,
    //             'lh_nd_excess' => $data['LH-ND-Excess'] ?? null,
    //             'lh_nd_ot' => $data['LH-ND-OT'] ?? null,
    //             'lh_ot' => $data['LH-OT'] ?? null,
    //             'lh_rd' => $data['LH-RD'] ?? null,
    //             'lh_rd_nd' => $data['LH-RD-ND'] ?? null,
    //             'lh_rd_nd_excess' => $data['LH-RD-ND-Excess'] ?? null,
    //             'lh_rd_nd_ot' => $data['LH-RD-ND-OT'] ?? null,
    //             'lh_rd_ot' => $data['LH-RD-OT'] ?? null,
    //             'name' => $data['Name'] ?? null,
    //             'ord_nd' => $data['Ord-ND'] ?? null,
    //             'ord_nd_ot' => $data['Ord-ND-OT'] ?? null,
    //             'ord_ot' => $data['Ord-OT'] ?? null,
    //             'rd' => $data['RD'] ?? null,
    //             'rd_nd' => $data['RD-ND'] ?? null,
    //             'rd_nd_ot' => $data['RD-ND-OT'] ?? null,
    //             'rd_ot' => $data['RD-OT'] ?? null,
    //             'reg_nd_excess' => $data['RegNDExcess'] ?? null,
    //             'sh' => $data['SH'] ?? null,
    //             'sh_nd' => $data['SH-ND'] ?? null,
    //             'sh_nd_excess' => $data['SHNDExcess'] ?? null,
    //             'sh_nd_ot' => $data['SH-ND-OT'] ?? null,
    //             'sh_ot' => $data['SH-OT'] ?? null,
    //             'sh_rd' => $data['SH-RD'] ?? null,
    //             'sh_rd_nd' => $data['SH-RD-ND'] ?? null,
    //             'sh_rd_nd_excess' => $data['SH-RD-ND-Excess'] ?? null,
    //             'sh_rd_nd_ot' => $data['SH-RD-ND-OT'] ?? null,
    //             'sh_rd_ot' => $data['SH-RD-OT'] ?? null,
    //             'sun_nd_excess' => $data['Sun-ND-Excess'] ?? null,
    //             'total_non_working_days_present' => $data['Total Non-Working Days Present'] ?? null,
    //             'total_regular_working_days_present' => $data['Total Regular Working Days Present'] ?? null,
    //         ];

    //         // Insert data into the database
    //         Csvimport::create($mappedData);
    //     }

    //     return response()->json(['message' => $mappedData]);
    // }

    public function checkCSV(Request $request)
    {
        $title = $request->input('title');
        $exists = BiometricHistoryList::where('title', $title)->exists();

        // Return response based on existence
        if ($exists) {
            return response()->json(['exists' => true, 'message' => 'exists', 'title' => $title]);
        } else {
            return response()->json(['exists' => false, 'message' => 'not exist', 'title' => $title]);
        }
    }

    // public function runPythonScript(Request $request)
    // {
    //     $scriptPath = storage_path('app/public/python/autocompute_attendance.py');
    //     $csvPath = storage_path('app/public/python/DailyAttendance.csv');
    //     $BiometricsvPath = storage_path('app/public/python/BiometricAttendanceInfo.csv');
    //     $OutputcsvPath = public_path('app/python/');


    //     $command = escapeshellcmd("python $scriptPath $csvPath $BiometricsvPath $OutputcsvPath");
    //     $output = [];
    //     $returnVar = 0;
    //     exec($command, $output, $returnVar);
    //     if ($returnVar === 0) {
    //         return response()->json(['output' => implode("\n", $output)], 200);
    //     } else {
    //         return response()->json(['error' => 'Python script failed to execute.'], 500);
    //     }
    // }

    public function getDistinctEntryDates()
    {
        $dates = Csvimport::select('entry_date', 'generate_status')
                ->distinct()
                ->limit(5)
                ->get();

        return response()->json($dates);
    }
    public function exportCsv(Request $request)
    {
        // Query the database for records with the given entry_date
        $records = Csvimport::all();

        // Create a new CSV writer instance
        $csv = Writer::createFromFileObject(new SplTempFileObject());
        $csv->insertOne(['ID', 'Name', 'Basic', 'Hours Worked', 'Total Regular Working Days Present',
                        'Total Non Working Days Present', 'Ord OT', 'Ord ND', 'Ord-ND-OT', 'RegNDExcess',
                        'RD', 'RD-OT', 'RD-ND', 'RD-ND-OT', 'SunNDExcess', 'SH', 'SH-OT', 'SH-ND',
                        'SH-ND-OT', 'SHNDExcess', 'LH', 'LH-OT', 'LH-ND', 'LH-ND-OT', 'LHNDExcess',
                        'SH-RD', 'SH-RD-OT', 'SH-RD-ND', 'SH-RD-ND-OT', 'SHRNDExcess', 'LH-RD', 'LH-RD-OT',
                        'LH-RD-ND', 'LH-RD-ND-OT', 'LHRNDExcess', 'DH', 'DH-OT', 'DH-ND', 'DH-ND-OT',
                        'DHNDExcess', 'DH-RD', 'DH-RD-OT', 'DH-RD-ND', 'DH-RD-ND-OT']); // Column headers
        // Add rows to the CSV
        foreach ($records as $record) {
            $csv->insertOne([
                $record->id_number,
                $record->name,
                $record->basic,
                $record->hours_worked,
                $record->total_regular_working_days_present,
                $record->total_non_working_days_present,
                $record->ord_ot,
                $record->ord_nd,
                $record->ord_nd_ot,
                $record->reg_nd_excess,
                $record->rd,
                $record->rd_ot,
                $record->rd_nd,
                $record->rd_nd_ot,
                $record->sun_nd_excess,
                $record->sh,
                $record->sh_ot,
                $record->sh_nd,
                $record->sh_nd_ot,
                $record->sh_nd_excess,
                $record->lh,
                $record->lh_ot,
                $record->lh_nd,
                $record->lh_nd_ot,
                $record->lh_nd_excess,
                $record->sh_rd,
                $record->sh_rd_ot,
                $record->sh_rd_nd,
                $record->sh_rd_nd_ot,
                $record->sh_rd_nd_excess,
                $record->lh_rd,
                $record->lh_rd_ot,
                $record->lh_rd_nd,
                $record->lh_rd_nd_ot,
                $record->lh_rd_nd_excess,
                $record->dh,
                $record->dh_ot,
                $record->dh_nd,
                $record->dh_nd_ot,
                $record->dh_nd_excess,
                $record->dh_rd,
                $record->dh_rd_ot,
                $record->dh_rd_nd,
                $record->dh_rd_nd_ot,
            ]);
        }

        // Update the generate_status to true indicating that the data is generated
       Csvimport::query()->update(['generate_status' => true]);


        // Create a response with the CSV content and download headers
        $filename = 'csv_imports_.csv';
        return response((string) $csv, 200)
            ->header('Content-Type', 'text/csv')
            ->header('Content-Disposition', 'attachment; filename="' . $filename . '"');
    }

    // public function removeEntry(Request $request)
    // {
    //     // 1) Validate incoming index
    //     $request->validate([
    //         'index' => 'required|integer|min:0',
    //     ]);

    //     $index = $request->input('index');

    //     // 2) Locate the JSON file
    //     // Adjust path if you store it elsewhere
    //     $path = public_path('employee_dates.json');

    //     if (!file_exists($path)) {
    //         return response()->json(['message' => 'File not found.'], 404);
    //     }

    //     // 3) Read + decode
    //     $data = json_decode(file_get_contents($path), true);
    //     if (!is_array($data) || !isset($data[$index])) {
    //         return response()->json(['message' => 'Entry not found.'], 404);
    //     }

    //     // 4) Remove the entry and re-save
    //     array_splice($data, $index, 1);
    //     file_put_contents($path, json_encode($data, JSON_PRETTY_PRINT));

    //     // 5) Respond with success (and new length, if you like)
    //     return response()->json([
    //         'message' => 'Entry removed.',
    //         'total'   => count($data),
    //     ]);
    // }
    public function removeEntry(Request $request)
    {
        $request->validate([
            'index' => 'required|integer|min:0',
        ]);

        $index = $request->input('index');

        // Path to files
        $employeeDatesPath = public_path('employee_dates.json');
        $overtimeLogsPath  = public_path('overtime_logs.json');

        if (!file_exists($employeeDatesPath)) {
            return response()->json(['message' => 'employee_dates.json not found.'], 404);
        }

        // --- Step 1: Remove from employee_dates.json ---
        $employeeDates = json_decode(file_get_contents($employeeDatesPath), true);

        if (!is_array($employeeDates) || !isset($employeeDates[$index])) {
            return response()->json(['message' => 'Entry not found.'], 404);
        }

        // Get entry details before removing
        $entry = $employeeDates[$index];

        // Remove from employee_dates.json
        array_splice($employeeDates, $index, 1);
        file_put_contents($employeeDatesPath, json_encode($employeeDates, JSON_PRETTY_PRINT));

        // --- Step 2: Update overtime_logs.json ---
        if (file_exists($overtimeLogsPath)) {
            $overtimeLogs = json_decode(file_get_contents($overtimeLogsPath), true);

            // Handle if it's a single object or array
            if ($overtimeLogs && (isset($overtimeLogs[0]) || $this->is_assoc($overtimeLogs))) {
                $logs = isset($overtimeLogs[0]) ? $overtimeLogs : [$overtimeLogs];

                foreach ($logs as &$log) {
                    if (
                        $log['Type'] === $entry[0] &&
                        $log['Last Name'] === $entry[1] &&
                        $log['First Name'] === $entry[2] &&
                        $log['record_date'] === $entry[3] &&
                        $log['Earliest Time'] === $entry[4] &&
                        $log['Latest Time'] === $entry[5]
                    ) {
                        $log['approval_status'] = "false";
                    }
                }

                // Save back
                file_put_contents($overtimeLogsPath, json_encode($logs, JSON_PRETTY_PRINT));
            }
        }

        return response()->json([
            'message' => 'Entry removed and overtime log updated.',
            'total'   => count($employeeDates),
        ]);
    }

    // Helper: detect if array is associative
    private function is_assoc(array $arr)
    {
        return array_keys($arr) !== range(0, count($arr) - 1);
    }

    public function create()
    {
        //
    }

    public function store(Request $request)
    {
        //
    }

    public function show(Csvimport $csvimport)
    {
        //
    }

    public function edit(Csvimport $csvimport)
    {
        //
    }

    public function update(Request $request)
    {
    }


    public function destroy(Csvimport $csvimport)
    {
        //
    }
}

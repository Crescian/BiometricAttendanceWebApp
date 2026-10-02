<?php

namespace App\Http\Controllers;

use App\Services\AuditLogger;
use App\Models\Csvimport;
use App\Models\BiometricHistoryList;
use App\Services\AttendanceProcessor;
use Illuminate\Http\Request;
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
        $outputDir  = storage_path('app/reports/');

        // Create the real biometric_imports row here (instead of guessing a future id)
        // so attendance_records/overtimes seeded below always match the id that
        // biometric-history-list.store() later fills in and every other controller
        // reads via BiometricHistoryList::getLoadedRecordId().
        $previouslyLoaded = BiometricHistoryList::where('status', 'load')->pluck('id')->all();
        BiometricHistoryList::where('status', 'load')->update(['status' => 'unload']);
        $biometricImport = BiometricHistoryList::create([
            'title'       => $request->input('title', $fileName),
            'status'      => 'load',
            'imported_by' => Auth::user()->email ?? null,
            'imported_at' => now(),
        ]);
        $biometricImportId = $biometricImport->id;

        $attempts = 0;
        while (!file_exists($csvPath) && $attempts < 10) {
            usleep(50000);
            $attempts++;
        }

        if (!file_exists($csvPath)) {
            return response()->json(['error' => 'Uploaded file not found on disk'], 500);
        }

        $fileEvidence = [
            'file' => $uploadedFile->getClientOriginalName(),
            'bytes' => $uploadedFile->getSize(),
            'sha256' => hash_file('sha256', $csvPath),
            'biometric_import_id' => $biometricImportId,
            'previously_loaded_import_ids' => $previouslyLoaded,
        ];

        try {
            $result = $processor->processFile($csvPath, $outputDir, $biometricImportId);

            if (!empty($result['error'])) {
                AuditLogger::record('import.biometric_file_processed', [
                    'category' => 'import', 'action' => 'import', 'outcome' => 'failure',
                    'target' => ['BiometricHistoryList', $biometricImportId],
                    'description' => 'Biometric file import failed: '.$result['error'],
                    'metadata' => $fileEvidence + ['error' => $result['error']],
                ]);

                return response()->json(['error' => $result['error']], 500);
            }

            $batch = BiometricHistoryList::find($biometricImportId);

            AuditLogger::record('import.biometric_file_processed', [
                'category' => 'import', 'action' => 'import',
                'target' => ['BiometricHistoryList', $biometricImportId],
                'description' => 'Imported biometric file '.$fileEvidence['file']
                    .' as import #'.$biometricImportId.' ('.($batch->period_start ?? '?').' to '.($batch->period_end ?? '?').')',
                'metadata' => $fileEvidence + [
                    'period_start' => $batch->period_start ?? null,
                    'period_end' => $batch->period_end ?? null,
                    'attendance_records' => \DB::table('attendance_records')->where('biometric_imports_id', $biometricImportId)->count(),
                    'overtimes' => \DB::table('overtimes')->where('biometric_imports_id', $biometricImportId)->count(),
                    'stats' => $result['stats'] ?? null,
                ],
            ]);

            return response()->json([
                'message' => 'File processed successfully',
                'preview' => $result['preview'] ?? null,
                'stats'   => $result['stats']   ?? null,
                'biometric_imports_id' => $biometricImportId,
                'period_start' => $batch->period_start ?? null,
                'period_end'   => $batch->period_end ?? null,
            ], 200);

        } catch (\Throwable $e) {
            AuditLogger::record('import.biometric_file_processed', [
                'category' => 'import', 'action' => 'import', 'outcome' => 'failure',
                'target' => ['BiometricHistoryList', $biometricImportId],
                'description' => 'Biometric file import failed: '.$e->getMessage(),
                'metadata' => $fileEvidence + ['error' => $e->getMessage()],
            ]);
            Log::error('Attendance processing error: ' . $e->getMessage(), ['trace' => $e->getTraceAsString()]);
            return response()->json(['error' => 'Processing failed: ' . $e->getMessage()], 500);
        }
    }

    public function reportGeneration(Request $request, AttendanceProcessor $processor)
    {
        set_time_limit(0);
        ini_set('max_execution_time', 0);

        // The payroll period is chosen at generation time; records from every
        // biometric import dated inside it are included.
        $v = $request->validate([
            'period_start' => 'required|date',
            'period_end'   => 'required|date|after_or_equal:period_start',
        ]);
        $start = \Carbon\Carbon::parse($v['period_start'])->toDateString();
        $end   = \Carbon\Carbon::parse($v['period_end'])->toDateString();

        try {
            $result = $processor->generatePayrollReport($start, $end);

            if (!empty($result['error'])) {
                AuditLogger::record('report.payroll_generated', [
                    'category' => 'report', 'action' => 'generate', 'outcome' => 'failure',
                    'description' => "Payroll report for {$start} to {$end} not generated: ".$result['error'],
                    'metadata' => ['period_start' => $start, 'period_end' => $end, 'error' => $result['error']],
                ]);

                return response()->json(['error' => $result['error']], 422);
            }

            $stats = $result['stats'] ?? [];

            // Evidence of exactly what was produced
            $outputs = [];
            foreach (['payroll file.csv', 'payroll file.xlsx', 'reportdtr.xlsx', 'security.xlsx'] as $name) {
                $path = AttendanceProcessor::reportPath($name);
                if (is_file($path)) {
                    $outputs[$name] = ['bytes' => filesize($path), 'sha256' => hash_file('sha256', $path)];
                }
            }
            AuditLogger::record('report.payroll_generated', [
                'category' => 'report', 'action' => 'generate',
                'description' => "Generated payroll report for {$start} to {$end}",
                'metadata' => [
                    'period_start' => $start,
                    'period_end' => $end,
                    'outputs' => $outputs,
                    'imports' => $stats['imports'] ?? [],
                    'missing_dates' => $stats['missing_dates'] ?? [],
                    'security_guards' => $stats['security_guards'] ?? 0,
                ],
            ]);

            return response()->json([
                'message' => 'Report generated successfully',
                'stats'   => $stats,
                'period'          => $stats['period'] ?? null,
                'missing_dates'   => $stats['missing_dates'] ?? [],
                'imports'         => $stats['imports'] ?? [],
                'security_guards' => $stats['security_guards'] ?? 0,
            ], 200);

        } catch (\Throwable $e) {
            AuditLogger::record('report.payroll_generated', [
                'category' => 'report', 'action' => 'generate', 'outcome' => 'failure',
                'description' => "Payroll report for {$start} to {$end} failed: ".$e->getMessage(),
                'metadata' => ['period_start' => $start, 'period_end' => $end, 'error' => $e->getMessage()],
            ]);
            Log::error('Report generation error: ' . $e->getMessage());
            return response()->json(['error' => 'Report generation failed: ' . $e->getMessage()], 500);
        }
    }

    public function importCSV(Request $request)
    {
        // Validate the request
        $v = $request->validate([
            'biometric_imports_id' => 'required_without:period_start|nullable|integer',
            'period_start'         => 'nullable|date|required_with:period_end',
            'period_end'           => 'nullable|date|required_with:period_start|after_or_equal:period_start',
        ]);

        // Without an explicit period (upload page), fall back to the import's own period.
        if (!empty($v['period_start'])) {
            $periodStart = \Carbon\Carbon::parse($v['period_start'])->toDateString();
            $periodEnd   = \Carbon\Carbon::parse($v['period_end'])->toDateString();
        } else {
            $batch       = BiometricHistoryList::find($v['biometric_imports_id']);
            $periodStart = $batch && $batch->period_start ? substr($batch->period_start, 0, 10) : null;
            $periodEnd   = $batch && $batch->period_end ? substr($batch->period_end, 0, 10) : null;
        }

        // Get the current date
        $dates = now()->toDateString();

        // Re-generating a payroll period replaces its earlier payroll data. Rows saved
        // before periods were recorded are still cleared per entry date, as before.
        Csvimport::where(function ($q) use ($periodStart, $periodEnd) {
            $q->whereNotNull('period_start')
                ->where('period_start', $periodStart)->where('period_end', $periodEnd);
        })->orWhere(function ($q) use ($dates) {
            $q->whereNull('period_start')->where('entry_date', $dates);
        })->delete();

        // Path to the .csv file
        $path = AttendanceProcessor::reportPath('payroll file.csv');

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
                'biometric_imports_id' => $v['biometric_imports_id'] ?? null,
                'period_start' => $periodStart,
                'period_end' => $periodEnd,
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
            $loaded = ($loaded ?? 0) + 1;
        }

        AuditLogger::record('payroll.loaded', [
            'category' => 'report', 'action' => 'import',
            'description' => 'Loaded '.($loaded ?? 0)." payroll rows for {$periodStart} to {$periodEnd}",
            'metadata' => [
                'rows' => $loaded ?? 0,
                'period_start' => $periodStart,
                'period_end' => $periodEnd,
                'biometric_imports_id' => $v['biometric_imports_id'] ?? null,
                'source_sha256' => is_file($path) ? hash_file('sha256', $path) : null,
            ],
        ]);

        return response()->json([
            'message' => 'CSV imported successfully.',
            'id' => $v['biometric_imports_id'] ?? null,
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
        // Only the payroll period that was just generated, when one is given
        $records = $request->filled(['period_start', 'period_end'])
            ? Csvimport::where('period_start', $request->period_start)
                ->where('period_end', $request->period_end)->get()
            : Csvimport::all();

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

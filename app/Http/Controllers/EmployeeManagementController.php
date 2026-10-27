<?php

namespace App\Http\Controllers;

use App\Services\AuditLogger;
use App\Models\EmployeeManagement;
use App\Models\Department;
use Yajra\DataTables\Facades\DataTables;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Concerns\FromCollection;
use PhpOffice\PhpSpreadsheet\IOFactory;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\QueryException;

class EmployeeManagementController extends Controller
{

    public function import(Request $request)
    {
        $request->validate([
            'file' => 'required|mimes:csv,txt'
        ]);

        $path = $request->file('file')->getRealPath();

        // Open CSV with UTF-8 conversion
        $rows = [];
        if (($handle = fopen($path, 'r')) !== false) {
            while (($data = fgetcsv($handle, 1000, ',')) !== false) {
                // Convert each field to UTF-8
                $data = array_map(function($value) {
                    // Skip empty values
                    if ($value === null) return null;

                    // Convert to UTF-8
                    return mb_convert_encoding($value, 'UTF-8', 'auto');
                }, $data);

                $rows[] = $data;
            }
            fclose($handle);
        }

        if (count($rows) <= 1) {
            return response()->json([
                'success' => false,
                'message' => 'CSV file is empty or has no data.'
            ]);
        }

        // Unique IDs must be unique (DB index). Check before truncating so a bad file changes nothing.
        $idCounts = array_count_values(array_filter(
            array_map(fn ($row) => trim((string) ($row[0] ?? '')), array_slice($rows, 1)),
            fn ($id) => $id !== ''
        ));
        $duplicateIds = array_keys(array_filter($idCounts, fn ($count) => $count > 1));
        if ($duplicateIds) {
            return response()->json([
                'success' => false,
                'message' => 'The file has duplicate Unique IDs: '.implode(', ', $duplicateIds).'. Nothing was imported.',
            ], 422);
        }

        // Step 1: Truncate table
        $employeesBefore = DB::table('employee_management')->count();
        DB::table('employee_management')->truncate();

        // Step 2: Insert rows (skip header)
        $data = [];
        foreach ($rows as $i => $row) {
            if ($i === 0) continue; // skip header

            // Skip if unique_id is empty
            if (empty($row[0])) continue;

            $data[] = [
                'unique_id'     => trim($row[0]),
                'employee_name' => isset($row[1]) ? trim($row[1]) : null,
                'basic_salary'  => isset($row[2]) ? trim($row[2]) : null,
                'schedule' => isset($row[3]) ? str_replace('a', '', trim($row[3])) : null,
                'report_to'  => isset($row[4]) ? trim($row[4]) : null,
                'department' => isset($row[5]) ? strtoupper(trim($row[5])) : null,
                'status'  => isset($row[6]) ? trim($row[6]) : null
            ];
        }

        if (!empty($data)) {
            EmployeeManagement::insert($data);
        }

        AuditLogger::record('import.employees_replaced', [
            'category' => 'import', 'action' => 'import',
            'description' => "Replaced the employee master list from {$request->file('file')->getClientOriginalName()}: "
                ."{$employeesBefore} employees removed, ".DB::table('employee_management')->count().' imported',
            'metadata' => [
                'file' => $request->file('file')->getClientOriginalName(),
                'bytes' => $request->file('file')->getSize(),
                'sha256' => hash_file('sha256', $path),
                'employees_before' => $employeesBefore,
                'employees_after' => DB::table('employee_management')->count(),
            ],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'CSV data imported successfully!'
        ]);
    }


    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */

     public function fetchs()
     {
         $EmployeeManagement = EmployeeManagement::orderBy('employee_name', 'asc')->get();

         return response()->json($EmployeeManagement);
     }

    public function index(Request $request)
    {
        if ($request->ajax()) {
            \Log::info('Ajax request data:', $request->all());

            $userRole   = $request->get('userRole');
            $department = $request->get('department');

            // Base query
            $data = EmployeeManagement::select([
                'id',
                'unique_id',
                'employee_name',
                'basic_salary',
                'department',
                'report_to',
                'schedule',
                'status',
            ]);

            // Fixed order only when the table asks for none; otherwise DataTables applies the clicked column
            if (!$request->filled('order')) {
                $data->orderBy('unique_id', 'asc');
            }

            // Apply department filter only if userRole is not admin
            if ($userRole !== 'admin' && $department) {
                $data->where('department', $department);
            }

            return DataTables::of($data)->make(true);
        }

        return view('employees.fetch');
    }


    public function fetchEmployeeName(Request $request)
    {
        $userRole = $request->get('userRole');
        $department = $request->get('department');
        // Get distinct unique_id values
        $uniqueIds = EmployeeManagement::select('id','unique_id', 'employee_name', 'basic_salary', 'department', 'report_to', 'schedule')
            ->distinct()
            ->when($userRole === 'user' && $department, function ($query) use ($department) {
                    $query->where('department', $department);
                })
            ->orderBy('employee_name', 'asc')
            ->get();

        return response()->json($uniqueIds);
    }
    // public function edit($id)
    // {
    //     // Fetch the employee by ID
    //     $employee = EmployeeManagement::findOrFail($id);

    //     // Return the employee details as JSON
    //     return response()->json($employee);
    // }

    public function edit($id)
    {
        $employee = EmployeeManagement::join('departments', 'employee_management.department', '=', 'departments.department_name')
            ->select(
                'employee_management.*',
                'departments.id as department_id'
            )
            ->where('employee_management.id', $id)
            ->firstOrFail();

        return response()->json($employee);
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
    // public function store(Request $request)
    // {
    //     // Validate the incoming request data
    //     $request->validate([
    //         'employeeAddUniqueId' => [
    //             'required',
    //             'string',
    //             'max:255',
    //             'unique:employee_management,unique_id',
    //         ],
    //         'employeeAddName' => [
    //             'required',
    //             'string',
    //             'max:255',
    //             'unique:employee_management,employee_name',
    //         ],
    //         'basicAddSalary' => 'required|numeric',
    //     ], [
    //         'employeeAddUniqueId.unique' => 'Unique ID already exists.',
    //         'employeeAddName.unique' => 'Employee name already exists.',
    //     ]);

    //     // Create a new employee record
    //     $employee = EmployeeManagement::create([
    //         'unique_id' => $request->employeeAddUniqueId,
    //         'employee_name' => $request->employeeAddName,
    //         'basic_salary' => $request->basicAddSalary,
    //     ]);

    //     // Append data to the CSV file
    //     $filePath = storage_path('app/public/python/BiometricAttendanceInfo.csv');
    //     $csvFile = fopen($filePath, 'a'); // Open in append mode

    //     if ($csvFile !== false) {
    //         // Write the data as a new row
    //         fputcsv($csvFile, [
    //             $employee->unique_id,
    //             $employee->employee_name,
    //             $employee->basic_salary,
    //         ]);
    //         fclose($csvFile); // Close the file
    //     } else {
    //         return response()->json(['message' => 'Employee added, but failed to update CSV.'], 500);
    //     }

    //     return response()->json(['message' => 'Employee added successfully.']);
    // }

    /** An employee name as stored everywhere: "LAST, FIRST" in uppercase. */
    private function formatEmployeeName(?string $lastName, ?string $firstName): string
    {
        $clean = fn (?string $part) => mb_strtoupper(trim((string) $part));

        return $clean($lastName) . ', ' . $clean($firstName);
    }

    public function store(Request $request)
    {
        // Stored as "LAST, FIRST" in uppercase, the format biometric files are matched against
        $employeeName = $this->formatEmployeeName($request->employeeAddLastName, $request->employeeAddFirstName);

        // Validate the incoming request data
        $request->validate([
            'employeeAddUniqueId' => 'required|string|max:255',
            'employeeAddFirstName' => 'required|string|max:255',
            'employeeAddLastName' => 'required|string|max:255',
            'employeeAddImmediateSupervisor' => 'required|string|max:255',
            'employeeAddSchedule' => $this->scheduleRules(),
            'basicAddSalary' => 'required|numeric',
        ], [
            'employeeAddSchedule.regex' => 'Work schedule must be whole hours, e.g. 7-16 or 19-7.',
        ]);

        $uniqueId = trim($request->employeeAddUniqueId);
        $department = $request->employeeAddDepartment ?? null;

        // A Unique ID already held by someone is only taken if they get a new one in the same request
        $holder = $this->uniqueIdHolder($uniqueId);
        $holderNewUniqueId = null;

        if ($holder) {
            if ((int) $request->input('conflict_employee_id') !== $holder->id) {
                return $this->uniqueIdConflictResponse($holder, $uniqueId, $department);
            }

            $holderNewUniqueId = trim((string) $request->input('conflict_new_unique_id'));
            if ($error = $this->holderReassignmentError($holder, $holderNewUniqueId, $uniqueId, $holder->id)) {
                return response()->json(['message' => $error, 'errors' => ['conflict_new_unique_id' => [$error]]], 422);
            }
        }

        try {
            $employee = DB::transaction(function () use ($request, $uniqueId, $employeeName, $department, $holder, $holderNewUniqueId) {
                if ($holder) {
                    $holder->unique_id = $holderNewUniqueId;
                    $holder->save();
                    $this->syncOvertimeUniqueIds($holder);
                }

                // Create a new employee record
                return EmployeeManagement::create([
                    'unique_id' => $uniqueId,
                    'employee_name' => $employeeName, // "LAST, FIRST"
                    'basic_salary' => $request->basicAddSalary,
                    'department' => $department,
                    'schedule' => $request->employeeAddSchedule,
                    'report_to' => $request->employeeAddImmediateSupervisor,
                    'status' => $request->employeeAddStatus
                ]);
            });
        } catch (QueryException $e) {
            // Someone else saved the same ID (e.g. the same suggestion) after the check above
            if ($e->getCode() === '23505' && ($taken = $this->uniqueIdHolder($uniqueId))) {
                return $this->uniqueIdConflictResponse($taken, $uniqueId, $department);
            }
            throw $e;
        }

        if ($holder) {
            $this->syncCsvMirror([$uniqueId => [0 => $holder->unique_id]]);
        }

        // Append data to the CSV file
        $filePath = storage_path('app/public/python/BiometricAttendanceInfo.csv');
        $csvFile = fopen($filePath, 'a'); // Open in append mode

        if ($csvFile !== false) {
            // Write the data as a new row
            fputcsv($csvFile, [
                $employee->unique_id,
                $employee->employee_name,
                $employee->basic_salary,
                $employee->schedule,
                $employee->report_to,
                $employee->department,
            ]);
            fclose($csvFile); // Close the file
        } else {
            return response()->json(['message' => 'Employee added, but failed to update CSV.'], 500);
        }

        return response()->json(['message' => 'Employee added successfully.']);
    }


    /**
     * Display the specified resource.
     *
     * @param  \App\Models\EmployeeManagement  $employeeManagement
     * @return \Illuminate\Http\Response
     */
    public function show(EmployeeManagement $employeeManagement)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\EmployeeManagement  $employeeManagement
     * @return \Illuminate\Http\Response
     */

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\EmployeeManagement  $employeeManagement
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        // Validate the incoming request data
        $request->validate([
            'unique_id' => 'required|string|max:255',
            'employee_name' => 'required|string|max:255',
            'basic_salary' => 'required|numeric',
            'schedule' => $this->scheduleRules(),
        ], [
            'schedule.regex' => 'Work schedule must be whole hours, e.g. 7-16 or 19-7.',
        ]);

        // Fetch the employee by ID
        $employee = EmployeeManagement::findOrFail($id);
        $oldUniqueId = $employee->unique_id;
        $newUniqueId = trim($request->input('unique_id'));

        // Only enforce the duplicate-name check if the name input actually changed
        // from what's already on file — resubmitting an unchanged form shouldn't error.
        // The form sends "Last, First"; store it uppercase like every other name
        $newName = mb_strtoupper(trim($request->input('employee_name')));

        if ($newName !== $employee->employee_name) {
            $existingEmployee = EmployeeManagement::where('employee_name', $newName)
                ->where('id', '<>', $id) // Exclude the current employee
                ->first();

            if ($existingEmployee) {
                return response()->json(['message' => 'Employee name already exists. Update failed.'], 409); // Conflict status code
            }
        }

        // A Unique ID already held by another employee is only taken if that employee gets a new
        // one in the same request (a swap by default), so two employees never share an ID.
        $holder = $newUniqueId !== $oldUniqueId ? $this->uniqueIdHolder($newUniqueId, $employee->id) : null;
        $holderNewUniqueId = null;

        if ($holder) {
            if ((int) $request->input('conflict_employee_id') !== $holder->id) {
                return $this->uniqueIdConflictResponse($holder, $newUniqueId);
            }

            // The edited employee's old ID is free once this saves, so it isn't a conflict (that's the swap)
            $holderNewUniqueId = trim((string) $request->input('conflict_new_unique_id'));
            if ($error = $this->holderReassignmentError($holder, $holderNewUniqueId, $newUniqueId, $employee->id, $holder->id)) {
                return response()->json(['message' => $error, 'errors' => ['conflict_new_unique_id' => [$error]]], 422);
            }
        }

        DB::transaction(function () use ($request, $employee, $newUniqueId, $newName, $holder, $holderNewUniqueId) {
            if ($holder) {
                // Free the ID first so the unique index allows a swap. A query-builder update keeps
                // the placeholder out of the audit log; the save below records the real change.
                DB::table('employee_management')->where('id', $holder->id)->update(['unique_id' => '__tmp_'.$holder->id]);
            }

            // Update the employee's details
            $employee->unique_id = $newUniqueId;
            $employee->employee_name = $newName;
            $employee->basic_salary = $request->input('basic_salary');
            $employee->department = $request->input('department');
            $employee->report_to = $request->input('report_to');
            $employee->schedule = $request->input('schedule');
            $employee->status = $request->input('status');
            $employee->save(); // Save the updated employee details

            if ($holder) {
                $holder->unique_id = $holderNewUniqueId;
                $holder->save();
            }

            $this->syncOvertimeUniqueIds(...array_filter([$employee, $holder]));
        });

        // Rows are matched by the Unique ID they had before this update
        $csvChanges = [$oldUniqueId => [0 => $employee->unique_id, 1 => $employee->employee_name, 2 => $employee->basic_salary]];
        if ($holder) {
            $csvChanges[$newUniqueId] = [0 => $holder->unique_id];
        }
        $this->syncCsvMirror($csvChanges);

        // Return a success response
        return response()->json(['message' => 'Employee updated successfully', 'employee' => $employee]);
    }

    /**
     * Who already has a Unique ID, for the Add and Edit forms' warning before they save.
     */
    public function checkUniqueId(Request $request)
    {
        $request->validate([
            'unique_id' => 'required|string|max:255',
            'exclude_id' => 'nullable|integer',
        ]);

        $holder = $this->uniqueIdHolder(trim($request->input('unique_id')), (int) $request->input('exclude_id'));

        return response()->json([
            'conflict' => (bool) $holder,
            'employee' => $holder?->only(['id', 'unique_id', 'employee_name', 'department', 'status']),
        ]);
    }

    /** The employee holding $uniqueId, other than the ids in $excludeIds. */
    private function uniqueIdHolder(string $uniqueId, int ...$excludeIds): ?EmployeeManagement
    {
        return EmployeeManagement::where('unique_id', $uniqueId)->whereNotIn('id', $excludeIds)->first();
    }

    /**
     * The next ID in the sequence: SC-<batch>-NNN for Security, otherwise TMNG-<YYYYMM>-NNN
     * where NNN is one running number across all months.
     */
    private function nextUniqueId(?string $department): string
    {
        if (mb_strtoupper(trim((string) $department)) === 'SECURITY') {
            $last = EmployeeManagement::where('unique_id', '~', '^SC-\d+-\d+$')
                ->orderByRaw("split_part(unique_id, '-', 3)::int DESC")
                ->value('unique_id');
            $prefix = 'SC-'.($last ? explode('-', $last)[1] : now()->format('Y').'001').'-';
            $number = $last ? (int) explode('-', $last)[2] : 0;
        } else {
            $prefix = 'TMNG-'.now()->format('Ym').'-';
            $number = (int) EmployeeManagement::where('unique_id', '~', '^TMNG-\d{6}-\d+$')
                ->max(DB::raw("split_part(unique_id, '-', 3)::int"));
        }

        do {
            $candidate = $prefix.str_pad((string) ++$number, 3, '0', STR_PAD_LEFT);
        } while ($this->uniqueIdHolder($candidate));

        return $candidate;
    }

    /**
     * The next Unique ID for the Add Employee form.
     */
    public function suggestUniqueId(Request $request)
    {
        return response()->json(['unique_id' => $this->nextUniqueId($request->input('department'))]);
    }

    /** 409 naming who holds $uniqueId, so the form can ask for a new ID for them. */
    private function uniqueIdConflictResponse(EmployeeManagement $holder, string $uniqueId, ?string $department = null)
    {
        return response()->json([
            'code' => 'unique_id_taken',
            'message' => "Unique ID {$uniqueId} is already used by {$holder->employee_name}.",
            'employee' => $holder->only(['id', 'unique_id', 'employee_name', 'department', 'status']),
            'suggested' => $this->nextUniqueId($department ?? $holder->department),
        ], 409);
    }

    /** Why $holder can't move to $newId (null when it can). $excludeIds are freed by the same save. */
    private function holderReassignmentError(EmployeeManagement $holder, string $newId, string $takenId, int ...$excludeIds): ?string
    {
        $thirdHolder = $newId !== '' ? $this->uniqueIdHolder($newId, ...$excludeIds) : null;

        return match (true) {
            $newId === '' => "Enter a new Unique ID for {$holder->employee_name}.",
            mb_strlen($newId) > 255 => 'Unique ID may not be longer than 255 characters.',
            $newId === $takenId => "{$holder->employee_name} needs a different Unique ID than {$takenId}.",
            $thirdHolder !== null => "Unique ID {$newId} is already used by {$thirdHolder->employee_name}.",
            default => null,
        };
    }

    /**
     * Overtime rows keep a copy of the Unique ID; keep it in step. csvimports is the record of
     * what was paid and is left as it was.
     */
    private function syncOvertimeUniqueIds(EmployeeManagement ...$employees): void
    {
        foreach ($employees as $employee) {
            if ($employee->wasChanged('unique_id')) {
                DB::table('overtimes')->where('employee_management_id', $employee->id)->update(['unique_id' => $employee->unique_id]);
            }
        }
    }

    /**
     * Sync the legacy CSV mirror if it exists. $changes maps a row's current Unique ID to the
     * columns to overwrite. The database is the source of truth, so a missing/unavailable CSV
     * should not fail the request.
     */
    private function syncCsvMirror(array $changes): void
    {
        $filePath = storage_path('app/public/python/BiometricAttendanceInfo.csv');
        $tempFilePath = storage_path('app/public/python/temp.csv'); // Temporary file for updating

        if (!file_exists($filePath)) {
            return;
        }

        $updated = false;

        if (($csvFile = fopen($filePath, 'r')) !== false && ($tempFile = fopen($tempFilePath, 'w')) !== false) {
            while (($data = fgetcsv($csvFile)) !== false) {
                if (isset($data[0], $changes[$data[0]])) {
                    // Update the row with the new values
                    $data = array_replace($data, $changes[$data[0]]);
                    $updated = true;
                }
                // Write the (possibly updated) row to the temp file
                fputcsv($tempFile, $data);
            }

            fclose($csvFile);
            fclose($tempFile);

            // Replace the original file with the updated file
            if ($updated) {
                rename($tempFilePath, $filePath);
            } else {
                // If no update occurred, remove the temporary file
                unlink($tempFilePath);
            }
        }
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\EmployeeManagement  $employeeManagement
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        // Find the employee by database ID
        $employee = EmployeeManagement::find($id);

        if (!$employee) {
            return response()->json(['message' => 'Employee not found.'], 404);
        }

        // Store the unique_id for CSV deletion
        $unique_id = $employee->unique_id;

        // Delete the employee record from the database. Employees with attendance, overtime,
        // leave or schedule history are protected by foreign keys (ON DELETE RESTRICT).
        try {
            $employee->delete();
        } catch (QueryException $e) {
            if ($e->getCode() === '23503') {
                return response()->json([
                    'message' => 'Cannot delete this employee: they have attendance, overtime, leave or schedule records.',
                ], 422);
            }
            throw $e;
        }

        // Sync the legacy CSV mirror if it exists. The database is the source of
        // truth, so a missing/unavailable CSV should not fail the delete.
        $filePath = storage_path('app/public/python/BiometricAttendanceInfo.csv');

        if (file_exists($filePath)) {
            // Read all rows from the CSV file
            $rows = [];
            if (($csvFile = fopen($filePath, 'r')) !== false) {
                while (($row = fgetcsv($csvFile)) !== false) {
                    // Only keep rows that don't match the unique_id to be deleted
                    if ($row[0] != $unique_id) {
                        $rows[] = $row;
                    }
                }
                fclose($csvFile);

                // Write the filtered data back to the CSV file
                $csvFile = fopen($filePath, 'w');
                if ($csvFile !== false) {
                    foreach ($rows as $row) {
                        fputcsv($csvFile, $row);
                    }
                    fclose($csvFile);
                }
            }
        }

        return response()->json(['message' => 'Employee deleted successfully.']);
    }

    /**
     * Export all employee data from database to BiometricAttendanceInfo.csv
     *
     * @return \Illuminate\Http\Response
     */
    public function exportToCsv()
    {
        try {
            // Get all employees from database
            $employees = EmployeeManagement::orderBy('unique_id', 'asc')->get();

            // Path to the CSV file
            $filePath = storage_path('app/public/python/BiometricAttendanceInfo.csv');

            // Create/overwrite the CSV file
            $csvFile = fopen($filePath, 'w');

            if ($csvFile === false) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to create CSV file.'
                ], 500);
            }

            // Write header row
            fputcsv($csvFile, ['ID', 'Name', 'Basic', 'Schedule', 'Report To', 'Department']);

            // Write data rows
            foreach ($employees as $employee) {
                fputcsv($csvFile, [
                    $employee->unique_id,
                    $employee->employee_name,
                    $employee->basic_salary,
                    $employee->schedule ?? '7-4',
                    $employee->report_to,
                    $employee->department
                ]);
            }

            fclose($csvFile);

            AuditLogger::record('access.employees_exported', [
                'category' => 'access', 'action' => 'export',
                'description' => 'Exported '.$employees->count().' employees to BiometricAttendanceInfo.csv',
                'metadata' => ['count' => $employees->count(), 'sha256' => hash_file('sha256', $filePath)],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'CSV file updated successfully with ' . $employees->count() . ' employees.',
                'count' => $employees->count()
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error updating CSV file: ' . $e->getMessage()
            ], 500);
        }
    }


    /**
     * Work schedule must stay in the "{startHour}-{endHour}" format the overtime
     * formula reads (ComputationService / AttendanceProcessor), e.g. "7-16", "19-7", "15-24".
     */
    private function scheduleRules(): array
    {
        return [
            'required',
            'regex:/^([0-9]|1[0-9]|2[0-4])-([0-9]|1[0-9]|2[0-4])$/',
            function ($attribute, $value, $fail) {
                [$start, $end] = array_pad(explode('-', (string) $value), 2, null);
                if ($start !== null && (int) $start % 24 === (int) $end % 24) {
                    $fail('Work schedule start and end time must be different.');
                }
            },
        ];
    }
}

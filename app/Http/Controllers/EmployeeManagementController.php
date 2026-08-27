<?php

namespace App\Http\Controllers;

use App\Models\EmployeeManagement;
use App\Models\Department;
use Yajra\DataTables\Facades\DataTables;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Concerns\FromCollection;
use PhpOffice\PhpSpreadsheet\IOFactory;
use Illuminate\Support\Facades\DB;

class EmployeeManagementController extends Controller
{

    public function showImportForm()
    {
        return view('employee_management.import');
    }

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

        // Step 1: Truncate table
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
            ])->orderBy('unique_id', 'asc');

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

    public function store(Request $request)
    {
        // Combine first and last name into the required format "FirstName, LastName"
        $employeeName = $request->employeeAddFirstName . ', ' . $request->employeeAddLastName;

        // Validate the incoming request data
        $request->validate([
            'employeeAddUniqueId' => [
                'required',
                'string',
                'max:255',
                'unique:employee_management,unique_id',
            ],
            'employeeAddFirstName' => 'required|string|max:255',
            'employeeAddLastName' => 'required|string|max:255',
            'employeeAddImmediateSupervisor' => 'required|string|max:255',
            'employeeAddSchedule' => 'required|string|max:255',
            'basicAddSalary' => 'required|numeric',
        ], [
            'employeeAddUniqueId.unique' => 'Unique ID already exists.',
        ]);

        // Create a new employee record
        $employee = EmployeeManagement::create([
            'unique_id' => $request->employeeAddUniqueId,
            'employee_name' => $employeeName, // Store as "FirstName, LastName"
            'basic_salary' => $request->basicAddSalary,
            'department' => $request->employeeAddDepartment ?? null, // Optional if your DB has this field
            'schedule' => $request->employeeAddSchedule,
            'report_to' => $request->employeeAddImmediateSupervisor,
            'status' => $request->employeeAddStatus
        ]);

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
        ]);

        // Fetch the employee by ID
        $employee = EmployeeManagement::findOrFail($id);

        // Check if the new employee name already exists for another employee
        $existingEmployee = EmployeeManagement::where('employee_name', $request->input('employee_name'))
            ->where('id', '<>', $id) // Exclude the current employee
            ->first();

        if ($existingEmployee) {
            return response()->json(['message' => 'Employee name already exists. Update failed.'], 409); // Conflict status code
        }

        // Update the employee's details
        $employee->unique_id = $request->input('unique_id');
        $employee->employee_name = $request->input('employee_name');
        $employee->basic_salary = $request->input('basic_salary');
        $employee->department = $request->input('department');
        $employee->report_to = $request->input('report_to');
        $employee->schedule = $request->input('schedule');
        $employee->status = $request->input('status');
        $employee->save(); // Save the updated employee details

        // Update the CSV file
        $filePath = storage_path('app/public/python/BiometricAttendanceInfo.csv');
        $tempFilePath = storage_path('app/public/python/temp.csv'); // Temporary file for updating

        $updated = false;

        // Open the original CSV and a temporary file
        if (($csvFile = fopen($filePath, 'r')) !== false && ($tempFile = fopen($tempFilePath, 'w')) !== false) {
            while (($data = fgetcsv($csvFile)) !== false) {
                // Check if the unique_id matches
                if ($data[0] === $employee->unique_id) {
                    // Update the row with the new values
                    $data[1] = $employee->employee_name;
                    $data[2] = $employee->basic_salary;
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
        } else {
            return response()->json(['message' => 'Employee updated, but failed to update CSV.'], 500);
        }
        // Return a success response
        return response()->json(['message' => 'Employee updated successfully', 'employee' => $employee]);
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

        // Delete the employee record from the database
        $employee->delete();

        // Path to the CSV file
        $filePath = storage_path('app/public/python/BiometricAttendanceInfo.csv');

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
        } else {
            return response()->json(['message' => 'Failed to open CSV file.'], 500);
        }

        // Write the filtered data back to the CSV file
        $csvFile = fopen($filePath, 'w');
        if ($csvFile !== false) {
            foreach ($rows as $row) {
                fputcsv($csvFile, $row);
            }
            fclose($csvFile);
        } else {
            return response()->json(['message' => 'Failed to write to CSV file.'], 500);
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

}

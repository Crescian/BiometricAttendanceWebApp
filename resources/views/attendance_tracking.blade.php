<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight transition duration-300 ease-in-out transform hover:scale-105 hover:text-orange-600">
            {{ __('') }}
        </h2>
    </x-slot>

    <div class="py-12 bg-gray-100 min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white shadow-lg rounded-lg overflow-hidden">
                <div class="p-6 text-gray-900">
                    <div class="flex justify-between items-center mb-6">
                        <h1 class="text-4xl font-semibold text-gray-800">Attendance Tracking</h1>
                        <button x-data @click.prevent="$dispatch('open-modal', 'add-employee')"
                            class="px-4 py-2 text-white bg-green-600 rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2">
                            Add
                        </button>
                    </div>
                    <div class="relative overflow-x-auto shadow-md rounded-lg">
                        <table id="employeeTable" class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th
                                        class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Unique Id</th>
                                    <th
                                        class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Name</th>
                                    <th
                                        class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Basic Salary</th>
                                    <th
                                        class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Action</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
                                <!-- Table body will be populated by DataTables -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Employee Modal -->
    <x-modal name="add-employee" focusable>
        <div class="p-6">
            <h2 class="text-lg font-medium text-gray-900">Add Employee</h2>
            <div class="mt-4">
                <label for="employeeAddUniqueId" class="block text-sm font-medium text-gray-700">Unique ID</label>
                <input type="text" id="employeeAddUniqueId" name="unique_id"
                    class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm focus:border-blue-500 focus:ring-blue-500">
            </div>
            <div class="mt-4">
                <label for="employeeAddName" class="block text-sm font-medium text-gray-700">Name</label>
                <input type="text" id="employeeAddName" name="employee_name"
                    class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm focus:border-blue-500 focus:ring-blue-500">
            </div>
            <div class="mt-4">
                <label for="basicAddSalary" class="block text-sm font-medium text-gray-700">Basic Salary</label>
                <input type="text" id="basicAddSalary" name="basic_salary"
                    class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm focus:border-blue-500 focus:ring-blue-500">
            </div>
            <div class="flex justify-end mt-6">
                <button type="button" x-on:click="$dispatch('close')"
                    class="py-2.5 px-5 me-2 mb-2 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100">Cancel</button>
                <button type="submit" x-on:click="$dispatch('close')" onclick="addEmployee();"
                    class="py-2.5 px-5 text-sm font-medium text-white bg-green-600 rounded-lg hover:bg-green-700">Add
                    Employee</button>
            </div>
        </div>
    </x-modal>
</x-app-layout>

<link rel="stylesheet" href="https://cdn.datatables.net/2.1.8/css/dataTables.dataTables.min.css">
<script src="https://cdn.datatables.net/2.1.8/js/dataTables.min.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
            $('#employeeTable').DataTable({
                processing: true,
                serverSide: true,
                // ajax: "{{ route('employees.fetch') }}",
                columns: [{
                        data: 'unique_id',
                        name: 'unique_id',
                        className: 'px-6 py-4 text-sm text-gray-700'
                    },
                    {
                        data: 'employee_name',
                        name: 'employee_name',
                        className: 'px-6 py-4 text-sm text-gray-700'
                    },
                    {
                        data: 'basic_salary',
                        name: 'basic_salary',
                        className: 'px-6 py-4 text-sm text-gray-700'
                    },
                    {
                        orderable: false,
                        searchable: false,
                        className: 'px-6 py-4 text-center',
                        render: function(data, type, row) {
                            return `
                            <button x-data
                                @click.prevent="$dispatch('open-modal', 'confirm-user-clock-in')"
                                class="px-4 py-2 text-white bg-blue-600 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                                onclick="editFunction(${row.id});">Edit</button>

                            <button
                                class="px-4 py-2 text-white bg-red-600 rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2"
                                onclick="deleteEmployee(${row.id});">Delete</button>
                        `;
                        }
                    }
                ],
                responsive: true,
                language: {
                    search: "_INPUT_",
                    searchPlaceholder: "Search employees..."
                }
            });
        });
</script>

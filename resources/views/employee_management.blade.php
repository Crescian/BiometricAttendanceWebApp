<x-app-layout>

    <!-- Table Section inside Card -->
    <div class="p-6 mt-5">
        <div class="bg-white shadow-lg rounded-lg border border-gray-200">
            <!-- Card Header -->
            <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
                <h2 class="font-bold text-3xl">
                    <i class="fa-regular fa-clone" style="color: #8DE11A; font-size: 40px"></i>
                    {{ __('Employee Management') }}
                </h2>
                <button x-data @click.prevent="$dispatch('open-modal', 'add-employee')"
                    class="flex items-center px-4 py-2 bg-white text-green-600 font-semibold rounded-lg shadow-sm border border-green-600">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
                    </svg>
                    Add
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 ml-2" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
                    </svg>
                </button>
            </div>

            <!-- Table Section -->
            <div class="p-6 text-gray-900">
                <div id="overtime-table-container" class="border rounded-lg shadow-sm">
                    <div id="pagination" class="flex items-center justify-center my-4 space-x-4"></div>
                    <table id="employeeTable" class="min-w-full table-auto">
                        <thead class="text-white text-sm sticky top-0" style="background-color: #00291B;">
                            <tr>
                                <th class="px-4 py-2 text-white font-bold">Unique ID</th>
                                <th class="px-4 py-2 text-white">Employee Name</th>
                                <th class="px-4 py-2 text-white">Department</th>
                                <th class="px-4 py-2 text-white">Supervisor</th>
                                <th class="px-4 py-2 text-white">Schedule</th>
                                <th class="px-4 py-2 text-white">Basic Salary</th>
                                <th class="px-4 py-2 text-white">Status</th>
                                <th class="px-4 py-2 text-white text-center">Action</th>
                            </tr>
                        </thead>
                        <tbody id="overtime-body" class="text-sm text-gray-800 divide-y divide-gray-200">
                            <!-- Data will be injected here -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Employee Modal -->
    <x-modal name="edit-employee" focusable>
        <div class="p-8 bg-white rounded-xl">
            <div class="mb-6">
                <h2 class="text-2xl font-bold text-gray-900 mb-2">Edit Employee</h2>
                <p class="text-gray-600">Update employee information and details</p>
            </div>

            <div class="space-y-6">
                <!-- Schedule -->
                <div>
                    <label for="schedule" class="block text-sm font-semibold text-gray-700 mb-2">
                        Work Schedule
                    </label>
                    <select id="schedule" name="schedule"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                        <option value="" disabled selected class="text-gray-400">Select schedule</option>
                    </select>
                </div>

                <!-- Unique ID -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Unique ID</label>
                    <input id="employeeUniqueId" type="text"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50 text-gray-600" readonly>
                </div>

                <!-- Name Fields -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-2">First Name</label>
                        <input id="employeeFirstName" type="text"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Last Name</label>
                        <input id="employeeLastName" type="text"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                    </div>
                </div>

                <!-- Department and Supervisor -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Department</label>
                        {{-- <input id="department" type="text"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200"> --}}

                        <select id="department" name="department"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                            <option value="" disabled selected class="text-gray-400">Select department</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Immediate Supervisor</label>
                        <input id="report_to" type="text"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                    </div>
                </div>

                <!-- Basic Salary -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Basic Salary</label>
                    <input id="basicSalary" type="text"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                </div>
                <!-- Status -->
                <div>
                    <label for="employeeEditStatus" class="block text-sm font-semibold text-gray-700 mb-2">
                        Status
                    </label>
                    <select id="employeeEditStatus" name="status"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                        <option value="" disabled selected class="text-gray-400">Select status</option>
                        <option value="Active">Active</option>
                        <option value="Not Active">Not Active</option>
                    </select>
                </div>
            </div>

            <!-- Modal Actions -->
            <div class="flex justify-end space-x-3 mt-8 pt-6 border-t border-gray-200">
                <button x-on:click="$dispatch('close')" type="button"
                    class="px-6 py-3 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200">
                    Cancel
                </button>
                <button type="button" x-on:click="$dispatch('close')"
                    class="px-6 py-3 text-white bg-gradient-to-r from-blue-600 to-blue-700 rounded-lg hover:from-blue-700 hover:to-blue-800 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transform transition-all duration-200 hover:scale-105"
                    onclick="updateFunction();">
                    Save Changes
                </button>
            </div>
        </div>
    </x-modal>

    <!-- Add Employee Modal -->
    <x-modal name="add-employee" focusable>
        <div class="p-8 bg-white rounded-xl">
            <div class="mb-6">
                <h2 class="text-2xl font-bold text-gray-900 mb-2">Add New Employee</h2>
                <p class="text-gray-600">Enter employee information to add to the system</p>
            </div>

            <div class="space-y-6">
                <!-- Schedule -->
                <div>
                    <label for="employeeAddSchedule" class="block text-sm font-semibold text-gray-700 mb-2">
                        Work Schedule
                    </label>
                    <select id="employeeAddSchedule" name="employeeAddSchedule"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                    </select>
                </div>

                <!-- Unique ID -->
                <div>
                    <label for="employeeAddUniqueId" class="block text-sm font-semibold text-gray-700 mb-2">Unique
                        ID</label>
                    <input type="text" id="employeeAddUniqueId" name="unique_id"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                </div>

                <!-- Name Fields -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label for="employeeAddFirstName" class="block text-sm font-semibold text-gray-700 mb-2">First
                            Name</label>
                        <input type="text" id="employeeAddFirstName" name="first_name"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                    </div>
                    <div>
                        <label for="employeeAddLastName" class="block text-sm font-semibold text-gray-700 mb-2">Last
                            Name</label>
                        <input type="text" id="employeeAddLastName" name="last_name"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                    </div>
                </div>

                <!-- Department and Supervisor -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label for="employeeAddDepartment"
                            class="block text-sm font-semibold text-gray-700 mb-2">Department</label>
                        {{-- <input type="text" id="employeeAddDepartment" name="department"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200"> --}}

                        <select id="employeeAddDepartment" name="employeeAddDepartment"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                            <option value="" disabled selected class="text-gray-400">Select department</option>
                        </select>
                    </div>
                    <div>
                        <label for="employeeAddImmediateSupervisor"
                            class="block text-sm font-semibold text-gray-700 mb-2">Immediate Supervisor</label>
                        <input type="text" id="employeeAddImmediateSupervisor" name="immediate_supervisor"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                    </div>
                </div>

                <!-- Basic Salary -->
                <div>
                    <label for="basicAddSalary" class="block text-sm font-semibold text-gray-700 mb-2">Basic
                        Salary</label>
                    <input type="text" id="basicAddSalary" name="basic_salary"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                </div>

                <!-- Status -->
                <div>
                    <label for="employeeAddStatus" class="block text-sm font-semibold text-gray-700 mb-2">
                        Status
                    </label>
                    <select id="employeeAddStatus" name="status"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                        <option value="" disabled selected class="text-gray-400">Select status</option>
                        <option value="Active">Active</option>
                        <option value="Not Active">Not Active</option>
                    </select>
                </div>

            </div>

            <!-- Modal Actions -->
            <div class="flex justify-end space-x-3 mt-8 pt-6 border-t border-gray-200">
                <button type="button" x-on:click="$dispatch('close')"
                    class="px-6 py-3 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200">
                    Cancel
                </button>
                <button type="submit" x-on:click="$dispatch('close')" onclick="addEmployee();"
                    class="px-6 py-3 text-white bg-gradient-to-r from-green-600 to-green-700 rounded-lg hover:from-green-700 hover:to-green-800 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transform transition-all duration-200 hover:scale-105">
                    Add Employee
                </button>
            </div>
        </div>
    </x-modal>
    <script>
        const userId = "{{ Auth::user()->id ?? '' }}";
        const userRole = "{{ Auth::user()->role ?? '' }}";
        loadEmployeeTable();
        loadSchedule();
        loadDepartment();
        let globalID;

        function loadDepartment() {
            $('#employeeAddDepartment').html(''); // Clear existing options
            $('#employeeAddDepartment').append('<option value="">Select Department...</option>');
            $('#department').html(''); // Clear existing options
            $('#department').append('<option value="">Select Department...</option>');
            $.ajax({
                url: "{{ route('department.fetch') }}",
                type: 'GET',
                success: function(response) {
                    response.data.forEach(function(dept) {
                        console.log(dept.id);
                        $('#employeeAddDepartment').append(
                            `<option value="${dept.department_name}">${dept.department_name}</option>`
                        );
                        $('#department').append(
                            `<option value="${dept.department_name}">${dept.department_name}</option>`
                        );
                    });
                },
            });
        }

        function loadSchedule() {
            // Load Schedule
            $('#employeeAddSchedule').html(''); // Clear existing options
            $('#employeeAddSchedule').append('<option value="">Select Schedule...</option>');
            $('#schedule').html(''); // Clear existing options
            $('#schedule').append('<option value="">Select Schedule...</option>');

            $.ajax({
                url: "{{ route('schedule.fetch') }}",
                type: 'GET',
                success: function(response) {
                    // Helper function: convert 24-hour number to 12-hour format
                    function format12Hour(hour24) {
                        let hour = parseInt(hour24);
                        let suffix = hour >= 12 ? 'PM' : 'AM';
                        hour = hour % 12;
                        if (hour === 0) hour = 12;
                        return hour + suffix;
                    }
                    response.forEach((item, index) => {
                        // Convert schedule_name (e.g., "8-15") to 12-hour format
                        let [from, to] = item.schedule_name.split('-');
                        let formattedTime = `${format12Hour(from)}-${format12Hour(to)}`;

                        $('#employeeAddSchedule').append(
                            `<option value="${item.schedule_name}">${formattedTime} ${item.schedule_type}</option>`
                        );
                        $('#schedule').append(
                            `<option value="${item.schedule_name}">${formattedTime} ${item.schedule_type}</option>`
                        );
                    });
                }
            });
        }

        function loadEmployeeTable() {
            // Destroy existing DataTable if already initialized
            if ($.fn.DataTable.isDataTable('#employeeTable')) {
                $('#employeeTable').DataTable().clear().destroy();
            }

            $.ajax({
                url: "{{ route('department.getUserDepartment') }}",
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    console.log("Department Data:", userRole); // 👈 add this line
                    let departmentName;
                    if (!data.success) {
                        departmentName = 'N/A';
                    } else {
                        departmentName = data.data.department_name;
                    }

                    setTimeout(() => {
                        let table = $('#employeeTable').DataTable({
                            // processing: true,
                            serverSide: true,
                            autoWidth: false,
                            responsive: true,
                            lengthChange: true, // only keep this
                            lengthMenu: [10, 20, 50], // page length options
                            pageLength: 50, // default rows per page
                            dom: '<"flex justify-between items-center mb-4"Bf>rt<"flex justify-between items-center mt-4"lip>',
                            ajax: {
                                url: "{{ route('employees.fetch') }}",
                                data: function(d) {
                                    d.userRole = userRole; // admin or user
                                    d.department = departmentName; // only applies for user
                                    console.log("Sending:", d); // 👈 add this line
                                }
                            },
                            buttons: [{
                                    extend: 'collection',
                                    text: '<i class="fa fa-download mr-1 text-green-600"></i> Export',
                                    className: 'flex items-center px-4 py-2 bg-white font-semibold rounded-lg shadow-sm border border-green-600 mt-3',
                                    attr: {
                                        style: 'border-color:#16a34a !important;'
                                    },
                                    buttons: [{
                                            extend: 'copyHtml5',
                                            text: '<i class="fa fa-copy mr-1 text-gray-700"></i> Copy',
                                            className: 'bg-white text-black px-3 py-1 rounded hover:bg-gray-100 border border-gray-300'
                                        },
                                        {
                                            extend: 'excelHtml5',
                                            text: '<i class="fa fa-file-excel mr-1 text-green-600"></i> Excel',
                                            className: 'bg-white text-black px-3 py-1 rounded hover:bg-green-50 border border-gray-300'
                                        },
                                        {
                                            extend: 'csvHtml5',
                                            text: '<i class="fa fa-file-csv mr-1 text-blue-600"></i> CSV',
                                            className: 'bg-white text-black px-3 py-1 rounded hover:bg-blue-50 border border-gray-300'
                                        },
                                        {
                                            extend: 'pdfHtml5',
                                            text: '<i class="fa fa-file-pdf mr-1 text-red-600"></i> PDF',
                                            className: 'bg-white text-black px-3 py-1 rounded hover:bg-red-50 border border-gray-300'
                                        },
                                        {
                                            extend: 'print',
                                            text: '<i class="fa fa-print mr-1 text-gray-700"></i> Print',
                                            className: 'bg-white text-black px-3 py-1 rounded hover:bg-gray-100 border border-gray-300'
                                        }
                                    ]
                                },
                                {
                                    extend: 'colvis',
                                    text: '<i class="fa fa-columns mr-1 text-green-600"></i> Columns',
                                    className: 'flex items-center px-4 py-2 bg-white font-semibold rounded-lg shadow-sm border border-green-600 mt-3',
                                    attr: {
                                        style: 'border-color:#16a34a !important;'
                                    },
                                    columns: ':not(:last-child)',
                                    columnText: function(dt, idx, title) {
                                        const defaultTitles = [
                                            'Unique ID',
                                            'Employee Name',
                                            'Department',
                                            'Report To',
                                            'Schedule',
                                            'Basic Salary',
                                            'Action'
                                        ];
                                        return defaultTitles[idx] ||
                                            `Column ${idx + 1}`;
                                    }
                                }
                            ],
                            columns: [{
                                    data: 'unique_id',
                                    name: 'unique_id',
                                    className: 'px-6 py-4 text-sm text-gray-900 font-bold border-r border-gray-100'
                                },
                                {
                                    data: 'employee_name',
                                    name: 'employee_name',
                                    className: 'px-6 py-4 text-sm text-gray-900 border-r border-gray-100'
                                },
                                {
                                    data: 'department',
                                    name: 'department',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100'
                                },
                                {
                                    data: 'report_to',
                                    name: 'report_to',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100'
                                },
                                {
                                    data: 'schedule',
                                    name: 'schedule',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100'
                                },
                                {
                                    data: 'basic_salary',
                                    name: 'basic_salary',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100'
                                }, {
                                    data: 'status',
                                    name: 'status',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100',
                                    render: function(data) {
                                        if (data === 'Active') {
                                            return '<span class="px-3 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-700">ACTIVE</span>';
                                        } else {
                                            return '<span class="px-3 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-700">NOT ACTIVE</span>';
                                        }
                                    }
                                },

                                {
                                    data: null,
                                    orderable: false,
                                    searchable: false,
                                    className: 'px-6 py-4 text-center',
                                    render: function(data, type, row) {
                                        return `
                            <div class="flex items-center justify-center space-x-2">
                                <button x-data @click.prevent="$dispatch('open-modal', 'edit-employee')"
                                    class="inline-flex items-center px-3 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 transform transition-all duration-200 hover:scale-105"
                                    onclick="editFunction(${row.id});">
                                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414
                                            a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                    </svg>
                                    Edit
                                </button>

                                <button
                                    class="inline-flex items-center px-3 py-2 text-sm font-medium text-white bg-red-600 rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 transform transition-all duration-200 hover:scale-105"
                                    onclick="deleteEmployee(${row.id});">
                                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862
                                            a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6
                                            m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                                        </path>
                                    </svg>
                                    Delete
                                </button>
                            </div>`;
                                    }
                                }
                            ],
                            language: {
                                search: "_INPUT_",
                                searchPlaceholder: "Search employees...",
                                info: "Showing _START_ to _END_ of _TOTAL_ entries",
                                paginate: {
                                    first: "First",
                                    last: "Last",
                                    next: "Next",
                                    previous: "Previous"
                                }
                            },
                            initComplete: function() {
                                this.api().columns().every(function() {
                                    var column = this;
                                    $('input', column.header()).on(
                                        'keyup change clear',
                                        function() {
                                            if (column.search() !== this
                                                .value) {
                                                column.search(this.value)
                                                    .draw();
                                            }
                                        });
                                });
                            }
                        });

                        // Adjust columns once loaded
                        table.columns.adjust().draw();
                    }, 150);
                },
                error: function(xhr, status, error) {
                    console.error('Error:', error);
                }
            });
        }

        function editFunction(id) {
            globalID = id;
            $.ajax({
                url: `{{ route('employees.edit', ['id' => ':id']) }}`.replace(':id', id),
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    const fullName = data.employee_name || "";
                    let firstName = "";
                    let lastName = "";

                    if (fullName.includes(",")) {
                        const parts = fullName.split(",");
                        firstName = parts[0].trim();
                        lastName = parts[1].trim();
                    } else {
                        firstName = fullName;
                    }

                    console.log(data);
                    // Populate modal fields with employee data
                    $('#employeeUniqueId').val(data.unique_id);
                    $('#employeeFirstName').val(firstName);
                    $('#employeeLastName').val(lastName);
                    $('#basicSalary').val(data.basic_salary);
                    $('#department').val(data.department);
                    $('#report_to').val(data.report_to);
                    $('#schedule').val(data.schedule);
                    $('#employeeEditStatus').val(data.status ?? 'Not Active');
                    // Open the modal
                    window.dispatchEvent(new Event('open-modal'));
                },
                error: function(xhr, status, error) {
                    console.error('Error fetching employee data:', error);
                }
            });
        }

        function updateFunction() {
            let employeeUniqueId = $('#employeeUniqueId').val();
            let employeeFirstName = $('#employeeFirstName').val();
            let employeeLastName = $('#employeeLastName').val();
            let employeeName = employeeFirstName + ', ' + employeeLastName;
            let basicSalary = $('#basicSalary').val();
            let department = $('#department').val();
            let report_to = $('#report_to').val();
            let schedule = $('#schedule').val();
            let employeeEditStatus = $('#employeeEditStatus').val();
            $.ajax({
                url: `{{ route('employees.edit', ['id' => ':id']) }}`.replace(':id', globalID),
                type: 'PUT',
                dataType: 'json',
                data: {
                    unique_id: employeeUniqueId,
                    employee_name: employeeName,
                    basic_salary: basicSalary,
                    department: department,
                    report_to: report_to,
                    schedule: schedule,
                    status: employeeEditStatus,
                    _token: "{{ csrf_token() }}"
                },
                success: function(response) {
                    Swal.fire({
                        position: "center",
                        icon: "success",
                        title: "Employee updated successfully!",
                        showConfirmButton: false,
                        timer: 1500,
                        width: "500px"
                    });

                    $('#employeeTable').DataTable().ajax.reload();
                    window.dispatchEvent(new Event('close-modal'));
                },
                error: function(xhr, status, error) {
                    console.error('Error updating employee data:', error);
                    alert('Failed to update employee data');
                }
            });
        }

        function deleteEmployee(id) {
            Swal.fire({
                title: "Are you sure?",
                text: "You won't be able to revert this!",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#3085d6",
                cancelButtonColor: "#d33",
                customClass: 'swal-wide',
                confirmButtonText: "Yes, delete it!"
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        url: `{{ route('employees.destroy', ['id' => ':id']) }}`.replace(':id', id),
                        type: 'DELETE',
                        data: {
                            _token: "{{ csrf_token() }}"
                        },
                        success: function(response) {
                            location.reload();
                        },
                        error: function(xhr) {
                            alert('An error occurred: ' + xhr.responseText);
                        }
                    });
                    Swal.fire({
                        title: "Deleted!",
                        text: "Your file has been deleted.",
                        icon: "success"
                    });
                }
            });
        }

        function addEmployee() {
            let employeeAddUniqueId = $('#employeeAddUniqueId').val();
            let employeeAddFirstName = $('#employeeAddFirstName').val();
            let employeeAddLastName = $('#employeeAddLastName').val();
            let employeeAddDepartment = $('#employeeAddDepartment').val();
            let employeeAddSchedule = $('#employeeAddSchedule').val();
            let employeeAddImmediateSupervisor = $('#employeeAddImmediateSupervisor').val();
            let basicAddSalary = $('#basicAddSalary').val();
            let employeeAddStatus = $('#employeeAddStatus').val();


            $.ajax({
                url: "{{ route('employees.store') }}",
                type: 'POST',
                data: {
                    employeeAddUniqueId: employeeAddUniqueId,
                    employeeAddFirstName: employeeAddFirstName,
                    employeeAddLastName: employeeAddLastName,
                    employeeAddDepartment: employeeAddDepartment,
                    employeeAddSchedule: employeeAddSchedule,
                    employeeAddImmediateSupervisor: employeeAddImmediateSupervisor,
                    basicAddSalary: basicAddSalary,
                    employeeAddStatus: employeeAddStatus,
                    _token: "{{ csrf_token() }}"
                },
                success: function(response) {
                    Swal.fire({
                        position: "center",
                        icon: "success",
                        title: response.message,
                        showConfirmButton: false,
                        timer: 1500,
                        width: "500px"
                    });
                    window.dispatchEvent(new Event('close'));
                    $('#employeeTable').DataTable().ajax.reload();
                },
                error: function(xhr) {
                    if (xhr.status === 422) {
                        const errors = xhr.responseJSON.errors;
                        let errorMessage = '';
                        for (const key in errors) {
                            if (errors.hasOwnProperty(key)) {
                                errorMessage += errors[key].join(', ') + '\n';
                            }
                        }
                        Swal.fire({
                            position: "center",
                            icon: "error",
                            title: errorMessage,
                            showConfirmButton: false,
                            timer: 5000,
                            width: "500px"
                        });
                    } else {
                        alert('An error occurred. Please try again.');
                    }
                }
            });
        }

        document.addEventListener("DOMContentLoaded", function() {
            $('#addEmployeeForm').on('submit', function(event) {
                event.preventDefault();
            });
        });
    </script>

    <style>
        /* Custom DataTables Styling */
        #employeeTable_wrapper .dataTables_filter input {
            padding: 0.75rem 1rem;
            border: 1px solid #d1d5db;
            border-radius: 0.5rem;
            font-size: 0.875rem;
            width: 100%;
            max-width: 250px;
            background: white;
            transition: all 0.2s;
        }

        #employeeTable_wrapper .dataTables_filter input:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        #employeeTable_wrapper .dataTables_length select {
            padding: 0.75rem;
            border-radius: 0.5rem;
            border: 1px solid #d1d5db;
            font-size: 0.875rem;
            background: white;
            transition: all 0.2s;
        }

        #employeeTable_wrapper .dataTables_length select:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        /* Table row hover effects */
        #employeeTable tbody tr:hover {
            background-color: #f8fafc;
            transform: translateY(-1px);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            transition: all 0.2s ease;
        }

        /* DataTables pagination styling */
        .dataTables_paginate .paginate_button {
            padding: 0.5rem 1rem;
            margin: 0 0.25rem;
            border-radius: 0.375rem;
            border: 1px solid #d1d5db;
            background: white;
            color: #374151;
            transition: all 0.2s;
        }

        .dataTables_paginate .paginate_button:hover {
            background: #f3f4f6;
            border-color: #9ca3af;
        }

        .dataTables_paginate .paginate_button.current {
            background: #3b82f6;
            color: white;
            border-color: #3b82f6;
        }

        .dataTables_paginate .paginate_button.current:hover {
            background: #2563eb;
            border-color: #2563eb;
        }

        /* Info and length menu styling */
        .dataTables_info,
        .dataTables_length {
            color: #6b7280;
            font-size: 0.875rem;
        }

        /* Responsive table improvements */
        @media (max-width: 768px) {
            #employeeTable_wrapper .dataTables_filter input {
                max-width: 100%;
                margin-bottom: 1rem;
            }

            .dataTables_length {
                margin-bottom: 1rem;
            }
        }
    </style>
</x-app-layout>

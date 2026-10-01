<x-app-layout>
    <style>
        .loader-overlay {
            position: fixed;
            /* cover the whole screen */
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            /* dim background */
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999;
            /* on top of other content */
        }

        .loader {
            position: relative;
            width: 2.5em;
            height: 2.5em;
            transform: rotate(165deg);
            z-index: 9999;
        }

        .loader:before,
        .loader:after {
            content: "";
            position: absolute;
            top: 50%;
            left: 50%;
            display: block;
            width: 0.5em;
            height: 0.5em;
            border-radius: 0.25em;
            transform: translate(-50%, -50%);
        }

        .loader:before {
            animation: before8 2s infinite;
        }

        .loader:after {
            animation: after6 2s infinite;
        }

        @keyframes before8 {
            0% {
                width: 0.5em;
                box-shadow: 1em -0.5em rgba(225, 20, 98, 0.75), -1em 0.5em rgba(111, 202, 220, 0.75);
            }

            35% {
                width: 2.5em;
                box-shadow: 0 -0.5em rgba(225, 20, 98, 0.75), 0 0.5em rgba(111, 202, 220, 0.75);
            }

            70% {
                width: 0.5em;
                box-shadow: -1em -0.5em rgba(225, 20, 98, 0.75), 1em 0.5em rgba(111, 202, 220, 0.75);
            }

            100% {
                box-shadow: 1em -0.5em rgba(225, 20, 98, 0.75), -1em 0.5em rgba(111, 202, 220, 0.75);
            }
        }

        @keyframes after6 {
            0% {
                height: 0.5em;
                box-shadow: 0.5em 1em rgba(61, 184, 143, 0.75), -0.5em -1em rgba(233, 169, 32, 0.75);
            }

            35% {
                height: 2.5em;
                box-shadow: 0.5em 0 rgba(61, 184, 143, 0.75), -0.5em 0 rgba(233, 169, 32, 0.75);
            }

            70% {
                height: 0.5em;
                box-shadow: 0.5em -1em rgba(61, 184, 143, 0.75), -0.5em 1em rgba(233, 169, 32, 0.75);
            }

            100% {
                box-shadow: 0.5em 1em rgba(61, 184, 143, 0.75), -0.5em -1em rgba(233, 169, 32, 0.75);
            }
        }

        .loader {
            position: absolute;
            top: calc(50% - 1.25em);
            left: calc(50% - 1.25em);
        }

        /* Custom scrollbar */
        .custom-scrollbar::-webkit-scrollbar {
            width: 8px;
            /* scrollbar width */
        }

        .custom-scrollbar::-webkit-scrollbar-track {
            background: #f1f1f1;
            /* track color */
            border-radius: 8px;
        }

        .custom-scrollbar::-webkit-scrollbar-thumb {
            background-color: #17AD49;
            /* green scrollbar */
            border-radius: 8px;
        }

        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
            background-color: #0f7a34;
            /* darker green on hover */
        }
    </style>
    <x-approval-table-assets />
    {{-- <x-slot name="header">
        <div class="flex items-center justify-between">
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">
                {{ __('Certificates of Attendance') }}
            </h2>
            <button onclick="openAddleaveModal();"
                class="flex items-center px-4 py-2 bg-white text-green-600 font-semibold rounded-lg shadow-sm">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
                </svg>
                Add
            </button>

        </div>
    </x-slot> --}}

    <div class="px-2 lg:px-4">

        <div class="loader-overlay" id="loaderOverlay">
            <div class="loader"></div>
        </div>

        <!-- Page header + toolbar -->
        <div class="flex flex-wrap items-center justify-between gap-3 px-4 pt-4 pb-3">
            <h1 class="text-xl font-semibold text-gray-900">{{ __('Leaves') }}</h1>
            <div class="flex flex-wrap items-center gap-2">
                <button type="button" onclick="openAddleaveModal();"
                    class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-white bg-green-600 rounded-md hover:bg-green-700 shadow-sm">
                    <i class="fa-solid fa-plus"></i>
                    Add
                </button>
                <x-bulk-approve prefix="leave" table="#leaves-table" pending="pending" title="leaves"
                    one="leave request" many="leave requests" on-done="loadLeavesCounts"
                    :approve-url="route('leave.bulkApprove')" :options-url="route('leave.bulkOptions')"
                    :approve-by-url="route('leave.bulkApproveBy')" />
                <div class="relative">
                    <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs"></i>
                    <input id="leave-search" type="search" placeholder="Search"
                        class="w-48 pl-8 pr-3 py-1.5 text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500">
                </div>
                <div id="leave-toolbar-buttons" class="flex items-center gap-2"></div>
            </div>
        </div>

        <!-- Table card -->
        <div class="px-4 pb-4">
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm">
                <!-- Status filter -->
                <x-status-tabs loader="loadLeaves" :values="['pending', 'approved', 'cancelled']" />

                <div class="p-2 text-gray-900">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="leaves-table" class="modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th class="noVis" style="width: 2.5rem;">
                                            <input type="checkbox" id="leave-select-all" title="Select all on this page"
                                                class="rounded border-gray-300 text-green-600 focus:ring-green-500">
                                        </th>
                                        <th>Employee</th>
                                        <th>Department</th>
                                        <th>Reason</th>
                                        <th>Record Date</th>
                                        <th>With Pay</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Add Certificate Modal -->
        <div id="addleaveModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black bg-opacity-50">
            <div class="bg-white rounded-lg shadow-lg w-full max-w-4xl p-6">
                <!-- Modal Header -->
                <div class="flex justify-between items-center border-b pb-2 mb-4">
                    <h3 class="text-lg font-semibold text-gray-800">Add New Leave</h3>
                    <button onclick="closeLeaves()" class="text-gray-500 hover:text-gray-800 text-xl">&times;</button>
                </div>

                <!-- Modal Body -->

                <div class="grid grid-cols-1 md:grid-cols-1 mb-5">
                    <label for="employee_name" class="block text-sm font-semibold text-gray-700">Employee
                        Name</label>
                    <select id="employee_name" name="id"
                        class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm
                               focus:ring-blue-500 focus:border-blue-500 text-sm">
                    </select>
                </div>
                <!-- Two Cards in One Row -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Card 1 -->
                    <div class="bg-white border rounded-lg shadow p-4 h-[300px] overflow-y-auto">
                        <h2 class="text-md font-semibold text-gray-800 pb-1 mb-2">
                            Attendance Dates
                        </h2>
                        <p class="text-sm text-gray-600 border-b pb-2 mb-3">
                            Select the dates you want to add an attendance to
                        </p>

                        <!-- Radio Button Group with Dividers -->
                        <div class="flex items-center divide-x divide-gray-300">
                            <label class="flex items-center px-4">
                                <input type="radio" name="date_option" value="single"
                                    class="form-radio text-green-600">
                                <span class="ml-2 text-gray-700">Single Date</span>
                            </label>

                            <label class="flex items-center px-4">
                                <input type="radio" name="date_option" value="multi"
                                    class="form-radio text-green-600">
                                <span class="ml-2 text-gray-700">Multi Dates</span>
                            </label>

                            <label class="flex items-center px-4">
                                <input type="radio" name="date_option" value="range"
                                    class="form-radio text-green-600">
                                <span class="ml-2 text-gray-700">Date Range</span>
                            </label>
                        </div>

                        <!-- Calendar -->
                        <input type="text" id="leaveCalendar"
                            class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm
               focus:ring-blue-500 focus:border-blue-500 text-sm mt-5"
                            placeholder="Select date(s)">
                    </div>

                    <!-- Card 2 -->
                    <div class="bg-white border rounded-lg shadow p-4 h-[300px] overflow-y-auto custom-scrollbar">
                        <h2 class="text-md font-semibold text-gray-800 pb-1 mb-2">
                            Log Hours
                        </h2>
                        <p class="text-sm text-gray-600 border-b pb-2 mb-3">
                            Add in your clock in and out hrs for the dates you selected
                        </p>

                        <div class="mt-5 log_hours_container">
                        </div>
                    </div>
                </div>

                <!-- Others and Reasons -->
                <div class="mt-6 space-y-4">
                    <!-- Others Input -->
                    <div>
                        <label for="others" class="block text-sm font-semibold text-gray-700">Others</label>
                        <input type="text" id="others" name="others"
                            class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm
               focus:ring-blue-500 focus:border-blue-500 text-sm"
                            placeholder="Enter other details">
                    </div>

                    <!-- Reasons Textarea -->
                    <div>
                        <label for="reasons" class="block text-sm font-semibold text-gray-700">Reasons</label>
                        <textarea id="reasons" name="reasons" rows="3"
                            class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm
               focus:ring-blue-500 focus:border-blue-500 text-sm"
                            placeholder="Provide your reason here"></textarea>
                    </div>
                </div>
                <!-- Attachment Upload -->
                {{-- <div class="mt-6">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Attachment (Optional)</label>

                    <div id="dropZone"
                        class="flex flex-col items-center justify-center w-full h-32 px-4 transition bg-gray-50 border-2 border-dashed border-gray-300 rounded-md cursor-pointer hover:border-green-600 hover:bg-green-50">
                        <input id="attachment" type="file" accept=".jpg,.png,.pdf" class="hidden" />
                        <svg class="w-8 h-8 text-gray-500 mb-2" fill="none" stroke="currentColor"
                            viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M7 16a4 4 0 01-.88-7.9A5 5 0 1115 8h1a5 5 0 010 10h-1" />
                        </svg>
                        <p class="text-sm text-gray-600">
                            <span class="font-medium">Drop your image or browse</span>
                        </p>
                        <p class="text-xs text-gray-500">Supports JPG, PNG, PDF (Max 5MB)</p>
                    </div>
                </div> --}}

                <!-- Modal Footer -->
                <div class="flex justify-end space-x-4 pt-4">
                    <button type="button" onclick="closeLeaves()"
                        class="bg-gray-300 hover:bg-gray-400 text-sm px-4 py-2 rounded shadow-md">
                        Cancel
                    </button>
                    <button type="submit" onclick="submitLeaves();"
                        class="bg-green-600 hover:bg-green-700 text-white text-sm px-4 py-2 rounded shadow-md">
                        Add Leave
                    </button>
                </div>
            </div>
        </div>
    </div>
    <div id="skippedEmployeesModal"
        class="fixed inset-0 z-50 hidden items-center justify-center bg-black bg-opacity-50">
        <div class="bg-white rounded-lg shadow-lg w-full max-w-lg p-6">
            <!-- Header -->
            <div class="flex justify-between items-center border-b pb-2 mb-4">
                <h3 class="text-lg font-semibold text-gray-800 flex items-center space-x-2">
                    <i class="fas fa-exclamation-triangle text-yellow-500 fa-beat" style="font-size: 1.2rem;"></i>
                    <span>Skipped Attendance Records</span>
                </h3>
                <button onclick="closeSkippedModal()"
                    class="text-gray-500 hover:text-gray-800 text-xl">&times;</button>
            </div>
            <p class="text-sm text-gray-600 mb-3">
                The following employees already have leave for the selected date(s):
            </p>
            <div id="skippedEmployeesList"
                class="max-h-60 overflow-y-auto border rounded-md p-3 space-y-2 bg-gray-50">
            </div>
            <div class="flex justify-end mt-4">
                <button onclick="closeSkippedModal()"
                    class="bg-green-600 hover:bg-green-700 text-white text-sm px-4 py-2 rounded shadow-md">
                    OK
                </button>
            </div>
        </div>
    </div>

    <!-- JavaScript -->
    <script>
        let getUniqueId;
        const userId = "{{ Auth::user()->id ?? '' }}";
        const userRole = "{{ Auth::user()->role ?? '' }}";
        $('#loaderOverlay').hide();
        loadEmployeeName();
        loadLeaves('pending');
        bindTableSearch('#leave-search', '#leaves-table');

        function loadLeaves(status = 'pending') {
            bulk_leave.setStatus(status);

            if ($.fn.DataTable.isDataTable('#leaves-table')) {
                $('#leaves-table').DataTable().clear().destroy();
            }
            $('#leave-toolbar-buttons').empty();

            $.ajax({
                url: "{{ route('department.getUserDepartment') }}",
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    let departmentName = !data.success ? 'N/A' : data.data.department_name;

                    setTimeout(() => {
                        const table = $('#leaves-table').DataTable({
                            serverSide: true,
                            autoWidth: false,
                            responsive: {
                                details: {
                                    type: 'column',
                                    target: 0
                                }
                            },
                            lengthChange: true,
                            lengthMenu: [10, 20, 50],
                            pageLength: 50,
                            dom: 'rt<"flex flex-wrap justify-between items-center gap-2 px-3 py-2 border-t border-gray-200 text-xs text-gray-600"lip>',
                            search: {
                                search: $('#leave-search').val() || ''
                            },
                            order: [
                                [2, 'asc']
                            ],
                            ajax: {
                                url: "{{ route('leave.fetch') }}",
                                data: function(d) {
                                    d.status = status;
                                    d.userRole = userRole;
                                    if (userRole === 'user') {
                                        d.department = departmentName;
                                    }
                                }
                            },
                            drawCallback: function() {
                                bulk_leave.syncSelectAll();
                            },
                            buttons: exportAndColumnButtons(),
                            columns: [
                                expandControlColumn,
                                bulk_leave.checkboxColumn(),
                                {
                                    data: 'employee_name',
                                    name: 'employee_management.employee_name',
                                    className: 'all',
                                    render: function(data, type) {
                                        return type === 'display' ? employeeNameCell(data) : data;
                                    }
                                },
                                {
                                    data: 'department',
                                    name: 'department',
                                    render: function(data, type) {
                                        return type === 'display' ? colorBadgeCell(data) : data;
                                    }
                                },
                                {
                                    data: 'reason',
                                    name: 'leaves.reason'
                                },
                                {
                                    data: 'record_date',
                                    name: 'record_date',
                                    render: dateOnlyCell
                                },
                                {
                                    data: 'with_pay',
                                    name: 'leaves.with_pay',
                                    className: 'text-center',
                                    render: function(data, type) {
                                        const yes = data === true || data === 'true' || data === 1;
                                        if (type !== 'display') return yes ? 'Yes' : 'No';
                                        return yes ?
                                            `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-green-100 text-green-800">Yes</span>` :
                                            `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-red-100 text-red-800">No</span>`;
                                    }
                                },
                                {
                                    data: 'status',
                                    name: 'leaves.status',
                                    render: function(data, type) {
                                        return type === 'display' ? statusBadgeCell(data) : data;
                                    }
                                },
                                {
                                    data: null,
                                    orderable: false,
                                    searchable: false,
                                    className: 'noVis all text-center',
                                    render: function(data, type, row) {
                                        return approvalActionButtons(row.status, row.id, {
                                            approve: 'approveLeave',
                                            cancel: 'cancelLeave',
                                            restore: 'handleRedo'
                                        });
                                    }
                                }
                            ],
                            language: {
                                emptyTable: "No records available",
                                info: "Showing _START_ to _END_ of _TOTAL_ entries",
                                lengthMenu: "Rows per page _MENU_",
                                paginate: {
                                    first: "First",
                                    last: "Last",
                                    next: "Next",
                                    previous: "Previous"
                                }
                            }
                        });
                        table.buttons().container().appendTo('#leave-toolbar-buttons');
                    }, 150);
                },
                error: function(xhr, status, error) {
                    console.error('Error:', error);
                }
            });
        }

        // Load initially
        // loadLeaves('Pending');


        function approveLeave(id) {
            Swal.fire({
                title: "Are you sure?",
                text: "This overtime will be marked as Approved.",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#3085d6",
                cancelButtonColor: "#d33",
                confirmButtonText: "Yes, approve it!"
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        url: `/leave/${id}/approved`,
                        type: "POST",
                        data: {
                            _token: "{{ csrf_token() }}"
                        },
                        success: function(response) {
                            if (response.success) {
                                Swal.fire({
                                    title: "Approved!",
                                    text: response.message,
                                    icon: "success",
                                    timer: 2000,
                                    showConfirmButton: false
                                });
                                $('#leaves-table').DataTable().ajax.reload();
                                loadLeavesCounts();
                            } else {
                                Swal.fire("Failed!", response.message, "error");
                            }
                        },
                        error: function(xhr) {
                            Swal.fire("Error!", "An error occurred: " + xhr.responseText, "error");
                        }
                    });
                }
            });
        }

        function cancelLeave(id) {
            Swal.fire({
                title: "Are you sure?",
                text: "This certificate of attendance will be marked as Cancelled.",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#3085d6",
                cancelButtonColor: "#d33",
                confirmButtonText: "Yes, cancel it!"
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        url: `/leave/${id}/cancelled`,
                        type: "POST",
                        data: {
                            _token: "{{ csrf_token() }}"
                        },
                        success: function(response) {
                            if (response.success) {
                                Swal.fire({
                                    title: "Cancelled!",
                                    text: response.message,
                                    icon: "success",
                                    timer: 2000,
                                    showConfirmButton: false
                                });
                                $('#leaves-table').DataTable().ajax.reload();
                                loadLeavesCounts();
                            } else {
                                Swal.fire("Failed!", response.message, "error");
                            }
                        },
                        error: function(xhr) {
                            Swal.fire("Error!", "An error occurred: " + xhr.responseText, "error");
                        }
                    });
                }
            });
        }

        function loadEmployeeName() {
            $('#employee_name').html(''); // Clear existing options
            $('#employee_name').append('<option value="">Select an Employee Name...</option>');

            $.ajax({
                url: "{{ route('department.getUserDepartment') }}",
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    let departmentName;
                    if (!data.success) {
                        departmentName = 'N/A';
                    } else {
                        departmentName = data.data.department_name;
                    }
                    $.ajax({
                        url: "{{ route('employee.fetch.employeename') }}",
                        method: 'GET',
                        data: {
                            userRole: userRole,
                            department: departmentName
                        },
                        success: function(response) {
                            response.forEach(function(item) {
                                $('#employee_name').append(
                                    `<option value="${item.id}">${item.employee_name}</option>`
                                );
                            });
                        }
                    });
                }
            });
        }

        loadLeavesCounts();

        function loadLeavesCounts() {
            $.ajax({
                url: "{{ route('department.getUserDepartment') }}",
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    let departmentName;
                    if (!data.success) {
                        departmentName = 'N/A';
                    } else {
                        departmentName = data.data.department_name;
                    }

                    $.ajax({
                        url: "{{ route('leave.counts') }}",
                        type: "GET",
                        data: {
                            userRole: userRole,
                            department: departmentName // only used if userRole = 'user'
                        },
                        success: function(response) {
                            console.log(response);
                            $('#pending-count').text(response.pending);
                            $('#approved-count').text(response.approved);
                            $('#cancelled-count').text(response.cancelled);
                        },
                        error: function(xhr) {
                            console.error("Failed to fetch overtime counts:", xhr.responseText);
                        }
                    });

                },
                error: function(xhr, status, error) {
                    console.error('Error:', error);
                }
            });
        }

        function formatDate(rawDate) {
            if (!rawDate) return '';
            const parts = rawDate.includes('/') ? rawDate.split('/') : rawDate.split('-');
            const [year, month, day] = parts;
            return `${month.padStart(2,'0')}-${day.padStart(2,'0')}-${year}`;
        }

        function openAddleaveModal() {
            document.getElementById('addleaveModal').classList.replace('hidden', 'flex');
        }

        function closeLeaves() {
            document.getElementById('addleaveModal').classList.replace('flex', 'hidden');
            document.getElementById('addCertificateForm').reset();
        }


        let logHoursCount = 0;

        function addLogHours(date, dateFormatted, weekday) {
            logHoursCount++;
            const logHoursIdentification = `logHours${logHoursCount}`;
            $('.log_hours_container').append(`
                            <div class="log_hours_details mb-5" id="${logHoursIdentification}">
                                <div class="flex items-center justify-between mb-3">
                                    <span class="text-gray-800 font-medium">${date} ${weekday}</span>
                                    <button class="text-red-500 hover:text-red-700" onclick="removeLoghours('${logHoursIdentification}');">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                                <div class="time_type_container_${dateFormatted}">
                                </div>
                                <div class="flex space-x-4 mt-3">
                                    <button onclick="timeType('${dateFormatted}');"
                                        class="px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700 text-sm">
                                        + Add Leave Type
                                    </button>
                                </div>
                            </div>`);
        }
        let timeTypeCount = 0;

        function timeType(identification) {
            timeTypeCount++;
            $('.time_type_container_' + identification).append(`
            <div class="time_type_details mb-5" id="${identification}">
                <div class="flex items-center justify-between mb-3">
                    <div class="flex items-center space-x-4">
                        <label class="flex items-center space-x-2">
                            <input type="radio" name="timeType${timeTypeCount}" value="Whole Day"
                                class="text-green-600" checked>
                            <span>Whole Day</span>
                        </label>
                        <label class="flex items-center space-x-2">
                            <input type="radio" name="timeType${timeTypeCount}" value="Half Day"
                                class="text-green-600">
                            <span>Half Day</span>
                        </label>
                    </div>
                    <button class="text-red-500 hover:text-red-700" onclick="removeTimeType('${identification}');">
                        <i class="fas fa-times"></i>
                    </button>
                </div>`);
        }

        let range = [];
        let formattedD = [];

        let timeInputArray = [];

        function removeLoghours(logHoursIdentification) {
            $('#' + logHoursIdentification).remove();
        }

        function removeTimeType(identification) {
            $('#' + identification).remove();
        }

        function submitLeaves() {
            let leaveArray = []; // final result
            let rdValue = '';
            $.each(formattedD, function(index, date) {
                // convert date string to a Date object
                const weekday = new Date(date).toLocaleDateString("en-US", {
                    weekday: "long"
                });
                // loop through all time inputs for this date
                $('.timeInput' + date).each(function() {
                    const timeValue = $(this).val();
                    if (!timeValue) return; // skip empty

                    // get corresponding radio value
                    const inputName = $(this).attr('name'); // e.g. "timeInput3"
                    const countNumber = inputName.replace('timeInput', '');
                    const radioValue = $(`input[name="timeType${countNumber}"]:checked`).val();
                    rdValue = radioValue;
                    // assign to in/out
                    // if (radioValue === 'in') {
                    //     inTime = timeValue;
                    // } else if (radioValue === 'out') {
                    //     outTime = timeValue;
                    // }
                });

                // only push if at least one time exists
                leaveArray.push({
                    employee_management_id: $('#employee_name').val(),
                    record_date: date,
                    leave_type: rdValue,
                    others: $('#others').val(),
                    reason: $('#reasons').val(),
                    weekday: weekday
                });
            });
            if (leaveArray.length > 0) {
                $.ajax({
                    url: "{{ route('leave.store') }}",
                    method: 'POST',
                    data: {
                        leaveArray: leaveArray,
                    },
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    success: function(response) {
                        console.log(response);
                        // Show SweetAlert for success
                        Swal.fire({
                            icon: (response.skipped?.length || 0) > 0 ? 'warning' : 'success',
                            title: (response.skipped?.length || 0) > 0 ? 'Warning' : 'Success',
                            text: response.message,
                            timer: 2000,
                            showConfirmButton: false
                        });

                        // Reload leave counts
                        loadLeavesCounts();

                        // Show Skipped Leaves Modal if any
                        if (response.skipped && response.skipped.length > 0) {
                            showSkippedModal(response.skipped);
                        }
                    },
                    error: function(xhr) {
                        let errorMsg = "An error occurred";

                        if (xhr.status === 422) {
                            // Laravel validation error
                            let errors = xhr.responseJSON.errors;
                            if (errors) {
                                errorMsg = "";
                                Object.values(errors).forEach(function(errorArray) {
                                    errorArray.forEach(function(error) {
                                        errorMsg += error + "\n";
                                    });
                                });
                            } else if (xhr.responseJSON.error) {
                                errorMsg = xhr.responseJSON.error;
                            }
                        } else if (xhr.responseJSON && xhr.responseJSON.message) {
                            errorMsg = xhr.responseJSON.message;
                        }

                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: errorMsg
                        });
                    }
                });

            }
            console.log(leaveArray); // ✅ Final structured result

            $('#leaves-table').DataTable().ajax.reload();
        }

        function showSkippedModal(skippedList) {
            const modal = document.getElementById("skippedEmployeesModal");
            const listContainer = document.getElementById("skippedEmployeesList");
            listContainer.innerHTML = "";

            if (skippedList.length === 0) {
                listContainer.innerHTML = `<p class="text-gray-600 text-sm">No skipped records.</p>`;
            } else {
                skippedList.forEach(item => {
                    const div = document.createElement("div");
                    div.classList.add(
                        "flex", "justify-between", "items-center", "bg-white", "border",
                        "rounded-md", "p-2", "shadow-sm"
                    );
                    div.innerHTML = `
                <span class="text-gray-700 text-sm font-medium">${item.employee_name}</span>
                <span class="text-gray-500 text-xs">${item.record_date || item.date}</span>
            `;
                    listContainer.appendChild(div);
                });
            }

            modal.classList.remove("hidden");
            modal.classList.add("flex");
        }

        function closeSkippedModal() {
            const modal = document.getElementById("skippedEmployeesModal");
            modal.classList.add("hidden");
            modal.classList.remove("flex");
        }

        // Calendar ###########
        let calendar = $("#leaveCalendar").flatpickr({
            mode: "single"
        });
        // Helper function to handle adding log hours for selected dates
        function handleDates(dates) {
            formattedD = []; // reset
            $('.log_hours_container').html('');

            dates.forEach(d => {
                let selectedDate = new Date(d);

                // Format date (Oct 1, 2025)
                let formattedDate = selectedDate.toLocaleDateString("en-US", {
                    month: "short",
                    day: "numeric",
                    year: "numeric"
                });

                // Get weekday (Wednesday)
                let weekday = selectedDate.toLocaleDateString("en-US", {
                    weekday: "long"
                });

                formattedD.push(formatDateYMD(selectedDate)); // store YMD format for backend
                console.log("Adding:", formattedDate, weekday);

                addLogHours(formattedDate, formatDateYMD(selectedDate), weekday);
            });

            console.log(formattedD);
        }

        // Single Date
        $("input[value='single']").on("change", function() {
            calendar.set("mode", "single");
            calendar.set("onChange", function(dates) {
                if (dates.length > 0) {
                    handleDates([dates[0]]);
                }
            });
        });

        // Multiple Dates
        $("input[value='multi']").on("change", function() {
            calendar.set("mode", "multiple");
            calendar.set("onChange", function(dates) {
                if (dates.length > 0) {
                    handleDates(dates);
                }
            });
        });

        // Date Range
        $("input[value='range']").on("change", function() {
            calendar.set("mode", "range");
            calendar.set("onChange", function(dates) {
                if (dates.length === 2) {
                    let rangeDates = [];
                    let start = new Date(dates[0]);
                    let end = new Date(dates[1]);

                    while (start <= end) {
                        rangeDates.push(new Date(start)); // push copy
                        start.setDate(start.getDate() + 1);
                    }

                    handleDates(rangeDates);
                }
            });
        });

        // // Single Date
        // $("input[value='single']").on("change", function() {
        //     calendar.set("mode", "single");
        //     calendar.set("onChange", function(dates) {
        //         if (dates.length > 0) {
        //             let selectedDate = new Date(dates[0]);
        //             // format date (e.g., Oct 1, 2025)
        //             let options = {
        //                 month: "short",
        //                 day: "numeric",
        //                 year: "numeric"
        //             };
        //             let formattedDate = selectedDate.toLocaleDateString("en-US", options);

        //             // get weekday (e.g., Wednesday)
        //             let weekday = selectedDate.toLocaleDateString("en-US", {
        //                 weekday: "long"
        //             });

        //             console.log("Selected Date:", formattedDate, weekday);

        //             // now call addLogHours with parameters
        //             $('.log_hours_container').html('');
        //             addLogHours(formattedDate, weekday);
        //         }
        //     });
        // });

        // // Multi Dates
        // $("input[value='multi']").on("change", function() {
        //     calendar.set("mode", "multiple");
        //     calendar.set("onChange", function(dates) {
        //         console.log("Multi Dates:", dates);
        //         $('.log_hours_container').html('');
        //         dates.forEach(d => {
        //             let selectedDate = new Date(d);
        //             // Format date (Oct 1, 2025)
        //             let formattedDate = selectedDate.toLocaleDateString("en-US", {
        //                 month: "short",
        //                 day: "numeric",
        //                 year: "numeric"
        //             });
        //             // Get weekday (Wednesday)
        //             let weekday = selectedDate.toLocaleDateString("en-US", {
        //                 weekday: "long"
        //             });
        //             console.log("Adding:", formattedDate, weekday);
        //             // Append log hours row
        //             addLogHours(formattedDate, weekday);
        //         });
        //     });
        // });

        // // Date Range
        // $("input[value='range']").on("change", function() {
        //     calendar.set("mode", "range");
        //     calendar.set("onChange", function(dates) {
        //         if (dates.length === 2) {
        //             range = [];
        //             let start = new Date(dates[0]);
        //             let end = new Date(dates[1]);
        //             formattedD = [];
        //             // Loop from start to end date
        //             while (start <= end) {
        //                 range.push(new Date(start)); // push copy
        //                 start.setDate(start.getDate() + 1);
        //             }
        //             $('.log_hours_container').html('');
        //             range.forEach(d => {
        //                 let formattedDate = d.toLocaleDateString("en-US", {
        //                     month: "short",
        //                     day: "numeric",
        //                     year: "numeric"
        //                 });
        //                 let weekday = d.toLocaleDateString("en-US", {
        //                     weekday: "long"
        //                 });
        //                 formattedD.push(formatDateYMD(d)); // push copy
        //                 console.log("Adding:", formattedDate, weekday);
        //                 addLogHours(formattedDate, formatDateYMD(d), weekday);
        //             });

        //             console.log(formattedD);
        //         }
        //     });
        // });

        function formatDateYMD(date) {
            let year = date.getFullYear();
            let month = String(date.getMonth() + 1).padStart(2, '0'); // months are 0-based
            let day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        }

        // Trigger single by default on page load
        $("input[value='single']").trigger("change");

        // Attachments ###########
        const dropZone = document.getElementById("dropZone");
        const fileInput = document.getElementById("attachment");
        dropZone.addEventListener("click", () => fileInput.click());
        dropZone.addEventListener("dragover", (e) => {
            e.preventDefault();
            dropZone.classList.add("border-green-600", "bg-green-50");
        });
        dropZone.addEventListener("dragleave", () => {
            dropZone.classList.remove("border-green-600", "bg-green-50");
        });
        dropZone.addEventListener("drop", (e) => {
            e.preventDefault();
            fileInput.files = e.dataTransfer.files;
            dropZone.classList.remove("border-green-600", "bg-green-50");
            console.log("File selected:", fileInput.files[0]);
        });
    </script>
</x-app-layout>

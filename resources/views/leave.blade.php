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

    <div class="px-16 py-5">

        <div class="loader-overlay" id="loaderOverlay">
            <div class="loader"></div>
        </div>

        <div class="p-6 grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Pending -->
            <div onclick="loadLeaves('pending');"
                class="border-4 border-yellow-500 text-gray-900 rounded-xl shadow-md p-6 flex flex-col items-center cursor-pointer hover:scale-105 transition-transform duration-200">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-10 h-10 mb-2 text-yellow-500" fill="none"
                    viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round"
                        d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <h2 class="text-lg font-semibold">Pending/Resubmitted for editing</h2>
                <p id="pending-count" class="text-3xl font-bold mt-2">0</p>
            </div>

            <!-- Approved -->
            <div onclick="loadLeaves('approved');"
                class="border-4 border-green-600 text-gray-900 rounded-xl shadow-md p-6 flex flex-col items-center cursor-pointer hover:scale-105 transition-transform duration-200">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-10 h-10 mb-2 text-green-600" fill="none"
                    viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                </svg>
                <h2 class="text-lg font-semibold">Approved</h2>
                <p id="approved-count" class="text-3xl font-bold mt-2">0</p>
            </div>

            <!-- Cancelled -->
            <div onclick="loadLeaves('cancelled');"
                class="border-4 border-red-600 text-gray-900 rounded-xl shadow-md p-6 flex flex-col items-center cursor-pointer hover:scale-105 transition-transform duration-200">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-10 h-10 mb-2 text-red-600" fill="none"
                    viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
                <h2 class="text-lg font-semibold">Rejected/Cancelled</h2>
                <p id="cancelled-count" class="text-3xl font-bold mt-2">0</p>
            </div>
        </div>

        <!-- Table Section inside Card -->
        <div class="p-6">
            <div class="bg-white shadow-lg rounded-lg border border-gray-200">
                <!-- Card Header -->
                <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
                    <h2 class="font-bold text-3xl">
                        <i class="fa-regular fa-clone text-3xl" style="color: #8DE11A; font-size: 40px"></i>
                        {{ __('Leaves') }}
                    </h2>

                    <button onclick="openAddleaveModal();"
                        class="flex items-center px-4 py-2 bg-white text-green-600 font-semibold rounded-lg shadow-sm border border-green-600 hover:bg-green-50">
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
                <!-- Table Section inside Card -->
                <div class="p-6 text-gray-900">
                    <div class="border rounded-lg shadow-sm overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="leaves-table" class="table-auto w-full text-sm">
                                <thead class="text-white sticky top-0" style="background-color: #00291B;">
                                    <tr>
                                        <th style="width: 15%">Employee Name</th>
                                        <th style="width: 10%">Department</th>
                                        <th style="width: 10%">Reason</th>
                                        <th style="width: 10%">Record Date</th>
                                        <th style="width: 10%">With Pay</th>
                                        <th style="width: 15%">Status</th>
                                        <th style="width: 6%; text-align: center;">Action</th>
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

        function loadLeaves(status = 'pending') {
            if ($.fn.DataTable.isDataTable('#leaves-table')) {
                $('#leaves-table').DataTable().clear().destroy();
            }

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

                    setTimeout(() => {
                        let table = $('#leaves-table').DataTable({
                            serverSide: true,
                            autoWidth: false,
                            responsive: true,
                            lengthChange: true, // only keep this
                            lengthMenu: [10, 20, 50], // page length options
                            pageLength: 50, // default rows per page
                            dom: '<"flex justify-between items-center mb-4"Bf>rt<"flex justify-between items-center mt-4"lip>',
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
                                            'Employee Name', 'Department', 'Reason',
                                            'Schedule Shift', 'Record Date',
                                            'Leave Type',
                                            'With Pay', 'Status', 'Action'
                                        ];
                                        return defaultTitles[idx] ||
                                            `Column ${idx + 1}`;
                                    }
                                }
                            ],
                            columns: [{
                                    data: 'employee_name',
                                    name: 'employee_management.employee_name',
                                    width: '15%'
                                }, {
                                    data: 'department',
                                    name: 'department',
                                    width: "5%",
                                    render: function(data, type, row) {
                                        if (!data || data.trim() === '' || data ===
                                            'Not Assigned') {
                                            return `<span class="px-2 py-1 text-xs font-semibold rounded-full bg-gray-300 text-gray-800">Not Assigned</span>`;
                                        }

                                        // Generate consistent color based on department name
                                        const colors = [
                                            'bg-blue-100 text-blue-800',
                                            'bg-green-100 text-green-800',
                                            'bg-yellow-100 text-yellow-800',
                                            'bg-purple-100 text-purple-800',
                                            'bg-pink-100 text-pink-800',
                                            'bg-indigo-100 text-indigo-800',
                                            'bg-red-100 text-red-800',
                                            'bg-teal-100 text-teal-800'
                                        ];

                                        // Pick a color based on department name hash
                                        const index = Math.abs([...data].reduce((sum,
                                                c) => sum + c.charCodeAt(0), 0)) %
                                            colors.length;
                                        const colorClass = colors[index];

                                        return `<span class="px-2 py-1 text-xs font-semibold rounded-full ${colorClass}">${data}</span>`;
                                    }
                                },
                                {
                                    data: 'reason',
                                    name: 'leaves.reason',
                                    width: '10%'
                                }, {
                                    data: 'record_date',
                                    name: 'record_date',
                                    render: function(data) {
                                        if (!data) return '';
                                        // Keep only the date part before the space
                                        return data.split(' ')[0];
                                    }
                                }, {
                                    data: 'with_pay',
                                    name: 'leaves.with_pay',
                                    width: '10%',
                                    render: function(data, type, row) {
                                        if (data === true || data === 'true' || data ===
                                            1) {
                                            // With pay → green badge
                                            return `<span class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">Yes</span>`;
                                        } else {
                                            // Without pay → red badge
                                            return `<span class="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">No</span>`;
                                        }
                                    }
                                },
                                {
                                    data: 'status',
                                    name: 'leaves.status',
                                    width: '15%',
                                    render: function(data) {
                                        let badgeClass = '';
                                        if (data === 'pending') badgeClass =
                                            'bg-yellow-100 text-yellow-800';
                                        else if (data === 'approved') badgeClass =
                                            'bg-green-100 text-green-800';
                                        else badgeClass = 'bg-red-100 text-red-800';
                                        return `<span class="px-3 py-1 rounded-full text-sm font-semibold ${badgeClass}">${data}</span>`;
                                    }
                                },
                                {
                                    data: null,
                                    orderable: false,
                                    searchable: false,
                                    width: '10%',
                                    render: function(data, type, row) {
                                        switch (row.status) {
                                            case 'pending':
                                                return `
                                                <div class="flex justify-center space-x-2">
                                                    <button onclick="approveLeave(${row.id})"
                                                        class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-2 rounded-full shadow-md hover:shadow-lg transition">
                                                        <i class="fas fa-check"></i>
                                                    </button>
                                                    <button onclick="cancelLeave(${row.id})"
                                                        class="bg-red-500 hover:bg-red-600 text-white px-3 py-2 rounded-full shadow-md hover:shadow-lg transition">
                                                        <i class="fas fa-times"></i>
                                                    </button>
                                                </div>
                                                `;
                                            case 'approved':
                                                return `<div class="flex items-center justify-center space-x-2">
                                                        <button onclick="cancelLeave(${row.id})"
                                                            class="bg-red-500 hover:bg-red-600 text-white px-3 py-2 rounded-full shadow-md hover:shadow-lg transition">
                                                            <i class="fas fa-times"></i>
                                                        </button>
                                                    </div>`;
                                            case 'cancelled':
                                                return `
                                                    <div class="flex items-center justify-center space-x-2">
                                                        <button onclick="handleRedo(${row.id})"
                                                            class="bg-yellow-500 hover:bg-yellow-600 text-white px-3 py-2 rounded-full shadow-md hover:shadow-lg transition">
                                                            <i class="fas fa-undo"></i>
                                                        </button>
                                                    </div>`;
                                            default:
                                                return '';
                                        }
                                    }
                                }
                            ],
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

                        table.columns.adjust().draw();
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

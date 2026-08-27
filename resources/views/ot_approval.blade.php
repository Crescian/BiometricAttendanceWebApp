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
    </style>
    {{-- <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Overtime Approval') }}
        </h2>
    </x-slot> --}}

    {{-- <div class="loader-overlay" id="loaderOverlay">
        <div class="loader"></div>
    </div> --}}

    <div class="px-16 py-5">
        <div class="p-6 grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Pending -->
            <div onclick="loadOvertime('Pending');"
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
            <div onclick="loadOvertime('Approved');"
                class="border-4 border-green-600 text-gray-900 rounded-xl shadow-md p-6 flex flex-col items-center cursor-pointer hover:scale-105 transition-transform duration-200">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-10 h-10 mb-2 text-green-600" fill="none"
                    viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                </svg>
                <h2 class="text-lg font-semibold">Approved</h2>
                <p id="approved-count" class="text-3xl font-bold mt-2">0</p>
            </div>

            <!-- Cancelled -->
            <div onclick="loadOvertime('Cancelled');"
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
                        {{ __('Overtimes') }}
                    </h2>
                </div>
                <!-- Card Body -->
                <div class="p-6 text-gray-900">
                    <div class="border rounded-lg shadow-sm overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="overtime-table" class="table-auto w-full text-sm">
                                <thead class="text-white sticky top-0" style="background-color: #00291B;">
                                    <tr>
                                        <th class="px-4 py-2 border text-white" style="width: 4%;">ID</th>
                                        <th class="px-4 py-2 border text-white" style="width: 8%;">Last Name</th>
                                        <th class="px-4 py-2 border text-white" style="width: 8%;">First Name</th>
                                        <th class="px-4 py-2 border text-white" style="width: 8%;">Department</th>
                                        <th class="px-4 py-2 border text-white" style="width: 6%;">Area</th>
                                        <th class="px-4 py-2 border text-white" style="width: 7%;">Date</th>
                                        <th class="px-4 py-2 border text-white" style="width: 6%;">Earliest Time</th>
                                        <th class="px-4 py-2 border text-white" style="width: 6%;">Latest Time</th>
                                        <th class="px-4 py-2 border text-white" style="width: 7%;">Schedule</th>
                                        <th class="px-4 py-2 border text-white" style="width: 7%;">Schedule Shift</th>
                                        <th class="px-4 py-2 border text-white" style="width: 5%;">ORD-OT</th>
                                        <th class="px-4 py-2 border text-white" style="width: 5%;">Ord-ND</th>
                                        <th class="px-4 py-2 border text-white" style="width: 5%;">Ord-ND-OT</th>
                                        <th class="px-4 py-2 border text-white" style="width: 5%;">RD-OT</th>
                                        <th class="px-4 py-2 border text-white" style="width: 5%;">RD-ND</th>
                                        <th class="px-4 py-2 border text-white" style="width: 5%;">RD-ND-OT</th>
                                        <th class="px-4 py-2 border text-white" style="width: 5%;">RD</th>
                                        <th class="px-4 py-2 border text-white" style="width: 4%;">Late</th>
                                        <th class="px-4 py-2 border text-white" style="width: 5%;">Late Hours</th>
                                        <th class="px-4 py-2 border text-white" style="width: 5%;">Late Minutes</th>
                                        <th class="px-4 py-2 border text-white" style="width: 7%;">Action</th>

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
        </div>

        <!-- View Approved Modal -->
        <div id="approvedModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black bg-opacity-50">
            <div class="bg-white rounded-lg shadow-lg w-full max-w-2xl p-6">
                <div class="flex justify-between items-center border-b pb-2 mb-4">
                    <h3 class="text-lg font-semibold text-gray-800">Stored Approved Entries</h3>
                    <button onclick="closeViewApprovedModal()"
                        class="text-gray-500 hover:text-gray-800 text-xl">&times;</button>
                </div>
                <div class="overflow-y-auto max-h-[400px]">
                    <table class="min-w-full text-sm table-auto border rounded-lg">
                        <thead class="bg-gray-200 text-left text-xs font-semibold text-gray-700 sticky top-0">
                            <tr>
                                <th class="border px-3 py-2">Type</th>
                                <th class="border px-3 py-2">Last Name</th>
                                <th class="border px-3 py-2">First Name</th>
                                <th class="border px-3 py-2">Date</th>
                                <th class="border px-3 py-2">Earliest Time</th>
                                <th class="border px-3 py-2">Latest Time</th>
                                <th class="border px-3 py-2">Action</th>
                            </tr>
                        </thead>
                        <tbody id="approvedModalBody" class="text-gray-800 divide-y divide-gray-100">
                            <!-- Entries injected by JS -->
                        </tbody>
                    </table>
                </div>
                <div class="flex justify-between items-center pt-4">
                    <span id="approved-modal-count" class="text-sm text-gray-600">Total Approved: 0</span>
                    <div class="space-x-2">
                        <button onclick="finalizeApprovedEntries()"
                            class="bg-green-600 hover:bg-green-700 text-white text-sm px-4 py-2 rounded shadow-md">
                            Finalize
                        </button>
                        <button onclick="closeViewApprovedModal()"
                            class="bg-gray-300 hover:bg-gray-400 text-sm px-4 py-2 rounded shadow-md">
                            Close
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Edit Employee Modal -->
        <x-modal name="edit-overtime" focusable>
            <div class="p-8 bg-white rounded-xl">
                <div class="mb-6">
                    <h2 class="text-2xl font-bold text-gray-900 mb-2">Edit Employee</h2>
                    <p class="text-gray-600">Update employee information and details</p>
                </div>

                <!-- Restore Original Schedule -->
                <div class="pt-4 mb-6 mt-3 border-t border-gray-200">
                    <button type="button" onclick="setOriginalSchedule();"
                        class="px-5 py-2 text-sm text-white bg-yellow-500 rounded-lg hover:bg-yellow-600 focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:ring-offset-2 transition">
                        Set Original Schedule
                    </button>
                </div>

                <div class="space-y-6">
                    <!-- Schedule -->
                    <div>
                        <label for="earliest_time" class="block text-sm font-semibold text-gray-700 mb-2">
                            Earliest Time
                        </label>
                        <input id="earliest_time" type="time"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50 text-gray-600"
                            step="60" min="00:00:00" max="23:59:59" required>
                    </div>

                    <!-- Latest Time -->
                    <div>
                        <label for="latest_time" class="block text-sm font-semibold text-gray-700 mb-2">
                            Latest Time
                        </label>
                        <input id="latest_time" type="time"
                            class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50 text-gray-600"
                            step="60" min="00:00:00" max="23:59:59" required>
                    </div>

                    <!-- Modal Actions -->
                    <div class="flex justify-end space-x-3 mt-8 pt-6 border-t border-gray-200">
                        <button x-on:click="$dispatch('close')" type="button"
                            class="px-6 py-3 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200">
                            Cancel
                        </button>
                        <button type="button" x-on:click="$dispatch('close')"
                            class="px-6 py-3 text-white bg-gradient-to-r from-green-600 to-green-700 rounded-lg hover:from-green-700 hover:to-green-800 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transform transition-all duration-200 hover:scale-105"
                            onclick="updateFunction();">
                            Save & Approved
                        </button>
                    </div>
                </div>
            </div>
        </x-modal>

    </div>

    <!-- JavaScript -->
    <script>
        let dataDetails;
        const userId = "{{ Auth::user()->id ?? '' }}";
        const userRole = "{{ Auth::user()->role ?? '' }}";
        loadOvertime('Pending');

        function loadOvertime(status = 'Pending') {
            if ($.fn.DataTable.isDataTable('#overtime-table')) {
                $('#overtime-table').DataTable().destroy();
            }
            $.ajax({
                url: "{{ route('department.getUserDepartment') }}",
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    let departmentName = !data.success ? 'N/A' : data.data.department_name;

                    let dataDetails = {
                        status: status,
                        userRole: userRole
                    };

                    if (userRole === 'user') {
                        dataDetails.department = departmentName;
                    }
                    setTimeout(() => {
                        $('#overtime-table').DataTable({
                            processing: true,
                            serverSide: true,
                            autoWidth: false,
                            responsive: true,
                            lengthChange: true, // only keep this
                            lengthMenu: [10, 20, 50], // page length options
                            pageLength: 50, // default rows per page
                            dom: '<"flex justify-between items-center mb-4"Bf>rt<"flex justify-between items-center mt-4"ip>',

                            ajax: {
                                url: "{{ route('overtime.fetch') }}",
                                data: dataDetails
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
                                    columns: ':not(:last-child)', // hide last "action" column
                                    columnText: function(dt, idx, title) {
                                        // If no title, define one manually
                                        const defaultTitles = [
                                            'ID', 'First Name', 'Last Name',
                                            'Department',
                                            'Area', 'Date', 'Earliest Time',
                                            'Latest Time',
                                            'Schedule', 'ORD OT', 'ORD ND',
                                            'ORD ND OT', 'RD OT',
                                            'RD ND',
                                            'RD ND OT', 'RD', 'Late', 'Late Hours',
                                            'Late Minutes',
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
                                    className: 'px-6 py-4 text-sm font-bold text-gray-900 border-r border-gray-100 text-center'
                                },
                                {
                                    data: 'last_name',
                                    name: 'last_name',
                                    className: 'px-6 py-4 text-sm text-gray-900 border-r border-gray-100'
                                },
                                {
                                    data: 'first_name',
                                    name: 'first_name',
                                    className: 'px-6 py-4 text-sm text-gray-900 border-r border-gray-100'
                                },
                                {
                                    data: 'department',
                                    name: 'department',
                                    className: 'px-6 py-4 text-sm text-gray-900 border-r border-gray-100 text-center',
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
                                    data: 'attendance_area',
                                    name: 'attendance_area',
                                    className: 'px-6 py-4 text-sm text-gray-800 border-r border-gray-100 text-center'
                                }, {
                                    data: 'record_date',
                                    name: 'record_date',
                                    className: 'px-6 py-4 text-sm text-gray-800 border-r border-gray-100 text-center',
                                    render: function(data) {
                                        if (!data) return '';
                                        // Keep only the date part before the space
                                        return data.split(' ')[0];
                                    }
                                },
                                {
                                    data: 'earliest_time',
                                    name: 'earliest_time',
                                    className: 'px-6 py-4 text-sm text-gray-800 border-r border-gray-100'
                                },
                                {
                                    data: 'latest_time',
                                    name: 'latest_time',
                                    className: 'px-6 py-4 text-sm text-gray-800 border-r border-gray-100'
                                },
                                {
                                    data: 'schedule',
                                    name: 'schedule',
                                    className: 'px-6 py-4 text-sm text-gray-800 border-r border-gray-100'
                                },
                                {
                                    data: 'schedule_shift',
                                    name: 'schedule_shift',
                                    className: 'px-6 py-4 text-sm text-gray-800 border-r border-gray-100'
                                },
                                {
                                    data: 'ord_ot',
                                    name: 'ord_ot',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100 text-center'
                                },
                                {
                                    data: 'ord_nd',
                                    name: 'ord_nd',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100 text-center'
                                },
                                {
                                    data: 'ord_nd_ot',
                                    name: 'ord_nd_ot',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100 text-center'
                                },
                                {
                                    data: 'rd_ot',
                                    name: 'rd_ot',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100 text-center'
                                },
                                {
                                    data: 'rd_nd',
                                    name: 'rd_nd',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100 text-center'
                                },
                                {
                                    data: 'rd_nd_ot',
                                    name: 'rd_nd_ot',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100 text-center'
                                },
                                {
                                    data: 'rd',
                                    name: 'rd',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100 text-center'
                                }, {
                                    data: 'late',
                                    name: 'late',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100 text-center',
                                    render: function(data, type, row) {
                                        if (data === true || data === 'true' || data ===
                                            1) {
                                            // Late is false → red badge
                                            return `<span class="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">Late</span>`;
                                        } else {
                                            // Late is true → green badge
                                            return `<span class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">Not Late</span>`;
                                        }
                                    }
                                },
                                {
                                    data: 'late_hours',
                                    name: 'late_hours',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100 text-center'
                                },
                                {
                                    data: 'late_minutes',
                                    name: 'late_minutes',
                                    className: 'px-6 py-4 text-sm text-gray-700 border-r border-gray-100 text-center'
                                },
                                {
                                    data: null,
                                    orderable: false,
                                    searchable: false,
                                    className: 'px-6 py-4 text-center',
                                    render: function(data, type, row) {
                                        console.log(row);
                                        let buttonGroup = '';

                                        if (row.status === 'Pending') {
                                            buttonGroup = `
                                                <div class="flex items-center justify-center space-x-3">
                                                    <!-- Approve -->
                                                    <button onclick="approvedOvertimeFunction(${row.id})"
                                                        class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-2 rounded-full shadow-md hover:shadow-lg transition">
                                                        <i class="fas fa-check"></i>
                                                    </button>
                                                    <!-- Edit -->
                                                    <button x-data @click.prevent="$dispatch('open-modal', 'edit-overtime')"
                                                        onclick="editOvertimeFunction(${row.id})"
                                                        class="bg-green-500 hover:bg-green-600 text-white px-3 py-2 rounded-full shadow-md hover:shadow-lg transition">
                                                        <i class="fas fa-edit"></i>
                                                    </button>

                                                    <!-- Cancel -->
                                                    <button onclick="cancelOvertimeFunctio(${row.id})"
                                                        class="bg-red-500 hover:bg-red-600 text-white px-3 py-2 rounded-full shadow-md hover:shadow-lg transition">
                                                        <i class="fas fa-times"></i>
                                                    </button>
                                                </div>`;
                                        } else if (row.status === 'Approved') {
                                            buttonGroup = `
                                            <div class="flex items-center justify-center space-x-2">
                                                <button onclick="cancelOvertimeFunctio(${row.id})"
                                                    class="bg-red-600 hover:bg-red-700 text-white px-3 py-2 rounded-full shadow-md hover:shadow-lg transition">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            </div>`;
                                        } else if (row.status === 'Cancelled') {
                                            buttonGroup = `
                                                <div class="flex items-center justify-center space-x-2">
                                                    <button onclick="handleRedo(${row.id})"
                                                        class="bg-yellow-500 hover:bg-yellow-600 text-white px-3 py-2 rounded-full shadow-md hover:shadow-lg transition">
                                                        <i class="fas fa-undo"></i>
                                                    </button>
                                                </div>`;
                                        }

                                        return buttonGroup;
                                    }

                                }
                            ],
                            language: {
                                emptyTable: "No records available",
                                info: "Showing _START_ to _END_ of _TOTAL_ entries",
                                paginate: {
                                    first: "First",
                                    last: "Last",
                                    next: "Next",
                                    previous: "Previous"
                                }
                            },
                            pageLength: 30
                        });
                    }, 150);
                },
                error: function(xhr, status, error) {
                    console.error('Error:', error);
                }
            });
        }

        function setOriginalSchedule() {
            let [earliestHour, latestHour] = scheduleContainer.split('-');

            // Convert to 12-hour format with AM/PM text display (for alert/info)
            const formatTo12Hour = (hour) => {
                let period = hour >= 12 ? 'PM' : 'AM';
                let formattedHour = hour % 12 || 12; // Convert 0 or 12 → 12
                return `${formattedHour}:00 ${period}`;
            };

            // Convert to proper input values (still 24h format because <input type="time"> requires it)
            const toInputTime = (hour) => hour.toString().padStart(2, '0') + ":00";

            // alert(toInputTime(earliestHour));
            console.log(`${formatTo12Hour(earliestHour)} ${formatTo12Hour(latestHour)} ${scheduleContainer}`);


            // Assign to inputs
            document.getElementById('earliest_time').value = toInputTime(earliestHour);
            document.getElementById('latest_time').value = toInputTime(latestHour);
        }

        function deleteOvertimeFunction(id) {
            alert(id);
            // Swal.fire({
            //     title: "Are you sure?",
            //     text: "This overtime entry will be permanently deleted.",
            //     icon: "warning",
            //     showCancelButton: true,
            //     confirmButtonColor: "#3085d6",
            //     cancelButtonColor: "#d33",
            //     confirmButtonText: "Yes, delete it!"
            // }).then((result) => {
            //     if (result.isConfirmed) {
            //         $.ajax({
            //             url: `/overtime/${id}`,
            //             type: "DELETE",
            //             data: {
            //                 _token: "{{ csrf_token() }}"
            //             },
            //             success: function(response) {
            //                 if (response.success) {
            //                     Swal.fire({
            //                         title: "Deleted!",
            //                         text: response.message,
            //                         icon: "success",
            //                         timer: 2000,
            //                         showConfirmButton: false
            //                     });
            //                     $('#overtime-table').DataTable().ajax.reload();
            //                     loadOvertimeCounts();
            //                 } else {
            //                     Swal.fire("Failed!", response.message, "error");
            //                 }
            //             },
            //             error: function(xhr) {
            //                 Swal.fire("Error!", "An error occurred: " + xhr.responseText, "error");
            //             }
            //         });
            //     }
            // });
        }

        function approvedOvertimeFunction(id) {
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
                        url: `/overtime/${id}/approved`,
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
                                $('#overtime-table').DataTable().ajax.reload();
                                loadOvertimeCounts();
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
        let globalId;
        let scheduleContainer = '';

        function editOvertimeFunction(id) {
            globalId = id;
            $.ajax({
                url: `{{ route('overtime.edit', ['id' => ':id']) }}`.replace(':id', id),
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    scheduleContainer = data.schedule;
                    console.log(scheduleContainer);
                    $('#earliest_time').val(data.earliest_time.substring(0, 5));
                    $('#latest_time').val(data.latest_time.substring(0, 5));
                }
            });
        }

        function updateFunction() {
            let earliest_time = $('#earliest_time').val() + ":00";
            let latest_time = $('#latest_time').val() + ":00";


            $.ajax({
                url: `/overtime/${globalId}`,
                type: "POST",
                data: {
                    _token: "{{ csrf_token() }}",
                    earliest_time: earliest_time,
                    latest_time: latest_time
                },
                success: function(response) {
                    if (response.success) {
                        Swal.fire({
                            icon: "success",
                            title: "Updated!",
                            text: response.message,
                            timer: 2000,
                            showConfirmButton: false
                        });
                        $('#overtime-table').DataTable().ajax.reload();
                        loadOvertimeCounts();
                    } else {
                        Swal.fire("Error", response.message, "error");
                    }
                },
                error: function(xhr) {
                    Swal.fire("Error", xhr.responseText, "error");
                }
            });
        }
        loadOvertimeCounts();

        function loadOvertimeCounts() {
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
                        url: "{{ route('overtime.counts') }}",
                        type: "GET",
                        data: {
                            userRole: userRole,
                            department: departmentName // only used if userRole = 'user'
                        },
                        success: function(response) {
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


        function cancelOvertimeFunctio(id) {
            Swal.fire({
                title: "Are you sure?",
                text: "This overtime will be marked as Cancelled.",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#3085d6",
                cancelButtonColor: "#d33",
                confirmButtonText: "Yes, cancel it!"
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        url: `/overtime/${id}/cancelled`,
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
                                $('#overtime-table').DataTable().ajax.reload();
                                loadOvertimeCounts();
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
    </script>
</x-app-layout>

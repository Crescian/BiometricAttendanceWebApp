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
    <x-approval-table-assets />
    {{-- <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Overtime Approval') }}
        </h2>
    </x-slot> --}}

    {{-- <div class="loader-overlay" id="loaderOverlay">
        <div class="loader"></div>
    </div> --}}

    <div class="px-2 lg:px-4">
        <!-- Page header + toolbar -->
        <div class="flex flex-wrap items-center justify-between gap-3 px-4 pt-4 pb-3">
            <h1 class="text-xl font-semibold text-gray-900">{{ __('Overtime') }}</h1>
            <div class="flex flex-wrap items-center gap-2">
                <x-bulk-approve prefix="ot" table="#overtime-table" title="overtime"
                    one="overtime record" many="overtime records" on-done="loadOvertimeCounts"
                    :approve-url="route('overtime.bulkApprove')" :options-url="route('overtime.bulkOptions')"
                    :approve-by-url="route('overtime.bulkApproveBy')" />
                <div class="relative">
                    <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs"></i>
                    <input id="ot-search" type="search" placeholder="Search"
                        class="w-48 pl-8 pr-3 py-1.5 text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500">
                </div>
                <div id="ot-toolbar-buttons" class="flex items-center gap-2"></div>
            </div>
        </div>

        <!-- Table card -->
        <div class="px-4 pb-4">
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm">
                <!-- Status filter -->
                <x-status-tabs loader="loadOvertime" />

                <div class="p-2 text-gray-900">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="overtime-table" class="modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th class="noVis" style="width: 2.5rem;">
                                            <input type="checkbox" id="ot-select-all" title="Select all on this page"
                                                class="rounded border-gray-300 text-green-600 focus:ring-green-500">
                                        </th>
                                        <th>ID</th>
                                        <th>Employee</th>
                                        <th>First Name</th>
                                        <th>Department</th>
                                        <th>Area</th>
                                        <th>Date</th>
                                        <th>Earliest Time</th>
                                        <th>Latest Time</th>
                                        <th>Schedule</th>
                                        <th>Schedule Shift</th>
                                        <th>ORD-OT</th>
                                        <th>ORD-ND</th>
                                        <th>ORD-ND-OT</th>
                                        <th>RD-OT</th>
                                        <th>RD-ND</th>
                                        <th>RD-ND-OT</th>
                                        <th>RD</th>
                                        <th>Late</th>
                                        <th>Late Hours</th>
                                        <th>Late Minutes</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody id="overtime-body"></tbody>
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
        bindTableSearch('#ot-search', '#overtime-table');

        function loadOvertime(status = 'Pending') {
            bulk_ot.setStatus(status);

            if ($.fn.DataTable.isDataTable('#overtime-table')) {
                $('#overtime-table').DataTable().destroy();
            }
            $('#ot-toolbar-buttons').empty();
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
                        const table = $('#overtime-table').DataTable({
                            processing: true,
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
                                search: $('#ot-search').val() || ''
                            },
                            order: [
                                [2, 'asc']
                            ],
                            ajax: {
                                url: "{{ route('overtime.fetch') }}",
                                data: dataDetails
                            },
                            drawCallback: function() {
                                bulk_ot.syncSelectAll();
                            },
                            buttons: exportAndColumnButtons(),
                            columns: [
                                expandControlColumn,
                                bulk_ot.checkboxColumn(),
                                {
                                    data: 'unique_id',
                                    name: 'unique_id',
                                    className: 'font-semibold text-gray-900'
                                },
                                {
                                    data: 'last_name',
                                    name: 'last_name',
                                    className: 'all',
                                    render: function(data, type, row) {
                                        return type === 'display' ? employeeCell(row.last_name, row.first_name) :
                                            `${row.last_name || ''}, ${row.first_name || ''}`;
                                    }
                                },
                                {
                                    // Hidden; kept so searching by first name still works
                                    data: 'first_name',
                                    name: 'first_name',
                                    visible: false,
                                    className: 'noVis never'
                                },
                                {
                                    data: 'department',
                                    name: 'department',
                                    render: function(data, type, row) {
                                        if (!data || data.trim() === '' || data ===
                                            'Not Assigned') {
                                            return `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-gray-300 text-gray-800">Not Assigned</span>`;
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

                                        return `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full ${colorClass}">${data}</span>`;
                                    }
                                },
                                {
                                    data: 'attendance_area',
                                    name: 'attendance_area'
                                },
                                {
                                    data: 'record_date',
                                    name: 'record_date',
                                    render: function(data) {
                                        if (!data) return '';
                                        // Keep only the date part before the space
                                        return data.split(' ')[0];
                                    }
                                },
                                { data: 'earliest_time', name: 'earliest_time' },
                                { data: 'latest_time', name: 'latest_time' },
                                { data: 'schedule', name: 'schedule' },
                                { data: 'schedule_shift', name: 'schedule_shift' },
                                { data: 'ord_ot', name: 'ord_ot', className: 'text-center' },
                                { data: 'ord_nd', name: 'ord_nd', className: 'text-center' },
                                { data: 'ord_nd_ot', name: 'ord_nd_ot', className: 'text-center' },
                                { data: 'rd_ot', name: 'rd_ot', className: 'text-center' },
                                { data: 'rd_nd', name: 'rd_nd', className: 'text-center' },
                                { data: 'rd_nd_ot', name: 'rd_nd_ot', className: 'text-center' },
                                { data: 'rd', name: 'rd', className: 'text-center' },
                                {
                                    data: 'late',
                                    name: 'late',
                                    className: 'text-center',
                                    render: function(data) {
                                        if (data === true || data === 'true' || data === 1) {
                                            return `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-red-100 text-red-800">Late</span>`;
                                        }
                                        return `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-green-100 text-green-800">Not Late</span>`;
                                    }
                                },
                                { data: 'late_hours', name: 'late_hours', className: 'text-center' },
                                { data: 'late_minutes', name: 'late_minutes', className: 'text-center' },
                                {
                                    data: null,
                                    orderable: false,
                                    searchable: false,
                                    className: 'noVis all text-center',
                                    render: function(data, type, row) {
                                        if (row.status === 'Pending') {
                                            return `
                                                <div class="flex items-center justify-center gap-1.5">
                                                    <button type="button" title="Approve" onclick="approvedOvertimeFunction(${row.id})" class="row-btn approve">
                                                        <i class="fas fa-check"></i>
                                                    </button>
                                                    <button type="button" title="Edit time" x-data @click.prevent="$dispatch('open-modal', 'edit-overtime')"
                                                        onclick="editOvertimeFunction(${row.id})" class="row-btn edit">
                                                        <i class="fas fa-pen"></i>
                                                    </button>
                                                    <button type="button" title="Cancel" onclick="cancelOvertimeFunctio(${row.id})" class="row-btn cancel">
                                                        <i class="fas fa-times"></i>
                                                    </button>
                                                </div>`;
                                        }
                                        if (row.status === 'Approved') {
                                            return `
                                                <div class="flex items-center justify-center">
                                                    <button type="button" title="Cancel" onclick="cancelOvertimeFunctio(${row.id})" class="row-btn cancel">
                                                        <i class="fas fa-times"></i>
                                                    </button>
                                                </div>`;
                                        }
                                        if (row.status === 'Cancelled') {
                                            return `
                                                <div class="flex items-center justify-center">
                                                    <button type="button" title="Restore" onclick="handleRedo(${row.id})" class="row-btn restore">
                                                        <i class="fas fa-undo"></i>
                                                    </button>
                                                </div>`;
                                        }
                                        return '';
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
                        table.buttons().container().appendTo('#ot-toolbar-buttons');
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

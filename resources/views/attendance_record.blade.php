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
    <div class="px-2 lg:px-4">

        <div class="loader-overlay" id="loaderOverlay">
            <div class="loader"></div>
        </div>

        <!-- Page header + toolbar -->
        <div class="flex flex-wrap items-center justify-between gap-3 px-4 pt-4 pb-3">
            <h1 class="text-xl font-semibold text-gray-900">{{ __('Attendance Records') }}</h1>
            <div class="flex flex-wrap items-center gap-2">
                @if ((Auth::user()->role ?? '') === 'admin')
                    <button type="button" onclick="openManualAttendanceModal();"
                        class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-white bg-green-600 rounded-md hover:bg-green-700 shadow-sm">
                        <i class="fa-regular fa-clock"></i>
                        Add Time In / Out
                    </button>
                @endif
                <div class="relative">
                    <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs"></i>
                    <input id="ar-search" type="search" placeholder="Search"
                        class="w-48 pl-8 pr-3 py-1.5 text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500">
                </div>
                <div id="ar-toolbar-buttons" class="flex items-center gap-2"></div>
            </div>
        </div>

        <!-- Table card -->
        <div class="px-4 pb-4">
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm">
                <div class="p-2 text-gray-900">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="attendance-record-table" class="modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th>Employee</th>
                                        <th>Department</th>
                                        <th>Report To</th>
                                        <th>Schedule Shift</th>
                                        <th>Area</th>
                                        <th>Date</th>
                                        <th>Earliest Time</th>
                                        <th>Latest Time</th>
                                        <th>Weekday</th>
                                        <th>Leaves</th>
                                        @if ((Auth::user()->role ?? '') === 'admin')
                                            <th>Action</th>
                                        @endif
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        @if ((Auth::user()->role ?? '') === 'admin')
            <!-- Manual Time In / Time Out Modal -->
            <div id="manualAttendanceModal"
                class="fixed inset-0 z-50 hidden items-center justify-center bg-black bg-opacity-50">
                <div class="bg-white rounded-lg shadow-lg w-full max-w-lg p-6">
                    <div class="flex justify-between items-center border-b pb-2 mb-4">
                        <h3 id="manualAttendanceTitle" class="text-lg font-semibold text-gray-800">Add Time In / Time Out</h3>
                        <button onclick="closeManualAttendanceModal()"
                            class="text-gray-500 hover:text-gray-800 text-xl">&times;</button>
                    </div>

                    <input type="hidden" id="manual_record_id">

                    <div class="space-y-4">
                        <div>
                            <label for="manual_employee" class="block text-sm font-semibold text-gray-700">Employee Name</label>
                            <select id="manual_employee"
                                class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 text-sm">
                            </select>
                            <input type="text" id="manual_employee_readonly" readonly
                                class="hidden mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100 text-sm">
                        </div>

                        <div>
                            <label for="manual_record_date" class="block text-sm font-semibold text-gray-700">Record Date</label>
                            <input type="date" id="manual_record_date"
                                min="{{ $period['start'] ?? '' }}" max="{{ $period['end'] ?? '' }}"
                                class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 text-sm">
                            <p class="mt-1 text-xs text-gray-500">
                                @if (!empty($period['start']) && !empty($period['end']))
                                    Payroll period: {{ $period['start'] }} to {{ $period['end'] }}
                                @else
                                    No payroll period set on the active biometric import.
                                @endif
                            </p>
                        </div>

                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label for="manual_earliest_time" class="block text-sm font-semibold text-gray-700">Time In</label>
                                <input type="time" id="manual_earliest_time"
                                    class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 text-sm">
                            </div>
                            <div>
                                <label for="manual_latest_time" class="block text-sm font-semibold text-gray-700">Time Out</label>
                                <input type="time" id="manual_latest_time"
                                    class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-green-500 focus:border-green-500 text-sm">
                            </div>
                            <p class="col-span-2 text-xs text-gray-500">
                                A Time Out earlier than Time In is treated as an overnight shift (next day).
                            </p>
                        </div>

                        <p id="manualOriginalTimes" class="hidden text-xs text-gray-600 bg-gray-50 border rounded p-2"></p>
                    </div>

                    <div class="flex justify-end space-x-4 pt-6">
                        <button type="button" onclick="closeManualAttendanceModal()"
                            class="bg-gray-300 hover:bg-gray-400 text-sm px-4 py-2 rounded shadow-md">
                            Cancel
                        </button>
                        <button type="button" id="manualAttendanceSubmit" onclick="submitManualAttendance();"
                            class="bg-green-600 hover:bg-green-700 text-white text-sm px-4 py-2 rounded shadow-md">
                            Save
                        </button>
                    </div>
                </div>
            </div>
        @endif

    </div>
    <!-- JavaScript -->
    <script>
        let getUniqueId;
        const userId = "{{ Auth::user()->id ?? '' }}";
        const userRole = "{{ Auth::user()->role ?? '' }}";
        $('#loaderOverlay').hide();
        loadEmployeeName();
        loadAttendanceRecord('Pending');
        bindTableSearch('#ar-search', '#attendance-record-table');

        function loadAttendanceRecord(status = 'Pending') {
            if ($.fn.DataTable.isDataTable('#attendance-record-table')) {
                $('#attendance-record-table').DataTable().clear().destroy();
            }
            $('#ar-toolbar-buttons').empty();

            $.ajax({
                url: "{{ route('department.getUserDepartment') }}",
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    let departmentName = !data.success ? 'N/A' : data.data.department_name;

                    setTimeout(() => {
                        const table = $('#attendance-record-table').DataTable({
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
                                search: $('#ar-search').val() || ''
                            },
                            order: [
                                [1, 'asc']
                            ],
                            ajax: {
                                url: "{{ route('attendance-record.fetch') }}",
                                data: function(d) {
                                    d.userRole = userRole;
                                    if (userRole === 'user') {
                                        d.department = departmentName;
                                    }
                                }
                            },
                            buttons: exportAndColumnButtons(),
                            columns: [
                                expandControlColumn,
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
                                    name: 'employee_management.department',
                                    render: function(data, type) {
                                        return type === 'display' ? colorBadgeCell(data) : data;
                                    }
                                },
                                {
                                    data: 'report_to',
                                    name: 'employee_management.report_to',
                                    render: function(data, type) {
                                        return type === 'display' ? colorBadgeCell(data) : data;
                                    }
                                },
                                {
                                    data: 'schedule_shift',
                                    name: 'employee_management.schedule_shift'
                                },
                                {
                                    data: 'attendance_area',
                                    name: 'attendance_records.attendance_area',
                                    render: function(data, type, row) {
                                        if (data === 'COA') {
                                            return '<span class="px-1.5 py-0.5 text-[11px] font-semibold text-white bg-green-600 rounded-full">COA</span>';
                                        } else if (data === 'MANUAL') {
                                            return '<span class="px-1.5 py-0.5 text-[11px] font-semibold text-white bg-blue-600 rounded-full">MANUAL</span>';
                                        } else {
                                            return `<span class="px-1.5 py-0.5 text-[11px] font-semibold text-gray-700 bg-gray-200 rounded-full">${data || ''}</span>`;
                                        }
                                    }
                                },
                                {
                                    data: 'record_date',
                                    name: 'attendance_records.record_date',
                                    render: dateOnlyCell
                                },
                                {
                                    data: 'earliest_time',
                                    name: 'attendance_records.earliest_time',
                                    render: renderEditedTime('original_earliest_time')
                                },
                                {
                                    data: 'latest_time',
                                    name: 'attendance_records.latest_time',
                                    render: renderEditedTime('original_latest_time')
                                },
                                {
                                    data: 'weekday',
                                    name: 'attendance_records.weekday'
                                },
                                {
                                    data: 'leaves',
                                    name: 'attendance_records.leaves',
                                    className: 'text-center',
                                    render: function(data, type) {
                                        const yes = data === true || data === 'true' || data === 1 || data === '1';
                                        if (type !== 'display') return yes ? 'Yes' : 'No';
                                        return yes ?
                                            `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-yellow-100 text-yellow-800">Yes</span>` :
                                            `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-gray-100 text-gray-600">No</span>`;
                                    }
                                },
                                ...(userRole === 'admin' ? [{
                                    data: null,
                                    orderable: false,
                                    searchable: false,
                                    className: 'noVis all text-center',
                                    render: function(data, type, row) {
                                        return `
                                            <div class="flex items-center justify-center">
                                                <button type="button" title="Edit time in / out" class="row-btn edit"
                                                    onclick='openManualAttendanceModal(${JSON.stringify(row).replace(/'/g, "&#39;")});'>
                                                    <i class="fas fa-pen"></i>
                                                </button>
                                            </div>`;
                                    }
                                }] : [])
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
                        table.buttons().container().appendTo('#ar-toolbar-buttons');
                    }, 150);
                },
                error: function(xhr, status, error) {
                    console.error('Error:', error);
                }
            });
        }

        // Load initially
        // loadAttendanceRecord('Pending');

        function loadEmployeeName() {
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
                            $('#manual_employee').html('<option value="">Select an Employee Name...</option>');
                            response.forEach(function(item) {
                                $('#manual_employee').append(
                                    `<option value="${item.id}">${item.employee_name}</option>`
                                );
                            });
                        }
                    });
                }
            });
        }

        /** -----------------------------
         *  MANUAL TIME IN / TIME OUT
         * ------------------------------*/
        function renderEditedTime(originalField) {
            return function(data, type, row) {
                if (type !== 'display' || !row.edited_at || row.original_earliest_time === null) {
                    return data || '';
                }
                const tip = `Original: ${row[originalField] || '-'} | Edited by ${row.edited_by || '-'} on ${String(row.edited_at).substring(0, 16)}`;
                return `${data || ''} <span title="${tip}" class="ml-1 px-1.5 py-0.5 text-[10px] font-semibold text-amber-800 bg-amber-100 rounded cursor-help">Edited</span>`;
            };
        }

        // hh:mm:ss / hh:mm -> hh:mm for <input type="time">
        function toTimeInput(value) {
            return value ? String(value).substring(0, 5) : '';
        }

        function openManualAttendanceModal(row = null) {
            const isEdit = !!row;

            $('#manual_record_id').val(isEdit ? row.id : '');
            $('#manualAttendanceTitle').text(isEdit ? 'Edit Time In / Time Out' : 'Add Time In / Time Out');
            $('#manual_employee').toggleClass('hidden', isEdit).val('');
            $('#manual_employee_readonly').toggleClass('hidden', !isEdit).val(isEdit ? row.employee_name : '');
            $('#manual_record_date').val(isEdit ? String(row.record_date).substring(0, 10) : '')
                .prop('readonly', isEdit).toggleClass('bg-gray-100', isEdit);
            $('#manual_earliest_time').val(isEdit ? toTimeInput(row.earliest_time) : '');
            $('#manual_latest_time').val(isEdit ? toTimeInput(row.latest_time) : '');

            if (isEdit && row.original_earliest_time !== null && row.edited_at) {
                $('#manualOriginalTimes').removeClass('hidden').text(
                    `Original punches: ${row.original_earliest_time || '-'} to ${row.original_latest_time || '-'}. ` +
                    `Last edited by ${row.edited_by || '-'} on ${String(row.edited_at).substring(0, 16)}.`
                );
            } else {
                $('#manualOriginalTimes').addClass('hidden').text('');
            }

            document.getElementById('manualAttendanceModal').classList.replace('hidden', 'flex');
        }

        function closeManualAttendanceModal() {
            document.getElementById('manualAttendanceModal').classList.replace('flex', 'hidden');
        }

        function submitManualAttendance() {
            const id = $('#manual_record_id').val();
            const payload = {
                earliest_time: $('#manual_earliest_time').val(),
                latest_time: $('#manual_latest_time').val()
            };

            if (!id) {
                payload.employee_management_id = $('#manual_employee').val();
                payload.record_date = $('#manual_record_date').val();

                if (!payload.employee_management_id || !payload.record_date) {
                    Swal.fire('Missing fields', 'Select an employee and a record date.', 'warning');
                    return;
                }
            }

            if (!payload.earliest_time || !payload.latest_time) {
                Swal.fire('Missing fields', 'Enter both Time In and Time Out.', 'warning');
                return;
            }

            $('#manualAttendanceSubmit').prop('disabled', true);

            $.ajax({
                url: id ? `/attendance-record/${id}` : "{{ route('attendance-record.store') }}",
                type: 'POST',
                headers: {
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
                },
                data: payload,
                success: function(response) {
                    closeManualAttendanceModal();
                    Swal.fire({
                        icon: 'success',
                        title: response.message,
                        showConfirmButton: false,
                        timer: 1500
                    });
                    $('#attendance-record-table').DataTable().ajax.reload(null, false);
                },
                error: function(xhr) {
                    const json = xhr.responseJSON || {};
                    const firstError = json.errors ? Object.values(json.errors)[0][0] : null;
                    Swal.fire('Error', firstError || json.message || 'Something went wrong. Please try again.', 'error');
                },
                complete: function() {
                    $('#manualAttendanceSubmit').prop('disabled', false);
                }
            });
        }
    </script>
</x-app-layout>

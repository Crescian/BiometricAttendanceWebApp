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
    <div class="px-16 py-5">

        <div class="loader-overlay" id="loaderOverlay">
            <div class="loader"></div>
        </div>

        <!-- Table Section inside Card -->
        <div class="p-6">
            <div class="bg-white shadow-lg rounded-lg border border-gray-200">
                <!-- Card Header -->
                <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
                    <h2 class="font-bold text-3xl">
                        <i class="fa-regular fa-clone text-3xl" style="color: #8DE11A; font-size: 40px"></i>
                        {{ __('Attendance Record') }}
                    </h2>

                    <div class="flex items-center space-x-3">
                    @if ((Auth::user()->role ?? '') === 'admin')
                        <button onclick="openManualAttendanceModal();"
                            class="flex items-center px-4 py-2 bg-green-600 text-white font-semibold rounded-lg shadow-sm hover:bg-green-700">
                            <i class="fa-regular fa-clock mr-2"></i>
                            Add Time In / Out
                        </button>
                    @endif
                    </div>
                </div>
                <!-- Table Section inside Card -->
                <div class="p-6 text-gray-900">
                    <div class="border rounded-lg shadow-sm overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="attendance-record-table" class="table-auto w-full text-sm">
                                <thead class="text-white sticky top-0" style="background-color: #00291B;">
                                    <tr>
                                        <th style="width: 10%">Employee Name</th>
                                        <th style="width: 10%">Department</th>
                                        <th style="width: 10%">Report To</th>
                                        <th style="width: 10%">Schedule Shift</th>
                                        <th style="width: 10%">Attendance Area</th>
                                        {{-- <th style="width: 10%">Point Name</th>
                                        <th style="width: 10%">Verification Mode</th> --}}
                                        {{-- <th style="width: 10%">Attendance Photo</th> --}}
                                        <th style="width: 10%">Record Date</th>
                                        <th style="width: 8%">Earliest Time</th>
                                        <th style="width: 8%">Latest Time</th>
                                        <th style="width: 8%">Weekday</th>
                                        <th style="width: 8%">Leaves</th>
                                        @if ((Auth::user()->role ?? '') === 'admin')
                                            <th style="width: 6%">Action</th>
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

        function loadAttendanceRecord(status = 'Pending') {
            if ($.fn.DataTable.isDataTable('#attendance-record-table')) {
                $('#attendance-record-table').DataTable().clear().destroy();
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
                        let table = $('#attendance-record-table').DataTable({
                            processing: true,
                            serverSide: true,
                            autoWidth: false,
                            responsive: true,
                            lengthChange: true, // only keep this
                            lengthMenu: [10, 20, 50], // page length options
                            pageLength: 50, // default rows per page
                            dom: '<"flex justify-between items-center mb-4"Bf>rt<"flex justify-between items-center mt-4"lip>',
                            ajax: {
                                url: "{{ route('attendance-record.fetch') }}",
                                data: function(d) {
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
                                            text: '<i class="fa fa-copy mr-1 text-gray-700"></i> Copy'
                                        },
                                        {
                                            extend: 'excelHtml5',
                                            text: '<i class="fa fa-file-excel mr-1 text-green-600"></i> Excel'
                                        },
                                        {
                                            extend: 'csvHtml5',
                                            text: '<i class="fa fa-file-csv mr-1 text-blue-600"></i> CSV'
                                        },
                                        {
                                            extend: 'pdfHtml5',
                                            text: '<i class="fa fa-file-pdf mr-1 text-red-600"></i> PDF'
                                        },
                                        {
                                            extend: 'print',
                                            text: '<i class="fa fa-print mr-1 text-gray-700"></i> Print'
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
                                        const titles = [
                                            'Employee Name', 'Department',
                                            'Report To',
                                            'Schedule', 'Attendance Area',
                                            'Point Name',
                                            'Verification Mode', 'Record Date',
                                            'Earliest Time', 'Latest Time',
                                            'Weekday', 'Action'
                                        ];
                                        return titles[idx] || `Column ${idx + 1}`;
                                    }
                                }
                            ],
                            columns: [{
                                    data: 'employee_name',
                                    name: 'employee_management.employee_name',
                                    width: "10%"
                                },
                                {
                                    data: 'department',
                                    name: 'employee_management.department',
                                    width: "8%"
                                },
                                {
                                    data: 'report_to',
                                    name: 'employee_management.report_to',
                                    width: "8%"
                                },
                                {
                                    data: 'schedule_shift',
                                    name: 'employee_management.schedule_shift',
                                    width: "8%"
                                }, {
                                    data: 'attendance_area',
                                    name: 'attendance_records.attendance_area',
                                    width: "10%",
                                    render: function(data, type, row) {
                                        if (data === 'COA') {
                                            return '<span class="px-2 py-1 text-xs font-semibold text-white bg-green-600 rounded-full">COA</span>';
                                        } else if (data === 'MANUAL') {
                                            return '<span class="px-2 py-1 text-xs font-semibold text-white bg-blue-600 rounded-full">MANUAL</span>';
                                        } else {
                                            return `<span class="px-2 py-1 text-xs font-semibold text-gray-700 bg-gray-200 rounded-full">${data || ''}</span>`;
                                        }
                                    }
                                },

                                // {
                                //     data: 'attendance_point_name',
                                //     name: 'attendance_records.attendance_point_name',
                                //     width: "10%"
                                // },
                                // {
                                //     data: 'verification_mode',
                                //     name: 'attendance_records.verification_mode',
                                //     width: "8%"
                                // },
                                {
                                    data: 'record_date',
                                    name: 'attendance_records.record_date',
                                    width: "8%",
                                    render: function(data) {
                                        if (!data) return '';
                                        // Keep only the date part before the space
                                        return data.split(' ')[0];
                                    }
                                },
                                {
                                    data: 'earliest_time',
                                    name: 'attendance_records.earliest_time',
                                    width: "8%",
                                    render: renderEditedTime('original_earliest_time')
                                },
                                {
                                    data: 'latest_time',
                                    name: 'attendance_records.latest_time',
                                    width: "8%",
                                    render: renderEditedTime('original_latest_time')
                                },
                                {
                                    data: 'weekday',
                                    name: 'attendance_records.weekday',
                                    width: "8%"
                                },
                                {
                                    data: 'leaves',
                                    name: 'attendance_records.leaves',
                                    width: "8%"
                                },
                                ...(userRole === 'admin' ? [{
                                    data: null,
                                    orderable: false,
                                    searchable: false,
                                    width: "6%",
                                    render: function(data, type, row) {
                                        return `
                                    <div class="flex justify-center">
                                        <button onclick='openManualAttendanceModal(${JSON.stringify(row).replace(/'/g, "&#39;")});'
                                            class="px-3 py-1 bg-blue-600 text-white text-sm rounded hover:bg-blue-700">
                                            Edit
                                        </button>
                                    </div>`;
                                    }
                                }] : []),
                                // {
                                //     data: null,
                                //     orderable: false,
                                //     searchable: false,
                                //     width: "6%",
                                //     render: function(data, type, row) {
                                //         return `
                                //     <div class="flex justify-center space-x-2">
                                //         <button onclick="viewRecord(${row.id});"
                                //             class="px-3 py-1 bg-blue-600 text-white text-sm rounded hover:bg-blue-700">
                                //             View
                                //         </button>
                                //     </div>`;
                                //     }
                                // }
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

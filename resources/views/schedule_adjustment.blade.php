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

    <div class="px-2 lg:px-4">

        <div class="loader-overlay" id="loaderOverlay">
            <div class="loader"></div>
        </div>

        <!-- Page header + toolbar -->
        <div class="flex flex-wrap items-center justify-between gap-3 px-4 pt-4 pb-3">
            <h1 class="text-xl font-semibold text-gray-900">{{ __('Schedule Adjustments') }}</h1>
            <div class="flex flex-wrap items-center gap-2">
                <button type="button" onclick="viewScheduleModal();"
                    class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-green-700 bg-white border border-green-600 rounded-md hover:bg-green-50">
                    <i class="fa-regular fa-calendar"></i>
                    View Schedule
                </button>
                <button type="button" onclick="openAddScheduleAdjustmentModal();"
                    class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-white bg-green-600 rounded-md hover:bg-green-700 shadow-sm">
                    <i class="fa-solid fa-plus"></i>
                    Add
                </button>
                <x-bulk-approve prefix="sa" table="#schedule-adjustment-table" pending="Pending" title="schedule adjustments"
                    one="schedule adjustment" many="schedule adjustments" on-done="loadScheduleAdjustmentCounts"
                    :approve-url="route('scheduleAdjustment.bulkApprove')" :options-url="route('scheduleAdjustment.bulkOptions')"
                    :approve-by-url="route('scheduleAdjustment.bulkApproveBy')" />
                <div class="relative">
                    <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs"></i>
                    <input id="sa-search" type="search" placeholder="Search"
                        class="w-48 pl-8 pr-3 py-1.5 text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500">
                </div>
                <div id="sa-toolbar-buttons" class="flex items-center gap-2"></div>
            </div>
        </div>

        <!-- Table card -->
        <div class="px-4 pb-4">
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm">
                <!-- Status filter -->
                <x-status-tabs loader="loadScheduleAdjustmentPage" />

                <div class="p-2 text-gray-900">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="schedule-adjustment-table" class="modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th class="noVis" style="width: 2.5rem;">
                                            <input type="checkbox" id="sa-select-all" title="Select all on this page"
                                                class="rounded border-gray-300 text-green-600 focus:ring-green-500">
                                        </th>
                                        <th>Employee</th>
                                        <th>Department</th>
                                        <th>Report To</th>
                                        <th>Schedule</th>
                                        <th>Others</th>
                                        <th>Reason</th>
                                        <th>Date</th>
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
        <div id="addScheduleAdjustmentModal"
            class="fixed inset-0 z-50 hidden items-center justify-center bg-black bg-opacity-50">
            <div class="bg-white rounded-lg shadow-lg w-full max-w-4xl p-6">
                <!-- Modal Header -->
                <div class="flex justify-between items-center border-b pb-2 mb-4">
                    <h3 class="text-lg font-semibold text-gray-800">Add New Schedule Adjustments</h3>
                    <button onclick="closeAddScheduleAdjustmentModal()"
                        class="text-gray-500 hover:text-gray-800 text-xl">&times;</button>
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
                        <input type="text" id="attendanceCalendar"
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
                    <button type="button" onclick="closeAddScheduleAdjustmentModal()"
                        class="bg-gray-300 hover:bg-gray-400 text-sm px-4 py-2 rounded shadow-md">
                        Cancel
                    </button>
                    <button type="submit" onclick="submitScheduleAdjustment();"
                        class="bg-green-600 hover:bg-green-700 text-white text-sm px-4 py-2 rounded shadow-md">
                        Add Schedule Adjustment
                    </button>
                </div>
            </div>
        </div>
        <!-- View Schedule Modal -->
        <div id="viewScheduleModal"
            class="fixed inset-0 z-50 hidden items-center justify-center bg-black bg-opacity-50">
            <div class="bg-white rounded-xl shadow-2xl w-full max-w-5xl p-8">
                <!-- Modal Header -->
                <div class="flex justify-between items-center border-b pb-3 mb-5">
                    <h3 class="text-2xl font-bold text-gray-800 flex items-center">
                        <i class="fa-solid fa-calendar-days mr-2 text-green-600"></i>
                        View Schedule
                    </h3>
                    <button onclick="closeViewScheduleModal()"
                        class="text-gray-400 hover:text-gray-800 text-2xl transition duration-200">&times;</button>
                </div>

                <!-- Modal Body -->
                <div class="space-y-6">
                    <!-- Schedule Info -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label for="from_time" class="block text-sm font-medium text-gray-700 mb-1">
                                From Time
                            </label>
                            <input type="time" id="from_time" name="from_time"
                                class="w-full border-gray-300 rounded-lg shadow-sm focus:ring-green-500 focus:border-green-500">
                        </div>
                        <div>
                            <label for="to_time" class="block text-sm font-medium text-gray-700 mb-1">
                                To Time
                            </label>
                            <input type="time" id="to_time" name="to_time"
                                class="w-full border-gray-300 rounded-lg shadow-sm focus:ring-green-500 focus:border-green-500">
                        </div>
                        <div>
                            <label for="schedule_type" class="block text-sm font-medium text-gray-700 mb-1">
                                Schedule Type
                            </label>
                            <select id="schedule_type" name="schedule_type"
                                class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                                <option value="">Select Type</option>
                                <option value="Day Shift">Day Shift</option>
                                <option value="Day Shift (No Break)">Day Shift (No Break)</option>
                                <option value="Night Shift">Night Shift</option>
                                <option value="Night Shift (No Break)">Night Shift (No Break)</option>
                                <option value="Day Shift (Compressed)">Day Shift (Compressed)</option>
                                <option value="Night Shift (Compressed)">Night Shift (Compressed)</option>
                            </select>
                        </div>
                        <div>
                            <label for="schedule_shift" class="block text-sm font-medium text-gray-700 mb-1">
                                Schedule Shift
                            </label>
                            <select id="schedule_shift" name="schedule_shift"
                                class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                                <option value="">Select Shift</option>
                                <option value="Day Shift">Day Shift</option>
                                <option value="Night Shift">Night Shift</option>
                            </select>
                        </div>
                    </div>

                    <!-- Schedule List Table -->
                    <div class="overflow-x-auto">
                        <table class="min-w-full border border-gray-200 rounded-lg overflow-hidden mt-6">
                            <thead class="bg-green-600 text-white">
                                <tr>
                                    <th class="px-4 py-2 text-center">#</th>
                                    <th class="px-6 py-3 text-left text-sm font-semibold">Schedule Name</th>
                                    <th class="px-6 py-3 text-left text-sm font-semibold">Schedule Type</th>
                                    <th class="px-6 py-3 text-left text-sm font-semibold">Schedule Shift</th>
                                    <th class="px-6 py-3 text-left text-sm font-semibold">Action</th>
                                </tr>
                            </thead>
                            <tbody id="scheduleTableBody" class="divide-y divide-gray-200 text-gray-700">

                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Modal Footer -->
                <div class="flex justify-end space-x-4 pt-6 border-t mt-8">
                    <button type="button" onclick="closeViewScheduleModal()"
                        class="bg-gray-300 hover:bg-gray-400 text-gray-800 text-sm px-5 py-2.5 rounded-lg shadow transition duration-150">
                        Cancel
                    </button>
                    <button type="submit" onclick="submitViewSchedule();"
                        class="bg-green-600 hover:bg-green-700 text-white text-sm px-5 py-2.5 rounded-lg shadow transition duration-150">
                        Save Changes
                    </button>
                </div>
            </div>
        </div>
    </div>
    <!-- Skipped Records Modal -->
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

            <!-- Body -->
            <p class="text-sm text-gray-600 mb-3">
                The following employees already have attendance for the selected date(s):
            </p>

            <div id="skippedEmployeesList"
                class="max-h-60 overflow-y-auto border rounded-md p-3 space-y-2 bg-gray-50">
                <!-- Skipped employees will be inserted here dynamically -->
            </div>

            <!-- Footer -->
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
        const userId = "{{ Auth::user()->id ?? '' }}";
        const userRole = "{{ Auth::user()->role ?? '' }}";
        $('#loaderOverlay').hide();
        loadScheduleAdjustmentPage();
        bindTableSearch('#sa-search', '#schedule-adjustment-table');
        loadEmployeeName();
        loadScheduleAdjustmentCounts('Pending');

        function submitViewSchedule() {
            // Get time values
            let fromTime = document.getElementById('from_time').value;
            let toTime = document.getElementById('to_time').value;

            if (!fromTime || !toTime) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Missing Time',
                    text: 'Please select both From and To time.',
                });
                return;
            }

            // Function to format time (remove minutes and leading zero)
            function formatTime(time) {
                let [hour] = time.split(':');
                return hour.replace(/^0/, ''); // Remove leading zero if exists
            }

            // Format both times
            let formattedFrom = formatTime(fromTime);
            let formattedTo = formatTime(toTime);

            // Concatenate result like "8-15"
            let timeRange = `${formattedFrom}-${formattedTo}`;

            // Get other fields
            let scheduleType = document.getElementById('schedule_type').value;
            let scheduleShift = document.getElementById('schedule_shift').value;

            if (!scheduleType || !scheduleShift) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Missing Fields',
                    text: 'Please select Schedule Type and Shift.',
                });
                return;
            }

            // Final data object
            let scheduleData = {
                schedule_name: timeRange, // 👈 stored in DB
                schedule_type: scheduleType,
                schedule_shift: scheduleShift,
                _token: "{{ csrf_token() }}"
            };

            $.ajax({
                url: "{{ route('schedule.store') }}",
                type: "POST",
                data: scheduleData,
                success: function(response) {
                    console.log('Schedule save response:', response);
                    Swal.fire({
                        icon: (response.skipped?.length || 0) > 0 ? 'warning' : 'success',
                        title: (response.skipped?.length || 0) > 0 ? 'Warning' : 'Success',
                        text: response.message,
                        timer: 2000,
                        showConfirmButton: false
                    });
                    console.log(response.data);
                    // loadSchedule()
                },
                error: function(err) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Error saving schedule. Check console for details.',
                    });
                    console.error(err);
                }
            });
        }

        function loadSchedule() {
            // Load Schedule
            $('.scheduleSelect').html(''); // Clear existing options
            $('.scheduleSelect').append('<option value="">Select Schedule...</option>');
            $.ajax({
                url: "{{ route('schedule.fetch') }}",
                type: 'GET',
                success: function(response) {
                    console.log('Schedule data:', response);

                    let tbody = $('#scheduleTableBody');
                    tbody.empty(); // clear existing rows

                    if (response.length === 0) {
                        tbody.append(`
                        <tr>
                            <td colspan="5" class="text-center py-4 text-gray-500">No schedules available.</td>
                        </tr>
                `);
                        return;
                    }

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

                        $('.scheduleSelect').append(
                            `<option value="${item.schedule_name}">${formattedTime} ${item.schedule_type}</option>`
                        );

                        tbody.append(`
                    <tr class="hover:bg-gray-50 transition">
                        <td class="px-4 py-2 text-center">${index + 1}</td>
                        <td class="px-4 py-2">${formattedTime}</td>
                        <td class="px-4 py-2">${item.schedule_shift}</td>
                        <td class="px-4 py-2">${item.schedule_type}</td>
                        <td class="px-4 py-2 text-center space-x-2">
                            <button
                                class="bg-blue-500 hover:bg-blue-600 text-white text-xs px-3 py-1 rounded shadow-sm"
                                onclick="editSchedule(${item.id})">
                                <i class="fa-solid fa-pen"></i> Edit
                            </button>
                            <button
                                class="bg-red-500 hover:bg-red-600 text-white text-xs px-3 py-1 rounded shadow-sm"
                                onclick="deleteSchedule(${item.id})">
                                <i class="fa-solid fa-trash"></i> Delete
                            </button>
                        </td>
                    </tr>
                `);
                    });
                },
                error: function(xhr, status, error) {
                    console.error("Error fetching schedules:", error);
                    $('#scheduleTableBody').html(`
                <tr>
                    <td colspan="5" class="text-center py-4 text-red-500">Failed to load schedules.</td>
                </tr>
            `);
                }
            });
        }


        function viewScheduleModal() {
            document.getElementById('viewScheduleModal').classList.replace('hidden', 'flex');
            loadSchedule();
        }

        function loadScheduleAdjustmentCounts() {
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
                        url: "{{ route('scheduleAdjustment.counts') }}",
                        type: "GET",
                        data: {
                            userRole: userRole,
                            department: departmentName // only applies for users
                        },
                        success: function(response) {
                            $('#pending-count').text(response.pending);
                            $('#approved-count').text(response.approved);
                            $('#cancelled-count').text(response.cancelled);
                        },
                        error: function(xhr) {
                            console.error("Failed to fetch schedule adjustment counts:", xhr
                                .responseText);
                        }
                    });
                },
                error: function(xhr, status, error) {
                    console.error('Error fetching department:', error);
                }
            });
        }


        function loadScheduleAdjustmentPage(status = 'Pending') {
            bulk_sa.setStatus(status);

            if ($.fn.DataTable.isDataTable('#schedule-adjustment-table')) {
                $('#schedule-adjustment-table').DataTable().clear().destroy();
            }
            $('#sa-toolbar-buttons').empty();

            $.ajax({
                url: "{{ route('department.getUserDepartment') }}",
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    let departmentName = !data.success ? 'N/A' : data.data.department_name;

                    setTimeout(() => {
                        const table = $('#schedule-adjustment-table').DataTable({
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
                                search: $('#sa-search').val() || ''
                            },
                            order: [
                                [2, 'asc']
                            ],
                            ajax: {
                                url: "{{ route('schedule.adjustment') }}",
                                data: function(d) {
                                    d.status = status;
                                    d.userRole = userRole;
                                    if (userRole === 'user') {
                                        d.department = departmentName;
                                    }
                                }
                            },
                            drawCallback: function() {
                                bulk_sa.syncSelectAll();
                            },
                            buttons: exportAndColumnButtons(),
                            columns: [
                                expandControlColumn,
                                bulk_sa.checkboxColumn(),
                                {
                                    data: 'employee_name',
                                    name: 'employee_name',
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
                                    data: 'report_to',
                                    name: 'report_to',
                                    render: function(data, type) {
                                        return type === 'display' ? colorBadgeCell(data) : data;
                                    }
                                },
                                {
                                    data: 'schedule',
                                    name: 'schedule'
                                },
                                {
                                    data: 'others',
                                    name: 'others'
                                },
                                {
                                    data: 'reason',
                                    name: 'reason'
                                },
                                {
                                    data: 'record_date',
                                    name: 'record_date',
                                    render: dateOnlyCell
                                },
                                {
                                    data: 'approval_status',
                                    name: 'approval_status',
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
                                        return approvalActionButtons(row.approval_status, row.id, {
                                            approve: 'approveScheduleAdjustment',
                                            cancel: 'cancelScheduleAdjustment',
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
                        table.buttons().container().appendTo('#sa-toolbar-buttons');
                    }, 150);
                },
                error: function(xhr, status, error) {
                    console.error('Error:', error);
                }
            });
        }

        function approveScheduleAdjustment(id) {
            Swal.fire({
                title: "Are you sure?",
                text: "This Schedule Adjustment will be marked as Approved.",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#3085d6",
                cancelButtonColor: "#d33",
                confirmButtonText: "Yes, approve it!"
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        url: `/scheduleAdjustment/${id}/approved`,
                        type: "POST",
                        data: {
                            _token: "{{ csrf_token() }}"
                        },
                        success: function(response) {
                            if (response.success) {
                                $('#schedule-adjustment-table').DataTable().ajax.reload();
                                Swal.fire({
                                    title: "Approved!",
                                    text: response.message,
                                    icon: "success",
                                    timer: 2000,
                                    showConfirmButton: false
                                });
                                loadScheduleAdjustmentCounts();
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

        function cancelScheduleAdjustment(id) {
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
                        url: `/scheduleAdjustment/${id}/cancelled`,
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
                                $('#schedule-adjustment-table').DataTable().ajax.reload();
                                loadScheduleAdjustmentCounts();
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

        let timeTypeCount = 0;
        let logHoursCount = 0;
        let range = [];
        let formattedD = [];
        let timeInputArray = [];


        function submitScheduleAdjustment() {
            let attendanceArray = []; // final result

            $.each(formattedD, function(index, date) {
                const weekday = new Date(date).toLocaleDateString("en-US", {
                    weekday: "long"
                });

                let scheduleValue = null;

                // loop through all time inputs for this date
                $('.schedule' + date).each(function() {
                    const value = $(this).val();
                    if (value) scheduleValue = value; // store the latest non-empty value
                    console.log(scheduleValue);
                });

                // only push if at least one time exists
                if (scheduleValue) {
                    attendanceArray.push({
                        employee_management_id: $('#employee_name').val(),
                        record_date: date,
                        schedule: scheduleValue,
                        others: $('#others').val(),
                        reason: $('#reasons').val(),
                        weekday: weekday
                    });
                }
                console.log(attendanceArray);
            });

            if (attendanceArray.length > 0) {
                $.ajax({
                    url: "{{ route('scheduleAdjustment.store') }}",
                    method: 'POST',
                    data: {
                        attendanceArray: attendanceArray,
                    },
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    success: function(response) {
                        // Show SweetAlert for success
                        Swal.fire({
                            icon: 'success',
                            title: 'Success',
                            text: response.message,
                            timer: 2000,
                            showConfirmButton: false
                        });

                        // Show Skipped Records Modal if there are skipped records
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

            $('#schedule-adjustment-table').DataTable().ajax.reload();
            loadScheduleAdjustmentCounts();
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

        // Close modal function
        function closeSkippedModal() {
            const modal = document.getElementById("skippedEmployeesModal");
            modal.classList.add("hidden");
            modal.classList.remove("flex");
        }

        // function addLogHours(date, dateFormatted, weekday) {
        //     logHoursCount++;
        //     const logHoursIdentification = `logHours${logHoursCount}`;
        //     $('.log_hours_container').append(`
    //                     <div class="log_hours_details mb-5" id="${logHoursIdentification}">
    //                         <div class="flex items-center justify-between mb-3">
    //                             <span class="text-gray-800 font-medium">${date} ${weekday}</span>
    //                             <button class="text-red-500 hover:text-red-700" onclick="removeLoghours('${logHoursIdentification}');">
    //                                 <i class="fas fa-trash"></i>
    //                             </button>
    //                         </div>
    //                         <div class="time_type_container_${dateFormatted}">
    //                         </div>
    //                         <div class="flex space-x-4 mt-3">
    //                             <button onclick="timeType('${dateFormatted}');"
    //                                 class="px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700 text-sm">
    //                                 + In
    //                             </button>
    //                             <button onclick="timeType('${dateFormatted}');"
    //                                 class="px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700 text-sm">
    //                                 + Out
    //                             </button>
    //                         </div>
    //                     </div>`);
        // }

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
                                <select id="schedule${dateFormatted}" name="schedule${dateFormatted}"
                                    class="schedule${dateFormatted} w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200 scheduleSelect">
                                    <option value="" disabled selected class="text-gray-400">Select schedule</option>
                                </select>
                            </div>`);
        }

        function timeType(identification) {
            timeTypeCount++;
            $('.time_type_container_' + identification).append(`
            <div class="time_type_details mb-5" id="${identification}">
                <div class="flex items-center justify-between mb-3">
                    <div class="flex items-center space-x-4">
                        <label class="flex items-center space-x-2">
                            <input type="radio" name="timeType${timeTypeCount}" value="in"
                                class="text-green-600" checked>
                            <span>In</span>
                        </label>
                        <label class="flex items-center space-x-2">
                            <input type="radio" name="timeType${timeTypeCount}" value="out"
                                class="text-green-600">
                            <span>Out</span>
                        </label>
                        <input type="time" id="timeInput${timeTypeCount}" name="timeInput${timeTypeCount}"
                            class="timeInput${identification} mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm
                            focus:ring-blue-500 focus:border-blue-500 text-sm" />
                    </div>
                    <button class="text-red-500 hover:text-red-700" onclick="removeTimeType('${identification}');">
                        <i class="fas fa-times"></i>
                    </button>
                </div>`);
        }

        function removeLoghours(logHoursIdentification) {
            $('#' + logHoursIdentification).remove();
        }

        function removeTimeType(identification) {
            $('#' + identification).remove();
        }
        // Calendar ###########
        let calendar = $("#attendanceCalendar").flatpickr({
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
                $('.scheduleSelect').html(''); // Clear existing options
                loadSchedule();
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

        function formatDateYMD(date) {
            let year = date.getFullYear();
            let month = String(date.getMonth() + 1).padStart(2, '0'); // months are 0-based
            let day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        }

        function formatDate(rawDate) {
            if (!rawDate) return '';
            const parts = rawDate.includes('/') ? rawDate.split('/') : rawDate.split('-');
            const [year, month, day] = parts;
            return `${month.padStart(2,'0')}-${day.padStart(2,'0')}-${year}`;
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

        // // Add Certificate Modal Functions
        function openAddScheduleAdjustmentModal() {
            document.getElementById('addScheduleAdjustmentModal').classList.replace('hidden', 'flex');
        }

        function closeAddScheduleAdjustmentModal() {
            document.getElementById('addScheduleAdjustmentModal').classList.replace('flex', 'hidden');
            document.getElementById('addCertificateForm').reset();
        }

        // // Add View Schedule Modal Functions
        function closeViewScheduleModal() {
            document.getElementById('viewScheduleModal').classList.replace('flex', 'hidden');
        }

        function closeAddScheduleAdjustmentModal() {
            document.getElementById('addScheduleAdjustmentModal').classList.replace('flex', 'hidden');
        }
    </script>
</x-app-layout>

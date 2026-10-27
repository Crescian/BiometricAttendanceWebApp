<x-app-layout>

    <x-approval-table-assets />

    <div class="px-2 lg:px-4">
        <!-- Page header + toolbar -->
        <div class="flex flex-wrap items-center justify-between gap-3 px-4 pt-4 pb-3">
            <h1 class="text-xl font-semibold text-gray-900">{{ __('Employee Management') }}</h1>
            <div class="flex flex-wrap items-center gap-2">
                <button type="button" x-data @click.prevent="$dispatch('open-modal', 'add-employee'); openAddEmployee()"
                    class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-white bg-green-600 rounded-md hover:bg-green-700 shadow-sm">
                    <i class="fa-solid fa-plus"></i>
                    Add
                </button>
                <div class="relative">
                    <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs"></i>
                    <input id="emp-search" type="search" placeholder="Search"
                        class="w-48 pl-8 pr-3 py-1.5 text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500">
                </div>
                <div id="emp-toolbar-buttons" class="flex items-center gap-2"></div>
            </div>
        </div>

        <!-- Table card -->
        <div class="px-4 pb-4">
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm">
                <div class="p-2 text-gray-900">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="employeeTable" class="modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th>ID</th>
                                        <th>Employee</th>
                                        <th>Department</th>
                                        <th>Supervisor</th>
                                        <th>Schedule</th>
                                        <th>Basic Salary</th>
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
    </div>

    <x-modal name="edit-employee" focusable>
        <div class="p-8 bg-white rounded-xl">
            <div class="mb-6">
                <h2 class="text-2xl font-bold text-gray-900 mb-2">Edit Employee</h2>
                <p class="text-gray-600">Update employee information and details</p>
            </div>

            <div class="space-y-6">
                <!-- Schedule -->
                <div>
                    <label for="scheduleStart" class="block text-sm font-semibold text-gray-700 mb-2">
                        Work Schedule
                    </label>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <span class="block text-xs text-gray-500 mb-1">Time Start</span>
                            <input type="time" step="3600" id="scheduleStart"
                                oninput="previewSchedule('schedule')"
                                class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                        </div>
                        <div>
                            <span class="block text-xs text-gray-500 mb-1">Time End</span>
                            <input type="time" step="3600" id="scheduleEnd"
                                oninput="previewSchedule('schedule')"
                                class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                        </div>
                    </div>
                    <p id="schedulePreview" class="mt-2 text-xs text-gray-500">Whole hours only. A Time End earlier than Time Start is an overnight shift.</p>
                </div>

                <!-- Unique ID -->
                <div>
                    <label for="employeeUniqueId" class="block text-sm font-semibold text-gray-700 mb-2">Unique ID</label>
                    <input id="employeeUniqueId" type="text" onblur="checkUniqueIdConflict('employeeUniqueId', 'uniqueIdConflict', globalID, originalUniqueId)"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                    <p class="mt-2 text-xs text-gray-500">Changing this also updates the ID on the employee's overtime records.</p>
                    <p id="uniqueIdConflict" class="mt-2 text-xs text-amber-700 bg-amber-50 border border-amber-200 rounded-md px-3 py-2 hidden"></p>
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
                    <label for="employeeAddScheduleStart" class="block text-sm font-semibold text-gray-700 mb-2">
                        Work Schedule
                    </label>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <span class="block text-xs text-gray-500 mb-1">Time Start</span>
                            <input type="time" step="3600" id="employeeAddScheduleStart"
                                oninput="previewSchedule('employeeAddSchedule')"
                                class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                        </div>
                        <div>
                            <span class="block text-xs text-gray-500 mb-1">Time End</span>
                            <input type="time" step="3600" id="employeeAddScheduleEnd"
                                oninput="previewSchedule('employeeAddSchedule')"
                                class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-white text-gray-700 focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                        </div>
                    </div>
                    <p id="employeeAddSchedulePreview" class="mt-2 text-xs text-gray-500">Whole hours only. A Time End earlier than Time Start is an overnight shift.</p>
                </div>

                <!-- Unique ID -->
                <div>
                    <div class="flex items-center gap-1.5 mb-2">
                        <label for="employeeAddUniqueId" class="block text-sm font-semibold text-gray-700">Unique ID</label>
                        {{-- Explanation on hover / keyboard focus --}}
                        <span class="relative z-[100] inline-flex group">
                            <i class="fa-solid fa-circle-info text-gray-400 hover:text-gray-600 group-focus-within:text-gray-600 cursor-help"
                                tabindex="0" role="img" aria-label="How is the Unique ID suggested?"
                                aria-describedby="add-unique-id-tip"></i>
                            <span id="add-unique-id-tip" role="tooltip"
                                class="invisible opacity-0 group-hover:visible group-hover:opacity-100 group-focus-within:visible group-focus-within:opacity-100 transition-opacity absolute left-1/2 -translate-x-1/2 top-full mt-2 z-[9999] w-72 p-2.5 rounded-md bg-gray-900 text-white text-[11px] leading-snug font-normal shadow-lg">
                                <strong class="block mb-1">Suggested Unique ID</strong>
                                Filled in with the next ID in the sequence:
                                <span class="font-mono">TMNG-&lt;year+month&gt;-&lt;next number&gt;</span>, or
                                <span class="font-mono">SC-…-&lt;next number&gt;</span> for Security.
                                <span class="block mt-1.5">You can type a different ID. If it already belongs to
                                someone, you'll be asked to give them a new one.</span>
                            </span>
                        </span>
                    </div>
                    <input type="text" id="employeeAddUniqueId" name="unique_id"
                        oninput="updateAddUniqueIdHint()" onblur="checkUniqueIdConflict('employeeAddUniqueId', 'addUniqueIdConflict')"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:border-blue-500 focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200">
                    <p id="addUniqueIdHint" class="mt-2 text-xs text-gray-500"></p>
                    <p id="addUniqueIdConflict" class="mt-2 text-xs text-amber-700 bg-amber-50 border border-amber-200 rounded-md px-3 py-2 hidden"></p>
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

                        <select id="employeeAddDepartment" name="employeeAddDepartment" onchange="suggestAddUniqueId()"
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
        bindTableSearch('#emp-search', '#employeeTable');
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

        /** -----------------------------
         *  WORK SCHEDULE <-> FORMULA CODE
         *  The overtime formula reads employee_management.schedule as
         *  "{startHour}-{endHour}" (24h, whole hours, no leading zeros), e.g. "7-16", "19-7".
         * ------------------------------*/
        // Same night-shift / no-break lists as ComputationService and AttendanceProcessor.
        const NIGHT_SHIFT_CODES = ['18-6', '19-7', '19-4', '20-5', '15-23', '15-24', '23-7', '23-8'];
        const NO_BREAK_CODES = ['15-23', '23-7'];

        // Returns {code} or {error}.
        function toScheduleCode(start, end) {
            if (!start || !end) return { error: 'Enter both Time Start and Time End for the work schedule.' };

            const [sh, sm] = start.split(':').map(Number);
            const [eh, em] = end.split(':').map(Number);

            if (sm !== 0 || em !== 0) return { error: 'Work schedule must be in whole hours (e.g. 07:00, 16:00).' };
            if (sh === eh) return { error: 'Work schedule start and end time must be different.' };

            // Midnight end is stored as 24 (e.g. 15-24), matching the formula's shift lists.
            const endHour = (eh === 0 && sh !== 0) ? 24 : eh;
            return { code: `${sh}-${endHour}` };
        }

        // "19-7" -> {start: "19:00", end: "07:00"}; null when the stored value can't be parsed.
        function fromScheduleCode(code) {
            const match = /^(\d{1,2})-(\d{1,2})$/.exec(String(code ?? '').trim());
            if (!match) return null;
            const pad = h => String(parseInt(h, 10) % 24).padStart(2, '0') + ':00';
            return { start: pad(match[1]), end: pad(match[2]) };
        }

        function describeSchedule(code) {
            const [sh, eh] = code.split('-').map(Number);
            const parts = [];
            if (eh < sh || eh === 24) parts.push('overnight');
            if (NIGHT_SHIFT_CODES.includes(code)) parts.push('night shift');
            if (NO_BREAK_CODES.includes(code)) parts.push('no break');
            return parts.join(', ');
        }

        function previewSchedule(prefix) {
            const start = $(`#${prefix}Start`).val();
            const end = $(`#${prefix}End`).val();
            const $preview = $(`#${prefix}Preview`);

            if (!start || !end) {
                $preview.removeClass('text-red-600').addClass('text-gray-500')
                    .text('Whole hours only. A Time End earlier than Time Start is an overnight shift.');
                return;
            }

            const result = toScheduleCode(start, end);
            if (result.error) {
                $preview.removeClass('text-gray-500').addClass('text-red-600').text(result.error);
                return;
            }

            const details = describeSchedule(result.code);
            $preview.removeClass('text-red-600').addClass('text-gray-500')
                .html(`Saved as <strong>${result.code}</strong>${details ? ' (' + details + ')' : ''}`);
        }

        function setScheduleInputs(prefix, code) {
            const times = fromScheduleCode(code);
            $(`#${prefix}Start`).val(times ? times.start : '');
            $(`#${prefix}End`).val(times ? times.end : '');
            previewSchedule(prefix);

            if (!times && code) {
                $(`#${prefix}Preview`).removeClass('text-gray-500').addClass('text-red-600')
                    .text(`Current value "${code}" is not a valid schedule. Enter Time Start and Time End.`);
            }
        }

        // Builds the schedule code from the inputs, or shows an alert and returns null.
        function readScheduleInputs(prefix) {
            const result = toScheduleCode($(`#${prefix}Start`).val(), $(`#${prefix}End`).val());
            if (result.error) {
                Swal.fire({ icon: 'error', title: 'Invalid Work Schedule', text: result.error });
                return null;
            }
            return result.code;
        }

        function loadEmployeeTable() {
            if ($.fn.DataTable.isDataTable('#employeeTable')) {
                $('#employeeTable').DataTable().clear().destroy();
            }
            $('#emp-toolbar-buttons').empty();

            $.ajax({
                url: "{{ route('department.getUserDepartment') }}",
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    let departmentName = !data.success ? 'N/A' : data.data.department_name;

                    setTimeout(() => {
                        const table = $('#employeeTable').DataTable({
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
                                search: $('#emp-search').val() || ''
                            },
                            // Only the columns marked orderable: true can be sorted
                            columnDefs: [{ targets: '_all', orderable: false }],
                            order: [
                                [1, 'asc']
                            ],
                            ajax: {
                                url: "{{ route('employees.fetch') }}",
                                data: function(d) {
                                    d.userRole = userRole;
                                    d.department = departmentName; // the server only applies it to non-admins
                                }
                            },
                            buttons: exportAndColumnButtons(),
                            columns: [
                                expandControlColumn,
                                {
                                    data: 'unique_id',
                                    orderable: true,
                                    name: 'unique_id',
                                    className: 'font-semibold text-gray-900'
                                },
                                {
                                    data: 'employee_name',
                                    orderable: true,
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
                                    name: 'report_to'
                                },
                                {
                                    data: 'schedule',
                                    name: 'schedule'
                                },
                                {
                                    data: 'basic_salary',
                                    name: 'basic_salary',
                                    className: 'text-right'
                                },
                                {
                                    data: 'status',
                                    name: 'status',
                                    render: function(data, type) {
                                        if (type !== 'display') return data;
                                        return data === 'Active' ?
                                            '<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-green-100 text-green-800">Active</span>' :
                                            '<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-red-100 text-red-800">Not Active</span>';
                                    }
                                },
                                {
                                    data: null,
                                    orderable: false,
                                    searchable: false,
                                    className: 'noVis all text-center',
                                    render: function(data, type, row) {
                                        return `
                                            <div class="flex items-center justify-center gap-1.5">
                                                <button type="button" title="Edit" class="row-btn edit"
                                                    x-data @click.prevent="$dispatch('open-modal', 'edit-employee')"
                                                    onclick="editFunction(${row.id});">
                                                    <i class="fas fa-pen"></i>
                                                </button>
                                                <button type="button" title="Delete" class="row-btn cancel"
                                                    onclick="deleteEmployee(${row.id});">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>`;
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
                        table.buttons().container().appendTo('#emp-toolbar-buttons');
                    }, 150);
                },
                error: function(xhr, status, error) {
                    console.error('Error:', error);
                }
            });
        }

        // The Unique ID the edit modal loaded with; offered back to whoever holds the new one (a swap)
        let originalUniqueId = null;

        function escapeHtml(value) {
            return $('<div>').text(value ?? '').html();
        }

        function describeEmployee(emp) {
            return emp.employee_name + (emp.department ? ' (' + emp.department + ')' : '');
        }

        // Warn before saving when the typed Unique ID already belongs to someone else.
        // excludeId / unchangedId: the employee being edited and the ID it already has.
        function checkUniqueIdConflict(inputId, noteId, excludeId, unchangedId) {
            const note = $('#' + noteId);
            const value = $('#' + inputId).val().trim();
            if (value === '' || value === unchangedId) {
                note.addClass('hidden').text('');
                return;
            }
            $.get("{{ route('employees.checkUniqueId') }}", { unique_id: value, exclude_id: excludeId }, function(res) {
                if ($('#' + inputId).val().trim() !== value) return; // typed on since
                if (res.conflict) {
                    note.text('Already used by ' + describeEmployee(res.employee) +
                        ". You'll be asked to give them a new ID when you save.").removeClass('hidden');
                } else {
                    note.addClass('hidden').text('');
                }
            });
        }

        // The Add modal's suggested Unique ID; replaced on department change only while still in the field
        let suggestedAddUniqueId = null;

        function openAddEmployee() {
            $('#employeeAddUniqueId').val('');
            $('#addUniqueIdConflict').addClass('hidden').text('');
            suggestedAddUniqueId = null;
            suggestAddUniqueId();
        }

        function suggestAddUniqueId() {
            const department = $('#employeeAddDepartment').val() || '';
            $.get("{{ route('employees.suggestUniqueId') }}", { department: department }, function(res) {
                if (($('#employeeAddDepartment').val() || '') !== department) return; // department changed since
                const input = $('#employeeAddUniqueId');
                const current = input.val().trim();
                if (current === '' || current === suggestedAddUniqueId) {
                    input.val(res.unique_id);
                    $('#addUniqueIdConflict').addClass('hidden').text('');
                }
                suggestedAddUniqueId = res.unique_id;
                updateAddUniqueIdHint();
            });
        }

        function useSuggestedAddUniqueId() {
            $('#employeeAddUniqueId').val(suggestedAddUniqueId);
            $('#addUniqueIdConflict').addClass('hidden').text('');
            updateAddUniqueIdHint();
        }

        function updateAddUniqueIdHint() {
            const hint = $('#addUniqueIdHint');
            const current = $('#employeeAddUniqueId').val().trim();
            if (!suggestedAddUniqueId) {
                hint.text('');
            } else if (current === suggestedAddUniqueId) {
                hint.html('<i class="fa-solid fa-wand-magic-sparkles mr-1"></i>Suggested next ID');
            } else {
                hint.html('Custom ID · <button type="button" class="text-blue-600 hover:underline" onclick="useSuggestedAddUniqueId()">Use suggested (' +
                    escapeHtml(suggestedAddUniqueId) + ')</button>');
            }
        }

        // The new Unique ID belongs to another employee: give them a new one (the old ID, i.e. a swap,
        // by default) and save both together, or go back to the form
        function resolveUniqueIdConflict(emp, newUniqueId) {
            Swal.fire({
                icon: 'warning',
                title: 'Unique ID already in use',
                width: '560px',
                html: '<div class="text-left text-sm space-y-3">' +
                    '<p><b>' + escapeHtml(newUniqueId) + '</b> belongs to another employee. To prevent two employees ' +
                    'sharing an ID, they need a new one too.</p>' +
                    '<div class="rounded-lg border border-gray-200 bg-gray-50 p-3">' +
                    '<div><span class="text-gray-500">Name:</span> ' + escapeHtml(emp.employee_name) + '</div>' +
                    '<div><span class="text-gray-500">Department:</span> ' + escapeHtml(emp.department || '—') + '</div>' +
                    '<div><span class="text-gray-500">Status:</span> ' + escapeHtml(emp.status || '—') + '</div>' +
                    '<div><span class="text-gray-500">Current ID:</span> ' + escapeHtml(emp.unique_id) + '</div>' +
                    '</div>' +
                    '<label for="conflictNewUniqueId" class="block font-semibold text-gray-700">New Unique ID for ' +
                    escapeHtml(emp.employee_name) + '</label>' +
                    '<input id="conflictNewUniqueId" class="swal2-input !m-0 !w-full" value="' + escapeHtml(originalUniqueId) + '">' +
                    '<p class="text-xs text-gray-500">Leave as is to swap the two IDs.</p>' +
                    '</div>',
                showCancelButton: true,
                confirmButtonText: 'Update both',
                cancelButtonText: 'Cancel',
                showLoaderOnConfirm: true,
                allowOutsideClick: () => !Swal.isLoading(),
                preConfirm: () => {
                    const conflictNewUniqueId = $('#conflictNewUniqueId').val().trim();
                    if (conflictNewUniqueId === '') {
                        Swal.showValidationMessage('Enter a new Unique ID for ' + emp.employee_name);
                        return false;
                    }
                    return new Promise((resolve) => {
                        sendEmployeeUpdate({ conflict_employee_id: emp.id, conflict_new_unique_id: conflictNewUniqueId })
                            .done(resolve)
                            .fail((xhr) => {
                                const json = xhr.responseJSON || {};
                                const firstError = json.errors ? Object.values(json.errors)[0][0] : null;
                                Swal.showValidationMessage(firstError || json.message || 'Failed to update employee data');
                                resolve(false);
                            });
                    });
                }
            }).then((result) => {
                if (result.isConfirmed && result.value) {
                    employeeUpdated();
                } else if (result.isDismissed) {
                    window.dispatchEvent(new CustomEvent('open-modal', { detail: 'edit-employee' })); // back to the form, edits intact
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

                    // Stored as "LAST, FIRST": the part before the first comma is the last name
                    if (fullName.includes(",")) {
                        const comma = fullName.indexOf(",");
                        lastName = fullName.slice(0, comma).trim();
                        firstName = fullName.slice(comma + 1).trim();
                    } else {
                        lastName = fullName;
                    }

                    console.log(data);
                    // Populate modal fields with employee data
                    $('#employeeUniqueId').val(data.unique_id);
                    originalUniqueId = data.unique_id;
                    $('#uniqueIdConflict').addClass('hidden').text('');
                    $('#employeeFirstName').val(firstName);
                    $('#employeeLastName').val(lastName);
                    $('#basicSalary').val(data.basic_salary);
                    $('#department').val(data.department);
                    $('#report_to').val(data.report_to);
                    setScheduleInputs('schedule', data.schedule);
                    $('#employeeEditStatus').val(data.status ?? 'Not Active');
                    // Open the modal
                    window.dispatchEvent(new Event('open-modal'));
                },
                error: function(xhr, status, error) {
                    console.error('Error fetching employee data:', error);
                }
            });
        }

        // PUT the edit form; `extra` carries the conflict resolution when the new Unique ID was taken
        function sendEmployeeUpdate(extra) {
            let employeeFirstName = $('#employeeFirstName').val();
            let employeeLastName = $('#employeeLastName').val();
            let schedule = readScheduleInputs('schedule');
            if (schedule === null) return null;
            return $.ajax({
                url: `{{ route('employees.edit', ['id' => ':id']) }}`.replace(':id', globalID),
                type: 'PUT',
                dataType: 'json',
                data: Object.assign({
                    unique_id: $('#employeeUniqueId').val().trim(),
                    employee_name: employeeLastName.trim() + ', ' + employeeFirstName.trim(), // "LAST, FIRST"
                    basic_salary: $('#basicSalary').val(),
                    department: $('#department').val(),
                    report_to: $('#report_to').val(),
                    schedule: schedule,
                    status: $('#employeeEditStatus').val(),
                    _token: "{{ csrf_token() }}"
                }, extra || {})
            });
        }

        function employeeUpdated() {
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
        }

        function updateFunction() {
            const request = sendEmployeeUpdate();
            if (!request) return;
            request
                .done(employeeUpdated)
                .fail(function(xhr, status, error) {
                    const json = xhr.responseJSON || {};
                    if (xhr.status === 409 && json.code === 'unique_id_taken') {
                        resolveUniqueIdConflict(json.employee, $('#employeeUniqueId').val().trim());
                        return;
                    }
                    console.error('Error updating employee data:', error);
                    const firstError = json.errors ? Object.values(json.errors)[0][0] : null;
                    Swal.fire('Error', firstError || json.message || 'Failed to update employee data', 'error');
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
                            Swal.fire({
                                title: "Deleted!",
                                text: "The employee has been deleted.",
                                icon: "success"
                            }).then(() => location.reload());
                        },
                        error: function(xhr) {
                            const message = (xhr.responseJSON && xhr.responseJSON.message) || xhr.responseText;
                            Swal.fire('Cannot delete', message, 'error');
                        }
                    });
                }
            });
        }

        // POST the Add form. `overrides` replaces the Unique ID or carries the conflict resolution.
        function sendAddEmployee(overrides) {
            let employeeAddSchedule = readScheduleInputs('employeeAddSchedule');
            if (employeeAddSchedule === null) return null;
            return $.ajax({
                url: "{{ route('employees.store') }}",
                type: 'POST',
                dataType: 'json',
                data: Object.assign({
                    employeeAddUniqueId: $('#employeeAddUniqueId').val().trim(),
                    employeeAddFirstName: $('#employeeAddFirstName').val(),
                    employeeAddLastName: $('#employeeAddLastName').val(),
                    employeeAddDepartment: $('#employeeAddDepartment').val(),
                    employeeAddSchedule: employeeAddSchedule,
                    employeeAddImmediateSupervisor: $('#employeeAddImmediateSupervisor').val(),
                    basicAddSalary: $('#basicAddSalary').val(),
                    employeeAddStatus: $('#employeeAddStatus').val(),
                    _token: "{{ csrf_token() }}"
                }, overrides || {})
            });
        }

        function employeeAdded(response) {
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
        }

        function requestErrorMessage(xhr, fallback) {
            const json = xhr.responseJSON || {};
            const firstError = json.errors ? Object.values(json.errors)[0][0] : null;
            return firstError || json.message || fallback;
        }

        function addEmployee() {
            const request = sendAddEmployee();
            if (!request) return;
            request
                .done(employeeAdded)
                .fail(function(xhr) {
                    const json = xhr.responseJSON || {};
                    if (xhr.status === 409 && json.code === 'unique_id_taken') {
                        resolveAddUniqueIdConflict(json, $('#employeeAddUniqueId').val().trim());
                        return;
                    }
                    Swal.fire('Error', requestErrorMessage(xhr, 'Failed to add employee'), 'error');
                });
        }

        // The Unique ID typed in the Add form belongs to someone: use the next free ID for the new
        // employee, or give the current holder a new ID and keep this one. Cancel goes back to the form.
        function resolveAddUniqueIdConflict(conflict, takenId) {
            const emp = conflict.employee;
            const submit = (overrides) => new Promise((resolve) => {
                sendAddEmployee(overrides)
                    .done(resolve)
                    .fail((xhr) => {
                        Swal.showValidationMessage(requestErrorMessage(xhr, 'Failed to add employee'));
                        resolve(false);
                    });
            });

            Swal.fire({
                icon: 'warning',
                title: 'Unique ID already in use',
                width: '600px',
                html: '<div class="text-left text-sm space-y-3">' +
                    '<p><b>' + escapeHtml(takenId) + '</b> belongs to another employee. To prevent two employees ' +
                    'sharing an ID, either use the next free ID for the new employee, or give this employee a new one.</p>' +
                    '<div class="rounded-lg border border-gray-200 bg-gray-50 p-3">' +
                    '<div><span class="text-gray-500">Name:</span> ' + escapeHtml(emp.employee_name) + '</div>' +
                    '<div><span class="text-gray-500">Department:</span> ' + escapeHtml(emp.department || '—') + '</div>' +
                    '<div><span class="text-gray-500">Status:</span> ' + escapeHtml(emp.status || '—') + '</div>' +
                    '<div><span class="text-gray-500">Current ID:</span> ' + escapeHtml(emp.unique_id) + '</div>' +
                    '</div>' +
                    '<label for="conflictAddNewUniqueId" class="block font-semibold text-gray-700">New Unique ID for ' +
                    escapeHtml(emp.employee_name) + ' <span class="font-normal text-gray-500">(only if you keep ' +
                    escapeHtml(takenId) + ' for the new employee)</span></label>' +
                    '<input id="conflictAddNewUniqueId" class="swal2-input !m-0 !w-full" value="' + escapeHtml(conflict.suggested) + '">' +
                    '</div>',
                showDenyButton: true,
                showCancelButton: true,
                confirmButtonText: 'Use ' + escapeHtml(conflict.suggested) + ' for the new employee',
                denyButtonText: 'Give ' + escapeHtml(emp.employee_name) + ' the new ID',
                denyButtonColor: '#d97706',
                cancelButtonText: 'Cancel',
                showLoaderOnConfirm: true,
                showLoaderOnDeny: true,
                allowOutsideClick: () => !Swal.isLoading(),
                preConfirm: () => submit({ employeeAddUniqueId: conflict.suggested }),
                preDeny: () => {
                    const newId = $('#conflictAddNewUniqueId').val().trim();
                    if (newId === '') {
                        Swal.showValidationMessage('Enter a new Unique ID for ' + emp.employee_name);
                        return false;
                    }
                    return submit({ conflict_employee_id: emp.id, conflict_new_unique_id: newId });
                }
            }).then((result) => {
                if ((result.isConfirmed || result.isDenied) && result.value) {
                    employeeAdded(result.value);
                } else if (result.isDismissed) {
                    window.dispatchEvent(new CustomEvent('open-modal', { detail: 'add-employee' })); // back to the form, entries intact
                }
            });
        }

        document.addEventListener("DOMContentLoaded", function() {
            $('#addEmployeeForm').on('submit', function(event) {
                event.preventDefault();
            });
        });
    </script>

</x-app-layout>

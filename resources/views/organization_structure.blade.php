<x-app-layout>
    <x-approval-table-assets />

    <div class="px-2 lg:px-4">
        <!-- Page header + toolbar -->
        <div class="flex flex-wrap items-center justify-between gap-3 px-4 pt-4 pb-3">
            <h1 class="text-xl font-semibold text-gray-900">{{ __('Organization Structure') }}</h1>
            <div class="flex flex-wrap items-center gap-2">
                <button type="button" id="org-add-btn" onclick="openModal(orgTabs[orgActiveTab].modal)"
                    class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-white bg-green-600 rounded-md hover:bg-green-700 shadow-sm">
                    <i class="fa-solid fa-plus"></i>
                    <span id="org-add-label">Add business unit</span>
                </button>
                <div class="relative">
                    <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs"></i>
                    <input id="org-search" type="search" placeholder="Search"
                        class="w-48 pl-8 pr-3 py-1.5 text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500">
                </div>
                <div id="org-toolbar-bu" class="org-toolbar flex items-center gap-2"></div>
                <div id="org-toolbar-company" class="org-toolbar hidden items-center gap-2"></div>
                <div id="org-toolbar-department" class="org-toolbar hidden items-center gap-2"></div>
            </div>
        </div>

        <!-- Table card -->
        <div class="px-4 pb-4">
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm">
                <x-status-tabs loader="showOrgTab" :tabs="[
                    ['value' => 'bu', 'label' => 'Business Units', 'title' => 'Business Units', 'count' => 'bu-count', 'badge' => 'bg-gray-100 text-gray-700'],
                    ['value' => 'company', 'label' => 'Companies', 'title' => 'Companies', 'count' => 'company-count', 'badge' => 'bg-gray-100 text-gray-700'],
                    ['value' => 'department', 'label' => 'Departments', 'title' => 'Departments', 'count' => 'department-count', 'badge' => 'bg-gray-100 text-gray-700'],
                ]" />

                <div class="p-2 text-gray-900 org-panel" data-org-panel="bu">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="business-unit-table" class="org-table modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th>Business Unit</th>
                                        <th>Head</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="p-2 text-gray-900 org-panel hidden" data-org-panel="company">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="company-table" class="org-table modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th>Company</th>
                                        <th>Company Head</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="p-2 text-gray-900 org-panel hidden" data-org-panel="department">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="department-table" class="org-table modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th>Department</th>
                                        <th>Department Head</th>
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

        <!-- ========== MODALS (Reusable Layout) ========== -->
        <!-- Business Unit Modal -->
        <div id="businessUnitModal"
            class="hidden fixed inset-0 bg-gray-900 bg-opacity-50 flex justify-center items-center z-50">
            <div class="bg-white w-96 rounded-lg shadow-lg p-6">
                <h3 class="text-xl font-bold mb-4">Add / Edit Business Unit</h3>
                <form id="businessUnitForm">
                    <label class="block text-gray-700 mb-2">Business Unit Name</label>
                    <input type="text" id="bu_name"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500"
                        placeholder="Enter name">

                    <label class="block text-gray-700 mb-2">Head</label>
                    <input type="text" id="bu_head"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500"
                        placeholder="Enter head name">

                    <div class="flex justify-end space-x-2">
                        <button type="button" onclick="closeModal('#businessUnitModal')"
                            class="px-4 py-2 bg-gray-200 rounded-lg">Cancel</button>
                        <button type="button" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                            onclick="save('businessUnit');">Save</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Department Modal -->
        <div id="departmentModal"
            class="hidden fixed inset-0 bg-gray-900 bg-opacity-50 flex justify-center items-center z-50">
            <div class="bg-white w-96 rounded-lg shadow-lg p-6">
                <h3 class="text-xl font-bold mb-4">Add / Edit Department</h3>
                <form id="departmentForm">
                    <label class="block text-gray-700 mb-2">Department Name</label>
                    <input type="text" id="dept_name"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500"
                        placeholder="Enter name">

                    <label class="block text-gray-700 mb-2">Department Head</label>
                    {{-- <input type="text" id="dept_head"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500"
                        placeholder="Enter head name"> --}}
                    <select id="dept_head"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500">
                        <option value="">-- Select Department Head --</option>
                        <!-- Options will be populated dynamically -->
                    </select>

                    <label class="block text-gray-700 mb-2">Company</label>
                    <select id="dept_company"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500">
                        <option value="">-- Select Company --</option>
                        <!-- Options will be populated dynamically -->
                    </select>

                    <div class="flex justify-end space-x-2">
                        <button type="button" onclick="closeModal('#departmentModal')"
                            class="px-4 py-2 bg-gray-200 rounded-lg">Cancel</button>
                        <button type="button" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                            onclick="save('department');">Save</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Company Modal -->
        <div id="companyModal"
            class="hidden fixed inset-0 bg-gray-900 bg-opacity-50 flex justify-center items-center z-50">
            <div class="bg-white w-96 rounded-lg shadow-lg p-6">
                <h3 class="text-xl font-bold mb-4">Add / Edit Company</h3>
                <form id="companyForm">
                    <label class="block text-gray-700 mb-2">Company Name</label>
                    <input type="text" id="comp_name"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500"
                        placeholder="Enter name">

                    <label class="block text-gray-700 mb-2">Company Head</label>
                    <input type="text" id="comp_head"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500"
                        placeholder="Enter head name">

                    <label class="block text-gray-700 mb-2">Business Unit</label>
                    <select id="comp_bu"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500">
                        <option value="">-- Select Business Unit --</option>
                        <!-- Options will be populated dynamically -->
                    </select>

                    <div class="flex justify-end space-x-2">
                        <button type="button" onclick="closeModal('#companyModal')"
                            class="px-4 py-2 bg-gray-200 rounded-lg">Cancel</button>
                        <button type="button" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                            onclick="save('company');">Save</button>
                    </div>
                </form>
            </div>
        </div>

    </div>

    <!-- ========== jQuery Functions ========== -->
    <script>
        const orgTabs = {
            bu: { table: '#business-unit-table', modal: '#businessUnitModal', add: 'Add business unit' },
            company: { table: '#company-table', modal: '#companyModal', add: 'Add company' },
            department: { table: '#department-table', modal: '#departmentModal', add: 'Add department' },
        };
        let orgActiveTab = 'bu';

        loadTables();
        getUsers();

        // Header search filters all three tables
        let orgSearchTimer;
        $(document).on('input', '#org-search', function() {
            clearTimeout(orgSearchTimer);
            const term = this.value;
            orgSearchTimer = setTimeout(function() {
                Object.values(orgTabs).forEach(function(tab) {
                    if ($.fn.DataTable.isDataTable(tab.table)) {
                        $(tab.table).DataTable().search(term).draw();
                    }
                });
            }, 350);
        });

        function showOrgTab(key) {
            orgActiveTab = key;
            $('.org-panel').addClass('hidden');
            $(`[data-org-panel="${key}"]`).removeClass('hidden');
            $('.org-toolbar').addClass('hidden').removeClass('flex');
            $(`#org-toolbar-${key}`).removeClass('hidden').addClass('flex');
            $('#org-add-label').text(orgTabs[key].add);
            // A table laid out while hidden needs its widths recalculated once shown
            if ($.fn.DataTable.isDataTable(orgTabs[key].table)) {
                $(orgTabs[key].table).DataTable().columns.adjust().responsive.recalc();
            }
        }

        // Head shown as a pill when empty
        function headCell(head, type) {
            if (type !== 'display') return head || '';
            if (!head || String(head).trim() === '') {
                return `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-gray-200 text-gray-600">Not Assigned</span>`;
            }
            return personCell(head);
        }

        function orgActions(kind) {
            return {
                data: null,
                orderable: false,
                searchable: false,
                className: 'noVis all text-center',
                render: function(data, type, row) {
                    return `
                        <div class="flex items-center justify-center gap-1.5">
                            <button type="button" title="Edit" class="row-btn edit" onclick="editOrgRow('${kind}', this)">
                                <i class="fas fa-pen"></i>
                            </button>
                            <button type="button" title="Delete" class="row-btn cancel" onclick="deleteItems('${kind === 'bu' ? 'business_unit' : kind}', ${Number(row.id)})">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>`;
                }
            };
        }

        // Edit opens the modal pre-filled from the row's data (no names inlined into onclick)
        function editOrgRow(kind, button) {
            const row = $(orgTabs[kind].table).DataTable().row($(button).closest('tr')).data();
            if (!row) return;
            if (kind === 'bu') editModal('#businessUnitModal', row.name, row.head || '');
            if (kind === 'company') editModal('#companyModal', row.name, row.head || '');
            if (kind === 'department') editModal('#departmentModal', row.department_name, row.department_head || '');
        }

        function orgRows(response) {
            return response.success && Array.isArray(response.data) ? response.data : [];
        }

        function loadTables() {
            // Load Business Units
            $.ajax({
                url: "{{ route('business-unit.fetch') }}",
                type: 'GET',
                success: function(response) {
                    const rows = orgRows(response);
                    $('#comp_bu').html('<option value="">-- Select Business Unit --</option>');
                    rows.forEach(function(bu) {
                        $('#comp_bu').append($('<option>').val(bu.id).text(bu.name));
                    });
                    $('#bu-count').text(rows.length);
                    renderClientTable('#business-unit-table', {
                        data: rows,
                        toolbar: '#org-toolbar-bu',
                        search: '#org-search',
                        emptyText: 'No business units found.',
                        columns: [
                            { data: 'name', className: 'all font-semibold text-gray-900', render: $.fn.dataTable.render.text() },
                            { data: 'head', render: (data, type) => headCell(data, type) },
                            orgActions('bu')
                        ]
                    });
                },
            });

            // Load Companies
            $.ajax({
                url: "{{ route('company.fetch') }}",
                type: 'GET',
                success: function(response) {
                    const rows = orgRows(response);
                    $('#dept_company').html('<option value="">-- Select Company --</option>');
                    rows.forEach(function(comp) {
                        $('#dept_company').append($('<option>').val(comp.id).text(comp.name));
                    });
                    $('#company-count').text(rows.length);
                    renderClientTable('#company-table', {
                        data: rows,
                        toolbar: '#org-toolbar-company',
                        search: '#org-search',
                        emptyText: 'No companies found.',
                        columns: [
                            { data: 'name', className: 'all font-semibold text-gray-900', render: $.fn.dataTable.render.text() },
                            { data: 'head', render: (data, type) => headCell(data, type) },
                            orgActions('company')
                        ]
                    });
                },
            });

            // Load Departments
            $.ajax({
                url: "{{ route('department.fetch') }}",
                type: 'GET',
                success: function(response) {
                    const rows = orgRows(response);
                    $('#department-count').text(rows.length);
                    renderClientTable('#department-table', {
                        data: rows,
                        toolbar: '#org-toolbar-department',
                        search: '#org-search',
                        emptyText: 'No departments found.',
                        columns: [
                            { data: 'department_name', className: 'all', render: (data, type) => type === 'display' ? colorBadgeCell(data) : data },
                            { data: 'department_head_name', defaultContent: '', render: (data, type) => headCell(data, type) },
                            orgActions('department')
                        ]
                    });
                },
            });
        }

        function getUsers() {
            $.ajax({
                url: "{{ route('department.getUsers') }}",
                type: 'GET',
                success: function(response) {
                    if (response.success) {
                        $('#dept_head').html(''); // Clear existing options
                        $('#dept_head').append('<option value="">-- Select Department Head --</option>');

                        $.each(response.data, function(index, user) {
                            $('#dept_head').append(
                                `<option value="${user.id}">${user.name}</option>`
                            );
                        });
                    }
                },
            });
        }


        function save(type) {
            let name, head;
            let dataDetails;
            let urlDetails;
            switch (type) {
                case 'businessUnit':
                    name = $('#bu_name').val();
                    head = $('#bu_head').val();
                    urlDetails = "{{ route('business-unit.store') }}";
                    dataDetails = {
                        _token: $('meta[name="csrf-token"]').attr('content'),
                        name: name,
                        head: head
                    };
                    break;
                case 'department':
                    company_id = $('#dept_company').val();
                    name = $('#dept_name').val();
                    head = $('#dept_head').val();
                    urlDetails = "{{ route('department.store') }}";
                    dataDetails = {
                        _token: $('meta[name="csrf-token"]').attr('content'),
                        company_id: company_id,
                        department_name: name,
                        department_head: head
                    };
                    break;
                case 'company':
                    business_unit_id = $('#comp_bu').val();
                    name = $('#comp_name').val();
                    head = $('#comp_head').val();
                    urlDetails = "{{ route('company.store') }}";
                    dataDetails = {
                        _token: $('meta[name="csrf-token"]').attr('content'),
                        business_unit_id: business_unit_id,
                        name: name,
                        head: head
                    };
                    break;
            }
            $.ajax({
                url: urlDetails,
                type: 'POST',
                data: dataDetails,
                success: function(response) {
                    closeModal('#' + type + 'Modal');
                    Swal.fire({
                        position: "center",
                        icon: "success",
                        title: response.message,
                        showConfirmButton: false,
                        timer: 1500,
                        width: "500px"
                    });
                    loadTables();
                },
                error: function(xhr) {
                    const message = (xhr.responseJSON && xhr.responseJSON.message) || 'Save failed.';
                    Swal.fire('Could not save', message, 'error');
                },
            });
        }

        function deleteItems(type, id) {
            switch (type) {
                case 'business_unit':
                    urlDetails = `{{ route('business-unit.destroy', ['id' => ':id']) }}`.replace(':id', id);
                    break;
                case 'department':
                    urlDetails = `{{ route('department.destroy', ['id' => ':id']) }}`.replace(':id', id);
                    break;
                case 'company':
                    urlDetails = `{{ route('company.destroy', ['id' => ':id']) }}`.replace(':id', id);
                    break;
            }

            Swal.fire({
                title: 'Are you sure?',
                text: "This action cannot be undone!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, delete it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    let url = urlDetails;
                    $.ajax({
                        url: url,
                        type: 'DELETE',
                        data: {
                            _token: $('meta[name="csrf-token"]').attr('content')
                        },
                        success: function(response) {
                            Swal.fire(
                                'Deleted!',
                                response.message,
                                'success'
                            );
                            loadTables(); // reload the table after delete
                        },
                        error: function(xhr) {
                            const message = (xhr.responseJSON && xhr.responseJSON.message) || 'Delete failed.';
                            Swal.fire('Cannot delete', message, 'error');
                        }
                    });
                }
            });
        }

        function openModal(modalId) {
            $(modalId).removeClass('hidden').hide().fadeIn(200);
            $(modalId + ' form')[0].reset();
        }

        function closeModal(modalId) {
            $(modalId).fadeOut(200, function() {
                $(this).addClass('hidden');
            });
        }

        function editModal(modalId, name, head) {
            openModal(modalId);
            $(modalId + ' input[type=text]').eq(0).val(name);
            $(modalId + ' input[type=text]').eq(1).val(head);
        }

        // Example form submit (you can later connect via AJAX or form POST)
        // $('#businessUnitForm, #departmentForm, #companyForm').on('submit', function(e) {
        //     e.preventDefault();
        //     closeModal('#' + $(this).attr('id').replace('Form', 'Modal'));
        // });
    </script>

</x-app-layout>

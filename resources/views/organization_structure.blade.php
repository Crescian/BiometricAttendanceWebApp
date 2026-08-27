<x-app-layout>
    <div class="px-16 py-12"><!-- Row: Business Unit, Department, Company -->
        <!-- ========== GRID CARDS ========== -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Business Unit -->
            <div class="bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col">
                <div class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200 flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-gray-900 flex items-center space-x-2">
                        <i class="fa-solid fa-building text-3xl" style="color: #8DE11A;"></i>
                        <span>Business Unit</span>
                    </h2>
                    <button onclick="openModal('#businessUnitModal')"
                        class="flex items-center px-4 py-2 bg-white text-green-600 font-semibold rounded-lg shadow-sm border border-green-600 hover:bg-green-50 transition">
                        <i class="fa-solid fa-plus mr-2"></i> Add
                    </button>
                </div>
                <div class="p-6 flex-1 overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Business Unit Name
                                </th>
                                <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Head</th>
                                <th class="px-4 py-2 text-center text-sm font-semibold text-gray-700">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 businessUnitMDetails">
                            {{-- <tr>
                                <td class="px-4 py-2 text-sm text-gray-800">Finance</td>
                                <td class="px-4 py-2 text-sm text-gray-800">John Doe</td>
                                <td class="px-4 py-2 text-center">
                                    <button class="text-blue-600 hover:underline mx-1"
                                        onclick="editModal('#businessUnitModal', 'Finance', 'John Doe')">Edit</button>
                                    <button class="text-red-600 hover:underline mx-1">Delete</button>
                                </td>
                            </tr> --}}
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Department -->
            <div class="bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col">
                <div class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200 flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-gray-900 flex items-center space-x-2">
                        <i class="fa-solid fa-sitemap text-3xl" style="color: #8DE11A;"></i>
                        <span>Department</span>
                    </h2>
                    <button onclick="openModal('#departmentModal')"
                        class="flex items-center px-4 py-2 bg-white text-green-600 font-semibold rounded-lg shadow-sm border border-green-600 hover:bg-green-50 transition">
                        <i class="fa-solid fa-plus mr-2"></i> Add
                    </button>
                </div>
                <div class="p-6 flex-1 overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Department Name</th>
                                <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Department Head</th>
                                <th class="px-4 py-2 text-center text-sm font-semibold text-gray-700">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 departmentDetails">
                            {{-- <tr>
                                <td class="px-4 py-2 text-sm text-gray-800">HR</td>
                                <td class="px-4 py-2 text-sm text-gray-800">Jane Smith</td>
                                <td class="px-4 py-2 text-center">
                                    <button class="text-blue-600 hover:underline mx-1"
                                        onclick="editModal('#departmentModal', 'HR', 'Jane Smith')">Edit</button>
                                    <button class="text-red-600 hover:underline mx-1">Delete</button>
                                </td>
                            </tr> --}}
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Company -->
            <div class="bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col">
                <div class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200 flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-gray-900 flex items-center space-x-2">
                        <i class="fa-solid fa-city text-3xl" style="color: #8DE11A;"></i>
                        <span>Company</span>
                    </h2>
                    <button onclick="openModal('#companyModal')"
                        class="flex items-center px-4 py-2 bg-white text-green-600 font-semibold rounded-lg shadow-sm border border-green-600 hover:bg-green-50 transition">
                        <i class="fa-solid fa-plus mr-2"></i> Add
                    </button>
                </div>
                <div class="p-6 flex-1 overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Company Name</th>
                                <th class="px-4 py-2 text-left text-sm font-semibold text-gray-700">Company Head</th>
                                <th class="px-4 py-2 text-center text-sm font-semibold text-gray-700">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 companyDetails">
                            {{-- <tr>
                                <td class="px-4 py-2 text-sm text-gray-800">Leoniogroup Inc.</td>
                                <td class="px-4 py-2 text-sm text-gray-800">Michael Reyes</td>
                                <td class="px-4 py-2 text-center">
                                    <button class="text-blue-600 hover:underline mx-1"
                                        onclick="editModal('#companyModal', 'Leoniogroup Inc.', 'Michael Reyes')">Edit</button>
                                    <button class="text-red-600 hover:underline mx-1">Delete</button>
                                </td>
                            </tr> --}}
                        </tbody>
                    </table>
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
                        <button class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
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
                        <button type="submit" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
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
                        <button type="submit" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                            onclick="save('company');">Save</button>
                    </div>
                </form>
            </div>
        </div>

    </div>

    <!-- ========== jQuery Functions ========== -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        loadTables();
        getUsers();

        function loadTables() {
            // Helper to show badge if head is empty
            function formatHead(head) {
                if (!head || head.trim() === '') {
                    return `<span class="px-2 py-1 bg-gray-200 text-gray-600 rounded-full text-xs">No Assigned</span>`;
                }
                return head;
            }

            // Load Business Units
            $.ajax({
                url: "{{ route('business-unit.fetch') }}",
                type: 'GET',
                success: function(response) {
                    let buTableBody = '';
                    $('#comp_bu').html(''); // Clear existing options
                    $('#comp_bu').append('<option value="">-- Select Business Unit --</option>');
                    if (response.success && response.data.length > 0) {
                        response.data.forEach(function(bu) {
                            $('#comp_bu').append(`<option value="${bu.id}">${bu.name}</option>`);
                            buTableBody += `
                        <tr>
                            <td class="px-4 py-2 text-sm text-gray-800">${bu.name}</td>
                            <td class="px-4 py-2 text-sm text-gray-800">${formatHead(bu.head)}</td>
                            <td class="px-4 py-2 text-center">
                                <button class="text-blue-600 hover:underline mx-1" onclick="editModal('#businessUnitModal', '${bu.name}', '${bu.head || ''}')">Edit</button>
                                <button class="text-red-600 hover:underline mx-1" onclick="deleteItems('business_unit','${bu.id}');">Delete</button>
                            </td>
                        </tr>`;
                        });
                    } else {
                        buTableBody = `
                    <tr>
                        <td colspan="3" class="text-center text-gray-500 py-4">No Business Units found.</td>
                    </tr>`;
                    }
                    $('.businessUnitMDetails').html(buTableBody);
                },
            });

            // Load Departments
            $.ajax({
                url: "{{ route('department.fetch') }}",
                type: 'GET',
                success: function(response) {
                    let deptTableBody = '';
                    if (response.success && response.data.length > 0) {
                        response.data.forEach(function(dept) {
                            deptTableBody += `
                        <tr>
                            <td class="px-4 py-2 text-sm text-gray-800">${dept.department_name}</td>
                            <td class="px-4 py-2 text-sm text-gray-800">${formatHead(dept.department_head_name)}</td>
                            <td class="px-4 py-2 text-center">
                                <button class="text-blue-600 hover:underline mx-1" onclick="editModal('#departmentModal', '${dept.department_name}', '${dept.department_head || ''}')">Edit</button>
                                <button class="text-red-600 hover:underline mx-1" onclick="deleteItems('department','${dept.id}');">Delete</button>
                            </td>
                        </tr>`;
                        });
                    } else {
                        deptTableBody = `
                    <tr>
                        <td colspan="3" class="text-center text-gray-500 py-4">No Departments found.</td>
                    </tr>`;
                    }
                    $('.departmentDetails').html(deptTableBody);
                },
            });

            // Load Companies
            $.ajax({
                url: "{{ route('company.fetch') }}",
                type: 'GET',
                success: function(response) {
                    let compTableBody = '';
                    $('#dept_company').html(''); // Clear existing options
                    $('#dept_company').append('<option value="">-- Select Company --</option>');
                    if (response.success && response.data.length > 0) {
                        response.data.forEach(function(comp) {
                            $('#dept_company').append(
                                `<option value="${comp.id}">${comp.name}</option>`);
                            compTableBody += `
                        <tr>
                            <td class="px-4 py-2 text-sm text-gray-800">${comp.name}</td>
                            <td class="px-4 py-2 text-sm text-gray-800">${formatHead(comp.head)}</td>
                            <td class="px-4 py-2 text-center">
                                <button class="text-blue-600 hover:underline mx-1" onclick="editModal('#companyModal', '${comp.name}', '${comp.head || ''}')">Edit</button>
                                <button class="text-red-600 hover:underline mx-1" onclick="deleteItems('company','${comp.id}');">Delete</button>
                            </td>
                        </tr>`;
                        });
                    } else {
                        compTableBody = `
                    <tr>
                        <td colspan="3" class="text-center text-gray-500 py-4">No Companies found.</td>
                    </tr>`;
                    }
                    $('.companyDetails').html(compTableBody);
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
                            console.log(user); // This will now show the user object correctly
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
                },
            })
            loadTables();
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

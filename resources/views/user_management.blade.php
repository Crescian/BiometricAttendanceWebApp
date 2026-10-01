<x-app-layout>
    <x-approval-table-assets />

    <div class="px-2 lg:px-4">
        <!-- Page header + toolbar -->
        <div class="flex flex-wrap items-center justify-between gap-3 px-4 pt-4 pb-3">
            <div class="flex flex-wrap items-center gap-3">
                <h1 class="text-xl font-semibold text-gray-900">{{ __('User Management') }}</h1>
                <div class="flex items-center gap-1.5 text-[11px] font-semibold">
                    <span class="px-2 py-0.5 rounded-full bg-green-100 text-green-800">Active <span id="count-active">0</span></span>
                    <span class="px-2 py-0.5 rounded-full bg-red-100 text-red-800">Inactive <span id="count-inactive">0</span></span>
                    <span class="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 inline-flex items-center gap-1">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Online <span id="count-online">0</span>
                    </span>
                </div>
            </div>
            <div class="flex flex-wrap items-center gap-2">
                <button type="button" onclick="openUserModal()"
                    class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-white bg-green-600 rounded-md hover:bg-green-700 shadow-sm">
                    <i class="fa-solid fa-plus"></i>
                    Add
                </button>
                <div class="relative">
                    <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs"></i>
                    <input id="users-search" type="search" placeholder="Search"
                        class="w-48 pl-8 pr-3 py-1.5 text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500">
                </div>
                <div id="users-toolbar-buttons" class="flex items-center gap-2"></div>
            </div>
        </div>

        <!-- Table card -->
        <div class="px-4 pb-4">
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm">
                <div class="p-2 text-gray-900">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="users-table" class="modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th>User</th>
                                        <th>Role</th>
                                        <th>Department</th>
                                        <th>Position</th>
                                        <th>Status</th>
                                        <th>Presence</th>
                                        <th>Joined</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- User Modal -->
        <div id="userModal"
            class="hidden fixed inset-0 bg-gray-900 bg-opacity-50 flex justify-center items-center z-50">
            <div class="bg-white w-96 rounded-lg shadow-lg p-6">
                <h3 class="text-xl font-bold mb-4">Register User</h3>
                <form id="userForm">
                    <label class="block text-gray-700 mb-2">Find Person</label>
                    <div class="relative mb-1">
                        <input type="text" id="user_search" autocomplete="off"
                            class="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-green-500"
                            placeholder="Search by name or email...">
                        <div id="user_search_results"
                            class="hidden absolute z-10 w-full bg-white border rounded-lg shadow-lg mt-1 max-h-48 overflow-y-auto">
                        </div>
                    </div>
                    <p class="text-xs text-gray-500 mb-4">Pulled from the ticketing system directory — select a
                        person to autofill their name and email.</p>

                    <input type="hidden" id="user_name">
                    <input type="hidden" id="user_email">
                    <input type="hidden" id="user_position">

                    <div id="user_selected" class="hidden mb-4 px-3 py-2 bg-green-50 border border-green-200 rounded-lg text-sm text-gray-800">
                    </div>

                    <label class="block text-gray-700 mb-2">Role</label>
                    <select id="user_role"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500">
                        <option value="user">Department Head</option>
                        <option value="admin">Admin</option>
                    </select>

                    <div class="flex justify-end space-x-2">
                        <button type="button" onclick="closeModal('#userModal')"
                            class="px-4 py-2 bg-gray-200 rounded-lg">Cancel</button>
                        <button type="button" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                            onclick="saveUser();">Save</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Edit User Modal -->
        <div id="editUserModal"
            class="hidden fixed inset-0 bg-gray-900 bg-opacity-50 flex justify-center items-center z-50">
            <div class="bg-white w-96 rounded-lg shadow-lg p-6">
                <h3 class="text-xl font-bold mb-1">Edit User</h3>
                <p id="edit_user_label" class="text-sm text-gray-500 mb-4"></p>
                <form id="editUserForm">
                    <input type="hidden" id="edit_user_id">

                    <label class="block text-gray-700 mb-2">Role</label>
                    <select id="edit_user_role"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500">
                        <option value="user">Department Head</option>
                        <option value="admin">Admin</option>
                    </select>

                    <label class="block text-gray-700 mb-2">Position</label>
                    <input type="text" id="edit_user_position" maxlength="255"
                        class="w-full border rounded-lg px-3 py-2 mb-4 focus:ring-2 focus:ring-green-500"
                        placeholder="e.g. HR Supervisor">

                    <label class="block text-gray-700 mb-2">Status</label>
                    <select id="edit_user_active"
                        class="w-full border rounded-lg px-3 py-2 mb-1 focus:ring-2 focus:ring-green-500">
                        <option value="1">Active</option>
                        <option value="0">Inactive</option>
                    </select>
                    <p class="text-xs text-gray-500 mb-4">Inactive users can't log in.</p>

                    <p class="text-xs text-gray-500 mb-4">Departments are assigned on the Organization Structure page
                        (Department Head).</p>

                    <div class="flex justify-end space-x-2">
                        <button type="button" onclick="closeModal('#editUserModal')"
                            class="px-4 py-2 bg-gray-200 rounded-lg">Cancel</button>
                        <button type="button" class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                            onclick="updateUser();">Save</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        loadUsers();
        bindTableSearch('#users-search', '#users-table');

        const usersUpdateUrl = "{{ route('users.update', ['id' => '__ID__']) }}";
        let usersById = {};

        const escapeHtml = (value) => $('<div>').text(value ?? '').html();
        const pill = (classes, html) => `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full whitespace-nowrap ${classes}">${html}</span>`;

        function formatDate(iso) {
            return iso ? new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '';
        }

        // "just now", "5m ago", "3h ago", "2d ago", then the date
        function timeAgo(iso) {
            if (!iso) return 'never';
            const minutes = Math.floor((Date.now() - new Date(iso).getTime()) / 60000);
            if (minutes < 1) return 'just now';
            if (minutes < 60) return `${minutes}m ago`;
            if (minutes < 1440) return `${Math.floor(minutes / 60)}h ago`;
            if (minutes < 10080) return `${Math.floor(minutes / 1440)}d ago`;
            return formatDate(iso);
        }

        function loadUsers() {
            $.ajax({
                url: "{{ route('users.fetch') }}",
                type: 'GET',
                success: function(response) {
                    const rows = response.success && Array.isArray(response.data) ? response.data : [];
                    usersById = Object.fromEntries(rows.map(u => [u.id, u]));
                    $('#count-active').text(rows.filter(u => u.active).length);
                    $('#count-inactive').text(rows.filter(u => !u.active).length);
                    $('#count-online').text(rows.filter(u => u.online).length);

                    renderClientTable('#users-table', {
                        data: rows,
                        toolbar: '#users-toolbar-buttons',
                        search: '#users-search',
                        emptyText: 'No users found.',
                        columns: [
                            {
                                data: 'name',
                                className: 'all',
                                render: function(data, type, row) {
                                    if (type !== 'display') return `${data} ${row.email}`;
                                    return personCell(data, row.email);
                                }
                            },
                            {
                                data: 'role',
                                render: function(data, type) {
                                    const label = data === 'admin' ? 'Admin' : 'Department Head';
                                    if (type !== 'display') return label;
                                    return pill(data === 'admin' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800', label);
                                }
                            },
                            {
                                data: 'departments',
                                render: function(data, type, row) {
                                    const list = Array.isArray(data) ? data : [];
                                    if (type !== 'display') return row.role === 'admin' ? 'All departments' : list.join(', ');
                                    if (row.role === 'admin') return `<span class="text-gray-500">All departments</span>`;
                                    if (!list.length) return pill('bg-gray-200 text-gray-600', 'Not Assigned');
                                    return `<div class="flex flex-wrap gap-1">${list.map(colorBadgeCell).join('')}</div>`;
                                }
                            },
                            {
                                data: 'position',
                                defaultContent: '',
                                render: (data, type) => type === 'display' ? (data ? escapeHtml(data) : '<span class="text-gray-400">—</span>') : (data || '')
                            },
                            {
                                data: 'active',
                                render: function(data, type) {
                                    if (type !== 'display') return data ? 'Active' : 'Inactive';
                                    return data ?
                                        pill('bg-green-100 text-green-800 inline-flex items-center gap-1', '<span class="w-1.5 h-1.5 rounded-full bg-green-500"></span>Active') :
                                        pill('bg-red-100 text-red-800 inline-flex items-center gap-1', '<span class="w-1.5 h-1.5 rounded-full bg-red-500"></span>Inactive');
                                }
                            },
                            {
                                data: 'online',
                                render: function(data, type, row) {
                                    if (type === 'sort') return row.last_seen_at || '';
                                    if (type !== 'display') return data ? 'Online' : 'Offline';
                                    return data ?
                                        pill('bg-emerald-50 text-emerald-700 inline-flex items-center gap-1', '<span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>Online') :
                                        `<span class="text-gray-500" title="${escapeHtml(row.last_seen_at ? new Date(row.last_seen_at).toLocaleString() : 'Never signed in')}">Offline · ${timeAgo(row.last_seen_at)}</span>`;
                                }
                            },
                            {
                                data: 'joined',
                                render: (data, type) => type === 'display' ? formatDate(data) : (data || '')
                            },
                            {
                                data: null,
                                orderable: false,
                                searchable: false,
                                className: 'noVis all text-center',
                                render: function(data, type, row) {
                                    const toggle = row.is_me ? '' : (row.active ?
                                        `<button type="button" title="Deactivate" class="row-btn cancel" onclick="setUserActive(${row.id}, false)"><i class="fas fa-user-slash"></i></button>` :
                                        `<button type="button" title="Activate" class="row-btn approve" onclick="setUserActive(${row.id}, true)"><i class="fas fa-user-check"></i></button>`);
                                    return `<div class="flex items-center justify-center gap-1.5">
                                        <button type="button" title="Edit" class="row-btn edit" onclick="openEditUser(${row.id})"><i class="fas fa-pen"></i></button>
                                        ${toggle}
                                    </div>`;
                                }
                            }
                        ]
                    });
                },
            });
        }

        function openEditUser(id) {
            const user = usersById[id];
            if (!user) return;
            $('#edit_user_id').val(user.id);
            $('#edit_user_label').text(`${user.name} — ${user.email}`);
            openModal('#editUserModal');
            $('#edit_user_role').val(user.role === 'admin' ? 'admin' : 'user');
            $('#edit_user_position').val(user.position || '');
            $('#edit_user_active').val(user.active ? '1' : '0');
            // You can't demote or deactivate yourself
            $('#edit_user_role, #edit_user_active').prop('disabled', !!user.is_me);
        }

        function sendUserUpdate(id, data, onSuccess) {
            $.ajax({
                url: usersUpdateUrl.replace('__ID__', id),
                type: 'POST',
                data: Object.assign({ _token: $('meta[name="csrf-token"]').attr('content'), _method: 'PUT' }, data),
                success: function(response) {
                    if (onSuccess) onSuccess();
                    Swal.fire({ icon: 'success', title: response.message, showConfirmButton: false, timer: 1200 });
                    loadUsers();
                },
                error: function(xhr) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Could not update user',
                        text: xhr.responseJSON?.message || 'Please check the form and try again.',
                    });
                },
            });
        }

        function updateUser() {
            const id = $('#edit_user_id').val();
            const user = usersById[id] || {};
            const data = { position: $('#edit_user_position').val().trim() };
            if (!user.is_me) {
                data.role = $('#edit_user_role').val();
                data.active = $('#edit_user_active').val();
            }
            sendUserUpdate(id, data, () => closeModal('#editUserModal'));
        }

        function setUserActive(id, active) {
            const user = usersById[id];
            if (!user) return;
            Swal.fire({
                title: active ? `Activate ${user.name}?` : `Deactivate ${user.name}?`,
                text: active ? 'They will be able to log in again.' : "They won't be able to log in, and are signed out on their next page load.",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: active ? '#16a34a' : '#d33',
                confirmButtonText: active ? 'Yes, activate' : 'Yes, deactivate'
            }).then((result) => {
                if (result.isConfirmed) sendUserUpdate(id, { active: active ? 1 : 0 });
            });
        }

        function saveUser() {
            if (!$('#user_email').val()) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Select a person first',
                    text: 'Search the directory above and pick who you\'re registering.',
                });
                return;
            }

            $.ajax({
                url: "{{ route('users.store') }}",
                type: 'POST',
                data: {
                    _token: $('meta[name="csrf-token"]').attr('content'),
                    name: $('#user_name').val(),
                    email: $('#user_email').val(),
                    position: $('#user_position').val(),
                    role: $('#user_role').val(),
                },
                success: function(response) {
                    closeModal('#userModal');
                    Swal.fire({
                        position: "center",
                        icon: "success",
                        title: response.message,
                        showConfirmButton: false,
                        timer: 1500,
                        width: "500px"
                    });
                    loadUsers();
                },
                error: function(xhr) {
                    Swal.fire({
                        icon: "error",
                        title: "Could not register user",
                        text: xhr.responseJSON?.message || 'Please check the form and try again.',
                    });
                },
            });
        }

        // ===== Directory search (autofill from the ticketing system) =====
        let orgDirectory = null; // cached after first load

        function openUserModal() {
            $('#user_search').val('');
            $('#user_name').val('');
            $('#user_email').val('');
            $('#user_position').val('');
            $('#user_role').val('user');
            $('#user_selected').addClass('hidden').text('');
            $('#user_search_results').addClass('hidden').html('');

            openModal('#userModal');
            loadOrgDirectory();
        }

        function loadOrgDirectory() {
            if (orgDirectory !== null) return; // already cached

            $('#user_search').prop('disabled', true).attr('placeholder', 'Loading directory...');
            $.ajax({
                url: "{{ route('users.directory') }}",
                type: 'GET',
                success: function(response) {
                    orgDirectory = (response.success && response.data) ? response.data : [];
                    $('#user_search').prop('disabled', false).attr('placeholder',
                        'Search by name or email...');
                },
                error: function() {
                    orgDirectory = [];
                    $('#user_search').prop('disabled', false).attr('placeholder',
                        'Directory unavailable — type to enter manually');
                },
            });
        }

        $(document).on('input', '#user_search', function() {
            const term = $(this).val().trim().toLowerCase();
            $('#user_name').val('');
            $('#user_email').val('');
            $('#user_position').val('');
            $('#user_selected').addClass('hidden');

            if (!term || !orgDirectory) {
                $('#user_search_results').addClass('hidden').html('');
                return;
            }

            const matches = orgDirectory.filter(function(person) {
                return (person.name && person.name.toLowerCase().includes(term)) ||
                    (person.email && person.email.toLowerCase().includes(term));
            }).slice(0, 20);

            if (matches.length === 0) {
                $('#user_search_results').removeClass('hidden').html(
                    `<div class="px-3 py-2 text-sm text-gray-500">No matches found.</div>`);
                return;
            }

            let html = '';
            matches.forEach(function(person, i) {
                html += `
                <div class="px-3 py-2 text-sm hover:bg-green-50 cursor-pointer directory-result"
                    data-index="${i}">
                    <div class="font-medium text-gray-800">${person.name}</div>
                    <div class="text-gray-500">${person.email}${person.department ? ' &middot; ' + person.department : ''}</div>
                </div>`;
            });
            $('#user_search_results').removeClass('hidden').html(html).data('matches', matches);
        });

        $(document).on('click', '.directory-result', function() {
            const matches = $('#user_search_results').data('matches') || [];
            const person = matches[$(this).data('index')];
            if (!person) return;

            $('#user_name').val(person.name);
            $('#user_email').val(person.email);
            $('#user_position').val(person.position || '');
            $('#user_search').val(person.name);
            $('#user_search_results').addClass('hidden').html('');
            $('#user_selected').removeClass('hidden').html(
                `<i class="fa-solid fa-circle-check text-green-600 mr-1"></i> ${person.name} &mdash; ${person.email}`
            );
        });

        $(document).on('click', function(e) {
            if (!$(e.target).closest('#user_search, #user_search_results').length) {
                $('#user_search_results').addClass('hidden');
            }
        });

        function openModal(modalId) {
            $(modalId).removeClass('hidden').hide().fadeIn(200);
            $(modalId + ' form')[0].reset();
        }

        function closeModal(modalId) {
            $(modalId).fadeOut(200, function() {
                $(this).addClass('hidden');
            });
        }
    </script>
</x-app-layout>

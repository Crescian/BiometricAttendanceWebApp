<x-app-layout>
    <x-approval-table-assets />

    <div class="px-2 lg:px-4">
        <!-- Page header + toolbar -->
        <div class="flex flex-wrap items-center justify-between gap-3 px-4 pt-4 pb-3">
            <div class="flex flex-wrap items-center gap-3">
                <h1 class="text-xl font-semibold text-gray-900">{{ __('Audit Log') }}</h1>
                <div class="flex items-center gap-1.5 text-[11px] font-semibold">
                    <span class="px-2 py-0.5 rounded-full bg-gray-100 text-gray-700">Today {{ number_format($stats['today']) }}</span>
                    <span class="px-2 py-0.5 rounded-full bg-amber-100 text-amber-800">Failed sign-ins (24h) {{ number_format($stats['failed_logins']) }}</span>
                    <span class="px-2 py-0.5 rounded-full bg-red-100 text-red-800">Denied (24h) {{ number_format($stats['denied']) }}</span>
                    <span class="px-2 py-0.5 rounded-full bg-gray-100 text-gray-500">{{ number_format($stats['total']) }} entries</span>
                </div>
            </div>
            <div class="flex flex-wrap items-center gap-2">
                <span id="integrity-status" class="hidden text-xs font-medium"></span>
                <button type="button" onclick="verifyIntegrity()" id="verify-btn"
                    class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-green-700 bg-white border border-green-600 rounded-md hover:bg-green-50">
                    <i class="fa-solid fa-shield-halved"></i>
                    Verify integrity
                </button>
                <button type="button" onclick="exportAudit()"
                    class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-white bg-green-600 rounded-md hover:bg-green-700 shadow-sm">
                    <i class="fa-solid fa-file-csv"></i>
                    Export CSV
                </button>
            </div>
        </div>

        @if ($fallbackEntries > 0)
            <div class="mx-4 mb-3 px-3 py-2 rounded-md border border-red-300 bg-red-50 text-xs text-red-800">
                <i class="fa-solid fa-triangle-exclamation mr-1"></i>
                {{ $fallbackEntries }} audit {{ \Illuminate\Support\Str::plural('entry', $fallbackEntries) }} could not be written to the
                database and {{ $fallbackEntries === 1 ? 'is' : 'are' }} held in <code>storage/logs/audit-fallback*.log</code>.
                Investigate the cause; these entries must be reviewed with the rest of the trail.
            </div>
        @endif

        <!-- Filters -->
        <div class="px-4 pb-3">
            <div class="flex flex-wrap items-end gap-2 text-xs">
                <label class="flex flex-col gap-1">
                    <span class="text-[11px] font-semibold uppercase tracking-wide text-gray-500">From</span>
                    <input type="date" id="f-from" class="audit-filter py-1 px-2 text-xs border border-gray-300 rounded-md">
                </label>
                <label class="flex flex-col gap-1">
                    <span class="text-[11px] font-semibold uppercase tracking-wide text-gray-500">To</span>
                    <input type="date" id="f-to" class="audit-filter py-1 px-2 text-xs border border-gray-300 rounded-md">
                </label>
                <label class="flex flex-col gap-1">
                    <span class="text-[11px] font-semibold uppercase tracking-wide text-gray-500">User</span>
                    <select id="f-actor" class="audit-filter py-1 pl-2 pr-7 text-xs border border-gray-300 rounded-md">
                        <option value="">All users</option>
                        @foreach ($actors as $actor)
                            <option value="{{ $actor->actor_id }}">{{ $actor->actor_name ?: $actor->actor_email }}</option>
                        @endforeach
                    </select>
                </label>
                <label class="flex flex-col gap-1">
                    <span class="text-[11px] font-semibold uppercase tracking-wide text-gray-500">Category</span>
                    <select id="f-category" class="audit-filter py-1 pl-2 pr-7 text-xs border border-gray-300 rounded-md">
                        <option value="">All</option>
                        @foreach ($categories as $category)
                            <option value="{{ $category }}">{{ ucfirst($category) }}</option>
                        @endforeach
                    </select>
                </label>
                <label class="flex flex-col gap-1">
                    <span class="text-[11px] font-semibold uppercase tracking-wide text-gray-500">Outcome</span>
                    <select id="f-outcome" class="audit-filter py-1 pl-2 pr-7 text-xs border border-gray-300 rounded-md">
                        <option value="">All</option>
                        <option value="success">Success</option>
                        <option value="failure">Failure</option>
                        <option value="denied">Denied</option>
                    </select>
                </label>
                <label class="flex flex-col gap-1 grow max-w-xs">
                    <span class="text-[11px] font-semibold uppercase tracking-wide text-gray-500">Search</span>
                    <div class="relative">
                        <i class="fa-solid fa-magnifying-glass absolute left-2.5 top-1/2 -translate-y-1/2 text-gray-400 text-[10px]"></i>
                        <input id="f-q" type="search" placeholder="Description, event, user, IP, record id"
                            class="w-full pl-7 pr-2 py-1 text-xs border border-gray-300 rounded-md">
                    </div>
                </label>
                <input type="hidden" id="f-request">
                <span id="request-chip" class="hidden items-center gap-1 px-2 py-1 rounded-md bg-blue-50 text-blue-800 text-[11px]">
                    Request <code id="request-chip-id"></code>
                    <button type="button" onclick="clearRequestFilter()" class="ml-1 text-blue-600 hover:text-blue-900">&times;</button>
                </span>
                <button type="button" onclick="clearFilters()" class="py-1 px-2 text-xs text-gray-500 hover:text-gray-800 underline">Clear</button>
                <div id="audit-toolbar-buttons" class="flex items-center gap-2 ml-auto"></div>
            </div>
        </div>

        <!-- Table card -->
        <div class="px-4 pb-4">
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm">
                <div class="p-2 text-gray-900">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="audit-table" class="modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th>Time</th>
                                        <th>User</th>
                                        <th>Event</th>
                                        <th>Target</th>
                                        <th>Description</th>
                                        <th>Outcome</th>
                                        <th>IP Address</th>
                                        <th>Details</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Entry detail modal -->
        <div id="auditDetailModal" class="hidden fixed inset-0 z-50 items-center justify-center bg-black/50 px-4">
            <div class="w-full max-w-3xl max-h-[90vh] flex flex-col bg-white rounded-lg shadow-xl">
                <div class="flex items-center justify-between px-5 py-3 border-b border-gray-200">
                    <h3 class="text-sm font-semibold text-gray-900">
                        <i class="fa-solid fa-shield-halved text-green-600 mr-1"></i>
                        Audit entry <span id="d-id"></span>
                    </h3>
                    <button type="button" onclick="closeDetail()" class="text-gray-400 hover:text-gray-700 text-xl">&times;</button>
                </div>
                <div id="d-body" class="px-5 py-4 overflow-y-auto text-xs space-y-4"></div>
            </div>
        </div>
    </div>

    <script>
        const CATEGORY_STYLE = {
            auth: 'bg-indigo-100 text-indigo-800',
            access: 'bg-sky-100 text-sky-800',
            approval: 'bg-green-100 text-green-800',
            data: 'bg-gray-100 text-gray-700',
            import: 'bg-purple-100 text-purple-800',
            report: 'bg-teal-100 text-teal-800',
            admin: 'bg-amber-100 text-amber-800',
            security: 'bg-rose-100 text-rose-800',
        };
        const OUTCOME_STYLE = {
            success: 'bg-green-100 text-green-800',
            failure: 'bg-amber-100 text-amber-800',
            denied: 'bg-red-100 text-red-800',
        };

        const esc = (value) => $('<div>').text(value ?? '').html();
        const pill = (classes, text) => `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full whitespace-nowrap ${classes}">${esc(text)}</span>`;

        function formatTime(iso, withSeconds = true) {
            const d = new Date(iso);
            return d.toLocaleString('en-US', {
                month: 'short', day: 'numeric', year: 'numeric',
                hour: '2-digit', minute: '2-digit', second: withSeconds ? '2-digit' : undefined,
                hour12: false, timeZone: 'Asia/Manila'
            });
        }

        function filters() {
            return {
                from: $('#f-from').val(),
                to: $('#f-to').val(),
                actor_id: $('#f-actor').val(),
                category: $('#f-category').val(),
                outcome: $('#f-outcome').val(),
                request_id: $('#f-request').val(),
                q: $('#f-q').val().trim(),
            };
        }

        const auditTable = $('#audit-table').DataTable({
            processing: true,
            serverSide: true,
            searching: true,
            autoWidth: false,
            responsive: { details: { type: 'column', target: 0 } },
            lengthChange: true,
            lengthMenu: [25, 50, 100, 250],
            pageLength: 50,
            dom: 'rt<"flex flex-wrap justify-between items-center gap-2 px-3 py-2 border-t border-gray-200 text-xs text-gray-600"lip>',
            order: [[1, 'desc']],
            ajax: {
                url: "{{ route('audit.data') }}",
                data: function(d) {
                    Object.assign(d, filters());
                    d.search = { value: '', regex: false }; // filtering is done by the q filter above
                }
            },
            buttons: [
                toolbarButton({
                    extend: 'colvis',
                    text: '<i class="fa-solid fa-table-columns text-gray-500"></i> Columns',
                    columns: ':not(.noVis)'
                })
            ],
            columns: [
                expandControlColumn,
                {
                    data: 'occurred_at',
                    name: 'occurred_at',
                    render: (data, type) => type === 'display'
                        ? `<span title="${esc(new Date(data).toISOString())} UTC">${formatTime(data)}</span>`
                        : data
                },
                {
                    data: 'actor_name',
                    name: 'actor_name',
                    className: 'all',
                    render: function(data, type, row) {
                        if (type !== 'display') return data || row.actor_email || '';
                        if (!data && !row.actor_email) return '<span class="text-gray-400">System / anonymous</span>';
                        const role = row.actor_role ? (row.actor_role === 'admin' ? 'Admin' : 'Department Head') : '';
                        return personCell(data || row.actor_email, [row.actor_email, role].filter(Boolean).join(' · '));
                    }
                },
                {
                    data: 'event',
                    name: 'event',
                    render: (data, type, row) => type === 'display'
                        ? `<div class="flex flex-col gap-0.5"><code class="text-[11px] text-gray-800">${esc(data)}</code>${pill(CATEGORY_STYLE[row.category] || 'bg-gray-100 text-gray-700', row.category)}</div>`
                        : data
                },
                {
                    data: 'auditable_type',
                    name: 'auditable_type',
                    defaultContent: '',
                    render: (data, type, row) => !data ? '' : (type === 'display'
                        ? `<span class="text-gray-700">${esc(data)}</span> <span class="text-gray-400">#${esc(row.auditable_id)}</span>`
                        : `${data} ${row.auditable_id}`)
                },
                {
                    data: 'description',
                    name: 'description',
                    orderable: false,
                    defaultContent: '',
                    render: (data, type) => type === 'display'
                        ? `<span class="block max-w-[28rem] truncate" title="${esc(data)}">${esc(data)}</span>`
                        : data
                },
                {
                    data: 'outcome',
                    name: 'outcome',
                    render: (data, type) => type === 'display' ? pill(OUTCOME_STYLE[data] || 'bg-gray-100 text-gray-700', data) : data
                },
                {
                    data: 'ip_address',
                    name: 'ip_address',
                    defaultContent: '',
                    render: (data, type) => type === 'display' ? `<code class="text-[11px] text-gray-600">${esc(data || '—')}</code>` : (data || '')
                },
                {
                    data: 'id',
                    orderable: false,
                    searchable: false,
                    className: 'noVis all text-center',
                    render: (id) => `<button type="button" title="View details" class="row-btn approve" onclick="openDetail(${Number(id)})"><i class="fas fa-eye"></i></button>`
                }
            ],
            language: {
                emptyTable: "No audit entries match these filters",
                info: "Showing _START_ to _END_ of _TOTAL_ entries",
                lengthMenu: "Rows per page _MENU_",
                processing: "Loading…",
                paginate: { first: "First", last: "Last", next: "Next", previous: "Previous" }
            }
        });
        auditTable.buttons().container().appendTo('#audit-toolbar-buttons');

        let filterTimer;
        $(document).on('change', '.audit-filter', () => auditTable.ajax.reload());
        $(document).on('input', '#f-q', function() {
            clearTimeout(filterTimer);
            filterTimer = setTimeout(() => auditTable.ajax.reload(), 400);
        });

        function clearFilters() {
            $('#f-from, #f-to, #f-actor, #f-category, #f-outcome, #f-q').val('');
            clearRequestFilter(false);
            auditTable.ajax.reload();
        }

        function filterByRequest(requestId) {
            $('#f-request').val(requestId);
            $('#request-chip-id').text(requestId.slice(0, 8) + '…');
            $('#request-chip').removeClass('hidden').addClass('inline-flex');
            closeDetail();
            auditTable.ajax.reload();
        }

        function clearRequestFilter(reload = true) {
            $('#f-request').val('');
            $('#request-chip').addClass('hidden').removeClass('inline-flex');
            if (reload) auditTable.ajax.reload();
        }

        function exportAudit() {
            const params = new URLSearchParams(Object.entries(filters()).filter(([, v]) => v));
            window.location = "{{ route('audit.export') }}" + (params.toString() ? '?' + params.toString() : '');
        }

        function verifyIntegrity() {
            const button = $('#verify-btn').prop('disabled', true);
            $('#integrity-status').removeClass('hidden text-green-700 text-red-700').addClass('text-gray-500').text('Verifying…');
            $.ajax({
                url: "{{ route('audit.verify') }}",
                type: 'POST',
                data: { _token: $('meta[name="csrf-token"]').attr('content') },
                success: function(r) {
                    if (r.ok) {
                        $('#integrity-status').removeClass('text-gray-500').addClass('text-green-700')
                            .html(`<i class="fa-solid fa-circle-check mr-1"></i>${Number(r.checked).toLocaleString()} entries verified, chain intact`);
                    } else {
                        $('#integrity-status').removeClass('text-gray-500').addClass('text-red-700')
                            .html(`<i class="fa-solid fa-triangle-exclamation mr-1"></i>Integrity check failed at entry #${esc(r.broken_id)}`);
                        Swal.fire('Integrity check failed', `Entry #${r.broken_id}: ${r.reason}`, 'error');
                    }
                    auditTable.ajax.reload(null, false);
                },
                error: () => $('#integrity-status').text('Could not run the check. Please try again.'),
                complete: () => button.prop('disabled', false)
            });
        }

        // ---- Entry detail ----
        function valueText(value) {
            if (value === null || value === undefined || value === '') return '<span class="text-gray-400">∅</span>';
            if (typeof value === 'object') return `<code class="whitespace-pre-wrap break-all">${esc(JSON.stringify(value, null, 2))}</code>`;
            return esc(String(value));
        }

        function changesTable(oldValues, newValues) {
            const keys = [...new Set([...Object.keys(oldValues || {}), ...Object.keys(newValues || {})])];
            if (!keys.length) return '<p class="text-gray-400">No field values recorded for this event.</p>';
            return `<table class="w-full border border-gray-200 rounded">
                <thead class="bg-gray-50 text-[11px] uppercase text-gray-500"><tr>
                    <th class="text-left px-2 py-1 w-1/4">Field</th><th class="text-left px-2 py-1">Before</th><th class="text-left px-2 py-1">After</th>
                </tr></thead>
                <tbody>${keys.map(k => `<tr class="border-t border-gray-100 align-top">
                    <td class="px-2 py-1 font-medium text-gray-700">${esc(k)}</td>
                    <td class="px-2 py-1 text-red-700 bg-red-50/40">${valueText((oldValues || {})[k])}</td>
                    <td class="px-2 py-1 text-green-800 bg-green-50/40">${valueText((newValues || {})[k])}</td>
                </tr>`).join('')}</tbody></table>`;
        }

        function field(label, html) {
            return `<div><div class="text-[11px] font-semibold uppercase tracking-wide text-gray-500">${label}</div><div class="text-gray-800 break-all">${html}</div></div>`;
        }

        function openDetail(id) {
            $('#auditDetailModal').removeClass('hidden').addClass('flex');
            $('#d-id').text('#' + id);
            $('#d-body').html('<p class="text-gray-500">Loading…</p>');
            $.getJSON("{{ route('audit.show', ['id' => '__ID__']) }}".replace('__ID__', id), function(r) {
                const e = r.data;
                const actor = e.actor_name || e.actor_email
                    ? `${esc(e.actor_name || '')} ${e.actor_email ? '&lt;' + esc(e.actor_email) + '&gt;' : ''} ${e.actor_role ? '· ' + esc(e.actor_role) : ''} ${e.actor_id ? '· user #' + esc(e.actor_id) : ''}`
                    : '<span class="text-gray-400">System / anonymous</span>';
                const request = e.request_id
                    ? `<code>${esc(e.request_id)}</code> <button type="button" class="ml-1 text-blue-600 hover:underline" onclick="filterByRequest('${esc(e.request_id)}')">Show all from this request</button>`
                    : '<span class="text-gray-400">—</span>';

                $('#d-body').html(`
                    <div class="flex flex-wrap items-center gap-2">
                        <code class="text-sm text-gray-900">${esc(e.event)}</code>
                        ${pill(CATEGORY_STYLE[e.category] || 'bg-gray-100 text-gray-700', e.category)}
                        ${pill(OUTCOME_STYLE[e.outcome] || 'bg-gray-100 text-gray-700', e.outcome)}
                    </div>
                    <p class="text-sm text-gray-800">${esc(e.description || '')}</p>
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        ${field('When', `${formatTime(e.occurred_at)} (Manila)<br><span class="text-gray-500">${esc(new Date(e.occurred_at).toISOString())} UTC</span>`)}
                        ${field('Who', actor)}
                        ${field('Target', e.auditable_type ? `${esc(e.auditable_type)} #${esc(e.auditable_id)}` : '<span class="text-gray-400">—</span>')}
                        ${field('Action', esc(e.action))}
                        ${field('Where', `${esc(e.ip_address || '—')} · ${esc(e.http_method || '')} ${esc(e.route || '')}`)}
                        ${field('Request', request)}
                    </div>
                    <div>
                        <div class="text-[11px] font-semibold uppercase tracking-wide text-gray-500 mb-1">Changes</div>
                        ${changesTable(e.old_values, e.new_values)}
                    </div>
                    ${e.metadata ? `<div><div class="text-[11px] font-semibold uppercase tracking-wide text-gray-500 mb-1">Details</div>
                        <pre class="bg-gray-50 border border-gray-200 rounded p-2 text-[11px] whitespace-pre-wrap break-all">${esc(JSON.stringify(e.metadata, null, 2))}</pre></div>` : ''}
                    <div class="grid grid-cols-1 gap-2 border-t border-gray-200 pt-3">
                        ${field('URL', esc(e.url || '—'))}
                        ${field('User agent', esc(e.user_agent || '—'))}
                        ${field('Session (hashed)', `<code>${esc(e.session_hash || '—')}</code>`)}
                        ${field('Entry hash', `<code>${esc(e.hash)}</code>`)}
                        ${field('Previous hash', `<code>${esc(e.prev_hash)}</code>`)}
                    </div>
                `);
            }).fail(() => $('#d-body').html('<p class="text-red-600">Could not load this entry.</p>'));
        }

        function closeDetail() {
            $('#auditDetailModal').addClass('hidden').removeClass('flex');
        }
    </script>
</x-app-layout>

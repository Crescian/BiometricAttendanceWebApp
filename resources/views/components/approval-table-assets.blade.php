{{--
    Shared look for the approval tables (Overtime, Leaves, Certificates of Attendance, Schedule Adjustments):
    light "modern-table" styling, quiet toolbar / row buttons, and the small JS helpers the pages' DataTables use.
--}}
@once
    <style>
        /* ===== Table + toolbar look (light header, compact rows, quiet buttons) =====
           Compact scale to match the dashboard: 11px headers, 12px cells, ~34px rows. */
        .toolbar-btn {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            padding: .375rem .7rem;
            font-size: .75rem;
            font-weight: 500;
            color: #374151;
            background: #f3f4f6;
            border: 1px solid #e5e7eb;
            border-radius: .375rem;
            cursor: pointer;
            transition: background-color .15s;
        }

        .toolbar-btn:hover {
            background: #e5e7eb;
        }

        .dt-button-collection .toolbar-btn {
            width: 100%;
            justify-content: flex-start;
            margin: 0 0 .25rem;
        }

        table.modern-table.dataTable {
            border-collapse: collapse !important;
            margin: 0 !important;
        }

        table.modern-table thead th {
            background: #f9fafb;
            color: #6b7280;
            font-size: .6875rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .03em;
            text-align: left;
            padding: .5rem .625rem !important;
            border-bottom: 1px solid #e5e7eb !important;
            white-space: nowrap;
        }

        table.modern-table tbody td {
            font-size: .75rem;
            line-height: 1.25;
            padding: .375rem .625rem !important;
            border-bottom: 1px solid #f3f4f6;
            color: #1f2937;
            white-space: nowrap;
        }

        table.modern-table tbody tr:hover td {
            background: #f9fafb;
        }

        table.modern-table td.dtr-control,
        table.modern-table th:first-child {
            width: 1.5rem;
            padding-left: .375rem !important;
            padding-right: .375rem !important;
        }

        /* Center the Responsive +/- control in its own column */
        table.modern-table td.dtr-control {
            position: relative;
            text-align: center;
        }

        table.modern-table td.dtr-control:before {
            position: absolute !important;
            top: 50% !important;
            left: 50% !important;
            margin: 0 !important;
            transform: translate(-50%, -50%);
        }

        /* Expanded row (Responsive child): hidden fields on one compact line, divider-separated */
        table.modern-table tbody td.child {
            white-space: normal;
            padding: .375rem .625rem !important;
            background: #fcfcfd;
        }

        table.modern-table tbody tr.child:hover td {
            background: #fcfcfd;
        }

        table.modern-table ul.dtr-details {
            display: flex !important;
            flex-wrap: nowrap;
            overflow-x: auto;
            /* width 0 keeps the strip from stretching the table; min-width fills the row */
            width: 0;
            min-width: 100%;
            margin: 0;
            padding: 0;
            scrollbar-width: thin;
        }

        table.modern-table ul.dtr-details > li {
            flex: 1 0 auto;
            display: flex;
            flex-direction: column;
            gap: .125rem;
            padding: .125rem .625rem !important;
            border: 0 !important;
            border-left: 1px solid #e5e7eb !important;
        }

        table.modern-table ul.dtr-details > li:first-child {
            border-left: 0 !important;
        }

        table.modern-table ul.dtr-details > li .dtr-title {
            min-width: 0 !important;
            font-size: .65rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .03em;
            color: #6b7280;
        }

        table.modern-table ul.dtr-details > li .dtr-data {
            font-size: .75rem;
            color: #111827;
            white-space: nowrap;
        }

        .row-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 1.5rem;
            height: 1.5rem;
            border-radius: .3rem;
            border: 1px solid #d1d5db;
            background: #fff;
            font-size: .7rem;
            transition: background-color .15s, border-color .15s;
        }

        .row-btn:hover {
            background: #f9fafb;
        }

        .row-btn.approve { color: #2563eb; }
        .row-btn.approve:hover { border-color: #2563eb; }
        .row-btn.edit { color: #16a34a; }
        .row-btn.edit:hover { border-color: #16a34a; }
        .row-btn.cancel { color: #dc2626; }
        .row-btn.cancel:hover { border-color: #dc2626; }
        .row-btn.restore { color: #d97706; }
        .row-btn.restore:hover { border-color: #d97706; }

        .bulk-approve-modal .select2-container { width: 100% !important; }

        /* DataTables footer (rows per page, info, pagination) at the same compact scale */
        .dataTables_wrapper .dataTables_length,
        .dataTables_wrapper .dataTables_info,
        .dataTables_wrapper .dataTables_paginate {
            font-size: .75rem;
            padding-top: 0 !important;
        }

        .dataTables_wrapper .dataTables_length select {
            padding: .125rem 1.5rem .125rem .4rem;
            font-size: .75rem;
        }

        .dataTables_wrapper .dataTables_paginate .paginate_button {
            padding: .2rem .55rem !important;
            min-width: 1.5rem;
        }
    </style>

    <script>
        // Colored initials avatar next to a name (optional grey second line); the color is stable per name
        function avatarCell(label, initials, subtitle) {
            const palette = ['#6366f1', '#ec4899', '#0ea5e9', '#f59e0b', '#10b981', '#ef4444', '#8b5cf6', '#14b8a6'];
            const color = palette[[...label].reduce((sum, c) => sum + c.charCodeAt(0), 0) % palette.length];
            const escape = (value) => $('<div>').text(value).html();
            const second = subtitle ? `<span class="block text-[11px] text-gray-500">${escape(subtitle)}</span>` : '';
            return `<div class="flex items-center gap-2">
                        <span class="shrink-0 w-6 h-6 rounded-full text-white text-[10px] font-semibold flex items-center justify-center" style="background-color:${color}">${(initials || '?').toUpperCase()}</span>
                        <span class="leading-tight">${escape(label)}${second}</span>
                    </div>`;
        }

        // Initials avatar + "LAST, FIRST" for the Employee column
        function employeeCell(lastName, firstName) {
            const last = (lastName || '').trim();
            const first = (firstName || '').trim();
            return avatarCell(first ? `${last}, ${first}` : last, (first[0] || '') + (last[0] || ''));
        }

        // Initials avatar + a plain name ("Juan Dela Cruz") for user / account columns
        function personCell(fullName, subtitle) {
            const words = (fullName || '').trim().split(/\s+/).filter(Boolean);
            return avatarCell(words.join(' '), ((words[0] || '')[0] || '') + (words.length > 1 ? words[words.length - 1][0] : ''), subtitle);
        }

        // Same cell from a single "LAST, FIRST" employee_name
        function employeeNameCell(fullName) {
            const [last, ...rest] = (fullName || '').split(',');
            return employeeCell(last, rest.join(','));
        }

        // Colored pill for a department / report-to name; the color is stable per name
        function colorBadgeCell(data) {
            if (!data || data.trim() === '' || data === 'Not Assigned') {
                return `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full bg-gray-300 text-gray-800">Not Assigned</span>`;
            }
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
            const colorClass = colors[[...data].reduce((sum, c) => sum + c.charCodeAt(0), 0) % colors.length];
            return `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full ${colorClass}">${$('<div>').text(data).html()}</span>`;
        }

        // Pending / Approved / Cancelled pill (any letter case)
        function statusBadgeCell(data) {
            const status = (data || '').toLowerCase();
            const badgeClass = status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                status === 'approved' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800';
            return `<span class="px-1.5 py-0.5 rounded-full text-[11px] font-semibold capitalize ${badgeClass}">${data || ''}</span>`;
        }

        // Row action buttons by status: Approve + Cancel / Cancel / Restore
        function approvalActionButtons(status, id, handlers) {
            const button = (kind, title, icon, fn) =>
                `<button type="button" title="${title}" onclick="${fn}(${id})" class="row-btn ${kind}"><i class="fas ${icon}"></i></button>`;
            const approve = button('approve', 'Approve', 'fa-check', handlers.approve);
            const cancel = button('cancel', 'Cancel', 'fa-times', handlers.cancel);
            const restore = button('restore', 'Restore', 'fa-undo', handlers.restore);
            const buttons = { pending: approve + cancel, approved: cancel, cancelled: restore }[(status || '').toLowerCase()];
            return buttons ? `<div class="flex items-center justify-center gap-1.5">${buttons}</div>` : '';
        }

        // "2025-01-31 00:00:00" -> "2025-01-31"
        function dateOnlyCell(data) {
            return data ? String(data).split(' ')[0] : '';
        }

        // Buttons rendered by DataTables, restyled as quiet toolbar buttons
        function toolbarButton(extra) {
            return Object.assign({
                className: 'toolbar-btn',
                init: function(api, node) {
                    $(node).removeClass('dt-button');
                }
            }, extra);
        }

        // The standard Export + Columns toolbar buttons
        function exportAndColumnButtons() {
            return [
                toolbarButton({
                    extend: 'collection',
                    text: '<i class="fa-solid fa-download text-gray-500"></i> Export',
                    buttons: [
                        toolbarButton({ extend: 'copyHtml5', text: '<i class="fa fa-copy text-gray-600"></i> Copy' }),
                        toolbarButton({ extend: 'excelHtml5', text: '<i class="fa fa-file-excel text-green-600"></i> Excel' }),
                        toolbarButton({ extend: 'csvHtml5', text: '<i class="fa fa-file-csv text-blue-600"></i> CSV' }),
                        toolbarButton({ extend: 'pdfHtml5', text: '<i class="fa fa-file-pdf text-red-600"></i> PDF' }),
                        toolbarButton({ extend: 'print', text: '<i class="fa fa-print text-gray-600"></i> Print' })
                    ]
                }),
                toolbarButton({
                    extend: 'colvis',
                    text: '<i class="fa-solid fa-table-columns text-gray-500"></i> Columns',
                    columns: ':not(.noVis)'
                })
            ];
        }

        // Responsive expand / collapse (+/-) control column
        const expandControlColumn = {
            data: null,
            defaultContent: '',
            orderable: false,
            searchable: false,
            className: 'dtr-control noVis all text-center'
        };

        // Client-side DataTable (rows already loaded with $.ajax) in the shared look.
        // Re-creates the table on every call, so it doubles as a "reload with new rows".
        function renderClientTable(selector, options) {
            if ($.fn.DataTable.isDataTable(selector)) {
                $(selector).DataTable().clear().destroy();
            }
            const toolbar = options.toolbar;
            if (toolbar) $(toolbar).empty();

            const table = $(selector).DataTable({
                data: options.data || [],
                autoWidth: false,
                responsive: {
                    details: {
                        type: 'column',
                        target: 0
                    }
                },
                lengthChange: true,
                lengthMenu: [10, 20, 50, 100],
                pageLength: options.pageLength || 50,
                dom: 'rt<"flex flex-wrap justify-between items-center gap-2 px-3 py-2 border-t border-gray-200 text-xs text-gray-600"lip>',
                search: {
                    search: options.search ? ($(options.search).val() || '') : ''
                },
                order: options.order || [
                    [1, 'asc']
                ],
                buttons: exportAndColumnButtons(),
                columns: [expandControlColumn, ...options.columns],
                language: {
                    emptyTable: options.emptyText || "No records available",
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
            if (toolbar) table.buttons().container().appendTo(toolbar);
            return table;
        }

        // Header search box drives a DataTable search (debounced)
        function bindTableSearch(inputSelector, tableSelector) {
            let timer;
            $(document).on('input', inputSelector, function() {
                clearTimeout(timer);
                const term = this.value;
                timer = setTimeout(function() {
                    if ($.fn.DataTable.isDataTable(tableSelector)) {
                        $(tableSelector).DataTable().search(term).draw();
                    }
                }, 350);
            });
        }
    </script>
@endonce

{{--
    Toolbar buttons + modal for approving many pending records at once:
    tick rows and "Approve selected (N)", or "Bulk approve" all / by department / employee / date.

    Creates a page object window.bulk_<prefix> that the page's DataTable uses:
      bulk_<prefix>.setStatus(status)   call at the start of the page's load…(status)
      bulk_<prefix>.checkboxColumn()    the row-checkbox column definition
      bulk_<prefix>.syncSelectAll()     call from drawCallback
    The table header needs <input type="checkbox" id="<prefix>-select-all"> in the checkbox column.
--}}
@props([
    'prefix',
    'table',                       // table selector, e.g. '#leaves-table'
    'pending' => 'Pending',        // the status value of the Pending tab
    'title',                       // modal title noun, e.g. 'leaves'
    'one',                         // e.g. 'leave request'
    'many',                        // e.g. 'leave requests'
    'approveUrl',
    'optionsUrl',
    'approveByUrl',
    'onDone',                      // the page's counts loader, e.g. 'loadLeavesCounts'
])

@php
    $instance = 'bulk_' . $prefix;
    $config = compact('prefix', 'table', 'pending', 'one', 'many', 'approveUrl', 'optionsUrl', 'approveByUrl', 'onDone');
@endphp

<button type="button" id="{{ $prefix }}-bulk-by-btn" onclick="{{ $instance }}.openModal()"
    class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-green-700 bg-white border border-green-600 rounded-md hover:bg-green-50">
    <i class="fa-solid fa-layer-group"></i>
    Bulk approve
</button>
<button type="button" id="{{ $prefix }}-bulk-clear" onclick="{{ $instance }}.clearSelection()"
    class="hidden text-xs text-gray-500 hover:text-gray-800 underline">Clear</button>
<button type="button" id="{{ $prefix }}-bulk-approve" onclick="{{ $instance }}.approveSelected()"
    class="hidden items-center gap-2 px-3 py-1.5 text-xs font-medium text-white bg-green-600 rounded-md hover:bg-green-700 shadow-sm">
    <i class="fa-solid fa-check-double"></i>
    Approve selected (<span id="{{ $prefix }}-bulk-count">0</span>)
</button>

<!-- Bulk approve by All / Department / Employee / Date -->
<div id="{{ $prefix }}-bulk-modal" class="bulk-approve-modal hidden fixed inset-0 z-50 items-center justify-center bg-black/50 px-4">
    <div class="w-full max-w-lg bg-white rounded-lg shadow-xl">
        <div class="flex items-center justify-between px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900">
                <i class="fa-solid fa-layer-group text-green-600 mr-2"></i>Bulk approve {{ $title }}
            </h3>
            <button type="button" onclick="{{ $instance }}.closeModal()" class="text-gray-400 hover:text-gray-700 text-xl">&times;</button>
        </div>
        <div class="px-6 py-5 space-y-4">
            <div>
                <p class="block text-sm font-medium text-gray-700 mb-2">Approve by</p>
                <div class="inline-flex flex-wrap p-1 bg-gray-100 rounded-lg" role="tablist">
                    <button type="button" data-bulk-mode="all" onclick="{{ $instance }}.setMode('all')"
                        class="bulk-mode px-4 py-1.5 text-sm font-medium rounded-md">
                        <i class="fa-solid fa-check-double mr-1"></i> All
                    </button>
                    <button type="button" data-bulk-mode="department" onclick="{{ $instance }}.setMode('department')"
                        class="bulk-mode px-4 py-1.5 text-sm font-medium rounded-md">
                        <i class="fa-solid fa-sitemap mr-1"></i> Department
                    </button>
                    <button type="button" data-bulk-mode="employee" onclick="{{ $instance }}.setMode('employee')"
                        class="bulk-mode px-4 py-1.5 text-sm font-medium rounded-md">
                        <i class="fa-solid fa-user mr-1"></i> Employee
                    </button>
                    <button type="button" data-bulk-mode="date" onclick="{{ $instance }}.setMode('date')"
                        class="bulk-mode px-4 py-1.5 text-sm font-medium rounded-md">
                        <i class="fa-regular fa-calendar mr-1"></i> Date
                    </button>
                </div>
            </div>
            <div id="{{ $prefix }}-bulk-value-wrap">
                <label for="{{ $prefix }}-bulk-value" id="{{ $prefix }}-bulk-value-label" class="block text-sm font-medium text-gray-700 mb-2">Department</label>
                <select id="{{ $prefix }}-bulk-value" class="w-full"></select>
            </div>
            <p id="{{ $prefix }}-bulk-summary" class="text-sm text-gray-600">Loading…</p>
        </div>
        <div class="flex justify-end gap-2 px-6 py-4 border-t border-gray-200 bg-gray-50 rounded-b-lg">
            <button type="button" onclick="{{ $instance }}.closeModal()"
                class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-100">Cancel</button>
            <button type="button" id="{{ $prefix }}-bulk-by-submit" onclick="{{ $instance }}.submitBy()" disabled
                class="px-4 py-2 text-sm font-medium text-white bg-green-600 rounded-md hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed">Approve</button>
        </div>
    </div>
</div>

@once
    <script>
        function createBulkApprove(cfg) {
            const el = (name) => $(`#${cfg.prefix}-${name}`);
            const rowCheck = `${cfg.table} .${cfg.prefix}-row-check`;
            const records = (n) => `${n} ${n === 1 ? cfg.one : cfg.many}`;
            const isAdmin = "{{ Auth::user()->role ?? '' }}" === 'admin';

            const self = {
                selected: new Set(),
                status: cfg.pending,
                options: null,
                mode: 'all',

                isPending() {
                    return self.status === cfg.pending;
                },

                // Call at the start of the page's load…(status)
                setStatus(status) {
                    if (status !== self.status) {
                        self.selected.clear();
                    }
                    self.status = status;
                    self.updateBar();
                    el('bulk-by-btn').toggleClass('hidden', !self.isPending()).toggleClass('inline-flex', self.isPending());
                    el('select-all').prop({ checked: false, indeterminate: false });
                },

                // Multi-select checkbox column (Pending tab only)
                checkboxColumn() {
                    return {
                        data: 'id',
                        orderable: false,
                        searchable: false,
                        visible: self.isPending(),
                        className: 'noVis all text-center',
                        render: function(id) {
                            const checked = self.selected.has(Number(id)) ? 'checked' : '';
                            return `<input type="checkbox" class="${cfg.prefix}-row-check rounded border-gray-300 text-green-600 focus:ring-green-500" value="${id}" ${checked}>`;
                        }
                    };
                },

                updateBar() {
                    const n = self.selected.size;
                    el('bulk-count').text(n);
                    el('bulk-approve').toggleClass('hidden', n === 0).toggleClass('inline-flex', n > 0);
                    el('bulk-clear').toggleClass('hidden', n === 0);
                },

                syncSelectAll() {
                    const boxes = $(rowCheck);
                    const checked = boxes.filter(':checked').length;
                    el('select-all').prop({
                        checked: boxes.length > 0 && checked === boxes.length,
                        indeterminate: checked > 0 && checked < boxes.length
                    });
                },

                clearSelection() {
                    self.selected.clear();
                    $(rowCheck).prop('checked', false);
                    self.updateBar();
                    self.syncSelectAll();
                },

                afterApprove() {
                    self.clearSelection();
                    $(cfg.table).DataTable().ajax.reload(null, false);
                    if (typeof window[cfg.onDone] === 'function') {
                        window[cfg.onDone]();
                    }
                },

                showError(xhr) {
                    const message = (xhr.responseJSON && xhr.responseJSON.message) || xhr.responseText;
                    Swal.fire("Error!", "An error occurred: " + message, "error");
                },

                approveSelected() {
                    const ids = [...self.selected];
                    if (!ids.length) return;

                    Swal.fire({
                        title: `Approve ${records(ids.length)}?`,
                        text: `The selected ${cfg.many} will be marked as Approved.`,
                        icon: "warning",
                        showCancelButton: true,
                        confirmButtonColor: "#16a34a",
                        cancelButtonColor: "#d33",
                        confirmButtonText: "Yes, approve them"
                    }).then((result) => {
                        if (!result.isConfirmed) return;
                        Swal.fire({ title: 'Approving…', allowOutsideClick: false, didOpen: () => Swal.showLoading() });
                        $.ajax({
                            url: cfg.approveUrl,
                            type: "POST",
                            data: {
                                ids: ids,
                                _token: "{{ csrf_token() }}"
                            },
                            success: function(response) {
                                Swal.fire({
                                    title: "Approved!",
                                    text: response.message,
                                    icon: "success",
                                    timer: response.skipped > 0 ? undefined : 2000,
                                    showConfirmButton: response.skipped > 0
                                });
                                self.afterApprove();
                            },
                            error: self.showError
                        });
                    });
                },

                // ===== Bulk approve by All / Department / Employee / Date =====
                openModal() {
                    el('bulk-modal').removeClass('hidden').addClass('flex');
                    el('bulk-summary').text('Loading…');
                    el('bulk-by-submit').prop('disabled', true).text('Approve');
                    $.getJSON(cfg.optionsUrl, function(response) {
                        self.options = response;
                        self.setMode(self.mode);
                    }).fail(function() {
                        el('bulk-summary').text(`Could not load the pending ${cfg.many}. Please try again.`);
                    });
                },

                closeModal() {
                    if (el('bulk-value').hasClass('select2-hidden-accessible')) {
                        el('bulk-value').select2('close');
                    }
                    el('bulk-modal').addClass('hidden').removeClass('flex');
                },

                formatDate(value) {
                    const d = new Date(value + 'T00:00:00');
                    return isNaN(d) ? value : d.toLocaleDateString('en-US', {
                        weekday: 'short',
                        month: 'short',
                        day: 'numeric',
                        year: 'numeric'
                    });
                },

                setMode(mode) {
                    self.mode = mode;
                    el('bulk-modal').find('.bulk-mode').each(function() {
                        const active = $(this).data('bulk-mode') === mode;
                        $(this).toggleClass('bg-white text-gray-900 shadow-sm', active).toggleClass('text-gray-500', !active);
                    });
                    el('bulk-value-wrap').toggleClass('hidden', mode === 'all');
                    if (mode === 'all') {
                        self.updateSummary();
                        return;
                    }
                    el('bulk-value-label').text({ department: 'Department', employee: 'Employee', date: 'Date' }[mode]);

                    const select = el('bulk-value');
                    if (select.hasClass('select2-hidden-accessible')) {
                        select.select2('destroy');
                    }
                    select.empty().append(new Option('', '', true, true));

                    const list = (self.options && self.options[mode + 's']) || [];
                    list.forEach(function(item) {
                        let label = item.value || '(none)';
                        if (mode === 'employee' && item.department) label += ` · ${item.department}`;
                        if (mode === 'date') label = self.formatDate(item.value);
                        const option = new Option(`${label} — ${item.count} pending`, item.value, false, false);
                        $(option).attr('data-count', item.count);
                        select.append(option);
                    });

                    select.select2({
                        dropdownParent: el('bulk-modal'),
                        placeholder: { department: 'Choose a department', employee: 'Choose an employee', date: 'Choose a date' }[mode],
                        width: '100%'
                    });
                    select.off('change.bulk').on('change.bulk', self.updateSummary);
                    self.updateSummary();
                },

                updateSummary() {
                    if (self.mode === 'all') {
                        const total = self.options ? Number(self.options.total || 0) : 0;
                        el('bulk-summary').html(total > 0 ?
                            `This will approve <strong>all ${total}</strong> pending ${total === 1 ? cfg.one : cfg.many}` +
                            (isAdmin ? ' in the loaded import.' : ' in your departments.') :
                            `There are no pending ${cfg.many} to approve.`);
                        el('bulk-by-submit').prop('disabled', total === 0).text(total > 0 ? `Approve all ${total}` : 'Approve');
                        return;
                    }

                    const selected = el('bulk-value').find('option:selected');
                    const count = Number(selected.attr('data-count') || 0);
                    if (!el('bulk-value').val()) {
                        el('bulk-summary').text(el('bulk-value').find('option').length > 1 ?
                            'Pick one to see how many records will be approved.' :
                            `There are no pending ${cfg.many} to approve.`);
                        el('bulk-by-submit').prop('disabled', true).text('Approve');
                        return;
                    }
                    el('bulk-summary').html(`This will approve <strong>${count}</strong> pending ${count === 1 ? cfg.one : cfg.many}.`);
                    el('bulk-by-submit').prop('disabled', false).text(`Approve ${count}`);
                },

                submitBy() {
                    const value = self.mode === 'all' ? '' : el('bulk-value').val();
                    if (self.mode !== 'all' && !value) return;

                    if (self.mode === 'all') {
                        // Approving everything is the one bulk action worth a second look
                        const total = Number(self.options?.total || 0);
                        Swal.fire({
                            title: `Approve all ${records(total)}?`,
                            text: `Every pending ${cfg.one} listed on this tab will be marked as Approved.`,
                            icon: "warning",
                            showCancelButton: true,
                            confirmButtonColor: "#16a34a",
                            cancelButtonColor: "#d33",
                            confirmButtonText: `Yes, approve all ${total}`
                        }).then((result) => {
                            if (result.isConfirmed) self.sendBy(value);
                        });
                        return;
                    }
                    self.sendBy(value);
                },

                sendBy(value) {
                    el('bulk-by-submit').prop('disabled', true).text('Approving…');

                    $.ajax({
                        url: cfg.approveByUrl,
                        type: "POST",
                        data: {
                            by: self.mode,
                            value: value,
                            _token: "{{ csrf_token() }}"
                        },
                        success: function(response) {
                            self.closeModal();
                            Swal.fire({
                                title: response.approved > 0 ? "Approved!" : "Nothing to approve",
                                text: response.message,
                                icon: response.approved > 0 ? "success" : "info",
                                timer: response.skipped > 0 ? undefined : 2500,
                                showConfirmButton: response.skipped > 0
                            });
                            self.afterApprove();
                        },
                        error: function(xhr) {
                            self.showError(xhr);
                            self.updateSummary();
                        }
                    });
                }
            };

            $(document).on('change', rowCheck, function() {
                const id = Number(this.value);
                this.checked ? self.selected.add(id) : self.selected.delete(id);
                self.updateBar();
                self.syncSelectAll();
            });

            $(document).on('change', `#${cfg.prefix}-select-all`, function() {
                const check = this.checked;
                $(rowCheck).each(function() {
                    this.checked = check;
                    const id = Number(this.value);
                    check ? self.selected.add(id) : self.selected.delete(id);
                });
                self.updateBar();
                self.syncSelectAll();
            });

            return self;
        }
    </script>
@endonce

<script>
    window.{{ $instance }} = createBulkApprove(@json($config));
</script>

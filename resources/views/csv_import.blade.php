<x-app-layout>
    <style>
        .upload-area {
            border: 2px dashed #00aaff;
            padding: 40px;
            width: 400px;
            text-align: center;
            background-color: #fff;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        .upload-area.drag-over {
            border-color: #0066cc;
        }

        .upload-area p {
            font-size: 18px;
            color: #333;
        }

        #fileInput {
            display: none;
        }

        .upload-btn {
            display: inline-block;
            background-color: #00aaff;
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }

        .upload-btn:hover {
            background-color: #0066cc;
        }

        .import-btn {
            display: none;
            /* Hidden by default */
            background-color: #28a745;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }

        .import-btn:hover {
            background-color: #218838;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        table,
        th,
        td {
            border: 1px solid #ddd;
            padding: 8px;
        }

        th {
            background-color: #f2f2f2;
            text-align: left;
        }

        #fileName {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.8);
            justify-content: center;
            align-items: center;
        }

        .modal-content {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            max-height: 90%;
            overflow-y: auto;
            width: 90%;
        }

        .modal-close {
            background-color: red;
            color: white;
            padding: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-bottom: 20px;
        }

        .loader {
            width: 48px;
            height: 48px;
            /* border: 5px solid; */
            border-color: #FF3D00 transparent;
            border-radius: 50%;
            display: none;
            /* Hide loader initially */
            box-sizing: border-box;
            animation: rotation 1s linear infinite;
        }

        @keyframes rotation {
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }
    </style>
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

        .loaders {
            position: relative;
            width: 2.5em;
            height: 2.5em;
            transform: rotate(165deg);
            z-index: 9999;
        }

        .loaders:before,
        .loaders:after {
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

        .loaders:before {
            animation: before8 2s infinite;
        }

        .loaders:after {
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

        .loaders {
            position: absolute;
            top: calc(50% - 1.25em);
            left: calc(50% - 1.25em);
        }
    </style>
    {{-- <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Biometric Import') }}
        </h2>
    </x-slot>
    <div class="loader-overlay" id="loaderOverlay">
        <div class="loaders"></div>
    </div> --}}
    {{-- <div class="py-12 flex justify-center drag-csv">
        <div class="max-w-xl w-full bg-white border border-gray-300 rounded-lg shadow-lg p-8">
            <div class="p-6 text-gray-900 flex justify-center">
                <div class="upload-area" id="uploadArea">
                    <p>Drag & Drop your .csv file here</p>
                    <p>or</p>
                    <button class="upload-btn" x-data @click.prevent="$dispatch('open-modal', 'biometric-info')">Browse
                        Files</button>
                    <input type="file" id="fileInput" accept=".csv" onchange="handleFiles(this.files)">
                </div>
            </div>
        </div>
    </div> --}}
    <div class="loader-overlay" id="loaderOverlay">
        <div class="loaders"></div>
    </div>

    <x-approval-table-assets />

    <div class="px-2 lg:px-4">
        <!-- Page header + toolbar -->
        <div class="flex flex-wrap items-center justify-between gap-3 px-4 pt-4 pb-3">
            <h1 class="text-xl font-semibold text-gray-900">{{ __('Biometric Data Import') }}</h1>
            <div class="flex flex-wrap items-center gap-2">
                <button type="button" x-data @click.prevent="$dispatch('open-modal', 'biometric-info')"
                    class="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium text-white bg-green-600 rounded-md hover:bg-green-700 shadow-sm">
                    <i class="fa-solid fa-file-import"></i>
                    Import Now
                </button>
                <div class="relative">
                    <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-xs"></i>
                    <input id="imports-search" type="search" placeholder="Search"
                        class="w-48 pl-8 pr-3 py-1.5 text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500">
                </div>
                <div id="imports-toolbar-buttons" class="flex items-center gap-2"></div>
            </div>
        </div>

        <!-- Table card -->
        <div class="px-4 pb-4">
            <div class="bg-white rounded-lg border border-gray-200 shadow-sm">
                <div class="p-2 text-gray-900">
                    <div class="border border-gray-200 rounded-md overflow-hidden">
                        <div class="overflow-x-auto">
                            <table id="imports-table" class="modern-table w-full text-sm">
                                <thead>
                                    <tr>
                                        <th class="noVis" style="width: 2rem;"></th>
                                        <th>Title</th>
                                        <th>Status</th>
                                        <th>Payroll Period</th>
                                        <th>Records</th>
                                        <th>Imported By</th>
                                        <th>Imported At</th>
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

        <!-- Edit import modal -->
        <div id="editImportModal" class="hidden fixed inset-0 z-50 items-center justify-center bg-black/50 px-4">
            <div class="w-full max-w-md bg-white rounded-lg shadow-xl">
                <div class="flex items-center justify-between px-5 py-3 border-b border-gray-200">
                    <h3 class="text-sm font-semibold text-gray-900"><i class="fa-solid fa-pen text-green-600 mr-1"></i> Edit import</h3>
                    <button type="button" onclick="closeImportModal('#editImportModal')" class="text-gray-400 hover:text-gray-700 text-xl">&times;</button>
                </div>
                <div class="px-5 py-4 space-y-3 text-sm">
                    <input type="hidden" id="edit-import-id">
                    <label class="block">
                        <span class="block text-gray-700 mb-1">Title</span>
                        <input type="text" id="edit-import-title" maxlength="100" class="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-green-500">
                    </label>
                    <div class="grid grid-cols-2 gap-3">
                        <label class="block">
                            <span class="block text-gray-700 mb-1">Payroll from</span>
                            <input type="date" id="edit-import-start" class="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-green-500">
                        </label>
                        <label class="block">
                            <span class="block text-gray-700 mb-1">Payroll to</span>
                            <input type="date" id="edit-import-end" class="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-green-500">
                        </label>
                    </div>
                    <p class="text-xs text-gray-500">Imported by, imported at and the attendance data itself can't be edited.</p>
                </div>
                <div class="flex justify-end gap-2 px-5 py-3 border-t border-gray-200 bg-gray-50 rounded-b-lg">
                    <button type="button" onclick="closeImportModal('#editImportModal')" class="px-4 py-2 text-sm text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-100">Cancel</button>
                    <button type="button" onclick="saveImportEdit()" class="px-4 py-2 text-sm text-white bg-green-600 rounded-md hover:bg-green-700">Save</button>
                </div>
            </div>
        </div>

        <!-- Delete import modal -->
        <div id="deleteImportModal" class="hidden fixed inset-0 z-50 items-center justify-center bg-black/50 px-4">
            <div class="w-full max-w-md bg-white rounded-lg shadow-xl">
                <div class="flex items-center justify-between px-5 py-3 border-b border-gray-200">
                    <h3 class="text-sm font-semibold text-red-700"><i class="fa-solid fa-trash mr-1"></i> Delete import</h3>
                    <button type="button" onclick="closeImportModal('#deleteImportModal')" class="text-gray-400 hover:text-gray-700 text-xl">&times;</button>
                </div>
                <div id="delete-import-body" class="px-5 py-4 space-y-3 text-sm"></div>
                <div class="flex justify-end gap-2 px-5 py-3 border-t border-gray-200 bg-gray-50 rounded-b-lg">
                    <button type="button" onclick="closeImportModal('#deleteImportModal')" class="px-4 py-2 text-sm text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-100">Cancel</button>
                    <button type="button" id="delete-import-confirm" onclick="confirmImportDelete()" disabled
                        class="px-4 py-2 text-sm text-white bg-red-600 rounded-md hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed">Delete import and its data</button>
                </div>
            </div>
        </div>
    </div>

    {{-- <div class="flex justify-center csv-output mt-5">
        <div class="max-w-7xl w-full bg-white border border-gray-300 rounded-lg shadow-lg p-8">
            <div id="fileName"></div>
            <button id="importBtn" class="import-btn" onclick="uploadCSV()">Import Now</button>
            <button x-data @click.prevent="$dispatch('open-modal', 'set-ot')" id="setOtBtn"
                class="bg-yellow-500 hover:bg-yellow-600 text-white py-2 px-4 rounded-lg text-lg" onclick="setOt()"
                style="display:none;">Set Overtime</button>
            <button id="setBackBtn" class="bg-blue-500 hover:bg-blue-600 text-white py-2 px-4 rounded-lg text-lg"
                onclick="backFunction()"style="display:none;"><i class="fa-solid fa-arrow-left"></i></button>
            <div class="overflow-auto max-w-full">
                <div id="csvOutput"></div>
            </div>
            <div class="detailsLoader">
                <div class="shadow rounded-md p-4 m-10 w-full mx-auto">
                    <div class="animate-pulse flex space-x-4">
                        <div class="flex-1 space-y-6 py-1">
                            <div class="h-2 bg-slate-500 rounded"></div>
                            <div class="space-y-3">
                                <div class="grid grid-cols-3 gap-4">
                                    <div class="h-2 bg-slate-500 rounded col-span"></div>
                                    <div class="h-2 bg-slate-500 rounded col-span"></div>
                                    <div class="h-2 bg-slate-500 rounded col-span"></div>
                                    <div class="h-2 bg-slate-500 rounded col-span"></div>
                                    <div class="h-2 bg-slate-500 rounded col-span"></div>
                                    <div class="h-2 bg-slate-500 rounded col-span"></div>
                                    <div class="h-2 bg-slate-500 rounded col-span"></div>
                                    <div class="h-2 bg-slate-500 rounded col-span"></div>
                                    <div class="h-2 bg-slate-500 rounded col-span"></div>
                                    <div class="h-2 bg-slate-500 rounded col-span"></div>
                                </div>
                                <div class="h-2 bg-slate-500 rounded"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="csvModal" class="modal">
                <div class="modal-content">
                    <button class="modal-close" onclick="closeModal()">Close</button>
                    <div id="fullCsvTable"></div>
                </div>
            </div>
        </div>
    </div> --}}
    <x-modal name="biometric-info" focusable>
        <div class="flex items-center justify-center min-h-[60vh]">
            <div class="p-6 bg-white rounded-2xl shadow-2xl w-full max-w-md mx-auto border border-gray-200">
                <!-- Header -->
                <div class="text-center mb-5">
                    <h2 class="text-xl font-semibold text-gray-800 mb-1">Import Biometric File</h2>
                    <p class="text-sm text-gray-500">Provide a title and upload your biometric CSV file.</p>
                </div>

                <!-- Form -->
                <form id="biometricImportForm" enctype="multipart/form-data">
                    <div class="space-y-4">
                        <!-- Imported By -->
                        <div>
                            <label for="imported-by" class="block text-sm font-medium text-gray-700 mb-1">
                                Import By
                            </label>
                            <input id="imported-by" name="imported-by" type="text"
                                class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500"
                                readonly>
                        </div>

                        <!-- Title -->
                        <div>
                            <label for="title" class="block text-sm font-medium text-gray-700 mb-1">
                                Import Title
                            </label>
                            <input id="title" name="title" type="text"
                                placeholder="e.g., Biometric data for 8/26/2025 - 9/10/2025"
                                class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500"
                                required>
                        </div>

                        <!-- Payroll Period -->
                        <div class="grid grid-cols-2 gap-3">
                            <div>
                                <label for="period-start" class="block text-sm font-medium text-gray-700 mb-1">
                                    Payroll Period Start
                                </label>
                                <input id="period-start" name="period_start" type="date"
                                    class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500">
                            </div>
                            <div>
                                <label for="period-end" class="block text-sm font-medium text-gray-700 mb-1">
                                    Payroll Period End
                                </label>
                                <input id="period-end" name="period_end" type="date"
                                    class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500">
                            </div>
                            <p class="col-span-2 text-xs text-gray-500">
                                Defaults to the first and last punch date in the file. Manual attendance entries must fall inside this period.
                            </p>
                        </div>

                        <!-- File Upload -->
                        <div>
                            <label for="biometricFile" class="block text-sm font-medium text-gray-700 mb-1">
                                Select Biometric CSV File
                            </label>
                            <input type="file" accept=".csv" onchange="handleFiles(this.files)"
                                class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500"
                                required>
                        </div>

                        <!-- Total Rows -->
                        <div>
                            <label for="total-rows" class="block text-sm font-medium text-gray-700 mb-1">
                                Total Rows
                            </label>
                            <input id="total-rows" name="total-rows" type="text"
                                class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500"
                                readonly>
                        </div>
                    </div>

                    <!-- Modal Actions -->
                    <div class="flex justify-end space-x-3 mt-6 pt-4 border-t border-gray-200">
                        <button type="button" x-on:click="$dispatch('close')"
                            class="px-4 py-2 text-sm text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-400 transition">
                            Cancel
                        </button>
                        <button type="button" onclick="uploadCSV()"
                            class="px-4 py-2 text-sm text-white bg-gradient-to-r from-green-600 to-green-700 rounded-lg hover:from-green-700 hover:to-green-800 focus:outline-none focus:ring-2 focus:ring-green-500 transition">
                            Import Now
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </x-modal>

    <script>
        const csrfToken = '{{ csrf_token() }}';
        const userEmail = "{{ Auth::user()->email ?? '' }}";
        /** -----------------------------
         *  INITIALIZATION
         * ------------------------------*/
        $('#title').val(generateBiometricTitle());
        $('#imported-by').val(userEmail);
        $('.detailsLoader, .csv-output, #loaderOverlay').hide();

        loadImportedCsvList();

        /** -----------------------------
         *  LOAD IMPORT HISTORY
         * ------------------------------*/
        const importRoutes = {
            update: "{{ route('biometric-history-list.update', ['id' => '__ID__']) }}",
            preview: "{{ route('biometric-history-list.delete-preview', ['id' => '__ID__']) }}",
            destroy: "{{ route('biometric-history-list.destroy', ['id' => '__ID__']) }}",
        };
        let importsById = {};
        let deletingImport = null;

        const escapeHtml = (value) => $('<div>').text(value ?? '').html();
        const importPill = (classes, text) => `<span class="px-1.5 py-0.5 text-[11px] font-semibold rounded-full whitespace-nowrap ${classes}">${escapeHtml(text)}</span>`;
        const dateOnly = (value) => value ? String(value).substring(0, 10) : '';

        function formatPeriod(start, end) {
            if (!start || !end) return '<span class="text-gray-400">Not set</span>';
            const fmt = (d, withYear) => new Date(dateOnly(d) + 'T00:00:00')
                .toLocaleDateString('en-US', withYear ? { month: 'short', day: 'numeric', year: 'numeric' } : { month: 'short', day: 'numeric' });
            return `${fmt(start, false)} – ${fmt(end, true)}`;
        }

        bindTableSearch('#imports-search', '#imports-table');

        function loadImportedCsvList() {
            $.ajax({
                url: "{{ route('biometric-history-list.fetch') }}",
                type: 'GET',
                success: function(response) {
                    const rows = Array.isArray(response) ? response : [];
                    importsById = Object.fromEntries(rows.map(r => [r.id, r]));

                    const table = renderClientTable('#imports-table', {
                        data: rows,
                        reload: loadImportedCsvList,
                        toolbar: '#imports-toolbar-buttons',
                        search: '#imports-search',
                        emptyText: 'No biometric data imports yet. Use Import Now to add one.',
                        order: [[6, 'desc']],
                        columns: [
                            {
                                data: 'title',
                                orderable: true,
                                className: 'all font-medium text-gray-900',
                                render: $.fn.dataTable.render.text()
                            },
                            {
                                data: 'status',
                                render: (data, type) => {
                                    const loaded = data === 'load';
                                    if (type !== 'display') return loaded ? 'Loaded' : 'Unloaded';
                                    return loaded
                                        ? importPill('bg-green-100 text-green-800', 'Loaded')
                                        : importPill('bg-gray-100 text-gray-600', 'Unloaded');
                                }
                            },
                            {
                                data: 'period_start',
                                orderable: true,
                                defaultContent: '',
                                render: (data, type, row) => type === 'display' ? formatPeriod(row.period_start, row.period_end) : dateOnly(data)
                            },
                            {
                                data: 'attendance_count',
                                render: (data, type, row) => {
                                    if (type !== 'display') return data;
                                    const approved = row.approved_ot_count
                                        ? ` <span class="text-green-700">(${row.approved_ot_count} approved)</span>` : '';
                                    return `${Number(data).toLocaleString()} attendance · ${Number(row.overtime_count).toLocaleString()} OT${approved}`;
                                }
                            },
                            { data: 'imported_by', defaultContent: '', render: $.fn.dataTable.render.text() },
                            {
                                data: (row) => row.imported_at || row.created_at, // older imports have no imported_at
                                orderable: true,
                                render: (data, type) => type === 'display' && data
                                    ? new Date(data).toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' })
                                    : data
                            },
                            {
                                data: null,
                                orderable: false,
                                searchable: false,
                                className: 'noVis all text-center',
                                render: (data, type, row) => {
                                    const loaded = row.status === 'load';
                                    return `<div class="flex items-center justify-center gap-1.5">
                                        <button type="button" title="${loaded ? 'Unload' : 'Load'}" class="row-btn ${loaded ? 'restore' : 'approve'}" onclick="toggleImport(${row.id})">
                                            <i class="fa-solid ${loaded ? 'fa-upload' : 'fa-download'}"></i></button>
                                        <button type="button" title="Edit" class="row-btn edit" onclick="openImportEdit(${row.id})"><i class="fas fa-pen"></i></button>
                                        <button type="button" title="Delete" class="row-btn cancel" onclick="openImportDelete(${row.id})"><i class="fas fa-trash"></i></button>
                                    </div>`;
                                }
                            }
                        ]
                    });
                    // Highlight the loaded import
                    table.rows().every(function() {
                        $(this.node()).toggleClass('bg-green-50/60', this.data().status === 'load');
                    });
                },
                error: function(xhr, status, error) {
                    console.error('Error fetching biometric history:', error);
                }
            });
        }

        function openImportModal(selector) {
            $(selector).removeClass('hidden').addClass('flex');
        }

        function closeImportModal(selector) {
            $(selector).addClass('hidden').removeClass('flex');
        }

        function showAjaxError(xhr, title) {
            const errors = xhr.responseJSON?.errors;
            const text = errors ? Object.values(errors).flat().join('\n') : (xhr.responseJSON?.message || 'Please try again.');
            Swal.fire({ icon: 'error', title: title, text: text });
        }

        // ---- Load / Unload
        function toggleImport(id) {
            const item = importsById[id];
            if (!item) return;
            const loading = item.status !== 'load';
            Swal.fire({
                title: loading ? `Load "${escapeHtml(item.title)}"?` : `Unload "${escapeHtml(item.title)}"?`,
                text: loading ? 'It becomes the active import; any other loaded import is unloaded.' : 'No import will be active until another one is loaded.',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#16a34a',
                confirmButtonText: loading ? 'Load' : 'Unload'
            }).then((result) => {
                if (!result.isConfirmed) return;
                $.ajax({
                    url: "{{ route('biometric-history-list.toggle-status') }}",
                    type: 'POST',
                    data: { id: id, _token: csrfToken },
                    success: function(response) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Status updated',
                            text: `"${response.data.title}" is now ${response.data.status === 'load' ? 'loaded' : 'unloaded'}.`,
                            timer: 1500,
                            showConfirmButton: false
                        }).then(() => location.reload()); // other parts of the app read the loaded import
                    },
                    error: (xhr) => showAjaxError(xhr, 'Unable to update status')
                });
            });
        }

        // ---- Edit
        function openImportEdit(id) {
            const item = importsById[id];
            if (!item) return;
            $('#edit-import-id').val(item.id);
            $('#edit-import-title').val(item.title || '');
            $('#edit-import-start').val(dateOnly(item.period_start));
            $('#edit-import-end').val(dateOnly(item.period_end));
            openImportModal('#editImportModal');
        }

        function saveImportEdit() {
            const id = $('#edit-import-id').val();
            $.ajax({
                url: importRoutes.update.replace('__ID__', id),
                type: 'POST',
                data: {
                    _token: csrfToken,
                    _method: 'PUT',
                    title: $('#edit-import-title').val().trim(),
                    period_start: $('#edit-import-start').val(),
                    period_end: $('#edit-import-end').val(),
                },
                success: function(response) {
                    closeImportModal('#editImportModal');
                    Swal.fire({ icon: 'success', title: response.message, timer: 1200, showConfirmButton: false });
                    loadImportedCsvList();
                },
                error: (xhr) => showAjaxError(xhr, 'Could not save')
            });
        }

        // ---- Delete (with all related data)
        const TABLE_LABELS = {
            attendance_records: 'Attendance records',
            overtimes: 'Overtime records',
            leaves: 'Leaves',
            certificate_attendance: 'Certificates of attendance',
            schedule_adjustments: 'Schedule adjustments',
            security_attendance: 'Security attendance',
            dtr_report: 'DTR rows',
            csvimports: 'Payroll rows',
        };

        function openImportDelete(id) {
            const item = importsById[id];
            if (!item) return;
            deletingImport = item;
            $('#delete-import-confirm').prop('disabled', true);
            $('#delete-import-body').html('<p class="text-gray-500">Checking what will be deleted…</p>');
            openImportModal('#deleteImportModal');

            $.getJSON(importRoutes.preview.replace('__ID__', id), function(r) {
                const listOf = (counts) => Object.entries(TABLE_LABELS)
                    .map(([table, label]) => ({ label, count: (counts || {})[table] || 0 }))
                    .filter(x => x.count > 0)
                    .map(x => `<li class="flex justify-between"><span>${x.label}</span><span class="font-semibold">${x.count.toLocaleString()}</span></li>`)
                    .join('');
                const section = (heading, items) => items
                    ? `<p class="text-xs font-semibold text-gray-700">${heading}</p><ul class="text-xs space-y-1 border border-gray-200 rounded p-2 bg-gray-50">${items}</ul>`
                    : '';
                const lines = listOf(r.deleted);
                const movedLines = (r.moved || [])
                    .map(m => `<li class="flex justify-between"><span>To <strong>${escapeHtml(m.title)}</strong></span><span class="font-semibold">${Number(m.total).toLocaleString()}</span></li>`)
                    .join('');
                const keptLines = listOf(r.kept);
                const loadedNote = r.is_loaded
                    ? `<p class="text-xs text-amber-800 bg-amber-50 border border-amber-200 rounded px-2 py-1">This is the loaded import. ${r.next_loaded ? `<strong>${escapeHtml(r.next_loaded.title)}</strong> will be loaded instead.` : 'No other import exists, so nothing will be loaded.'}</p>`
                    : '';
                const approvedNote = r.approved_overtime
                    ? `<p class="text-xs text-red-800 bg-red-50 border border-red-200 rounded px-2 py-1"><i class="fa-solid fa-triangle-exclamation mr-1"></i>${r.approved_overtime} <strong>approved</strong> overtime ${r.approved_overtime === 1 ? 'record' : 'records'} will be deleted.</p>`
                    : '';

                $('#delete-import-body').html(`
                    <p>This permanently deletes <strong>${escapeHtml(item.title)}</strong> and the days no other import's payroll period covers.</p>
                    ${section('Deleted', lines) || '<p class="text-xs text-gray-500">No records will be deleted.</p>'}
                    ${section('Moved to imports whose payroll period covers those days', movedLines)}
                    ${section('Kept, no longer tied to an import', keptLines)}
                    ${approvedNote}
                    ${loadedNote}
                    <label class="block">
                        <span class="block text-xs text-gray-700 mb-1">Type the import title to confirm:</span>
                        <input type="text" id="delete-import-typed" autocomplete="off" class="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:ring-2 focus:ring-red-500" placeholder="${escapeHtml(item.title)}">
                    </label>
                `);
                $('#delete-import-typed').on('input', function() {
                    $('#delete-import-confirm').prop('disabled', this.value.trim() !== String(item.title).trim());
                }).trigger('focus');
            }).fail((xhr) => {
                closeImportModal('#deleteImportModal');
                showAjaxError(xhr, 'Could not check this import');
            });
        }

        function confirmImportDelete() {
            if (!deletingImport) return;
            $('#delete-import-confirm').prop('disabled', true).text('Deleting…');
            $.ajax({
                url: importRoutes.destroy.replace('__ID__', deletingImport.id),
                type: 'POST',
                data: { _token: csrfToken, _method: 'DELETE', confirm_title: $('#delete-import-typed').val() },
                success: function(r) {
                    closeImportModal('#deleteImportModal');
                    Swal.fire({
                        icon: 'success',
                        title: 'Import deleted',
                        html: `${Number(r.total).toLocaleString()} related records were deleted.` +
                            (r.moved_total ? `<br>${Number(r.moved_total).toLocaleString()} records were moved to other imports.` : '') +
                            (r.now_loaded ? `<br><strong>${escapeHtml(r.now_loaded.title)}</strong> is now loaded.` : ''),
                    }).then(() => location.reload());
                },
                error: (xhr) => showAjaxError(xhr, 'Could not delete'),
                complete: () => $('#delete-import-confirm').text('Delete import and its data')
                    .prop('disabled', ($('#delete-import-typed').val() || '').trim() !== String(deletingImport?.title).trim())
            });
        }

        /** -----------------------------
         *  GENERATE BIOMETRIC TITLE
         * ------------------------------*/
        function generateBiometricTitle() {
            const today = new Date();
            const day = today.getDate();
            const month = today.getMonth() + 1;
            const year = today.getFullYear();

            let startDate, endDate;

            if (day >= 26 || day <= 10) {
                if (day >= 26) {
                    const nextMonth = month === 12 ? 1 : month + 1;
                    const nextYear = month === 12 ? year + 1 : year;
                    startDate = `${month}/26/${year}`;
                    endDate = `${nextMonth}/10/${nextYear}`;
                } else {
                    const prevMonth = month === 1 ? 12 : month - 1;
                    const prevYear = month === 1 ? year - 1 : year;
                    startDate = `${prevMonth}/26/${prevYear}`;
                    endDate = `${month}/10/${year}`;
                }
            } else {
                startDate = `${month}/11/${year}`;
                endDate = `${month}/25/${year}`;
            }

            return `Biometric data for ${startDate} - ${endDate}`;
        }

        /** -----------------------------
         *  FILE UPLOAD HANDLER
         * ------------------------------*/
        const $uploadArea = $('#uploadArea');
        let csvDataGlobal = '';
        const MAX_UPLOAD_MB = 20;

        window.handleFiles = function(files) {
            $('.csv-output').show();
            $('.drag-csv').hide();

            if (!files.length) return;

            const file = files[0];
            const fileExtension = file.name.split('.').pop().toLowerCase();
            const allowedExtensions = ['csv', 'xls', 'xlsx'];

            if (!allowedExtensions.includes(fileExtension)) {
                Swal.fire('Invalid file!', 'Please upload a valid .csv, .xls, or .xlsx file.',
                    'warning');
                return;
            }

            // Same limit as PHP (docker/php/uploads.ini); the proxy refuses bigger bodies with a 413
            if (file.size > MAX_UPLOAD_MB * 1024 * 1024) {
                Swal.fire('File too large',
                    `The file is ${(file.size / 1024 / 1024).toFixed(1)} MB; the maximum is ${MAX_UPLOAD_MB} MB.`, 'warning');
                return;
            }

            currentBiometricImportId = null; // set again once this upload succeeds
            $('.detailsLoader, #loaderOverlay').show();

            const formData = new FormData();
            formData.append('file', file);

            $.ajax({
                url: "{{ route('upload.csv') }}",
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': csrfToken
                },
                data: formData,
                processData: false,
                contentType: false,
                success: result => handleUploadSuccess(result, file),
                error: handleAjaxError
            });
        };

        let currentBiometricImportId = null;

        function handleUploadSuccess(result, file) {
            $('.detailsLoader, #loaderOverlay').hide();
            console.log("Upload Result:", result);

            currentBiometricImportId = result.biometric_imports_id ?? null;
            if (result.period_start) $('#period-start').val(result.period_start.substring(0, 10));
            if (result.period_end) $('#period-end').val(result.period_end.substring(0, 10));

            if (file.name.endsWith('.csv') && result.csvData) {
                csvDataGlobal = result.csvData;
                const totalRows = calculateTotalRows(result.csvData);
                $('#total-rows').val(totalRows);
                console.log("Total rows:", totalRows);
            } else {
                Swal.fire('Upload complete', 'Preview is only available for CSV files.', 'info');
            }
        }

        function calculateTotalRows(data) {
            if (Array.isArray(data)) {
                return data.length - 1;
            } else if (typeof data === 'string') {
                const rows = data.trim().split(/\r?\n/);
                return rows.length - 2;
            }
            return 0;
        }

        /** -----------------------------
         *  UPLOAD / IMPORT LOGIC
         * ------------------------------*/
        window.uploadCSV = function() {
            // The upload creates the import and its attendance; without it there is nothing to import
            if (!currentBiometricImportId) {
                Swal.fire('Upload the file first',
                    'Upload the biometric file first; the last upload did not finish.', 'warning');
                return;
            }
            $.ajax({
                url: "{{ route('upload.exist') }}",
                type: 'POST',
                headers: {
                    'X-CSRF-TOKEN': csrfToken
                },
                data: {
                    title: $('#title').val() // 👈 send the title input value to controller
                },
                success: result => {
                    console.log("Exist Check:", result.exists);
                    $("#custom-holiday-records, #overtime-records").empty();

                    if (result.exists) {
                        Swal.fire({
                            title: "Are you sure?",
                            text: "This will overwrite existing data!",
                            icon: "warning",
                            showCancelButton: true,
                            confirmButtonColor: "#3085d6",
                            cancelButtonColor: "#d33",
                            confirmButtonText: "Overwrite it!"
                        }).then(res => {
                            // Reload the page after the alert closes
                            location.reload();
                            if (res.isConfirmed) importCsvData();
                        });
                    } else {
                        importCsvData();
                    }
                },
                error: handleAjaxError
            });
        };

        function importCsvData() {
            let userEmail = $('#userEmail').val();
            let imported_by = $('#imported-by').val();
            let title = $('#title').val();
            let total_rows = $('#total-rows').val();
            $.ajax({
                url: "{{ route('biometric-history-list.store') }}",
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': csrfToken
                },
                data: {
                    id: currentBiometricImportId,
                    title: title,
                    imported_by: imported_by,
                    total_rows: total_rows,
                    period_start: $('#period-start').val(),
                    period_end: $('#period-end').val()
                },
                success: function() {
                    // Payroll rows (csvimports) are loaded by Report Generation after it writes the
                    // payroll file; loading here picked up a stale file or failed with "File not found."
                    Swal.fire({
                        icon: "success",
                        title: "CSV imported successfully!",
                        showConfirmButton: false,
                        timer: 1500,
                        width: "400px"
                    });
                },
                error: handleAjaxError
            });

        }

        /** -----------------------------
         *  FORM VALIDATION HELPERS
         * ------------------------------*/
        window.formValidation = function(...fields) {
            let isValid = true;

            fields.forEach(id => {
                const $input = $('#' + id);
                const $error = $('#' + id + 'Error');

                if ($input.val().trim() === '') {
                    markInvalid($input, $error);
                    isValid = false;
                } else {
                    markValid($input, $error);
                }
            });

            return isValid;
        };

        function markInvalid($input, $error) {
            $input.addClass('border-red-500').removeClass('border-green-500');
            $error.removeClass('hidden');
        }

        function markValid($input, $error) {
            $input.addClass('border-green-500').removeClass('border-red-500');
            $error.addClass('hidden');
        }

        /** -----------------------------
         *  UTILITY FUNCTIONS
         * ------------------------------*/
        function handleAjaxError(xhr, status, error) {
            $('.detailsLoader, #loaderOverlay').hide();
            console.error('AJAX Error:', error);
            let message = xhr.responseJSON?.message;
            if (xhr.status === 413) {
                message = `The file is too large for the server (max ${MAX_UPLOAD_MB} MB).`;
            } else if (!message) {
                message = 'Something went wrong' + (xhr.status ? ` (HTTP ${xhr.status})` : '') + '. Please try again.';
            }
            Swal.fire('Error', message, 'error');
        }

        window.closeModal = () => $('#csvModal').hide();
    </script>
</x-app-layout>

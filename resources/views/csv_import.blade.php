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

    <div class="px-16 py-8">
        <div class="flex items-center justify-between mb-6">
            <h2 class="text-3xl font-bold text-gray-800 flex items-center">
                <i class="fa-solid fa-file-import text-green-500 mr-3"></i>
                Imported CSV Files
            </h2>
            <button x-data @click.prevent="$dispatch('open-modal', 'biometric-info')"
                class="flex items-center px-4 py-2 bg-gradient-to-r from-green-600 to-green-700 text-white font-semibold rounded-lg shadow-sm hover:from-green-700 hover:to-green-800 transition-all duration-200">
                <i class="fa-solid fa-file-import mr-2"></i> Import Now
            </button>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 imported-csv-list" id="importedCsvList"></div>

        {{-- <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 imported-csv-list">
            <!-- File Card 1 -->
            <div
                class="bg-white shadow-md rounded-xl border border-gray-200 p-5 hover:shadow-lg transition-all duration-200">
                <div class="flex items-start justify-between mb-3">
                    <h3 class="font-bold text-lg text-gray-900">Daily Attendance - Oct 10, 2025</h3>
                    <span class="bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-semibold">
                        Completed
                    </span>
                </div>

                <div class="text-sm text-gray-700 space-y-1">
                    <p><strong>Imported By:</strong> Crescian Lanoy</p>
                    <p><strong>Imported At:</strong> 2025-10-10 08:42 AM</p>
                    <p><strong>Total Rows:</strong> 8,000</p>
                    <p><strong>Created:</strong> 2025-10-10</p>
                    <p><strong>Updated:</strong> 2025-10-10</p>
                </div>

                <div class="mt-4 flex justify-end">
                    <button onclick="loadFile(2)"
                        class="inline-flex items-center px-4 py-2 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-lg text-sm font-semibold hover:scale-105 transform transition">
                        <i class="fa-solid fa-download mr-2 text-xs"></i> Load
                    </button>
                </div>
            </div>

            <!-- File Card 2 -->
            <div
                class="bg-white shadow-md rounded-xl border border-gray-200 p-5 hover:shadow-lg transition-all duration-200">
                <div class="flex items-start justify-between mb-3">
                    <h3 class="font-bold text-lg text-gray-900">Daily Attendance - Oct 09, 2025</h3>
                    <span class="bg-yellow-100 text-yellow-700 px-3 py-1 rounded-full text-xs font-semibold">
                        Processing
                    </span>
                </div>

                <div class="text-sm text-gray-700 space-y-1">
                    <p><strong>Imported By:</strong> Admin</p>
                    <p><strong>Imported At:</strong> 2025-10-09 07:58 AM</p>
                    <p><strong>Total Rows:</strong> 7,550</p>
                    <p><strong>Created:</strong> 2025-10-09</p>
                    <p><strong>Updated:</strong> 2025-10-09</p>
                </div>

                <div class="mt-4 flex justify-end">
                    <button onclick="unloadFile(1)"
                        class="inline-flex items-center px-4 py-2 bg-gradient-to-r from-red-600 to-red-700 text-white rounded-lg text-sm font-semibold hover:scale-105 transform transition">
                        <i class="fa-solid fa-upload mr-2 text-xs"></i> Unload
                    </button>
                </div>
            </div>
        </div> --}}
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
        function loadImportedCsvList() {
            $.ajax({
                url: "{{ route('biometric-history-list.fetch') }}",
                type: 'GET',
                headers: {
                    'X-CSRF-TOKEN': csrfToken
                },
                success: function(response) {
                    let container = $('#importedCsvList');
                    container.empty(); // Clear old cards

                    if (response.length === 0) {
                        container.append(`
                    <div class="col-span-full text-center text-gray-500 py-10">
                        <i class="fa-solid fa-folder-open text-4xl mb-2"></i>
                        <p>No biometric data imports found.</p>
                    </div>
                `);
                        return;
                    }

                    $.each(response, function(index, item) {
                        let statusColor = '';
                        let statusBg = '';
                        let buttonLabel = '';
                        let buttonColor = '';
                        let buttonIcon = '';
                        console.log("Item Status:", item.status);
                        if (item.status == 'load') {
                            statusColor = 'text-green-700';
                            statusBg = 'bg-green-100';
                            buttonLabel = 'Unload';
                            buttonColor = 'bg-gradient-to-r from-red-600 to-red-700';
                            buttonIcon = 'fa-upload';
                        } else if (item.status == 'unload') {
                            statusColor = 'text-yellow-700';
                            statusBg = 'bg-yellow-100';
                            buttonLabel = 'Load';
                            buttonColor = 'bg-gradient-to-r from-green-600 to-green-700';
                            buttonIcon = 'fa-download';
                        } else {
                            statusColor = 'text-gray-700';
                            statusBg = 'bg-gray-100';
                            buttonLabel = 'Pending';
                            buttonColor = 'bg-gradient-to-r from-gray-400 to-gray-500';
                            buttonIcon = 'fa-clock';
                        }

                        container.append(`
                    <div class="bg-white shadow-md rounded-xl border border-gray-200 p-5 hover:shadow-lg transition-all duration-200">
                        <div class="flex items-start justify-between mb-3">
                            <h3 class="font-bold text-lg text-gray-900">${item.title}</h3>
                            <span class="${statusBg} ${statusColor} px-3 py-1 rounded-full text-xs font-semibold capitalize">
                                ${item.status}
                            </span>
                        </div>

                        <div class="text-sm text-gray-700 space-y-1">
                            <p><strong>Imported By:</strong> ${item.imported_by}</p>
                            <p><strong>Imported At:</strong> ${item.imported_at}</p>
                            <p><strong>Total Rows:</strong> ${item.total_rows}</p>
                            <p><strong>Created:</strong> ${new Date(item.created_at).toLocaleDateString()}</p>
                            <p><strong>Updated:</strong> ${new Date(item.updated_at).toLocaleDateString()}</p>
                        </div>

                        <div class="mt-4 flex justify-end">
                            <button data-id="${item.id}" data-status="${item.status}"
                                class="inline-flex items-center px-4 py-2 ${buttonColor} text-white rounded-lg text-sm font-semibold hover:scale-105 transform transition file-action-btn">
                                <i class="fa-solid ${buttonIcon} mr-2 text-xs"></i> ${buttonLabel}
                            </button>
                        </div>
                    </div>
                `);
                    });
                },
                error: function(xhr, status, error) {
                    console.error('Error fetching biometric history:', error);
                }
            });
            // Delegate event to dynamically created buttons
            $(document).on('click', '.file-action-btn', function() {
                const id = $(this).data('id');
                const status = $(this).data('status');
                handleFileAction(id);
            });
            // Example placeholder action
            function handleFileAction(id) {
                console.log("Toggling status for ID:", id);
                $.ajax({
                    url: "{{ route('biometric-history-list.toggle-status') }}",
                    type: "POST",
                    data: {
                        id: id,
                        _token: "{{ csrf_token() }}"
                    },
                    success: function(response) {
                        console.log("Status toggled:", response);
                        Swal.fire({
                            icon: 'success',
                            title: 'Status Updated',
                            text: `File "${response.data.title}" is now "${response.data.status.toUpperCase()}"`,
                            timer: 1500,
                            showConfirmButton: false
                        }).then(() => {
                            // Reload the page after the alert closes
                            location.reload();
                        });

                        // Reload list after change
                        loadImportedCsvList();
                    },
                    error: function(xhr) {
                        console.error("Error:", xhr.responseText);
                        Swal.fire({
                            icon: 'error',
                            title: 'Failed!',
                            text: 'Unable to update status.',
                        });
                    }
                });
            }

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

        function handleUploadSuccess(result, file) {
            $('.detailsLoader, #loaderOverlay').hide();
            console.log("Upload Result:", result);

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
                    title: title,
                    imported_by: imported_by,
                    total_rows: total_rows
                },
                success: function(response) {
                    $.ajax({
                        url: "{{ route('import.csv') }}",
                        type: 'POST',
                        headers: {
                            'X-CSRF-TOKEN': csrfToken
                        },
                        data: {
                            biometric_imports_id: response.id,
                        },
                        success: () => {
                            Swal.fire({
                                icon: "success",
                                title: "CSV imported successfully!",
                                showConfirmButton: false,
                                timer: 1500,
                                width: "400px"
                            }).then(() => {
                                // Reload the page after the alert closes
                                // location.reload();
                            });
                        },
                        error: handleAjaxError
                    });
                    console.log(response.id);
                }
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
            Swal.fire('Error', 'Something went wrong. Please try again.', 'error');
        }

        window.closeModal = () => $('#csvModal').hide();
    </script>
</x-app-layout>

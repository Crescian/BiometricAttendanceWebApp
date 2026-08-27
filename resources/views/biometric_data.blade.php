<x-app-layout>
    <style>
        .loader-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999;
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
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Biometric Data Import') }}
        </h2>
    </x-slot>

    <div class="loader-overlay" id="loaderOverlay">
        <div class="loader"></div>
    </div>

    <div class="py-12">
        <div class="max-w-3xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white shadow-sm sm:rounded-lg p-8 border border-gray-200">
                <h3 class="text-lg font-semibold text-gray-800">Upload CSV</h3>
                <p class="text-sm text-gray-600 mt-1">Select a .csv file exported from your biometric system. Large files
                    (8k–10k rows) may take a while to process.</p>
                <form id="biometricForm" enctype="multipart/form-data" class="mt-6">
                    @csrf
                    <div class="mb-5">
                        <label for="file" class="block text-sm font-medium text-gray-700">CSV File</label>
                        <input type="file" name="file" id="file" accept=".csv" required
                            class="mt-2 block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 bg-white" />
                        <p class="mt-2 text-xs text-gray-500">Accepted format: .csv only.</p>
                    </div>
                    <div class="flex items-center gap-3">
                        <button id="submitBtn" type="submit"
                            class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-5 rounded shadow-sm">
                            Import
                        </button>
                        <span id="helperText" class="text-xs text-gray-500">Do not close the page while
                            importing.</span>
                    </div>
                </form>

                <div id="message" class="mt-4 text-sm"></div>
            </div>

            <!-- Export Section -->
            <div class="bg-white shadow-sm sm:rounded-lg p-8 border border-gray-200 mt-6">
                <h3 class="text-lg font-semibold text-gray-800">Export to CSV</h3>
                <p class="text-sm text-gray-600 mt-1">Update BiometricAttendanceInfo.csv with current database data.</p>
                <div class="mt-6">
                    <button id="exportBtn" type="button"
                        class="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-5 rounded shadow-sm">
                        Export Database to CSV
                    </button>
                    <span id="exportHelperText" class="ml-3 text-xs text-gray-500">This will overwrite the existing CSV
                        file.</span>
                </div>
                <div id="exportMessage" class="mt-4 text-sm"></div>
            </div>
        </div>
    </div>

    <!-- AJAX Script -->
    <script>
        $('#loaderOverlay').hide();
        document.getElementById('biometricForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const form = this;
            const submitBtn = document.getElementById('submitBtn');
            const msg = document.getElementById('message');
            msg.className = 'mt-4 text-sm text-gray-600';
            msg.innerHTML = 'Preparing upload…';

            const formData = new FormData(form);

            $.ajax({
                url: "{{ route('employee.import') }}",
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                headers: {
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
                },
                beforeSend: function() {
                    $('#loaderOverlay').show();
                    submitBtn.disabled = true;
                    submitBtn.classList.add('opacity-70', 'cursor-not-allowed');
                    submitBtn.textContent = 'Importing…';
                    msg.innerHTML = 'Uploading and processing, please wait…';
                },
                success: function(data) {
                    $('#loaderOverlay').hide();
                    msg.innerHTML = data.message || 'Import completed.';
                    msg.className = (data.success ? 'mt-4 text-green-600' : 'mt-4 text-red-600');
                    // Refresh after a short delay
                    setTimeout(function() {
                        location.reload();
                    }, 2000); // 0.8 second delay (for message flash)
                },
                error: function() {
                    msg.innerHTML = 'Upload failed. Please try again.';
                    msg.className = 'mt-4 text-red-600';
                },
                complete: function() {
                    $('#loaderOverlay').hide();
                    submitBtn.disabled = false;
                    submitBtn.classList.remove('opacity-70', 'cursor-not-allowed');
                    submitBtn.textContent = 'Import';
                }
            });
            $('#loaderOverlay').hide();
        });
    </script>

    <!-- Export Script -->
    <script>
        document.getElementById('exportBtn').addEventListener('click', function() {
            const exportBtn = this;
            const exportMsg = document.getElementById('exportMessage');
            const exportHelperText = document.getElementById('exportHelperText');

            // Reset message
            exportMsg.className = 'mt-4 text-sm text-gray-600';
            exportMsg.innerHTML = 'Preparing export...';

            // Disable button
            exportBtn.disabled = true;
            exportBtn.classList.add('opacity-70', 'cursor-not-allowed');
            exportBtn.textContent = 'Exporting...';

            $.ajax({
                url: "{{ route('employee.export.csv') }}",
                type: 'POST',
                headers: {
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
                },
                success: function(data) {
                    if (data.success) {
                        exportMsg.innerHTML = data.message;
                        exportMsg.className = 'mt-4 text-sm text-green-600';
                        exportHelperText.textContent =
                            `Successfully exported ${data.count} employees to CSV.`;
                    } else {
                        exportMsg.innerHTML = data.message;
                        exportMsg.className = 'mt-4 text-sm text-red-600';
                    }
                    // Refresh after a short delay
                    setTimeout(function() {
                        location.reload();
                    }, 2000); // 0.8 second delay (for message flash)
                },
                error: function() {
                    exportMsg.innerHTML = 'Export failed. Please try again.';
                    exportMsg.className = 'mt-4 text-sm text-red-600';
                },
                complete: function() {
                    // Re-enable button
                    exportBtn.disabled = false;
                    exportBtn.classList.remove('opacity-70', 'cursor-not-allowed');
                    exportBtn.textContent = 'Export Database to CSV';
                }
            });
        });
    </script>
</x-app-layout>

<x-app-layout>
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
            {{ __('Report Generation') }}
        </h2>
    </x-slot>

    {{-- <div class="py-12 flex justify-center">
        <div class="max-w-xl w-full bg-white border border-gray-300 rounded-lg shadow-lg p-8">
            <h2 class="text-2xl font-bold text-gray-800 text-center">
                {{ __('Report Generation') }}
            </h2>
            <p class="text-gray-600 text-center mt-2">
                Generate a detailed report of your data with a single click.
            </p>
            <div class="loader-overlay" id="loaderOverlay">
                <div class="loader"></div>
            </div>
            <div class="mt-6 flex justify-center">
                <button x-data @click.prevent="$dispatch('open-modal', 'finalizeModal')"
                    class="flex items-center gap-2 px-5 py-3 bg-green-500 hover:bg-green-600 text-white font-semibold rounded-md shadow-md">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                    Generate Reports
                </button>
            </div>
        </div>
    </div> --}}
    {{-- <button x-data @click.prevent="$dispatch('open-modal', 'finalize')" onclick="GenerateCSVreportFiltered();" --}}
    <div class="py-12 flex justify-center">
        <div class="max-w-xl w-full bg-white border border-gray-200 rounded-2xl shadow-lg p-8">
            <!-- Header -->
            <h2 class="text-2xl font-bold text-gray-900 text-center flex items-center justify-center gap-2">
                <i class="fas fa-chart-bar text-green-600"></i> Final Report Generation
            </h2>

            <!-- Subtext -->
            <p class="text-gray-600 text-center mt-2">
                Automatically compile and finalize employee data including <br>
                <span class="font-semibold text-gray-800">Overtime, Attendance, Schedule Adjustments</span> and
                <span class="font-semibold text-gray-800">Leaves</span>.
            </p>

            <!-- Optional loader overlay (hidden by default) -->
            <div class="loader-overlay hidden" id="loaderOverlay">
                <div class="loader"></div>
            </div>

            <!-- Generate Button -->
            <div class="mt-8 flex justify-center">
                <button x-data @click.prevent="$dispatch('open-modal', 'finalizeModal')"
                    class="flex items-center gap-2 px-6 py-3 bg-green-600 hover:bg-green-700 text-white text-lg font-semibold rounded-lg shadow-md transition-all duration-300">
                    <i class="fas fa-play-circle"></i>
                    Start Report Generation
                </button>
            </div>

            <!-- Footer Info -->
            <p class="text-xs text-gray-500 text-center mt-4">
                Please ensure all employee data is up to date before generating the report.
            </p>
        </div>
    </div>

    <x-modal name="finalizeModal" focusable>
        <div class="p-6">
            <h2 class="text-xl font-semibold text-gray-900 mb-2 flex items-center gap-2">
                <i class="fas fa-clipboard-check text-green-600"></i> Finalization
            </h2>

            <!-- Container for Displaying Dates -->
            <div id="datesContainer" class="text-sm text-gray-600 mb-4"></div>

            <!-- Employee Data Processing Section -->
            <div id="processContainer" class="space-y-2 bg-gray-50 border border-gray-200 rounded-xl p-4 shadow-inner">
                <div class="flex items-center justify-between">
                    <span class="text-gray-700 font-medium">Overtime</span>
                    <i class="fas fa-spinner fa-spin text-blue-500" id="icon-overtime"></i>
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-gray-700 font-medium">Certificate of Attendance</span>
                    <i class="fas fa-clock text-gray-400" id="icon-certificate"></i>
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-gray-700 font-medium">Schedule Adjustment</span>
                    <i class="fas fa-clock text-gray-400" id="icon-schedule"></i>
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-gray-700 font-medium">Leaves</span>
                    <i class="fas fa-clock text-gray-400" id="icon-leaves"></i>
                </div>
            </div>

            <!-- Report Generation Button -->
            <div class="mt-5 text-center">
                <button id="generateReportBtn" onclick="GenerateCSVreportFiltered();"
                    class="px-5 py-2 bg-gray-400 text-white text-sm font-semibold rounded-lg cursor-not-allowed transition-all duration-300 flex items-center gap-2 mx-auto"
                    disabled>
                    <i class="fas fa-file-alt"></i> Generate Report
                </button>
            </div>
        </div>
    </x-modal>

    <script>
        $('#loaderOverlay').hide();

        function processStep(currentIcon, nextIcon, callback) {
            // Simulate loading
            setTimeout(function() {
                // Change current icon to check
                $(currentIcon).removeClass("fa-spinner fa-spin text-blue-500")
                    .addClass("fa-check text-green-500");
                // If there's a next icon, start its loading
                if (nextIcon) {
                    $(nextIcon).removeClass("fa-clock text-gray-400")
                        .addClass("fa-spinner fa-spin text-blue-500");
                    callback && callback();
                }
            }, 1500);
        }

        // Start fake loading process
        function startProcess() {
            $("#icon-overtime").addClass("fa-spinner fa-spin text-blue-500");

            processStep("#icon-overtime", "#icon-certificate", function() {
                processStep("#icon-certificate", "#icon-schedule", function() {
                    processStep("#icon-schedule", "#icon-leaves", function() {
                        // Final step (leaves)
                        setTimeout(function() {
                            $("#icon-leaves").removeClass(
                                    "fa-spinner fa-spin text-blue-500")
                                .addClass("fa-check text-green-500");

                            // Enable button
                            $("#generateReportBtn")
                                .removeAttr("disabled")
                                .removeClass("bg-gray-400 cursor-not-allowed")
                                .addClass("bg-green-600 hover:bg-green-700 cursor-pointer")
                                .html(
                                    '<i class="fas fa-file-export mr-2"></i> Generate Report Ready'
                                );
                        }, 1500);
                    });
                });
            });
        }

        // Trigger process when modal is shown (or manually call it)
        startProcess();

        // On button click
        $("#generateReportBtn").click(function() {});

        function generateReport() {
            $.ajax({
                url: "{{ route('report.fetch') }}",
                type: 'POST',
                headers: {
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
                },
                success: function(result) {
                    displayDates(result);
                },
                error: function(xhr, status, error) {
                    console.error('Error:', error);
                }
            });
        }

        function finalizeApprovedEntries() {
            $.ajax({
                url: "{{ route('report.generation') }}",
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
                },
                processData: false,
                contentType: false,
                success: result => {
                    uploadCsvData();
                },
                error: (xhr, status, error) => {
                    console.error('Error:', error);
                    const errorData = xhr.responseJSON || {};
                    alert(`Error: ${errorData.message || 'An error occurred'}`);
                }
            });
        }

        function uploadCsvData() {
            $.ajax({
                url: "{{ route('import.csv') }}",
                type: 'POST',
                headers: {
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
                },
                success: result => {},
                error: (xhr, status, error) => {
                    console.error('Error:', error);
                }
            });
        }

        // function displayDates(dates) {
        //     var $datesContainer = $('#datesContainer');
        //     $datesContainer.empty(); // Clear previous dates

        //     // Assuming `dates` is an array of date objects with `entry_date` and `generate_status` properties
        //     $.each(dates, function(index, date) {
        //         console.log(date);

        //         // Determine the button class based on generate_status
        //         var buttonClass = date.generate_status ? 'bg-red-500 hover:bg-red-600' :
        //             'bg-blue-500 hover:bg-blue-600';

        //         $datesContainer.append(`
    //             <div class="mt-4 flex justify-center items-center text-center my-2">
    //                 <button value="${date.entry_date}"
    //                     onclick="GenerateCSVreportFiltered(this.value)"
    //                     class="${buttonClass} text-white font-semibold py-2 px-4 rounded shadow-md transition duration-200">
    //                     ${date.entry_date}
    //                 </button>
    //                 ${date.generate_status ? '<span class="ml-2 text-red-500 font-medium">Already generated</span>' : ''}
    //             </div>
    //         `);
        //     });
        // }

        function GenerateCSVreportFiltered(val) {
            $('#loaderOverlay').show();
            finalizeApprovedEntries();

            const authUserId = {{ Auth::check() ? Auth::id() : 'null' }};
            const userRole = "{{ Auth::check() ? Auth::user()->role : '' }}";
            console.log('Authenticated User ID:', authUserId);
            console.log('User Role:', userRole);
            if (userRole === 'admin') {
                setTimeout(() => {
                    let link1 = document.createElement('a');
                    link1.href = '{{ route('download.payrollfile') }}';
                    link1.download = 'PayrollFile.csv';
                    link1.click();

                    setTimeout(() => {
                        let link2 = document.createElement('a');
                        link2.href = '{{ route('download.reportdtr') }}';
                        link2.download = 'reportdtr.xlsx';
                        link2.click();
                    }, 1000);
                }, 1000);
            } else if (authUserId === 7) {
                setTimeout(() => {
                    let link = document.createElement('a');
                    link.href = '{{ route('download.security') }}';
                    link.download = 'security.xlsx';
                    link.click();
                }, 1000);
            } else {
                console.log('No downloads allowed for this user.');
            }


            $.ajax({
                url: '{{ route('export.csv') }}',
                type: 'GET',
                data: {
                    entry_date: val // Passing the entry_date to the controller
                },
                success: function(response) {
                    $('#loaderOverlay').hide();

                    // Create a Blob from the CSV data
                    var blob = new Blob([response], {
                        type: 'text/csv'
                    });
                    var link = document.createElement('a');
                    link.href = URL.createObjectURL(blob);
                    link.download = 'csv_imports_' + val +
                        '.csv'; // Name the file dynamically based on the entry_date
                    link.click();
                },
                error: function(xhr, status, error) {
                    console.error('Error exporting CSV:', error);
                }
            });
        }
    </script>

</x-app-layout>

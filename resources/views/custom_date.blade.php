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
            {{ __('Custom Dates') }}
        </h2>
    </x-slot>

    {{-- <div class="loader-overlay" id="loaderOverlay">
        <div class="loader"></div>
    </div> --}}

    <!-- Table Section -->
    <div class="p-6 text-gray-900">
        <div id="overtime-table-container" class="overflow-x-auto border rounded-lg shadow-sm">
            <div id="pagination" class="flex items-center justify-center my-4 space-x-4"></div>
            <table id="overtime-table" class="min-w-full table-auto">
                <thead class="bg-gray-800 text-white text-sm sticky top-0">
                    <tr>
                        <th class="px-4 py-2 border text-white">ID</th>
                        <th class="px-4 py-2 border text-white">First Name</th>
                        <th class="px-4 py-2 border text-white">Last Name</th>
                        <th class="px-4 py-2 border text-white">Department</th>
                        <th class="px-4 py-2 border text-white">Area</th>
                        <th class="px-4 py-2 border text-white">Date</th>
                        <th class="px-4 py-2 border text-white">Earliest Time</th>
                        <th class="px-4 py-2 border text-white">Latest Time</th>
                        <th class="px-4 py-2 border text-white">Schedule</th>
                        <th class="px-4 py-2 border text-white">ORD-OT</th>
                        <th class="px-4 py-2 border text-white">Ord-ND</th>
                        <th class="px-4 py-2 border text-white">Ord-ND-OT</th>
                        <th class="px-4 py-2 border text-white">RD-OT</th>
                        <th class="px-4 py-2 border text-white">RD-ND</th>
                        <th class="px-4 py-2 border text-white">RD-ND-OT</th>
                        <th class="px-4 py-2 border text-white">RD</th>
                        <th class="px-4 py-2 border text-white">Late</th>
                        <th class="px-4 py-2 border text-white">Late Hours</th>
                        <th class="px-4 py-2 border text-white">Late Minutes</th>
                        <th class="px-4 py-2 border text-white">Action</th>
                    </tr>
                </thead>
                <tbody id="overtime-body" class="text-sm text-gray-800 divide-y divide-gray-200">
                    <!-- Data will be injected here -->
                </tbody>
            </table>
        </div>
    </div>

    <!-- View Approved Modal -->
    <div id="approvedModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black bg-opacity-50">
        <div class="bg-white rounded-lg shadow-lg w-full max-w-2xl p-6">
            <div class="flex justify-between items-center border-b pb-2 mb-4">
                <h3 class="text-lg font-semibold text-gray-800">Stored Approved Entries</h3>
                <button onclick="closeViewApprovedModal()"
                    class="text-gray-500 hover:text-gray-800 text-xl">&times;</button>
            </div>
            <div class="overflow-y-auto max-h-[400px]">
                <table class="min-w-full text-sm table-auto border rounded-lg">
                    <thead class="bg-gray-200 text-left text-xs font-semibold text-gray-700 sticky top-0">
                        <tr>
                            <th class="border px-3 py-2">Type</th>
                            <th class="border px-3 py-2">Last Name</th>
                            <th class="border px-3 py-2">First Name</th>
                            <th class="border px-3 py-2">Date</th>
                            <th class="border px-3 py-2">Earliest Time</th>
                            <th class="border px-3 py-2">Latest Time</th>
                            <th class="border px-3 py-2">Action</th>
                        </tr>
                    </thead>
                    <tbody id="approvedModalBody" class="text-gray-800 divide-y divide-gray-100">
                        <!-- Entries injected by JS -->
                    </tbody>
                </table>
            </div>
            <div class="flex justify-between items-center pt-4">
                <span id="approved-modal-count" class="text-sm text-gray-600">Total Approved: 0</span>
                <div class="space-x-2">
                    <button onclick="finalizeApprovedEntries()"
                        class="bg-green-600 hover:bg-green-700 text-white text-sm px-4 py-2 rounded shadow-md">
                        Finalize
                    </button>
                    <button onclick="closeViewApprovedModal()"
                        class="bg-gray-300 hover:bg-gray-400 text-sm px-4 py-2 rounded shadow-md">
                        Close
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Employee Modal -->
    <x-modal name="edit-overtime" focusable>
        <div class="p-8 bg-white rounded-xl">
            <div class="mb-6">
                <h2 class="text-2xl font-bold text-gray-900 mb-2">Edit Employee</h2>
                <p class="text-gray-600">Update employee information and details</p>
            </div>

            <div class="space-y-6">
                <!-- Schedule -->
                <div>
                    <label for="earliest_time" class="block text-sm font-semibold text-gray-700 mb-2">
                        Earliest Time
                    </label>
                    <input id="earliest_time" type="time"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50 text-gray-600"
                        step="60" min="00:00:00" max="23:59:59" required>
                </div>

                <!-- Unique ID -->
                <div>
                    <label for="latest_time" class="block text-sm font-semibold text-gray-700 mb-2">
                        Latest Time
                    </label>
                    <input id="latest_time" type="time"
                        class="w-full px-4 py-3 border border-gray-300 rounded-lg bg-gray-50 text-gray-600"
                        step="60" min="00:00:00" max="23:59:59" required>
                </div>


                <!-- Modal Actions -->
                <div class="flex justify-end space-x-3 mt-8 pt-6 border-t border-gray-200">
                    <button x-on:click="$dispatch('close')" type="button"
                        class="px-6 py-3 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200">
                        Cancel
                    </button>
                    <button type="button" x-on:click="$dispatch('close')"
                        class="px-6 py-3 text-white bg-gradient-to-r from-blue-600 to-blue-700 rounded-lg hover:from-blue-700 hover:to-blue-800 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transform transition-all duration-200 hover:scale-105"
                        onclick="updateFunction();">
                        Save Changes
                    </button>
                </div>
            </div>
    </x-modal>

    <!-- DataTables CSS and JS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/2.1.8/css/dataTables.dataTables.min.css">
    <script src="https://cdn.datatables.net/2.1.8/js/dataTables.min.js"></script>

    <!-- JavaScript -->
    <script></script>
</x-app-layout>

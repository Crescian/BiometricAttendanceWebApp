<x-app-layout>
    <div class="px-16 py-12 bg-gray-50 min-h-screen">
        <h2 class="text-3xl font-bold mb-8 text-gray-800 border-b-2 border-green-700 pb-2">
            User Logs
        </h2>

        <div class="overflow-x-auto shadow-lg rounded-xl border border-gray-300">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-[#00291B] text-white">
                    <tr>
                        <th class="px-4 py-3 text-center text-sm font-semibold uppercase tracking-wider">#</th>
                        <th class="px-6 py-3 text-left text-sm font-semibold uppercase tracking-wider">User</th>
                        <th class="px-6 py-3 text-left text-sm font-semibold uppercase tracking-wider">Action</th>
                        <th class="px-6 py-3 text-left text-sm font-semibold uppercase tracking-wider">Timestamp</th>
                        <th class="px-6 py-3 text-left text-sm font-semibold uppercase tracking-wider">IP Address</th>
                    </tr>
                </thead>
                <tbody id="logsTableBody" class="bg-white divide-y divide-gray-200 text-gray-700">
                    <tr>
                        <td colspan="5" class="text-center py-6 text-gray-500">Loading logs...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>


    <!-- AJAX Script -->
    <script>
        function loadLogs() {
            $.ajax({
                url: "{{ route('attendanceLogs.fetch') }}", // Laravel route to fetch logs
                type: "GET",
                success: function(response) {
                    let tbody = $('#logsTableBody');
                    tbody.empty();

                    if (response.length === 0) {
                        tbody.append(`
                            <tr>
                                <td colspan="7" class="text-center py-4 text-gray-500">No logs found.</td>
                            </tr>
                        `);
                        return;
                    }

                    response.forEach((log, index) => {
                        tbody.append(`
                            <tr class="hover:bg-gray-50 transition">
                                <td class="px-4 py-2 text-center">${index + 1}</td>
                                <td class="px-4 py-2">${log.user_name}</td>
                                <td class="px-4 py-2">${log.action}</td>
                                <td class="px-4 py-2">${log.timestamp}</td>
                                <td class="px-4 py-2">${log.ip_address || '-'}</td>
                            </tr>
                        `);
                    });
                },
                error: function(err) {
                    console.error(err);
                    $('#logsTableBody').html(`
                        <tr>
                            <td colspan="7" class="text-center py-4 text-red-500">Failed to load logs.</td>
                        </tr>
                    `);
                }
            });
        }

        // Load logs on page load
        $(document).ready(function() {
            loadLogs();
        });
    </script>
</x-app-layout>

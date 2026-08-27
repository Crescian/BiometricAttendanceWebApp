<x-app-layout>
    <!-- Dashboard Header -->
    <div class="px-16 py-8">
        <h1 class="text-4xl font-semibold text-gray-900 tracking-tight">
            Dashboard
        </h1>
        <p class="text-gray-500 text-lg mt-2">
            Welcome back, <span class="text-emerald-600 font-medium">{{ Auth::user()->name ?? 'User' }}</span>.
            Here’s an overview of your workspace today.
        </p>
    </div>

    <div class="px-16 py-2">
        <!-- Row 1 -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">

            <div class="bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col h-auto">
                <!-- Card Header -->
                <div class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200">
                    <h2 class="text-2xl font-bold text-gray-900">
                        <i class="fa-solid fa-square-binary text-3xl" style="color: #8DE11A;"></i>
                        Today <span id="todayDate"></span>
                    </h2>
                </div>

                <!-- Card Body -->
                <div class="p-6 flex-1 flex flex-col items-center justify-center text-center">
                    <img src="{{ asset('image/team-bro.png') }}" alt="Team Illustration"
                        class="max-w-full object-contain mb-4" width="200" height="200">
                    <p class="text-gray-700 text-lg font-medium" style="margin-top: -50px">We hope you have a productive
                        day!</p>
                </div>
            </div>


            <!-- Attendance Card -->
            <div class="bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col h-auto">
                <div class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200">
                    <h2 class="text-2xl font-bold text-gray-900 flex items-center gap-2">
                        <i class="fa-regular fa-calendar-days text-3xl" style="color: #8DE11A;"></i>
                        Attendance
                    </h2>
                </div>

                <div class="p-6 flex-1">
                    <div class="relative w-full h-[300px] sm:h-[350px] md:h-[400px]">
                        <canvas id="attendanceChart" class="w-full h-full"></canvas>
                    </div>
                </div>
            </div>

            <!-- My Stuff Card -->
            <div class="bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col h-auto">
                <!-- Header -->
                <div class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200 flex justify-between items-center">
                    <h2 class="text-2xl font-bold text-gray-900">
                        <i class="fa-solid fa-folder-open text-3xl" style="color: #8DE11A;"></i>
                        My Stuff
                    </h2>
                    <button class="text-sm text-green-600 hover:underline">View All</button>
                </div>

                <!-- Body -->
                <div class="p-6 flex-1 overflow-y-auto space-y-6 custom-scrollbar">
                    <!-- Attendance Stats Summary -->
                    <div>
                        <h3 class="text-md font-semibold text-gray-800 mb-2 border-b pb-1">Attendance Summary</h3>
                        <div class="grid grid-cols-3 gap-3">
                            <div class="bg-green-50 rounded-lg p-3 text-center border border-green-200">
                                <p class="text-2xl font-bold text-green-700">24</p>
                                <p class="text-xs text-gray-600">Days Present</p>
                            </div>
                            <div class="bg-yellow-50 rounded-lg p-3 text-center border border-yellow-200">
                                <p class="text-2xl font-bold text-yellow-700">3</p>
                                <p class="text-xs text-gray-600">Late Entries</p>
                            </div>
                            <div class="bg-red-50 rounded-lg p-3 text-center border border-red-200">
                                <p class="text-2xl font-bold text-red-700">1</p>
                                <p class="text-xs text-gray-600">Absences</p>
                            </div>
                        </div>
                    </div>

                    <!-- Recent Certificates -->
                    <div>
                        <h3 class="text-md font-semibold text-gray-800 mb-2 border-b pb-1">Recent Certificates</h3>
                        <ul class="space-y-2 text-sm">
                            <li class="flex justify-between items-center border-b pb-1">
                                <span class="text-gray-700">Nov 1, 2025</span>
                                <span class="text-green-600 font-medium">Approved</span>
                            </li>
                            <li class="flex justify-between items-center border-b pb-1">
                                <span class="text-gray-700">Oct 29, 2025</span>
                                <span class="text-yellow-600 font-medium">Pending</span>
                            </li>
                            <li class="flex justify-between items-center">
                                <span class="text-gray-700">Oct 25, 2025</span>
                                <span class="text-green-600 font-medium">Approved</span>
                            </li>
                        </ul>
                    </div>

                    <!-- Pending Approvals -->
                    <div>
                        <h3 class="text-md font-semibold text-gray-800 mb-2 border-b pb-1">Pending Approvals</h3>
                        <p class="text-sm text-gray-600">You currently have <span class="font-bold text-yellow-600">2
                                pending</span> certificates awaiting admin review.</p>
                    </div>

                    <!-- Recent Clock-ins -->
                    <div>
                        <h3 class="text-md font-semibold text-gray-800 mb-2 border-b pb-1">Recent Clock-ins/Outs</h3>
                        <ul class="space-y-2 text-sm">
                            <li class="flex justify-between items-center border-b pb-1">
                                <span class="text-gray-700">Nov 3, 2025</span>
                                <span class="text-gray-500">8:02 AM - 5:01 PM</span>
                            </li>
                            <li class="flex justify-between items-center border-b pb-1">
                                <span class="text-gray-700">Nov 2, 2025</span>
                                <span class="text-gray-500">8:05 AM - 5:03 PM</span>
                            </li>
                            <li class="flex justify-between items-center">
                                <span class="text-gray-700">Nov 1, 2025</span>
                                <span class="text-gray-500">8:00 AM - 5:00 PM</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <style>
            .marquee-vertical {
                display: flex;
                flex-direction: column;
                animation: scrollUp 15s linear infinite;
                height: 100%;
            }

            .marquee-content {
                display: flex;
                flex-direction: column;
            }

            @keyframes scrollUp {
                0% {
                    transform: translateY(0);
                }

                100% {
                    transform: translateY(-50%);
                }
            }

            /* Scrollbar visible only on hover */
            .group:hover .marquee-vertical {
                overflow-y: auto;
                scrollbar-width: thin;
                scrollbar-color: #8DE11A #f9fafb;
            }

            /* Hide scrollbar when not hovering */
            .marquee-vertical::-webkit-scrollbar {
                width: 0;
            }

            .group:hover .marquee-vertical::-webkit-scrollbar {
                width: 6px;
            }

            .group:hover .marquee-vertical::-webkit-scrollbar-thumb {
                background-color: #8DE11A;
                border-radius: 4px;
            }
        </style>

        <!-- Row 2 -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-10">
            <!-- Card 1: Upcoming Holidays -->
            <div class="col-span-1 bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col h-[415px]">
                <div class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200 flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-gray-900 flex items-center space-x-2">
                        <i class="fa-solid fa-calendar-days text-3xl" style="color: #8DE11A;"></i>
                        <span>Upcoming Holidays</span>
                    </h2>
                    <button onclick="openCustomeDates();"
                        class="flex items-center px-3 py-1 bg-white text-green-600 font-semibold rounded-lg shadow-sm border border-green-600 text-sm">
                        <i class="fa-solid fa-plus mr-1"></i> Add
                    </button>
                </div>

                <div
                    class="p-6 flex-1 overflow-hidden relative h-64 group rounded-lg border border-gray-200 bg-white transition-all flex flex-col">
                    <div class="marquee-vertical group-hover:[animation-play-state:paused] group-hover:overflow-y-auto">
                        <div class="marquee-content">
                        </div>
                    </div>
                </div>
            </div>

            <!-- Card 2: Overtime Requests Status -->
            <div class="col-span-1 bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col">
                <div class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200 flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-gray-900 flex items-center">
                        <i class="fa-solid fa-clock text-3xl mr-2" style="color: #8DE11A;"></i>
                        Overtime Requests Status
                    </h2>
                </div>
                <div class="p-6 flex-1 flex justify-center items-center relative" style="height: 300px;">
                    <canvas id="overtimeStatusChart"></canvas>
                </div>
            </div>

            <!-- Card 3: Certificate of Attendance -->
            <div class="col-span-1 bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col">
                <div class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200 flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-gray-900 flex items-center">
                        <i class="fa-regular fa-calendar-check text-3xl mr-2" style="color: #8DE11A;"></i>
                        Certificate of Attendance Status
                    </h2>
                </div>
                <div class="p-6 flex-1 flex justify-center items-center relative" style="height: 300px;">
                    <canvas id="certificateOfAttendanceChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Row 3 -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <!-- Card 1: Schedule Djustment Status -->
            <div class="col-span-1 bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col">
                <div
                    class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200 flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-gray-900 flex items-center">
                        <i class="fa-solid fa-clock text-3xl mr-2" style="color: #8DE11A;"></i>
                        Schedule Adjustment Status
                    </h2>
                </div>
                <div class="p-6 flex-1 flex justify-center items-center relative" style="height: 300px;">
                    <canvas id="scheduleAdjustmentStatusChart"></canvas>
                </div>
            </div>

            <!-- Card 2: Leaves Status -->
            <div class="col-span-1 bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col">
                <div
                    class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200 flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-gray-900 flex items-center">
                        <i class="fa-solid fa-clock text-3xl mr-2" style="color: #8DE11A;"></i>
                        Leaves Status
                    </h2>
                </div>
                <div class="p-6 flex-1 flex justify-center items-center relative" style="height: 300px;">
                    <canvas id="leaveStatusChart"></canvas>
                </div>
            </div>

            <!-- Card 3: Certificate of Attendance -->
            {{-- <div class="col-span-1 bg-white shadow-lg rounded-lg border border-gray-200 flex flex-col">
                <div
                    class="bg-white px-6 py-3 rounded-t-lg border-b border-gray-200 flex items-center justify-between">
                    <h2 class="text-2xl font-bold text-gray-900 flex items-center">
                        <i class="fa-regular fa-calendar-check text-3xl mr-2" style="color: #8DE11A;"></i>
                        Certificate of Attendance
                    </h2>
                </div>
                <div class="p-6 flex-1 flex justify-center items-center relative" style="height: 300px;">
                    <canvas id="certificateOfAttendanceChart"></canvas>
                </div>
            </div> --}}
        </div>

        <!-- Add Custom Dates Modal -->
        <div id="addCustomeDatesModal"
            class="fixed inset-0 z-50 hidden items-center justify-center bg-black bg-opacity-50">
            <div class="bg-white rounded-lg shadow-lg w-full max-w-4xl p-6">
                <!-- Modal Header -->
                <div class="flex justify-between items-center border-b pb-2 mb-4">
                    <h3 class="text-lg font-semibold text-gray-800">Add New Custom Holiday</h3>
                    <button onclick="closeCustomeDates()"
                        class="text-gray-500 hover:text-gray-800 text-xl">&times;</button>
                </div>

                <!-- Modal Body -->
                <div class="space-y-4">
                    <!-- Title -->
                    <div>
                        <label for="holidayTitle" class="block text-sm font-medium text-gray-700 mb-1">Title</label>
                        <input type="text" id="holidayTitle" name="holidayTitle"
                            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500 text-sm"
                            placeholder="Enter holiday title">
                    </div>

                    <!-- Record Date -->
                    <div>
                        <label for="recordDate" class="block text-sm font-medium text-gray-700 mb-1">Record
                            Date</label>
                        <input type="date" id="recordDate" name="recordDate"
                            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500 text-sm">
                    </div>

                    <!-- Holiday Type -->
                    <div>
                        <label for="holidayType" class="block text-sm font-medium text-gray-700 mb-1">Holiday
                            Type</label>
                        <select id="holidayType" name="holidayType"
                            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500 text-sm">
                            <option value="" disabled selected>Select holiday type</option>
                            <option value="Regular Holiday">Regular Holiday</option>
                            <option value="Special Non-working Day">Special Non-working Day</option>
                            <option value="Others">Others</option>
                        </select>
                    </div>
                </div>

                <!-- Modal Footer -->
                <div class="flex justify-end space-x-4 pt-6 border-t mt-6">
                    <button type="button" onclick="closeCustomeDates()"
                        class="bg-gray-300 hover:bg-gray-400 text-gray-700 text-sm px-4 py-2 rounded shadow-md transition-all">
                        Cancel
                    </button>
                    <button type="submit" onclick="submitCustomeDates();"
                        class="bg-green-600 hover:bg-green-700 text-white text-sm px-4 py-2 rounded shadow-md transition-all">
                        Add Holiday
                    </button>
                </div>
            </div>
        </div>

        <!-- Chart.js CDN -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>

        <!-- AJAX Script -->
        <script>
            $(document).ready(function() {
                $.ajax({
                    url: "{{ route('leaves.status.summary') }}",
                    method: "GET",
                    success: function(response) {
                        const ctx = document.getElementById('leaveStatusChart').getContext('2d');
                        const chartContainer = $('#leaveStatusChart').parent(); // the .p-6 container

                        // Check if response has data
                        const hasData = response.data && response.data.some(value => value > 0);

                        if (!hasData) {
                            chartContainer.html(`
                    <div class="flex flex-col items-center justify-center h-64 text-gray-500">
                        <i class="fa-solid fa-chart-pie text-5xl mb-3 text-gray-400"></i>
                        <p class="text-lg font-semibold text-gray-600">No leave data available</p>
                        <p class="text-sm text-gray-400">Data will appear once records are submitted</p>
                    </div>
                `);
                            return;
                        }

                        // Render chart
                        new Chart(ctx, {
                            type: 'pie',
                            data: {
                                labels: response.labels,
                                datasets: [{
                                    label: 'Leave Status',
                                    data: response.data,
                                    backgroundColor: [
                                        'rgba(141, 225, 26, 0.6)', // Approved
                                        'rgba(255, 205, 86, 0.6)', // Pending
                                        'rgba(255, 99, 132, 0.6)' // Rejected
                                    ],
                                    borderColor: ['#8DE11A', '#FFCD56', '#FF6384'],
                                    borderWidth: 1,
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        position: "bottom",
                                        labels: {
                                            color: "#333",
                                            font: {
                                                size: 14
                                            }
                                        }
                                    },
                                    tooltip: {
                                        callbacks: {
                                            label: function(context) {
                                                let label = context.label || "";
                                                let value = context.parsed;
                                                let total = context.chart._metasets[context
                                                    .datasetIndex].total;
                                                let percentage = ((value / total) * 100)
                                                    .toFixed(1) + "%";
                                                return `${label}: ${value} (${percentage})`;
                                            }
                                        }
                                    },
                                    datalabels: {
                                        color: "#000",
                                        font: {
                                            weight: "bold"
                                        },
                                        formatter: (value, ctx) => {
                                            const total = ctx.chart._metasets[ctx.datasetIndex]
                                                .total;
                                            const percentage = ((value / total) * 100).toFixed(
                                                1);
                                            return percentage + "%";
                                        }
                                    }
                                }
                            },
                            plugins: [ChartDataLabels]
                        });
                    },
                    error: function() {
                        const chartContainer = $('#leaveStatusChart').parent();
                        chartContainer.html(`
                <div class="flex flex-col items-center justify-center h-64 text-gray-500">
                    <i class="fa-solid fa-triangle-exclamation text-5xl mb-3 text-red-400"></i>
                    <p class="text-lg font-semibold text-gray-700">Failed to load data</p>
                    <p class="text-sm text-gray-400">Please try again later</p>
                </div>
            `);
                    }
                });
            });
            $(document).ready(function() {
                $.ajax({
                    url: "{{ route('schedule.status.summary') }}",
                    method: "GET",
                    success: function(response) {
                        const ctx = document.getElementById('scheduleAdjustmentStatusChart').getContext(
                            '2d');
                        const chartContainer = $('#scheduleAdjustmentStatusChart')
                            .parent(); // parent container

                        // Check if response has data
                        const hasData = response.data && response.data.some(value => value > 0);

                        if (!hasData) {
                            chartContainer.html(`
                    <div class="flex flex-col items-center justify-center h-64 text-gray-500">
                        <i class="fa-solid fa-calendar-xmark text-5xl mb-3 text-gray-400"></i>
                        <p class="text-lg font-semibold text-gray-600">No schedule adjustment data</p>
                        <p class="text-sm text-gray-400">Records will appear once adjustments are filed</p>
                    </div>
                `);
                            return;
                        }

                        // Render the pie chart
                        new Chart(ctx, {
                            type: 'pie',
                            data: {
                                labels: response.labels,
                                datasets: [{
                                    label: 'Schedule Adjustment Status',
                                    data: response.data,
                                    backgroundColor: [
                                        'rgba(141, 225, 26, 0.6)', // Approved
                                        'rgba(255, 205, 86, 0.6)', // Pending
                                        'rgba(255, 99, 132, 0.6)' // Rejected
                                    ],
                                    borderColor: ['#8DE11A', '#FFCD56', '#FF6384'],
                                    borderWidth: 1,
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        position: "bottom",
                                        labels: {
                                            color: "#333",
                                            font: {
                                                size: 14
                                            }
                                        }
                                    },
                                    tooltip: {
                                        callbacks: {
                                            label: function(context) {
                                                let label = context.label || "";
                                                let value = context.parsed;
                                                let total = context.chart._metasets[context
                                                    .datasetIndex].total;
                                                let percentage = ((value / total) * 100)
                                                    .toFixed(1) + "%";
                                                return `${label}: ${value} (${percentage})`;
                                            }
                                        }
                                    },
                                    datalabels: {
                                        color: "#000",
                                        font: {
                                            weight: "bold"
                                        },
                                        formatter: (value, ctx) => {
                                            const total = ctx.chart._metasets[ctx.datasetIndex]
                                                .total;
                                            const percentage = ((value / total) * 100).toFixed(
                                                1);
                                            return percentage + "%";
                                        }
                                    }
                                }
                            },
                            plugins: [ChartDataLabels]
                        });
                    },
                    error: function() {
                        const chartContainer = $('#scheduleAdjustmentStatusChart').parent();
                        chartContainer.html(`
                <div class="flex flex-col items-center justify-center h-64 text-gray-500">
                    <i class="fa-solid fa-triangle-exclamation text-5xl mb-3 text-red-400"></i>
                    <p class="text-lg font-semibold text-gray-700">Failed to load schedule data</p>
                    <p class="text-sm text-gray-400">Please refresh or try again later</p>
                </div>
            `);
                    }
                });
            });
            document.addEventListener("DOMContentLoaded", function() {
                fetch("/certificate-attendance-summary")
                    .then(response => response.json())
                    .then(data => {
                        const chartContainer = document.getElementById("certificateOfAttendanceChartContainer");
                        const canvas = document.getElementById("certificateOfAttendanceChart");
                        const ctx = canvas.getContext("2d");

                        const hasData = data.data && data.data.some(value => value > 0);

                        // Show "No Data" UI
                        if (!hasData) {
                            chartContainer.innerHTML = `
                    <div class="flex flex-col items-center justify-center h-64 text-gray-500">
                        <i class="fa-solid fa-chart-pie text-5xl mb-3 text-gray-400"></i>
                        <p class="text-lg font-semibold text-gray-600">No certificate data available</p>
                        <p class="text-sm text-gray-400">Data will appear once records are submitted</p>
                    </div>
                `;
                            return;
                        }

                        // Render chart when data exists
                        new Chart(ctx, {
                            type: "doughnut",
                            data: {
                                labels: data.labels,
                                datasets: [{
                                    label: "Certificate Status",
                                    data: data.data,
                                    backgroundColor: [
                                        "#8DE11A",
                                        "#FFCD56",
                                        "#36A2EB",
                                        "#FF6384",
                                        "#4BC0C0"
                                    ],
                                    borderColor: "#fff",
                                    borderWidth: 2
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        position: "bottom",
                                        labels: {
                                            color: "#333",
                                            font: {
                                                size: 14
                                            }
                                        }
                                    },
                                    tooltip: {
                                        callbacks: {
                                            label: function(context) {
                                                let label = context.label || "";
                                                let value = context.parsed;
                                                let total = context.dataset.data.reduce((a, b) => a + b,
                                                    0);
                                                let percentage = ((value / total) * 100).toFixed(1) +
                                                    "%";
                                                return `${label}: ${value} (${percentage})`;
                                            }
                                        }
                                    },
                                    datalabels: {
                                        color: "#000",
                                        font: {
                                            weight: "bold"
                                        },
                                        formatter: (value, ctx) => {
                                            const total = ctx.dataset.data.reduce((a, b) => a + b, 0);
                                            const percentage = ((value / total) * 100).toFixed(1);
                                            return percentage + "%";
                                        }
                                    }
                                }
                            },
                            plugins: [ChartDataLabels]
                        });
                    })
                    .catch(() => {
                        const chartContainer = document.getElementById("certificateOfAttendanceChartContainer");
                        chartContainer.innerHTML = `
                <div class="flex flex-col items-center justify-center h-64 text-gray-500">
                    <i class="fa-solid fa-triangle-exclamation text-5xl mb-3 text-red-400"></i>
                    <p class="text-lg font-semibold text-gray-700">Failed to load data</p>
                    <p class="text-sm text-gray-400">Please try again later</p>
                </div>
            `;
                    });
            });

            $(document).ready(function() {
                $.ajax({
                    url: "{{ route('overtime.status.summary') }}",
                    type: 'GET',
                    success: function(response) {
                        const ctx = document.getElementById('overtimeStatusChart').getContext('2d');
                        new Chart(ctx, {
                            type: 'pie',
                            data: {
                                labels: response.labels,
                                datasets: [{
                                    data: response.data,
                                    backgroundColor: [
                                        'rgba(255, 205, 86, 0.8)', // Pending
                                        'rgba(75, 192, 192, 0.8)', // Approved
                                        'rgba(255, 99, 132, 0.8)' // Cancelled
                                    ],
                                    borderColor: ['#FACC15', '#10B981', '#EF4444'],
                                    borderWidth: 2
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        position: 'bottom',
                                        labels: {
                                            color: '#374151',
                                            font: {
                                                size: 14
                                            }
                                        }
                                    },
                                    datalabels: {
                                        color: '#fff',
                                        font: {
                                            weight: 'bold',
                                            size: 14
                                        },
                                        formatter: (value, context) => {
                                            const dataset = context.chart.data.datasets[0].data;
                                            const total = dataset.reduce((a, b) => a + b, 0);
                                            const percentage = ((value / total) * 100).toFixed(
                                                1) + '%';
                                            return percentage;
                                        }
                                    }
                                }
                            },
                            plugins: [ChartDataLabels]
                        });
                    }
                });
            });

            $(document).ready(function() {
                $.ajax({
                    url: "{{ route('attendance.summary') }}",
                    type: "GET",
                    dataType: "json",
                    success: function(data) {
                        const ctx = $("#attendanceChart")[0].getContext("2d");

                        new Chart(ctx, {
                            type: "bar",
                            data: {
                                labels: data.labels,
                                datasets: [{
                                    label: "Total Presents",
                                    data: data.data,
                                    backgroundColor: "rgba(141, 225, 26, 0.6)",
                                    borderColor: "#8DE11A",
                                    borderWidth: 1,
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                scales: {
                                    y: {
                                        beginAtZero: true,
                                        ticks: {
                                            color: "#333"
                                        },
                                        grid: {
                                            color: "#e5e7eb"
                                        }
                                    },
                                    x: {
                                        ticks: {
                                            color: "#333"
                                        },
                                        grid: {
                                            display: false
                                        }
                                    }
                                }
                            }
                        });
                    },
                    error: function(xhr, status, error) {
                        console.error("Error fetching attendance data:", error);
                    }
                });
            });
            loadCustomDates();
            setTodayDate();

            function setTodayDate() {
                const today = new Date();
                const formatted = today.toLocaleDateString('en-US', {
                    month: '2-digit',
                    day: '2-digit',
                    year: 'numeric'
                });
                $('#todayDate').text(formatted);
            }

            function loadCustomDates() {
                fetch('/custom-dates')
                    .then(res => res.json())
                    .then(data => {
                        const container = document.querySelector('.marquee-content');
                        container.innerHTML = '';

                        data.forEach(item => {
                            container.innerHTML += `
                    <div class="flex justify-between items-center bg-white px-4 py-3 rounded-lg border-b border-[#8DE11A] mb-3">
                        <div>
                            <p class="text-gray-900 font-semibold">
                                ${new Date(item.record_date).toLocaleDateString('en-US', {
                                    month: 'short',
                                    day: '2-digit',
                                    year: 'numeric'
                                })}
                            </p>
                            <p class="text-gray-700 text-sm">
                                ${item.title} — <span class="italic text-gray-600">${item.holiday_type}</span>
                            </p>
                        </div>
                        <div class="flex space-x-2">
                            <button class="p-2 bg-white rounded-lg hover:bg-gray-100 focus:outline-none">
                                <i class="fa-solid fa-pen"></i>
                            </button>
                            <button class="p-2 bg-white rounded-lg hover:bg-gray-100 focus:outline-none">
                                <i class="fa-solid fa-trash text-black"></i>
                            </button>
                        </div>
                    </div>
                `;
                        });
                    })
                    .catch(err => {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: 'Failed to load custom dates.'
                        });
                        console.error(err);
                    });
            }

            function submitCustomeDates() {
                const data = {
                    record_date: $('#recordDate').val(),
                    title: $('#holidayTitle').val(),
                    holiday_type: $('#holidayType').val(),
                };

                fetch('/custom-dates/store', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                        },
                        body: JSON.stringify(data)
                    })
                    .then(res => res.json())
                    .then(response => {
                        if (response.success) {
                            Swal.fire({
                                title: 'Success!',
                                text: response.message,
                                icon: 'success',
                                confirmButtonColor: '#16A34A', // Tailwind green-600
                                confirmButtonText: 'OK'
                            }).then(() => {
                                closeCustomeDates();
                                // Optional: refresh data table or reload list here
                                // location.reload();
                            });
                        } else {
                            Swal.fire({
                                title: 'Oops!',
                                text: response.message || 'Something went wrong while adding the holiday.',
                                icon: 'warning',
                                confirmButtonColor: '#F87171', // red-400
                            });
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        Swal.fire({
                            title: 'Error!',
                            text: 'An error occurred while saving the holiday. Please try again.',
                            icon: 'error',
                            confirmButtonColor: '#EF4444', // Tailwind red-600
                        });
                    });
            }

            function openCustomeDates() {
                document.getElementById('addCustomeDatesModal').classList.replace('hidden', 'flex');
            }

            function closeCustomeDates() {
                document.getElementById('addCustomeDatesModal').classList.replace('flex', 'hidden');
            }
        </script>
</x-app-layout>

<x-app-layout>
    <!-- Dashboard Header -->
    <div class="px-6 pt-4 pb-2 flex flex-wrap items-baseline gap-x-3">
        <h1 class="text-xl font-semibold text-gray-900 tracking-tight">Dashboard</h1>
        <p class="text-sm text-gray-500">
            Welcome back, <span class="text-emerald-600 font-medium">{{ Auth::user()->name ?? 'User' }}</span>.
            Here’s an overview of your workspace today.
        </p>
    </div>

    <!-- Both rows share the screen height on large screens, so the whole dashboard fits in one view -->
    <div class="px-6 pb-4 flex flex-col gap-4 lg:h-[calc(100vh-7rem)] lg:min-h-[34rem]">
        <!-- Row 1 -->
        <div class="grid grid-cols-1 lg:grid-cols-4 gap-4 lg:flex-1 lg:min-h-0">

            <div class="bg-white shadow rounded-lg border border-gray-200 flex flex-col min-h-0">
                <!-- Card Header -->
                <div class="px-4 py-2 border-b border-gray-200 flex items-center justify-between gap-2">
                    <h2 class="text-sm font-semibold text-gray-900 flex items-center gap-2 truncate">
                        <i class="fa-solid fa-square-binary text-base" style="color: #8DE11A;"></i>
                        <span class="truncate">Today <span id="todayDate"></span></span>
                    </h2>
                </div>

                <!-- Card Body -->
                <div class="p-3 flex-1 min-h-0 flex flex-col items-center justify-center text-center gap-2">
                    <img src="{{ asset('image/Team-bro.png') }}" alt="Team Illustration"
                        class="max-h-28 w-auto object-contain">
                    <p class="text-gray-700 text-sm font-medium">We hope you have a productive day!</p>
                </div>
            </div>


            <!-- Attendance Card -->
            <div class="bg-white shadow rounded-lg border border-gray-200 flex flex-col min-h-0 lg:col-span-2">
                <div class="px-4 py-2 border-b border-gray-200 flex items-center justify-between gap-2">
                    <h2 class="text-sm font-semibold text-gray-900 flex items-center gap-2 truncate">
                        <i class="fa-regular fa-calendar-days text-base" style="color: #8DE11A;"></i>
                        <span class="truncate">Attendance</span>
                    </h2>
                </div>

                <div class="p-3 flex-1 min-h-0">
                    <div class="relative w-full h-64 lg:h-full">
                        <canvas id="attendanceChart" class="w-full h-full"></canvas>
                    </div>
                </div>
            </div>

            <!-- My Stuff Card -->
            @php
                $statusColor = fn($status) => match (strtolower((string) $status)) {
                    'approved' => 'text-green-600',
                    'pending' => 'text-yellow-600',
                    default => 'text-red-600',
                };
            @endphp
            <div class="bg-white shadow rounded-lg border border-gray-200 flex flex-col min-h-0 max-h-96 lg:max-h-none">
                <!-- Header -->
                <div class="px-4 py-2 border-b border-gray-200 flex items-center justify-between gap-2">
                    <div class="min-w-0">
                        <h2 class="text-sm font-semibold text-gray-900 flex items-center gap-2 truncate">
                        <i class="fa-solid fa-folder-open text-base" style="color: #8DE11A;"></i>
                        <span class="truncate">My Stuff</span>
                    </h2>
                        <p class="text-[11px] text-gray-500 truncate">{{ $myStuff['scope'] }}</p>
                    </div>
                    <a href="{{ route('attendance.record') }}" class="text-xs text-green-600 hover:underline shrink-0">View All</a>
                </div>

                <!-- Body -->
                <div class="p-3 flex-1 min-h-0 overflow-y-auto space-y-3 custom-scrollbar">
                    <!-- Attendance Stats Summary -->
                    <div>
                        <h3 class="text-[11px] font-semibold uppercase tracking-wide text-gray-500 mb-1.5">Attendance Summary</h3>
                        <div class="grid grid-cols-3 gap-2">
                            <div class="bg-green-50 rounded-md p-2 text-center border border-green-200">
                                <p class="text-lg font-bold leading-tight text-green-700">{{ number_format($myStuff['present']) }}</p>
                                <p class="text-[11px] text-gray-600">Present</p>
                            </div>
                            <div class="bg-yellow-50 rounded-md p-2 text-center border border-yellow-200">
                                <p class="text-lg font-bold leading-tight text-yellow-700">{{ number_format($myStuff['late']) }}</p>
                                <p class="text-[11px] text-gray-600">Late</p>
                            </div>
                            <div class="bg-red-50 rounded-md p-2 text-center border border-red-200">
                                <p class="text-lg font-bold leading-tight text-red-700">{{ number_format($myStuff['on_leave']) }}</p>
                                <p class="text-[11px] text-gray-600">On Leave</p>
                            </div>
                        </div>
                    </div>

                    <!-- Recent Certificates -->
                    <div>
                        <h3 class="text-[11px] font-semibold uppercase tracking-wide text-gray-500 mb-1.5">Recent Certificates</h3>
                        <ul class="space-y-1.5 text-xs">
                            @forelse ($myStuff['certificates'] as $certificate)
                                <li class="flex justify-between items-center gap-2 {{ $loop->last ? '' : 'border-b pb-1' }}">
                                    <span class="text-gray-700 min-w-0">
                                        {{ $certificate->date ? \Carbon\Carbon::parse($certificate->date)->format('M j, Y') : '—' }}
                                        <span class="text-gray-400 text-[11px] block truncate">{{ $certificate->employee_name }}</span>
                                    </span>
                                    <span class="{{ $statusColor($certificate->approval_status) }} font-medium">{{ ucfirst($certificate->approval_status) }}</span>
                                </li>
                            @empty
                                <li class="text-gray-400">No certificates filed yet.</li>
                            @endforelse
                        </ul>
                    </div>

                    <!-- Pending Approvals -->
                    <div>
                        <h3 class="text-[11px] font-semibold uppercase tracking-wide text-gray-500 mb-1.5">Pending Approvals</h3>
                        @if ($myStuff['pending_total'] > 0)
                            <p class="text-xs text-gray-600 mb-1"><span class="font-bold text-yellow-600">{{ $myStuff['pending_total'] }}
                                    pending</span> {{ \Illuminate\Support\Str::plural('request', $myStuff['pending_total']) }} awaiting review.</p>
                            <ul class="text-xs text-gray-600 space-y-0.5">
                                <li class="flex justify-between"><span>Certificates of Attendance</span><span class="font-semibold">{{ $myStuff['pending']['certificates'] }}</span></li>
                                <li class="flex justify-between"><span>Schedule Adjustments</span><span class="font-semibold">{{ $myStuff['pending']['schedule_adjustments'] }}</span></li>
                                <li class="flex justify-between"><span>Overtime</span><span class="font-semibold">{{ $myStuff['pending']['overtimes'] }}</span></li>
                                <li class="flex justify-between"><span>Leaves</span><span class="font-semibold">{{ $myStuff['pending']['leaves'] }}</span></li>
                            </ul>
                        @else
                            <p class="text-xs text-gray-400">Nothing is awaiting review.</p>
                        @endif
                    </div>

                    <!-- Recent Clock-ins -->
                    <div>
                        <h3 class="text-[11px] font-semibold uppercase tracking-wide text-gray-500 mb-1.5">Recent Clock-ins/Outs</h3>
                        <ul class="space-y-1.5 text-xs">
                            @forelse ($myStuff['clock_ins'] as $clockIn)
                                <li class="flex justify-between items-center gap-2 {{ $loop->last ? '' : 'border-b pb-1' }}">
                                    <span class="text-gray-700 min-w-0">
                                        {{ \Carbon\Carbon::parse($clockIn->record_date)->format('M j, Y') }}
                                        <span class="text-gray-400 text-[11px] block truncate">{{ $clockIn->employee_name }}</span>
                                    </span>
                                    <span class="text-gray-500 whitespace-nowrap">{{ $clockIn->earliest_time ?: '—' }} - {{ $clockIn->latest_time ?: '—' }}</span>
                                </li>
                            @empty
                                <li class="text-gray-400">No clock-ins in the active import.</li>
                            @endforelse
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
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 lg:flex-1 lg:min-h-0">
            <!-- Upcoming Holidays -->
            <div class="bg-white shadow rounded-lg border border-gray-200 flex flex-col min-h-0 h-72 lg:h-auto">
                <div class="px-4 py-2 border-b border-gray-200 flex items-center justify-between gap-2">
                    <h2 class="text-sm font-semibold text-gray-900 flex items-center gap-2 truncate">
                        <i class="fa-solid fa-calendar-days text-base" style="color: #8DE11A;"></i>
                        <span class="truncate">Upcoming Holidays</span>
                    </h2>
                    <button onclick="openCustomeDates();"
                        class="flex items-center px-2 py-0.5 bg-white text-green-600 font-semibold rounded-md border border-green-600 text-xs shrink-0">
                        <i class="fa-solid fa-plus mr-1"></i> Add
                    </button>
                </div>

                <div class="p-2 flex-1 min-h-0 overflow-hidden relative group flex flex-col">
                    <div class="marquee-vertical group-hover:[animation-play-state:paused] group-hover:overflow-y-auto">
                        <div class="marquee-content">
                        </div>
                    </div>
                </div>
            </div>

            <div class="bg-white shadow rounded-lg border border-gray-200 flex flex-col min-h-0 h-72 lg:h-auto">
                <div class="px-4 py-2 border-b border-gray-200 flex items-center justify-between gap-2">
                    <h2 class="text-sm font-semibold text-gray-900 flex items-center gap-2 truncate">
                        <i class="fa-solid fa-clock text-base" style="color: #8DE11A;"></i>
                        <span class="truncate">Overtime Requests</span>
                    </h2>
                </div>
                <div class="p-3 flex-1 min-h-0 relative">
                    <canvas id="overtimeStatusChart"></canvas>
                </div>
            </div>
            <div class="bg-white shadow rounded-lg border border-gray-200 flex flex-col min-h-0 h-72 lg:h-auto">
                <div class="px-4 py-2 border-b border-gray-200 flex items-center justify-between gap-2">
                    <h2 class="text-sm font-semibold text-gray-900 flex items-center gap-2 truncate">
                        <i class="fa-regular fa-calendar-check text-base" style="color: #8DE11A;"></i>
                        <span class="truncate">Certificates of Attendance</span>
                    </h2>
                </div>
                <div class="p-3 flex-1 min-h-0 relative">
                    <canvas id="certificateOfAttendanceChart"></canvas>
                </div>
            </div>
            <div class="bg-white shadow rounded-lg border border-gray-200 flex flex-col min-h-0 h-72 lg:h-auto">
                <div class="px-4 py-2 border-b border-gray-200 flex items-center justify-between gap-2">
                    <h2 class="text-sm font-semibold text-gray-900 flex items-center gap-2 truncate">
                        <i class="fa-solid fa-clock text-base" style="color: #8DE11A;"></i>
                        <span class="truncate">Schedule Adjustments</span>
                    </h2>
                </div>
                <div class="p-3 flex-1 min-h-0 relative">
                    <canvas id="scheduleAdjustmentStatusChart"></canvas>
                </div>
            </div>
            <div class="bg-white shadow rounded-lg border border-gray-200 flex flex-col min-h-0 h-72 lg:h-auto">
                <div class="px-4 py-2 border-b border-gray-200 flex items-center justify-between gap-2">
                    <h2 class="text-sm font-semibold text-gray-900 flex items-center gap-2 truncate">
                        <i class="fa-solid fa-plane-departure text-base" style="color: #8DE11A;"></i>
                        <span class="truncate">Leaves</span>
                    </h2>
                </div>
                <div class="p-3 flex-1 min-h-0 relative">
                    <canvas id="leaveStatusChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <div class="px-6">
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
                            <option value="Special Non-Working Holiday">Special Non-Working Holiday</option>
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
            Chart.defaults.font.size = 11;
            Chart.defaults.plugins.legend.labels.boxWidth = 10;
            Chart.defaults.plugins.legend.labels.padding = 8;

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
                    <div class="flex flex-col items-center justify-center h-full text-center text-gray-500">
                        <i class="fa-solid fa-chart-pie text-3xl mb-2 text-gray-400"></i>
                        <p class="text-sm font-semibold text-gray-600">No leave data available</p>
                        <p class="text-xs text-gray-400">Data will appear once records are submitted</p>
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
                                                size: 11
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
                <div class="flex flex-col items-center justify-center h-full text-center text-gray-500">
                    <i class="fa-solid fa-triangle-exclamation text-3xl mb-2 text-red-400"></i>
                    <p class="text-sm font-semibold text-gray-700">Failed to load data</p>
                    <p class="text-xs text-gray-400">Please try again later</p>
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
                    <div class="flex flex-col items-center justify-center h-full text-center text-gray-500">
                        <i class="fa-solid fa-calendar-xmark text-3xl mb-2 text-gray-400"></i>
                        <p class="text-sm font-semibold text-gray-600">No schedule adjustment data</p>
                        <p class="text-xs text-gray-400">Records will appear once adjustments are filed</p>
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
                                                size: 11
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
                <div class="flex flex-col items-center justify-center h-full text-center text-gray-500">
                    <i class="fa-solid fa-triangle-exclamation text-3xl mb-2 text-red-400"></i>
                    <p class="text-sm font-semibold text-gray-700">Failed to load schedule data</p>
                    <p class="text-xs text-gray-400">Please refresh or try again later</p>
                </div>
            `);
                    }
                });
            });
            document.addEventListener("DOMContentLoaded", function() {
                fetch("/certificate-attendance-summary")
                    .then(response => response.json())
                    .then(data => {
                        const canvas = document.getElementById("certificateOfAttendanceChart");
                        const chartContainer = canvas.parentElement;
                        const ctx = canvas.getContext("2d");

                        const hasData = data.data && data.data.some(value => value > 0);

                        // Show "No Data" UI
                        if (!hasData) {
                            chartContainer.innerHTML = `
                    <div class="flex flex-col items-center justify-center h-full text-center text-gray-500">
                        <i class="fa-solid fa-chart-pie text-3xl mb-2 text-gray-400"></i>
                        <p class="text-sm font-semibold text-gray-600">No certificate data available</p>
                        <p class="text-xs text-gray-400">Data will appear once records are submitted</p>
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
                                                size: 11
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
                        const chartContainer = document.getElementById("certificateOfAttendanceChart").parentElement;
                        chartContainer.innerHTML = `
                <div class="flex flex-col items-center justify-center h-full text-center text-gray-500">
                    <i class="fa-solid fa-triangle-exclamation text-3xl mb-2 text-red-400"></i>
                    <p class="text-sm font-semibold text-gray-700">Failed to load data</p>
                    <p class="text-xs text-gray-400">Please try again later</p>
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
                                                size: 11
                                            }
                                        }
                                    },
                                    datalabels: {
                                        color: '#fff',
                                        font: {
                                            weight: 'bold',
                                            size: 11
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
                    <div class="flex justify-between items-center gap-2 bg-white px-2 py-1.5 border-b border-[#8DE11A] mb-1">
                        <div>
                            <p class="text-xs text-gray-900 font-semibold">
                                ${new Date(item.record_date).toLocaleDateString('en-US', {
                                    month: 'short',
                                    day: '2-digit',
                                    year: 'numeric'
                                })}
                            </p>
                            <p class="text-xs text-gray-700">
                                ${item.title} — <span class="italic text-gray-600">${item.holiday_type}</span>
                            </p>
                        </div>
                        <div class="flex shrink-0 gap-1">
                            <button class="p-1 text-xs bg-white rounded hover:bg-gray-100 focus:outline-none">
                                <i class="fa-solid fa-pen"></i>
                            </button>
                            <button class="p-1 text-xs bg-white rounded hover:bg-gray-100 focus:outline-none">
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
                                loadCustomDates();
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
    </div>
</x-app-layout>

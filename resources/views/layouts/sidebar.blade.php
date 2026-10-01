@php
    $isAdmin = (Auth::user()->role ?? '') === 'admin';

    // [route name, label, Font Awesome icon]
    $navGroups = [
        'Main' => [
            ['dashboard', 'Dashboard', 'fa-solid fa-chart-line'],
            ['ot.approval', 'Overtime', 'fa-solid fa-business-time'],
            ['certificate.attendance', 'Certificates of Attendance', 'fa-solid fa-file-circle-check'],
            ['leave', 'Leaves', 'fa-solid fa-plane-departure'],
            ['schedule.adjustment', 'Schedule Adjustment', 'fa-solid fa-calendar-days'],
        ],
        'Records' => [
            ['attendance.record', 'Attendance Record', 'fa-solid fa-calendar-check'],
            ['employee.management', 'Employee Management', 'fa-solid fa-users'],
        ],
        'Reports' => [
            ['report.generation', 'Report Generation', 'fa-solid fa-file-lines'],
        ],
    ];

    if ($isAdmin) {
        $navGroups['Admin Management'] = [
            ['csv.import', 'Biometric Data Import', 'fa-solid fa-database'],
            ['biometric.data', 'Employee Data Import', 'fa-solid fa-users-gear'],
            ['organization.structure', 'Organization Structure', 'fa-solid fa-sitemap'],
            ['user.management', 'User Management', 'fa-solid fa-user-shield'],
            ['attendance.log', 'Audit Log', 'fa-solid fa-shield-halved'],
        ];
    }

    $currentLabel = 'Attendance System';
    foreach ($navGroups as $links) {
        foreach ($links as [$routeName, $label]) {
            if (request()->routeIs($routeName)) {
                $currentLabel = $label;
            }
        }
    }

    $loadedTitle = app('App\\Models\\BiometricHistoryList')->getLoadedRecord();
@endphp

<!-- Mobile overlay -->
<div x-cloak x-show="sidebarOpen" x-transition.opacity @click="sidebarOpen = false"
    class="fixed inset-0 z-30 bg-black/50 lg:hidden"></div>

<!-- Sidebar -->
<aside
    class="fixed inset-y-0 left-0 z-40 w-64 flex flex-col text-white transform transition-transform duration-200 ease-in-out"
    style="background-color: #00291B;"
    :class="sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'">

    <!-- Logo -->
    <div class="flex items-center justify-between h-16 px-5 border-b border-white/10">
        {{-- AttendanceSystemLogo.png is 1536x1024 with wide transparent padding; this window
             crops to the artwork (about x 340-1310, y 340-670) at 44px tall. --}}
        <a href="{{ route('dashboard') }}" class="relative block overflow-hidden" style="width: 134px; height: 48px;">
            <img src="{{ asset('image/AttendanceSystemLogo.png') }}" alt="Attendance System"
                class="absolute max-w-none" style="width: 203px; height: 135px; left: -43px; top: -43px;">
        </a>
        <button @click="sidebarOpen = false" class="lg:hidden text-white/70 hover:text-white text-xl"
            aria-label="Close menu">
            <i class="fa-solid fa-xmark"></i>
        </button>
    </div>

    <!-- Links -->
    <nav class="flex-1 overflow-y-auto px-3 py-4 space-y-6">
        @foreach ($navGroups as $group => $links)
            <div>
                <p class="px-3 mb-2 text-[11px] font-semibold uppercase tracking-wider text-white/50">{{ $group }}</p>
                <ul class="space-y-1">
                    @foreach ($links as [$routeName, $label, $icon])
                        @php $active = request()->routeIs($routeName); @endphp
                        <li>
                            <a href="{{ route($routeName) }}"
                                class="flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium border-l-4 transition duration-150 ease-in-out
                                    {{ $active ? 'bg-[#004d33] border-[#8DE11A] text-white' : 'border-transparent text-white/80 hover:bg-[#004d33] hover:text-white' }}"
                                @if ($active) aria-current="page" @endif>
                                <i class="{{ $icon }} w-5 text-center {{ $active ? 'text-[#8DE11A]' : '' }}"></i>
                                <span>{{ __($label) }}</span>
                            </a>
                        </li>
                    @endforeach
                </ul>
            </div>
        @endforeach
    </nav>

    <!-- User -->
    <div class="border-t border-white/10 px-3 py-4">
        <div class="px-3 mb-3">
            <p class="text-sm font-semibold truncate">{{ Auth::user()->name }}</p>
            <p class="text-xs text-white/60 capitalize">{{ $isAdmin ? 'Administrator' : 'Department Head' }}</p>
        </div>
        <a href="{{ route('profile.edit') }}"
            class="flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium border-l-4
                {{ request()->routeIs('profile.edit') ? 'bg-[#004d33] border-[#8DE11A] text-white' : 'border-transparent text-white/80 hover:bg-[#004d33] hover:text-white' }}">
            <i class="fa-solid fa-user w-5 text-center"></i>
            <span>{{ __('Profile') }}</span>
        </a>
        <form method="POST" action="{{ route('logout') }}">
            @csrf
            <button type="submit"
                class="w-full flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium border-l-4 border-transparent text-white/80 hover:bg-red-600/80 hover:text-white">
                <i class="fa-solid fa-right-from-bracket w-5 text-center"></i>
                <span>{{ __('Log Out') }}</span>
            </button>
        </form>
    </div>
</aside>

<!-- Mobile top bar -->
<div class="lg:hidden sticky top-0 z-20 flex items-center gap-3 h-14 px-4 text-white" style="background-color: #00291B;">
    <button @click="sidebarOpen = true" class="text-xl" aria-label="Open menu">
        <i class="fa-solid fa-bars"></i>
    </button>
    <span class="font-semibold truncate">{{ __($currentLabel) }}</span>
</div>

<!-- Loaded data banner -->
@if ($loadedTitle)
    <div class="bg-[#004d33] text-center py-2">
        <span class="text-sm text-gray-200">
            Loaded Data: <span class="font-semibold text-white">{{ $loadedTitle }}</span>
        </span>
    </div>
@endif

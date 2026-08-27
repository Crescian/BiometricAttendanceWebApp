<nav x-data="{ open: false }" style="background-color: #00291B;">
    <!-- Primary Navigation Menu -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
            <div class="flex">
                <!-- Logo -->
                <div class="shrink-0 flex items-center">
                    <a href="{{ route('dashboard') }}">
                        <x-application-logo class="block h-9 w-auto fill-current text-white" />
                    </a>
                </div>
            </div>

            <!-- Navigation Links -->
            <div class="hidden sm:flex space-x-6">
                <x-nav-link :href="route('dashboard')" :active="request()->routeIs('dashboard')"
                    class="text-white hover:text-white hover:bg-[#004d33] rounded-md px-3 text-sm font-medium transition duration-300 ease-in-out">
                    <i class="fa-solid fa-chart-line mr-2"></i> {{ __('Dashboard') }}
                </x-nav-link>

                <x-nav-link :href="route('ot.approval')" :active="request()->routeIs('ot.approval')"
                    class="text-white hover:text-white hover:bg-[#004d33] rounded-md px-3 text-sm font-medium transition duration-300 ease-in-out">
                    <i class="fa-solid fa-business-time mr-2"></i> {{ __('Overtime') }}
                </x-nav-link>

                <x-nav-link :href="route('certificate.attendance')" :active="request()->routeIs('certificate.attendance')"
                    class="text-white hover:text-white hover:bg-[#004d33] rounded-md px-3 text-sm font-medium transition duration-300 ease-in-out">
                    <i class="fa-solid fa-file-circle-check mr-2"></i> {{ __('Certificates of Attendance') }}
                </x-nav-link>

                <x-nav-link :href="route('leave')" :active="request()->routeIs('leave')"
                    class="text-white hover:text-white hover:bg-[#004d33] rounded-md px-3 text-sm font-medium transition duration-300 ease-in-out">
                    <i class="fas fa-plane-departure mr-2"></i> {{ __('Leaves') }}
                </x-nav-link>

                <x-nav-link :href="route('schedule.adjustment')" :active="request()->routeIs('schedule.adjustment')"
                    class="text-white hover:text-white hover:bg-[#004d33] rounded-md px-3 text-sm font-medium transition duration-300 ease-in-out">
                    <i class="fa-solid fa-calendar-days mr-2"></i> {{ __('Schedule Adjustment') }}
                </x-nav-link>
            </div>


            <!-- Navigation Links -->
            {{-- <div class="hidden space-x-8 sm:-my-px sm:ml-10 sm:flex">
                <x-nav-link :href="route('dashboard')" :active="request()->routeIs('dashboard')"
                    class="text-white hover:text-white hover:bg-[#004d33] rounded-md px-3 transition duration-300 ease-in-out">
                    {{ __('Dashboard') }}
                </x-nav-link>
            </div>

            <div class="hidden space-x-8 sm:-my-px sm:ml-10 sm:flex">
                <x-nav-link :href="route('ot.approval')" :active="request()->routeIs('ot.approval')"
                    class="text-white hover:text-white hover:bg-[#004d33] rounded-md px-3 transition duration-300 ease-in-out">
                    {{ __('Overtime') }}
                </x-nav-link>
            </div>

            <div class="hidden space-x-8 sm:-my-px sm:ml-10 sm:flex">
                <x-nav-link :href="route('certificate.attendance')" :active="request()->routeIs('certificate.attendance')"
                    class="text-white hover:text-white hover:bg-[#004d33] rounded-md px-3 transition duration-300 ease-in-out">
                    {{ __('Certificates of Attendance') }}
                </x-nav-link>
            </div>

            <div class="hidden space-x-8 sm:-my-px sm:ml-10 sm:flex">
                <x-nav-link :href="route('schedule.adjustment')" :active="request()->routeIs('schedule.adjustment')"
                    class="text-white hover:text-white hover:bg-[#004d33] rounded-md px-3 transition duration-300 ease-in-out">
                    {{ __('Schedule Adjustment') }}
                </x-nav-link>
            </div>

            <div class="hidden space-x-8 sm:-my-px sm:ml-10 sm:flex">
                <x-nav-link :href="route('employee.management')" :active="request()->routeIs('employee.management')"
                    class="text-white hover:text-white hover:bg-[#004d33] rounded-md px-3 transition duration-300 ease-in-out">
                    {{ __('Employee Management') }}
                </x-nav-link>
            </div> --}}
            <!-- Settings Dropdown -->
            <div class="hidden sm:flex sm:items-center sm:ml-6">
                <x-dropdown align="right" width="100">
                    <x-slot name="trigger">
                        <button
                            class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-[#00291B] hover:text-white focus:outline-none transition ease-in-out duration-150">
                            <div>{{ Auth::user()->name }}</div>

                            <div class="ml-1">
                                <svg class="fill-current h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg"
                                    viewBox="0 0 20 20">
                                    <path fill-rule="evenodd"
                                        d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                                        clip-rule="evenodd" />
                                </svg>
                            </div>
                        </button>
                    </x-slot>

                    @php
                        $userRole = Auth::user()->role;
                    @endphp

                    <x-slot name="content">
                        <div class="w-[15rem]">
                            {{-- PERSONAL ACCESS --}}
                            <x-dropdown-link :href="route('profile.edit')"
                                class="text-black hover:text-green-700 flex items-center gap-2">
                                <i class="fas fa-user text-gray-600 w-4"></i>
                                {{ __('Profile') }}
                            </x-dropdown-link>

                            {{-- DAILY OPERATIONS --}}
                            <x-dropdown-link :href="route('attendance.record')"
                                class="text-black hover:text-green-700 flex items-center gap-2">
                                <i class="fas fa-calendar-check text-gray-600 w-4"></i>
                                {{ __('Attendance Record') }}
                            </x-dropdown-link>

                            <x-dropdown-link :href="route('employee.management')"
                                class="text-black hover:text-green-700 flex items-center gap-2">
                                <i class="fa-solid fa-users text-gray-600 w-4"></i>
                                {{ __('Employee Management') }}
                            </x-dropdown-link>

                            {{-- ADMIN TOOLS --}}
                            @if ($userRole === 'admin')
                                <div class="border-t border-gray-200 my-1"></div>
                                <span class="block px-4 py-2 text-xs text-gray-500 uppercase">Admin Management</span>

                                <x-dropdown-link :href="route('csv.import')"
                                    class="text-black hover:text-green-700 flex items-center gap-2">
                                    <i class="fas fa-database text-gray-600 w-4"></i>
                                    {{ __('Biometric Data Import') }}
                                </x-dropdown-link>

                                <x-dropdown-link :href="route('biometric.data')"
                                    class="text-black hover:text-green-700 flex items-center gap-2">
                                    <i class="fas fa-users-cog text-gray-600 w-4"></i>
                                    {{ __('Employee Data Import') }}
                                </x-dropdown-link>

                                <x-dropdown-link :href="route('organization.structure')"
                                    class="text-black hover:text-green-700 flex items-center gap-2">
                                    <i class="fas fa-sitemap text-gray-600 w-4"></i>
                                    {{ __('Organization Structure') }}
                                </x-dropdown-link>

                                <x-dropdown-link :href="route('attendance.log')"
                                    class="text-black hover:text-green-700 flex items-center gap-2">
                                    <i class="fas fa-clipboard-list text-gray-600 w-4"></i>
                                    {{ __('User Log') }}
                                </x-dropdown-link>
                            @endif

                            {{-- REPORTS --}}
                            <div class="border-t border-gray-200 my-1"></div>
                            <x-dropdown-link :href="route('report.generation')"
                                class="text-black hover:text-green-700 flex items-center gap-2">
                                <i class="fas fa-file-alt text-gray-600 w-4"></i>
                                {{ __('Report Generation') }}
                            </x-dropdown-link>

                            {{-- LOGOUT --}}
                            <div class="border-t border-gray-200 my-1"></div>
                            <form method="POST" action="{{ route('logout') }}">
                                @csrf
                                <x-dropdown-link :href="route('logout')"
                                    class="text-black hover:text-red-600 flex items-center gap-2"
                                    onclick="event.preventDefault(); this.closest('form').submit();">
                                    <i class="fas fa-sign-out-alt text-gray-600 w-4"></i>
                                    {{ __('Log Out') }}
                                </x-dropdown-link>
                            </form>
                        </div>
                    </x-slot>
                </x-dropdown>
            </div>


            <!-- Hamburger -->
            <div class="-mr-2 flex items-center sm:hidden">
                <button @click="open = ! open"
                    class="inline-flex items-center justify-center p-2 rounded-md text-white hover:text-white hover:bg-gray-700 focus:outline-none focus:bg-gray-700 focus:text-white transition duration-150 ease-in-out">
                    <svg class="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
                        <path :class="{ 'hidden': open, 'inline-flex': !open }" class="inline-flex"
                            stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M4 6h16M4 12h16M4 18h16" />
                        <path :class="{ 'hidden': !open, 'inline-flex': open }" class="hidden" stroke-linecap="round"
                            stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </div>
    </div>


    <!-- Responsive Navigation Menu -->
    <div :class="{ 'block': open, 'hidden': !open }" class="hidden sm:hidden">
        <div class="pt-2 pb-3 space-y-1">
            <x-responsive-nav-link :href="route('dashboard')" :active="request()->routeIs('dashboard')" class="text-black hover:text-black">
                {{ __('Dashboard') }}
            </x-responsive-nav-link>
        </div>

        <!-- Responsive Settings Options -->
        <div class="pt-4 pb-1 border-t border-gray-200">
            <div class="px-4">
                <div class="font-medium text-base text-black">{{ Auth::user()->name }}</div>
                <div class="font-medium text-sm text-black">{{ Auth::user()->email }}</div>
            </div>

            <div class="mt-3 space-y-1" style="color: black">
                <x-responsive-nav-link :href="route('profile.edit')" class="text-black hover:text-black">
                    {{ __('Profile') }}
                </x-responsive-nav-link>
                @if ($userRole === 'admin')
                    <x-responsive-nav-link :href="route('organization.structure')" class="text-black hover:text-black">
                        {{ __('Organization Structure') }}
                    </x-responsive-nav-link>

                    <x-responsive-nav-link :href="route('biometric.data')" class="text-black hover:text-black">
                        {{ __('Employee Data Import') }}
                    </x-responsive-nav-link>

                    <x-responsive-nav-link :href="route('csv.import')" class="text-black hover:text-black">
                        {{ __('Biometric Data Import') }}
                    </x-responsive-nav-link>

                    <x-responsive-nav-link :href="route('report.generation')" class="text-black hover:text-black">
                        {{ __('Report Generation') }}
                    </x-responsive-nav-link>

                    <x-responsive-nav-link :href="route('attendance.log')" class="text-black hover:text-black">
                        {{ __('User Log') }}
                    </x-responsive-nav-link>

                    <x-responsive-nav-link :href="route('attendance.record')" class="text-black hover:text-black">
                        {{ __('Attendance Record') }}
                    </x-responsive-nav-link>

                    <x-responsive-nav-link :href="route('leave')" class="text-black hover:text-black">
                        {{ __('Leaves') }}
                    </x-responsive-nav-link>
                @endif
                <!-- Authentication -->
                <form method="POST" action="{{ route('logout') }}">
                    @csrf
                    <x-responsive-nav-link :href="route('logout')" class="text-black hover:text-black"
                        onclick="event.preventDefault();
                                    this.closest('form').submit();">
                        {{ __('Log Out') }}
                    </x-responsive-nav-link>
                </form>
            </div>
        </div>
    </div>

</nav>
@php
    $loadedTitle = app('App\\Models\\BiometricHistoryList')->getLoadedRecord();
@endphp
<!-- ✅ Loaded Data Section (Placed at the End) -->

@if ($loadedTitle)
    <div class="bg-[#004d33] text-center py-2">
        <span class="text-sm text-gray-200">
            Loaded Data: <span class="font-semibold text-white">{{ $loadedTitle }}</span>
        </span>
    </div>
@endif

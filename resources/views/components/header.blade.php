
<div class="flex flex-wrap items-center justify-between space-y-4 md:space-y-0 md:flex-nowrap">
    <a href="{{ route('dashboard') }}" class="font-semibold text-xl text-gray-800 leading-tight transition duration-300 ease-in-out transform hover:scale-105 hover:text-orange-600">
        {{ __('Dashboard') }}
    </a>
    <a href="{{ route('employee.management') }}" class="font-semibold text-xl text-gray-800 leading-tight transition duration-300 ease-in-out transform hover:scale-105 hover:text-orange-600">
        {{ __('Employee Management') }}
    </a>
    {{-- <a href="{{ route('attendance.tracking') }}" class="font-semibold text-xl text-gray-800 leading-tight transition duration-300 ease-in-out transform hover:scale-105 hover:text-orange-600">
        {{ __('Attendance Tracking') }}
    </a> --}}
    <a href="{{ route('report.generation') }}" class="font-semibold text-xl text-gray-800 leading-tight transition duration-300 ease-in-out transform hover:scale-105 hover:text-orange-600">
        {{ __('Report Generation') }}
    </a>
    <a href="{{ route('csv.import') }}" class="font-semibold text-xl text-gray-800 leading-tight transition duration-300 ease-in-out transform hover:scale-105 hover:text-orange-600">
        {{ __('CSV Import') }}
    </a>
</div>

{{--
    Filter bar for a list page: From / To dates, Department, optional Schedule, any extra controls
    in the slot, and Clear. Every control with a data-filter attribute is sent with the table's
    requests; wire it up with initTableFilters() from the approval-table-assets component.

    Usage: the table-filters component with prefix="lv" (and the schedule attribute to add the
    Schedule dropdown); put extra selects with a data-filter attribute inside it.
--}}
@props(['prefix', 'schedule' => false])

@php
    $control = 'px-2 py-1.5 text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500';
@endphp

<div id="{{ $prefix }}-filters" class="flex flex-wrap items-center gap-2 px-3 pt-2 text-xs text-gray-600">
    <i class="fa-solid fa-filter text-gray-400"></i>
    <label class="flex items-center gap-1">From
        <input id="{{ $prefix }}-filter-from" type="date" data-filter="date_from" class="{{ $control }}">
    </label>
    <label class="flex items-center gap-1">To
        <input id="{{ $prefix }}-filter-to" type="date" data-filter="date_to" class="{{ $control }}">
    </label>
    <select id="{{ $prefix }}-filter-department" data-filter="filter_department" class="{{ $control }} hidden" aria-label="Department">
        <option value="">All departments</option>
    </select>
    @if ($schedule)
        <select id="{{ $prefix }}-filter-schedule" data-filter="filter_schedule" class="w-40 {{ $control }} hidden" aria-label="Schedule">
            <option value="">All schedules</option>
        </select>
    @endif
    {{ $slot }}
    <button id="{{ $prefix }}-filter-clear" type="button"
        class="px-2 py-1.5 text-xs text-gray-700 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200">
        Clear
    </button>
</div>

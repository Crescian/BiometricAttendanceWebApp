<?php

namespace App\Http\Controllers\Concerns;

use App\Models\Department;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

/**
 * Filter bar of the list pages (Overtime, Attendance Record, Leave, Certificates of Attendance,
 * Schedule Adjustments): date range, department and schedule, plus the choices for its dropdowns.
 *
 * Who sees which rows is decided here, not from the role/department the page sends: a non-admin
 * only sees the departments they head (the same rule as bulk approve), so the department filter
 * can only narrow that down.
 */
trait FiltersTables
{
    /** Limit a non-admin to the departments they head. */
    protected function restrictToHeadedDepartments($query, string $departmentColumn)
    {
        if ((Auth::user()->role ?? '') !== 'admin') {
            $query->whereIn($departmentColumn, Department::where('department_head', Auth::id())->pluck('department_name'));
        }

        return $query;
    }

    /**
     * Apply the filter bar's date_from / date_to / filter_department / filter_schedule (all optional).
     * Pass null as $scheduleColumn for a page without a schedule filter.
     */
    protected function applyTableFilters($query, Request $request, string $dateColumn, string $departmentColumn, ?string $scheduleColumn = null)
    {
        $request->validate([
            'date_from' => ['nullable', 'date'],
            'date_to' => ['nullable', 'date'],
            'filter_department' => ['nullable', 'string', 'max:100'],
            'filter_schedule' => ['nullable', 'string', 'max:100'],
        ]);

        if ($request->filled('date_from')) {
            $query->whereRaw("{$dateColumn}::date >= ?", [$request->date_from]);
        }
        if ($request->filled('date_to')) {
            $query->whereRaw("{$dateColumn}::date <= ?", [$request->date_to]);
        }
        if ($request->filled('filter_department')) {
            $query->where($departmentColumn, $request->filter_department);
        }
        if ($scheduleColumn && $request->filled('filter_schedule')) {
            $query->where($scheduleColumn, $request->filter_schedule);
        }

        return $query;
    }

    /**
     * Dropdown choices for the filter bar from the page's rows ($scope returns a fresh query of the
     * rows the user may see): departments, schedules (by start hour) and the date range.
     */
    protected function tableFilterOptions(callable $scope, string $dateColumn, string $departmentColumn, ?string $scheduleColumn = null): array
    {
        $distinct = fn (string $column) => $scope()->whereNotNull($column)->where($column, '<>', '')
            ->distinct()->orderBy($column)->pluck($column)->values();

        $range = $scope()->selectRaw("MIN({$dateColumn})::date AS min_date, MAX({$dateColumn})::date AS max_date")->first();

        return [
            'departments' => $distinct($departmentColumn),
            // By start hour, then end hour ("6-15" before "7-16" before "20-5")
            'schedules' => $scheduleColumn
                ? $distinct($scheduleColumn)->sortBy(fn ($s) => array_map('intval', explode('-', $s) + [0, 0]))->values()
                : [],
            'min_date' => $range->min_date ?? null,
            'max_date' => $range->max_date ?? null,
        ];
    }
}

<?php

namespace App\Http\Controllers\Concerns;

use App\Services\AuditLogger;
use App\Models\Department;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

/**
 * "Approve selected" and "Bulk approve" (all / by department / employee / date) for an approval
 * table whose rows link to employee_management through employee_management_id — the same
 * endpoints OvertimeController has, for Leaves, Certificates of Attendance and Schedule Adjustments.
 *
 * The using controller has a $biometricHistoryList and says which table/columns to use and how
 * to approve a batch of pending ids.
 */
trait BulkApprovesRecords
{
    /** Table name, e.g. 'leaves'. */
    abstract protected function bulkTable(): string;

    /** Eloquent model class of bulkTable(). */
    abstract protected function bulkModel(): string;

    /** Status column, e.g. 'status' or 'approval_status'. */
    abstract protected function bulkStatusColumn(): string;

    /** Status value of a pending row, e.g. 'pending' or 'Pending'. */
    abstract protected function bulkPendingValue(): string;

    /** Date column used by "Bulk approve by date". */
    abstract protected function bulkDateColumn(): string;

    /** "1 leave request" / "3 leave requests". */
    abstract protected function bulkRecords(int $count): string;

    /** Approve the given pending ids; returns how many were approved. */
    abstract protected function approvePendingRecords(Collection $ids): int;

    /**
     * Pending rows of the loaded import that the current user may approve —
     * the same rows the page's Pending tab lists. A department head only sees
     * the departments they head.
     */
    protected function pendingScope()
    {
        $table = $this->bulkTable();
        $model = $this->bulkModel();

        $query = $model::query()
            ->join('employee_management', 'employee_management.id', '=', "{$table}.employee_management_id")
            ->where("{$table}.{$this->bulkStatusColumn()}", $this->bulkPendingValue())
            ->when($this->biometricHistoryList->getLoadedRecordId(),
                fn ($q, $biometricImportId) => $q->where("{$table}.biometric_imports_id", $biometricImportId));

        if ((Auth::user()->role ?? '') !== 'admin') {
            $query->whereIn('employee_management.department',
                Department::where('department_head', Auth::id())->pluck('department_name'));
        }

        return $query;
    }

    /**
     * Approve several pending rows at once ("Approve selected").
     */
    public function bulkApprove(Request $request)
    {
        $validated = $request->validate([
            'ids'   => ['required', 'array', 'min:1', 'max:500'],
            'ids.*' => ['integer'],
        ]);
        $ids = array_values(array_unique($validated['ids']));

        $pendingIds = $this->pendingScope()
            ->whereIn("{$this->bulkTable()}.id", $ids)
            ->pluck("{$this->bulkTable()}.id");

        $approved = $this->approvePendingRecords($pendingIds);
        $this->auditBulkApproval($approved, $pendingIds, ['mode' => 'selected', 'requested_ids' => $ids]);

        return $this->bulkApprovedResponse($approved, count($ids));
    }

    /**
     * Choices for "Bulk approve": pending counts per department, per employee and per date.
     */
    public function bulkOptions()
    {
        $date = "{$this->bulkTable()}.{$this->bulkDateColumn()}";

        $departments = $this->pendingScope()
            ->select('employee_management.department as value', DB::raw('COUNT(*) as count'))
            ->groupBy('employee_management.department')
            ->orderBy('employee_management.department')
            ->get();

        $employees = $this->pendingScope()
            ->select('employee_management.employee_name as value', 'employee_management.department', DB::raw('COUNT(*) as count'))
            ->groupBy('employee_management.employee_name', 'employee_management.department')
            ->orderBy('employee_management.employee_name')
            ->get();

        $dates = $this->pendingScope()
            ->select(DB::raw("TO_CHAR({$date}, 'YYYY-MM-DD') as value"), DB::raw('COUNT(*) as count'))
            ->groupBy(DB::raw("TO_CHAR({$date}, 'YYYY-MM-DD')"))
            ->orderBy('value')
            ->get();

        return response()->json([
            'success'     => true,
            'total'       => $this->pendingScope()->count(),
            'departments' => $departments,
            'employees'   => $employees,
            'dates'       => $dates,
        ]);
    }

    /**
     * Approve every pending row of one department, one employee or one date, or all of them.
     */
    public function bulkApproveBy(Request $request)
    {
        $validated = $request->validate([
            'by'    => ['required', 'in:all,department,employee,date'],
            'value' => ['required_unless:by,all', 'nullable', 'string', 'max:255'],
        ]);
        if ($validated['by'] === 'date') {
            $request->validate(['value' => ['date_format:Y-m-d']]);
        }

        $query = $this->pendingScope();
        match ($validated['by']) {
            'all'        => null,
            'department' => $query->where('employee_management.department', $validated['value']),
            'employee'   => $query->where('employee_management.employee_name', $validated['value']),
            'date'       => $query->whereDate("{$this->bulkTable()}.{$this->bulkDateColumn()}", $validated['value']),
        };
        $pendingIds = $query->pluck("{$this->bulkTable()}.id");

        $approved = $this->approvePendingRecords($pendingIds);
        $this->auditBulkApproval($approved, $pendingIds, ['mode' => $validated['by'], 'value' => $validated['value'] ?? null]);

        return $this->bulkApprovedResponse($approved, $pendingIds->count());
    }

    /** One summary entry per bulk action (each record also gets its own entry where Eloquent saves it). */
    protected function auditBulkApproval(int $approved, Collection $pendingIds, array $filter): void
    {
        $prefix = ['leaves' => 'leave', 'certificate_attendance' => 'certificate', 'schedule_adjustments' => 'schedule_adjustment'][$this->bulkTable()] ?? $this->bulkTable();
        $by = $filter['mode'] === 'selected' ? 'selected rows' : $filter['mode'].($filter['mode'] !== 'all' ? ' "'.$filter['value'].'"' : '');

        AuditLogger::record("{$prefix}.bulk_approved", [
            'category' => 'approval',
            'action' => 'approve',
            'outcome' => $approved > 0 ? 'success' : 'failure',
            'description' => 'Bulk approved '.$this->bulkRecords($approved)." by {$by}",
            'old' => [$this->bulkStatusColumn() => $this->bulkPendingValue()],
            'new' => [$this->bulkStatusColumn() => $this->bulkPendingValue() === 'pending' ? 'approved' : 'Approved'],
            'metadata' => $filter + ['attempted_ids' => $pendingIds->values()->all(), 'approved' => $approved, 'skipped' => $pendingIds->count() - $approved],
        ]);
    }

    protected function bulkApprovedResponse(int $approved, int $requested)
    {
        $skipped = $requested - $approved;

        if ($requested === 0) {
            $message = 'There was nothing pending to approve for this choice.';
        } else {
            $message = $this->bulkRecords($approved) . ' approved.'
                . ($skipped > 0 ? " {$skipped} skipped (no longer pending, outside your departments, or could not be processed)." : '');
        }

        return response()->json([
            'success'  => true,
            'approved' => $approved,
            'skipped'  => $skipped,
            'message'  => $message,
        ]);
    }
}

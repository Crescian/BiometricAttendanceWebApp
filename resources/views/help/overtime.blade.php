<h3>What this page is for</h3>
<p>
    Review and approve the overtime (OT), night differential (ND) and rest-day hours of the
    <b>loaded</b> biometric import (shown in the green "Loaded Data" bar at the top). Only
    <b>approved</b> hours are paid in the payroll report.
</p>
<p>
    Department heads see only the departments they head. Admins see every department.
</p>

<h3>Where the hours come from</h3>
<ul>
    <li>Hours are calculated automatically when the biometric file is uploaded, from each employee's
        <b>schedule</b> and their first and last punch of the day.</li>
    <li>OT starts after the regular day (8 hours plus a 1-hour break from the schedule start) and only
        counts once it reaches <b>1 hour</b>. Above that, every minute counts (e.g. 1:48).</li>
    <li>Arriving early does not add OT. Arriving more than 15 minutes late moves the start of the
        regular day.</li>
    <li>ND covers hours between 10:00 PM and 6:00 AM. Rest-day and holiday hours (RD columns) apply
        to dates set as holidays or rest days.</li>
</ul>

<h3>Daily workflow</h3>
<ol>
    <li>Stay on the <b>Pending</b> tab. It lists what still needs a decision.</li>
    <li>Narrow the list with the filter bar if you like: <b>From / To</b> dates, <b>Department</b>,
        <b>Schedule</b>, <b>OT type</b>, or the <b>Search</b> box (name, ID or department; a pasted
        "LAST, FIRST" name works).</li>
    <li>Check each row's <b>Earliest Time</b> and <b>Latest Time</b> against the hours shown.</li>
    <li>Approve, correct or cancel each row (see "Row buttons" below), or approve many at once
        (see "Approving many rows").</li>
    <li>Approved rows move to the <b>Approved</b> tab, cancelled ones to <b>Rejected / Cancelled</b>.</li>
</ol>

<h3>"With hours only"</h3>
<p>
    Ticked by default. It hides days where every hour column is 00:00, because there is nothing to
    approve. Untick it to see every attendance day, for example to check who was late. The tab
    counts and <b>Bulk approve</b> follow this setting. Hidden rows are not deleted.
</p>

<h3>Row buttons</h3>
<ul>
    <li><span class="help-btn"><i class="fas fa-check"></i> Approve</span> marks the row Approved, so it is paid.</li>
    <li><span class="help-btn"><i class="fas fa-pen"></i> Edit time</span> corrects the Earliest / Latest
        Time (for example a missed punch).
        <ul>
            <li><b>Set Original Schedule</b> fills in the schedule's start and end times.</li>
            <li><b>Save &amp; Approved</b> saves the times and <b>recalculates the hours</b>. The row
                stays <b>Pending</b>, so click <b>Approve</b> afterwards.</li>
        </ul>
    </li>
    <li><span class="help-btn"><i class="fas fa-xmark"></i> Cancel</span> rejects the row (also available on
        Approved rows, to take an approval back).</li>
</ul>

<h3>Approving many rows</h3>
<ul>
    <li><b>Approve selected:</b> tick the checkboxes of the rows (or the header checkbox for the whole
        page), then click <b>Approve selected</b>.</li>
    <li><b>Bulk approve:</b> approve everything pending, or everything for one <b>department</b>,
        <b>employee</b> or <b>date</b>. The window shows how many rows each choice covers before you confirm.</li>
</ul>

<h3>Sorting, columns and export</h3>
<ul>
    <li>Click the <b>Employee</b> or <b>Date</b> header to sort. The list opens sorted by date.</li>
    <li><b>Columns</b> shows or hides table columns. <b>Export</b> copies the table or saves it as Excel, CSV or PDF, or prints it.</li>
</ul>

<div class="help-warn">
    <b>Changed an employee's schedule?</b> Rows that already exist keep the hours calculated with the old
    schedule. For one or a few days, use <b>Schedule Adjustment</b> (approving it recalculates those
    days). For a permanent change, see the Employee Management help.
</div>
<div class="help-tip">
    <b>Tip:</b> approve overtime <b>before</b> generating the payroll report. Pending rows are not paid.
</div>

<h3>What this page is for</h3>
<p>
    Produce the payroll file and the Daily Time Record (DTR) for a payroll period. The report includes
    attendance from <b>every</b> biometric upload whose dates fall inside the period.
</p>

<h3>Before you generate</h3>
<ol>
    <li>Upload the biometric file(s) for the whole period (<b>Biometric Data Import</b>).</li>
    <li>Approve <b>Certificates of Attendance</b> and <b>Schedule Adjustments</b> for the period.</li>
    <li>Approve the <b>Overtime</b>. Only <b>approved</b> OT, ND-OT and rest-day / holiday hours are paid.
        Pending rows are left out.</li>
    <li>Make sure holidays are set (Dashboard, Upcoming Holidays) and employee details are up to date.</li>
</ol>

<h3>Generate the report</h3>
<ol>
    <li>Click <b>Start Report Generation</b>.</li>
    <li>Check <b>Payroll From</b> and <b>Payroll To</b>. They start at the loaded import's payroll period.
        Change them if you need a different range.</li>
    <li>Wait for the checklist (Overtime, Certificate of Attendance, Schedule Adjustment, Leaves) to
        finish. Then click <b>Generate Report</b>.</li>
    <li>If some dates in the period have no attendance at all, a warning lists them. That usually means
        an upload is missing. Click <b>Continue to download</b> to go ahead anyway.</li>
</ol>

<h3>What you get</h3>
<ul>
    <li><span class="help-admin">Admin</span> the <b>payroll file</b>, the <b>DTR</b> (reportdtr.xlsx) and a CSV of
        the payroll rows.</li>
    <li>The security account gets the <b>security guards' report</b> (if the period has security attendance).</li>
    <li>Other users don't receive files.</li>
</ul>

<h3>How the numbers are worked out</h3>
<ul>
    <li><b>Hours Worked</b> holds regular hours only: 8 per working day (less late beyond the 15-minute grace
        and any undertime). Overtime is not included here.</li>
    <li><b>OT, ND-OT, rest-day and holiday</b> columns come from the <b>approved</b> overtime figures.</li>
    <li>Holidays are classified from the holiday list: Regular / Legal Holiday, Special Non-Working
        Holiday, or Rest Day (Sundays).</li>
</ul>

<div class="help-tip">
    <b>Re-running</b> the report for the same period replaces that period's earlier payroll rows. So
    after approving more overtime, just generate again.
</div>

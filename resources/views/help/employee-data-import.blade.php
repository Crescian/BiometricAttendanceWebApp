<h3>What this page is for</h3>
<p>Load the employee master list from a CSV file in one go, instead of adding employees one by one.</p>

<div class="help-warn">
    <b>This replaces the entire employee list.</b> Every current employee is removed before the file's
    rows are added. Employees with attendance or other records can't be removed, so the upload may
    stop with an error. Use <b>Employee Management</b> (Add / Edit) for day-to-day changes, and talk to
    IT before using this page.
</div>

<h3>File format</h3>
<p>A <b>.csv</b> file whose first row is a header, followed by one row per employee with these columns, in this order:</p>
<ol>
    <li><b>Unique ID</b> (required; rows without one are skipped)</li>
    <li><b>Employee name</b> as <b>LAST, FIRST</b>, exactly as on the biometric device</li>
    <li><b>Basic salary</b></li>
    <li><b>Schedule</b> in whole hours, e.g. 7-16 or 19-7</li>
    <li><b>Report to</b> (supervisor)</li>
    <li><b>Department</b> (saved in capitals)</li>
    <li><b>Status</b></li>
</ol>

<h3>Upload</h3>
<ol>
    <li>Under <b>Upload CSV</b>, choose the file and click <b>Import</b>.</li>
    <li>Large files (8,000 to 10,000 rows) may take a while.</li>
</ol>

<h3>Export</h3>
<p>
    <b>Export Database to CSV</b> refreshes the system's own employee CSV copy from the database. It
    doesn't download a file to your computer.
</p>

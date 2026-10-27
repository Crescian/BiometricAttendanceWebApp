<h3>What this page is for</h3>
<p>
    Upload the attendance file exported from the biometric device. Each upload becomes an <b>import</b>.
    The <b>loaded</b> import is the one the Overtime, Leaves, Certificates, Schedule Adjustment, Attendance
    Record and Dashboard pages work on. Its title shows in the green "Loaded Data" bar.
</p>

<h3>Before you upload</h3>
<ul>
    <li>Employees and their <b>schedules</b> are up to date (Employee Management). Names must match the device.</li>
    <li><b>Holidays</b> for the period are set (Dashboard, Holidays card).</li>
</ul>
<p>Overtime is calculated during the upload, from these settings.</p>

<h3>Upload a file</h3>
<ol>
    <li>Click <span class="help-btn"><i class="fa-solid fa-file-import"></i> Import Now</span>.</li>
    <li>Check <b>Import By</b> and give it an <b>Import Title</b> that describes the payroll dates, e.g.
        "Biometric data for Sep 20 to Sep 25, 2026".</li>
    <li>Leave <b>Payroll Period Start / End</b> blank to use the first and last punch date in the file, or
        set them. Manual attendance entries must fall inside this period.</li>
    <li>Choose the device's <b>.csv</b> file. <b>Total Rows</b> fills in by itself.</li>
    <li>Click <b>Import Now</b> and wait. Large files take a few seconds.</li>
</ol>
<p>
    The new import becomes the <b>loaded</b> one. A day an employee already has from an earlier upload is
    skipped, so uploading overlapping files doesn't create duplicates.
</p>

<h3>The import list</h3>
<ul>
    <li><b>Load / Unload</b>: choose which import the other pages work on. Only one can be loaded.</li>
    <li><span class="help-btn"><i class="fas fa-pen"></i> Edit</span>: change the <b>title</b> or <b>payroll period</b>.
        The attendance itself can't be edited here.</li>
    <li><span class="help-btn"><i class="fas fa-trash"></i> Delete</span>: type the title to confirm. The
        window first shows exactly what happens:
        <ul>
            <li>Days inside <b>another</b> import's payroll period are <b>moved</b> to that import, not deleted.</li>
            <li>Other days are <b>deleted</b> with their overtime.</li>
            <li>Leaves, certificates, schedule adjustments and generated payroll rows are <b>kept</b>.</li>
        </ul>
    </li>
    <li>A <b>locked</b> import (already paid) can't be edited or deleted.</li>
</ul>

<div class="help-tip">
    <b>Need to redo an upload?</b> If nothing in it has been approved yet, delete it and upload the file
    again, for example after correcting schedules. Once overtime is approved, use Schedule Adjustments
    or time corrections instead.
</div>

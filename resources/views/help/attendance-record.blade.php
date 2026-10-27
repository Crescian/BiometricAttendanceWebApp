<h3>What this page is for</h3>
<p>
    Every employee's daily time in and time out for the <b>loaded</b> biometric import (green "Loaded
    Data" bar): their first punch (<b>Earliest Time</b>) and last punch (<b>Latest Time</b>) of each day.
    Department heads see their own departments. Admins see all.
</p>
<ul>
    <li>A <b>COA</b> badge means the day came from an approved Certificate of Attendance.</li>
    <li>A <b>MANUAL</b> badge means an admin entered or edited the time on this page.</li>
    <li>A night shift that ends after midnight is stored on the day it started.</li>
</ul>

<h3>Finding records</h3>
<p>
    Use the filter bar (<b>From / To</b>, <b>Department</b>), the <b>Search</b> box, and the <b>Employee</b> /
    <b>Date</b> headers to sort. The list opens with the newest dates first.
</p>

<h3>Add a missing day <span class="help-admin">Admin</span></h3>
<ol>
    <li>Click <span class="help-btn"><i class="fa-solid fa-clock"></i> Add Time In / Out</span>.</li>
    <li>Choose the <b>Employee Name</b> and the <b>Record Date</b>. The date must fall inside the loaded
        import's payroll period.</li>
    <li>Enter <b>Time In</b> and <b>Time Out</b>. A Time Out earlier than Time In is treated as an overnight
        shift ending the next day.</li>
    <li>Click <b>Save</b>. The day's overtime is calculated and appears as <b>Pending</b> on the Overtime page.</li>
</ol>

<h3>Correct a time <span class="help-admin">Admin</span></h3>
<ol>
    <li>Click <span class="help-btn"><i class="fas fa-pen"></i></span> (Edit time in / out) on the row.</li>
    <li>Change the times and save. The day's overtime is recalculated. The original punches are kept
        for reference, and the change is recorded in the Audit Log.</li>
</ol>

<div class="help-warn">
    You can't add or edit times when no import is loaded, when the loaded import is locked, or when
    it has no payroll period. Set the period on <b>Biometric Data Import</b> (Edit).
</div>
<div class="help-tip">
    <b>Forgot to punch?</b> Department heads can file a <b>Certificate of Attendance</b> instead. It goes
    through approval. Use this page for corrections HR makes directly.
</div>

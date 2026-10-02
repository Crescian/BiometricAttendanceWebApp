<h3>What this page is for</h3>
<p>
    The employee master list: each employee's ID, name, department, supervisor, work schedule, basic
    salary and status. Biometric files are matched to employees by <b>name</b>, so names here must
    match the biometric device exactly.
</p>

<h3>Add an employee</h3>
<ol>
    <li>Click <span class="help-btn"><i class="fa-solid fa-plus"></i> Add</span>.</li>
    <li>Enter the <b>Unique ID</b>, <b>First Name</b> and <b>Last Name</b>. The name is saved as
        <b>LAST, FIRST</b> in capital letters, the format the biometric file uses.</li>
    <li>Choose the <b>Department</b> and enter the <b>Immediate Supervisor</b>.</li>
    <li>Set the <b>Work Schedule</b> start and end in whole hours, e.g. 7:00 to 16:00 (7-16). An end earlier
        than the start is an overnight shift, e.g. 19:00 to 07:00 (19-7).</li>
    <li>Enter the <b>Basic Salary</b> and <b>Status</b>, then save.</li>
</ol>

<h3>Edit or delete</h3>
<ul>
    <li><span class="help-btn"><i class="fas fa-pen"></i> Edit</span> opens the same form. The First / Last
        Name boxes show the name's two parts, and saving keeps the LAST, FIRST format.</li>
    <li><span class="help-btn"><i class="fas fa-trash"></i> Delete</span> removes the employee after you
        confirm. You can't delete an employee who already has attendance or other records.</li>
</ul>

<h3>Finding employees</h3>
<p>Use the <b>Search</b> box, and the <b>ID</b> or <b>Employee</b> headers to sort.</p>

<div class="help-warn">
    <b>Changing a work schedule</b> applies to <b>new</b> uploads only. Overtime already calculated for the
    loaded import keeps the old schedule. To correct it:
    <ul>
        <li>For <b>specific days</b>, file a <b>Schedule Adjustment</b> and approve it.</li>
        <li>For the whole loaded import, if <b>nothing has been approved yet</b>, delete the import on
            <b>Biometric Data Import</b> and upload the file again.</li>
    </ul>
    The payroll report uses the <b>current</b> schedule for regular hours and late, so keep schedules
    current before generating it.
</div>
<div class="help-warn">
    <b>Renaming</b> an employee changes how future biometric files are matched. The new name must
    match the device exactly (LAST, FIRST).
</div>

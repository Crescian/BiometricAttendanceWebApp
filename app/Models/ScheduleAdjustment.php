<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ScheduleAdjustment extends Model
{
    use HasFactory;
    protected $table = 'schedule_adjustments'; // Specify the table name
    protected $fillable = [
        'employee_management_id',
        'earliest_time', 'latest_time', 'attendance_area', 'late',
        'late_hours', 'late_minutes', 'approval_status', 'total_non_working_days_present', 'record_date',
        'action', 'schedule', 'others', 'reason','biometric_imports_id','attendance_records_id'
    ];
}

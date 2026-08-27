<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Overtime extends Model
{
    use HasFactory;

    protected $fillable = [
        'unique_id',
        'first_name',
        'last_name',
        'employee_name',
        'earliest_time',
        'latest_time',
        'type',
        'department',
        'attendance_area',
        'serial_number',
        'schedule',
        'ord_ot',
        'ord_nd',
        'ord_nd_ot',
        'rd',
        'rd_ot',
        'rd_nd',
        'rd_nd_ot',
        'total_non_working_days_present',
        'late',
        'late_hours',
        'late_minutes',
        'out_time_required',
        'approval_status',
        'record_date',
        'status',
        'original_earliest_time',
        'original_latest_time',
        'biometric_imports_id',
        'schedule_shift',
        'is_cutoff',
        'attendance_records_id'
    ];

}

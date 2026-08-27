<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AttendanceRecord extends Model
{
    use HasFactory;
    protected $fillable = [
        'id',
        'employee_management_id',
        'attendance_area',
        'attendance_point_name',
        'verification_mode',
        'attendance_photo',
        'data_sources',
        'record_date',
        'earliest_time',
        'latest_time',
        'weekday',
        'biometric_imports_id',
        'late',
        'late_hours',
        'late_minutes',
        'leaves',
        'created_at',
        'updated_at',
    ];
}

<?php

namespace App\Models;

use App\Models\Concerns\Auditable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CertificateOfAttendance extends Model
{
    use Auditable, HasFactory;
    protected $table = 'certificate_attendance';
    protected $fillable = [
        'earliest_time',
        'latest_time',
        'approval_status',
        'date',
        'employee_management_id',
        'created_at',
        'updated_at',
        'others',
        'reason',
        'weekday',
        'biometric_imports_id',
        'attendance_records_id',
        'is_cutoff'
    ];

}

<?php

namespace App\Models;

use App\Models\Concerns\Auditable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Leave extends Model
{
    use Auditable, HasFactory;

    protected $fillable = [
        'employee_management_id',
        'status',
        'record_date',
        'leave_type',
        'reason',
        'with_pay',
        'biometric_imports_id',
        'created_at',
        'updated_at',
        'weekday',
        'others'
    ];

    // ✅ Relationship: Each leave belongs to one employee
    public function employee()
    {
        return $this->belongsTo(EmployeeManagement::class, 'employee_management_id');
    }
}

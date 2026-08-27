<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EmployeeManagement extends Model
{
    use HasFactory;

    protected $fillable = [
        'unique_id',
        'employee_name',
        'basic_salary',
        'department',
        'report_to',
        'schedule',
        'status'
    ];
}

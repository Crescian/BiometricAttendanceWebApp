<?php

namespace App\Models;

use App\Models\Concerns\Auditable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Department extends Model
{
    use Auditable, HasFactory;
    protected $fillable = [
        'department_name',
        'department_head',
        'company_id'
    ];

}

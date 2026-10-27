<?php

namespace App\Models;

use App\Models\Concerns\Auditable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Schedule extends Model
{
    use Auditable, HasFactory;
    protected $fillable = [
        'schedule_name',
        'schedule_type',
        'schedule_shift'
    ];
}

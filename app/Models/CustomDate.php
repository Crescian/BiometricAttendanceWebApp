<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CustomDate extends Model
{
    use HasFactory;
    protected $fillable = [
        'record_date',
        'title',
        'holiday_type',
    ];
}

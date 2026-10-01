<?php

namespace App\Models;

use App\Models\Concerns\Auditable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CustomDate extends Model
{
    use Auditable, HasFactory;

    // custom_dates has no created_at / updated_at columns.
    public $timestamps = false;
    protected $fillable = [
        'record_date',
        'title',
        'holiday_type',
    ];
}

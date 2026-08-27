<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Csvimport extends Model
{
    use HasFactory;

    protected $fillable = [
        'entry_date',
        'basic',
        'dh',
        'dh_nd',
        'dh_nd_excess',
        'dh_nd_ot',
        'dh_ot',
        'dh_rd',
        'dh_rd_nd',
        'dh_rd_nd_ot',
        'dh_rd_ot',
        'hours_worked',
        'id_number',
        'lh',
        'lh_nd',
        'lh_nd_excess',
        'lh_nd_ot',
        'lh_ot',
        'lh_rd',
        'lh_rd_nd',
        'lh_rd_nd_excess',
        'lh_rd_nd_ot',
        'lh_rd_ot',
        'name',
        'ord_nd',
        'ord_nd_ot',
        'ord_ot',
        'rd',
        'rd_nd',
        'rd_nd_ot',
        'rd_ot',
        'reg_nd_excess',
        'sh',
        'sh_nd',
        'sh_nd_excess',
        'sh_nd_ot',
        'sh_ot',
        'sh_rd',
        'sh_rd_nd',
        'sh_rd_nd_excess',
        'sh_rd_nd_ot',
        'sh_rd_ot',
        'sun_nd_excess',
        'total_non_working_days_present',
        'total_regular_working_days_present',
        'biometric_imports_id'
    ];
}

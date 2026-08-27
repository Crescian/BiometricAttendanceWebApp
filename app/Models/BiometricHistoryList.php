<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BiometricHistoryList extends Model
{
    use HasFactory;
    protected $table = 'biometric_imports';
    protected $fillable = [
        'id',
        'title',
        'status',
        'imported_by',
        'imported_at',
        'total_rows',
        'created_at',
        'updated_at',
    ];

    public function getLoadedRecord()
    {
        $record = BiometricHistoryList::where('status', 'load')->first();
        return $record ? $record->title : null;
    }

    public function getLoadedRecordId()
    {
        return BiometricHistoryList::where('status', 'load')->value('id');
    }
}

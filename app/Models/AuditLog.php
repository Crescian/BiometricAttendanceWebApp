<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use LogicException;

/**
 * One audit trail entry. Append-only: rows are written by App\Services\AuditLogger and can never
 * be changed or removed (a database trigger and the app's DB role enforce this as well).
 */
class AuditLog extends Model
{
    public $timestamps = false;

    protected $guarded = ['*'];

    protected $casts = [
        'occurred_at' => 'datetime',
        'old_values' => 'array',
        'new_values' => 'array',
        'metadata' => 'array',
    ];

    protected static function booted()
    {
        static::updating(fn () => throw new LogicException('Audit log entries cannot be modified.'));
        static::deleting(fn () => throw new LogicException('Audit log entries cannot be deleted.'));
    }
}

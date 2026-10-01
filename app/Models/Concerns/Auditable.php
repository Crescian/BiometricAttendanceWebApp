<?php

namespace App\Models\Concerns;

use App\Services\AuditLogger;

/**
 * Writes an audit entry (with before/after values of the changed fields) whenever the model is
 * created, updated or deleted through Eloquent. Query-builder bulk writes don't fire these events;
 * those code paths record their own business-level entries through AuditLogger.
 */
trait Auditable
{
    public static function bootAuditable(): void
    {
        static::created(fn ($model) => AuditLogger::modelEvent($model, 'created'));
        static::updated(fn ($model) => AuditLogger::modelEvent($model, 'updated'));
        static::deleted(fn ($model) => AuditLogger::modelEvent($model, 'deleted'));
    }
}

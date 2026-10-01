<?php

namespace App\Console\Commands;

use App\Services\AuditLogger;
use Illuminate\Console\Command;

/**
 * Re-computes the audit trail's hash chain. Exit code 1 means an entry was changed, removed or
 * reordered after it was written, so this can run from cron or monitoring.
 */
class AuditVerify extends Command
{
    protected $signature = 'audit:verify';

    protected $description = 'Verify the integrity (hash chain) of the audit log';

    public function handle(): int
    {
        $result = AuditLogger::verify();

        AuditLogger::record('audit.integrity_verified', [
            'outcome' => $result['ok'] ? 'success' : 'failure',
            'description' => $result['ok']
                ? "Audit log integrity verified from the command line: {$result['checked']} entries intact."
                : "Audit log integrity check FAILED at entry #{$result['broken_id']}: {$result['reason']}",
            'metadata' => $result,
        ]);

        if ($result['ok']) {
            $this->info("OK: {$result['checked']} audit entries verified; the chain is intact.");

            return self::SUCCESS;
        }

        $this->error("FAILED at entry #{$result['broken_id']} after {$result['checked']} good entries: {$result['reason']}");

        return self::FAILURE;
    }
}

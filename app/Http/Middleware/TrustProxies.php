<?php

namespace App\Http\Middleware;

use Illuminate\Http\Middleware\TrustProxies as Middleware;
use Illuminate\Http\Request;

class TrustProxies extends Middleware
{
    /**
     * The trusted proxies for this application.
     *
     * @var array|string|null
     */
    protected $proxies;

    /**
     * Only proxies listed in TRUSTED_PROXIES (comma-separated IPs/CIDRs) may set X-Forwarded-For.
     * Trusting every proxy ('*') let any client put a fake IP into the audit trail. nginx talks to
     * PHP over FastCGI, so with no trusted proxy the recorded IP is the address nginx saw.
     */
    public function __construct()
    {
        $configured = array_filter(array_map('trim', explode(',', (string) config('app.trusted_proxies'))));
        $this->proxies = $configured ?: null;
    }

    /**
     * The headers that should be used to detect proxies.
     *
     * @var int
     */
    protected $headers =
        Request::HEADER_X_FORWARDED_FOR |
        Request::HEADER_X_FORWARDED_HOST |
        Request::HEADER_X_FORWARDED_PORT |
        Request::HEADER_X_FORWARDED_PROTO;
}

<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * Gives every request a UUID so all audit entries written while handling it can be tied together
 * (and matched to server logs through the X-Request-Id response header).
 */
class AssignRequestId
{
    public function handle(Request $request, Closure $next)
    {
        $id = (string) Str::uuid();
        $request->attributes->set('request_id', $id);

        $response = $next($request);
        $response->headers->set('X-Request-Id', $id);

        return $response;
    }
}

<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Services\AuditLogger;
use Illuminate\Support\Facades\Auth;

/**
 * Keeps users.last_seen_at fresh for the Presence column on User Management (at most one
 * write per user per minute), and signs out accounts an admin has set to Inactive.
 */
class TrackLastSeen
{
    public function handle(Request $request, Closure $next)
    {
        $user = Auth::user();

        if ($user) {
            if ($user->active === false) {
                AuditLogger::record('auth.session_terminated', [
                    'category' => 'auth',
                    'action' => 'logout',
                    'outcome' => 'denied',
                    'description' => 'Signed out automatically: account is inactive',
                ]);
                Auth::guard('web')->logout();
                $request->session()->invalidate();
                $request->session()->regenerateToken();

                return $request->expectsJson()
                    ? response()->json(['message' => 'This account is inactive.'], 401)
                    : redirect()->route('login')->withErrors(['email' => 'This account is inactive. Please contact an administrator.']);
            }

            if (! $user->last_seen_at || $user->last_seen_at->lt(now()->subMinute())) {
                // Query-builder update: no updated_at bump, no model events
                $user->newQuery()->whereKey($user->getKey())->update(['last_seen_at' => now()]);
            }
        }

        return $next($request);
    }
}

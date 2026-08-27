<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */

    public function handle(Request $request, Closure $next, $role)
    {
        $user = Auth::user();

        // Allow access if user is admin (admins bypass all restrictions)
        if ($user && $user->role === 'admin') {
            return $next($request);
        }

        // Otherwise, only allow if user role matches required role
        if (!$user || $user->role !== $role) {
            abort(403, 'Unauthorized access.');
        }

        return $next($request);
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\Department;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class UserManagementController extends Controller
{
    /** Seen within this many minutes counts as Online. */
    private const ONLINE_MINUTES = 5;

    /**
     * Local login accounts for the User Management table. A department head's
     * Department is the department(s) they head — the same rule that limits what they see.
     */
    public function index()
    {
        $headed = Department::whereNotNull('department_head')
            ->orderBy('department_name')
            ->get(['department_head', 'department_name'])
            ->groupBy('department_head');

        $onlineSince = now()->subMinutes(self::ONLINE_MINUTES);

        $users = User::select('id', 'name', 'email', 'role', 'position', 'active', 'created_at', 'last_seen_at')
            ->orderBy('name')
            ->get()
            ->map(fn (User $u) => [
                'id'           => $u->id,
                'name'         => $u->name,
                'email'        => $u->email,
                'role'         => $u->role,
                'position'     => $u->position,
                'active'       => (bool) $u->active,
                'departments'  => ($headed[$u->id] ?? collect())->pluck('department_name')->values(),
                'online'       => $u->last_seen_at !== null && $u->last_seen_at->gte($onlineSince),
                'last_seen_at' => $u->last_seen_at?->toIso8601String(),
                'joined'       => $u->created_at?->toIso8601String(),
                'is_me'        => $u->id === Auth::id(),
            ]);

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    /**
     * Org/user directory from TicketingSystemVersion2 (GET /org/users), used to
     * autofill the "Register User" form instead of typing name/email by hand.
     * That endpoint has no name/email search param, so we pull pages here and
     * let the frontend filter client-side.
     */
    public function directory()
    {
        $baseUrl = rtrim(config('services.ticketing.url'), '/');
        $token = config('services.ticketing.org_token');

        if (! $token) {
            return response()->json([
                'success' => false,
                'message' => 'TICKETING_ORG_API_TOKEN is not configured.',
            ], 500);
        }

        $people = collect();
        $page = 1;
        $lastPage = 1;

        do {
            $response = Http::withToken($token)
                ->acceptJson()
                ->timeout(10)
                ->get($baseUrl.'/org/users', ['per_page' => 200, 'page' => $page]);

            if ($response->failed()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unable to reach the ticketing system directory right now.',
                ], 502);
            }

            $body = $response->json();
            $people = $people->merge($body['data'] ?? []);
            $lastPage = $body['last_page'] ?? 1;
            $page++;
        } while ($page <= min($lastPage, 5));

        return response()->json([
            'success' => true,
            'data' => $people->values(),
        ]);
    }

    /**
     * Admin-only: register a local user account.
     *
     * Login credentials are verified against the external ticketing system
     * (see LoginRequest::authenticate()); this only needs to exist locally
     * so a matching email can be found on login. A random password is
     * generated when one isn't supplied, since it isn't used to authenticate.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'role' => ['nullable', 'string', Rule::in(['admin', 'user'])],
            'position' => ['nullable', 'string', 'max:255'],
            'password' => ['nullable', 'string', 'min:8'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'role' => $validated['role'] ?? 'user',
            'position' => $validated['position'] ?? null,
            'password' => Hash::make($validated['password'] ?? Str::password(20)),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'User registered successfully.',
            'data' => $user,
        ], 201);
    }

    /**
     * Admin-only: change a user's role, position or status (Active / Inactive).
     * Inactive accounts can't log in and are signed out on their next request.
     */
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'role' => ['sometimes', 'string', Rule::in(['admin', 'user'])],
            'position' => ['sometimes', 'nullable', 'string', 'max:255'],
            'active' => ['sometimes', 'boolean'],
        ]);

        // Don't let an admin lock themselves out
        if ($user->id === Auth::id()) {
            if (array_key_exists('active', $validated) && ! $validated['active']) {
                return response()->json(['success' => false, 'message' => "You can't deactivate your own account."], 422);
            }
            if (($validated['role'] ?? 'admin') !== 'admin') {
                return response()->json(['success' => false, 'message' => "You can't remove your own admin role."], 422);
            }
        }

        $user->fill($validated)->save();

        return response()->json([
            'success' => true,
            'message' => 'User updated successfully.',
        ]);
    }
}

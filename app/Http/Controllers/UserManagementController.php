<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class UserManagementController extends Controller
{
    /**
     * List local login accounts (id, name, email, role) for the Organization
     * Structure admin page.
     */
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => User::select('id', 'name', 'email', 'role')->orderBy('name')->get(),
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
            'password' => ['nullable', 'string', 'min:8'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'role' => $validated['role'] ?? 'user',
            'password' => Hash::make($validated['password'] ?? Str::password(20)),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'User registered successfully.',
            'data' => $user,
        ], 201);
    }
}

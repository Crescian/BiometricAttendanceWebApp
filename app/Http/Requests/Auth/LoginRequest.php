<?php

namespace App\Http\Requests\Auth;

use App\Models\User;
use Illuminate\Auth\Events\Lockout;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class LoginRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\Rule|array|string>
     */
    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ];
    }

    /**
     * Attempt to authenticate the request's credentials against the centralized
     * org login (TicketingSystemVersion2 /api/login), then sign in the matching
     * local user. Credentials themselves are never checked locally anymore.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function authenticate(): void
    {
        $this->ensureIsNotRateLimited();

        try {
            $response = Http::acceptJson()
                ->timeout(10)
                ->post(rtrim(config('services.ticketing.url'), '/').'/login', [
                    'email' => $this->input('email'),
                    'password' => $this->input('password'),
                ]);
        } catch (ConnectionException $e) {
            throw ValidationException::withMessages([
                'email' => ['Unable to reach the authentication service right now. Please try again in a moment.'],
            ]);
        }

        if ($response->failed()) {
            RateLimiter::hit($this->throttleKey());

            if ($response->status() === 429) {
                throw ValidationException::withMessages([
                    'email' => ['Too many login attempts. Please try again later.'],
                ]);
            }

            throw ValidationException::withMessages([
                'email' => [$response->json('message') ?: trans('auth.failed')],
            ]);
        }

        $user = User::where('email', $response->json('user.email', $this->input('email')))->first();

        if (! $user) {
            RateLimiter::hit($this->throttleKey());

            throw ValidationException::withMessages([
                'email' => ['Your account is valid but is not registered in the Attendance System. Please contact your administrator.'],
            ]);
        }

        Auth::login($user, $this->boolean('remember'));

        RateLimiter::clear($this->throttleKey());
    }

    /**
     * Ensure the login request is not rate limited.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function ensureIsNotRateLimited(): void
    {
        if (! RateLimiter::tooManyAttempts($this->throttleKey(), 5)) {
            return;
        }

        event(new Lockout($this));

        $seconds = RateLimiter::availableIn($this->throttleKey());

        throw ValidationException::withMessages([
            'email' => trans('auth.throttle', [
                'seconds' => $seconds,
                'minutes' => ceil($seconds / 60),
            ]),
        ]);
    }

    /**
     * Get the rate limiting throttle key for the request.
     */
    public function throttleKey(): string
    {
        return Str::transliterate(Str::lower($this->input('email')).'|'.$this->ip());
    }
}

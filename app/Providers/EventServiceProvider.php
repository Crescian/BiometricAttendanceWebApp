<?php

namespace App\Providers;

use Illuminate\Auth\Events\Registered;
use Illuminate\Auth\Listeners\SendEmailVerificationNotification;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Event;
use Illuminate\Auth\Events\Login;
use Illuminate\Auth\Events\Logout;
use Illuminate\Auth\Events\Failed;
use App\Services\AuditLogger;

class EventServiceProvider extends ServiceProvider
{
    /**
     * The event to listener mappings for the application.
     *
     * @var array<class-string, array<int, class-string>>
     */
    protected $listen = [
        Registered::class => [
            SendEmailVerificationNotification::class,
        ],
    ];

    /**
     * Register any events for your application.
     *
     * @return void
     */
    public function boot()
    {
        // Sign-in / sign-out go to the audit trail. Failed sign-ins are recorded with their reason
        // in LoginRequest, since credentials are checked by the Ticketing service, not Auth::attempt.
        Event::listen(Login::class, function ($event) {
            AuditLogger::record('auth.login.success', [
                'category' => 'auth',
                'action' => 'login',
                'actor' => $event->user,
                'description' => 'Signed in',
                'metadata' => ['remember' => (bool) $event->remember],
            ]);
        });

        Event::listen(Logout::class, function ($event) {
            if (! $event->user) {
                return;
            }
            AuditLogger::record('auth.logout', [
                'category' => 'auth',
                'action' => 'logout',
                'actor' => $event->user,
                'description' => 'Signed out',
            ]);
        });

        Event::listen(Failed::class, function ($event) {
            AuditLogger::record('auth.login.failed', [
                'category' => 'auth',
                'action' => 'login',
                'outcome' => 'failure',
                'actor' => null,
                'actor_email' => $event->credentials['email'] ?? null,
                'description' => 'Failed sign-in attempt',
            ]);
        });
    }

    /**
     * Determine if events and listeners should be automatically discovered.
     *
     * @return bool
     */
    public function shouldDiscoverEvents()
    {
        return false;
    }
}

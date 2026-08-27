<?php

namespace App\Providers;

use Illuminate\Auth\Events\Registered;
use Illuminate\Auth\Listeners\SendEmailVerificationNotification;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Event;
use Illuminate\Auth\Events\Login;
use Illuminate\Auth\Events\Logout;
use Illuminate\Auth\Events\Failed;
use App\Models\AttendanceLog;

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
        // Successful login
        Event::listen(Login::class, function ($event) {
            AttendanceLog::create([
                'user_id' => $event->user->id,
                'action' => 'login',
                'timestamp' => now(),
                'ip_address' => request()->ip(),
                'device_info' => request()->userAgent(),
            ]);
        });

        // Logout
        Event::listen(Logout::class, function ($event) {
            AttendanceLog::create([
                'user_id' => $event->user->id,
                'action' => 'logout',
                'timestamp' => now(),
                'ip_address' => request()->ip(),
                'device_info' => request()->userAgent(),
            ]);
        });

        // Failed login
        Event::listen(Failed::class, function ($event) {
            AttendanceLog::create([
                'user_id' => $event->user ? $event->user->id : null,
                'action' => 'failed_login',
                'timestamp' => now(),
                'ip_address' => request()->ip(),
                'device_info' => request()->userAgent(),
                'notes' => 'Failed login attempt',
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

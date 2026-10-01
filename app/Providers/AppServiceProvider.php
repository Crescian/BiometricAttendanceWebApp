<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        // Schema changes need the owner role; the app's own role can't alter tables or the audit
        // triggers. Run every migrate* command on the admin connection when one is configured.
        $command = $_SERVER['argv'][1] ?? '';
        if ($this->app->runningInConsole() && str_starts_with($command, 'migrate')
            && config('database.connections.pgsql_admin.username') !== config('database.connections.pgsql.username')) {
            config(['database.default' => 'pgsql_admin']);
        }
    }
}

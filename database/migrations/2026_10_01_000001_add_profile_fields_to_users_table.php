<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * User Management columns: Position (from the Ticketing directory), Status (inactive accounts
 * can't log in) and Presence (last request time, kept fresh by TrackLastSeen).
 */
return new class extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('position')->nullable()->after('role');
            $table->boolean('active')->default(true)->after('position');
            $table->timestamp('last_seen_at')->nullable()->after('active');
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['position', 'active', 'last_seen_at']);
        });
    }
};

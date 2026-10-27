<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * One employee per Unique ID. The edit form can now change the ID, so the database enforces what
 * store() and update() check. Existing duplicates must be fixed by hand first, never merged here.
 */
return new class extends Migration
{
    public function up()
    {
        $duplicates = DB::table('employee_management')
            ->select('unique_id')
            ->groupBy('unique_id')
            ->havingRaw('count(*) > 1')
            ->pluck('unique_id');

        if ($duplicates->isNotEmpty()) {
            throw new RuntimeException(
                'Fix duplicate employee Unique IDs before migrating: '.$duplicates->implode(', ')
            );
        }

        DB::statement('CREATE UNIQUE INDEX IF NOT EXISTS employee_management_unique_id_unique ON employee_management (unique_id)');
    }

    public function down()
    {
        DB::statement('DROP INDEX IF EXISTS employee_management_unique_id_unique');
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('csvimports', function (Blueprint $table) {
            $table->id();
            $table->date('entry_date')->nullable()->useCurrent();
            $table->string('basic')->nullable();
            $table->string('dh')->nullable();
            $table->string('dh_nd')->nullable();
            $table->string('dh_nd_excess')->nullable();
            $table->string('dh_nd_ot')->nullable();
            $table->string('dh_ot')->nullable();
            $table->string('dh_rd')->nullable();
            $table->string('dh_rd_nd')->nullable();
            $table->string('dh_rd_nd_ot')->nullable();
            $table->string('dh_rd_ot')->nullable();
            $table->string('hours_worked')->nullable();
            $table->string('id_number')->nullable();
            $table->string('lh')->nullable();
            $table->string('lh_nd')->nullable();
            $table->string('lh_nd_excess')->nullable();
            $table->string('lh_nd_ot')->nullable();
            $table->string('lh_ot')->nullable();
            $table->string('lh_rd')->nullable();
            $table->string('lh_rd_nd')->nullable();
            $table->string('lh_rd_nd_excess')->nullable();
            $table->string('lh_rd_nd_ot')->nullable();
            $table->string('lh_rd_ot')->nullable();
            $table->string('name')->nullable();
            $table->string('ord_nd')->nullable();
            $table->string('ord_nd_ot')->nullable();
            $table->string('ord_ot')->nullable();
            $table->string('rd')->nullable();
            $table->string('rd_nd')->nullable();
            $table->string('rd_nd_ot')->nullable();
            $table->string('rd_ot')->nullable();
            $table->string('reg_nd_excess')->nullable();
            $table->string('sh')->nullable();
            $table->string('sh_nd')->nullable();
            $table->string('sh_nd_excess')->nullable();
            $table->string('sh_nd_ot')->nullable();
            $table->string('sh_ot')->nullable();
            $table->string('sh_rd')->nullable();
            $table->string('sh_rd_nd')->nullable();
            $table->string('sh_rd_nd_excess')->nullable();
            $table->string('sh_rd_nd_ot')->nullable();
            $table->string('sh_rd_ot')->nullable();
            $table->string('sun_nd_excess')->nullable();
            $table->string('total_non_working_days_present')->nullable();
            $table->string('total_regular_working_days_present')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('csvimports');
    }
};

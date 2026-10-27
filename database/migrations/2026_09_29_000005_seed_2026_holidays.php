<?php

use App\Services\AttendanceProcessor;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Seeds the 2026 non-working days into custom_dates: every Sunday (Rest Day) plus the
 * public holidays of Proclamation No. 1006, s. 2025. These drive the RD / LH / SH split
 * in overtime and payroll, and the dashboard's "Upcoming Holidays" card.
 * Existing (record_date, title) rows are skipped, so re-running is safe.
 */
return new class extends Migration
{
    public function up()
    {
        app(AttendanceProcessor::class)->calculateTotalNonWorkingDays(2026);
    }

    /** Removes only the rows seeded above; holidays added by hand are kept. */
    public function down()
    {
        DB::table('custom_dates')
            ->whereBetween('record_date', ['2026-01-01', '2026-12-31 23:59:59'])
            ->where('title', 'Sunday Rest Day')
            ->delete();

        foreach (AttendanceProcessor::PUBLIC_HOLIDAYS[2026] as $date => [$title]) {
            DB::table('custom_dates')
                ->whereDate('record_date', $date)
                ->whereIn('title', [$title, "$title (Falls on Rest Day)"])
                ->delete();
        }
    }
};

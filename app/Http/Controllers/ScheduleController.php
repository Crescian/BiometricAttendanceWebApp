<?php

namespace App\Http\Controllers;

use App\Models\Schedule;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $data = Schedule::orderByRaw("
                CASE schedule_shift
                    WHEN 'Day Shift' THEN 1
                    WHEN 'Night Shift' THEN 2
                    ELSE 3
                END
            ")
            ->orderByRaw("CAST(split_part(schedule_name, '-', 1) AS INTEGER)")
            ->get();

        return response()->json($data);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */

    // Store a new schedule
    public function store(Request $request)
    {
        $request->validate([
            'schedule_name' => 'required',
            'schedule_type' => 'required',
            'schedule_shift' => 'required',
        ]);

        // Create new schedule directly using already formatted name
        $schedule = Schedule::create([
            'schedule_name' => $request->schedule_name, // already "8-15"
            'schedule_type' => $request->schedule_type,
            'schedule_shift' => $request->schedule_shift,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Schedule created successfully',
            'data' => $schedule
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Schedule  $schedule
     * @return \Illuminate\Http\Response
     */
    public function show(Schedule $schedule)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Schedule  $schedule
     * @return \Illuminate\Http\Response
     */
    public function edit(Schedule $schedule)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Schedule  $schedule
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Schedule $schedule)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Schedule  $schedule
     * @return \Illuminate\Http\Response
     */

    // Delete schedule
    public function destroy($id)
    {
        $schedule = Schedule::findOrFail($id);
        $schedule->delete();

        return response()->json([
            'success' => true,
            'message' => 'Schedule deleted successfully'
        ]);
    }
}

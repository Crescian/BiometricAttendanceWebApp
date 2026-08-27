<?php

namespace App\Http\Controllers;

use App\Models\CustomDate;
use Illuminate\Http\Request;
use Carbon\Carbon;

class CustomDateController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */

    // ✅ Get only upcoming custom dates
    public function index()
    {
        $today = Carbon::today();

        $dates = CustomDate::whereDate('record_date', '>=', $today)
            ->orderBy('record_date', 'asc')
            ->get();

        return response()->json($dates);
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

    public function store(Request $request)
    {
        $request->validate([
            'record_date' => 'required|date',
            'title' => 'required|string|max:255',
            'holiday_type' => 'required|string|max:255',
        ]);

        $customDate = CustomDate::create([
            'record_date' => $request->record_date,
            'title' => $request->title,
            'holiday_type' => $request->holiday_type,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Holiday added successfully!',
            'data' => $customDate,
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\CustomDate  $customDate
     * @return \Illuminate\Http\Response
     */
    public function show(CustomDate $customDate)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\CustomDate  $customDate
     * @return \Illuminate\Http\Response
     */
    public function edit(CustomDate $customDate)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\CustomDate  $customDate
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, CustomDate $customDate)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\CustomDate  $customDate
     * @return \Illuminate\Http\Response
     */
    public function destroy(CustomDate $customDate)
    {
        //
    }
}

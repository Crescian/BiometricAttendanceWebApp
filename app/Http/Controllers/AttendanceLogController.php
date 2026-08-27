<?php

namespace App\Http\Controllers;

use App\Models\AttendanceLog;
use Illuminate\Http\Request;

class AttendanceLogController extends Controller
{
    public function fetch()
    {
        $logs = AttendanceLog::with('user')->latest()->get();

        // Map data to include username
        $logsData = $logs->map(function ($log) {
            return [
                'id' => $log->id,
                'user_name' => $log->user ? $log->user->name : 'Unknown',
                'action' => $log->action,
                'timestamp' => $log->timestamp,
                'ip_address' => $log->ip_address
            ];
        });

        return response()->json($logsData);
    }
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
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
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\AttendanceLog  $attendanceLog
     * @return \Illuminate\Http\Response
     */
    public function show(AttendanceLog $attendanceLog)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\AttendanceLog  $attendanceLog
     * @return \Illuminate\Http\Response
     */
    public function edit(AttendanceLog $attendanceLog)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\AttendanceLog  $attendanceLog
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, AttendanceLog $attendanceLog)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\AttendanceLog  $attendanceLog
     * @return \Illuminate\Http\Response
     */
    public function destroy(AttendanceLog $attendanceLog)
    {
        //
    }
}

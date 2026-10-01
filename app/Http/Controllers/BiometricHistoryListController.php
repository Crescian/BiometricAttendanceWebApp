<?php

namespace App\Http\Controllers;

use App\Services\AuditLogger;
use App\Models\BiometricHistoryList;
use Illuminate\Http\Request;

class BiometricHistoryListController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function toggleStatus(Request $request)
    {
        $id = $request->id;

        // Find the record by ID
        $record = BiometricHistoryList::findOrFail($id);

        // Determine the new status (toggle)
        $newStatus = $record->status === 'load' ? 'unload' : 'load';

        // If setting this one to 'load', unload all others first
        if ($newStatus === 'load') {
            $unloaded = BiometricHistoryList::where('status', 'load')->where('id', '<>', $record->id)->pluck('id')->all();
            BiometricHistoryList::where('status', 'load')->update(['status' => 'unload']);
            if ($unloaded) {
                AuditLogger::record('biometric_import.unloaded', [
                    'category' => 'import', 'action' => 'update', 'target' => $record,
                    'description' => 'Unloaded import(s) #'.implode(', #', $unloaded).' to load #'.$record->id,
                    'old' => ['status' => 'load'], 'new' => ['status' => 'unload'],
                    'metadata' => ['unloaded_ids' => $unloaded],
                ]);
            }
        }

        // Update the selected record
        $record->update(['status' => $newStatus]);

        return response()->json([
            'message' => 'Status toggled successfully.',
            'data' => $record
        ]);
    }

    public function index()
    {
        $data = BiometricHistoryList::orderBy('created_at', 'desc')->get();
        return response()->json($data);
    }
    
    public function getLoadedRecord()
    {
        $record = BiometricHistoryList::where('status', 'load')->first();

        if ($record) {
            return response()->json([
                'id' => $record->id,
                'data' => $record
            ]);
        }

        return response()->json([
            'message' => 'No record with status "load" found.'
        ], 404);
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
            'period_start' => 'nullable|date',
            'period_end'   => 'nullable|date|after_or_equal:period_start',
        ]);

        // Only overwrite the period when the admin supplied one; otherwise keep
        // the default set from the punch dates during upload.
        $period = array_filter($request->only('period_start', 'period_end'));

        // If uploadCSV() already created the row for this import (the normal path),
        // fill in the details the user entered on the "Import Now" step rather than
        // creating a second row — attendance_records/overtimes are already tied to
        // the id created during upload, so a new row here would orphan them again.
        if ($request->filled('id')) {
            $record = BiometricHistoryList::findOrFail($request->id);
            $record->update([
                'title' => $request->title,
                'imported_by' => $request->imported_by,
                'total_rows' => $request->total_rows,
            ] + $period);

            return response()->json([
                'message' => 'Biometric import record updated successfully.',
                'id' => $record->id,
                'data' => $record
            ], 200);
        }

        // 1️⃣ Unload all previously "loaded" records
        $unloaded = BiometricHistoryList::where('status', 'load')->pluck('id')->all();
        BiometricHistoryList::where('status', 'load')->update(['status' => 'unload']);
        if ($unloaded) {
            AuditLogger::record('biometric_import.unloaded', [
                'category' => 'import', 'action' => 'update',
                'description' => 'Unloaded import(s) #'.implode(', #', $unloaded).' for a new import',
                'old' => ['status' => 'load'], 'new' => ['status' => 'unload'],
                'metadata' => ['unloaded_ids' => $unloaded],
            ]);
        }

        $BiometricHistoryList = BiometricHistoryList::create([
            'title' => $request->title,
            'status' => 'load',
            'imported_by' => $request->imported_by,
            'total_rows' => $request->total_rows,
            'imported_at' => now(), // current date and time
        ] + $period);

        return response()->json([
            'message' => 'Biometric import record created successfully.',
            'id' => $BiometricHistoryList->id,
            'data' => $BiometricHistoryList
        ], 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\BiometricHistoryList  $biometricHistoryList
     * @return \Illuminate\Http\Response
     */
    public function show(BiometricHistoryList $biometricHistoryList)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\BiometricHistoryList  $biometricHistoryList
     * @return \Illuminate\Http\Response
     */
    public function edit(BiometricHistoryList $biometricHistoryList)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\BiometricHistoryList  $biometricHistoryList
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, BiometricHistoryList $biometricHistoryList)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\BiometricHistoryList  $biometricHistoryList
     * @return \Illuminate\Http\Response
     */
    public function destroy(BiometricHistoryList $biometricHistoryList)
    {
        //
    }
}

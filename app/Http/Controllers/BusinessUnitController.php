<?php

namespace App\Http\Controllers;

use App\Models\BusinessUnit;
use Illuminate\Http\Request;

class BusinessUnitController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        // ✅ Get all business units
        $businessUnits = BusinessUnit::all();
        
        return response()->json([
            'success' => true,
            'data' => $businessUnits
        ]);
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
        // ✅ Validate input
        $request->validate([
            'name' => 'required|string|max:255',
            'head' => 'nullable|string|max:255',
        ]);

        // ✅ Create record
        $businessUnit = BusinessUnit::create([
            'name' => $request->name,
            'head' => $request->head,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Business Unit added successfully.',
            'data' => $businessUnit
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\BusinessUnit  $businessUnit
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        // ✅ Find business unit by ID
        $businessUnit = BusinessUnit::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $businessUnit
        ]);
    }


    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\BusinessUnit  $businessUnit
     * @return \Illuminate\Http\Response
     */
    public function edit(BusinessUnit $businessUnit)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\BusinessUnit  $businessUnit
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        // ✅ Validate input
        $request->validate([
            'name' => 'required|string|max:255',
            'head' => 'nullable|string|max:255',
        ]);

        // ✅ Find business unit
        $businessUnit = BusinessUnit::findOrFail($id);

        // ✅ Update fields
        $businessUnit->update([
            'name' => $request->name,
            'head' => $request->head,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Business Unit updated successfully.',
            'data' => $businessUnit
        ]);
    }


    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\BusinessUnit  $businessUnit
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $businessUnit = BusinessUnit::findOrFail($id);
        $businessUnit->delete();

        return response()->json([
            'success' => true,
            'message' => 'Business Unit deleted successfully.'
        ]);
    }

}

<?php

namespace App\Http\Controllers;

use App\Models\Company;
use Illuminate\Http\Request;

class CompanyController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        // ✅ Get all companies
        $companies = Company::all();

        return response()->json([
            'success' => true,
            'data' => $companies
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
        $company = Company::create([
            'name' => $request->name,
            'head' => $request->head,
            'business_unit_id' => $request->business_unit_id, // save BU ID
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Company added successfully.',
            'data' => $company
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Company  $company
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        // ✅ Find company by ID
        $company = Company::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $company
        ]);
    }


    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\Company  $company
     * @return \Illuminate\Http\Response
     */
    public function edit(Company $company)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Company  $company
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        // ✅ Validate input
        $request->validate([
            'name' => 'required|string|max:255',
            'head' => 'nullable|string|max:255',
        ]);

        // ✅ Find company
        $company = Company::findOrFail($id);

        // ✅ Update fields
        $company->update([
            'name' => $request->name,
            'head' => $request->head,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Company updated successfully.',
            'data' => $company
        ]);
    }


    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Company  $company
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $company = Company::findOrFail($id);
        $company->delete();

        return response()->json([
            'success' => true,
            'message' => 'Company deleted successfully.'
        ]);
    }

}

<?php

namespace App\Http\Controllers;

use App\Models\BiometricImport;
use Illuminate\Http\Request;

class BiometricImportController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $data = BiometricImport::all();
        return response()->json($data);
    }

// LANO0593
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
     * @param  \App\Models\BiometricImport  $biometricImport
     * @return \Illuminate\Http\Response
     */
    public function show(BiometricImport $biometricImport)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\BiometricImport  $biometricImport
     * @return \Illuminate\Http\Response
     */
    public function edit(BiometricImport $biometricImport)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\BiometricImport  $biometricImport
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, BiometricImport $biometricImport)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\BiometricImport  $biometricImport
     * @return \Illuminate\Http\Response
     */
    public function destroy(BiometricImport $biometricImport)
    {
        //
    }
}

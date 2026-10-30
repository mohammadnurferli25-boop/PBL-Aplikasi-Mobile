<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Laporan;
use Illuminate\Http\Request;

class LaporanController extends Controller
{
    public function index()
    {
        $laporans = Laporan::latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Data laporan berhasil diambil.',
            'data' => $laporans,
        ]);
    }

   public function store(Request $request)
{
    $validated = $request->validate([
        'lokasi' => 'required|string|max:255',
        'latitude' => 'required|numeric|between:-90,90',
        'longitude' => 'required|numeric|between:-180,180',
        'tingkat_genangan' => 'required|in:Rendah,Sedang,Tinggi',
        'deskripsi' => 'nullable|string|max:2000',
        'foto' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
    ]);

    if ($request->hasFile('foto')) {
        $validated['foto'] = $request->file('foto')
            ->store('laporan', 'public');
    }

    $validated['status'] = 'menunggu';

    $laporan = Laporan::create($validated);

    return response()->json([
        'success' => true,
        'message' => 'Laporan berhasil disimpan.',
        'data' => $laporan,
    ], 201);
}


    public function show(Laporan $laporan)
    {
        return response()->json([
            'success' => true,
            'data' => $laporan,
        ]);
    }

    public function update(Request $request, Laporan $laporan)
    {
        $validated = $request->validate([
            'lokasi' => 'sometimes|required|string|max:255',
            'latitude' => 'sometimes|required|numeric',
            'longitude' => 'sometimes|required|numeric',
            'tingkat_genangan' => 'sometimes|required|in:Rendah,Sedang,Tinggi',
            'deskripsi' => 'nullable|string',
            'foto' => 'nullable|string|max:255',
            'status' => 'sometimes|required|in:menunggu,diverifikasi,ditolak,selesai',
        ]);

        $laporan->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil diperbarui.',
            'data' => $laporan,
        ]);
    }

    public function destroy(Laporan $laporan)
    {
        $laporan->delete();

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil dihapus.',
        ]);
    }
}
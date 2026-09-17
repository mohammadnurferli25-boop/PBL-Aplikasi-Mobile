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
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'tingkat_genangan' => 'required|in:Rendah,Sedang,Tinggi',
            'deskripsi' => 'nullable|string',
            'foto' => 'nullable|string|max:255',
        ]);

        $laporan = Laporan::create([
            'lokasi' => $validated['lokasi'],
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
            'tingkat_genangan' => $validated['tingkat_genangan'],
            'deskripsi' => $validated['deskripsi'] ?? null,
            'foto' => $validated['foto'] ?? null,
            'status' => 'menunggu',
        ]);

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
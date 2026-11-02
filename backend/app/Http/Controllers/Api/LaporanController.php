<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Laporan;
use Illuminate\Http\Request;

class LaporanController extends Controller
{
    // Menampilkan laporan sesuai role pengguna
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'admin') {
            $laporans = Laporan::latest()->get();
        } else {
            $laporans = Laporan::where('user_id', $user->id)
                ->latest()
                ->get();
        }

        return response()->json([
            'success' => true,
            'message' => 'Data laporan berhasil diambil.',
            'data' => $laporans,
        ]);
    }

    // Membuat laporan baru
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

        $validated['user_id'] = $request->user()->id;
        $validated['status'] = 'menunggu';

        $laporan = Laporan::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil disimpan.',
            'data' => $laporan,
        ], 201);
    }

    // Melihat detail laporan
    public function show(Request $request, Laporan $laporan)
    {
        $user = $request->user();

        abort_unless(
            $user->role === 'admin' || $laporan->user_id === $user->id,
            403,
            'Kamu tidak memiliki akses ke laporan ini.'
        );

        return response()->json([
            'success' => true,
            'data' => $laporan,
        ]);
    }

    // Memperbarui laporan: khusus admin
    public function update(Request $request, Laporan $laporan)
    {
        abort_unless(
            $request->user()->role === 'admin',
            403,
            'Hanya admin yang dapat memperbarui laporan.'
        );

        $validated = $request->validate([
            'lokasi' => 'sometimes|required|string|max:255',
            'latitude' => 'sometimes|required|numeric|between:-90,90',
            'longitude' => 'sometimes|required|numeric|between:-180,180',
            'tingkat_genangan' => 'sometimes|required|in:Rendah,Sedang,Tinggi',
            'deskripsi' => 'nullable|string|max:2000',
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

    // Menghapus laporan: khusus admin
    public function destroy(Request $request, Laporan $laporan)
    {
        abort_unless(
            $request->user()->role === 'admin',
            403,
            'Hanya admin yang dapat menghapus laporan.'
        );

        $laporan->delete();

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil dihapus.',
        ]);
    }
}

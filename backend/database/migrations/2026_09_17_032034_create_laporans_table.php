<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('laporans', function (Blueprint $table) {
            $table->id();

            // Informasi laporan
            $table->string('lokasi');
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->enum('tingkat_genangan', [
                'Rendah',
                'Sedang',
                'Tinggi'
            ]);

            $table->text('deskripsi')->nullable();
            $table->string('foto')->nullable();

            // Status laporan
            $table->enum('status', [
                'menunggu',
                'diverifikasi',
                'ditolak',
                'selesai'
            ])->default('menunggu');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('laporans');
    }
};
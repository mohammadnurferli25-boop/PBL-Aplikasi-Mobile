<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\LaporanController;

// Autentikasi publik
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Endpoint yang memerlukan token Sanctum
Route::middleware('auth:sanctum')->group(function () {

    // Autentikasi pengguna
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Pengelolaan laporan
    Route::apiResource('laporan', LaporanController::class);
});

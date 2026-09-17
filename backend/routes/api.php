<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LaporanController;

Route::apiResource('laporan', LaporanController::class);
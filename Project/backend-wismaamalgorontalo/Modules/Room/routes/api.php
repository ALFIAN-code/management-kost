<?php

use Illuminate\Support\Facades\Route;
use Modules\Room\Http\Controllers\BuildingController;
use Modules\Room\Http\Controllers\RoomController;

Route::get('rooms', [RoomController::class, 'index']);
Route::get('rooms/{id}', [RoomController::class, 'show']);
Route::get('rooms-schedules', [RoomController::class, 'schedules']);

// Public/tenant buildings list
Route::get('buildings', [BuildingController::class, 'index']);
Route::get('buildings/{id}', [BuildingController::class, 'show']);

Route::middleware(['auth:sanctum'])->group(function () {
    // Kamar operations
    Route::post('rooms', [RoomController::class, 'store'])->middleware(['permission:create-room']);
    Route::put('rooms/{id}', [RoomController::class, 'update'])->middleware(['permission:update-room']);
    Route::delete('rooms/{id}', [RoomController::class, 'destroy'])->middleware(['permission:delete-room']);

    // Batch operations
    Route::post('rooms/batch-generate', [RoomController::class, 'batchGenerate'])->middleware(['permission:create-room']);
    Route::post('rooms/batch-store', [RoomController::class, 'batchStore'])->middleware(['permission:create-room']);
    Route::post('rooms/import-csv', [RoomController::class, 'importCsv'])->middleware(['permission:create-room']);

    // routes untuk upload dan hapus foto
    Route::post('rooms/{id}/images', [RoomController::class, 'uploadImages'])->middleware(['permission:update-room']);
    Route::delete('rooms/{roomId}/images/{imageId}', [RoomController::class, 'deleteImage'])->middleware(['permission:update-room']);

    // Properti / Gedung (Multi-Tenant Management)
    Route::post('buildings', [BuildingController::class, 'store'])->middleware(['permission:create-room']);
    Route::put('buildings/{id}', [BuildingController::class, 'update'])->middleware(['permission:update-room']);
    Route::delete('buildings/{id}', [BuildingController::class, 'destroy'])->middleware(['permission:delete-room']);
    Route::post('buildings/{id}/switch', [BuildingController::class, 'switchBuilding']);
});

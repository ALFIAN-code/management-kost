<?php

use Illuminate\Support\Facades\Route;
use Modules\Auth\Http\Controllers\AuthController;
use Modules\Auth\Http\Controllers\PermissionController;
use Modules\Auth\Http\Controllers\RoleController;
use Modules\Auth\Http\Controllers\UserController;
use Modules\Auth\Http\Controllers\UserProfileController;

Route::middleware(['auth:sanctum'])->prefix('v1')->group(function () {});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/permissions', [AuthController::class, 'myPermissions']);

// Password Recovery & SSO (Public)
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);
Route::post('/google-login', [AuthController::class, 'googleLogin']);

// Email Verification (Public OTP)
Route::post('/email/verify-otp', [AuthController::class, 'verifyEmailPublic']);
Route::post('/email/resend-otp', [AuthController::class, 'resendEmailVerification']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::put('/change-password', [AuthController::class, 'changePassword']);

    // Email verification
    Route::post('/email/send-verification', [AuthController::class, 'sendEmailVerification']);
    Route::post('/email/verify', [AuthController::class, 'verifyEmail']);

    Route::get('/resident/profile', [UserProfileController::class, 'show']);
    Route::post('/resident/profile', [UserProfileController::class, 'store']);

    Route::prefix('admin')->group(function () {
        // route crud permission
        Route::get('/permissions', [PermissionController::class, 'index'])->middleware('permission:view-permission');
        Route::post('/permissions', [PermissionController::class, 'store'])->middleware('permission:create-permission');
        Route::get('/permissions/{id}', [PermissionController::class, 'show'])->middleware('permission:view-permission');
        Route::put('/permissions/{id}', [PermissionController::class, 'update'])->middleware('permission:update-permission');
        Route::delete('/permissions/{id}', [PermissionController::class, 'destroy'])->middleware('permission:delete-permission');

        // route crud role
        Route::get('/roles', [RoleController::class, 'index'])->middleware('permission:view-role');
        Route::post('/roles', [RoleController::class, 'store'])->middleware('permission:create-role');
        Route::get('/roles/{role}', [RoleController::class, 'show'])->middleware('permission:view-role');
        Route::put('/roles/{role}', [RoleController::class, 'update'])->middleware('permission:update-role');
        Route::delete('/roles/{role}', [RoleController::class, 'destroy'])->middleware('permission:delete-role');

        // route crud user
        Route::get('/users', [UserController::class, 'index'])->middleware('permission:view-user');
        Route::post('/users', [UserController::class, 'store'])->middleware('permission:create-user');
        Route::get('/users/{user}', [UserController::class, 'show'])->middleware('permission:view-user');
        Route::put('/users/{user}', [UserController::class, 'update'])->middleware('permission:update-user');
        Route::delete('/users/{user}', [UserController::class, 'destroy'])->middleware('permission:delete-user');
    });
});

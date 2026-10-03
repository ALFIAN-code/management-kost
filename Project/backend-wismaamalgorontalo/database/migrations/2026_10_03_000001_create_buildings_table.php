<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// ADR-005: Multi-tenant multi-gedung — entitas tenant pusat (Core tier).
// Owner direferensikan ke users (Infrastructure tier / shared kernel).
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('buildings', function (Blueprint $table) {
            $table->id();
            $table->string('name', 150);
            $table->text('address');
            $table->foreignId('owner_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('phone_number', 20)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('buildings');
    }
};

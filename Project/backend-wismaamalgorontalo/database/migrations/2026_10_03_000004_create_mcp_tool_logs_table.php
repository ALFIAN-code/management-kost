<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// ADR-005: audit trail pemanggilan tool MCP AI (read-only analytics).
// user_id / building_id soft reference (tanpa FK) — modul Mcp adalah Business tier.
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mcp_tool_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->index();
            $table->unsignedBigInteger('building_id')->nullable()->index();
            $table->string('tool_name', 100)->index();
            $table->json('parameters')->nullable();
            $table->integer('execution_time_ms')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mcp_tool_logs');
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// ADR-005: FK fisik hanya boleh di dalam satu modul. Dua constraint lintas
// modul bisnis yang tersisa dilepas menjadi soft reference (kolom + index tetap ada).
// Pola defensif mengikuti 2026_05_15_300001_drop_old_module_fk_constraints.php
// (no-op di SQLite karena SQLite tidak menyimpan FK bernama pasca-migrate).
return new class extends Migration
{
    public function up(): void
    {
        // Finance -> Schedule: refund_requests.schedule_id
        if (Schema::hasTable('refund_requests') && $this->hasForeignKey('refund_requests', 'refund_requests_schedule_id_foreign')) {
            Schema::table('refund_requests', function (Blueprint $table) {
                $table->dropForeign('refund_requests_schedule_id_foreign');
            });
        }

        // Maintenance -> Room: maintenance_requests.room_id
        if (Schema::hasTable('maintenance_requests') && $this->hasForeignKey('maintenance_requests', 'maintenance_requests_room_id_foreign')) {
            Schema::table('maintenance_requests', function (Blueprint $table) {
                $table->dropForeign('maintenance_requests_room_id_foreign');
            });
        }
    }

    public function down(): void
    {
        // Constraint lintas modul sengaja tidak dikembalikan (keputusan arsitektur permanen).
    }

    private function hasForeignKey(string $table, string $constraintName): bool
    {
        if (DB::getDriverName() === 'sqlite') {
            return false;
        }

        $connection = config('database.default');
        $dbName = config("database.connections.{$connection}.database");

        if (empty($dbName)) {
            return false;
        }

        return DB::table('information_schema.TABLE_CONSTRAINTS')
            ->where('CONSTRAINT_SCHEMA', $dbName)
            ->where('TABLE_NAME', $table)
            ->where('CONSTRAINT_NAME', $constraintName)
            ->where('CONSTRAINT_TYPE', 'FOREIGN KEY')
            ->exists();
    }
};

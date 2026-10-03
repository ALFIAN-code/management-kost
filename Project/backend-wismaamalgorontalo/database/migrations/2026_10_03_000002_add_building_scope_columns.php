<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// ADR-005: Row-level multi-tenancy — kolom scoping building_id di tabel domain.
// Disengaja TANPA foreign key constraint (soft reference + index) agar modul
// bisnis tetap toggleable independen (aturan deptrac / event-driven).
return new class extends Migration
{
    /** @var array<string> */
    private array $scopedTables = [
        'rooms',
        'room_schedules',
        'invoices',
        'expenses',
        'fixed_expense_entries',
        'fines',
        'refund_requests',
        'maintenance_requests',
        'maintenance_schedules',
        'guests',
        'guest_bills',
        'inventories',
        'notification_logs',
    ];

    public function up(): void
    {
        foreach ($this->scopedTables as $tableName) {
            if (! Schema::hasTable($tableName) || Schema::hasColumn($tableName, 'building_id')) {
                continue;
            }

            Schema::table($tableName, function (Blueprint $table) {
                $table->unsignedBigInteger('building_id')->nullable()->after('id');
                $table->index('building_id');
            });
        }

        if (Schema::hasTable('users') && ! Schema::hasColumn('users', 'assigned_building_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->unsignedBigInteger('assigned_building_id')->nullable()->after('id');
                $table->index('assigned_building_id');
            });
        }
    }

    public function down(): void
    {
        foreach ($this->scopedTables as $tableName) {
            if (! Schema::hasTable($tableName) || ! Schema::hasColumn($tableName, 'building_id')) {
                continue;
            }

            Schema::table($tableName, function (Blueprint $table) {
                $table->dropIndex(['building_id']);
                $table->dropColumn('building_id');
            });
        }

        if (Schema::hasTable('users') && Schema::hasColumn('users', 'assigned_building_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropIndex(['assigned_building_id']);
                $table->dropColumn('assigned_building_id');
            });
        }
    }
};

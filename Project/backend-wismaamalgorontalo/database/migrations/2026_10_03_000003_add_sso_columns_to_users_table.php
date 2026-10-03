<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// ADR-006: Keycloak OIDC SSO — identitas federasi di tabel users.
// password tetap required di skema; akun SSO memakai password acak (JIT provisioning).
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'keycloak_id')) {
                $table->string('keycloak_id', 64)->nullable()->unique()->after('id');
            }

            if (! Schema::hasColumn('users', 'auth_provider')) {
                $table->string('auth_provider', 20)->default('local')->after('keycloak_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'auth_provider')) {
                $table->dropColumn('auth_provider');
            }

            if (Schema::hasColumn('users', 'keycloak_id')) {
                $table->dropUnique(['keycloak_id']);
                $table->dropColumn('keycloak_id');
            }
        });
    }
};

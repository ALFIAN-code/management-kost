<?php

namespace Modules\Auth\database\seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        Role::updateOrCreate(
            ['name' => 'super-admin', 'guard_name' => 'api'],
            ['description' => 'Main admin / boarding house owner']
        );
        Role::updateOrCreate(
            ['name' => 'admin', 'guard_name' => 'api'],
            ['description' => 'Admin in charge of boarding house management']
        );
        Role::updateOrCreate(
            ['name' => 'member', 'guard_name' => 'api'],
            ['description' => 'Application user who has not become a boarding house resident yet']
        );
        Role::updateOrCreate(
            ['name' => 'resident', 'guard_name' => 'api'],
            ['description' => 'Boarding house resident with an active lease']
        );
    }
}

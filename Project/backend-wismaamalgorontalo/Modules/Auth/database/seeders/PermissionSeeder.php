<?php

namespace Modules\Auth\database\seeders;

use Illuminate\Database\Seeder;
use Modules\Auth\Models\Permission;

class PermissionSeeder extends Seeder
{
    public function run(): void
    {
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        $permissions = [
            // ─── Dashboard ───────────────────────────────────────────────
            ['name' => 'view-dashboard',       'target' => 'dashboard', 'description' => 'View the main dashboard page'],
            ['name' => 'view-resident-dashboard', 'target' => 'dashboard', 'description' => 'View the resident-specific dashboard page'],

            // ─── Permission Management ────────────────────────────────────
            ['name' => 'view-permission',              'target' => 'permission', 'description' => 'View the permission list'],
            ['name' => 'create-permission',            'target' => 'permission', 'description' => 'Create a new permission'],
            ['name' => 'update-permission',            'target' => 'permission', 'description' => 'Update permission data'],
            ['name' => 'delete-permission',            'target' => 'permission', 'description' => 'Delete a permission'],

            // ─── Role Management ──────────────────────────────────────────
            ['name' => 'view-role',               'target' => 'role', 'description' => 'View the role list'],
            ['name' => 'create-role',             'target' => 'role', 'description' => 'Create a new role'],
            ['name' => 'update-role',             'target' => 'role', 'description' => 'Update role data'],
            ['name' => 'delete-role',             'target' => 'role', 'description' => 'Delete a role'],

            // ─── User Management ──────────────────────────────────────────
            ['name' => 'view-user',               'target' => 'user', 'description' => 'View the user list'],
            ['name' => 'create-user',             'target' => 'user', 'description' => 'Add a new user'],
            ['name' => 'update-user',             'target' => 'user', 'description' => 'Update user data'],
            ['name' => 'delete-user',             'target' => 'user', 'description' => 'Delete user data'],

            // ─── Room Management ──────────────────────────────────────────
            ['name' => 'view-room',               'target' => 'room', 'description' => 'View the room list (including public rooms)'],
            ['name' => 'create-room',             'target' => 'room', 'description' => 'Add a new room'],
            ['name' => 'update-room',             'target' => 'room', 'description' => 'Update room data'],
            ['name' => 'delete-room',             'target' => 'room', 'description' => 'Delete room data'],

            // ─── Lease / Sewa ─────────────────────────────────────────────
            ['name' => 'view-lease',    'target' => 'lease', 'description' => 'View the lease list / reservation management'],
            ['name' => 'approve-lease', 'target' => 'lease', 'description' => 'Approve or reject a lease request'],
            ['name' => 'create-lease',  'target' => 'lease', 'description' => 'Apply for a new room lease'],
            ['name' => 'extend-lease',  'target' => 'lease', 'description' => 'Extend an active lease (for active residents only)'],

            // ─── Finance ──────────────────────────────────────────────────
            ['name' => 'finance-dashboard-view',    'target' => 'finance', 'description' => 'View the finance summary dashboard'],
            ['name' => 'finance-payment-view',      'target' => 'finance', 'description' => 'View the full payment history (admin)'],
            ['name' => 'finance-payment-verify',    'target' => 'finance', 'description' => 'Verify a manual payment'],
            ['name' => 'finance-payment-refund',    'target' => 'finance', 'description' => 'Process a payment refund'],
            ['name' => 'finance-invoice-view',      'target' => 'finance', 'description' => 'View the full invoice list (admin)'],
            ['name' => 'finance-invoice-create',    'target' => 'finance', 'description' => 'Create a payment invoice (resident)'],
            ['name' => 'finance-me-summary-view',   'target' => 'finance', 'description' => 'View a personal finance summary (resident)'],
            ['name' => 'finance-me-invoice-view',   'target' => 'finance', 'description' => 'View personal invoices (resident)'],
            ['name' => 'finance-me-payment-view',   'target' => 'finance', 'description' => 'View personal payment history (resident)'],
            ['name' => 'finance-expense-view',      'target' => 'finance', 'description' => 'View the expense list'],
            ['name' => 'finance-expense-create',    'target' => 'finance', 'description' => 'Create a new expense'],
            ['name' => 'finance-expense-update',    'target' => 'finance', 'description' => 'Update expense data'],
            ['name' => 'finance-expense-delete',    'target' => 'finance', 'description' => 'Delete expense data'],
            ['name' => 'finance-fixed-expense-view',   'target' => 'finance', 'description' => 'View the monthly fixed expense list'],
            ['name' => 'finance-fixed-expense-create', 'target' => 'finance', 'description' => 'Record a new monthly fixed expense'],
            ['name' => 'finance-fixed-expense-update', 'target' => 'finance', 'description' => 'Update a monthly fixed expense entry'],
            ['name' => 'finance-fixed-expense-delete', 'target' => 'finance', 'description' => 'Delete a monthly fixed expense entry'],
            ['name' => 'finance-fine-view',            'target' => 'finance', 'description' => 'View the fine list (admin)'],
            ['name' => 'finance-fine-create',          'target' => 'finance', 'description' => 'Create a fine for a user'],
            ['name' => 'finance-fine-waive',           'target' => 'finance', 'description' => 'Waive or cancel a fine'],
            ['name' => 'finance-me-fine-view',         'target' => 'finance', 'description' => 'View personal fines and pay them'],

            // ─── Inventory ────────────────────────────────────────────────
            ['name' => 'view-inventory',               'target' => 'inventory', 'description' => 'View the inventory list'],
            ['name' => 'create-inventory',             'target' => 'inventory', 'description' => 'Add an inventory item'],
            ['name' => 'update-inventory',             'target' => 'inventory', 'description' => 'Update inventory data'],
            ['name' => 'delete-inventory',             'target' => 'inventory', 'description' => 'Delete inventory data'],

            // ─── Maintenance ──────────────────────────────────────────────
            ['name' => 'view-maintenance',              'target' => 'maintenance', 'description' => 'View maintenance schedules and tasks'],
            ['name' => 'create-maintenance',            'target' => 'maintenance', 'description' => 'Create a maintenance task (admin)'],
            ['name' => 'update-maintenance',            'target' => 'maintenance', 'description' => 'Update the maintenance status'],
            ['name' => 'delete-maintenance',            'target' => 'maintenance', 'description' => 'Delete maintenance data'],
            ['name' => 'schedule-maintenance',          'target' => 'maintenance', 'description' => 'Create a maintenance schedule'],
            ['name' => 'view-damage-report',            'target' => 'maintenance', 'description' => 'View all damage reports (admin)'],
            ['name' => 'create-damage-report',          'target' => 'maintenance', 'description' => 'Report damage (resident)'],
            ['name' => 'view-my-damage-report',         'target' => 'maintenance', 'description' => 'View your own damage reports (resident)'],

            // ─── Resident ─────────────────────────────────────────────────
            ['name' => 'view-resident',               'target' => 'resident', 'description' => 'View the resident list'],
            ['name' => 'create-resident',             'target' => 'resident', 'description' => 'Add a resident manually'],
            ['name' => 'update-resident',             'target' => 'resident', 'description' => 'Update resident data'],
            ['name' => 'delete-resident',             'target' => 'resident', 'description' => 'Delete resident data'],
            ['name' => 'complete-resident-profile',   'target' => 'resident', 'description' => 'Complete the profile to become an official resident'],

            // ─── Notification ─────────────────────────────────────────────
            ['name' => 'notification-log-view',  'target' => 'notification', 'description' => 'View the WhatsApp notification log history'],
            ['name' => 'notification-send',      'target' => 'notification', 'description' => 'Send a custom notification and resend failed notifications'],

            // ─── Setting ──────────────────────────────────────────────────
            ['name' => 'setting-view',               'target' => 'setting', 'description' => 'View the settings details'],
            ['name' => 'setting-update',             'target' => 'setting', 'description' => 'Save setting changes'],

            // ─── Guest ────────────────────────────────────────────────────
            ['name' => 'view-guest',         'target' => 'guest', 'description' => 'View all guest data (admin)'],
            ['name' => 'view-my-guest',      'target' => 'guest', 'description' => 'View your own guest list (active resident)'],
            ['name' => 'create-guest',       'target' => 'guest', 'description' => 'Register a new guest (active resident)'],
            ['name' => 'delete-guest',       'target' => 'guest', 'description' => 'Delete your own guest data (active resident)'],
            ['name' => 'pay-guest-bill',     'target' => 'guest', 'description' => 'Pay a guest bill (active resident)'],
            ['name' => 'verify-guest-bill',  'target' => 'guest', 'description' => 'Verify a guest bill payment (admin)'],
            ['name' => 'view-guest-bill',    'target' => 'guest', 'description' => 'View all guest bills (admin)'],
            ['name' => 'checkout-guest',     'target' => 'guest', 'description' => 'Mark a guest as checked out (admin)'],
        ];

        foreach ($permissions as $permission) {
            Permission::updateOrCreate(
                ['name' => $permission['name'], 'guard_name' => 'api'],
                [
                    'target' => $permission['target'],
                    'description' => $permission['description'],
                ]
            );
        }

        $this->command->info('PermissionSeeder ran successfully!');
    }
}

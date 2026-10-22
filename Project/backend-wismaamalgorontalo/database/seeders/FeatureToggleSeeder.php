<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Modules\Setting\Models\FeatureToggle;

class FeatureToggleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        FeatureToggle::truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // 1. AUTH (Core)
        $authModule = FeatureToggle::create([
            'name' => 'Account Login',
            'key' => 'auth',
            'description' => 'Authentication, Access & Roles (Required)',
            'icon' => 'lock',
            'is_active' => true,
            'is_locked' => true,
        ]);

        $authFeatures = [
            ['name' => 'Account Registration', 'key' => 'auth_registration', 'description' => 'Allows prospective residents to register directly through the app.', 'icon' => 'app_registration'],
        ];

        foreach ($authFeatures as $feat) {
            FeatureToggle::create([
                'parent_id' => $authModule->id,
                'name' => $feat['name'],
                'key' => $feat['key'],
                'description' => $feat['description'],
                'icon' => $feat['icon'],
                'is_active' => true,
                'is_locked' => false,
            ]);
        }

        // 1. CORE MODULES (Locked)
        $coreModules = [
            ['name' => 'Room', 'key' => 'room', 'description' => 'Room & Facility Management (Required)', 'icon' => 'meeting_room'],
            ['name' => 'Schedule', 'key' => 'schedule', 'description' => 'Resident Registration & Reservation (Required)', 'icon' => 'calendar_month'],
            ['name' => 'Setting', 'key' => 'setting', 'description' => 'Main System Settings (Required)', 'icon' => 'settings'],
        ];

        foreach ($coreModules as $mod) {
            FeatureToggle::create([
                'name' => $mod['name'],
                'key' => $mod['key'],
                'description' => $mod['description'],
                'icon' => $mod['icon'],
                'is_active' => true,
                'is_locked' => true, // Locked for core modules
            ]);
        }

        // 2. INVENTORY (Togglable)
        $inventoryModule = FeatureToggle::create([
            'name' => 'Inventory Management',
            'key' => 'inventory', // Maps to Inventory module
            'description' => 'Records of items and assets in the boarding house and inside the rooms.',
            'icon' => 'inventory_2',
            'is_active' => true,
            'is_locked' => false,
        ]);

        // 3. MAINTENANCE (Togglable)
        $maintenanceModule = FeatureToggle::create([
            'name' => 'Maintenance Management',
            'key' => 'maintenance', // Maps to Maintenance module
            'description' => 'Manage cleaning schedules and damage reporting.',
            'icon' => 'home_repair_service',
            'is_active' => true,
            'is_locked' => false,
        ]);

        $maintenanceFeatures = [
            ['name' => 'Maintenance Schedule', 'key' => 'maintenance_schedule', 'description' => 'Create routine schedules for cleaning rooms or facilities.', 'icon' => 'cleaning_services'],
            ['name' => 'Damage Report', 'key' => 'damage_report', 'description' => 'Allows residents to report damage directly from the app.', 'icon' => 'report_problem'],
        ];

        foreach ($maintenanceFeatures as $feat) {
            FeatureToggle::create([
                'name' => $feat['name'],
                'key' => $feat['key'],
                'description' => $feat['description'],
                'icon' => $feat['icon'],
                'is_active' => true,
                'is_locked' => false,
                'parent_id' => $maintenanceModule->id,
            ]);
        }

        // 3. FINANCE (Togglable)
        $financeModule = FeatureToggle::create([
            'name' => 'Finance Management',
            'key' => 'finance', // Maps to Finance module
            'description' => 'Manage cash flow, invoices, payments, and boarding house expenses.',
            'icon' => 'account_balance_wallet',
            'is_active' => true,
            'is_locked' => false,
        ]);

        // Pengeluaran umum: inti, tidak bisa dimatikan
        FeatureToggle::create([
            'name' => 'Expense Tracking',
            'key' => 'finance_expense',
            'description' => 'Records boarding house operational expenses (required).',
            'icon' => 'receipt_long',
            'is_active' => true,
            'is_locked' => true,
            'parent_id' => $financeModule->id,
        ]);

        $financeFeatures = [
            ['name' => 'Midtrans Payment (Online)', 'key' => 'finance_midtrans', 'description' => 'Midtrans integration for Virtual Account, QRIS, and other payment methods.', 'icon' => 'payment'],
            ['name' => 'Monthly Fixed Expenses', 'key' => 'finance_fixed_expense', 'description' => 'Reminders and records for fixed bills (PLN, PDAM, WiFi).', 'icon' => 'bolt'],
        ];

        foreach ($financeFeatures as $feat) {
            FeatureToggle::create([
                'name' => $feat['name'],
                'key' => $feat['key'],
                'description' => $feat['description'],
                'icon' => $feat['icon'],
                'is_active' => true,
                'is_locked' => false,
                'parent_id' => $financeModule->id,
            ]);
        }

        // 4. GUEST (Togglable)
        FeatureToggle::create([
            'name' => 'Guest Management',
            'key' => 'guest', // Maps to Guest module
            'description' => 'Allows residents to register guests and charge an additional rate when needed.',
            'icon' => 'group_add',
            'is_active' => true,
            'is_locked' => false,
        ]);

        // 5. NOTIFICATION (Togglable)
        $notifModule = FeatureToggle::create([
            'name' => 'System & WhatsApp Notifications',
            'key' => 'notification', // Maps to Notification module
            'description' => 'Configure automatic WhatsApp notifications for residents.',
            'icon' => 'notifications_active',
            'is_active' => true,
            'is_locked' => false,
        ]);

        $notifFeatures = [
            ['name' => 'WhatsApp Payment Receipt', 'key' => 'notif_receipt', 'description' => 'Automatically sends a payment proof via WhatsApp after verification.', 'icon' => 'mark_chat_read'],
            ['name' => 'Due Date Reminder', 'key' => 'notif_due_reminder', 'description' => 'Sends automatic WhatsApp reminders 7, 3, 2, and 1 days before, and on the day the lease ends.', 'icon' => 'alarm'],
            ['name' => 'Include Invoice PDF Link in WhatsApp', 'key' => 'notif_pdf_link', 'description' => 'Includes a PDF receipt download link in the WhatsApp message.', 'icon' => 'picture_as_pdf'],
        ];

        foreach ($notifFeatures as $feat) {
            FeatureToggle::create([
                'name' => $feat['name'],
                'key' => $feat['key'],
                'description' => $feat['description'],
                'icon' => $feat['icon'],
                'is_active' => true,
                'is_locked' => false,
                'parent_id' => $notifModule->id,
            ]);
        }
    }
}

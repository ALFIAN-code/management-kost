<?php

namespace Modules\Setting\database\seeders;

use Illuminate\Database\Seeder;
use Modules\Setting\Services\SettingService;

class SettingDatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $settingService = app(SettingService::class);

        $settings = [
            'wisma_name' => 'Wisma Amal Gorontalo',
            'wisma_address' => 'St. Wisma Amal No. 1, Gorontalo',
            'wisma_phone' => '0811-4300-XXX',
            'wisma_email' => 'wismaamal@email.com',
            'wisma_maps_link' => 'https://maps.google.com',
            'wisma_operational_hours' => 'Monday - Saturday, 08.00 - 17.00 WITA',
            'bank_name' => 'Bank BSI',
            'bank_account' => '7123456789',
            'bank_holder' => 'Wisma Amal Gorontalo',
            'landing_header_title' => 'Discover Comfortable Living at Wisma Amal Gorontalo',
            'landing_header_subtitle' => 'Check room availability, browse the facilities, and make a reservation in seconds.',
            'landing_facilities' => 'Fast WiFi, 24-Hour Security, Wide Parking Area, Shared Kitchen',
            'landing_highlighted_rooms' => '[]',
        ];

        foreach ($settings as $key => $value) {
            $settingService->updateSetting($key, $value);
        }

        $settingService->setEnabledMidtransPaymentMethods(['qris', 'gopay', 'bca_va', 'mandiri_va']);
        $settingService->setMidtransFeeConfig(SettingService::defaultMidtransFeeConfig());

        // Pengeluaran Tetap (default: nonaktif)
        $settingService->setJenisPengeluaranTetapAktif([]);
    }
}

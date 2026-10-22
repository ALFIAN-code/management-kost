<?php

namespace Modules\Inventory\database\seeders;

use Illuminate\Database\Seeder;

class InventoryDatabaseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $items = [
            ['name' => 'Single King Koil Bed', 'description' => 'High-quality bed for standard rooms', 'quantity' => 10, 'condition' => 'good', 'purchase_price' => 2500000],
            ['name' => 'Sharp Split AC 1/2 PK', 'description' => 'Energy-efficient air conditioner', 'quantity' => 15, 'condition' => 'good', 'purchase_price' => 3200000],
            ['name' => 'Teak Wood Wardrobe', 'description' => 'Minimalist two-door wardrobe', 'quantity' => 20, 'condition' => 'good', 'purchase_price' => 1500000],
            ['name' => 'Minimalist Study Desk', 'description' => 'Wooden desk with drawers', 'quantity' => 20, 'condition' => 'good', 'purchase_price' => 450000],
            ['name' => 'Ergonomic Office Chair', 'description' => 'Chair with a backrest', 'quantity' => 20, 'condition' => 'good', 'purchase_price' => 650000],
            ['name' => 'Silicone Microfiber Pillow', 'description' => 'Soft hotel-standard pillow', 'quantity' => 40, 'condition' => 'good', 'purchase_price' => 85000],
            ['name' => 'Silicone Microfiber Bolster', 'description' => 'Soft hotel-standard bolster', 'quantity' => 40, 'condition' => 'good', 'purchase_price' => 90000],
            ['name' => 'Samsung 32-inch LED TV', 'description' => 'Smart TV for suite rooms', 'quantity' => 5, 'condition' => 'good', 'purchase_price' => 2100000],
            ['name' => 'Portable Mini Refrigerator', 'description' => 'Small refrigerator for suite rooms', 'quantity' => 5, 'condition' => 'good', 'purchase_price' => 1200000],
            ['name' => 'Sharp Water Dispenser', 'description' => 'Dispenser in the common area', 'quantity' => 2, 'condition' => 'fair', 'purchase_price' => 1800000],
            ['name' => 'Grey 2-Seater Sofa', 'description' => 'Sofa for the suite living room area', 'quantity' => 5, 'condition' => 'good', 'purchase_price' => 2800000],
            ['name' => 'LG Front Load Washing Machine', 'description' => 'Shared laundry facility', 'quantity' => 2, 'condition' => 'good', 'purchase_price' => 4500000],
            ['name' => 'Large Wall Mirror', 'description' => 'Decorative mirror in the room', 'quantity' => 20, 'condition' => 'good', 'purchase_price' => 150000],
            ['name' => 'Philips 9W LED Lamp', 'description' => 'Spare lamp stock', 'quantity' => 50, 'condition' => 'good', 'purchase_price' => 35000],
            ['name' => 'White Cotton Bed Sheet Set', 'description' => 'One set of bed sheets and a pillowcase', 'quantity' => 60, 'condition' => 'good', 'purchase_price' => 120000],
        ];

        foreach ($items as $item) {
            \Modules\Inventory\Models\Inventory::create($item);
        }
    }
}

<?php

namespace Modules\Maintenance\database\seeders;

use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Modules\Auth\Models\User;
use Modules\Maintenance\Enums\ScheduleStatus;
use Modules\Maintenance\Enums\ScheduleSubtype;
use Modules\Maintenance\Enums\ScheduleType;
use Modules\Maintenance\Models\MaintenanceSchedule;

class MaintenanceScheduleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $admin = User::whereHas('roles', function ($q) {
            $q->where('name', 'super-admin')->orWhere('name', 'admin');
        })->first();

        if (! $admin) {
            return;
        }

        $schedules = [
            [
                'technician_name' => 'Budi Santoso (AC Specialist)',
                'location' => 'Floor 1 & 2',
                'type' => ScheduleType::PERAWATAN,
                'subtype' => ScheduleSubtype::MAINTENANCE,
                'status' => ScheduleStatus::DONE,
                'notes' => 'AC filter cleaning and a routine monthly freon check.',
                'start_time' => Carbon::now()->subDays(5)->setHour(9),
                'end_time' => Carbon::now()->subDays(5)->setHour(15),
            ],
            [
                'technician_name' => 'Berkah Cleaning Team',
                'location' => 'All Common Areas',
                'type' => ScheduleType::PEMBERSIHAN,
                'subtype' => ScheduleSubtype::DEEP_CLEANING,
                'status' => ScheduleStatus::DONE,
                'notes' => 'Fogging of the parking area and cleaning of the outer window glass.',
                'start_time' => Carbon::now()->subDays(10)->setHour(8),
                'end_time' => Carbon::now()->subDays(10)->setHour(16),
            ],
            [
                'technician_name' => 'Agus Perdana',
                'location' => 'Suite Rooms 401-405',
                'type' => ScheduleType::PERAWATAN,
                'subtype' => ScheduleSubtype::RUTIN,
                'status' => ScheduleStatus::IN_PROGRESS,
                'notes' => 'Routine check of the suite room facilities (TV, refrigerator, water heater).',
                'start_time' => Carbon::now()->addDays(1)->setHour(10),
                'end_time' => Carbon::now()->addDays(1)->setHour(14),
            ],
            [
                'technician_name' => 'Terminator Pest Control',
                'location' => 'Kitchen & Storage Area',
                'type' => ScheduleType::PEMBERSIHAN,
                'subtype' => ScheduleSubtype::RUTIN,
                'status' => ScheduleStatus::IN_PROGRESS,
                'notes' => 'Quarterly routine anti-pest spraying (cockroaches and ants).',
                'start_time' => Carbon::now()->addDays(3)->setHour(13),
                'end_time' => Carbon::now()->addDays(3)->setHour(15),
            ],
            [
                'technician_name' => 'Dedi Junaedi',
                'location' => 'Main Electrical Panel',
                'type' => ScheduleType::PERAWATAN,
                'subtype' => ScheduleSubtype::MAINTENANCE,
                'status' => ScheduleStatus::IN_PROGRESS,
                'notes' => 'Load check and inspection of the main panel cabling.',
                'start_time' => Carbon::now()->addDays(5)->setHour(9),
                'end_time' => Carbon::now()->addDays(5)->setHour(11),
            ],
        ];

        foreach ($schedules as $data) {
            MaintenanceSchedule::create(array_merge($data, [
                'created_by' => $admin->id,
            ]));
        }
    }
}

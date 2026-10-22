<?php

namespace Modules\Maintenance\database\seeders;

use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Modules\Auth\Models\User;
use Modules\Maintenance\Enums\MaintenanceStatus;
use Modules\Maintenance\Models\MaintenanceRequest;
use Modules\Maintenance\Models\MaintenanceRequestUpdate;
use Modules\Schedule\Models\Schedule;

class MaintenanceRequestSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $members = User::whereHas('roles', fn ($q) => $q->where('name', 'member'))->get();
        $admin = User::whereHas('roles', function ($q) {
            $q->where('name', 'super-admin')->orWhere('name', 'admin');
        })->first();

        if ($members->isEmpty() || ! $admin) {
            return;
        }

        $scenarios = [
            [
                'title' => 'Leaking Faucet in the Bathroom',
                'description' => 'The bathroom sink faucet keeps dripping even when it is turned all the way. Please fix it as soon as possible so that no water is wasted.',
                'status' => MaintenanceStatus::PENDING,
                'days_ago' => 2,
            ],
            [
                'title' => 'Room Light Dims and Flickers',
                'description' => 'The main light in the room is starting to dim and flickers a lot, which is very distracting at night.',
                'status' => MaintenanceStatus::IN_PROGRESS,
                'days_ago' => 5,
                'update' => 'The repairman is on the way, estimated arrival around 2 PM.',
            ],
            [
                'title' => 'AC Not Cooling',
                'description' => 'The AC in the room only blows air and does not cool as usual. It may need a freon refill or an AC cleaning.',
                'status' => MaintenanceStatus::COMPLETED,
                'days_ago' => 10,
                'update' => 'The AC has been cleaned and the freon has been refilled. It is cooling properly again.',
            ],
            [
                'title' => 'Gate Door Makes a Loud Noise',
                'description' => 'The front gate hinge makes a very loud noise when the door is opened or closed.',
                'status' => MaintenanceStatus::CANCELLED,
                'days_ago' => 1,
                'update' => 'It has already been fixed by the night guard.',
            ],
            [
                'title' => 'Sink Drain is Blocked',
                'description' => 'Water in the sink drains very slowly, there seems to be a blockage in the waste pipe.',
                'status' => MaintenanceStatus::PENDING,
                'days_ago' => 3,
            ],
            [
                'title' => 'Loose Power Socket',
                'description' => 'The socket next to the bed is loose and shakes when the charger is plugged in, there is a risk of a short circuit.',
                'status' => MaintenanceStatus::IN_PROGRESS,
                'days_ago' => 4,
                'update' => 'The in-house technician is checking the availability of replacement parts.',
            ],
            [
                'title' => 'Broken Bathroom Door Handle',
                'description' => 'The bathroom door handle is hard to turn and often gets stuck, it nearly locked itself earlier this morning.',
                'status' => MaintenanceStatus::PENDING,
                'days_ago' => 1,
            ],
            [
                'title' => 'Window Cannot Be Locked',
                'description' => 'The window latch is broken so it cannot be locked properly, please fix it as soon as possible for safety.',
                'status' => MaintenanceStatus::COMPLETED,
                'days_ago' => 15,
                'update' => 'The window latch has been replaced with a new one.',
            ],
            [
                'title' => 'Missing or Broken AC Remote',
                'description' => 'The AC remote does not work even though the battery has just been replaced.',
                'status' => MaintenanceStatus::PENDING,
                'days_ago' => 6,
            ],
            [
                'title' => 'Damp and Mouldy Room Walls',
                'description' => 'Water is seeping from the ceiling, making the walls damp and black mould starting to grow.',
                'status' => MaintenanceStatus::IN_PROGRESS,
                'days_ago' => 8,
                'update' => 'The floor above has been checked and a leak was found in the water pipe. A pipe repair is being coordinated.',
            ],
        ];

        foreach ($scenarios as $index => $data) {
            $member = $members[$index % $members->count()];
            $activeSchedule = Schedule::where('tenant_user_id', $member->id)
                ->where('status', 'active')
                ->first();
            $roomId = $activeSchedule?->room_id;

            if (! $roomId) {
                continue;
            }

            $request = MaintenanceRequest::create([
                'room_id' => $roomId,
                'reporter_user_id' => $member->id,
                'reporter_name' => $member->name,
                'title' => $data['title'],
                'description' => $data['description'],
                'status' => $data['status'],
                'reported_at' => Carbon::now()->subDays($data['days_ago']),
            ]);

            if (isset($data['update'])) {
                MaintenanceRequestUpdate::create([
                    'maintenance_request_id' => $request->id,
                    'user_id' => $admin->id,
                    'status' => $data['status'],
                    'description' => $data['update'],
                ]);
            }
        }
    }
}

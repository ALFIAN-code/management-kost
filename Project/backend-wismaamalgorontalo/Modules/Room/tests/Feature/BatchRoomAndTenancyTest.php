<?php

namespace Modules\Room\tests\Feature;

use App\Models\Building;
use App\Support\TenantContext;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Laravel\Sanctum\Sanctum;
use Modules\Auth\Models\User;
use Modules\Room\Models\Room;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class BatchRoomAndTenancyTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    private Building $buildingA;

    private Building $buildingB;

    protected function setUp(): void
    {
        parent::setUp();

        $this->mock(\Modules\Setting\Services\FeatureToggleService::class, function ($mock) {
            $mock->shouldReceive('isEnabled')->andReturn(true);
            $mock->shouldReceive('getHierarchicalToggles')->andReturn([]);
        });

        $role = Role::create(['name' => 'admin', 'guard_name' => 'api']);
        $pCreate = Permission::create(['name' => 'create-room', 'guard_name' => 'api']);
        $pUpdate = Permission::create(['name' => 'update-room', 'guard_name' => 'api']);
        $pDelete = Permission::create(['name' => 'delete-room', 'guard_name' => 'api']);
        $role->givePermissionTo([$pCreate, $pUpdate, $pDelete]);

        $this->admin = User::factory()->create([
            'email' => 'admin@kost.test',
        ]);
        $this->admin->assignRole('admin');

        $this->buildingA = Building::create([
            'name' => 'Kost Utama Kampus',
            'address' => 'Jl. Pendidikan No. 1',
            'owner_id' => $this->admin->id,
        ]);

        $this->buildingB = Building::create([
            'name' => 'Kost Cabang Dua',
            'address' => 'Jl. Melati No. 45',
            'owner_id' => $this->admin->id,
        ]);

        TenantContext::clear();
    }

    public function test_batch_generate_creates_rooms_in_range(): void
    {
        Sanctum::actingAs($this->admin, ['*']);

        $response = $this->postJson('/api/rooms/batch-generate', [
            'prefix' => 'A-',
            'start_number' => 101,
            'end_number' => 105,
            'price' => 1250000,
            'facilities' => ['AC', 'WiFi', 'Kamar Mandi Dalam'],
            'title_template' => 'Kamar Deluxe {number}',
            'building_id' => $this->buildingA->id,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => [
                    'total_requested' => 5,
                    'created_count' => 5,
                    'skipped_count' => 0,
                ],
            ]);

        $this->assertEquals(5, Room::where('building_id', $this->buildingA->id)->count());
        $this->assertDatabaseHas('rooms', [
            'number' => 'A-101',
            'title' => 'Kamar Deluxe A-101',
            'price' => 1250000,
            'building_id' => $this->buildingA->id,
        ]);
        $this->assertDatabaseHas('rooms', [
            'number' => 'A-105',
            'title' => 'Kamar Deluxe A-105',
        ]);
    }

    public function test_batch_generate_skips_existing_rooms_gracefully(): void
    {
        Sanctum::actingAs($this->admin, ['*']);

        // Buat kamar awal
        Room::create([
            'number' => 'B-202',
            'title' => 'Kamar B-202',
            'price' => 1000000,
            'status' => 'available',
            'building_id' => $this->buildingB->id,
        ]);

        $response = $this->postJson('/api/rooms/batch-generate', [
            'prefix' => 'B-',
            'start_number' => 201,
            'end_number' => 203,
            'price' => 1000000,
            'building_id' => $this->buildingB->id,
            'skip_existing' => true,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => [
                    'total_requested' => 3,
                    'created_count' => 2,
                    'skipped_count' => 1,
                    'skipped_numbers' => ['B-202'],
                ],
            ]);
    }

    public function test_batch_store_creates_multiple_rooms_from_array(): void
    {
        Sanctum::actingAs($this->admin, ['*']);

        $response = $this->postJson('/api/rooms/batch-store', [
            'rooms' => [
                ['number' => 'C-01', 'title' => 'Kamar C1', 'price' => 800000],
                ['number' => 'C-02', 'title' => 'Kamar C2', 'price' => 850000],
            ],
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => [
                    'created_count' => 2,
                ],
            ]);

        $this->assertDatabaseHas('rooms', ['number' => 'C-01']);
        $this->assertDatabaseHas('rooms', ['number' => 'C-02']);
    }

    public function test_import_rooms_csv(): void
    {
        Sanctum::actingAs($this->admin, ['*']);

        $csvContent = "number,title,price,facilities,description\n";
        $csvContent .= "D-101,Kamar D 101,1500000,AC;WiFi,Lantai 1 dekat lobi\n";
        $csvContent .= "D-102,Kamar D 102,1500000,AC;WiFi,Lantai 1 menghadap taman\n";

        $file = UploadedFile::fake()->createWithContent('rooms.csv', $csvContent);

        $response = $this->postJson('/api/rooms/import-csv', [
            'file' => $file,
            'building_id' => $this->buildingA->id,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => [
                    'created_count' => 2,
                ],
            ]);

        $this->assertDatabaseHas('rooms', ['number' => 'D-101', 'price' => 1500000]);
        $this->assertDatabaseHas('rooms', ['number' => 'D-102', 'price' => 1500000]);
    }

    public function test_tenancy_isolation_with_header(): void
    {
        Sanctum::actingAs($this->admin, ['*']);

        // Kamar di Building A
        Room::create([
            'number' => 'GA-1',
            'title' => 'Room in Gedung A',
            'price' => 1000000,
            'status' => 'available',
            'building_id' => $this->buildingA->id,
        ]);

        // Kamar di Building B
        Room::create([
            'number' => 'GB-1',
            'title' => 'Room in Gedung B',
            'price' => 1000000,
            'status' => 'available',
            'building_id' => $this->buildingB->id,
        ]);

        // Request dengan X-Building-ID Building A
        $responseA = $this->withHeader('X-Building-ID', (string) $this->buildingA->id)
            ->getJson('/api/rooms');

        $responseA->assertStatus(200);
        $dataA = $responseA->json('data.data') ?? $responseA->json('data');

        // Pastikan hanya kamar Building A yang muncul
        $numbersA = collect($dataA)->pluck('number')->all();
        $this->assertContains('GA-1', $numbersA);
        $this->assertNotContains('GB-1', $numbersA);
    }

    public function test_switch_building_endpoint(): void
    {
        Sanctum::actingAs($this->admin, ['*']);

        $response = $this->postJson("/api/buildings/{$this->buildingB->id}/switch");

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => [
                    'active_building' => [
                        'id' => $this->buildingB->id,
                        'name' => 'Kost Cabang Dua',
                    ],
                ],
            ]);

        $this->assertEquals($this->buildingB->id, $this->admin->fresh()->assigned_building_id);
    }
}

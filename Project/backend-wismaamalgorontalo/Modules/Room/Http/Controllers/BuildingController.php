<?php

namespace Modules\Room\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Building;
use App\Support\TenantContext;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class BuildingController extends Controller
{
    use ApiResponse;

    /**
     * Daftar Properti / Gedung
     */
    public function index(Request $request)
    {
        $user = $request->user();

        // Jika super-admin atau admin dapat melihat semua
        if ($user && ($user->hasRole('super-admin') || $user->hasRole('admin'))) {
            $buildings = Building::withCount('rooms')->latest()->get();
        } else {
            // Pengguna hanya melihat properti miliknya atau yang di-assign
            $buildings = Building::withCount('rooms')
                ->where('owner_id', $user?->id)
                ->orWhere('id', $user?->assigned_building_id)
                ->latest()
                ->get();
        }

        return $this->apiSuccess($buildings, 'Daftar gedung berhasil diambil');
    }

    /**
     * Tambah Gedung / Properti Baru
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:150',
            'address' => 'required|string',
            'phone_number' => 'nullable|string|max:20',
        ]);

        $validated['owner_id'] = $request->user()?->id;

        $building = Building::create($validated);

        // Jika user belum punya assigned building, assign otomatis
        if ($request->user() && empty($request->user()->assigned_building_id)) {
            $request->user()->update(['assigned_building_id' => $building->id]);
        }

        return $this->apiSuccess($building, 'Gedung/properti berhasil dibuat', 201);
    }

    /**
     * Detail Gedung
     */
    public function show($id)
    {
        $building = Building::with(['owner', 'rooms'])->findOrFail($id);

        return $this->apiSuccess($building, 'Detail gedung berhasil diambil');
    }

    /**
     * Update Gedung
     */
    public function update(Request $request, $id)
    {
        $building = Building::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:150',
            'address' => 'sometimes|required|string',
            'phone_number' => 'nullable|string|max:20',
        ]);

        $building->update($validated);

        return $this->apiSuccess($building, 'Data gedung berhasil diperbarui');
    }

    /**
     * Hapus Gedung
     */
    public function destroy($id)
    {
        $building = Building::findOrFail($id);

        if ($building->rooms()->exists()) {
            return $this->apiError('Tidak dapat menghapus gedung yang masih memiliki kamar.', 422);
        }

        $building->delete();

        return $this->apiSuccess(null, 'Gedung berhasil dihapus');
    }

    /**
     * Beralih Properti Aktif (Tenant Switcher)
     *
     * Mengatur assigned_building_id untuk user saat ini, sehingga query otomatis
     * tersaring ke gedung ini.
     */
    public function switchBuilding(Request $request, $id)
    {
        $building = Building::findOrFail($id);
        $user = $request->user();

        if ($user) {
            $user->update(['assigned_building_id' => $building->id]);
            TenantContext::setTenantId($building->id);
        }

        return $this->apiSuccess([
            'active_building' => $building,
            'user' => $user?->fresh(['roles']),
        ], 'Berhasil beralih ke properti: '.$building->name);
    }
}

<?php

namespace Modules\Room\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Modules\Room\Http\Requests\StoreRoomRequest;
use Modules\Room\Http\Requests\UpdateRoomRequest;
use Modules\Room\Services\RoomService;
use Modules\Room\Transformers\RoomResource;

class RoomController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly RoomService $roomService
    ) {}

    /**
     * Daftar Kamar
     *
     * Mengambil daftar seluruh kamar berserta status ketersediaannya.
     *
     * @unauthenticated
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $rooms = $this->roomService->getAllRooms($request->query());

        return $this->apiSuccess(
            RoomResource::collection($rooms)->response()->getData(true),
            'Data kamar berhasil diambil'
        );
    }

    /**
     * Jadwal Kamar (Public)
     *
     * Mengambil daftar kamar beserta jadwal kosong terdekat untuk ditampilkan di katalog aplikasi.
     *
     * @unauthenticated
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function schedules()
    {
        $rooms = $this->roomService->getRoomSchedules();

        return $this->apiSuccess(
            RoomResource::collection($rooms),
            'Jadwal kamar berhasil diambil'
        );
    }

    /**
     * Tambah Kamar Baru
     *
     * Membuat data kamar baru beserta foto dan fasilitasnya. (Hanya Admin)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(StoreRoomRequest $request)
    {
        $room = $this->roomService->createRoom(
            $request->validated(),
            $request->file('images', [])
        );

        return $this->apiSuccess(new RoomResource($room), 'Kamar berhasil dibuat', 201);
    }

    /**
     * Detail Kamar
     *
     * Mengambil detail lengkap suatu kamar berdasarkan ID.
     *
     * @unauthenticated
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $room = $this->roomService->getRoomDetails($id);

        return $this->apiSuccess(new RoomResource($room), 'Detail kamar berhasil diambil');
    }

    /**
     * Update Kamar
     *
     * Memperbarui data kamar berdasarkan ID. (Hanya Admin)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(UpdateRoomRequest $request, $id)
    {
        $updatedRoom = $this->roomService->updateRoom(
            $id,
            $request->validated(),
            $request->file('images', [])
        );

        return $this->apiSuccess(new RoomResource($updatedRoom), 'Kamar berhasil diupdate');
    }

    /**
     * Hapus Kamar
     *
     * Menghapus data kamar berdasarkan ID secara permanen. (Hanya Admin)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $this->roomService->deleteRoom($id);

        return $this->apiSuccess(null, 'Kamar berhasil dihapus');
    }

    /**
     * Upload Foto Kamar
     *
     * Menambahkan foto-foto baru ke kamar yang sudah ada. (Hanya Admin)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function uploadImages(Request $request, $id)
    {
        $request->validate(['images' => 'required|array', 'images.*' => 'image|max:5120']);
        $room = $this->roomService->getRoomDetails($id);

        $this->roomService->uploadImages($room, $request->file('images'));

        return $this->apiSuccess(new RoomResource($room->refresh()), 'Foto berhasil ditambahkan');
    }

    /**
     * Hapus Foto Kamar
     *
     * Menghapus foto kamar tertentu. (Hanya Admin)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteImage($roomId, $imageId)
    {
        $this->roomService->deleteImage($imageId);

        return $this->apiSuccess(null, 'Foto berhasil dihapus');
    }

    /**
     * Generator Batch Kamar (Rentang Nomor)
     *
     * Membuat serangkaian kamar baru secara otomatis berdasarkan pola (misal: 101 s/d 115).
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function batchGenerate(Request $request)
    {
        $validated = $request->validate([
            'prefix' => 'nullable|string|max:20',
            'start_number' => 'required|integer|min:1',
            'end_number' => 'required|integer|gte:start_number',
            'pad_length' => 'nullable|integer|min:0|max:10',
            'title_template' => 'nullable|string|max:100',
            'price' => 'required|numeric|min:0',
            'price_daily' => 'nullable|numeric|min:0',
            'facilities' => 'nullable|array',
            'facilities.*' => 'string',
            'description' => 'nullable|string',
            'building_id' => 'nullable|integer',
            'skip_existing' => 'nullable|boolean',
        ]);

        try {
            $result = $this->roomService->generateRoomsBatch($validated);

            return $this->apiSuccess(
                $result,
                "Berhasil men-generate {$result['created_count']} kamar baru."
            );
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), 422);
        }
    }

    /**
     * Batch Store Kamar (Array Data)
     *
     * Menyimpan banyak kamar sekaligus dari payload JSON array.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function batchStore(Request $request)
    {
        $validated = $request->validate([
            'rooms' => 'required|array|min:1',
            'rooms.*.number' => 'required|string|max:50',
            'rooms.*.title' => 'nullable|string|max:255',
            'rooms.*.price' => 'required|numeric|min:0',
            'rooms.*.price_daily' => 'nullable|numeric|min:0',
            'rooms.*.facilities' => 'nullable|array',
            'rooms.*.description' => 'nullable|string',
        ]);

        try {
            $result = $this->roomService->bulkCreateRooms($validated['rooms']);

            return $this->apiSuccess(
                $result,
                "Berhasil menambahkan {$result['created_count']} kamar baru secara massal."
            );
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), 422);
        }
    }

    /**
     * Import Kamar via CSV / Spreadsheet
     *
     * Mengunggah file CSV untuk mengimpor data kamar secara massal.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function importCsv(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:csv,txt|max:5120',
            'building_id' => 'nullable|integer',
        ]);

        try {
            $result = $this->roomService->importRoomsCsv(
                $request->file('file'),
                $request->input('building_id')
            );

            return $this->apiSuccess(
                $result,
                "Berhasil mengimpor {$result['created_count']} kamar dari file CSV."
            );
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), 422);
        }
    }
}

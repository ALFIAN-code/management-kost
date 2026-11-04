<?php

namespace Modules\Room\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Modules\Room\Contracts\RoomAvailabilityService;
use Modules\Room\Enums\RoomStatus;
use Modules\Room\Models\Room;
use Modules\Room\Repositories\Contracts\RoomRepositoryInterface;

class RoomService implements RoomAvailabilityService
{
    public function __construct(
        private readonly RoomRepositoryInterface $roomRepository,
        private readonly \App\Services\ImageService $imageService
    ) {}

    public function getAllRooms(array $filters = [])
    {
        return $this->roomRepository->getAllPaginated($filters);
    }

    public static function getTotalRoomsCount(): int
    {
        return Room::count();
    }

    public static function getOccupiedRoomsCount(): int
    {
        return Room::where('status', RoomStatus::OCCUPIED)->count();
    }

    public static function getAvailableRoomsCount(): int
    {
        return Room::where('status', RoomStatus::AVAILABLE)->count();
    }

    public function getRoomSchedules()
    {
        return $this->roomRepository->getAllWithSchedules();
    }

    public function getRoomDetails(int $id): Room
    {
        return $this->roomRepository->findById($id);
    }

    public function createRoom(array $data, array $images = []): Room
    {
        return DB::transaction(function () use ($data, $images) {
            $room = $this->roomRepository->create($data);

            if (! empty($images)) {
                $this->uploadImages($room, $images);
            }

            return $room->load('images');
        });
    }

    public function updateRoom(int $id, array $data, array $newImages = []): Room
    {
        return DB::transaction(function () use ($id, $data, $newImages) {
            $room = $this->roomRepository->findById($id);
            $room = $this->roomRepository->update($room, $data);

            if (! empty($newImages)) {
                $this->uploadImages($room, $newImages);
            }

            return $room->load('images');
        });
    }

    public function deleteRoom(int $id): void
    {
        DB::transaction(function () use ($id) {
            $room = $this->roomRepository->findById($id);
            $this->roomRepository->delete($room);
        });
    }

    public function uploadImages(Room $room, array $files): void
    {
        \Log::info('RoomService: Memulai upload gambar untuk Kamar ID '.$room->id.'. Jumlah file: '.count($files));

        foreach ($files as $index => $file) {
            if (! $file instanceof UploadedFile) {
                \Log::warning('RoomService: File pada index '.$index.' bukan instance dari UploadedFile.');

                continue;
            }

            \Log::info('RoomService: Memproses file: '.$file->getClientOriginalName().' (Size: '.$file->getSize().' bytes)');

            $folder = "rooms/{$room->id}";

            try {
                // Menggunakan global ImageService untuk compress & convert ke WebP
                $path = $this->imageService->uploadAndCompress($file, $folder);
                $thumbPath = $this->imageService->createThumbnail($file, $folder);

                $this->roomRepository->addImage($room, [
                    'image_path' => $path,
                    'thumbnail_path' => $thumbPath,
                    'order' => $index + 1,
                ]);

                \Log::info('RoomService: Berhasil simpan gambar ke database untuk file: '.$file->getClientOriginalName());
            } catch (\Exception $e) {
                \Log::error('RoomService: Gagal upload gambar index '.$index.'. Error: '.$e->getMessage());
            }
        }
    }

    public function deleteImage(int $imageId): void
    {
        $image = $this->roomRepository->findImageById($imageId);
        $this->roomRepository->deleteImage($image);
    }

    public function isAvailable(int $roomId): bool
    {
        $room = $this->roomRepository->findById($roomId);

        return $room->status === RoomStatus::AVAILABLE;
    }

    public function markAsReserved(int $roomId): void
    {
        $room = $this->roomRepository->findById($roomId);
        $this->roomRepository->update($room, ['status' => RoomStatus::RESERVED]);
    }

    public function markAsOccupied(int $roomId): void
    {
        $room = $this->roomRepository->findById($roomId);
        $this->roomRepository->update($room, ['status' => RoomStatus::OCCUPIED]);
    }

    public function markAsAvailable(int $roomId): void
    {
        $room = $this->roomRepository->findById($roomId);
        $this->roomRepository->update($room, ['status' => RoomStatus::AVAILABLE]);
    }

    public function getPrice(int $roomId, string $type = 'monthly'): float
    {
        $room = $this->roomRepository->findById($roomId);

        return $type === 'daily' ? (float) $room->price_daily : (float) $room->price;
    }

    public function getName(int $roomId): string
    {
        return $this->roomRepository->findById($roomId)->title ?? $this->roomRepository->findById($roomId)->number;
    }

    /**
     * Generator batch kamar berdasarkan pola rentang nomor (misal 101 s/d 115).
     */
    public function generateRoomsBatch(array $config): array
    {
        $prefix = $config['prefix'] ?? '';
        $startNumber = (int) ($config['start_number'] ?? 1);
        $endNumber = (int) ($config['end_number'] ?? 1);
        $padLength = (int) ($config['pad_length'] ?? 0);
        $titleTemplate = $config['title_template'] ?? 'Kamar {number}';
        $price = (float) ($config['price'] ?? 0);
        $priceDaily = isset($config['price_daily']) ? (float) $config['price_daily'] : null;
        $facilities = $config['facilities'] ?? [];
        $description = $config['description'] ?? null;
        $buildingId = $config['building_id'] ?? \App\Support\TenantContext::getTenantId();
        $skipExisting = $config['skip_existing'] ?? true;

        if ($endNumber < $startNumber) {
            throw new \InvalidArgumentException('Nomor akhir harus lebih besar atau sama dengan nomor awal.');
        }

        if (($endNumber - $startNumber) > 200) {
            throw new \InvalidArgumentException('Maksimal pembuatan kamar dalam satu batch adalah 200 unit.');
        }

        return DB::transaction(function () use (
            $prefix, $startNumber, $endNumber, $padLength, $titleTemplate,
            $price, $priceDaily, $facilities, $description, $buildingId, $skipExisting
        ) {
            $createdRooms = [];
            $skippedNumbers = [];

            for ($i = $startNumber; $i <= $endNumber; $i++) {
                $numStr = $padLength > 0 ? str_pad((string) $i, $padLength, '0', STR_PAD_LEFT) : (string) $i;
                $roomNumber = $prefix.$numStr;

                // Cek duplikasi nomor kamar
                $existsQuery = Room::where('number', $roomNumber);
                if ($buildingId) {
                    $existsQuery->where('building_id', $buildingId);
                }

                if ($existsQuery->exists()) {
                    if ($skipExisting) {
                        $skippedNumbers[] = $roomNumber;

                        continue;
                    } else {
                        throw new \DomainException("Kamar dengan nomor {$roomNumber} sudah ada.");
                    }
                }

                $title = str_replace('{number}', $roomNumber, $titleTemplate);

                $room = Room::create([
                    'number' => $roomNumber,
                    'title' => $title,
                    'price' => $price,
                    'price_daily' => $priceDaily,
                    'status' => RoomStatus::AVAILABLE,
                    'facilities' => $facilities,
                    'description' => $description,
                    'building_id' => $buildingId,
                ]);

                $createdRooms[] = $room;
            }

            return [
                'total_requested' => ($endNumber - $startNumber) + 1,
                'created_count' => count($createdRooms),
                'skipped_count' => count($skippedNumbers),
                'created_rooms' => $createdRooms,
                'skipped_numbers' => $skippedNumbers,
            ];
        });
    }

    /**
     * Menyimpan daftar kamar sekaligus dari array data.
     */
    public function bulkCreateRooms(array $roomsList): array
    {
        return DB::transaction(function () use ($roomsList) {
            $createdRooms = [];
            $buildingId = \App\Support\TenantContext::getTenantId();

            foreach ($roomsList as $roomData) {
                if (empty($roomData['number'])) {
                    continue;
                }

                if (Room::where('number', $roomData['number'])->when($buildingId, fn ($q) => $q->where('building_id', $buildingId))->exists()) {
                    continue;
                }

                $room = Room::create([
                    'number' => $roomData['number'],
                    'title' => $roomData['title'] ?? ('Kamar '.$roomData['number']),
                    'price' => $roomData['price'] ?? 0,
                    'price_daily' => $roomData['price_daily'] ?? null,
                    'status' => $roomData['status'] ?? RoomStatus::AVAILABLE,
                    'facilities' => $roomData['facilities'] ?? [],
                    'description' => $roomData['description'] ?? null,
                    'building_id' => $roomData['building_id'] ?? $buildingId,
                ]);

                $createdRooms[] = $room;
            }

            return [
                'created_count' => count($createdRooms),
                'created_rooms' => $createdRooms,
            ];
        });
    }

    /**
     * Import kamar dari file CSV/Excel teks.
     */
    public function importRoomsCsv(UploadedFile $file, ?int $buildingId = null): array
    {
        $buildingId = $buildingId ?? \App\Support\TenantContext::getTenantId();
        $handle = fopen($file->getRealPath(), 'r');
        if (! $handle) {
            throw new \Exception('Gagal membaca file CSV.');
        }

        $headers = fgetcsv($handle, 1000, ',');
        if (! $headers) {
            fclose($handle);
            throw new \Exception('File CSV kosong atau format header tidak valid.');
        }

        // Normalisasi header ke lowercase
        $headers = array_map(fn ($h) => strtolower(trim($h)), $headers);

        $numberIdx = array_search('number', $headers);
        if ($numberIdx === false) {
            $numberIdx = array_search('nomor', $headers);
        }
        $titleIdx = array_search('title', $headers);
        if ($titleIdx === false) {
            $titleIdx = array_search('nama', $headers);
        }
        $priceIdx = array_search('price', $headers);
        if ($priceIdx === false) {
            $priceIdx = array_search('harga', $headers);
        }
        $facilitiesIdx = array_search('facilities', $headers);
        if ($facilitiesIdx === false) {
            $facilitiesIdx = array_search('fasilitas', $headers);
        }
        $descriptionIdx = array_search('description', $headers);
        if ($descriptionIdx === false) {
            $descriptionIdx = array_search('deskripsi', $headers);
        }

        if ($numberIdx === false || $priceIdx === false) {
            fclose($handle);
            throw new \Exception('Kolom wajib "number" (atau "nomor") dan "price" (atau "harga") tidak ditemukan di header CSV.');
        }

        $roomsToInsert = [];
        while (($row = fgetcsv($handle, 1000, ',')) !== false) {
            if (empty($row[$numberIdx])) {
                continue;
            }

            $facilities = [];
            if ($facilitiesIdx !== false && ! empty($row[$facilitiesIdx])) {
                $facilities = array_map('trim', explode(';', $row[$facilitiesIdx]));
            }

            $roomsToInsert[] = [
                'number' => trim($row[$numberIdx]),
                'title' => ($titleIdx !== false && ! empty($row[$titleIdx])) ? trim($row[$titleIdx]) : ('Kamar '.trim($row[$numberIdx])),
                'price' => (float) preg_replace('/[^0-9.]/', '', $row[$priceIdx]),
                'facilities' => $facilities,
                'description' => ($descriptionIdx !== false && ! empty($row[$descriptionIdx])) ? trim($row[$descriptionIdx]) : null,
                'building_id' => $buildingId,
            ];
        }

        fclose($handle);

        return $this->bulkCreateRooms($roomsToInsert);
    }
}

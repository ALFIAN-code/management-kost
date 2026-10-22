<?php

namespace Modules\Room\Enums;

enum RoomStatus: string
{
    case AVAILABLE = 'available';
    case RESERVED = 'reserved';
    case OCCUPIED = 'occupied';
    case MAINTENANCE = 'maintenance';

    public function label(): string
    {
        return match ($this) {
            self::AVAILABLE => 'Available',
            self::RESERVED => 'Reserved',
            self::OCCUPIED => 'Occupied',
            self::MAINTENANCE => 'Under Repair',
        };
    }
}

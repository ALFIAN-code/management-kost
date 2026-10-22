<?php

namespace Modules\Guest\Enums;

enum GuestBillStatus: string
{
    case UNPAID = 'unpaid';
    case PENDING = 'pending';
    case VERIFIED = 'verified';
    case PAID = 'paid';
    case REJECTED = 'rejected';
    case FAILED = 'failed';

    public function label(): string
    {
        return match ($this) {
            self::UNPAID => 'Unpaid',
            self::PENDING => 'Pending Verification',
            self::VERIFIED => 'Verified',
            self::PAID => 'Paid',
            self::REJECTED => 'Rejected',
            self::FAILED => 'Failed',
        };
    }
}

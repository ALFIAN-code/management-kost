<?php

namespace Modules\Guest\Enums;

enum GuestRelationship: string
{
    case PARENT = 'parent';    // Parent
    case SIBLING = 'sibling';   // Sibling
    case FRIEND = 'friend';    // Friend
    case RELATIVE = 'relative';  // Relative
    case COLLEAGUE = 'colleague'; // Colleague
    case OTHER = 'other';     // Other

    public function label(): string
    {
        return match ($this) {
            self::PARENT => 'Parent',
            self::SIBLING => 'Sibling',
            self::FRIEND => 'Friend',
            self::RELATIVE => 'Relative',
            self::COLLEAGUE => 'Colleague',
            self::OTHER => 'Other',
        };
    }
}

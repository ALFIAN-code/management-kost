<?php

namespace App\Support;

class TenantContext
{
    private static ?int $activeTenantId = null;

    private static bool $bypass = false;

    public static function setTenantId(?int $tenantId): void
    {
        self::$activeTenantId = $tenantId;
    }

    public static function getTenantId(): ?int
    {
        return self::$activeTenantId;
    }

    public static function hasActiveTenant(): bool
    {
        return ! is_null(self::$activeTenantId);
    }

    public static function clear(): void
    {
        self::$activeTenantId = null;
        self::$bypass = false;
    }

    public static function isBypassed(): bool
    {
        return self::$bypass;
    }

    /**
     * Menjalankan callback dengan mengabaikan isolasi tenant (misal: agregasi super-admin).
     */
    public static function bypass(callable $callback)
    {
        $previousBypass = self::$bypass;
        self::$bypass = true;

        try {
            return $callback();
        } finally {
            self::$bypass = $previousBypass;
        }
    }
}

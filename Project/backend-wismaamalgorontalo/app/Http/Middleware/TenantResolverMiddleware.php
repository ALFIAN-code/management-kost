<?php

namespace App\Http\Middleware;

use App\Models\Building;
use App\Support\TenantContext;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class TenantResolverMiddleware
{
    /**
     * Resolve tenant/building context dari header X-Building-ID / X-Tenant-ID
     * atau dari assigned_building_id pengguna yang login.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $tenantId = null;

        // 1. Cek Header X-Building-ID atau X-Tenant-ID
        if ($request->hasHeader('X-Building-ID')) {
            $tenantId = (int) $request->header('X-Building-ID');
        } elseif ($request->hasHeader('X-Tenant-ID')) {
            $tenantId = (int) $request->header('X-Tenant-ID');
        } elseif ($request->query('building_id')) {
            $tenantId = (int) $request->query('building_id');
        } elseif ($request->user() && $request->user()->assigned_building_id) {
            $tenantId = (int) $request->user()->assigned_building_id;
        }

        if ($tenantId !== null && $tenantId > 0) {
            TenantContext::setTenantId($tenantId);
        }

        return $next($request);
    }
}

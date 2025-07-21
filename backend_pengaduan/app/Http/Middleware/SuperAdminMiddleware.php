<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SuperAdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = auth()->user();
        
        if (!$user || !$user->getAttribute('role') || $user->getAttribute('role') !== 'super_admin') {
            abort(403, 'Akses ditolak. Hanya Super Admin yang diperbolehkan.');
        }

        return $next($request);
    }
}

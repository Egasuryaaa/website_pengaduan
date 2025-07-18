<?php

namespace App\Filament\Widgets;

use App\Models\User;
use App\Models\Admin;
use App\Models\Pengaduan;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class RoleOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $stats = [];

        // Statistik untuk Super Admin
        if (auth()->user()?->role === 'super_admin') {
            $stats = [
                Stat::make('Total Pengaduan', Pengaduan::count())
                    ->description('Semua pengaduan')
                    ->descriptionIcon('heroicon-m-document-text')
                    ->color('info'),
                Stat::make('Total Administrator', Admin::count())
                    ->description('Admin yang terdaftar')
                    ->descriptionIcon('heroicon-m-shield-check')
                    ->color('success'),
                Stat::make('Total Pengguna', User::count())
                    ->description('User yang terdaftar')
                    ->descriptionIcon('heroicon-m-users')
                    ->color('warning'),
            ];
        } else {
            // Statistik untuk Admin biasa
            $stats = [
                Stat::make('Total Pengaduan', Pengaduan::count())
                    ->description('Semua pengaduan')
                    ->descriptionIcon('heroicon-m-document-text')
                    ->color('info'),
                Stat::make('Pengaduan Baru', Pengaduan::where('status', 'pending')->count())
                    ->description('Menunggu review')
                    ->descriptionIcon('heroicon-m-clock')
                    ->color('warning'),
                Stat::make('Pengaduan Selesai', Pengaduan::where('status', 'selesai')->count())
                    ->description('Sudah ditangani')
                    ->descriptionIcon('heroicon-m-check-circle')
                    ->color('success'),
            ];
        }

        return $stats;
    }
}

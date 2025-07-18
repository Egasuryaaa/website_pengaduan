<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class KategoriSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $kategoris = [
            [
                'nama' => 'Infrastruktur IT',
                'deskripsi' => 'Masalah terkait infrastruktur teknologi informasi',
                'icon' => 'server',
                'color' => '#2196F3',
                'is_active' => true,
            ],
            [
                'nama' => 'Website & Aplikasi',
                'deskripsi' => 'Masalah terkait website dan aplikasi pemerintahan',
                'icon' => 'web',
                'color' => '#4CAF50',
                'is_active' => true,
            ],
            [
                'nama' => 'Layanan Internet',
                'deskripsi' => 'Masalah terkait layanan internet dan koneksi',
                'icon' => 'wifi',
                'color' => '#FF9800',
                'is_active' => true,
            ],
            [
                'nama' => 'Keamanan Data',
                'deskripsi' => 'Masalah terkait keamanan dan privasi data',
                'icon' => 'security',
                'color' => '#F44336',
                'is_active' => true,
            ],
            [
                'nama' => 'Sistem Informasi',
                'deskripsi' => 'Masalah terkait sistem informasi pemerintahan',
                'icon' => 'system',
                'color' => '#9C27B0',
                'is_active' => true,
            ],
            [
                'nama' => 'Lainnya',
                'deskripsi' => 'Masalah lain yang tidak termasuk kategori di atas',
                'icon' => 'other',
                'color' => '#607D8B',
                'is_active' => true,
            ],
        ];

        foreach ($kategoris as $kategori) {
            \App\Models\Kategori::create($kategori);
        }
    }
}

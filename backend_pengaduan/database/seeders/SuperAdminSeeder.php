<?php

namespace Database\Seeders;

use App\Models\Admin;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        Admin::create([
            'name' => 'Super Administrator',
            'email' => 'superadmin@gunungkidul.id',
            'password' => Hash::make('password'),
            'role' => 'super_admin',
        ]);

        // Tambahkan admin biasa untuk testing
        Admin::create([
            'name' => 'Admin Biasa',
            'email' => 'admin@gunungkidul.id',
            'password' => Hash::make('password'),
            'role' => 'admin',
        ]);
    }
}

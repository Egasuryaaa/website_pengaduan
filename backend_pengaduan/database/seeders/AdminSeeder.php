<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $admins = [
            [
                'name' => 'Super Admin',
                'email' => 'superadmin@gunungkidulkab.go.id',
                'password' => bcrypt('password'),
                'phone' => '081234567890',
                'jabatan' => 'Kepala Dinas',
                'role' => 'super_admin',
                'is_active' => true,
            ],
            [
                'name' => 'Admin IT',
                'email' => 'admin@gunungkidulkab.go.id',
                'password' => bcrypt('password'),
                'phone' => '081234567891',
                'jabatan' => 'Staff IT',
                'role' => 'admin',
                'is_active' => true,
            ],
        ];

        foreach ($admins as $admin) {
            \App\Models\Admin::create($admin);
        }
    }
}

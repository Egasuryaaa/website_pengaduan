<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
// Hapus semua kategori
App\Models\Kategori::truncate();
echo 'Semua kategori telah dihapus.' . PHP_EOL;

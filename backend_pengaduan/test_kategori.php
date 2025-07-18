<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$kategoris = App\Models\Kategori::all();
echo 'Jumlah kategori: ' . $kategoris->count() . PHP_EOL;
foreach ($kategoris as $kategori) {
    echo $kategori->id . '. ' . $kategori->nama . PHP_EOL;
}

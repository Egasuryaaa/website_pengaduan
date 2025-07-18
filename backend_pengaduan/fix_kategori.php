<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
use App\Models\Kategori;
use App\Models\Pengaduan;
// Daftar kategori yang kita inginkan
$desiredKategoris = [
    [
        "nama" => "Infrastruktur IT",
        "deskripsi" => "Masalah terkait infrastruktur teknologi informasi",
        "icon" => "server",
        "color" => "#2196F3",
        "is_active" => true,
    ],
    [
        "nama" => "Website & Aplikasi",
        "deskripsi" => "Masalah terkait website dan aplikasi pemerintahan",
        "icon" => "web",
        "color" => "#4CAF50",
        "is_active" => true,
    ],
    [
        "nama" => "Layanan Internet",
        "deskripsi" => "Masalah terkait layanan internet dan koneksi",
        "icon" => "wifi",
        "color" => "#FF9800",
        "is_active" => true,
    ],
    [
        "nama" => "Keamanan Data",
        "deskripsi" => "Masalah terkait keamanan dan privasi data",
        "icon" => "security",
        "color" => "#F44336",
        "is_active" => true,
    ],
    [
        "nama" => "Sistem Informasi",
        "deskripsi" => "Masalah terkait sistem informasi pemerintahan",
        "icon" => "system",
        "color" => "#9C27B0",
        "is_active" => true,
    ],
    [
        "nama" => "Lainnya",
        "deskripsi" => "Masalah lain yang tidak termasuk kategori di atas",
        "icon" => "other",
        "color" => "#607D8B",
        "is_active" => true,
    ],
];
// Simpan ID kategori yang valid
$validKategoriIds = [];
// Hanya simpan satu dari setiap nama kategori yang diinginkan
foreach ($desiredKategoris as $index => $desiredKategori) {
    $existingKategori = Kategori::where("nama", $desiredKategori["nama"])->first();
    
    if ($existingKategori) {
        // Update kategori yang ada
        $existingKategori->update($desiredKategori);
        $validKategoriIds[] = $existingKategori->id;
        echo "Updated kategori: {$existingKategori->nama}" . PHP_EOL;
    } else {
        // Buat kategori baru
        $newKategori = Kategori::create($desiredKategori);
        $validKategoriIds[] = $newKategori->id;
        echo "Created kategori: {$newKategori->nama}" . PHP_EOL;
    }
}
// Hapus kategori yang tidak sesuai dengan daftar yang diinginkan
// Tapi pastikan tidak menghapus kategori yang digunakan oleh pengaduan
$usedKategoriIds = Pengaduan::distinct("kategori_id")->pluck("kategori_id")->toArray();
$kategoriToPreserve = array_merge($validKategoriIds, $usedKategoriIds);
$deleted = Kategori::whereNotIn("id", $kategoriToPreserve)->delete();
echo "Deleted {$deleted} duplicate/unused kategori entries." . PHP_EOL;
// Tampilkan daftar kategori yang ada sekarang
$kategoris = Kategori::orderBy("id")->get();
echo "Current kategori list:" . PHP_EOL;
foreach ($kategoris as $kategori) {
    echo "{$kategori->id}. {$kategori->nama}" . PHP_EOL;
}

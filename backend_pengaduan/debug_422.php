<?php

// Test untuk debug 422 error
// Simulasi persis seperti yang dikirim Flutter

// 1. Login dulu untuk mendapatkan token
$loginUrl = 'http://localhost:8000/api/login';
$loginData = [
    'email' => 'flutter@example.com',
    'password' => 'password'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $loginUrl);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($loginData));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$loginResponse = curl_exec($ch);
$loginData = json_decode($loginResponse, true);
curl_close($ch);

if (!isset($loginData['data']['token'])) {
    echo "Login failed\n";
    exit;
}

$token = $loginData['data']['token'];
echo "Token: $token\n";

// 2. Test dengan data JSON (tanpa file)
echo "\n=== Test 1: JSON Data (no file) ===\n";
$pengaduanUrl = 'http://localhost:8000/api/pengaduan';
$pengaduanData = [
    'nama_instansi' => 'Test Instansi',
    'deskripsi' => 'Test deskripsi pengaduan yang panjang minimal 10 karakter',
    'kategori_id' => '1',
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $pengaduanUrl);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($pengaduanData));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json',
    'Authorization: Bearer ' . $token
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: " . $response . "\n";

// 3. Test dengan FormData (simulasi Flutter uploadFile)
echo "\n=== Test 2: FormData (simulating Flutter) ===\n";
$postData = [
    'nama_instansi' => 'Test Instansi FormData',
    'deskripsi' => 'Test deskripsi pengaduan dengan FormData minimal 10 karakter',
    'kategori_id' => '1',
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $pengaduanUrl);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Authorization: Bearer ' . $token
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: " . $response . "\n";

// 4. Test dengan kategori_id sebagai integer
echo "\n=== Test 3: kategori_id as integer ===\n";
$pengaduanData = [
    'nama_instansi' => 'Test Instansi Integer',
    'deskripsi' => 'Test deskripsi pengaduan dengan integer kategori minimal 10 karakter',
    'kategori_id' => 1, // integer, bukan string
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $pengaduanUrl);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($pengaduanData));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json',
    'Authorization: Bearer ' . $token
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: " . $response . "\n";

?>

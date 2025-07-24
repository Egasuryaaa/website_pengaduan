<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pengaduan;
use App\Models\Kategori;
use App\Models\StatusHistory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class PengaduanController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $userId = $user ? $user->getAttribute('id') : null;
        
        $pengaduans = Pengaduan::with(['kategori', 'user'])
            ->where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $pengaduans
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'deskripsi' => 'required|string',
            'kategori_id' => 'required|exists:kategoris,id',
            'nama_instansi' => 'required|string|max:255',
            'foto_bukti' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $fotoPath = null;
        if ($request->hasFile('foto_bukti')) {
            $fotoPath = $request->file('foto_bukti')->store('pengaduan', 'public');
        }
        
        // Hapus debug log

        $user = $request->user();
        $userId = $user ? $user->getAttribute('id') : null;
        $namaInstansi = $request->input('nama_instansi');

        $pengaduan = Pengaduan::create([
            'judul' => 'Pengaduan dari ' . $namaInstansi,
            'deskripsi' => $request->input('deskripsi'),
            'kategori_id' => $request->input('kategori_id'),
            'lokasi' => $namaInstansi,
            'foto' => $fotoPath,
            'user_id' => $userId,
            'nomor_pengaduan' => $this->generateTicketNumber(),
            'status' => 'pending',
        ]);

        // Buat history status
        // StatusHistory::create([
        //     'pengaduan_id' => $pengaduan->id,
        //     'status' => 'pending',
        //     'keterangan' => 'Pengaduan berhasil dibuat',
        // ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengaduan berhasil dibuat',
            'data' => $pengaduan->load(['kategori', 'user'])
        ], 201);
    }

    public function show($id)
    {
        $user = auth()->user();
        $userId = $user ? $user->getAttribute('id') : null;
        
        $pengaduan = Pengaduan::with(['kategori', 'user', 'statusHistories'])
            ->where('id', $id)
            ->where('user_id', $userId)
            ->first();

        if (!$pengaduan) {
            return response()->json([
                'success' => false,
                'message' => 'Pengaduan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $pengaduan
        ]);
    }

    public function getKategori()
    {
        $kategoris = Kategori::all();

        return response()->json([
            'success' => true,
            'data' => $kategoris
        ]);
    }

    public function myPengaduan(Request $request)
    {
        // Pastikan user sudah terautentikasi
        $user = $request->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak terautentikasi'
            ], 401);
        }

        // Ambil pengaduan hanya milik user yang sedang login
        $pengaduans = Pengaduan::with(['kategori', 'user', 'statusHistories'])
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data pengaduan berhasil diambil',
            'data' => $pengaduans,
            'total' => $pengaduans->count()
        ]);
    }

    public function myPengaduanDetail(Request $request, $id)
    {
        // Pastikan user sudah terautentikasi
        $user = $request->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak terautentikasi'
            ], 401);
        }

        // Ambil detail pengaduan hanya jika milik user yang sedang login
        $pengaduan = Pengaduan::with(['kategori', 'user', 'statusHistories'])
            ->where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$pengaduan) {
            return response()->json([
                'success' => false,
                'message' => 'Pengaduan tidak ditemukan atau Anda tidak memiliki akses'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail pengaduan berhasil diambil',
            'data' => $pengaduan
        ]);
    }

    public function update(Request $request, $id)
    {
        // Pastikan user sudah terautentikasi
        $user = $request->user();
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak terautentikasi'
            ], 401);
        }

        // Cari pengaduan yang akan diupdate, pastikan milik user yang sedang login
        $pengaduan = Pengaduan::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$pengaduan) {
            return response()->json([
                'success' => false,
                'message' => 'Pengaduan tidak ditemukan atau Anda tidak memiliki akses'
            ], 404);
        }

        // Validasi input
        $validator = Validator::make($request->all(), [
            'deskripsi' => 'sometimes|string',
            'kategori_id' => 'sometimes|exists:kategoris,id',
            'nama_instansi' => 'sometimes|string|max:255',
            'foto_bukti' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        // Hanya izinkan update jika status masih pending
        if ($pengaduan->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Pengaduan hanya dapat diubah ketika status masih pending'
            ], 400);
        }

        // Update foto jika ada
        if ($request->hasFile('foto_bukti')) {
            // Hapus foto lama jika ada
            $oldFoto = $pengaduan->foto;
            if ($oldFoto) {
                try {
                    Storage::disk('public')->delete($oldFoto);
                } catch (\Exception $e) {
                    // Log error tapi tetap lanjut
                }
            }
            $fotoPath = $request->file('foto_bukti')->store('pengaduan', 'public');
        } else {
            $fotoPath = $pengaduan->foto;
        }

        // Update data pengaduan
        $updateData = [];
        if ($request->has('deskripsi')) {
            $updateData['deskripsi'] = $request->input('deskripsi');
        }
        if ($request->has('kategori_id')) {
            $updateData['kategori_id'] = $request->input('kategori_id');
        }
        if ($request->has('nama_instansi')) {
            $updateData['nama_instansi'] = $request->input('nama_instansi');
            $updateData['judul'] = 'Pengaduan dari ' . $request->input('nama_instansi');
            $updateData['lokasi'] = $request->input('nama_instansi');
        }
        if ($request->hasFile('foto_bukti')) {
            $updateData['foto'] = $fotoPath;
        }

        $pengaduan->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'Pengaduan berhasil diperbarui',
            'data' => $pengaduan->load(['kategori', 'user'])
        ]);
    }

    public function getStatistics(Request $request)
    {
        $user = $request->user();
        $userId = $user ? $user->getAttribute('id') : null;

        $statistics = [
            'total' => Pengaduan::where('user_id', $userId)->count(),
            'pending' => Pengaduan::where('user_id', $userId)->where('status', 'pending')->count(),
            'proses' => Pengaduan::where('user_id', $userId)->where('status', 'proses')->count(),
            'selesai' => Pengaduan::where('user_id', $userId)->where('status', 'selesai')->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => $statistics
        ]);
    }

    private function generateTicketNumber()
    {
        $prefix = 'TKT';
        $date = date('Ymd');
        $random = str_pad(mt_rand(1, 9999), 4, '0', STR_PAD_LEFT);
        
        return $prefix . $date . $random;
    }
}

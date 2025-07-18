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
        $pengaduans = Pengaduan::with(['kategori', 'user'])
            ->where('user_id', $request->user()->id)
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
        
        // Debug request data
        \Log::info('Pengaduan Request Data:', [
            'all' => $request->all(),
            'has_file' => $request->hasFile('foto_bukti'),
            'files' => $request->allFiles(),
            'headers' => $request->headers->all(),
        ]);

        $pengaduan = Pengaduan::create([
            'judul' => 'Pengaduan dari ' . $request->nama_instansi,
            'deskripsi' => $request->deskripsi,
            'kategori_id' => $request->kategori_id,
            'lokasi' => $request->nama_instansi,
            'foto' => $fotoPath,
            'user_id' => $request->user()->id,
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
        $pengaduan = Pengaduan::with(['kategori', 'user', 'statusHistories'])
            ->where('id', $id)
            ->where('user_id', auth()->user()->id)
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

    public function getStatistics(Request $request)
    {
        $userId = $request->user()->id;

        $statistics = [
            'total' => Pengaduan::where('user_id', $userId)->count(),
            'pending' => Pengaduan::where('user_id', $userId)->where('status', 'pending')->count(),
            'proses' => Pengaduan::where('user_id', $userId)->where('status', 'proses')->count(),
            'selesai' => Pengaduan::where('user_id', $userId)->where('status', 'selesai')->count(),
            'ditolak' => Pengaduan::where('user_id', $userId)->where('status', 'ditolak')->count(),
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

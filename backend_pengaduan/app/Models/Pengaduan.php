<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pengaduan extends Model
{
    use HasFactory;

    protected $fillable = [
        'nomor_pengaduan',
        'user_id',
        'kategori_id',
        'judul',
        'deskripsi',
        'lokasi',
        'foto',
        'status',
        'tanggapan',
        'foto_tanggapan',
        'admin_id',
        'tanggal_selesai',
        'rating',
        'feedback',
    ];

    protected $casts = [
        'foto' => 'array',
        'foto_tanggapan' => 'array',
        'tanggal_selesai' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function kategori()
    {
        return $this->belongsTo(Kategori::class);
    }

    public function admin()
    {
        return $this->belongsTo(Admin::class);
    }

    public function statusHistories()
    {
        return $this->hasMany(StatusHistory::class);
    }

    public function getStatusColorAttribute()
    {
        return match($this->status) {
            'pending' => '#FF9800',
            'diproses' => '#2196F3',
            'selesai' => '#4CAF50',
            'ditolak' => '#F44336',
            default => '#9E9E9E',
        };
    }

    public function getStatusTextAttribute()
    {
        return match($this->status) {
            'pending' => 'Menunggu',
            'diproses' => 'Diproses',
            'selesai' => 'Selesai',
            'ditolak' => 'Ditolak',
            default => 'Unknown',
        };
    }
}

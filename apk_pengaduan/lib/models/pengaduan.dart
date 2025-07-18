import 'user.dart';
import 'kategori.dart';

class Pengaduan {
  final int id;
  final String judul;
  final String deskripsi;
  final String lokasi;
  final String? foto;
  final String nomorTiket;
  final String status;
  final String? tanggalDitangani;
  final String? tanggalSelesai;
  final String? catatan;
  final int userId;
  final int kategoriId;
  final String createdAt;
  final String updatedAt;
  final User? user;
  final Kategori? kategori;
  final List<StatusHistory>? statusHistories;

  Pengaduan({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.lokasi,
    this.foto,
    required this.nomorTiket,
    required this.status,
    this.tanggalDitangani,
    this.tanggalSelesai,
    this.catatan,
    required this.userId,
    required this.kategoriId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.kategori,
    this.statusHistories,
  });

  factory Pengaduan.fromJson(Map<String, dynamic> json) {
    return Pengaduan(
      id: json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      lokasi: json['lokasi'],
      foto: json['foto'],
      nomorTiket: json['nomor_tiket'],
      status: json['status'],
      tanggalDitangani: json['tanggal_ditangani'],
      tanggalSelesai: json['tanggal_selesai'],
      catatan: json['catatan'],
      userId: json['user_id'],
      kategoriId: json['kategori_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      kategori: json['kategori'] != null ? Kategori.fromJson(json['kategori']) : null,
      statusHistories: json['status_histories'] != null
          ? (json['status_histories'] as List)
              .map((item) => StatusHistory.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'foto': foto,
      'nomor_tiket': nomorTiket,
      'status': status,
      'tanggal_ditangani': tanggalDitangani,
      'tanggal_selesai': tanggalSelesai,
      'catatan': catatan,
      'user_id': userId,
      'kategori_id': kategoriId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user?.toJson(),
      'kategori': kategori?.toJson(),
      'status_histories': statusHistories?.map((item) => item.toJson()).toList(),
    };
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'proses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Tidak Diketahui';
    }
  }
}

class StatusHistory {
  final int id;
  final int pengaduanId;
  final String status;
  final String? keterangan;
  final String createdAt;
  final String updatedAt;

  StatusHistory({
    required this.id,
    required this.pengaduanId,
    required this.status,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: json['id'],
      pengaduanId: json['pengaduan_id'],
      status: json['status'],
      keterangan: json['keterangan'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pengaduan_id': pengaduanId,
      'status': status,
      'keterangan': keterangan,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// Import statements for related models
import 'user.dart';
import 'kategori.dart';

class Pengaduan {
  final int id;
  final String nomorPengaduan;
  final String judul;
  final String deskripsi;
  final String? lokasi;
  final String? foto;
  final String status;
  final String? tanggapan;
  final String? fotoTanggapan;
  final int userId;
  final int kategoriId;
  final int? adminId;
  final DateTime? tanggalSelesai;
  final int? rating;
  final String? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final Kategori? kategori;

  Pengaduan({
    required this.id,
    required this.nomorPengaduan,
    required this.judul,
    required this.deskripsi,
    this.lokasi,
    this.foto,
    required this.status,
    this.tanggapan,
    this.fotoTanggapan,
    required this.userId,
    required this.kategoriId,
    this.adminId,
    this.tanggalSelesai,
    this.rating,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.kategori,
  });

  factory Pengaduan.fromJson(Map<String, dynamic> json) {
    return Pengaduan(
      id: json['id'],
      nomorPengaduan: json['nomor_pengaduan'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      lokasi: json['lokasi'],
      foto: json['foto'],
      status: json['status'],
      tanggapan: json['tanggapan'],
      fotoTanggapan: json['foto_tanggapan'],
      userId: json['user_id'],
      kategoriId: json['kategori_id'],
      adminId: json['admin_id'],
      tanggalSelesai: json['tanggal_selesai'] != null 
          ? DateTime.parse(json['tanggal_selesai'])
          : null,
      rating: json['rating'],
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      kategori: json['kategori'] != null ? Kategori.fromJson(json['kategori']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_pengaduan': nomorPengaduan,
      'judul': judul,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'foto': foto,
      'status': status,
      'tanggapan': tanggapan,
      'foto_tanggapan': fotoTanggapan,
      'user_id': userId,
      'kategori_id': kategoriId,
      'admin_id': adminId,
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
      if (kategori != null) 'kategori': kategori!.toJson(),
    };
  }

  // Helper method to get photo URL
  String? get photoUrl {
    if (foto != null && foto!.isNotEmpty) {
      // Assuming the backend serves photos from storage/app/public
      return 'http://localhost:8000/storage/$foto';
    }
    return null;
  }

  // Helper method to get response photo URL
  String? get responsePhotoUrl {
    if (fotoTanggapan != null && fotoTanggapan!.isNotEmpty) {
      return 'http://localhost:8000/storage/$fotoTanggapan';
    }
    return null;
  }
}

class Kategori {
  final int id;
  final String nama;
  final String? deskripsi;
  final String createdAt;
  final String updatedAt;

  Kategori({
    required this.id,
    required this.nama,
    this.deskripsi,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

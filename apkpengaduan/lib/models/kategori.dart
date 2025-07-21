class Kategori {
  final int id;
  final String nama;
  final String? deskripsi;
  final String? icon;
  final String? color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Kategori({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.icon,
    this.color,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      icon: json['icon'],
      color: json['color'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'icon': icon,
      'color': color,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

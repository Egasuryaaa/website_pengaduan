class PengaduanModel {
  final String? id;
  final String? userId;
  final String? namaInstansi;
  final String? deskripsi;
  final String? fotoBukti;
  final String? kategoriId;
  final String? status;
  final String? assignedTo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<StatusHistoryModel>? statusHistory;
  final UserModel? user;
  final KategoriModel? kategori;

  PengaduanModel({
    this.id,
    this.userId,
    this.namaInstansi,
    this.deskripsi,
    this.fotoBukti,
    this.kategoriId,
    this.status,
    this.assignedTo,
    this.createdAt,
    this.updatedAt,
    this.statusHistory,
    this.user,
    this.kategori,
  });

  factory PengaduanModel.fromJson(Map<String, dynamic> json) {
    return PengaduanModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      namaInstansi: json['nama_instansi']?.toString(),
      deskripsi: json['deskripsi']?.toString(),
      fotoBukti: json['foto_bukti']?.toString(),
      kategoriId: json['kategori_id']?.toString(),
      status: json['status']?.toString(),
      assignedTo: json['assigned_to']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
      statusHistory: json['status_history'] != null
          ? (json['status_history'] as List)
              .map((item) => StatusHistoryModel.fromJson(item))
              .toList()
          : null,
      user: json['user'] != null 
          ? UserModel.fromJson(json['user'])
          : null,
      kategori: json['kategori'] != null 
          ? KategoriModel.fromJson(json['kategori'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama_instansi': namaInstansi,
      'deskripsi': deskripsi,
      'foto_bukti': fotoBukti,
      'kategori_id': kategoriId,
      'status': status,
      'assigned_to': assignedTo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PengaduanModel copyWith({
    String? id,
    String? userId,
    String? namaInstansi,
    String? deskripsi,
    String? fotoBukti,
    String? kategoriId,
    String? status,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<StatusHistoryModel>? statusHistory,
    UserModel? user,
    KategoriModel? kategori,
  }) {
    return PengaduanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaInstansi: namaInstansi ?? this.namaInstansi,
      deskripsi: deskripsi ?? this.deskripsi,
      fotoBukti: fotoBukti ?? this.fotoBukti,
      kategoriId: kategoriId ?? this.kategoriId,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusHistory: statusHistory ?? this.statusHistory,
      user: user ?? this.user,
      kategori: kategori ?? this.kategori,
    );
  }
}

class StatusHistoryModel {
  final String? id;
  final String? pengaduanId;
  final String? statusOld;
  final String? statusNew;
  final String? keterangan;
  final String? updatedBy;
  final DateTime? createdAt;

  StatusHistoryModel({
    this.id,
    this.pengaduanId,
    this.statusOld,
    this.statusNew,
    this.keterangan,
    this.updatedBy,
    this.createdAt,
  });

  factory StatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return StatusHistoryModel(
      id: json['id']?.toString(),
      pengaduanId: json['pengaduan_id']?.toString(),
      statusOld: json['status_old']?.toString(),
      statusNew: json['status_new']?.toString(),
      keterangan: json['keterangan']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pengaduan_id': pengaduanId,
      'status_old': statusOld,
      'status_new': statusNew,
      'keterangan': keterangan,
      'updated_by': updatedBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class KategoriModel {
  final String? id;
  final String? nama;
  final String? deskripsi;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KategoriModel({
    this.id,
    this.nama,
    this.deskripsi,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id']?.toString(),
      nama: json['nama']?.toString(),
      deskripsi: json['deskripsi']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Import required for UserModel
class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? namaInstansi;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.namaInstansi,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      namaInstansi: json['nama_instansi']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'nama_instansi': namaInstansi,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

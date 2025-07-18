class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? namaInstansi;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.namaInstansi,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing User JSON: $json');
    
    // Handle case where the user data might be nested in a 'user' field
    final userData = json.containsKey('user') ? json['user'] : json;
    
    // Convert various ID formats (string, int, etc)
    int userId;
    if (userData['id'] == null) {
      print('DEBUG: No ID found in user data, using default');
      userId = -1;
    } else if (userData['id'] is String) {
      userId = int.tryParse(userData['id']) ?? -1;
    } else {
      userId = userData['id'];
    }
    
    // Handle cases where dates might be missing or in unexpected formats
    String createdAt, updatedAt;
    try {
      createdAt = userData['created_at'] ?? DateTime.now().toIso8601String();
      updatedAt = userData['updated_at'] ?? DateTime.now().toIso8601String();
    } catch (e) {
      print('DEBUG: Error parsing dates: $e');
      createdAt = DateTime.now().toIso8601String();
      updatedAt = DateTime.now().toIso8601String();
    }
    
    return User(
      id: userId,
      name: userData['name'] ?? 'Unknown',
      email: userData['email'] ?? 'no-email@example.com',
      phone: userData['phone'] ?? userData['telephone'] ?? userData['mobile'] ?? null,
      namaInstansi: userData['nama_instansi'] ?? userData['instansi'] ?? null,
      emailVerifiedAt: userData['email_verified_at'],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'nama_instansi': namaInstansi,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

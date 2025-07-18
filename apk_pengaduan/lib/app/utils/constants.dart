import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Dinas Kominfo Theme
  static const Color primaryColor = Color(0xFF2E7D32); // Green
  static const Color primaryColorLight = Color(0xFF4CAF50);
  static const Color primaryColorDark = Color(0xFF1B5E20);
  
  // Secondary Colors
  static const Color secondaryColor = Color(0xFF1976D2); // Blue
  static const Color secondaryColorLight = Color(0xFF42A5F5);
  static const Color secondaryColorDark = Color(0xFF0D47A1);
  
  // Accent Colors
  static const Color accentColor = Color(0xFFFF9800); // Orange
  static const Color accentColorLight = Color(0xFFFFB74D);
  static const Color accentColorDark = Color(0xFFE65100);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color dangerColor = Color(0xFFF44336);
  
  // Basic Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Status Pengaduan Colors
  static const Color statusPending = Color(0xFFFF9800); // Orange
  static const Color statusDiproses = Color(0xFF2196F3); // Blue
  static const Color statusSelesai = Color(0xFF4CAF50); // Green
  static const Color statusDitolak = Color(0xFFF44336); // Red
  
  // Divider
  static const Color dividerColor = Color(0xFFE0E0E0);
  
  // Shadow
  static const Color shadowColor = Color(0x1F000000);
}

class AppSizes {
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  
  // Font Sizes
  static const double fontSize10 = 10.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;
  
  // Border Radius
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  
  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  
  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  
  // AppBar Height
  static const double appBarHeight = 56.0;
  
  // Input Field Height
  static const double inputFieldHeight = 56.0;
  
  // Card Elevation
  static const double cardElevation = 4.0;
  
  // Avatar Sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 96.0;
}

class AppStrings {
  // App Info
  static const String appName = 'Pengaduan Diskominfo';
  static const String appVersion = '1.0.0';
  static const String copyright = '© 2024 Dinas Kominfo Gunung Kidul';
  
  // Auth
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String logout = 'Keluar';
  static const String email = 'Email';
  static const String password = 'Kata Sandi';
  static const String confirmPassword = 'Konfirmasi Kata Sandi';
  static const String forgotPassword = 'Lupa Kata Sandi?';
  static const String rememberMe = 'Ingat Saya';
  static const String name = 'Nama';
  static const String phone = 'No. Telepon';
  static const String namaInstansi = 'Nama Instansi';
  
  // Navigation
  static const String home = 'Beranda';
  static const String pengaduan = 'Pengaduan';
  static const String history = 'Riwayat';
  static const String profile = 'Profil';
  static const String settings = 'Pengaturan';
  static const String about = 'Tentang';
  
  // Pengaduan
  static const String createPengaduan = 'Buat Pengaduan';
  static const String detailPengaduan = 'Detail Pengaduan';
  static const String editPengaduan = 'Edit Pengaduan';
  static const String deletePengaduan = 'Hapus Pengaduan';
  static const String deskripsi = 'Deskripsi';
  static const String kategori = 'Kategori';
  static const String fotoBukti = 'Foto Bukti';
  static const String status = 'Status';
  static const String tanggalPengaduan = 'Tanggal Pengaduan';
  static const String nomorPengaduan = 'Nomor Pengaduan';
  
  // Status
  static const String statusPending = 'Menunggu';
  static const String statusDiproses = 'Diproses';
  static const String statusSelesai = 'Selesai';
  static const String statusDitolak = 'Ditolak';
  
  // Actions
  static const String submit = 'Kirim';
  static const String save = 'Simpan';
  static const String cancel = 'Batal';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String view = 'Lihat';
  static const String refresh = 'Refresh';
  static const String retry = 'Coba Lagi';
  static const String close = 'Tutup';
  static const String ok = 'OK';
  static const String yes = 'Ya';
  static const String no = 'Tidak';
  
  // Messages
  static const String noData = 'Tidak ada data';
  static const String noInternet = 'Tidak ada koneksi internet';
  static const String error = 'Terjadi kesalahan';
  static const String success = 'Berhasil';
  static const String loading = 'Memuat...';
  static const String pleaseWait = 'Mohon tunggu...';
  static const String tryAgain = 'Silakan coba lagi';
  
  // Validation Messages
  static const String fieldRequired = 'Field ini wajib diisi';
  static const String invalidEmail = 'Format email tidak valid';
  static const String passwordTooShort = 'Kata sandi minimal 8 karakter';
  static const String passwordNotMatch = 'Kata sandi tidak cocok';
  static const String invalidPhone = 'Format nomor telepon tidak valid';
  
  // Permissions
  static const String cameraPermission = 'Izin Kamera';
  static const String storagePermission = 'Izin Penyimpanan';
  static const String cameraPermissionMessage = 'Aplikasi membutuhkan izin kamera untuk mengambil foto';
  static const String storagePermissionMessage = 'Aplikasi membutuhkan izin penyimpanan untuk menyimpan file';
  
  // Image Picker
  static const String chooseImage = 'Pilih Gambar';
  static const String takePhoto = 'Ambil Foto';
  static const String chooseFromGallery = 'Pilih dari Galeri';
  static const String removeImage = 'Hapus Gambar';
  
  // Notifications
  static const String newNotification = 'Notifikasi Baru';
  static const String pengaduanUpdated = 'Pengaduan Diperbarui';
  static const String pengaduanProcessed = 'Pengaduan Diproses';
  static const String pengaduanCompleted = 'Pengaduan Selesai';
}

class AppConstants {
  // API
  static const String baseUrl = 'http://localhost:8000/api';
  static const int requestTimeoutDuration = 30000; // 30 seconds
  
  // Database
  static const String dbName = 'pengaduan_app.db';
  static const int dbVersion = 1;
  
  // SharedPreferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // File
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // Animation Duration
  static const int animationDuration = 300;
  static const int splashDuration = 3000;
  
  // Status
  static const String statusPending = 'pending';
  static const String statusDiproses = 'diproses';
  static const String statusSelesai = 'selesai';
  static const String statusDitolak = 'ditolak';
  
  // Date Format
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Regular Expressions
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^(\+62|62|0)[0-9]{9,13}$';
}

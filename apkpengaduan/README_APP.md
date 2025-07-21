# Aplikasi Pengaduan Flutter

Aplikasi mobile untuk sistem pengaduan masyarakat yang terintegrasi dengan backend Laravel.

## Fitur

### Autentikasi
- Login
- Register  
- Logout
- Ubah Password
- Update Profile

### Pengaduan
- Buat Pengaduan Baru
- Lihat Daftar Pengaduan
- Detail Pengaduan
- Edit Pengaduan (untuk status pending)
- Filter berdasarkan Kategori
- Statistik Pengaduan

### Profil
- Lihat Profil
- Edit Profil
- Ubah Password

## Route Mapping

Aplikasi ini mengimplementasikan routing yang sesuai dengan API backend:

### API Routes yang diimplementasikan:
- `POST /api/login` → Login Screen
- `POST /api/register` → Register Screen  
- `POST /api/logout` → Logout Function
- `GET /api/me` → User Profile
- `PUT /api/profile` → Edit Profile
- `PUT /api/change-password` → Change Password
- `GET /api/kategori` → Categories untuk dropdown
- `GET /api/pengaduan` → List Pengaduan
- `POST /api/pengaduan` → Create Pengaduan
- `GET /api/pengaduan/{id}` → Detail Pengaduan
- `PUT /api/pengaduan/{id}` → Edit Pengaduan
- `GET /api/pengaduan-statistics` → Dashboard Statistics

### Screen Routes:
- `/` → Home Screen (Dashboard dengan statistik)
- `/login` → Login Screen
- `/register` → Register Screen
- `/pengaduan` → Pengaduan List Screen
- `/pengaduan/create` → Create Pengaduan Screen
- `/pengaduan/:id` → Pengaduan Detail Screen
- `/pengaduan/:id/edit` → Edit Pengaduan Screen (Coming Soon)
- `/profile` → Profile Tab di Home Screen
- `/profile/edit` → Edit Profile Screen
- `/profile/change-password` → Change Password Screen

## Konfigurasi

### 1. Backend URL
Edit file `lib/services/api_service.dart` dan ubah `baseUrl`:

```dart
static const String baseUrl = 'http://your-backend-url/api';
```

### 2. Dependencies
Aplikasi menggunakan:
- `go_router` untuk routing
- `provider` untuk state management
- `dio` untuk HTTP requests
- `shared_preferences` untuk local storage

### 3. Menjalankan Aplikasi

```bash
# Install dependencies
flutter pub get

# Run aplikasi
flutter run
```

## Struktur Folder

```
lib/
├── config/
│   └── router.dart           # Konfigurasi routing
├── models/
│   ├── user.dart            # Model User
│   ├── kategori.dart        # Model Kategori
│   └── pengaduan.dart       # Model Pengaduan
├── providers/
│   ├── auth_provider.dart   # State management untuk auth
│   └── pengaduan_provider.dart # State management untuk pengaduan
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── pengaduan/
│   │   ├── pengaduan_list_screen.dart
│   │   ├── create_pengaduan_screen.dart
│   │   └── pengaduan_detail_screen.dart
│   ├── profile/
│   │   ├── edit_profile_screen.dart
│   │   └── change_password_screen.dart
│   └── home_screen.dart     # Main screen dengan bottom navigation
├── services/
│   └── api_service.dart     # HTTP client dan API calls
└── main.dart               # Entry point aplikasi
```

## Fitur yang Diimplementasikan

### Home Screen
- Dashboard dengan statistik pengaduan
- Bottom navigation dengan 4 tab (Beranda, Pengaduan, Riwayat, Profil)
- Menu grid untuk akses cepat
- Welcome card dengan info user

### Autentikasi
- Form login dengan validasi
- Form register dengan field lengkap
- Logout dengan konfirmasi dialog
- Auto redirect berdasarkan status login

### Pengaduan Management
- Create pengaduan dengan kategori
- List pengaduan dengan status badge
- Detail pengaduan lengkap dengan tanggapan admin
- Refresh to reload data
- Error handling yang baik

### Profile Management
- Edit profile dengan validasi
- Change password dengan keamanan
- Tips keamanan password

## Status Badge dan Icons

Status pengaduan ditampilkan dengan:
- **Pending**: Orange badge dengan ikon pending
- **Diproses**: Blue badge dengan ikon settings  
- **Selesai**: Green badge dengan ikon check_circle
- **Ditolak**: Red badge dengan ikon cancel

## Error Handling

- Network error handling
- Form validation
- Loading states
- User-friendly error messages
- Offline mode consideration

Aplikasi ini siap untuk dikembangkan lebih lanjut dan dapat dengan mudah dikustomisasi sesuai kebutuhan.

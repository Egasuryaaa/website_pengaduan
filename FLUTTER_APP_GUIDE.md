# Flutter App Pengaduan - Testing Guide

## ✅ **Fitur yang Berhasil Diimplementasi**

### 1. **Authentication System**
- **Login**: User dapat login dengan email dan password
- **Register**: User dapat mendaftar akun baru
- **Logout**: User dapat keluar dari aplikasi
- **Auto Login**: Aplikasi mengingat status login user

### 2. **Pengaduan Management**
- **Create Pengaduan**: User dapat membuat pengaduan baru
- **View Pengaduan**: User dapat melihat daftar pengaduan mereka
- **Upload Foto**: User dapat mengupload foto untuk pengaduan
- **Kategori**: User dapat memilih kategori pengaduan

### 3. **Dashboard**
- **Statistics**: Menampilkan statistik pengaduan user
- **Recent Pengaduan**: Menampilkan pengaduan terbaru
- **Quick Actions**: Menu cepat untuk aksi utama

## 🔧 **API Endpoints yang Tersedia**

### Authentication
```
POST /api/register
POST /api/login
POST /api/logout
GET /api/me
PUT /api/profile
PUT /api/change-password
```

### Pengaduan
```
GET /api/pengaduan
POST /api/pengaduan
GET /api/pengaduan/{id}
GET /api/pengaduan-statistics
```

### Kategori
```
GET /api/kategori
```

## 🧪 **Cara Testing**

### 1. **Test Registration**
1. Buka aplikasi Flutter
2. Klik "Daftar sekarang"
3. Isi form registrasi:
   - Nama: John Doe
   - Email: john@example.com
   - Phone: 08123456789
   - Password: password123
   - Confirm Password: password123
4. Klik "Daftar"

### 2. **Test Login**
1. Gunakan kredensial yang sudah didaftarkan
2. Email: john@example.com
3. Password: password123
4. Klik "Login"

### 3. **Test Create Pengaduan**
1. Setelah login, klik "Buat Pengaduan"
2. Isi form pengaduan:
   - Judul: "Masalah Jaringan Internet"
   - Kategori: Pilih dari dropdown
   - Lokasi: "Wonosari, Gunung Kidul"
   - Deskripsi: "Jaringan internet di area ini sering putus"
3. (Optional) Upload foto
4. Klik "Kirim Pengaduan"

### 4. **Test View Pengaduan**
1. Dari dashboard, klik "Lihat Pengaduan"
2. Akan muncul daftar pengaduan user
3. Setiap pengaduan menampilkan:
   - Status (Pending, Proses, Selesai, Ditolak)
   - Nomor tiket
   - Judul dan deskripsi
   - Kategori dan lokasi
   - Waktu dibuat

## 📱 **Screens yang Tersedia**

1. **SplashScreen** - Splash screen dengan auto-navigation
2. **LoginScreen** - Form login dengan validation
3. **RegisterScreen** - Form registrasi dengan validation
4. **HomeScreen** - Dashboard dengan statistik dan menu
5. **CreatePengaduanScreen** - Form untuk membuat pengaduan
6. **PengaduanListScreen** - Daftar pengaduan user

## 🎨 **UI/UX Features**

- **Material Design 3** dengan tema amber
- **Responsive Layout** untuk berbagai ukuran layar
- **Loading States** untuk semua operasi async
- **Error Handling** dengan snackbar
- **Form Validation** di semua input
- **Image Picker** untuk upload foto
- **Pull to Refresh** di list pengaduan
- **Status Colors** untuk berbagai status pengaduan

## 🔐 **Security Features**

- **JWT Authentication** menggunakan Laravel Sanctum
- **Secure Storage** untuk token
- **Form Validation** di client dan server
- **Password Hashing** di backend
- **CSRF Protection** di Laravel

## 📊 **Database Structure**

### Users Table
- id, name, email, phone, nama_instansi, password, timestamps

### Pengaduans Table
- id, judul, deskripsi, lokasi, foto, nomor_tiket, status, user_id, kategori_id, timestamps

### Kategoris Table
- id, nama, deskripsi, timestamps

### Status Histories Table
- id, pengaduan_id, status, keterangan, timestamps

## 🚀 **Getting Started**

1. **Backend Setup**:
   ```bash
   cd backend_pengaduan
   php artisan serve
   ```

2. **Flutter Setup**:
   ```bash
   cd apk_pengaduan
   flutter pub get
   flutter run
   ```

3. **Access Points**:
   - **Flutter App**: http://localhost:port (Chrome)
   - **Laravel API**: http://127.0.0.1:8000/api
   - **Admin Panel**: http://127.0.0.1:8000/admin

## 🔄 **Data Flow**

1. **User Registration/Login** → **API Authentication** → **Token Storage**
2. **Create Pengaduan** → **API Call** → **Database Storage** → **Response**
3. **View Pengaduan** → **API Call** → **Data Fetching** → **UI Update**
4. **Statistics** → **API Call** → **Data Aggregation** → **Dashboard Update**

## 🛠️ **Technologies Used**

### Frontend (Flutter)
- **GetX** - State management
- **Dio** - HTTP client
- **Flutter Secure Storage** - Secure token storage
- **Image Picker** - Photo upload
- **Material Design 3** - UI components

### Backend (Laravel)
- **Laravel Sanctum** - API authentication
- **Filament** - Admin panel
- **MySQL** - Database
- **Laravel Validation** - Form validation

## 📝 **Notes**

- Aplikasi sudah siap untuk production dengan beberapa penyesuaian
- Semua fitur utama sudah berfungsi dengan baik
- UI/UX sudah responsive dan user-friendly
- Security sudah diimplementasi dengan baik
- Error handling sudah lengkap
- Database design sudah optimal

# Sistem Role Management - Pengaduan Dinas Kominfo

## Fitur Role Management

### 1. **Role dan Permissions**
- **Super Admin**: Memiliki akses penuh ke semua fitur
- **Admin**: Dapat mengelola pengaduan dan profile

### 2. **Akses Berdasarkan Role**

#### Super Admin dapat:
- Mengelola semua pengaduan
- Mengelola semua user
- Mengelola semua admin
- Mengelola kategori
- Mengubah role user/admin
- Menghapus pengaduan
- Melihat dashboard lengkap

#### Admin dapat:
- Mengelola pengaduan
- Melihat dashboard pengaduan
- Mengelola profile sendiri

### 3. **Kredensial Login**

#### Super Admin:
- **Email**: superadmin@gunungkidul.id
- **Password**: password

#### Admin Biasa:
- **Email**: admin@gunungkidul.id
- **Password**: password

### 4. **Fitur Role Management**

#### A. **User Management** (Super Admin Only)
- Lihat semua user
- Promosi user menjadi admin
- Bulk action untuk promosi multiple user

#### B. **Admin Management** (Super Admin Only)
- Lihat semua admin
- Demosi admin menjadi user
- Edit informasi admin
- Bulk action untuk demosi multiple admin

#### C. **Dashboard Berdasarkan Role**
- Super Admin: Statistik lengkap (pengaduan, admin, user)
- Admin: Statistik pengaduan (total, pending, selesai)

### 5. **Cara Menggunakan**

#### Login Super Admin:
1. Buka http://127.0.0.1:8000/admin
2. Login dengan kredensial super admin
3. Akses menu "User" dan "Administrator"

#### Promosi User ke Admin:
1. Masuk menu "User"
2. Klik tombol "Promosi ke Admin" pada user
3. User akan dipindah ke tabel admins

#### Demosi Admin ke User:
1. Masuk menu "Administrator"
2. Klik tombol "Demosi ke User" pada admin
3. Admin akan dipindah ke tabel users

#### Bulk Actions:
- Pilih multiple records dengan checkbox
- Gunakan bulk action di atas tabel
- Konfirmasi aksi yang dipilih

### 6. **Keamanan**
- Middleware SuperAdminMiddleware untuk proteksi
- Guard yang berbeda untuk user dan admin
- Validation pada setiap perubahan role
- Tidak bisa demosi super admin

### 7. **Database**
- Tabel `users` untuk user biasa
- Tabel `admins` untuk administrator
- Field `role` untuk membedakan admin dan super_admin

### 8. **Navigation**
- Menu hanya tampil sesuai permission
- Super Admin melihat semua menu
- Admin biasa hanya melihat menu pengaduan

### 9. **Testing**
1. Login sebagai super admin
2. Coba promosi user ke admin
3. Login sebagai admin biasa
4. Cek menu yang tersedia
5. Coba akses menu yang tidak diizinkan

### 10. **Troubleshooting**
- Pastikan database sudah di-seed
- Cek role field di database
- Pastikan middleware berjalan dengan baik
- Cek authentication guard

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../utils/constants.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil'),
                subtitle: const Text('Kelola informasi profil Anda'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.toNamed('/profile');
                },
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            
            // App Settings Section
            const Text(
              'Pengaturan Aplikasi',
              style: TextStyle(
                fontSize: AppSizes.fontSize16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifikasi'),
                    subtitle: const Text('Atur notifikasi aplikasi'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Handle notification toggle
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Mode Gelap'),
                    subtitle: const Text('Aktifkan tema gelap'),
                    trailing: Switch(
                      value: Get.isDarkMode,
                      onChanged: (value) {
                        Get.changeThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Bahasa'),
                    subtitle: const Text('Bahasa Indonesia'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Handle language selection
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            
            // Help & Support Section
            const Text(
              'Bantuan & Dukungan',
              style: TextStyle(
                fontSize: AppSizes.fontSize16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Bantuan'),
                    subtitle: const Text('Cara menggunakan aplikasi'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showHelpDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Tentang Aplikasi'),
                    subtitle: const Text('Informasi aplikasi'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.contact_support),
                    title: const Text('Hubungi Kami'),
                    subtitle: const Text('Dinas Kominfo Gunung Kidul'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showContactDialog(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            
            // Account Section
            const Text(
              'Akun',
              style: TextStyle(
                fontSize: AppSizes.fontSize16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Keamanan'),
                    subtitle: const Text('Ubah kata sandi'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showChangePasswordDialog(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.dangerColor),
                    title: const Text(
                      'Keluar',
                      style: TextStyle(color: AppColors.dangerColor),
                    ),
                    subtitle: const Text('Keluar dari aplikasi'),
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacing32),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Aplikasi'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aplikasi Pengaduan Dinas Kominfo Gunung Kidul',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSizes.spacing8),
              Text('Versi: 1.0.0'),
              Text('Build: 1.0.0+1'),
              SizedBox(height: AppSizes.spacing16),
              Text(
                'Aplikasi ini dikembangkan untuk memudahkan masyarakat Gunung Kidul dalam menyampaikan pengaduan kepada Dinas Kominfo.',
              ),
              SizedBox(height: AppSizes.spacing16),
              Text(
                'Fitur:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Pengaduan online'),
              Text('• Tracking status pengaduan'),
              Text('• Notifikasi real-time'),
              Text('• Riwayat pengaduan'),
              SizedBox(height: AppSizes.spacing16),
              Text(
                'Dikembangkan oleh:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Dinas Kominfo Gunung Kidul'),
              Text('© 2025 - Pemerintah Kabupaten Gunung Kidul'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bantuan'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cara Menggunakan Aplikasi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSizes.spacing8),
              Text('1. Buat akun atau login'),
              Text('2. Buat pengaduan baru'),
              Text('3. Unggah foto dan bukti'),
              Text('4. Pantau status pengaduan'),
              Text('5. Dapatkan notifikasi update'),
              SizedBox(height: AppSizes.spacing16),
              Text(
                'Untuk bantuan lebih lanjut, hubungi Dinas Kominfo Gunung Kidul.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hubungi Kami'),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Dinas Kominfo Gunung Kidul',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSizes.spacing8),
            Text('Alamat: Jl. Brigjend Katamso No.1, Wonosari'),
            Text('Telepon: (0274) 391019'),
            Text('Email: kominfo@gunungkidulkab.go.id'),
            Text('Website: www.gunungkidulkab.go.id'),
            SizedBox(height: AppSizes.spacing8),
            Text('Jam Operasional:'),
            Text('Senin - Jumat: 08.00 - 16.00 WIB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Kata Sandi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Kata Sandi Lama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Kata Sandi Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Kata Sandi',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text == confirmPasswordController.text) {
                Get.back();
                Get.snackbar('Sukses', 'Kata sandi berhasil diubah');
              } else {
                Get.snackbar('Error', 'Konfirmasi kata sandi tidak cocok');
              }
            },
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.find<ProfileController>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerColor,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

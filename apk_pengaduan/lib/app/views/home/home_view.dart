import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Beranda'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Get.toNamed(AppRoutes.profile);
                  break;
                case 'settings':
                  Get.toNamed(AppRoutes.settings);
                  break;
                case 'logout':
                  authController.logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Pengaturan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Keluar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Obx(() => Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    Text(
                      authController.user.value?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: AppSizes.fontSize16,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      authController.user.value?.namaInstansi ?? 'Instansi',
                      style: const TextStyle(
                        fontSize: AppSizes.fontSize14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: AppSizes.spacing24),
            
            // Menu Grid
            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: AppSizes.fontSize18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: AppSizes.spacing16),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSizes.spacing16,
              mainAxisSpacing: AppSizes.spacing16,
              children: [
                _buildMenuCard(
                  icon: Icons.add_box,
                  title: 'Buat Pengaduan',
                  subtitle: 'Laporkan masalah baru',
                  onTap: () => Get.toNamed(AppRoutes.pengaduanCreate),
                ),
                _buildMenuCard(
                  icon: Icons.list_alt,
                  title: 'Daftar Pengaduan',
                  subtitle: 'Lihat semua pengaduan',
                  onTap: () => Get.toNamed(AppRoutes.pengaduanList),
                ),
                _buildMenuCard(
                  icon: Icons.history,
                  title: 'Riwayat',
                  subtitle: 'Lihat riwayat pengaduan',
                  onTap: () => Get.toNamed(AppRoutes.history),
                ),
                _buildMenuCard(
                  icon: Icons.notifications,
                  title: 'Notifikasi',
                  subtitle: 'Lihat notifikasi terbaru',
                  onTap: () => Get.toNamed(AppRoutes.notifications),
                ),
              ],
            ),
            
            const SizedBox(height: AppSizes.spacing24),
            
            // Quick Actions
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: AppSizes.fontSize18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: AppSizes.spacing16),
            
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Buat Pengaduan',
                    icon: Icons.add,
                    onPressed: () => Get.toNamed(AppRoutes.pengaduanCreate),
                  ),
                ),
                const SizedBox(width: AppSizes.spacing16),
                Expanded(
                  child: CustomButton(
                    text: 'Lihat Riwayat',
                    icon: Icons.history,
                    onPressed: () => Get.toNamed(AppRoutes.history),
                    isOutlined: true,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSizes.spacing24),
            
            // Info Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: AppSizes.spacing8),
                        Text(
                          'Informasi',
                          style: TextStyle(
                            fontSize: AppSizes.fontSize16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacing12),
                    const Text(
                      'Aplikasi ini digunakan untuk melaporkan masalah terkait teknologi informasi di lingkungan Dinas Kominfo Gunung Kidul.',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing12),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: AppSizes.iconSmall,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: AppSizes.spacing8),
                        const Text(
                          'Kontak: (0274) 391016',
                          style: TextStyle(
                            fontSize: AppSizes.fontSize14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppSizes.iconXLarge,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: AppSizes.spacing12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppSizes.fontSize16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacing4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: AppSizes.fontSize12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

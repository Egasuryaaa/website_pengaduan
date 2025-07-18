import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final authController = Get.find<AuthController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final user = controller.user.value ?? authController.user.value;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing24),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: AppSizes.avatarXLarge,
                        height: AppSizes.avatarXLarge,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: AppSizes.iconLarge,
                          color: AppColors.textWhite,
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.spacing16),
                      
                      // Name
                      Text(
                        user?.name ?? 'Nama User',
                        style: const TextStyle(
                          fontSize: AppSizes.fontSize20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.spacing4),
                      
                      // Institution
                      Text(
                        user?.namaInstansi ?? 'Nama Instansi',
                        style: const TextStyle(
                          fontSize: AppSizes.fontSize14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.spacing4),
                      
                      // Email
                      Text(
                        user?.email ?? 'email@example.com',
                        style: const TextStyle(
                          fontSize: AppSizes.fontSize14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.spacing16),
              
              // Menu Items
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit Profil'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed(AppRoutes.editProfile),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Ubah Password'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed(AppRoutes.changePassword),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.spacing16),
              
              // App Info
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Tentang Aplikasi'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed(AppRoutes.about),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Bantuan'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed(AppRoutes.help),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.spacing16),
              
              // Logout
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: AppColors.errorColor,
                  ),
                  title: const Text(
                    'Keluar',
                    style: TextStyle(
                      color: AppColors.errorColor,
                    ),
                  ),
                  onTap: () => authController.logout(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

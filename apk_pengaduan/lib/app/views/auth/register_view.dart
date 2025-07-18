import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.spacing24),
              
              // Header
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    SizedBox(height: AppSizes.spacing8),
                    
                    Text(
                      'Lengkapi data diri Anda',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.spacing32),
              
              // Register Form
              Form(
                key: controller.registerFormKey,
                child: Column(
                  children: [
                    // Name Field
                    CustomTextField(
                      controller: controller.nameController,
                      labelText: AppStrings.name,
                      hintText: 'Masukkan nama lengkap Anda',
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person_outline,
                      validator: (value) => controller.validateRequired(value, 'Nama'),
                    ),
                    
                    const SizedBox(height: AppSizes.spacing16),
                    
                    // Email Field
                    CustomTextField(
                      controller: controller.emailController,
                      labelText: AppStrings.email,
                      hintText: 'Masukkan email Anda',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: controller.validateEmail,
                    ),
                    
                    const SizedBox(height: AppSizes.spacing16),
                    
                    // Phone Field
                    CustomTextField(
                      controller: controller.phoneController,
                      labelText: AppStrings.phone,
                      hintText: 'Masukkan nomor telepon Anda',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: controller.validatePhone,
                    ),
                    
                    const SizedBox(height: AppSizes.spacing16),
                    
                    // Institution Field
                    CustomTextField(
                      controller: controller.namaInstansiController,
                      labelText: AppStrings.namaInstansi,
                      hintText: 'Masukkan nama instansi Anda',
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.business_outlined,
                      validator: (value) => controller.validateRequired(value, 'Nama Instansi'),
                    ),
                    
                    const SizedBox(height: AppSizes.spacing16),
                    
                    // Password Field
                    CustomTextField(
                      controller: controller.passwordController,
                      labelText: AppStrings.password,
                      hintText: 'Masukkan password Anda',
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: controller.validatePassword,
                    ),
                    
                    const SizedBox(height: AppSizes.spacing16),
                    
                    // Confirm Password Field
                    CustomTextField(
                      controller: controller.confirmPasswordController,
                      labelText: AppStrings.confirmPassword,
                      hintText: 'Konfirmasi password Anda',
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: controller.validateConfirmPassword,
                    ),
                    
                    const SizedBox(height: AppSizes.spacing32),
                    
                    // Register Button
                    Obx(() => CustomButton(
                      text: AppStrings.register,
                      onPressed: controller.isLoading.value ? null : controller.register,
                      isLoading: controller.isLoading.value,
                      width: double.infinity,
                    )),
                    
                    const SizedBox(height: AppSizes.spacing16),
                    
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            fontSize: AppSizes.fontSize14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.goToLogin,
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: AppSizes.fontSize14,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

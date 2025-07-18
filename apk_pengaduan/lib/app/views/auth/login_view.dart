import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.spacing48),
              
              // Header
              Center(
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.report_problem,
                        size: 50,
                        color: AppColors.textWhite,
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.spacing24),
                    
                    // Title
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.spacing8),
                    
                    const Text(
                      'Masuk ke akun Anda',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.spacing48),
              
              // Login Form
              Form(
                key: controller.loginFormKey,
                child: Column(
                  children: [
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
                    
                    // Password Field
                    CustomTextField(
                      controller: controller.passwordController,
                      labelText: AppStrings.password,
                      hintText: 'Masukkan password Anda',
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: controller.validatePassword,
                    ),
                    
                    const SizedBox(height: AppSizes.spacing24),
                    
                    // Login Button
                    Obx(() => CustomButton(
                      text: AppStrings.login,
                      onPressed: controller.isLoading.value ? null : controller.login,
                      isLoading: controller.isLoading.value,
                      width: double.infinity,
                    )),
                    
                    const SizedBox(height: AppSizes.spacing16),
                    
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            fontSize: AppSizes.fontSize14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.goToRegister,
                          child: const Text(
                            'Daftar',
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

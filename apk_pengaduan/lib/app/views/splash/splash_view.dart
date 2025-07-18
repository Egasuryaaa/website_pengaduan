import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: AppConstants.splashDuration));
    
    // Check if user is logged in
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    
    if (isLoggedIn) {
      // Validate token
      final result = await authService.getCurrentUser();
      if (result['success']) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or Animation
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
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
                size: 60,
                color: AppColors.primaryColor,
              ),
            ),
            
            const SizedBox(height: AppSizes.spacing32),
            
            // App Name
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: AppSizes.fontSize24,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            
            const SizedBox(height: AppSizes.spacing8),
            
            // Subtitle
            const Text(
              'Dinas Kominfo Gunung Kidul',
              style: TextStyle(
                fontSize: AppSizes.fontSize16,
                color: AppColors.textWhite,
              ),
            ),
            
            const SizedBox(height: AppSizes.spacing48),
            
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
              strokeWidth: 3,
            ),
            
            const SizedBox(height: AppSizes.spacing16),
            
            const Text(
              'Memuat...',
              style: TextStyle(
                fontSize: AppSizes.fontSize14,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: const Text(
          AppStrings.copyright,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.fontSize12,
            color: AppColors.textWhite,
          ),
        ),
      ),
    );
  }
}

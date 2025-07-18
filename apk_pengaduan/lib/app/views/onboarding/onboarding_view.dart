import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  
  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Selamat Datang',
      description: 'Aplikasi pengaduan resmi Dinas Kominfo Gunung Kidul untuk memudahkan Anda dalam melaporkan masalah teknologi informasi.',
      icon: Icons.waving_hand,
    ),
    OnboardingItem(
      title: 'Mudah Digunakan',
      description: 'Laporkan masalah dengan mudah melalui form yang sederhana dan lengkapi dengan foto bukti untuk mempercepat proses penanganan.',
      icon: Icons.touch_app,
    ),
    OnboardingItem(
      title: 'Pantau Status',
      description: 'Pantau perkembangan pengaduan Anda secara real-time dan dapatkan notifikasi untuk setiap update status pengaduan.',
      icon: Icons.track_changes,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  child: const Text(
                    'Lewati',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontSize14,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSizes.spacing32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 60,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        
                        const SizedBox(height: AppSizes.spacing48),
                        
                        // Title
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: AppSizes.fontSize28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: AppSizes.spacing24),
                        
                        // Description
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: AppSizes.fontSize16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing32),
              child: Column(
                children: [
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: AppConstants.animationDuration),
                        margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing4),
                        width: _currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index 
                              ? AppColors.primaryColor 
                              : AppColors.dividerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.spacing32),
                  
                  // Navigation Buttons
                  Row(
                    children: [
                      // Previous Button
                      if (_currentIndex > 0)
                        Expanded(
                          child: CustomButton(
                            text: 'Sebelumnya',
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: AppConstants.animationDuration),
                                curve: Curves.easeInOut,
                              );
                            },
                            isOutlined: true,
                          ),
                        ),
                      
                      if (_currentIndex > 0)
                        const SizedBox(width: AppSizes.spacing16),
                      
                      // Next/Finish Button
                      Expanded(
                        child: CustomButton(
                          text: _currentIndex == _items.length - 1 ? 'Mulai' : 'Selanjutnya',
                          onPressed: () {
                            if (_currentIndex == _items.length - 1) {
                              Get.offAllNamed(AppRoutes.login);
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: AppConstants.animationDuration),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
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
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

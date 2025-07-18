import 'package:get/get.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/splash/splash_view.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/home/home_view.dart';
import '../views/pengaduan/pengaduan_list_view.dart';
import '../views/pengaduan/pengaduan_detail_view.dart';
import '../views/pengaduan/pengaduan_create_view.dart';
import '../views/profile/profile_view.dart';
import '../views/profile/edit_profile_view.dart';
import '../views/history/history_view.dart';
import '../views/settings/settings_view.dart';
import '../views/settings/about_view.dart';
import '../views/notifications/notifications_view.dart';
import '../controllers/auth_controller.dart';
import '../controllers/pengaduan_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/notification_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      transition: Transition.fadeIn,
    ),
    
    // Onboarding
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      transition: Transition.rightToLeft,
    ),
    
    // Auth
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
      transition: Transition.fadeIn,
    ),
    
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    // Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
        Get.lazyPut(() => PengaduanController());
      }),
      transition: Transition.fadeIn,
    ),
    
    // Pengaduan
    GetPage(
      name: AppRoutes.pengaduanList,
      page: () => const PengaduanListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PengaduanController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    GetPage(
      name: AppRoutes.pengaduanDetail,
      page: () => const PengaduanDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PengaduanController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    GetPage(
      name: AppRoutes.pengaduanCreate,
      page: () => const PengaduanCreateView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PengaduanController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    GetPage(
      name: AppRoutes.pengaduanEdit,
      page: () => const PengaduanCreateView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PengaduanController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    // History
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HistoryController());
      }),
      transition: Transition.rightToLeft,
    ),
    
    // Settings
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      transition: Transition.rightToLeft,
    ),
    
    GetPage(
      name: AppRoutes.about,
      page: () => const AboutView(),
      transition: Transition.rightToLeft,
    ),
    
    // Notifications
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NotificationController());
      }),
      transition: Transition.rightToLeft,
    ),
  ];
}

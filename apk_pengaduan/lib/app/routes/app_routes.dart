abstract class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main Routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  
  // Pengaduan Routes
  static const String pengaduanList = '/pengaduan';
  static const String pengaduanDetail = '/pengaduan/detail';
  static const String pengaduanCreate = '/pengaduan/create';
  static const String pengaduanEdit = '/pengaduan/edit';
  
  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  
  // History Routes
  static const String history = '/history';
  static const String historyDetail = '/history/detail';
  
  // Settings Routes
  static const String settings = '/settings';
  static const String about = '/about';
  static const String help = '/help';
  
  // Notification Routes
  static const String notifications = '/notifications';
  static const String notificationDetail = '/notification/detail';
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/pengaduan/create_pengaduan_screen.dart';
import 'screens/pengaduan/pengaduan_list_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/pengaduan_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize controllers
  final authController = Get.put(AuthController());
  
  // Initial check for login state
  await authController.checkLoginStatus();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pengaduan Dinas Kominfo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/create-pengaduan', page: () => CreatePengaduanScreen()),
        GetPage(name: '/pengaduan-list', page: () => PengaduanListScreen()),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers if not already done
    final AuthController authController = Get.find<AuthController>();
    
    // Make sure PengaduanController is available
    if (!Get.isRegistered<PengaduanController>()) {
      Get.put(PengaduanController());
    }
    
    // Check login status and navigate
    _checkLoginAndNavigate(authController);
  }
  
  Future<void> _checkLoginAndNavigate(AuthController authController) async {
    try {
      // Wait for login check to complete or timeout after 3 seconds
      await Future.delayed(const Duration(seconds: 2));
      
      print('DEBUG: Login state after splash: ${authController.isLoggedIn.value}');
      
      if (authController.isLoggedIn.value) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('DEBUG: Error in splash navigation: $e');
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.report_problem,
                size: 60,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Pengaduan Dinas Kominfo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Gunung Kidul',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

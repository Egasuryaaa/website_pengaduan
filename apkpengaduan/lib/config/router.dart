import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/pengaduan/pengaduan_list_screen.dart';
import '../screens/pengaduan/create_pengaduan_screen.dart';
import '../screens/pengaduan/pengaduan_detail_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/change_password_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;
        
        // Show loading screen while checking auth - don't redirect yet
        if (isLoading) return null;
        
        final isAuthRoute = state.fullPath?.startsWith('/login') == true ||
                          state.fullPath?.startsWith('/register') == true;
        
        // Only redirect to login if we're sure user is not authenticated
        // and not already on an auth route
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }
        
        // Only redirect to home if user is authenticated and on auth route
        if (isAuthenticated && isAuthRoute) {
          return '/';
        }
        
        // No redirect needed
        return null;
      },
      routes: [
        // Auth routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        
        // Main app routes
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        
        // Pengaduan routes
        GoRoute(
          path: '/pengaduan',
          builder: (context, state) => const PengaduanListScreen(),
        ),
        GoRoute(
          path: '/pengaduan/create',
          builder: (context, state) => const CreatePengaduanScreen(),
        ),
        GoRoute(
          path: '/pengaduan/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PengaduanDetailScreen(pengaduanId: id);
          },
        ),
        GoRoute(
          path: '/pengaduan/:id/edit',
          builder: (context, state) {
    
            return const Scaffold(
              body: Center(
                child: Text('Edit Pengaduan Screen - Coming Soon'),
              ),
            );
          },
        ),
        
        // Profile routes
        GoRoute(
          path: '/profile',
          builder: (context, state) => const HomeScreen(), // Will show profile tab
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/profile/change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Halaman tidak ditemukan: ${state.fullPath}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

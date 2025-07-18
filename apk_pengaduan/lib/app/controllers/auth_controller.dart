import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_utils.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  // Observable variables
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final user = Rxn<UserModel>();
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final namaInstansiController = TextEditingController();
  
  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    namaInstansiController.dispose();
    super.onClose();
  }
  
  Future<void> checkAuthStatus() async {
    isLoading.value = true;
    
    try {
      final loggedIn = await _authService.isLoggedIn();
      if (loggedIn) {
        final result = await _authService.getCurrentUser();
        if (result['success']) {
          user.value = result['user'];
          isLoggedIn.value = true;
        } else {
          isLoggedIn.value = false;
        }
      } else {
        isLoggedIn.value = false;
      }
    } catch (e) {
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    
    isLoading.value = true;
    
    try {
      final result = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      if (result['success']) {
        user.value = result['user'];
        isLoggedIn.value = true;
        AppUtils.showSuccessToast(result['message']);
        Get.offAllNamed(AppRoutes.home);
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Login gagal: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;
    
    isLoading.value = true;
    
    try {
      final result = await _authService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim(),
        namaInstansi: namaInstansiController.text.trim(),
      );
      
      if (result['success']) {
        user.value = result['user'];
        isLoggedIn.value = true;
        AppUtils.showSuccessToast(result['message']);
        Get.offAllNamed(AppRoutes.home);
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Registrasi gagal: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    final confirm = await AppUtils.showConfirmDialog(
      title: 'Konfirmasi',
      message: 'Apakah Anda yakin ingin keluar?',
    );
    
    if (!confirm) return;
    
    isLoading.value = true;
    
    try {
      await _authService.logout();
      user.value = null;
      isLoggedIn.value = false;
      AppUtils.showSuccessToast('Berhasil keluar');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      AppUtils.showErrorToast('Logout gagal: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refreshToken() async {
    try {
      final result = await _authService.refreshToken();
      if (result['success']) {
        user.value = result['user'];
      }
    } catch (e) {
      // Silent fail for token refresh
    }
  }
  
  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    phoneController.clear();
    namaInstansiController.clear();
  }
  
  void goToLogin() {
    clearControllers();
    Get.toNamed(AppRoutes.login);
  }
  
  void goToRegister() {
    clearControllers();
    Get.toNamed(AppRoutes.register);
  }
  
  // Validation methods
  String? validateEmail(String? value) {
    return AppUtils.validateEmail(value);
  }
  
  String? validatePassword(String? value) {
    return AppUtils.validatePassword(value);
  }
  
  String? validateConfirmPassword(String? value) {
    return AppUtils.validateConfirmPassword(value, passwordController.text);
  }
  
  String? validatePhone(String? value) {
    return AppUtils.validatePhone(value);
  }
  
  String? validateRequired(String? value, [String? fieldName]) {
    return AppUtils.validateRequired(value, fieldName);
  }
}

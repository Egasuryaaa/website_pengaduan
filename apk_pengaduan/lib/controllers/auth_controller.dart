import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  
  // Observables
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var user = Rxn<User>();
  
  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final namaInstansiController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }
  
  Future<void> checkLoginStatus() async {
    try {
      isLoading.value = true;
      
      // First check if we have a token stored
      isLoggedIn.value = await _apiService.isLoggedIn();
      print('DEBUG: Token exists: ${isLoggedIn.value}');
      
      if (isLoggedIn.value) {
        // If we have a token, try to get the user profile to verify it's valid
        try {
          print('DEBUG: Attempting to validate token by getting profile');
          final result = await getProfile(showErrors: false);
          
          if (result) {
            print('DEBUG: Token is valid, user profile retrieved successfully');
          } else {
            print('DEBUG: Token exists but profile retrieval failed - token may be invalid');
            isLoggedIn.value = false;
            // Clear token if invalid
            await logout(showMessage: false);
          }
        } catch (e) {
          print('DEBUG: Exception when validating token: $e');
          // Token might be invalid or expired
          isLoggedIn.value = false;
          // Clear token if invalid
          await logout(showMessage: false);
        }
      } else {
        print('DEBUG: No token found, user is not logged in');
      }
    } catch (e) {
      print('DEBUG: Error checking login status: $e');
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> register() async {
    try {
      isLoading.value = true;
      
      final data = {
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'password_confirmation': confirmPasswordController.text,
        'phone': phoneController.text,
        'nama_instansi': namaInstansiController.text,
      };
      
      final response = await _apiService.register(data);
      
      if (response['success']) {
        user.value = User.fromJson(response['data']['user']);
        isLoggedIn.value = true;
        
        Get.snackbar(
          'Berhasil',
          'Registrasi berhasil!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Registrasi gagal',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> login() async {
    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        Get.snackbar(
          'Error',
          'Email dan password harus diisi',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      isLoading.value = true;
      
      print('DEBUG: AuthController - Attempting login with email: ${emailController.text}');
      
      final response = await _apiService.login(
        emailController.text,
        passwordController.text,
      );
      
      print('DEBUG: AuthController - Login response: $response');
      
      if (response['success']) {
        // Pastikan data user ada
        if (response['data'] != null && response['data']['user'] != null) {
          user.value = User.fromJson(response['data']['user']);
          isLoggedIn.value = true;
          
          Get.snackbar(
            'Berhasil',
            'Login berhasil!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          
          Get.offAllNamed('/home');
        } else {
          print('DEBUG: AuthController - Login success but missing user data');
          Get.snackbar(
            'Error',
            'Data user tidak valid',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Login gagal',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout({bool showMessage = true}) async {
    try {
      isLoading.value = true;
      
      // The improved API service logout handles all exceptions internally
      final result = await _apiService.logout();
      print('DEBUG: Logout result: $result');
      
      // Always clear local state
      user.value = null;
      isLoggedIn.value = false;
      
      if (showMessage) {
        Get.snackbar(
          'Berhasil',
          'Logout berhasil!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      Get.offAllNamed('/login');
    } catch (e) {
      print('DEBUG: Critical error in logout: $e');
      // Still clear local state even on error
      user.value = null;
      isLoggedIn.value = false;
      
      if (showMessage) {
        Get.snackbar(
          'Error',
          'Terjadi kesalahan saat logout: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> getProfile({bool showErrors = true}) async {
    try {
      print('DEBUG: Getting user profile in controller');
      final response = await _apiService.getProfile();
      
      if (response['success'] && response['data'] != null) {
        print('DEBUG: User profile retrieved successfully');
        user.value = User.fromJson(response['data']);
        isLoggedIn.value = true;
        return true;
      } else {
        print('DEBUG: Failed to get user profile: ${response['message']}');
        isLoggedIn.value = false;
        
        if (showErrors) {
          Get.snackbar(
            'Error',
            'Failed to get user profile: ${response['message']}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        
        return false;
      }
    } catch (e) {
      print('DEBUG: Error getting profile: $e');
      isLoggedIn.value = false;
      
      if (showErrors) {
        Get.snackbar(
          'Error',
          'Error getting profile: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      
      if (showErrors) {
        throw e; // Only rethrow if showErrors is true
      }
      return false;
    }
  }
  
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      
      final data = {
        'name': nameController.text,
        'phone': phoneController.text,
        'nama_instansi': namaInstansiController.text,
      };
      
      final response = await _apiService.updateProfile(data);
      
      if (response['success']) {
        user.value = User.fromJson(response['data']);
        
        Get.snackbar(
          'Berhasil',
          'Profile berhasil diperbarui!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Update profile gagal',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    namaInstansiController.clear();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    namaInstansiController.dispose();
    super.onClose();
  }
}

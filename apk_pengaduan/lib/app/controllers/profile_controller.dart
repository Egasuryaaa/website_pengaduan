import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_utils.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();
  
  // Observable variables
  final isLoading = false.obs;
  final user = Rxn<UserModel>();
  
  // Form controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final namaInstansiController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // Form keys
  final profileFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    namaInstansiController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  Future<void> loadUserProfile() async {
    isLoading.value = true;
    
    try {
      final result = await _authService.getCurrentUser();
      if (result['success']) {
        user.value = result['user'];
        _fillFormData();
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Gagal memuat profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateProfile() async {
    if (!profileFormKey.currentState!.validate()) return;
    
    isLoading.value = true;
    
    try {
      final result = await _authService.updateProfile(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        namaInstansi: namaInstansiController.text.trim(),
      );
      
      if (result['success']) {
        user.value = result['user'];
        AppUtils.showSuccessToast(result['message']);
        Get.back();
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Gagal memperbarui profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> changePassword() async {
    if (!passwordFormKey.currentState!.validate()) return;
    
    isLoading.value = true;
    
    try {
      final result = await _authService.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
      
      if (result['success']) {
        AppUtils.showSuccessToast(result['message']);
        _clearPasswordForm();
        Get.back();
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Gagal mengubah password: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: $e');
    }
  }
  
  void _fillFormData() {
    if (user.value != null) {
      nameController.text = user.value!.name ?? '';
      phoneController.text = user.value!.phone ?? '';
      namaInstansiController.text = user.value!.namaInstansi ?? '';
    }
  }
  
  void _clearPasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }
  
  // Validation methods
  String? validateRequired(String? value, [String? fieldName]) {
    return AppUtils.validateRequired(value, fieldName);
  }
  
  String? validatePhone(String? value) {
    return AppUtils.validatePhone(value);
  }
  
  String? validatePassword(String? value) {
    return AppUtils.validatePassword(value);
  }
  
  String? validateConfirmPassword(String? value) {
    return AppUtils.validateConfirmPassword(value, newPasswordController.text);
  }
}

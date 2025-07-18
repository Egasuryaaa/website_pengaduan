import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../models/pengaduan_model.dart';
import '../services/pengaduan_service.dart';
import '../utils/app_utils.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class PengaduanController extends GetxController {
  final PengaduanService _pengaduanService = PengaduanService();
  
  // Observable variables
  final isLoading = false.obs;
  final pengaduanList = <PengaduanModel>[].obs;
  final kategoriList = <KategoriModel>[].obs;
  final selectedPengaduan = Rxn<PengaduanModel>();
  final selectedImagePath = Rxn<String>();
  final selectedImageBytes = Rxn<Uint8List>(); // For web
  final selectedImageName = Rxn<String>(); // For web
  
  // Form controllers
  final namaInstansiController = TextEditingController();
  final deskripsiController = TextEditingController();
  final selectedKategori = Rxn<KategoriModel>();
  
  // Form key
  final pengaduanFormKey = GlobalKey<FormState>();
  
  // Pagination
  final currentPage = 1.obs;
  final hasMore = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadKategori();
  }
  
  @override
  void onClose() {
    namaInstansiController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }
  
  Future<void> loadKategori() async {
    try {
      final result = await _pengaduanService.getKategoriList();
      if (result['success']) {
        kategoriList.assignAll(result['kategori']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Gagal memuat kategori: $e');
    }
  }
  
  Future<void> loadPengaduanList({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }
    
    if (!hasMore.value) return;
    
    isLoading.value = true;
    
    try {
      final result = await _pengaduanService.getPengaduanList(
        page: currentPage.value,
        limit: AppConstants.defaultPageSize,
      );
      
      if (result['success']) {
        final newPengaduan = result['pengaduan'] as List<PengaduanModel>;
        
        if (isRefresh) {
          pengaduanList.assignAll(newPengaduan);
        } else {
          pengaduanList.addAll(newPengaduan);
        }
        
        // Check if there are more items
        hasMore.value = newPengaduan.length >= AppConstants.defaultPageSize;
        currentPage.value++;
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Gagal memuat pengaduan: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadPengaduanDetail(String id) async {
    isLoading.value = true;
    
    try {
      final result = await _pengaduanService.getPengaduanDetail(id);
      
      if (result['success']) {
        selectedPengaduan.value = result['pengaduan'];
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Gagal memuat detail pengaduan: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> createPengaduan() async {
    if (!pengaduanFormKey.currentState!.validate()) return;
    
    if (selectedKategori.value == null) {
      AppUtils.showErrorToast('Pilih kategori pengaduan');
      return;
    }
    
    isLoading.value = true;
    
    try {
      // Debug: print data yang akan dikirim
      print('DEBUG: Sending data to API:');
      print('namaInstansi: ${namaInstansiController.text.trim()}');
      print('deskripsi: ${deskripsiController.text.trim()}');
      print('kategoriId: ${selectedKategori.value!.id!}');
      print('fotoBukti: ${selectedImagePath.value}');
      print('imageBytes: ${selectedImageBytes.value != null ? 'Has bytes' : 'No bytes'}');
      print('imageName: ${selectedImageName.value}');
      
      // Make sure we have valid data that matches the backend expectations
      final namaInstansi = namaInstansiController.text.trim();
      final deskripsi = deskripsiController.text.trim();
      int kategoriId;
      
      try {
        kategoriId = int.parse(selectedKategori.value!.id!);
        print('Parsed kategori ID: $kategoriId');
      } catch (e) {
        print('Error parsing kategori ID: $e');
        kategoriId = 1; // Default to first kategori if parsing fails
      }
      
      // First try without image
      final result = await _pengaduanService.createPengaduan(
        namaInstansi: namaInstansi,
        deskripsi: deskripsi,
        kategoriId: kategoriId,
      );
      
      if (result['success']) {
        AppUtils.showSuccessToast(result['message']);
        clearForm();
        Get.back();
        // Refresh list if on pengaduan list page
        if (Get.currentRoute == AppRoutes.pengaduanList) {
          loadPengaduanList(isRefresh: true);
        }
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Gagal membuat pengaduan: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updatePengaduan(String id) async {
    if (!pengaduanFormKey.currentState!.validate()) return;
    
    if (selectedKategori.value == null) {
      AppUtils.showErrorToast('Pilih kategori pengaduan');
      return;
    }
    
    isLoading.value = true;
    
    try {
      final result = await _pengaduanService.updatePengaduan(
        id: id,
        namaInstansi: namaInstansiController.text.trim(),
        deskripsi: deskripsiController.text.trim(),
        kategoriId: int.parse(selectedKategori.value!.id!),
        fotoBukti: selectedImagePath.value,
      );
      
      if (result['success']) {
        AppUtils.showSuccessToast(result['message']);
        clearForm();
        Get.back();
        // Refresh list if on pengaduan list page
        if (Get.currentRoute == AppRoutes.pengaduanList) {
          loadPengaduanList(isRefresh: true);
        }
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Gagal memperbarui pengaduan: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deletePengaduan(String id) async {
    final confirm = await AppUtils.showConfirmDialog(
      title: 'Konfirmasi',
      message: 'Apakah Anda yakin ingin menghapus pengaduan ini?',
    );
    
    if (!confirm) return;
    
    isLoading.value = true;
    
    try {
      final result = await _pengaduanService.deletePengaduan(id);
      
      if (result['success']) {
        AppUtils.showSuccessToast(result['message']);
        // Remove from list
        pengaduanList.removeWhere((item) => item.id == id);
        Get.back();
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Gagal menghapus pengaduan: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await image.readAsBytes();
        selectedImageBytes.value = bytes;
        selectedImageName.value = image.name;
        selectedImagePath.value = null; // Clear path for web
      } else {
        // For mobile, use path
        selectedImagePath.value = image.path;
        selectedImageBytes.value = null; // Clear bytes for mobile
        selectedImageName.value = null;
      }
    }
  }
  
  void removeImage() {
    selectedImagePath.value = null;
    selectedImageBytes.value = null;
    selectedImageName.value = null;
  }
  
  void clearForm() {
    namaInstansiController.clear();
    deskripsiController.clear();
    selectedKategori.value = null;
    selectedImagePath.value = null;
  }
  
  void setEditMode(PengaduanModel pengaduan) {
    namaInstansiController.text = pengaduan.namaInstansi ?? '';
    deskripsiController.text = pengaduan.deskripsi ?? '';
    selectedKategori.value = pengaduan.kategori;
    selectedImagePath.value = pengaduan.fotoBukti;
  }
  
  void goToDetail(PengaduanModel pengaduan) {
    selectedPengaduan.value = pengaduan;
    Get.toNamed(AppRoutes.pengaduanDetail, arguments: pengaduan.id);
  }
  
  void goToEdit(PengaduanModel pengaduan) {
    setEditMode(pengaduan);
    Get.toNamed(AppRoutes.pengaduanEdit, arguments: pengaduan);
  }
  
  void goToCreate() {
    clearForm();
    Get.toNamed(AppRoutes.pengaduanCreate);
  }
  
  // Validation methods
  String? validateRequired(String? value, [String? fieldName]) {
    return AppUtils.validateRequired(value, fieldName);
  }
  
  String? validateNamaInstansi(String? value) {
    return validateRequired(value, 'Nama Instansi');
  }
  
  String? validateDeskripsi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi wajib diisi';
    }
    if (value.trim().length < 10) {
      return 'Deskripsi minimal 10 karakter';
    }
    return null;
  }
}

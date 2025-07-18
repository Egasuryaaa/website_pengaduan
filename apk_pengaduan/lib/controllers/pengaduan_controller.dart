import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import '../models/pengaduan.dart';
import '../models/kategori.dart';
import '../services/api_service.dart';

class PengaduanController extends GetxController {
  final ApiService _apiService = ApiService();
  
  // Observables
  var isLoading = false.obs;
  var pengaduans = <Pengaduan>[].obs;
  var kategoris = <Kategori>[].obs;
  var statistics = {}.obs;
  var selectedImage = Rxn<File>();
  var selectedImageBytes = Rxn<Uint8List>(); // For web
  var selectedImageName = Rxn<String>(); // For web
  
  // Form controllers
  final judulController = TextEditingController();
  final deskripsiController = TextEditingController();
  final lokasiController = TextEditingController();
  var selectedKategoriId = Rxn<int>();
  
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  
  Future<void> loadData() async {
    await Future.wait([
      getPengaduans(),
      getKategoris(),
      getStatistics(),
    ]);
  }
  
  Future<void> getPengaduans() async {
    try {
      isLoading.value = true;
      
      final response = await _apiService.getPengaduans();
      
      if (response['success']) {
        pengaduans.value = (response['data'] as List)
            .map((item) => Pengaduan.fromJson(item))
            .toList();
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
  
  Future<void> getKategoris() async {
    try {
      final response = await _apiService.getKategori();
      
      if (response['success']) {
        kategoris.value = (response['data'] as List)
            .map((item) => Kategori.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error getting categories: $e');
    }
  }
  
  Future<void> getStatistics() async {
    try {
      final response = await _apiService.getStatistics();
      
      if (response['success']) {
        statistics.value = response['data'];
      }
    } catch (e) {
      print('Error getting statistics: $e');
    }
  }
  
  Future<void> createPengaduan() async {
    try {
      // Check if form is valid
      if (selectedKategoriId.value == null) {
        Get.snackbar(
          'Error',
          'Pilih kategori pengaduan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      isLoading.value = true;
      
      // Print debug information
      print('DEBUG: Starting pengaduan creation process');
      print('DEBUG: Judul: ${judulController.text}');
      print('DEBUG: Deskripsi: ${deskripsiController.text}');
      print('DEBUG: Lokasi: ${lokasiController.text}');
      print('DEBUG: Kategori ID: ${selectedKategoriId.value}');
      print('DEBUG: Has image? ${selectedImage.value != null}');
      print('DEBUG: Has image bytes? ${selectedImageBytes.value != null}');
      
      // Check authentication status before proceeding
      final isAuth = await _apiService.isLoggedIn();
      print('DEBUG: User is authenticated: $isAuth');
      
      if (!isAuth) {
        Get.snackbar(
          'Error',
          'Anda belum login. Silakan login terlebih dahulu.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }
      
      // Data akan dimasukkan langsung ke FormData
      
      // Persiapkan foto, backend mengharapkan foto_bukti sebagai FormData
      dio.FormData formData = dio.FormData();
      
      // Tambahkan field data ke formData
      formData.fields.add(MapEntry('deskripsi', deskripsiController.text.trim()));
      formData.fields.add(MapEntry('nama_instansi', lokasiController.text.trim()));
      formData.fields.add(MapEntry('kategori_id', selectedKategoriId.value.toString()));
      
      if (selectedImage.value != null) {
        print('DEBUG: Adding image file from path: ${selectedImage.value!.path}');
        formData.files.add(MapEntry(
          'foto_bukti',
          await dio.MultipartFile.fromFile(
            selectedImage.value!.path,
            filename: 'pengaduan_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      } else if (selectedImageBytes.value != null && selectedImageName.value != null) {
        print('DEBUG: Adding image from bytes with name: ${selectedImageName.value}');
        formData.files.add(MapEntry(
          'foto_bukti',
          dio.MultipartFile.fromBytes(
            selectedImageBytes.value!,
            filename: selectedImageName.value,
          ),
        ));
      }
      
      final response = await _apiService.createPengaduan(formData);
      
      if (response['success']) {
        Get.snackbar(
          'Berhasil',
          'Pengaduan berhasil dibuat!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        clearForm();
        await loadData(); // Refresh data
        Get.back(); // Close form
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Pengaduan gagal dibuat',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('DEBUG: Error in createPengaduan: $e');
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
  
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        if (kIsWeb) {
          // For web, read as bytes
          final bytes = await image.readAsBytes();
          selectedImageBytes.value = bytes;
          selectedImageName.value = image.name;
          selectedImage.value = null; // Clear file for web
        } else {
          // For mobile, use file
          selectedImage.value = File(image.path);
          selectedImageBytes.value = null; // Clear bytes for mobile
          selectedImageName.value = null;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        if (kIsWeb) {
          // For web, read as bytes
          final bytes = await image.readAsBytes();
          selectedImageBytes.value = bytes;
          selectedImageName.value = image.name;
          selectedImage.value = null; // Clear file for web
        } else {
          // For mobile, use file
          selectedImage.value = File(image.path);
          selectedImageBytes.value = null; // Clear bytes for mobile
          selectedImageName.value = null;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  void clearForm() {
    judulController.clear();
    deskripsiController.clear();
    lokasiController.clear();
    selectedKategoriId.value = null;
    selectedImage.value = null;
  }
  
  @override
  void onClose() {
    judulController.dispose();
    deskripsiController.dispose();
    lokasiController.dispose();
    super.onClose();
  }
}

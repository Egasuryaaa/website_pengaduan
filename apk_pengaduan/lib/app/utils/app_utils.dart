import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../utils/constants.dart';

class AppUtils {
  // Date and Time Formatting
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat(AppConstants.dateTimeFormat).format(date);
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Status Formatting
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.statusPending:
        return AppStrings.statusPending;
      case AppConstants.statusDiproses:
        return AppStrings.statusDiproses;
      case AppConstants.statusSelesai:
        return AppStrings.statusSelesai;
      case AppConstants.statusDitolak:
        return AppStrings.statusDitolak;
      default:
        return status;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.statusPending:
        return AppColors.statusPending;
      case AppConstants.statusDiproses:
        return AppColors.statusDiproses;
      case AppConstants.statusSelesai:
        return AppColors.statusSelesai;
      case AppConstants.statusDitolak:
        return AppColors.statusDitolak;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.statusPending:
        return Icons.hourglass_empty;
      case AppConstants.statusDiproses:
        return Icons.refresh;
      case AppConstants.statusSelesai:
        return Icons.check_circle;
      case AppConstants.statusDitolak:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Validation
  static bool isValidEmail(String email) {
    return RegExp(AppConstants.emailRegex).hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(AppConstants.phoneRegex).hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (!isValidEmail(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (!isValidPassword(value)) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value != password) {
      return AppStrings.passwordNotMatch;
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (!isValidPhone(value)) {
      return AppStrings.invalidPhone;
    }
    return null;
  }

  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName wajib diisi' : AppStrings.fieldRequired;
    }
    return null;
  }

  // File Handling
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  static bool isValidImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.allowedImageTypes.contains(extension);
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Image Picker with Permissions
  static Future<String?> pickImage({
    required ImageSource source,
    int imageQuality = 70,
  }) async {
    try {
      // Check permissions
      final permission = source == ImageSource.camera 
          ? Permission.camera 
          : Permission.photos;
      
      final status = await permission.request();
      
      if (status.isDenied) {
        showToast(source == ImageSource.camera 
            ? AppStrings.cameraPermissionMessage 
            : AppStrings.storagePermissionMessage);
        return null;
      }
      
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return null;
      }
      
      // Pick image
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );
      
      if (pickedFile != null) {
        // Validate file size
        final fileSize = await pickedFile.length();
        if (fileSize > AppConstants.maxFileSize) {
          showToast('Ukuran file maksimal ${formatFileSize(AppConstants.maxFileSize)}');
          return null;
        }
        
        return pickedFile.path;
      }
      
      return null;
    } catch (e) {
      showToast('Gagal mengambil gambar: $e');
      return null;
    }
  }

  // Show Image Picker Options
  static Future<String?> showImagePickerOptions() async {
    return await Get.bottomSheet<String>(
      Container(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        decoration: const BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radius16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            const Text(
              AppStrings.chooseImage,
              style: TextStyle(
                fontSize: AppSizes.fontSize18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(AppStrings.takePhoto),
              onTap: () async {
                final image = await pickImage(source: ImageSource.camera);
                Get.back(result: image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(AppStrings.chooseFromGallery),
              onTap: () async {
                final image = await pickImage(source: ImageSource.gallery);
                Get.back(result: image);
              },
            ),
            const SizedBox(height: AppSizes.spacing16),
          ],
        ),
      ),
    );
  }

  // Toast Messages
  static void showToast(String message, {
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color backgroundColor = AppColors.textPrimary,
    Color textColor = AppColors.textWhite,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  static void showSuccessToast(String message) {
    showToast(message, backgroundColor: AppColors.successColor);
  }

  static void showErrorToast(String message) {
    showToast(message, backgroundColor: AppColors.errorColor);
  }

  static void showWarningToast(String message) {
    showToast(message, backgroundColor: AppColors.warningColor);
  }

  static void showInfoToast(String message) {
    showToast(message, backgroundColor: AppColors.infoColor);
  }

  // Dialogs
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = AppStrings.yes,
    String cancelText = AppStrings.no,
  }) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    ) ?? false;
  }

  // Loading Dialog
  static void showLoadingDialog({String message = AppStrings.pleaseWait}) {
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: AppSizes.spacing16),
            Text(message),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  // Network Image Error Builder
  static Widget buildNetworkImageError(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      color: AppColors.dividerColor,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: AppColors.textSecondary,
          size: AppSizes.iconLarge,
        ),
      ),
    );
  }

  // Network Image Loading Builder
  static Widget buildNetworkImageLoading(BuildContext context, String url, DownloadProgress progress) {
    return Container(
      color: AppColors.dividerColor,
      child: Center(
        child: CircularProgressIndicator(
          value: progress.progress,
          strokeWidth: 2,
        ),
      ),
    );
  }

  // Debounce Function
  static Timer? _debounceTimer;
  
  static void debounce(VoidCallback callback, Duration duration) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }
}

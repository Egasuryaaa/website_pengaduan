import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static String handleDioError(DioException error) {
    // Print detailed error for debugging
    if (kDebugMode) {
      print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
      print('Message: ${error.message}');
      print('Data: ${error.response?.data}');
      print('Headers: ${error.requestOptions.headers}');
      print('Query Params: ${error.requestOptions.queryParameters}');
      print('Request Data: ${error.requestOptions.data}');
    }
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi timeout. Silakan coba lagi.';
      case DioExceptionType.sendTimeout:
        return 'Gagal mengirim data. Silakan coba lagi.';
      case DioExceptionType.receiveTimeout:
        return 'Gagal menerima data. Silakan coba lagi.';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'Sesi telah berakhir. Silakan login kembali.';
        } else if (error.response?.statusCode == 403) {
          return 'Akses ditolak.';
        } else if (error.response?.statusCode == 404) {
          return 'Data tidak ditemukan.';
        } else if (error.response?.statusCode == 422) {
          // Validation error
          final responseData = error.response?.data;
          if (responseData != null && responseData['errors'] != null) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.cast<String>());
              }
            });
            return errorMessages.join('\n');
          }
          return 'Data tidak valid.';
        } else if (error.response?.statusCode == 500) {
          return 'Terjadi kesalahan server. Silakan coba lagi.';
        } else {
          return error.response?.data['message'] ?? 'Terjadi kesalahan.';
        }
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.unknown:
        return error.message ?? 'Terjadi kesalahan tidak diketahui.';
      default:
        return 'Terjadi kesalahan.';
    }
  }
}

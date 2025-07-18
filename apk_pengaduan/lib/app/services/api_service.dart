import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const String _tokenKey = 'auth_token';
  
  late Dio _dio;
  static ApiService? _instance;
  
  ApiService._internal() {
    _dio = Dio();
    _initializeInterceptors();
  }
  
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }
  
  void _initializeInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          
          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('Headers: ${options.headers}');
            print('Data: ${options.data}');
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
            print('Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
            print('Message: ${error.message}');
            print('Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }
  
  // Token management
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
  
  // Connectivity check
  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  // Generic GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      if (!await isConnected()) {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          message: 'Tidak ada koneksi internet',
        );
      }
      
      final response = await _dio.get(
        '$baseUrl$endpoint',
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      if (!await isConnected()) {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          message: 'Tidak ada koneksi internet',
        );
      }
      
      if (kDebugMode) {
        print('=== POST Request Details ===');
        print('URL: $baseUrl$endpoint');
        print('Data: $data');
      }
      
      final response = await _dio.post(
        '$baseUrl$endpoint',
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      if (!await isConnected()) {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          message: 'Tidak ada koneksi internet',
        );
      }
      
      final response = await _dio.put(
        '$baseUrl$endpoint',
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic DELETE request
  Future<Response> delete(String endpoint) async {
    try {
      if (!await isConnected()) {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          message: 'Tidak ada koneksi internet',
        );
      }
      
      final response = await _dio.delete('$baseUrl$endpoint');
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Upload file
  Future<Response> uploadFile(String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!await isConnected()) {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          message: 'Tidak ada koneksi internet',
        );
      }
      
      if (kDebugMode) {
        print('DEBUG: Uploading file');
        print('File path: $filePath');
        print('Field name: $fieldName');
        print('Data: $data');
      }
      
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });
      
      final response = await _dio.post(
        '$baseUrl$endpoint',
        data: formData,
      );
      
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Upload file bytes (for web)
  Future<Response> uploadFileBytes(String endpoint, {
    required Uint8List fileBytes,
    required String fileName,
    required String fieldName,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!await isConnected()) {
        throw DioException(
          requestOptions: RequestOptions(path: endpoint),
          message: 'Tidak ada koneksi internet',
        );
      }
      
      FormData formData = FormData.fromMap({
        fieldName: MultipartFile.fromBytes(fileBytes, filename: fileName),
        if (data != null) ...data,
      });
      
      final response = await _dio.post(
        '$baseUrl$endpoint',
        data: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Error handling
  String getErrorMessage(DioException error) {
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

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'package:http_parser/http_parser.dart';
import '../models/user.dart';
import '../models/pengaduan.dart';
import '../models/kategori.dart';

class ApiService {
  // Dynamic base URL that works for both web and mobile
  static String get baseUrl {
    if (kIsWeb) {
      // For web, we have two options:
      // 1. Use relative URL if the API is served from the same domain
      // 2. Use the full URL if running on a different server

      // Option 2: Use the full URL for development
      return 'http://127.0.0.1:8000/api'; // Change this to your actual API server URL

      // Option 1: Uncomment this when deploying to production if API is on same server
      // return '/api';
    } else {
      // Mobile environment can use localhost
      return 'http://10.0.2.2:8000/api'; // 10.0.2.2 points to host machine in Android emulator
    }
  }

  // Debug method to print FormData details
  static void debugFormData(FormData formData) {
    if (kDebugMode) {
      debugPrint('======= FORM DATA DEBUG =======');
      debugPrint('Fields:');
      for (final field in formData.fields) {
        debugPrint('- ${field.key}: ${field.value}');
      }
      debugPrint('Files:');
      for (final file in formData.files) {
        debugPrint(
          '- ${file.key}: ${file.value.filename} (${file.value.contentType?.mimeType})',
        );
      }
    }
  }

  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30), // Increased timeout
        receiveTimeout: const Duration(seconds: 30), // Increased timeout
        sendTimeout: const Duration(seconds: 30), // Added send timeout
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add token interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Ensure we accept JSON response
          options.headers['Accept'] = 'application/json';

          if (kDebugMode) {
            print('Request: ${options.method} ${options.uri}');
            if (token != null) {
              print('Using token: ${token.substring(0, 20)}...');
            }
            if (options.data != null) {
              print('Request Data: ${options.data}');
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              'Response: ${response.statusCode} ${response.requestOptions.uri}',
            );
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print(
              'Error: ${error.response?.statusCode} ${error.requestOptions.uri}',
            );
            print('Error Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  // Auth methods
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (kDebugMode && token != null) {
      debugPrint('Retrieved token: ${token.substring(0, 20)}...');
    } else if (kDebugMode) {
      print('No token found in storage');
    }
    return token;
  }

  Future<void> saveToken(String token) async {
    if (kDebugMode) {
      print('Saving token: ${token.substring(0, 20)}...');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);

    // Verify token was saved
    final savedToken = prefs.getString('auth_token');
    if (kDebugMode) {
      print('Token saved successfully: ${savedToken != null}');
    }
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Authentication API calls
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('Attempting login with email: $email');
        print('API URL: $baseUrl/login');
      }

      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (kDebugMode) {
        print('Login response status: ${response.statusCode}');
        print('Login response data: ${response.data}');
      }

      // Save token if present - handle the actual response structure
      if (response.data['data'] != null &&
          response.data['data']['token'] != null) {
        await saveToken(response.data['data']['token']);
        if (kDebugMode) {
          print(
            'Token saved from data.token: ${response.data['data']['token'].substring(0, 20)}...',
          );
        }
      } else if (response.data['access_token'] != null) {
        await saveToken(response.data['access_token']);
        if (kDebugMode) {
          print(
            'Token saved from access_token: ${response.data['access_token'].substring(0, 20)}...',
          );
        }
      } else if (response.data['token'] != null) {
        await saveToken(response.data['token']);
        if (kDebugMode) {
          print(
            'Token saved from token: ${response.data['token'].substring(0, 20)}...',
          );
        }
      } else {
        if (kDebugMode) {
          print('Warning: No token found in response');
          print('Available keys: ${response.data.keys.toList()}');
          if (response.data['data'] != null) {
            print('Data keys: ${response.data['data'].keys.toList()}');
          }
        }
      }

      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException caught:');
        print('Status code: ${e.response?.statusCode}');
        print('Error data: ${e.response?.data}');
        print('Error message: ${e.message}');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Email atau password salah');
      } else if (e.response?.statusCode == 422) {
        // Show validation errors from backend
        final errors =
            e.response?.data['errors'] ??
            e.response?.data['message'] ??
            'Data yang dimasukkan tidak valid';
        throw Exception('Validation error: $errors');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error: Silakan coba lagi nanti');
      } else {
        throw Exception(
          'Login gagal: Periksa koneksi internet Anda (${e.response?.statusCode ?? 'No connection'})',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('General exception caught: $e');
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? namaInstansi,
  }) async {
    try {
      final response = await dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'nama_instansi': namaInstansi,
        },
      );

      if (response.data['access_token'] != null) {
        await saveToken(response.data['access_token']);
      } else if (response.data['token'] != null) {
        await saveToken(response.data['token']);
      }

      return response.data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await dio.post('/logout');
      await removeToken();
    } catch (e) {
      await removeToken(); // Remove token even if logout fails
      throw Exception('Logout failed: $e');
    }
  }

  Future<User> getMe() async {
    try {
      // Use the correct endpoint /me that returns the structure you provided
      final response = await dio.get('/me');

      if (kDebugMode) {
        print('getMe response: ${response.data}');
      }

      // Handle the response structure: {"success": true, "data": {...}}
      if (response.data is Map<String, dynamic>) {
        if (response.data['success'] == true && response.data['data'] != null) {
          return User.fromJson(response.data['data']);
        } else if (response.data['data'] != null) {
          return User.fromJson(response.data['data']);
        } else if (response.data['success'] == true) {
          // In case data is directly in response without 'data' wrapper
          return User.fromJson(response.data);
        } else {
          throw Exception('Invalid response format: missing data field');
        }
      } else {
        throw Exception('Invalid response format from server');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print(
          'getMe DioException: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }

      if (e.response?.statusCode == 401) {
        // Token expired or invalid
        await removeToken();
        throw Exception('Session expired. Please login again.');
      } else if (e.response?.statusCode == 404) {
        // Endpoint not found
        throw Exception(
          'User endpoint not available. Please check your backend configuration.',
        );
      } else {
        throw Exception(
          'Failed to get user data: ${e.response?.statusCode ?? 'Network error'}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('getMe general exception: $e');
      }
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? namaInstansi,
  }) async {
    try {
      if (kDebugMode) {
        print(
          'Updating profile with data: {name: $name, email: $email, phone: $phone, nama_instansi: $namaInstansi}',
        );
      }

      final response = await dio.put(
        '/profile',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'nama_instansi': namaInstansi,
        },
      );

      if (kDebugMode) {
        print('Update profile response: ${response.data}');
      }

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await dio.put(
        '/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Kategori API calls
  Future<List<Kategori>> getKategori() async {
    try {
      final response = await dio.get('/kategori');
      // Handle response structure - might be wrapped in "data" field
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => Kategori.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // Pengaduan API calls
  Future<List<Pengaduan>> getPengaduan() async {
    try {
      // Use /my-pengaduan to get only current user's pengaduan
      final response = await dio.get('/my-pengaduan');
      // Handle response structure with "data" field
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => Pengaduan.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get pengaduan: $e');
    }
  }

  Future<Pengaduan> getPengaduanById(int id) async {
    try {
      // Use /my-pengaduan/{id} to ensure user can only access their own pengaduan
      final response = await dio.get('/my-pengaduan/$id');
      // Handle single item response
      final data = response.data['data'] ?? response.data;
      return Pengaduan.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get pengaduan detail: $e');
    }
  }

  Future<Map<String, dynamic>> createPengaduan({
    required String judul,
    required String deskripsi,
    required int kategoriId,
    String? lokasi,
    String? namaInstansi,
    String? foto, // File path for mobile
    Uint8List? imageBytes, // For web
    dynamic imageFile, // XFile for web
  }) async {
    try {
      if (kDebugMode) {
        print('======= CREATE PENGADUAN API CALL =======');
        print('Base URL: $baseUrl');
        print('Endpoint: /pengaduan');
        print('Judul: $judul');
        print('Deskripsi: $deskripsi');
        print('Kategori ID: $kategoriId');
        print('Lokasi: $lokasi');
        print('Foto path (mobile): $foto');
        print('Has Image Bytes (web): ${imageBytes != null}');
        print('Has Image File (web): ${imageFile != null}');

        // Check token
        final token = await getToken();
        print('Has Auth Token: ${token != null}');
        if (token != null) {
          print('Token Length: ${token.length}');
          print(
            'Token Preview: ${token.substring(0, min(20, token.length))}...',
          );
        }
      }

      // Get current user data untuk mendapatkan nama_instansi jika belum ada
      User? currentUser;
      try {
        currentUser = await getMe();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to get current user: $e');
        }
      }

      FormData formData = FormData.fromMap({
        'judul': judul,
        'deskripsi': deskripsi,
        'kategori_id': kategoriId,
        'lokasi': lokasi,
        'nama_instansi': namaInstansi ?? currentUser?.namaInstansi ?? '',
      });

      // Handle file upload based on platform
      if (kIsWeb) {
        // Web platform - use bytes
        if (imageBytes != null && imageFile != null) {
          // Buat nama file yang unik dengan timestamp
          DateTime now = DateTime.now();
          String timestamp = '${now.millisecondsSinceEpoch}';
          String originalName = 'upload.jpg';

          // Try to get filename if possible
          if (imageFile is XFile) {
            originalName = imageFile.name;
          }

          // Pastikan nama file memiliki ekstensi yang benar
          String extension =
              originalName.contains('.') ? originalName.split('.').last : 'jpg';

          // Format nama file: timestamp_originalname.extension
          String fileName = 'pengaduan_$timestamp.$extension';

          formData.files.add(
            MapEntry(
              'foto',
              MultipartFile.fromBytes(
                imageBytes,
                filename: fileName,
                contentType: MediaType(
                  'image',
                  extension == 'png' ? 'png' : 'jpeg',
                ),
              ),
            ),
          );

          if (kDebugMode) {
            print('Web upload: Adding file as bytes, filename: $fileName');
            print('Web upload: Image bytes length: ${imageBytes.length}');
            print(
              'Web upload: Content type: ${extension == 'png' ? 'image/png' : 'image/jpeg'}',
            );
          }
        }
      } else {
        // Mobile platform - use file path
        if (foto != null && foto.isNotEmpty) {
          // Get file name from path
          String fileName = foto.split('/').last;
          // Generate unique timestamp
          String timestamp = '${DateTime.now().millisecondsSinceEpoch}';
          // Get extension
          String extension =
              fileName.contains('.') ? fileName.split('.').last : 'jpg';

          // Format nama file: timestamp_originalname.extension
          String newFileName = 'pengaduan_$timestamp.$extension';

          formData.files.add(
            MapEntry(
              'foto',
              await MultipartFile.fromFile(
                foto,
                filename: newFileName,
                contentType: MediaType(
                  'image',
                  extension == 'png' ? 'png' : 'jpeg',
                ),
              ),
            ),
          );

          if (kDebugMode) {
            print('Mobile upload: Adding file from path: $foto');
            print('Mobile upload: New filename: $newFileName');
            print(
              'Mobile upload: Content type: ${extension == 'png' ? 'image/png' : 'image/jpeg'}',
            );
          }
        }
      }

      if (kDebugMode) {
        print('FormData fields: ${formData.fields}');
        print('FormData files: ${formData.files.length}');
        print('Sending POST request to: $baseUrl/pengaduan');
      }

      final response = await dio.post(
        '/pengaduan',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response data: ${response.data}');

        // Detail debug untuk file foto
        if (response.data is Map && response.data['data'] is Map) {
          final pengaduanData = response.data['data'];
          print('Foto URL in response: ${pengaduanData['foto']}');
          print('Full pengaduan data: $pengaduanData');
        }
      }

      if (response.statusCode! >= 400) {
        throw Exception(
          'Server error: ${response.statusCode} - ${response.data}',
        );
      }

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating pengaduan: $e');
        if (e is DioException) {
          print('DioError type: ${e.type}');
          print('DioError message: ${e.message}');
          print('DioError response status: ${e.response?.statusCode}');
          print('DioError response data: ${e.response?.data}');
        }
      }
      throw Exception('Failed to create pengaduan: $e');
    }
  }

  Future<Map<String, dynamic>> updatePengaduan({
    required int id,
    required String judul,
    required String deskripsi,
    required int kategoriId,
    String? lokasi,
    String? foto,
  }) async {
    try {
      final response = await dio.put(
        '/pengaduan/$id',
        data: {
          'judul': judul,
          'deskripsi': deskripsi,
          'kategori_id': kategoriId,
          'lokasi': lokasi,
          'foto': foto,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to update pengaduan: $e');
    }
  }

  Future<Map<String, dynamic>> getPengaduanStatistics() async {
    try {
      final response = await dio.get('/pengaduan-statistics');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}

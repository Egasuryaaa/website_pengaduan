import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/pengaduan.dart';
import '../models/kategori.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // For development
  // Change to your actual backend URL when deploying
  // static const String baseUrl = 'https://your-domain.com/api';
  late Dio dio;

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add token interceptor
    dio.interceptors.add(InterceptorsWrapper(
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
          print('Response: ${response.statusCode} ${response.requestOptions.uri}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
          print('Error Data: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));
  }

  // Auth methods
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (kDebugMode && token != null) {
      print('Retrieved token: ${token.substring(0, 20)}...');
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
      
      final response = await dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      
      if (kDebugMode) {
        print('Login response status: ${response.statusCode}');
        print('Login response data: ${response.data}');
      }
      
      // Save token if present - handle the actual response structure
      if (response.data['data'] != null && response.data['data']['token'] != null) {
        await saveToken(response.data['data']['token']);
        if (kDebugMode) {
          print('Token saved from data.token: ${response.data['data']['token'].substring(0, 20)}...');
        }
      } else if (response.data['access_token'] != null) {
        await saveToken(response.data['access_token']);
        if (kDebugMode) {
          print('Token saved from access_token: ${response.data['access_token'].substring(0, 20)}...');
        }
      } else if (response.data['token'] != null) {
        await saveToken(response.data['token']);
        if (kDebugMode) {
          print('Token saved from token: ${response.data['token'].substring(0, 20)}...');
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
        final errors = e.response?.data['errors'] ?? e.response?.data['message'] ?? 'Data yang dimasukkan tidak valid';
        throw Exception('Validation error: $errors');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error: Silakan coba lagi nanti');
      } else {
        throw Exception('Login gagal: Periksa koneksi internet Anda (${e.response?.statusCode ?? 'No connection'})');
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
      final response = await dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
        'nama_instansi': namaInstansi,
      });
      
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
        print('getMe DioException: ${e.response?.statusCode} - ${e.response?.data}');
      }
      
      if (e.response?.statusCode == 401) {
        // Token expired or invalid
        await removeToken();
        throw Exception('Session expired. Please login again.');
      } else if (e.response?.statusCode == 404) {
        // Endpoint not found
        throw Exception('User endpoint not available. Please check your backend configuration.');
      } else {
        throw Exception('Failed to get user data: ${e.response?.statusCode ?? 'Network error'}');
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
        print('Updating profile with data: {name: $name, email: $email, phone: $phone, nama_instansi: $namaInstansi}');
      }
      
      final response = await dio.put('/profile', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'nama_instansi': namaInstansi,
      });
      
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
      final response = await dio.put('/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      });
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
      final response = await dio.get('/pengaduan');
      // Handle response structure with "data" field
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => Pengaduan.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get pengaduan: $e');
    }
  }

  Future<Pengaduan> getPengaduanById(int id) async {
    try {
      final response = await dio.get('/pengaduan/$id');
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
    String? foto, // This should be file path or base64
  }) async {
    try {
      final response = await dio.post('/pengaduan', data: {
        'judul': judul,
        'deskripsi': deskripsi,
        'kategori_id': kategoriId,
        'lokasi': lokasi,
        'foto': foto,
      });
      return response.data;
    } catch (e) {
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
      final response = await dio.put('/pengaduan/$id', data: {
        'judul': judul,
        'deskripsi': deskripsi,
        'kategori_id': kategoriId,
        'lokasi': lokasi,
        'foto': foto,
      });
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

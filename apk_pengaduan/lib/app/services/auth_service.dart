import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService.instance;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String namaInstansi,
  }) async {
    try {
      final response = await _apiService.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'nama_instansi': namaInstansi,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['token'] != null) {
          await _apiService.setToken(data['token']);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
          'user': UserModel.fromJson(data['user']),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Registrasi gagal',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _apiService.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga: $e',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          await _apiService.setToken(data['token']);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil',
          'user': UserModel.fromJson(data['user']),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Login gagal',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _apiService.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga: $e',
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiService.post('/auth/logout');

      await _apiService.removeToken();
      
      return {
        'success': true,
        'message': response.data['message'] ?? 'Logout berhasil',
      };
    } on DioException catch (e) {
      // Even if logout fails on server, remove local token
      await _apiService.removeToken();
      return {
        'success': false,
        'message': _apiService.getErrorMessage(e),
      };
    } catch (e) {
      await _apiService.removeToken();
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga: $e',
      };
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _apiService.post('/auth/refresh');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          await _apiService.setToken(data['token']);
        }
        return {
          'success': true,
          'message': 'Token refreshed successfully',
          'user': UserModel.fromJson(data['user']),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to refresh token',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _apiService.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/user');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'user': UserModel.fromJson(data['user']),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mendapatkan data user',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _apiService.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    required String namaInstansi,
  }) async {
    try {
      final response = await _apiService.put('/auth/profile', data: {
        'name': name,
        'phone': phone,
        'nama_instansi': namaInstansi,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'message': data['message'] ?? 'Profile berhasil diperbarui',
          'user': UserModel.fromJson(data['user']),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal memperbarui profile',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _apiService.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga: $e',
      };
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.put('/auth/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'message': data['message'] ?? 'Password berhasil diubah',
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mengubah password',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _apiService.getErrorMessage(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan tidak terduga: $e',
      };
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}

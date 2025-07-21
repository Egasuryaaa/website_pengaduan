import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true; // Start with true to prevent premature redirects
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await _apiService.getToken();
      if (token != null) {
        try {
          _user = await _apiService.getMe();
          _isAuthenticated = true;
          if (kDebugMode) {
            print('Auth check successful: User ${_user?.name} is authenticated');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to get user info during auth check: $e');
          }
          
          // If the error is due to token expiry (401), remove token and set unauthenticated
          if (e.toString().contains('Session expired') || e.toString().contains('401')) {
            _isAuthenticated = false;
            _user = null;
          } else {
            // For other errors, still consider authenticated if we have a token
            // The user data will be fetched during actual usage
            _isAuthenticated = true;
            _user = null;
          }
        }
      } else {
        _isAuthenticated = false;
        _user = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking auth status: $e');
      }
      _isAuthenticated = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    if (kDebugMode) {
      print('AuthProvider: Starting login process');
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('AuthProvider: Calling API login');
      }
      
      final response = await _apiService.login(email, password);
      
      if (kDebugMode) {
        print('AuthProvider: Login API call successful');
        print('AuthProvider: Response keys: ${response.keys.toList()}');
      }
      
      // Check if response contains user data based on the actual structure
      if (response['data'] != null && response['data']['user'] != null) {
        _user = User.fromJson(response['data']['user']);
        if (kDebugMode) {
          print('AuthProvider: User data found in response.data.user');
        }
      } else if (response['user'] != null) {
        _user = User.fromJson(response['user']);
        if (kDebugMode) {
          print('AuthProvider: User data found in response.user');
        }
      } else if (response['success'] == true && response['data'] != null) {
        // Handle the case where login response has the same structure as /me
        _user = User.fromJson(response['data']);
        if (kDebugMode) {
          print('AuthProvider: User data found in response.data with success flag');
        }
      } else {
        // If no user in response, fetch user data from /me endpoint
        if (kDebugMode) {
          print('AuthProvider: No user in response, fetching from /me endpoint');
        }
        try {
          _user = await _apiService.getMe();
          if (kDebugMode) {
            print('AuthProvider: Successfully fetched user data from /me');
          }
        } catch (e) {
          if (kDebugMode) {
            print('AuthProvider: Failed to fetch user data: $e');
          }
          // If we can't get user data but login was successful, create basic user
          _user = User(
            id: 1,
            name: email.split('@')[0],
            email: email,
            phone: null,
            namaInstansi: null,
            emailVerifiedAt: null,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }
      
      _isAuthenticated = true;
      _isLoading = false;
      
      if (kDebugMode) {
        print('AuthProvider: Login successful, user: ${_user?.name}');
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AuthProvider: Login error: $e');
      }
      _isLoading = false;
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? namaInstansi,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        namaInstansi: namaInstansi,
      );
      _user = User.fromJson(response['user']);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? namaInstansi,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('AuthProvider: Updating profile for user: ${_user?.name}');
      }
      
      final response = await _apiService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        namaInstansi: namaInstansi,
      );
      
      if (kDebugMode) {
        print('AuthProvider: Update profile response received');
        print('AuthProvider: Response keys: ${response.keys.toList()}');
      }
      
      // Handle different response structures
      if (response['data'] != null && response['data']['user'] != null) {
        _user = User.fromJson(response['data']['user']);
        if (kDebugMode) {
          print('AuthProvider: User updated from response.data.user');
        }
      } else if (response['data'] != null) {
        _user = User.fromJson(response['data']);
        if (kDebugMode) {
          print('AuthProvider: User updated from response.data');
        }
      } else if (response['user'] != null) {
        _user = User.fromJson(response['user']);
        if (kDebugMode) {
          print('AuthProvider: User updated from response.user');
        }
      } else {
        // If no user data in response, fetch updated user data
        if (kDebugMode) {
          print('AuthProvider: No user in response, fetching updated user data');
        }
        try {
          _user = await _apiService.getMe();
          if (kDebugMode) {
            print('AuthProvider: Successfully fetched updated user data');
          }
        } catch (e) {
          if (kDebugMode) {
            print('AuthProvider: Failed to fetch updated user data: $e');
          }
          // Even if we can't fetch user data, the update was successful
          // Just update the current user object with the new data
          if (_user != null) {
            _user = User(
              id: _user!.id,
              name: name,
              email: email,
              phone: phone,
              namaInstansi: namaInstansi,
              emailVerifiedAt: _user!.emailVerifiedAt,
              isActive: _user!.isActive,
              createdAt: _user!.createdAt,
              updatedAt: DateTime.now(),
            );
            if (kDebugMode) {
              print('AuthProvider: Updated user object manually');
            }
          }
        }
      }
      
      _isLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        print('AuthProvider: Profile update successful, user: ${_user?.name}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AuthProvider: Profile update error: $e');
      }
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Method to manually refresh user data
  Future<void> refreshUserData() async {
    if (!_isAuthenticated) return;
    
    try {
      _user = await _apiService.getMe();
      notifyListeners();
      if (kDebugMode) {
        print('AuthProvider: User data refreshed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthProvider: Failed to refresh user data: $e');
      }
      // Don't throw error, just log it
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}

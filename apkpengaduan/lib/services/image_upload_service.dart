import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

/// A specialized service to handle image uploads for the Pengaduan app
class ImageUploadService {
  static String get baseUrl {
    if (kIsWeb) {
      // For web, check if we're running on localhost:60371 (Flutter web dev server)
      // and route to the Laravel backend accordingly
      return 'http://localhost:8000/api';
    } else {
      // Mobile environment - use 10.0.2.2 for Android emulator
      return 'http://10.0.2.2:8000/api';
    }
  }

  /// Debug method to debugPrint FormData details for troubleshooting
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

  /// Uploads a pengaduan with an image attachment
  /// Optimized for reliable file uploads across platforms
  static Future<Map<String, dynamic>> uploadPengaduanWithImage({
    required String judul,
    required String deskripsi,
    required int kategoriId,
    required String namaInstansi,
    String? lokasi,
    required XFile imageFile,
  }) async {
    if (kDebugMode) {
      debugPrint('======= UPLOAD PENGADUAN WITH IMAGE =======');
      debugPrint('Image filename: ${imageFile.name}');
      debugPrint('Judul: $judul');
      debugPrint('Deskripsi: $deskripsi');
      debugPrint('Kategori ID: $kategoriId');
      debugPrint('Nama Instansi: $namaInstansi');
      debugPrint('Lokasi: $lokasi');
    }

    // Validate file exists and is readable before proceeding
    try {
      final fileSize = await imageFile.length();
      if (fileSize <= 0) {
        throw Exception('File is empty or cannot be read');
      }
      if (kDebugMode) {
        debugPrint('File size verified: $fileSize bytes');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ERROR: Failed to validate file: $e');
      }
      throw Exception('Failed to validate image file: $e');
    }

    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      // Create FormData with all text fields - ensure proper field names
      final formData = FormData();
      formData.fields.add(MapEntry('judul', judul.trim()));
      formData.fields.add(MapEntry('deskripsi', deskripsi.trim()));
      formData.fields.add(MapEntry('kategori_id', kategoriId.toString()));
      
      // Handle nama_instansi properly - this should be sent to user profile, not pengaduan
      // But if the API expects it in pengaduan creation, we'll send it
      if (namaInstansi.isNotEmpty && namaInstansi != 'Default') {
        formData.fields.add(MapEntry('nama_instansi', namaInstansi.trim()));
      }

      // Add lokasi if provided and not empty
      if (lokasi != null && lokasi.trim().isNotEmpty) {
        formData.fields.add(MapEntry('lokasi', lokasi.trim()));
      }

      // Generate a unique filename to avoid conflicts
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String originalName = imageFile.name;
      final String extension = originalName.split('.').last.toLowerCase();
      final String uniqueFilename = 'pengaduan_$timestamp.$extension';

      // Determine correct MIME type based on file extension
      String mimeType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg';
      }

      // Handle file upload differently based on platform
      if (kIsWeb) {
        // Web platform - use bytes
        final bytes = await imageFile.readAsBytes();

        if (kDebugMode) {
          debugPrint('Web platform detected');
          debugPrint('Image bytes length: ${bytes.length}');
        }

        // Use 'foto' as the field name to match Laravel expectation
        formData.files.add(
          MapEntry(
            'foto', // This matches the API response field name
            MultipartFile.fromBytes(
              bytes,
              filename: uniqueFilename,
              contentType: MediaType.parse(mimeType),
            ),
          ),
        );
      } else {
        // Mobile platform - use file path
        if (kDebugMode) {
          debugPrint('Mobile platform detected');
          debugPrint('Image path: ${imageFile.path}');
        }

        // Use 'foto' as the field name to match Laravel expectation
        formData.files.add(
          MapEntry(
            'foto', // This matches the API response field name
            await MultipartFile.fromFile(
              imageFile.path,
              filename: uniqueFilename,
              contentType: MediaType.parse(mimeType),
            ),
          ),
        );
      }

      // Debug log the form data contents before sending
      debugFormData(formData);

      // Create a dedicated Dio instance with extended timeouts
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          validateStatus: (status) => status! < 500,
          responseType: ResponseType.json,
        ),
      );

      // Add logging interceptor for debugging
      if (kDebugMode) {
        dio.interceptors.add(
          LogInterceptor(
            requestBody: false, // Don't log file data
            responseBody: true,
            logPrint: (obj) => debugPrint(obj.toString()),
          ),
        );
      }

      // Make the API request
      if (kDebugMode) {
        debugPrint('===== SENDING REQUEST TO SERVER =====');
        debugPrint('URL: $baseUrl/pengaduan');
        debugPrint('Authorization token present: ${token.isNotEmpty}');
        debugPrint('FormData fields count: ${formData.fields.length}');
        debugPrint('FormData files count: ${formData.files.length}');
      }

      final response = await dio.post(
        '/pengaduan',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (kDebugMode) {
        debugPrint('===== RESPONSE FROM SERVER =====');
        debugPrint('Status code: ${response.statusCode}');
        debugPrint('Response data type: ${response.data.runtimeType}');
        debugPrint('Response data: ${response.data}');
      }

      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response types
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          
          // Handle different response structures
          if (responseData.containsKey('data')) {
            return responseData;
          } else if (responseData.containsKey('id')) {
            // Direct pengaduan object response
            return {'data': responseData};
          } else {
            // Unexpected response structure
            return responseData;
          }
        } else if (response.data is String) {
          // Handle string response (might be HTML error page or plain text)
          final stringResponse = response.data as String;
          if (kDebugMode) {
            debugPrint('Received string response: $stringResponse');
          }
          
          // Try to parse as JSON if it looks like JSON
          if (stringResponse.trim().startsWith('{') || stringResponse.trim().startsWith('[')) {
            try {
              final jsonData = jsonDecode(stringResponse) as Map<String, dynamic>;
              return jsonData.containsKey('data') ? jsonData : {'data': jsonData};
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Failed to parse string response as JSON: $e');
              }
            }
          }
          
          // If it's not JSON, treat as error
          throw Exception('Unexpected string response from server: ${stringResponse.length > 100 ? stringResponse.substring(0, 100) + '...' : stringResponse}');
        } else {
          // Handle other response types
          if (kDebugMode) {
            debugPrint('Unexpected response type: ${response.data.runtimeType}');
          }
          throw Exception('Unexpected response type from server: ${response.data.runtimeType}');
        }
      } else {
        // Handle error responses
        String errorMessage = 'Upload failed';
        
        if (response.data is Map<String, dynamic>) {
          final errorData = response.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorMessage;
        } else if (response.data is String) {
          errorMessage = response.data as String;
        }
        
        throw Exception('Server error (${response.statusCode}): $errorMessage');
      }

    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('===== DIO ERROR =====');
        debugPrint('Error type: ${e.type}');
        debugPrint('Error message: ${e.message}');
        debugPrint('Response status: ${e.response?.statusCode}');
        debugPrint('Response data: ${e.response?.data}');
        
        // Log validation errors if present
        if (e.response?.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData.containsKey('errors')) {
            debugPrint('Validation errors: ${errorData['errors']}');
          }
        }
      }

      // Extract meaningful error message
      String errorMessage = 'Upload failed';
      
      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorMessage;
          
          // Include validation errors if present
          if (errorData.containsKey('errors')) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            final errorList = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorList.addAll(value.map((e) => e.toString()));
              } else {
                errorList.add(value.toString());
              }
            });
            if (errorList.isNotEmpty) {
              errorMessage += ': ${errorList.join(', ')}';
            }
          }
        } else if (e.response!.data is String) {
          // Handle string error responses
          final stringError = e.response!.data as String;
          if (stringError.trim().startsWith('{')) {
            try {
              final jsonError = jsonDecode(stringError) as Map<String, dynamic>;
              errorMessage = jsonError['message'] ?? stringError;
            } catch (_) {
              errorMessage = stringError.length > 200 ? '${stringError.substring(0, 200)}...' : stringError;
            }
          } else {
            errorMessage = stringError.length > 200 ? '${stringError.substring(0, 200)}...' : stringError;
          }
        }
      }

      throw Exception('$errorMessage (Status: ${e.response?.statusCode ?? 'Unknown'})');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('===== GENERAL ERROR =====');
        debugPrint('Error: $e');
        debugPrint('Stack trace: ${StackTrace.current}');
      }
      throw Exception('Upload failed: $e');
    }
  }
}
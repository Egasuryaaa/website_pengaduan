import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

/// A specialized service to handle image uploads for the Pengaduan app
class ImageUploadService {
  static String get baseUrl {
    if (kIsWeb) {
      // When running in a browser, use the same domain as the page
      // This avoids CORS issues with file uploads
      return '/api'; // Use relative URL for web to avoid CORS issues with file uploads
    } else {
      // Mobile environment can use localhost
      return 'http://10.0.2.2:8000/api'; // 10.0.2.2 points to host machine in Android emulator
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

      // Create FormData with all text fields
      final formData = FormData();
      formData.fields.add(MapEntry('judul', judul));
      formData.fields.add(MapEntry('deskripsi', deskripsi));
      formData.fields.add(MapEntry('kategori_id', kategoriId.toString()));
      formData.fields.add(MapEntry('nama_instansi', namaInstansi));

      if (lokasi != null && lokasi.isNotEmpty) {
        formData.fields.add(MapEntry('lokasi', lokasi));
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

        // Use 'foto' as the field name to match what Laravel expects
        // This matches the field name in your API response example
        formData.files.add(
          MapEntry(
            'foto', // Must match the field name in the Laravel controller
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

        // Use 'foto' as the field name to match what Laravel expects
        // This matches the field name in your API response example
        formData.files.add(
          MapEntry(
            'foto', // Must match the field name in the Laravel controller
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
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          // These settings help with CORS on web
          validateStatus: (status) => status! < 500,
          responseType: ResponseType.json,
        ),
      );

      // Add logging interceptor
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) {
            if (kDebugMode) {
              debugPrint(obj.toString());
            }
          },
        ),
      );

      // Make the API request
      if (kDebugMode) {
        debugPrint('===== SENDING REQUEST TO SERVER =====');
        debugPrint('URL: $baseUrl/pengaduan');
        debugPrint('Authorization token length: ${token.length}');
        debugPrint('Content-Type: ${Headers.multipartFormDataContentType}');
        debugPrint('Filename: $uniqueFilename');
      }

      // Add additional debug information before sending
      if (kDebugMode) {
        debugPrint('===== CHECKING REQUEST FORMAT =====');
        debugPrint('Total fields in FormData: ${formData.fields.length}');
        debugPrint('Total files in FormData: ${formData.files.length}');
        debugPrint('Image file field name: foto');
        if (formData.files.isEmpty) {
          debugPrint(
            'WARNING: No files in FormData! Check if file was properly added.',
          );
        }
      }

      // Different approach for web and mobile
      Response<dynamic> response;

      if (kIsWeb) {
        // For web, use a more browser-friendly approach with explicit content type
        try {
          response = await dio.post(
            '$baseUrl/pengaduan',
            data: formData,
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
                // Don't set X-File-Upload header for web as it may cause preflight issues
              },
              // For web uploads, let Dio handle the content type automatically
              followRedirects: false,
              validateStatus: (status) {
                return status != null &&
                    status < 500; // Allow all responses for debugging
              },
            ),
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Web upload error: $e');
            debugPrint('Trying alternative approach with direct fetch API...');
          }

          // If Dio approach failed, our upload might be failing due to CORS
          // Try an alternative approach using direct fetch API
          throw Exception(
            'Web upload failed. Please try uploading from a mobile device or '
            'ensure your backend has proper CORS configuration for file uploads.',
          );
        }
      } else {
        // For mobile, use the standard approach
        response = await dio.post(
          '$baseUrl/pengaduan',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              // Make sure Laravel knows this is a file upload
              'X-File-Upload': 'true',
            },
            // Don't manually set Content-Type for FormData, Dio will set it with boundary
            contentType: Headers.multipartFormDataContentType,
            followRedirects: false,
            validateStatus: (status) {
              return status != null &&
                  status < 500; // Allow all responses for debugging
            },
          ),
        );
      }

      if (kDebugMode) {
        debugPrint('===== RESPONSE FROM SERVER =====');
        debugPrint('Status code: ${response.statusCode}');
        debugPrint('Headers: ${response.headers}');
        debugPrint('Response data: ${response.data}');

        // Detailed inspection of response structure
        if (response.data is Map<String, dynamic>) {
          debugPrint('Response structure:');
          response.data.forEach((key, value) {
            debugPrint('- $key: ${value?.runtimeType}');
          });

          // Check for data field in response
          if (response.data['data'] != null && response.data['data'] is Map) {
            final pengaduanData = response.data['data'];
            debugPrint('Pengaduan data:');
            for (final entry in pengaduanData.entries) {
              debugPrint('  - ${entry.key}: ${entry.value ?? "null"}');
            }

            // Specifically check for foto field
            if (pengaduanData.containsKey('foto')) {
              debugPrint(
                'FOTO field is present in response: ${pengaduanData['foto']}',
              );
            } else {
              debugPrint('FOTO field is MISSING in response!');
            }

            // Check if bukti_foto is used instead
            if (pengaduanData.containsKey('bukti_foto')) {
              debugPrint(
                'BUKTI_FOTO field is present in response: ${pengaduanData['bukti_foto']}',
              );
            }
          } else {
            debugPrint('No "data" field in response or it is not a Map');
            // Try to find foto field in the main response
            if (response.data.containsKey('foto')) {
              debugPrint(
                'FOTO field is present at root level: ${response.data['foto']}',
              );
            }
            if (response.data.containsKey('bukti_foto')) {
              debugPrint(
                'BUKTI_FOTO field is present at root level: ${response.data['bukti_foto']}',
              );
            }
          }
        } else {
          debugPrint('Response is not a Map<String, dynamic>');
        }
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('===== DIO ERROR =====');
        debugPrint('Error type: ${e.type}');
        debugPrint('Error message: ${e.message}');
        debugPrint('Request path: ${e.requestOptions.path}');
        debugPrint('Request headers: ${e.requestOptions.headers}');
        debugPrint('Response status: ${e.response?.statusCode}');
        debugPrint('Response data: ${e.response?.data}');

        // For multipart form data issues, check the request
        if (e.requestOptions.data is FormData) {
          debugPrint('FormData was being sent. Check field names:');
          final FormData formData = e.requestOptions.data as FormData;
          for (final field in formData.fields) {
            debugPrint('Field: ${field.key}=${field.value}');
          }

          for (final file in formData.files) {
            debugPrint(
              'File: ${file.key}, filename=${file.value.filename}, contentType=${file.value.contentType}',
            );
          }
        }
      }
      // Return a more detailed error message
      throw Exception(
        'Upload failed: ${e.response?.data ?? e.message}. Status: ${e.response?.statusCode}',
      );
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

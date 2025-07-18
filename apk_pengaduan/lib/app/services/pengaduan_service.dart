import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../models/pengaduan_model.dart';
import 'api_service.dart';
import 'error_handler.dart';

class PengaduanService {
  final ApiService _apiService = ApiService.instance;

  Future<Map<String, dynamic>> createPengaduan({
    required String namaInstansi,
    required String deskripsi,
    required int kategoriId,
    String? fotoBukti, // path to image file
    Uint8List? imageBytes, // bytes for web
    String? imageName, // name for web
  }) async {
    try {
      // Debug output
      if (kDebugMode) {
        print('=== Creating Pengaduan ===');
        print('namaInstansi: $namaInstansi');
        print('deskripsi: $deskripsi');
        print('kategoriId: $kategoriId');
        print('fotoBukti path: $fotoBukti');
        print('imageBytes: ${imageBytes != null ? '${imageBytes.length} bytes' : 'null'}');
        print('imageName: $imageName');
      }
      
      Map<String, dynamic> data = {
        'nama_instansi': namaInstansi,
        'deskripsi': deskripsi,
        'kategori_id': kategoriId,
      };

      Response response;
      
      if (fotoBukti != null) {
        // Upload with file path (mobile)
        if (kDebugMode) {
          print('Uploading file from path: $fotoBukti');
        }
        
        response = await _apiService.uploadFile(
          '/pengaduan',
          filePath: fotoBukti,
          fieldName: 'foto_bukti',
          data: data,
        );
      } else if (imageBytes != null && imageName != null) {
        // Upload with bytes (web)
        if (kDebugMode) {
          print('Uploading file bytes with name: $imageName');
        }
        
        response = await _apiService.uploadFileBytes(
          '/pengaduan',
          fileBytes: imageBytes,
          fileName: imageName,
          fieldName: 'foto_bukti',
          data: data,
        );
      } else {
        // Upload without file
        if (kDebugMode) {
          print('Posting data without file to: /pengaduan');
          print('Data: $data');
        }
        
        response = await _apiService.post('/pengaduan', data: data);
      }

      if (response.statusCode == 201) {
        final responseData = response.data;
        return {
          'success': true,
          'message': responseData['message'] ?? 'Pengaduan berhasil dibuat',
          'pengaduan': PengaduanModel.fromJson(responseData['pengaduan']),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal membuat pengaduan',
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

  Future<Map<String, dynamic>> getPengaduanList({
    int page = 1,
    int limit = 10,
    String? status,
    String? kategoriId,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      
      if (status != null) queryParams['status'] = status;
      if (kategoriId != null) queryParams['kategori_id'] = kategoriId;

      final response = await _apiService.get('/pengaduan', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'pengaduan': (data['pengaduan'] as List)
              .map((item) => PengaduanModel.fromJson(item))
              .toList(),
          'pagination': data['pagination'],
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mendapatkan data pengaduan',
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

  Future<Map<String, dynamic>> getPengaduanDetail(String id) async {
    try {
      final response = await _apiService.get('/pengaduan/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'pengaduan': PengaduanModel.fromJson(data['pengaduan']),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mendapatkan detail pengaduan',
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

  Future<Map<String, dynamic>> updatePengaduan({
    required String id,
    required String namaInstansi,
    required String deskripsi,
    required int kategoriId,
    String? fotoBukti, // path to image file
  }) async {
    try {
      Map<String, dynamic> data = {
        'nama_instansi': namaInstansi,
        'deskripsi': deskripsi,
        'kategori_id': kategoriId,
      };

      Response response;
      
      if (fotoBukti != null) {
        // Upload with file
        response = await _apiService.uploadFile(
          '/pengaduan/$id',
          filePath: fotoBukti,
          fieldName: 'foto_bukti',
          data: data,
        );
      } else {
        // Upload without file
        response = await _apiService.put('/pengaduan/$id', data: data);
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        return {
          'success': true,
          'message': responseData['message'] ?? 'Pengaduan berhasil diperbarui',
          'pengaduan': PengaduanModel.fromJson(responseData['pengaduan']),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal memperbarui pengaduan',
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

  Future<Map<String, dynamic>> deletePengaduan(String id) async {
    try {
      final response = await _apiService.delete('/pengaduan/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'message': data['message'] ?? 'Pengaduan berhasil dihapus',
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal menghapus pengaduan',
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

  Future<Map<String, dynamic>> getKategoriList() async {
    try {
      final response = await _apiService.get('/kategori');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'kategori': (data['kategori'] as List)
              .map((item) => KategoriModel.fromJson(item))
              .toList(),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mendapatkan data kategori',
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

  Future<Map<String, dynamic>> getStatusHistory(String pengaduanId) async {
    try {
      final response = await _apiService.get('/pengaduan/$pengaduanId/status-history');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'history': (data['history'] as List)
              .map((item) => StatusHistoryModel.fromJson(item))
              .toList(),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mendapatkan riwayat status',
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

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _apiService.get('/pengaduan/statistics');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'statistics': data['statistics'],
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Gagal mendapatkan statistik',
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
}

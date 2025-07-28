import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pengaduan.dart';
import '../models/kategori.dart';
import '../services/api_service.dart';
import '../services/image_upload_service.dart';

class PengaduanProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Pengaduan> _pengaduans = [];
  List<Kategori> _kategoris = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  bool _hasLoadedOnce = false; // Add flag to prevent multiple loads
  String? _error;

  List<Pengaduan> get pengaduans => _pengaduans;
  List<Kategori> get kategoris => _kategoris;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get error => _error;

  Future<void> loadPengaduans() async {
    // Prevent multiple simultaneous loads
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pengaduans = await _apiService.getPengaduan();
      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadKategoris() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _kategoris = await _apiService.getKategori();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _statistics = await _apiService.getPengaduanStatistics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Pengaduan?> getPengaduanById(int id) async {
    try {
      return await _apiService.getPengaduanById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createPengaduan({
    required String judul,
    required String deskripsi,
    required int kategoriId,
    String? lokasi,
    String? namaInstansi,
    String? foto,
    Uint8List? imageBytes,
    XFile? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print(
          "createPengaduan called in provider with imageFile: ${imageFile != null}",
        );
        print("Judul: $judul");
        print("Deskripsi: $deskripsi");
        print("Kategori ID: $kategoriId");
        print("Lokasi: $lokasi");
        print("Nama Instansi: $namaInstansi");
      }

      // Validate required fields
      if (judul.trim().isEmpty || deskripsi.trim().isEmpty) {
        throw Exception('Judul dan deskripsi harus diisi');
      }

      // If an XFile was provided, use our specialized ImageUploadService
      if (imageFile != null) {
        if (kDebugMode) {
          print("Using specialized ImageUploadService");
        }

        // Ensure required fields are not null or empty
        final instansi = namaInstansi?.trim() ?? '';
        final lokasiKejadian = lokasi?.trim() ?? '';
        
        if (instansi.isEmpty) {
          throw Exception('Nama instansi harus diisi');
        }

        final response = await ImageUploadService.uploadPengaduanWithImage(
          judul: judul.trim(),
          deskripsi: deskripsi.trim(),
          kategoriId: kategoriId,
          lokasi: lokasiKejadian.isEmpty ? null : lokasiKejadian,
          namaInstansi: instansi,
          imageFile: imageFile,
        );

        if (kDebugMode) {
          print("ImageUploadService response: $response");
        }

        // Check if response contains pengaduan data
        if (response.containsKey('data') || response.containsKey('id')) {
          // Success - refresh the list
          await loadPengaduans();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          throw Exception('Invalid response from server');
        }
      } else {
        // Otherwise use the regular method (without image)
        if (kDebugMode) {
          print("Using regular API service (no image)");
        }

        await _apiService.createPengaduan(
          judul: judul.trim(),
          deskripsi: deskripsi.trim(),
          kategoriId: kategoriId,
          lokasi: lokasi?.trim(),
          namaInstansi: namaInstansi?.trim(),
          foto: foto,
          imageBytes: imageBytes,
        );

        await loadPengaduans(); // Refresh the list
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print("Error in createPengaduan provider: $e");
        print("Stack trace: ${StackTrace.current}");
      }

      return false;
    }
  }

  Future<bool> updatePengaduan({
    required int id,
    required String judul,
    required String deskripsi,
    required int kategoriId,
    String? lokasi,
    String? foto,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.updatePengaduan(
        id: id,
        judul: judul,
        deskripsi: deskripsi,
        kategoriId: kategoriId,
        lokasi: lokasi,
        foto: foto,
      );
      await loadPengaduans(); // Refresh the list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

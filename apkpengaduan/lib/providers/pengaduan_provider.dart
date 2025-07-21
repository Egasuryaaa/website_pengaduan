import 'package:flutter/foundation.dart';
import '../models/pengaduan.dart';
import '../models/kategori.dart';
import '../services/api_service.dart';

class PengaduanProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Pengaduan> _pengaduans = [];
  List<Kategori> _kategoris = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _error;

  List<Pengaduan> get pengaduans => _pengaduans;
  List<Kategori> get kategoris => _kategoris;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPengaduans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pengaduans = await _apiService.getPengaduan();
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
    String? foto,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.createPengaduan(
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

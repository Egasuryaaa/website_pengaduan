import 'package:flutter/foundation.dart';
import '../models/pengaduan_statistics.dart';
import '../services/api_service.dart';

class StatisticsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  PengaduanStatistics? _statistics;
  bool _isLoading = false;
  String? _error;

  PengaduanStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('StatisticsProvider: Loading pengaduan statistics...');
      }
      
      final response = await _apiService.getPengaduanStatistics();
      
      if (kDebugMode) {
        print('StatisticsProvider: Response: $response');
      }
      
      // Handle response structure: {"success": true, "data": {...}}
      if (response['success'] == true && response['data'] != null) {
        _statistics = PengaduanStatistics.fromJson(response['data']);
        if (kDebugMode) {
          print('StatisticsProvider: Statistics loaded successfully');
          print('StatisticsProvider: Total: ${_statistics!.total}, Pending: ${_statistics!.pending}, Proses: ${_statistics!.proses}, Selesai: ${_statistics!.selesai}');
        }
      } else if (response['data'] != null) {
        _statistics = PengaduanStatistics.fromJson(response['data']);
      } else {
        // Fallback if structure is different
        _statistics = PengaduanStatistics.fromJson(response);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('StatisticsProvider: Error loading statistics: $e');
      }
      _error = 'Gagal memuat statistik: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadStatistics();
  }
}

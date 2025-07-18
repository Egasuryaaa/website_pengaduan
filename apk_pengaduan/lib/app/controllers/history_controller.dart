import 'package:get/get.dart';
import '../models/pengaduan_model.dart';
import '../services/pengaduan_service.dart';
import '../utils/app_utils.dart';
import '../utils/constants.dart';

class HistoryController extends GetxController {
  final PengaduanService _pengaduanService = PengaduanService();
  
  // Observable variables
  final isLoading = false.obs;
  final pengaduanList = <PengaduanModel>[].obs;
  final filteredList = <PengaduanModel>[].obs;
  final selectedStatus = 'all'.obs;
  
  // Pagination
  final currentPage = 1.obs;
  final hasMore = true.obs;
  
  final statusOptions = [
    {'value': 'all', 'label': 'Semua'},
    {'value': AppConstants.statusPending, 'label': AppStrings.statusPending},
    {'value': AppConstants.statusDiproses, 'label': AppStrings.statusDiproses},
    {'value': AppConstants.statusSelesai, 'label': AppStrings.statusSelesai},
  ];
  
  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }
  
  Future<void> loadHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }
    
    if (!hasMore.value) return;
    
    isLoading.value = true;
    
    try {
      final result = await _pengaduanService.getPengaduanList(
        page: currentPage.value,
        limit: AppConstants.defaultPageSize,
        status: selectedStatus.value != 'all' ? selectedStatus.value : null,
      );
      
      if (result['success']) {
        final newPengaduan = result['pengaduan'] as List<PengaduanModel>;
        
        if (isRefresh) {
          pengaduanList.assignAll(newPengaduan);
        } else {
          pengaduanList.addAll(newPengaduan);
        }
        
        // Check if there are more items
        hasMore.value = newPengaduan.length >= AppConstants.defaultPageSize;
        currentPage.value++;
        
        _filterList();
      } else {
        AppUtils.showErrorToast(result['message']);
      }
    } catch (e) {
      AppUtils.showErrorToast('Gagal memuat riwayat: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void filterByStatus(String status) {
    selectedStatus.value = status;
    loadHistory(isRefresh: true);
  }
  
  void _filterList() {
    if (selectedStatus.value == 'all') {
      filteredList.assignAll(pengaduanList);
    } else {
      filteredList.assignAll(
        pengaduanList.where((pengaduan) => pengaduan.status == selectedStatus.value).toList(),
      );
    }
  }
  
  Map<String, int> getStatistics() {
    final stats = <String, int>{};
    for (final pengaduan in pengaduanList) {
      final status = pengaduan.status ?? 'unknown';
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }
}

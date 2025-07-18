import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pengaduan_controller.dart';
import '../../utils/constants.dart';
import '../../utils/app_utils.dart';

class PengaduanDetailView extends StatelessWidget {
  const PengaduanDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PengaduanController>();
    final pengaduanId = Get.arguments as String?;
    
    if (pengaduanId != null) {
      controller.loadPengaduanDetail(pengaduanId);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengaduan'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final pengaduan = controller.selectedPengaduan.value;
        
        if (pengaduan == null) {
          return const Center(
            child: Text('Pengaduan tidak ditemukan'),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Row(
                    children: [
                      Icon(
                        AppUtils.getStatusIcon(pengaduan.status ?? ''),
                        color: AppUtils.getStatusColor(pengaduan.status ?? ''),
                        size: AppSizes.iconLarge,
                      ),
                      const SizedBox(width: AppSizes.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppUtils.getStatusText(pengaduan.status ?? ''),
                              style: TextStyle(
                                fontSize: AppSizes.fontSize18,
                                fontWeight: FontWeight.bold,
                                color: AppUtils.getStatusColor(pengaduan.status ?? ''),
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacing4),
                            Text(
                              pengaduan.createdAt != null
                                  ? AppUtils.formatDateTime(pengaduan.createdAt!)
                                  : 'Tidak diketahui',
                              style: const TextStyle(
                                fontSize: AppSizes.fontSize14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.spacing16),
              
              // Detail Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Pengaduan',
                        style: TextStyle(
                          fontSize: AppSizes.fontSize18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing16),
                      
                      _buildDetailRow('Nama Instansi', pengaduan.namaInstansi ?? '-'),
                      _buildDetailRow('Kategori', pengaduan.kategori?.nama ?? '-'),
                      _buildDetailRow('Deskripsi', pengaduan.deskripsi ?? '-'),
                      
                      if (pengaduan.fotoBukti != null) ...[
                        const SizedBox(height: AppSizes.spacing16),
                        const Text(
                          'Foto Bukti',
                          style: TextStyle(
                            fontSize: AppSizes.fontSize14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radius8),
                          child: Image.network(
                            pengaduan.fotoBukti!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: AppUtils.buildNetworkImageError,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppSizes.fontSize14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacing4),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppSizes.fontSize14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

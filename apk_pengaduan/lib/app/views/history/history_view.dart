import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/history_controller.dart';
import '../../utils/constants.dart';
import '../../utils/app_utils.dart';
import '../../routes/app_routes.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final ScrollController _scrollController = ScrollController();
  late HistoryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HistoryController>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pengaduan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadHistory(isRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            child: Obx(() {
              final stats = controller.getStatistics();
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      stats.values.fold(0, (sum, count) => sum + count),
                      AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      stats[AppConstants.statusPending] ?? 0,
                      AppColors.statusPending,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Expanded(
                    child: _buildStatCard(
                      'Diproses',
                      stats[AppConstants.statusDiproses] ?? 0,
                      AppColors.statusDiproses,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing8),
                  Expanded(
                    child: _buildStatCard(
                      'Selesai',
                      stats[AppConstants.statusSelesai] ?? 0,
                      AppColors.statusSelesai,
                    ),
                  ),
                ],
              );
            }),
          ),
          
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.statusOptions.map((option) {
                  final isSelected = controller.selectedStatus.value == option['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.spacing8),
                    child: FilterChip(
                      label: Text(option['label'] as String),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          controller.filterByStatus(option['value'] as String);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            )),
          ),
          
          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadHistory(isRefresh: true),
              child: Obx(() {
                if (controller.pengaduanList.isEmpty && controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (controller.pengaduanList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: AppSizes.spacing16),
                        Text(
                          'Belum ada riwayat pengaduan',
                          style: TextStyle(
                            fontSize: AppSizes.fontSize16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  itemCount: controller.pengaduanList.length + (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.pengaduanList.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.spacing16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final pengaduan = controller.pengaduanList[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
                      child: ListTile(
                        leading: Icon(
                          AppUtils.getStatusIcon(pengaduan.status ?? ''),
                          color: AppUtils.getStatusColor(pengaduan.status ?? ''),
                        ),
                        title: Text(
                          pengaduan.namaInstansi ?? 'Tidak diketahui',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pengaduan.deskripsi ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.spacing4),
                            Text(
                              pengaduan.createdAt != null
                                  ? AppUtils.formatDateTime(pengaduan.createdAt!)
                                  : 'Tidak diketahui',
                              style: const TextStyle(
                                fontSize: AppSizes.fontSize12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.spacing8,
                            vertical: AppSizes.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: AppUtils.getStatusColor(pengaduan.status ?? '').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radius12),
                          ),
                          child: Text(
                            AppUtils.getStatusText(pengaduan.status ?? ''),
                            style: TextStyle(
                              fontSize: AppSizes.fontSize10,
                              fontWeight: FontWeight.w600,
                              color: AppUtils.getStatusColor(pengaduan.status ?? ''),
                            ),
                          ),
                        ),
                        onTap: () {
                          Get.toNamed(AppRoutes.pengaduanDetail, arguments: pengaduan.id);
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing12),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: AppSizes.fontSize20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppSizes.spacing4),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppSizes.fontSize12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

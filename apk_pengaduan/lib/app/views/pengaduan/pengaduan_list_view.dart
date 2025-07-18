import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pengaduan_controller.dart';
import '../../utils/constants.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_button.dart';

class PengaduanListView extends StatefulWidget {
  const PengaduanListView({super.key});

  @override
  State<PengaduanListView> createState() => _PengaduanListViewState();
}

class _PengaduanListViewState extends State<PengaduanListView> {
  final ScrollController _scrollController = ScrollController();
  late PengaduanController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PengaduanController>();
    controller.loadPengaduanList(isRefresh: true);
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadPengaduanList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengaduan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadPengaduanList(isRefresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadPengaduanList(isRefresh: true),
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
                    Icons.inbox_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppSizes.spacing16),
                  Text(
                    'Belum ada pengaduan',
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
                margin: const EdgeInsets.only(bottom: AppSizes.spacing16),
                child: InkWell(
                  onTap: () => controller.goToDetail(pengaduan),
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pengaduan.namaInstansi ?? 'Tidak diketahui',
                                    style: const TextStyle(
                                      fontSize: AppSizes.fontSize16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.spacing4),
                                  Text(
                                    pengaduan.kategori?.nama ?? 'Tidak diketahui',
                                    style: const TextStyle(
                                      fontSize: AppSizes.fontSize14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.spacing8,
                                vertical: AppSizes.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: AppUtils.getStatusColor(pengaduan.status ?? '').withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radius16),
                              ),
                              child: Text(
                                AppUtils.getStatusText(pengaduan.status ?? ''),
                                style: TextStyle(
                                  fontSize: AppSizes.fontSize12,
                                  fontWeight: FontWeight.w600,
                                  color: AppUtils.getStatusColor(pengaduan.status ?? ''),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: AppSizes.spacing12),
                        
                        // Description
                        Text(
                          pengaduan.deskripsi ?? '',
                          style: const TextStyle(
                            fontSize: AppSizes.fontSize14,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: AppSizes.spacing12),
                        
                        // Footer
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: AppSizes.iconSmall,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSizes.spacing4),
                            Text(
                              pengaduan.createdAt != null
                                  ? AppUtils.formatRelativeTime(pengaduan.createdAt!)
                                  : 'Tidak diketahui',
                              style: const TextStyle(
                                fontSize: AppSizes.fontSize12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            if (pengaduan.fotoBukti != null)
                              const Icon(
                                Icons.image,
                                size: AppSizes.iconSmall,
                                color: AppColors.primaryColor,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}

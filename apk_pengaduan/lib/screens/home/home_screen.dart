import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/pengaduan_controller.dart';
import '../pengaduan/create_pengaduan_screen.dart';
import '../pengaduan/pengaduan_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final PengaduanController pengaduanController = Get.put(PengaduanController());

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => pengaduanController.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Obx(() => Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        authController.user.value?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              
              const SizedBox(height: 20),
              
              // Statistics Cards
              const Text(
                'Statistik Pengaduan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 10),
              
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      pengaduanController.statistics['total']?.toString() ?? '0',
                      Colors.blue,
                      Icons.description,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      pengaduanController.statistics['pending']?.toString() ?? '0',
                      Colors.orange,
                      Icons.access_time,
                    ),
                  ),
                ],
              )),
              
              const SizedBox(height: 10),
              
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Proses',
                      pengaduanController.statistics['proses']?.toString() ?? '0',
                      Colors.purple,
                      Icons.settings,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'Selesai',
                      pengaduanController.statistics['selesai']?.toString() ?? '0',
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                ],
              )),
              
              const SizedBox(height: 30),
              
              // Quick Actions
              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      'Buat Pengaduan',
                      'Ajukan pengaduan baru',
                      Icons.add_circle,
                      Colors.green,
                      () => Get.to(() => CreatePengaduanScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMenuCard(
                      'Lihat Pengaduan',
                      'Daftar pengaduan Anda',
                      Icons.list,
                      Colors.blue,
                      () => Get.to(() => PengaduanListScreen()),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Recent Pengaduan
              const Text(
                'Pengaduan Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 10),
              
              Obx(() {
                if (pengaduanController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (pengaduanController.pengaduans.isEmpty) {
                  return Card(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Belum ada pengaduan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pengaduanController.pengaduans.length > 3 
                      ? 3 
                      : pengaduanController.pengaduans.length,
                  itemBuilder: (context, index) {
                    final pengaduan = pengaduanController.pengaduans[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(pengaduan.status),
                          child: Icon(
                            _getStatusIcon(pengaduan.status),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          pengaduan.judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pengaduan.statusText,
                              style: TextStyle(
                                color: _getStatusColor(pengaduan.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              pengaduan.nomorTiket,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to detail
                        },
                      ),
                    );
                  },
                );
              }),
              
              if (pengaduanController.pengaduans.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Center(
                    child: TextButton(
                      onPressed: () => Get.to(() => PengaduanListScreen()),
                      child: const Text('Lihat Semua'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'proses':
        return Colors.purple;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'proses':
        return Icons.settings;
      case 'selesai':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

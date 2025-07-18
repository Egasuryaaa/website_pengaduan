import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSizes.spacing24),
            
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.report_problem,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),
            
            // App Name
            const Text(
              'Aplikasi Pengaduan',
              style: TextStyle(
                fontSize: AppSizes.fontSize24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.spacing8),
            
            // Subtitle
            const Text(
              'Dinas Kominfo Gunung Kidul',
              style: TextStyle(
                fontSize: AppSizes.fontSize16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spacing32),
            
            // Version Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Aplikasi',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing12),
                    const InfoRow(
                      label: 'Versi',
                      value: '1.0.0',
                    ),
                    const InfoRow(
                      label: 'Build',
                      value: '1',
                    ),
                    const InfoRow(
                      label: 'Tanggal Rilis',
                      value: '2024',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            
            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing12),
                    const Text(
                      'Aplikasi Pengaduan adalah platform digital yang memungkinkan masyarakat Gunung Kidul untuk menyampaikan keluhan, saran, dan laporan terkait pelayanan publik kepada Dinas Kominfo Gunung Kidul secara mudah dan transparan.',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            
            // Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fitur Utama',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing12),
                    const FeatureItem(
                      icon: Icons.add_circle_outline,
                      title: 'Buat Pengaduan',
                      description: 'Laporkan masalah dengan mudah',
                    ),
                    const FeatureItem(
                      icon: Icons.track_changes,
                      title: 'Lacak Status',
                      description: 'Pantau perkembangan pengaduan',
                    ),
                    const FeatureItem(
                      icon: Icons.notifications,
                      title: 'Notifikasi',
                      description: 'Dapatkan update real-time',
                    ),
                    const FeatureItem(
                      icon: Icons.history,
                      title: 'Riwayat',
                      description: 'Lihat semua pengaduan sebelumnya',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing16),
            
            // Contact Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kontak',
                      style: TextStyle(
                        fontSize: AppSizes.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing12),
                    const InfoRow(
                      label: 'Alamat',
                      value: 'Jl. Brigjend Katamso No.1, Wonosari',
                    ),
                    const InfoRow(
                      label: 'Telepon',
                      value: '(0274) 391019',
                    ),
                    const InfoRow(
                      label: 'Email',
                      value: 'kominfo@gunungkidulkab.go.id',
                    ),
                    const InfoRow(
                      label: 'Website',
                      value: 'www.gunungkidulkab.go.id',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacing32),
            
            // Copyright
            const Text(
              '© 2024 Dinas Kominfo Gunung Kidul\nSemua hak cipta dilindungi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.fontSize12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.fontSize14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppSizes.fontSize14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryColor,
            size: 20,
          ),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSize14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: AppSizes.fontSize12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

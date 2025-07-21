import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/pengaduan.dart';
import '../../providers/pengaduan_provider.dart';

class PengaduanDetailScreen extends StatefulWidget {
  final String pengaduanId;

  const PengaduanDetailScreen({
    super.key,
    required this.pengaduanId,
  });

  @override
  State<PengaduanDetailScreen> createState() => _PengaduanDetailScreenState();
}

class _PengaduanDetailScreenState extends State<PengaduanDetailScreen> {
  Pengaduan? pengaduan;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPengaduan();
  }

  Future<void> _loadPengaduan() async {
    final pengaduanProvider = Provider.of<PengaduanProvider>(context, listen: false);
    final result = await pengaduanProvider.getPengaduanById(int.parse(widget.pengaduanId));
    
    setState(() {
      pengaduan = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengaduan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (pengaduan != null && pengaduan!.status.toLowerCase() == 'pending')
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    context.push('/pengaduan/${pengaduan!.id}/edit');
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pengaduan == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Pengaduan tidak ditemukan'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      Card(
                        color: _getStatusColor(pengaduan!.status).withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(pengaduan!.status),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  _getStatusIcon(pengaduan!.status),
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status Pengaduan',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      pengaduan!.status,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(pengaduan!.status),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Basic Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Informasi Pengaduan',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('ID', '#${pengaduan!.id}'),
                              _buildInfoRow('Judul', pengaduan!.judul),
                              if (pengaduan!.kategori != null)
                                _buildInfoRow('Kategori', pengaduan!.kategori!.nama),
                              _buildInfoRow(
                                'Tanggal Dibuat',
                                '${pengaduan!.createdAt.day}/${pengaduan!.createdAt.month}/${pengaduan!.createdAt.year} ${pengaduan!.createdAt.hour}:${pengaduan!.createdAt.minute.toString().padLeft(2, '0')}',
                              ),
                              _buildInfoRow(
                                'Terakhir Diupdate',
                                '${pengaduan!.updatedAt.day}/${pengaduan!.updatedAt.month}/${pengaduan!.updatedAt.year} ${pengaduan!.updatedAt.hour}:${pengaduan!.updatedAt.minute.toString().padLeft(2, '0')}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.description, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Deskripsi',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  pengaduan!.deskripsi,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Foto Card
                      if (pengaduan!.foto != null && pengaduan!.foto!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.camera_alt, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Foto Bukti',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange[200]!),
                                  ),
                                  child: Text(
                                    pengaduan!.foto!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Response Card
                      if (pengaduan!.tanggapan != null && pengaduan!.tanggapan!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.reply, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tanggapan Admin',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue[200]!),
                                  ),
                                  child: Text(
                                    pengaduan!.tanggapan!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'diproses':
        return Icons.settings;
      case 'selesai':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

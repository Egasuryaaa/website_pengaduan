import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/pengaduan_provider.dart';

class CreatePengaduanScreen extends StatefulWidget {
  const CreatePengaduanScreen({super.key});

  @override
  State<CreatePengaduanScreen> createState() => _CreatePengaduanScreenState();
}

class _CreatePengaduanScreenState extends State<CreatePengaduanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _fotoController = TextEditingController();
  int? _selectedKategoriId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PengaduanProvider>(context, listen: false).loadKategoris();
    });
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> _submitPengaduan() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedKategoriId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih kategori pengaduan'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final pengaduanProvider = Provider.of<PengaduanProvider>(context, listen: false);
        final success = await pengaduanProvider.createPengaduan(
          judul: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          kategoriId: _selectedKategoriId!,
          lokasi: _lokasiController.text.trim().isEmpty 
              ? null 
              : _lokasiController.text.trim(),
          foto: _fotoController.text.trim().isEmpty 
              ? null 
              : _fotoController.text.trim(),
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengaduan berhasil dibuat'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat pengaduan: ${pengaduanProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pengaduan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PengaduanProvider>(
        builder: (context, pengaduanProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Informasi Pengaduan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _judulController,
                            decoration: const InputDecoration(
                              labelText: 'Judul Pengaduan *',
                              prefixIcon: Icon(Icons.title),
                              border: OutlineInputBorder(),
                              hintText: 'Masukkan judul pengaduan yang jelas',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Judul tidak boleh kosong';
                              }
                              if (value.trim().length < 10) {
                                return 'Judul minimal 10 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedKategoriId,
                            decoration: const InputDecoration(
                              labelText: 'Kategori *',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(),
                            ),
                            items: pengaduanProvider.kategoris.map((kategori) {
                              return DropdownMenuItem<int>(
                                value: kategori.id,
                                child: Text(kategori.nama),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedKategoriId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Pilih kategori pengaduan';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _deskripsiController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Deskripsi Pengaduan *',
                              prefixIcon: Icon(Icons.description),
                              border: OutlineInputBorder(),
                              hintText: 'Jelaskan detail pengaduan Anda dengan lengkap',
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Deskripsi tidak boleh kosong';
                              }
                              if (value.trim().length < 20) {
                                return 'Deskripsi minimal 20 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lokasiController,
                            decoration: const InputDecoration(
                              labelText: 'Lokasi Kejadian *',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(),
                              hintText: 'Masukkan lokasi terjadinya masalah',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Lokasi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _fotoController,
                            decoration: const InputDecoration(
                              labelText: 'Foto Bukti (Opsional)',
                              prefixIcon: Icon(Icons.camera_alt),
                              border: OutlineInputBorder(),
                              hintText: 'URL foto atau path file',
                            ),
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                // Basic validation for file path or URL
                                if (!value.contains('/') && !value.contains('http')) {
                                  return 'Masukkan path file atau URL yang valid';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.blue[50],
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.tips_and_updates, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            'Tips Membuat Pengaduan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Gunakan judul yang jelas dan spesifik\n'
                            '• Jelaskan masalah dengan detail\n'
                            '• Sertakan bukti jika diperlukan\n'
                            '• Pilih kategori yang sesuai',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: pengaduanProvider.isLoading ? null : _submitPengaduan,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: pengaduanProvider.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Menyimpan...'),
                            ],
                          )
                        : const Text(
                            'Kirim Pengaduan',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

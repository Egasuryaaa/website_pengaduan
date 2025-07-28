import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';

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
  final _namaInstansiController = TextEditingController();
  int? _selectedKategoriId;
  // Support both web and mobile
  io.File? _selectedImageFile;
  XFile? _selectedImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

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
    _namaInstansiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permission for camera or gallery (only on mobile)
      if (!kIsWeb && source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin kamera diperlukan untuk mengambil foto'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // Web platform handling
          // Read file as bytes
          final bytes = await image.readAsBytes();

          // Check file size (max 5MB)
          if (bytes.length > 5 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ukuran file terlalu besar (maksimal 5MB)'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          setState(() {
            _selectedImage = image;
            _webImage = bytes;
          });
        } else {
          // Mobile platform handling
          final file = io.File(image.path);

          // Cek apakah file benar-benar ada
          if (await file.exists()) {
            // Cek ukuran file (maksimal 5MB)
            final fileSize = await file.length();
            if (fileSize > 5 * 1024 * 1024) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ukuran file terlalu besar (maksimal 5MB)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }

            setState(() {
              _selectedImage = image;
              _selectedImageFile = file;
            });
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File gambar tidak ditemukan'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _imageErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red),
            Text('Gagal memuat gambar'),
          ],
        ),
      ),
    );
  }

  Widget _imageLoadingWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!kIsWeb) // Show camera option only on mobile
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Kamera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
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
        if (kDebugMode) {
          print('====== SUBMITTING PENGADUAN ======');
          print('Judul: ${_judulController.text.trim()}');
          print('Deskripsi: ${_deskripsiController.text.trim()}');
          print('Kategori ID: $_selectedKategoriId');
          print('Lokasi: ${_lokasiController.text.trim()}');
          print('Nama Instansi: ${_namaInstansiController.text.trim()}');
          print('Has Image: ${_selectedImage != null}');
        }

        final pengaduanProvider = Provider.of<PengaduanProvider>(
          context,
          listen: false,
        );

        // Always pass the XFile directly for better handling
        XFile? imageFile = _selectedImage;

        if (kDebugMode && imageFile != null) {
          developer.log('Image Info:');
          developer.log('- Image name: ${imageFile.name}');
          developer.log('- Image path: ${imageFile.path}');

          if (kIsWeb) {
            final bytes = await imageFile.readAsBytes();
            developer.log('- Web image bytes size: ${bytes.length} bytes');
          } else if (_selectedImageFile != null) {
            developer.log(
              '- Mobile file exists: ${_selectedImageFile!.existsSync()}',
            );
            developer.log(
              '- Mobile file size: ${await _selectedImageFile!.length()} bytes',
            );
          }
        }

        if (kDebugMode) {
          developer.log(
            '- Calling createPengaduan on provider: ${await _selectedImageFile!.length()} bytes',
          );
        }

        // Always include nama_instansi as it's required by the API
        String namaInstansi = _namaInstansiController.text.trim();
        if (namaInstansi.isEmpty) {
          // If not provided, use a default value to prevent API validation errors
          namaInstansi = "Default";
        }

        final success = await pengaduanProvider.createPengaduan(
          judul: _judulController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          kategoriId: _selectedKategoriId!,
          lokasi:
              _lokasiController.text.trim().isEmpty
                  ? null
                  : _lokasiController.text.trim(),
          namaInstansi: namaInstansi,
          imageFile: imageFile,
        );

        if (kDebugMode) {
          print('createPengaduan result: $success');
          print('Error: ${pengaduanProvider.error}');
        }

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
              content: Text(
                'Gagal membuat pengaduan: ${pengaduanProvider.error ?? "Unknown error"}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
                            items:
                                pengaduanProvider.kategoris.map((kategori) {
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
                              hintText:
                                  'Jelaskan detail pengaduan Anda dengan lengkap',
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Deskripsi tidak boleh kosong';
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
                            controller: _namaInstansiController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Instansi *',
                              prefixIcon: Icon(Icons.business),
                              border: OutlineInputBorder(),
                              hintText:
                                  'Masukkan nama instansi atau perusahaan',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama instansi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Image picker widget
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Foto Bukti (Opsional)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_selectedImage != null) ...[
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        kIsWeb
                                            ? _webImage != null
                                                ? Image.memory(
                                                  _webImage!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return _imageErrorWidget();
                                                  },
                                                )
                                                : _imageLoadingWidget()
                                            : _selectedImageFile != null
                                            ? Image.file(
                                              _selectedImageFile!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return _imageErrorWidget();
                                              },
                                            )
                                            : FutureBuilder<Uint8List>(
                                              future:
                                                  _selectedImage!.readAsBytes(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                        ConnectionState.done &&
                                                    snapshot.data != null) {
                                                  return Image.memory(
                                                    snapshot.data!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return _imageErrorWidget();
                                                    },
                                                  );
                                                } else {
                                                  return _imageLoadingWidget();
                                                }
                                              },
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _showImagePickerDialog,
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Ganti Foto'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedImage = null;
                                          _selectedImageFile = null;
                                          _webImage = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Hapus'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                GestureDetector(
                                  onTap: _showImagePickerDialog,
                                  child: Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        style: BorderStyle.solid,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Ketuk untuk menambah foto',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          'Kamera atau Galeri',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
                    onPressed:
                        pengaduanProvider.isLoading ? null : _submitPengaduan,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        pengaduanProvider.isLoading
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

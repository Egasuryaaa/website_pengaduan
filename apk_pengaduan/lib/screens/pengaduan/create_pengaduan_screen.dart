import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pengaduan_controller.dart';
import '../../app/widgets/universal_image.dart';

class CreatePengaduanScreen extends StatelessWidget {
  final PengaduanController pengaduanController = Get.isRegistered<PengaduanController>() 
      ? Get.find<PengaduanController>() 
      : Get.put(PengaduanController());
  final _formKey = GlobalKey<FormState>();

  CreatePengaduanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pengaduan'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Formulir Pengaduan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Judul Field
              TextFormField(
                controller: pengaduanController.judulController,
                decoration: InputDecoration(
                  labelText: 'Judul Pengaduan',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Kategori Dropdown
              Obx(() => DropdownButtonFormField<int>(
                value: pengaduanController.selectedKategoriId.value,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: pengaduanController.kategoris.map((kategori) {
                  return DropdownMenuItem<int>(
                    value: kategori.id,
                    child: Text(kategori.nama),
                  );
                }).toList(),
                onChanged: (value) {
                  pengaduanController.selectedKategoriId.value = value;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Kategori harus dipilih';
                  }
                  return null;
                },
              )),
              
              const SizedBox(height: 20),
              
              // Lokasi Field
              TextFormField(
                controller: pengaduanController.lokasiController,
                decoration: InputDecoration(
                  labelText: 'Lokasi Kejadian',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Deskripsi Field
              TextFormField(
                controller: pengaduanController.deskripsiController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Pengaduan',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Image Section
              const Text(
                'Foto Pendukung (Opsional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 10),
              
              Obx(() => (pengaduanController.selectedImage.value != null || pengaduanController.selectedImageBytes.value != null)
                  ? Card(
                      child: Column(
                        children: [
                          UniversalImage(
                            imagePath: pengaduanController.selectedImage.value?.path,
                            imageBytes: pengaduanController.selectedImageBytes.value,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  onPressed: () => pengaduanController.pickImage(),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Ganti Foto'),
                                ),
                                TextButton.icon(
                                  onPressed: () => pengaduanController.selectedImage.value = null,
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Hapus'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tambahkan foto untuk memperjelas pengaduan',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => pengaduanController.takePhoto(),
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Kamera'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => pengaduanController.pickImage(),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Galeri'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
              
              const SizedBox(height: 30),
              
              // Submit Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: pengaduanController.isLoading.value 
                      ? null 
                      : () {
                          if (_formKey.currentState!.validate()) {
                            pengaduanController.createPengaduan();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: pengaduanController.isLoading.value
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Kirim Pengaduan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pengaduan_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/universal_image.dart';

class PengaduanCreateView extends StatelessWidget {
  const PengaduanCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PengaduanController>();
    final pengaduan = Get.arguments; // For edit mode
    final isEdit = pengaduan != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pengaduan' : 'Buat Pengaduan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Form(
          key: controller.pengaduanFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Instansi
              CustomTextField(
                controller: controller.namaInstansiController,
                labelText: AppStrings.namaInstansi,
                hintText: 'Masukkan nama instansi',
                keyboardType: TextInputType.text,
                prefixIcon: Icons.business_outlined,
                validator: controller.validateNamaInstansi,
              ),
              
              const SizedBox(height: AppSizes.spacing16),
              
              // Kategori Dropdown
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: AppSizes.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.spacing8),
              
              Obx(() => DropdownButtonFormField(
                value: controller.selectedKategori.value,
                items: controller.kategoriList.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori.nama ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedKategori.value = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Pilih kategori',
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    color: AppColors.primaryColor,
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Kategori wajib dipilih';
                  }
                  return null;
                },
              )),
              
              const SizedBox(height: AppSizes.spacing16),
              
              // Deskripsi
              CustomTextField(
                controller: controller.deskripsiController,
                labelText: AppStrings.deskripsi,
                hintText: 'Jelaskan masalah yang Anda hadapi',
                maxLines: 5,
                prefixIcon: Icons.description_outlined,
                validator: controller.validateDeskripsi,
              ),
              
              const SizedBox(height: AppSizes.spacing16),
              
              // Foto Bukti
              const Text(
                'Foto Bukti (Opsional)',
                style: TextStyle(
                  fontSize: AppSizes.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.spacing8),
              
              Obx(() => Column(
                children: [
                  if (controller.selectedImagePath.value != null || controller.selectedImageBytes.value != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radius8),
                          child: UniversalImage(
                            imagePath: controller.selectedImagePath.value,
                            imageBytes: controller.selectedImageBytes.value,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.errorColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.textWhite,
                                size: AppSizes.iconSmall,
                              ),
                              onPressed: controller.removeImage,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.dividerColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radius8),
                      ),
                      child: InkWell(
                        onTap: controller.pickImage,
                        borderRadius: BorderRadius.circular(AppSizes.radius8),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: AppSizes.iconLarge,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: AppSizes.spacing8),
                            Text(
                              'Tap untuk menambah foto',
                              style: TextStyle(
                                fontSize: AppSizes.fontSize14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  if (controller.selectedImagePath.value == null)
                    const SizedBox(height: AppSizes.spacing8),
                  
                  if (controller.selectedImagePath.value == null)
                    CustomButton(
                      text: 'Pilih Foto',
                      icon: Icons.camera_alt,
                      onPressed: controller.pickImage,
                      isOutlined: true,
                      width: double.infinity,
                    ),
                ],
              )),
              
              const SizedBox(height: AppSizes.spacing32),
              
              // Submit Button
              Obx(() => CustomButton(
                text: isEdit ? 'Perbarui' : 'Kirim Pengaduan',
                onPressed: controller.isLoading.value 
                    ? null 
                    : isEdit 
                        ? () => controller.updatePengaduan(pengaduan.id)
                        : controller.createPengaduan,
                isLoading: controller.isLoading.value,
                width: double.infinity,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

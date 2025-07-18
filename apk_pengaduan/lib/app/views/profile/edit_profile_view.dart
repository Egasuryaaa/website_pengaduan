import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Form(
          key: controller.profileFormKey,
          child: Column(
            children: [
              // Name Field
              CustomTextField(
                controller: controller.nameController,
                labelText: AppStrings.name,
                hintText: 'Masukkan nama lengkap',
                keyboardType: TextInputType.name,
                prefixIcon: Icons.person_outline,
                validator: (value) => controller.validateRequired(value, 'Nama'),
              ),
              
              const SizedBox(height: AppSizes.spacing16),
              
              // Phone Field
              CustomTextField(
                controller: controller.phoneController,
                labelText: AppStrings.phone,
                hintText: 'Masukkan nomor telepon',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: controller.validatePhone,
              ),
              
              const SizedBox(height: AppSizes.spacing16),
              
              // Institution Field
              CustomTextField(
                controller: controller.namaInstansiController,
                labelText: AppStrings.namaInstansi,
                hintText: 'Masukkan nama instansi',
                keyboardType: TextInputType.text,
                prefixIcon: Icons.business_outlined,
                validator: (value) => controller.validateRequired(value, 'Nama Instansi'),
              ),
              
              const SizedBox(height: AppSizes.spacing32),
              
              // Save Button
              Obx(() => CustomButton(
                text: AppStrings.save,
                onPressed: controller.isLoading.value ? null : controller.updateProfile,
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

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/data/models/profil_model.dart';
import 'package:jawara/features/warga/controllers/profil_controller.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../widgets/input_field.dart';
import 'package:image_picker/image_picker.dart';


class EditAkunProfilPage extends ConsumerStatefulWidget {
  const EditAkunProfilPage({super.key});

  @override
  ConsumerState<EditAkunProfilPage> createState() =>
      _EditAkunProfilPageState();
}

class _EditAkunProfilPageState extends ConsumerState<EditAkunProfilPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profilControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomTopBar(title: 'Edit Akun & Profil', showBackButton: true, actions: [],),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (userData) {
          _emailController.text = userData.email;

          return Stack(
            children: [
              _buildForm(userData),
              if (_loading)
                Container(
                  color: Colors.white.withOpacity(0.6),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(ProfilModel user) {
    final controller = ref.read(profilControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.primary.withAlpha(40),
                  backgroundImage: controller.newAvatarFile != null
                      ? FileImage(controller.newAvatarFile!)
                      : controller.newAvatarBytes != null
                          ? MemoryImage(controller.newAvatarBytes!)
                          : user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                  child: (controller.newAvatarBytes == null &&
                          controller.newAvatarFile == null &&
                          user.avatarUrl == null)
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
                // Icon pensil di pojok kanan bawah
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // CARD FORM
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [               
                CustomInputField(
                  controller: _passwordController,
                  label: "Password Baru",
                  obscure: true,
                ),
                const SizedBox(height: 20),

                CustomInputField(
                  controller: _confirmPasswordController,
                  label: "Konfirmasi Password",
                  obscure: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveAll(user),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 22),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Simpan Perubahan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final controller = ref.read(profilControllerProvider.notifier);

    if (kIsWeb) {
      controller.setAvatar(null, await picked.readAsBytes());
    } else {
      controller.setAvatar(File(picked.path), null);
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _saveAll(ProfilModel user) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password dan konfirmasi tidak cocok")),
      );
      return;
    }

    final controller = ref.read(profilControllerProvider.notifier);

    if (!mounted) return;
    setState(() => _loading = true);

    await controller.saveProfile(
      password:
          _passwordController.text.isNotEmpty ? _passwordController.text : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil diperbarui")),
    );
  }
}
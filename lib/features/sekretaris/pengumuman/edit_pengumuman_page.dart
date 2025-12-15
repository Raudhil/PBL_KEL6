import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/pengumuman_provider.dart';
import '../../../data/models/pengumuman_model.dart';
import '../../../theme/app_colors.dart';

class EditPengumumanPage extends ConsumerStatefulWidget {
  final PengumumanModel pengumuman;

  const EditPengumumanPage({super.key, required this.pengumuman});

  @override
  ConsumerState<EditPengumumanPage> createState() => _EditPengumumanPageState();
}

class _EditPengumumanPageState extends ConsumerState<EditPengumumanPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _isiController;
  late TextEditingController _dokumenUrlController;

  // Image picker variables
  final _imagePicker = ImagePicker();
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.pengumuman.judul);
    _isiController = TextEditingController(text: widget.pengumuman.isi);
    _dokumenUrlController = TextEditingController(
      text: widget.pengumuman.dokumenUrl ?? '',
    );
    // Set foto URL jika ada
    if (widget.pengumuman.fotoUrl != null) {
      _uploadedImageUrl = widget.pengumuman.fotoUrl;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _dokumenUrlController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih Sumber Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      _showImagePreview(pickedFile, bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showImagePreview(XFile imageFile, Uint8List imageBytes) {
    // Langsung set state tanpa modal preview
    setState(() {
      _selectedImageFile = imageFile;
      _selectedImageBytes = imageBytes;
      _uploadedImageUrl = null;
    });
  }

  Widget _buildImagePickerSection() {
    final hasImage =
        _selectedImageFile != null ||
        _selectedImageBytes != null ||
        _uploadedImageUrl != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.image_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Foto Pengumuman (Opsional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Image Preview dengan AspectRatio untuk menghindari overflow
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasImage ? AppColors.primary : AppColors.greyLight,
                  width: hasImage ? 2 : 1,
                ),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _selectedImageBytes != null
                      ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                      : _selectedImageFile != null && !kIsWeb
                      ? Image.file(
                          File(_selectedImageFile!.path),
                          fit: BoxFit.cover,
                        )
                      : _uploadedImageUrl != null
                      ? Image.network(
                          _uploadedImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 40,
                                    color: AppColors.textSecondary.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gagal memuat foto',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap untuk upload foto',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'dari kamera atau galeri',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action button
          Center(
            child: TextButton.icon(
              onPressed: _showImageSourceDialog,
              icon: Icon(hasImage ? Icons.edit : Icons.add_a_photo, size: 18),
              label: Text(hasImage ? 'Ganti Foto' : 'Tambah Foto'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    String? fotoUrl;
    if (_selectedImageBytes != null) {
      // Upload image to storage
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mengupload foto...'),
            duration: Duration(seconds: 1),
          ),
        );

        final pengumumanId = widget.pengumuman.id.toString();

        fotoUrl = await ref
            .read(pengumumanServiceProvider)
            .uploadFotoPengumuman(_selectedImageBytes!, pengumumanId);
      } catch (uploadError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload foto: $uploadError'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    } else if (_uploadedImageUrl != null) {
      fotoUrl = _uploadedImageUrl;
    }

    final dokumenUrl = _dokumenUrlController.text.trim();

    // Call notifier - JANGAN AWAIT
    ref
        .read(pengumumanFormProvider.notifier)
        .updatePengumuman(
          id: widget.pengumuman.id,
          judul: _judulController.text.trim(),
          isi: _isiController.text.trim(),
          fotoUrl: fotoUrl,
          dokumenUrl: dokumenUrl.isEmpty ? null : dokumenUrl,
        );
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon with animation effect
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Berhasil Diupdate!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'Pengumuman berhasil diperbarui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // OK Button - Return true untuk trigger refresh di detail page
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(true); // Close modal & return true
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((result) {
      // Jika user click OK (result = true), close edit page & return true
      if (result == true && mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  // Tambahkan widget helper methods ini sebelum closing brace class:

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
      textCapitalization: TextCapitalization.words,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLength = 5000,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 8,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Icon(icon),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (value) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LISTEN to form state changes
    ref.listen<PengumumanFormState>(pengumumanFormProvider, (previous, next) {
      // Jika success
      if (next.isSuccess) {
        // Invalidate list providers
        ref.invalidate(pengumumanListProvider);
        ref.invalidate(allPengumumanProvider);
        ref.invalidate(pengumumanAktifProvider);

        // Reset form state
        ref.read(pengumumanFormProvider.notifier).resetFormState();

        // Show success modal
        _showSuccessModal();
      }

      // Jika error
      if (next.errorMessage != null && !next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    final formState = ref.watch(pengumumanFormProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Pengumuman',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informasi Dasar section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.15),
                              AppColors.primary.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Informasi Dasar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Judul
                  TextFormField(
                    controller: _judulController,
                    decoration: InputDecoration(
                      labelText: 'Judul Pengumuman',
                      hintText: 'Masukkan judul pengumuman',
                      helperText: 'Minimal 5 karakter, maksimal 100 karakter',
                      helperMaxLines: 2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.title),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '❌ Judul tidak boleh kosong';
                      }
                      if (value.trim().length < 5) {
                        return '❌ Judul minimal 5 karakter';
                      }
                      if (value.trim().length > 100) {
                        return '❌ Judul maksimal 100 karakter';
                      }
                      if (!RegExp(r'[a-zA-Z0-9]').hasMatch(value)) {
                        return '❌ Judul harus mengandung huruf atau angka';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Isi
                  TextFormField(
                    controller: _isiController,
                    decoration: InputDecoration(
                      labelText: 'Isi Pengumuman',
                      hintText:
                          'Tulis isi pengumuman dengan lengkap dan jelas...',
                      helperText: 'Minimal 10 karakter, maksimal 5000 karakter',
                      helperMaxLines: 2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Icon(Icons.description),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 8,
                    maxLength: 5000,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '❌ Isi pengumuman tidak boleh kosong';
                      }
                      if (value.trim().length < 10) {
                        return '❌ Isi pengumuman minimal 10 karakter';
                      }
                      if (value.trim().length > 5000) {
                        return '❌ Isi pengumuman maksimal 5000 karakter';
                      }
                      if (value.trim().isEmpty) {
                        return '❌ Isi pengumuman tidak boleh hanya spasi';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Foto section
            _buildImagePickerSection(),

            const SizedBox(height: 24),

            // Dokumen section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.15),
                              AppColors.primary.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.attach_file,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Dokumen (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _dokumenUrlController,
                    decoration: InputDecoration(
                      labelText: 'Link Dokumen',
                      hintText:
                          'https://example.com/dokumen.pdf atau link gdrive',
                      helperText:
                          'Masukkan link dokumen (pdf, docx, xlsx, gdrive, dll)',
                      helperMaxLines: 2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.insert_drive_file),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final trimmedValue = value.trim();

                        if (!trimmedValue.startsWith('http://') &&
                            !trimmedValue.startsWith('https://')) {
                          return '❌ URL harus dimulai dengan http:// atau https://';
                        }

                        final uri = Uri.tryParse(trimmedValue);
                        if (uri == null) {
                          return '❌ Format URL tidak valid';
                        }

                        if (uri.host.isEmpty) {
                          return '❌ URL harus memiliki domain yang valid';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: formState.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              child: formState.isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Menyimpan...',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Edit Pengumuman',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

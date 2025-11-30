import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late TextEditingController _fotoUrlController;
  late TextEditingController _dokumenUrlController;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.pengumuman.judul);
    _isiController = TextEditingController(text: widget.pengumuman.isi);
    _fotoUrlController = TextEditingController(
      text: widget.pengumuman.fotoUrl ?? '',
    );
    _dokumenUrlController = TextEditingController(
      text: widget.pengumuman.dokumenUrl ?? '',
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _fotoUrlController.dispose();
    _dokumenUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Ambil URL dari input dengan trimming
      final fotoUrl = _fotoUrlController.text.trim();
      final dokumenUrl = _dokumenUrlController.text.trim();

      // Update pengumuman
      await ref
          .read(pengumumanFormProvider.notifier)
          .updatePengumuman(
            id: widget.pengumuman.id,
            judul: _judulController.text.trim(),
            isi: _isiController.text.trim(),
            fotoUrl: fotoUrl.isEmpty ? null : fotoUrl,
            dokumenUrl: dokumenUrl.isEmpty ? null : dokumenUrl,
          );

      // Check state
      final formState = ref.read(pengumumanFormProvider);
      if (formState.isSuccess && mounted) {
        // Invalidate detail provider untuk force refresh
        ref.invalidate(pengumumanDetailProvider(widget.pengumuman.id));

        // Show success modal
        await _showSuccessModal();
      } else if (formState.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(formState.errorMessage!)),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Gagal memperbarui: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showSuccessModal() async {
    return showDialog(
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
                  'Berhasil Diperbarui!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'Pengumuman berhasil diperbarui dan sudah tersimpan di sistem.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close modal
                      Navigator.of(context).pop(); // Back to previous page
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(pengumumanFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengumuman'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Judul
            TextFormField(
              controller: _judulController,
              decoration: InputDecoration(
                labelText: 'Judul Pengumuman',
                hintText: 'Masukkan judul pengumuman',
                helperText: 'Minimal 5 karakter, maksimal 100 karakter',
                helperMaxLines: 2,
                counterText: '${_judulController.text.length}/100',
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
                hintText: 'Tulis isi pengumuman dengan lengkap dan jelas...',
                helperText: 'Minimal 10 karakter, maksimal 5000 karakter',
                helperMaxLines: 2,
                counterText: '${_isiController.text.length}/5000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
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
            const SizedBox(height: 24),

            // Foto URL Section
            Text(
              'Foto (Opsional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fotoUrlController,
              decoration: InputDecoration(
                labelText: 'Link Foto',
                hintText: 'https://example.com/foto.jpg atau link gdrive',
                helperText: 'Masukkan link gambar (jpg, png, gif, webp, dll)',
                helperMaxLines: 2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.link),
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
            const SizedBox(height: 24),

            // Dokumen URL Section
            Text(
              'Dokumen (Opsional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dokumenUrlController,
              decoration: InputDecoration(
                labelText: 'Link Dokumen',
                hintText: 'https://example.com/dokumen.pdf atau link gdrive',
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

                  // Check URL format
                  if (!trimmedValue.startsWith('http://') &&
                      !trimmedValue.startsWith('https://')) {
                    return '❌ URL harus dimulai dengan http:// atau https://';
                  }

                  // Parse URL
                  final uri = Uri.tryParse(trimmedValue);
                  if (uri == null) {
                    return '❌ Format URL tidak valid';
                  }

                  // Check domain
                  if (uri.host.isEmpty) {
                    return '❌ URL harus memiliki domain yang valid';
                  }
                }
                return null;
              },
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
                      'Perbarui Pengumuman',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

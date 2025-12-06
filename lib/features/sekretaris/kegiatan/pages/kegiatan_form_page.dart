import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../data/models/kegiatan_model.dart';
import '../../../../core/providers/kegiatan_provider.dart';

class KegiatanFormPage extends ConsumerStatefulWidget {
  final KegiatanModel? kegiatan; // null = create, not null = edit

  const KegiatanFormPage({super.key, this.kegiatan});

  @override
  ConsumerState<KegiatanFormPage> createState() => _KegiatanFormPageState();
}

class _KegiatanFormPageState extends ConsumerState<KegiatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _penyelenggaraController = TextEditingController();
  final _kuotaController = TextEditingController();
  final _fotoUrlController = TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  KategoriKegiatan _selectedKategori = KategoriKegiatan.sosial;
  StatusKegiatan _selectedStatus = StatusKegiatan.akanDatang;

  bool get isEditMode => widget.kegiatan != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _populateFormWithExistingData();
    }
  }

  void _populateFormWithExistingData() {
    final kegiatan = widget.kegiatan!;
    _judulController.text = kegiatan.judul;
    _deskripsiController.text = kegiatan.deskripsi ?? '';
    _lokasiController.text = kegiatan.lokasi ?? '';
    _penyelenggaraController.text = kegiatan.penyelenggara;
    _kuotaController.text = kegiatan.kuotaPeserta?.toString() ?? '';
    _fotoUrlController.text = kegiatan.fotoUrl ?? '';
    _tanggalMulai = kegiatan.tanggalMulai;
    _tanggalSelesai = kegiatan.tanggalSelesai;
    _selectedKategori = kegiatan.kategori;
    _selectedStatus = kegiatan.status;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _penyelenggaraController.dispose();
    _kuotaController.dispose();
    _fotoUrlController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close form page
                  // Data akan otomatis ter-update via realtime stream
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  backgroundColor: AppColors.success,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<KegiatanFormState>(kegiatanFormProvider, (previous, next) {
      if (next.isSuccess) {
        _showSuccessDialog(
          context,
          isEditMode ? 'Edit Berhasil' : 'Tambah Berhasil',
          isEditMode
              ? 'Kegiatan berhasil diperbarui'
              : 'Kegiatan berhasil ditambahkan',
        );
      }

      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    final formState = ref.watch(kegiatanFormProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditMode ? 'Edit Kegiatan' : 'Tambah Kegiatan',
          style: const TextStyle(
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
                  _buildTextField(
                    controller: _judulController,
                    label: 'Judul Kegiatan',
                    hint: 'Masukkan judul kegiatan',
                    icon: Icons.title,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      if (value.trim().length < 5) {
                        return 'Judul minimal 5 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi
                  _buildTextAreaField(
                    controller: _deskripsiController,
                    label: 'Deskripsi',
                    hint: 'Masukkan deskripsi kegiatan',
                    icon: Icons.description,
                    validator: (value) {
                      if (value != null &&
                          value.trim().isNotEmpty &&
                          value.trim().length < 10) {
                        return 'Deskripsi minimal 10 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Kategori
                  _buildDropdown<KategoriKegiatan>(
                    label: 'Kategori',
                    value: _selectedKategori,
                    items: KategoriKegiatan.values,
                    getLabel: (item) => item.label,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedKategori = value);
                      }
                    },
                    icon: Icons.category,
                  ),
                  const SizedBox(height: 16),

                  // Status
                  _buildDropdown<StatusKegiatan>(
                    label: 'Status',
                    value: _selectedStatus,
                    items: StatusKegiatan.values,
                    getLabel: (item) => item.label,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                    icon: Icons.flag,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Waktu dan Tempat section
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
                          Icons.event_note_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Waktu & Tempat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Mulai
                  _buildDateField(
                    label: 'Tanggal Mulai',
                    value: _tanggalMulai,
                    onTap: () => _selectDate(context, true),
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Selesai
                  _buildDateField(
                    label: 'Tanggal Selesai (Opsional)',
                    value: _tanggalSelesai,
                    onTap: () => _selectDate(context, false),
                    icon: Icons.event,
                  ),
                  const SizedBox(height: 16),

                  // Lokasi
                  _buildTextField(
                    controller: _lokasiController,
                    label: 'Lokasi',
                    hint: 'Masukkan lokasi kegiatan',
                    icon: Icons.location_on,
                    validator: (value) {
                      if (value != null &&
                          value.trim().isNotEmpty &&
                          value.trim().length < 3) {
                        return 'Lokasi minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Penyelenggara & Peserta section
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
                          Icons.groups_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Penyelenggara & Peserta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Penyelenggara
                  _buildTextField(
                    controller: _penyelenggaraController,
                    label: 'Penyelenggara',
                    hint: 'Masukkan nama penyelenggara',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Penyelenggara tidak boleh kosong';
                      }
                      if (value.trim().length < 3) {
                        return 'Penyelenggara minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Kuota Peserta
                  _buildTextField(
                    controller: _kuotaController,
                    label: 'Kuota Peserta (Opsional)',
                    hint: 'Masukkan jumlah kuota peserta',
                    icon: Icons.people,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final kuota = int.tryParse(value.trim());
                        if (kuota == null) {
                          return 'Kuota harus berupa angka';
                        }
                        if (kuota <= 0) {
                          return 'Kuota harus lebih dari 0';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Foto section
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
                          Icons.image_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Foto Kegiatan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // URL Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _fotoUrlController,
                      decoration: InputDecoration(
                        labelText: 'URL Foto (Opsional)',
                        hintText: 'https://example.com/image.jpg',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.link_rounded,
                          color: AppColors.primary,
                        ),
                        suffixIcon:
                            _fotoUrlController.text.isNotEmpty &&
                                _isValidUrl(_fotoUrlController.text)
                            ? IconButton(
                                icon: const Icon(
                                  Icons.preview_rounded,
                                  color: AppColors.primary,
                                ),
                                tooltip: 'Preview Foto',
                                onPressed: () {
                                  _showPhotoPreview(
                                    context,
                                    _fotoUrlController.text,
                                  );
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.greyLight.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.danger,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.danger,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      maxLines: 2,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !_isValidUrl(value)) {
                          return 'URL tidak valid';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),

                  // Helper text
                  if (_fotoUrlController.text.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cara upload gambar:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1. Buka postimages.org di browser',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '2. Pilih gambar dari HP/komputer Anda',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '3. Klik Upload, tunggu selesai',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '4. Copy "Direct link" lalu paste di sini',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Preview mini
                  if (_fotoUrlController.text.isNotEmpty &&
                      _isValidUrl(_fotoUrlController.text))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              _convertToDirectImageUrl(_fotoUrlController.text),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_rounded,
                                        size: 40,
                                        color: AppColors.textSecondary
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Gagal memuat gambar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Preview',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Submit button
            if (isEditMode) ...[
              // Edit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: formState.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  ),
                  icon: formState.isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.edit, size: 20),
                  label: formState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Edit Kegiatan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Delete button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: formState.isLoading
                      ? null
                      : () {
                          // TODO: Implement delete functionality
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Kegiatan'),
                              content: const Text(
                                'Apakah Anda yakin ingin menghapus kegiatan ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // TODO: Call delete API
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.danger,
                                  ),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text(
                    'Hapus Kegiatan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ] else
              // Create button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: formState.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  ),
                  child: formState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Tambah Kegiatan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.greyLight.withOpacity(0.5),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) getLabel,
    required void Function(T?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.greyLight.withOpacity(0.5),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        dropdownColor: AppColors.white,
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<T>(value: item, child: Text(getLabel(item))),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label dengan icon
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Text field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextFormField(
              controller: controller,
              minLines: 2,
              maxLines: 6,
              validator: validator,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.greyLight.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.greyLight.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.greyLight.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          child: Text(
            value != null ? _formatDate(value) : 'Pilih tanggal',
            style: TextStyle(
              fontSize: 16,
              color: value != null
                  ? AppColors.textPrimary
                  : AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? (_tanggalMulai ?? DateTime.now())
        : (_tanggalSelesai ?? _tanggalMulai ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _tanggalMulai = picked;
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  // Helper method untuk validasi URL yang lebih fleksibel
  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);

      // Check if has valid scheme (http or https)
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }

      // Check if has host
      if (!uri.hasAuthority || uri.host.isEmpty) {
        return false;
      }

      // Validasi fleksibel: terima semua URL yang valid
      // dengan http/https dan memiliki host yang valid
      // Ini akan menerima link dari Google Drive, Dropbox, OneDrive, dll
      return true;
    } catch (e) {
      return false;
    }
  }

  // Konversi URL ke direct image URL
  // Konversi URL ke format yang bisa ditampilkan
  String _convertToDirectImageUrl(String url) {
    try {
      // Google Drive - konversi sharing link ke direct image
      if (url.contains('drive.google.com')) {
        // Extract file ID from various Google Drive URL formats
        RegExp regExp = RegExp(
          r'(?:drive\.google\.com/(?:file/d/|open\?id=|uc\?id=))([a-zA-Z0-9_-]+)',
        );
        final match = regExp.firstMatch(url);
        if (match != null && match.groupCount >= 1) {
          final fileId = match.group(1);
          // Use thumbnail endpoint with max size
          return 'https://lh3.googleusercontent.com/d/$fileId';
        }
      }

      // Dropbox - konversi ke raw link
      if (url.contains('dropbox.com')) {
        return url
            .replaceAll('www.dropbox.com', 'dl.dropboxusercontent.com')
            .replaceAll('?dl=0', '')
            .replaceAll('?dl=1', '');
      }

      // Imgur - pastikan menggunakan i.imgur.com
      if (url.contains('imgur.com') && !url.contains('i.imgur.com')) {
        final imgurId = RegExp(r'imgur\.com/([a-zA-Z0-9]+)').firstMatch(url);
        if (imgurId != null) {
          final id = imgurId.group(1);
          return 'https://i.imgur.com/$id.jpg';
        }
      }

      // OneDrive - tambahkan parameter download
      if (url.contains('1drv.ms') || url.contains('onedrive')) {
        if (!url.contains('download=1')) {
          return url.contains('?') ? '$url&download=1' : '$url?download=1';
        }
      }

      // URL lainnya return as is
      return url;
    } catch (e) {
      return url;
    }
  }

  // Show photo preview in dialog
  void _showPhotoPreview(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Image preview
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.white,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                _convertToDirectImageUrl(photoUrl),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat gambar',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Periksa kembali URL foto',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validasi tanggal mulai
      if (_tanggalMulai == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal mulai harus diisi'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      // Validasi tanggal selesai tidak boleh lebih awal dari tanggal mulai
      if (_tanggalSelesai != null &&
          _tanggalSelesai!.isBefore(_tanggalMulai!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tanggal selesai tidak boleh lebih awal dari tanggal mulai',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      // Validasi kuota peserta
      final kuota = _kuotaController.text.isEmpty
          ? null
          : int.tryParse(_kuotaController.text);

      if (_kuotaController.text.isNotEmpty && kuota == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kuota peserta harus berupa angka'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      if (kuota != null && kuota <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kuota peserta harus lebih dari 0'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      // Validasi foto URL jika diisi
      if (_fotoUrlController.text.isNotEmpty &&
          !_isValidUrl(_fotoUrlController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL foto tidak valid'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      if (isEditMode) {
        ref
            .read(kegiatanFormProvider.notifier)
            .updateKegiatan(
              id: widget.kegiatan!.id,
              judul: _judulController.text.trim(),
              deskripsi: _deskripsiController.text.trim().isEmpty
                  ? null
                  : _deskripsiController.text.trim(),
              tanggalMulai: _tanggalMulai!,
              tanggalSelesai: _tanggalSelesai,
              lokasi: _lokasiController.text.trim().isEmpty
                  ? null
                  : _lokasiController.text.trim(),
              penyelenggara: _penyelenggaraController.text.trim(),
              kategori: _selectedKategori,
              status: _selectedStatus,
              kuotaPeserta: kuota,
              fotoUrl: _fotoUrlController.text.trim().isEmpty
                  ? null
                  : _fotoUrlController.text.trim(),
            );
      } else {
        ref
            .read(kegiatanFormProvider.notifier)
            .createKegiatan(
              judul: _judulController.text.trim(),
              deskripsi: _deskripsiController.text.trim().isEmpty
                  ? null
                  : _deskripsiController.text.trim(),
              tanggalMulai: _tanggalMulai!,
              tanggalSelesai: _tanggalSelesai,
              lokasi: _lokasiController.text.trim().isEmpty
                  ? null
                  : _lokasiController.text.trim(),
              penyelenggara: _penyelenggaraController.text.trim(),
              kategori: _selectedKategori,
              status: _selectedStatus,
              kuotaPeserta: kuota,
              fotoUrl: _fotoUrlController.text.trim().isEmpty
                  ? null
                  : _fotoUrlController.text.trim(),
            );
      }
    } else {
      // Show validation error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua field yang wajib diisi'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

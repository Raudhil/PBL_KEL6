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

  @override
  Widget build(BuildContext context) {
    ref.listen<KegiatanFormState>(kegiatanFormProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Kegiatan berhasil diupdate'
                  : 'Kegiatan berhasil ditambahkan',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
        // Refresh list
        ref.read(kegiatanListProvider.notifier).loadKegiatan();
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
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditMode ? 'Edit Kegiatan' : 'Tambah Kegiatan',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Judul
            _buildSectionTitle('Informasi Dasar'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _judulController,
              label: 'Judul Kegiatan',
              hint: 'Masukkan judul kegiatan',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Deskripsi
            _buildTextField(
              controller: _deskripsiController,
              label: 'Deskripsi',
              hint: 'Masukkan deskripsi kegiatan',
              icon: Icons.description,
              maxLines: 4,
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

            const SizedBox(height: 24),

            // Waktu dan Tempat
            _buildSectionTitle('Waktu & Tempat'),
            const SizedBox(height: 12),

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
            ),

            const SizedBox(height: 24),

            // Penyelenggara & Peserta
            _buildSectionTitle('Penyelenggara & Peserta'),
            const SizedBox(height: 12),

            // Penyelenggara
            _buildTextField(
              controller: _penyelenggaraController,
              label: 'Penyelenggara',
              hint: 'Masukkan nama penyelenggara',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Penyelenggara tidak boleh kosong';
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
            ),

            const SizedBox(height: 24),

            // Foto URL dengan preview dan validation
            _buildSectionTitle('Foto Kegiatan'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _fotoUrlController,
              decoration: InputDecoration(
                labelText: 'URL Foto (Opsional)',
                hintText: 'https://example.com/image.jpg',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.image_rounded,
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
                          _showPhotoPreview(context, _fotoUrlController.text);
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.greyLight),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              validator: (value) {
                if (value != null && value.isNotEmpty && !_isValidUrl(value)) {
                  return 'URL tidak valid. Contoh: https://example.com/image.jpg';
                }
                return null;
              },
              onChanged: (value) {
                // Rebuild untuk update suffix icon
                setState(() {});
              },
            ),

            // Helper text untuk URL
            if (_fotoUrlController.text.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 16),
                child: Text(
                  'Format yang didukung: .jpg, .jpeg, .png, .webp',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ),

            // Preview mini jika URL valid
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
                        _fotoUrlController.text,
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
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
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

            const SizedBox(height: 40),

            // Submit button
            SizedBox(
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
                    : Text(
                        isEditMode ? 'Update Kegiatan' : 'Tambah Kegiatan',
                        style: const TextStyle(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.greyLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            dropdownColor: AppColors.white,
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(getLabel(item)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.greyLight),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null ? _formatDate(value) : 'Pilih tanggal',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
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

  // Helper method untuk validasi URL
  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }

      // Check if URL ends with image extension
      final path = uri.path.toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
      return validExtensions.any((ext) => path.endsWith(ext));
    } catch (e) {
      return false;
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
                photoUrl,
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
      if (_tanggalMulai == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal mulai harus diisi'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      final kuota = _kuotaController.text.isEmpty
          ? null
          : int.tryParse(_kuotaController.text);

      if (isEditMode) {
        ref
            .read(kegiatanFormProvider.notifier)
            .updateKegiatan(
              id: widget.kegiatan!.id,
              judul: _judulController.text,
              deskripsi: _deskripsiController.text.isEmpty
                  ? null
                  : _deskripsiController.text,
              tanggalMulai: _tanggalMulai,
              tanggalSelesai: _tanggalSelesai,
              lokasi: _lokasiController.text.isEmpty
                  ? null
                  : _lokasiController.text,
              penyelenggara: _penyelenggaraController.text,
              kategori: _selectedKategori,
              status: _selectedStatus,
              kuotaPeserta: kuota,
              fotoUrl: _fotoUrlController.text.isEmpty
                  ? null
                  : _fotoUrlController.text,
            );
      } else {
        ref
            .read(kegiatanFormProvider.notifier)
            .createKegiatan(
              judul: _judulController.text,
              deskripsi: _deskripsiController.text.isEmpty
                  ? null
                  : _deskripsiController.text,
              tanggalMulai: _tanggalMulai!,
              tanggalSelesai: _tanggalSelesai,
              lokasi: _lokasiController.text.isEmpty
                  ? null
                  : _lokasiController.text,
              penyelenggara: _penyelenggaraController.text,
              kategori: _selectedKategori,
              status: _selectedStatus,
              kuotaPeserta: kuota,
              fotoUrl: _fotoUrlController.text.isEmpty
                  ? null
                  : _fotoUrlController.text,
            );
      }
    }
  }
}

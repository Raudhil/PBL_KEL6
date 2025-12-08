import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/kk_model.dart';
import '../../../data/models/warga_model.dart';
import '../../../core/services/kk_service.dart';
import '../../../core/providers/warga_provider.dart';

class CreateWargaPage extends ConsumerStatefulWidget {
  const CreateWargaPage({super.key});

  @override
  ConsumerState<CreateWargaPage> createState() => _CreateWargaPageState();
}

class _CreateWargaPageState extends ConsumerState<CreateWargaPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _noKkController = TextEditingController();

  // Selected values
  String? _selectedRt;
  String? _selectedRw;
  String? _selectedJenisKelamin;
  DateTime? _selectedTanggalLahir;
  String? _selectedPekerjaan;
  String? _selectedStatusPerkawinan;
  String? _selectedPendidikan;
  String? _selectedPeranKeluarga;

  // KK Options
  String _kkOption = 'existing'; // 'existing' or 'new'
  String? _selectedKkExisting;
  List<KKModel> _kkList = [];
  bool _isLoadingKK = true;
  final _kkService = KKService();
  int? _selectedKkId;

  // NIK Validation
  bool _isCheckingNik = false;
  bool _nikExists = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadKKList();
    _nikController.addListener(_onNikChanged);
  }

  Future<void> _loadKKList() async {
    try {
      final kkList = await _kkService.fetchAllKK();
      setState(() {
        _kkList = kkList;
        _isLoadingKK = false;
      });
    } catch (e) {
      print('Error loading KK: $e');
      setState(() {
        _isLoadingKK = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar KK: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nikController.dispose();
    _namaController.dispose();
    _nomorHpController.dispose();
    _alamatController.dispose();
    _tempatLahirController.dispose();
    _noKkController.dispose();
    super.dispose();
  }

  void _onNikChanged() {
    final nik = _nikController.text;
    _debounceTimer?.cancel();

    if (nik.isEmpty || nik.length != 16) {
      setState(() {
        _nikExists = false;
        _isCheckingNik = false;
      });
      return;
    }

    setState(() {
      _isCheckingNik = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _checkNikExists(nik);
    });
  }

  Future<void> _checkNikExists(String nik) async {
    try {
      final exists = await ref
          .read(wargaRepositoryProvider)
          .checkNikExists(nik);
      if (mounted) {
        setState(() {
          _nikExists = exists;
          _isCheckingNik = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingNik = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTanggalLahir) {
      setState(() {
        _selectedTanggalLahir = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        int kkId;

        // Handle KK creation if option is 'new'
        if (_kkOption == 'new') {
          final nomorKK = _noKkController.text.trim();
          final alamat = _alamatController.text.trim();

          // Create new KK
          final newKK = await _kkService.createKK(
            nomorKK: nomorKK,
            alamat: alamat,
            idRt: 1, // Default RT 1
          );
          kkId = newKK.id;
        } else {
          // Use existing KK
          if (_selectedKkId == null) {
            throw Exception('KK harus dipilih');
          }
          kkId = _selectedKkId!;
        }

        // Create warga model
        final newWarga = WargaModel(
          id: 0, // Will be auto-generated by database
          idKk: kkId,
          nik: _nikController.text.trim(),
          namaLengkap: _namaController.text.trim(),
          jenisKelamin: _selectedJenisKelamin!,
          tanggalLahir: _selectedTanggalLahir!,
          nomorHp: _nomorHpController.text.trim().isEmpty
              ? null
              : _nomorHpController.text.trim(),
          fotoKtp: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save to database
        await ref.read(wargaRepositoryProvider).addWarga(newWarga);

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          // Refresh warga list
          ref.invalidate(wargaNotifierProvider);

          // Show success modal
          _showSuccessDialog(
            'Warga Berhasil Ditambahkan',
            _kkOption == 'new'
                ? 'Data warga dengan KK baru telah disimpan'
                : 'Data warga telah ditambahkan ke KK existing',
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  void _showSuccessDialog(String title, String message) {
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
            padding: const EdgeInsets.all(32),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Close form page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tambah Warga Baru',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Data Identitas
              _buildSectionTitle('Data Identitas', Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildCard([
                // Custom NIK field with validation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.credit_card,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'NIK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nikController,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: 'Masukkan 16 digit NIK',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _nikExists
                                ? AppColors.danger
                                : Colors.grey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _nikExists
                                ? AppColors.danger
                                : AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.danger,
                            width: 1,
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
                          vertical: 14,
                        ),
                        counterText: '',
                        suffixIcon: _nikController.text.length == 16
                            ? _isCheckingNik
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      _nikExists
                                          ? Icons.error
                                          : Icons.check_circle,
                                      color: _nikExists
                                          ? AppColors.danger
                                          : AppColors.success,
                                    )
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'NIK tidak boleh kosong';
                        }
                        if (value.length != 16) {
                          return 'NIK harus 16 digit';
                        }
                        if (_nikExists) {
                          return 'NIK sudah terdaftar di database';
                        }
                        return null;
                      },
                    ),
                    if (_nikExists && _nikController.text.length == 16)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 8),
                        child: Text(
                          'NIK sudah terdaftar di database',
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama lengkap tidak boleh kosong';
                    }
                    if (value.length < 3) {
                      return 'Nama minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Jenis Kelamin',
                  hint: 'Pilih jenis kelamin',
                  icon: Icons.wc,
                  value: _selectedJenisKelamin,
                  items: ['Laki-laki', 'Perempuan'],
                  onChanged: (value) {
                    setState(() {
                      _selectedJenisKelamin = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jenis kelamin harus dipilih';
                    }
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // Section: Data Kelahiran
              _buildSectionTitle('Data Kelahiran', Icons.cake_outlined),
              const SizedBox(height: 16),
              _buildCard([
                _buildTextField(
                  controller: _tempatLahirController,
                  label: 'Tempat Lahir',
                  hint: 'Masukkan tempat lahir',
                  icon: Icons.location_city_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tempat lahir tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDatePicker(
                  label: 'Tanggal Lahir',
                  hint: 'Pilih tanggal lahir',
                  icon: Icons.calendar_today,
                  value: _selectedTanggalLahir,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (_selectedTanggalLahir == null) {
                      return 'Tanggal lahir harus dipilih';
                    }
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // Section: Data Keluarga
              _buildSectionTitle('Data Keluarga', Icons.home_outlined),
              const SizedBox(height: 16),

              // KK Option Toggle
              _buildCard([
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _kkOption = 'existing';
                            });
                          },
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _kkOption == 'existing'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.family_restroom,
                                  size: 18,
                                  color: _kkOption == 'existing'
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Masuk KK Existing',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _kkOption == 'existing'
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _kkOption = 'new';
                            });
                          },
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _kkOption == 'new'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_home,
                                  size: 18,
                                  color: _kkOption == 'new'
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Buat KK Baru',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _kkOption == 'new'
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // Conditional Fields based on KK Option
              if (_kkOption == 'existing') ...[
                _buildCard([
                  _isLoadingKK
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _kkList.isEmpty
                      ? Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.warning.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Belum Ada KK Tersedia',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Silakan buat KK baru untuk melanjutkan',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _kkOption = 'new';
                                  });
                                },
                                icon: const Icon(Icons.add_home),
                                label: const Text('Buat KK Baru'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _buildDropdown(
                          label: 'Pilih Kartu Keluarga',
                          hint: 'Pilih KK yang sudah ada',
                          icon: Icons.family_restroom_outlined,
                          value: _selectedKkExisting,
                          items: _kkList
                              .map(
                                (kk) =>
                                    '${kk.nomor} - ${kk.alamat ?? 'Alamat tidak tersedia'}',
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKkExisting = value;
                              // Find the selected KK ID
                              final selectedKK = _kkList.firstWhere(
                                (kk) =>
                                    '${kk.nomor} - ${kk.alamat ?? 'Alamat tidak tersedia'}' ==
                                    value,
                              );
                              _selectedKkId = selectedKK.id;
                            });
                          },
                          validator: (value) {
                            if (_kkOption == 'existing' &&
                                (value == null || value.isEmpty)) {
                              return 'KK harus dipilih';
                            }
                            return null;
                          },
                        ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Peran di Keluarga',
                    hint: 'Pilih peran di keluarga',
                    icon: Icons.people_outline,
                    value: _selectedPeranKeluarga,
                    items: [
                      'Kepala Keluarga',
                      'Istri',
                      'Anak',
                      'Orang Tua',
                      'Mertua',
                      'Menantu',
                      'Cucu',
                      'Famili Lain',
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPeranKeluarga = value;
                      });
                    },
                    validator: (value) {
                      if (_kkOption == 'existing' &&
                          (value == null || value.isEmpty)) {
                        return 'Peran di keluarga harus dipilih';
                      }
                      return null;
                    },
                  ),
                ]),
              ] else ...[
                _buildCard([
                  _buildTextField(
                    controller: _noKkController,
                    label: 'Nomor KK Baru',
                    hint: 'Masukkan 16 digit nomor KK',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (_kkOption == 'new') {
                        if (value == null || value.isEmpty) {
                          return 'Nomor KK tidak boleh kosong';
                        }
                        if (value.length != 16) {
                          return 'Nomor KK harus 16 digit';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _alamatController,
                    label: 'Alamat Lengkap',
                    hint: 'Masukkan alamat lengkap',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (_kkOption == 'new') {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'RT',
                          hint: 'Pilih RT',
                          icon: Icons.home_work_outlined,
                          value: _selectedRt,
                          items: List.generate(10, (i) => '${i + 1}'),
                          onChanged: (value) {
                            setState(() {
                              _selectedRt = value;
                            });
                          },
                          validator: (value) {
                            if (_kkOption == 'new' &&
                                (value == null || value.isEmpty)) {
                              return 'RT harus dipilih';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: 'RW',
                          hint: 'Pilih RW',
                          icon: Icons.location_city_outlined,
                          value: _selectedRw,
                          items: List.generate(10, (i) => '${i + 1}'),
                          onChanged: (value) {
                            setState(() {
                              _selectedRw = value;
                            });
                          },
                          validator: (value) {
                            if (_kkOption == 'new' &&
                                (value == null || value.isEmpty)) {
                              return 'RW harus dipilih';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Warga ini akan menjadi Kepala Keluarga',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 24),

              // Section: Data Pekerjaan & Pendidikan
              _buildSectionTitle('Pekerjaan & Pendidikan', Icons.work_outline),
              const SizedBox(height: 16),
              _buildCard([
                _buildDropdown(
                  label: 'Pekerjaan',
                  hint: 'Pilih pekerjaan',
                  icon: Icons.business_center_outlined,
                  value: _selectedPekerjaan,
                  items: [
                    'Belum Bekerja',
                    'Pelajar/Mahasiswa',
                    'Karyawan Swasta',
                    'PNS',
                    'Wiraswasta',
                    'Lainnya',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPekerjaan = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pekerjaan harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Pendidikan Terakhir',
                  hint: 'Pilih pendidikan terakhir',
                  icon: Icons.school_outlined,
                  value: _selectedPendidikan,
                  items: [
                    'Tidak Sekolah',
                    'SD',
                    'SMP',
                    'SMA/SMK',
                    'D3',
                    'S1',
                    'S2',
                    'S3',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPendidikan = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pendidikan harus dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Status Perkawinan',
                  hint: 'Pilih status perkawinan',
                  icon: Icons.favorite_outline,
                  value: _selectedStatusPerkawinan,
                  items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatusPerkawinan = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Status perkawinan harus dipilih';
                    }
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 24),

              // Section: Kontak (Optional)
              _buildSectionTitle('Kontak (Opsional)', Icons.phone_outlined),
              const SizedBox(height: 16),
              _buildCard([
                _buildTextField(
                  controller: _nomorHpController,
                  label: 'Nomor HP',
                  hint: 'Masukkan nomor HP (opsional)',
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                  maxLength: 15,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 10) {
                        return 'Nomor HP minimal 10 digit';
                      }
                    }
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Simpan Data Warga',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterText: '',
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            isDense: true,
          ),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return items.map((String item) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          onChanged: onChanged,
          validator: validator,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String hint,
    required IconData icon,
    required DateTime? value,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            child: Text(
              value != null ? _formatDate(value) : hint,
              style: TextStyle(
                color: value != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ),
        ),
        if (validator != null && _selectedTanggalLahir == null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              validator(null) ?? '',
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

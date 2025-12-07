import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_colors.dart';

class CreateWargaPage extends StatefulWidget {
  const CreateWargaPage({super.key});

  @override
  State<CreateWargaPage> createState() => _CreateWargaPageState();
}

class _CreateWargaPageState extends State<CreateWargaPage> {
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

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _nomorHpController.dispose();
    _alamatController.dispose();
    _tempatLahirController.dispose();
    _noKkController.dispose();
    super.dispose();
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Implement save to database
      // For now, just show success message
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data warga berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      });
    }
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
                _buildTextField(
                  controller: _nikController,
                  label: 'NIK',
                  hint: 'Masukkan 16 digit NIK',
                  icon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIK tidak boleh kosong';
                    }
                    if (value.length != 16) {
                      return 'NIK harus 16 digit';
                    }
                    return null;
                  },
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
              _buildCard([
                _buildTextField(
                  controller: _noKkController,
                  label: 'Nomor KK',
                  hint: 'Masukkan 16 digit nomor KK',
                  icon: Icons.family_restroom_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor KK tidak boleh kosong';
                    }
                    if (value.length != 16) {
                      return 'Nomor KK harus 16 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _alamatController,
                  label: 'Alamat',
                  hint: 'Masukkan alamat lengkap',
                  icon: Icons.location_on_outlined,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat tidak boleh kosong';
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
                          if (value == null || value.isEmpty) {
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
                          if (value == null || value.isEmpty) {
                            return 'RW harus dipilih';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ]),
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
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
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

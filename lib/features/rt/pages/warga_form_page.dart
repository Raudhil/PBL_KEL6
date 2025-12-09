import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/warga_model.dart';
import '../../../core/providers/warga_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../core/widgets/custom_top_bar.dart';

class WargaFormPage extends ConsumerStatefulWidget {
  final WargaModel? warga;
  const WargaFormPage({super.key, this.warga});

  @override
  ConsumerState<WargaFormPage> createState() => _WargaFormPageState();
}

class _WargaFormPageState extends ConsumerState<WargaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nikCtrl;
  late TextEditingController _namaCtrl;
  late String _jenisKel;
  late TextEditingController _tglCtrl;
  late TextEditingController _hpCtrl;
  bool _isSubmitting = false;
  bool _isCheckingNik = false;
  bool _nikExists = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final w = widget.warga;
    _nikCtrl = TextEditingController(text: w?.nik ?? '');
    _namaCtrl = TextEditingController(text: w?.namaLengkap ?? '');
    _jenisKel = w?.jenisKelamin ?? 'Laki-laki';
    _tglCtrl = TextEditingController(
      text: w?.tanggalLahir.toIso8601String().split('T').first ?? '2000-01-01',
    );
    _hpCtrl = TextEditingController(text: w?.nomorHp ?? '');

    // Add listener to check NIK in real-time
    _nikCtrl.addListener(_onNikChanged);
  }

  void _onNikChanged() {
    final nik = _nikCtrl.text.trim();

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Only check if NIK is 16 digits
    if (nik.length != 16) {
      setState(() {
        _nikExists = false;
        _isCheckingNik = false;
      });
      return;
    }

    // Set loading state
    setState(() {
      _isCheckingNik = true;
      _nikExists = false;
    });

    // Debounce: wait 500ms before checking
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _checkNikExists(nik);
    });
  }

  Future<void> _checkNikExists(String nik) async {
    try {
      final exists = await ref
          .read(wargaRepositoryProvider)
          .checkNikExists(nik, excludeId: widget.warga?.id);

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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nikCtrl.removeListener(_onNikChanged);
    _nikCtrl.dispose();
    _namaCtrl.dispose();
    _tglCtrl.dispose();
    _hpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nikExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIK sudah terdaftar. Gunakan NIK yang berbeda.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final idKk = widget.warga?.idKk ?? 1; // default KK id; adjust as needed
      final tanggal = DateTime.parse(_tglCtrl.text);
      if (widget.warga == null) {
        final newWarga = WargaModel(
          id: 0,
          idKk: idKk,
          nik: _nikCtrl.text.trim(),
          namaLengkap: _namaCtrl.text.trim(),
          jenisKelamin: _jenisKel,
          tanggalLahir: tanggal,
          nomorHp: _hpCtrl.text.trim(),
          fotoKtp: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref.read(wargaNotifierProvider.notifier).addWarga(newWarga);

        if (mounted) {
          _showSuccessDialog(
            'Warga Berhasil Ditambahkan',
            'Data warga baru telah berhasil ditambahkan',
          );
        }
      } else {
        final updated = WargaModel(
          id: widget.warga!.id,
          idKk: widget.warga!.idKk,
          nik: _nikCtrl.text.trim(),
          namaLengkap: _namaCtrl.text.trim(),
          jenisKelamin: _jenisKel,
          tanggalLahir: tanggal,
          nomorHp: _hpCtrl.text.trim(),
          fotoKtp: widget.warga!.fotoKtp,
          createdAt: widget.warga!.createdAt,
          updatedAt: DateTime.now(),
        );
        await ref.read(wargaNotifierProvider.notifier).updateWarga(updated);

        if (mounted) {
          _showSuccessDialog(
            'Warga Berhasil Diperbarui',
            'Data warga telah berhasil diperbarui',
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
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
                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close form page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
    final isEdit = widget.warga != null;

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: CustomTopBar(
        title: isEdit ? 'Edit Warga' : 'Tambah Warga',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('NIK'),
              TextFormField(
                controller: _nikCtrl,
                decoration: InputDecoration(
                  hintText: 'Masukkan NIK',
                  suffixIcon: _isCheckingNik
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _nikExists
                      ? const Icon(Icons.error_outline, color: AppColors.danger)
                      : _nikCtrl.text.length == 16
                      ? const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'NIK wajib diisi';
                  if (v.trim().length != 16) return 'NIK harus 16 digit';
                  if (_nikExists) return 'NIK sudah terdaftar di database';
                  return null;
                },
              ),
              if (_nikExists)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'NIK sudah terdaftar di database',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              _buildLabel('Nama Lengkap'),
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(hintText: 'Nama lengkap'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              _buildLabel('Jenis Kelamin'),
              DropdownButtonFormField<String>(
                value: _jenisKel,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(
                    value: 'Laki-laki',
                    child: Text('Laki-laki'),
                  ),
                  DropdownMenuItem(
                    value: 'Perempuan',
                    child: Text('Perempuan'),
                  ),
                ],
                onChanged: (v) => setState(() => _jenisKel = v ?? 'Laki-laki'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Jenis kelamin wajib' : null,
              ),
              const SizedBox(height: 12),
              _buildLabel('Tanggal Lahir'),
              TextFormField(
                controller: _tglCtrl,
                decoration: const InputDecoration(hintText: 'YYYY-MM-DD'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Tanggal lahir wajib';
                  try {
                    DateTime.parse(v.trim());
                    return null;
                  } catch (_) {
                    return 'Format tanggal tidak valid';
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildLabel('Nomor HP'),
              TextFormField(
                controller: _hpCtrl,
                decoration: const InputDecoration(hintText: '08xxxxxxxx'),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final t = v.trim();
                  if (!RegExp(r'^08[0-9]{7,12}$').hasMatch(t))
                    return 'Nomor HP tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? 'Update' : 'Simpan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

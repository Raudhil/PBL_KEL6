import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/data/models/keuangan_model.dart';
import 'package:jawara/features/bendahara/controllers/keuangan_controller.dart';
import 'package:jawara/core/services/profil_service.dart';
import 'package:jawara/core/widgets/custom_top_bar.dart';
import 'package:jawara/theme/app_colors.dart';

class PemasukanFormPage extends ConsumerStatefulWidget {
  const PemasukanFormPage({super.key});

  @override
  ConsumerState<PemasukanFormPage> createState() => _PemasukanFormPageState();
}

class _PemasukanFormPageState extends ConsumerState<PemasukanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '').replaceAll('.', '')) ?? 0.0;
    final note = _noteController.text.trim();
    final createdAt = _selectedDate ?? DateTime.now();

    final tx = KeuanganModel(
      title: title.isEmpty ? 'Pemasukan' : title,
      amount: amount.abs(),
      type: 'Pemasukan',
      note: note.isEmpty ? null : note,
      createdAt: createdAt,
    );

    int? idRt;
    try {
      final profilService = ProfilService();
      final full = await profilService.getFullUserData();
      final rt = full['rt'];
      if (rt is Map && rt.containsKey('id')) {
        idRt = rt['id'] as int?;
      }
    } catch (_) {
    }

    try {
      await ref.read(keuanganControllerProvider.notifier).addTransaction(tx, idRt: idRt);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pemasukan berhasil ditambahkan')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomTopBar(title: 'Tambah Pemasukan', showBackButton: true, actions: [],),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel('Judul'),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Contoh: Sumbangan',
                  hintStyle: TextStyle(color: AppColors.textPrimary),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              _buildLabel('Nominal'),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Contoh: 50000',
                  hintStyle: TextStyle(color: AppColors.textPrimary),
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(color: AppColors.textPrimary),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Masukkan jumlah';
                  final parsed = double.tryParse(v.replaceAll(',', '').replaceAll('.', ''));
                  if (parsed == null) return 'Jumlah tidak valid';
                  if (parsed <= 0) return 'Jumlah harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _buildLabel('Keterangan'),
              TextFormField(
                controller: _noteController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Contoh: Sumbangan dari warga',
                  hintStyle: TextStyle(color: AppColors.textPrimary),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                // optional
                validator: (v) => null,
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                child: _isSubmitting ? SizedBox(
                  width: double.infinity, 
                  height: 50, 
                  child: Center(child: CircularProgressIndicator(color: Colors.white))) 
                  : const Text('Simpan Pemasukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              )
              
            ],
          ),
        ),
      ),
    );
  }
}

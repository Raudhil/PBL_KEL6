import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jawara/data/models/keuangan_model.dart';
import 'package:jawara/features/bendahara/controllers/keuangan_controller.dart';
import 'package:jawara/core/services/profil_service.dart';
import 'package:jawara/core/widgets/custom_top_bar.dart';
import 'package:jawara/theme/app_colors.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  final KeuanganModel? transaction;

  const TransactionFormPage({super.key, this.transaction});

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize based on edit or create mode
    if (widget.transaction != null) {
      // Edit mode - load existing data
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toStringAsFixed(0);
      _noteController.text = widget.transaction!.note ?? '';
      _selectedDate = widget.transaction!.createdAt ?? DateTime.now();

      // Set tab index based on type
      final type = widget.transaction!.type?.trim().toLowerCase();
      _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: type == 'pemasukan' ? 0 : 1,
      );
    } else {
      // Create mode
      _tabController = TabController(length: 2, vsync: this);
      _selectedDate = DateTime.now();
    }

    initializeDateFormatting('id_ID', null);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _transactionType =>
      _tabController.index == 0 ? 'Pemasukan' : 'Pengeluaran';
  String get _appBarTitle =>
      widget.transaction != null ? 'Edit Transaksi' : 'Tambah Transaksi Baru';
  Color get _primaryColor =>
      _tabController.index == 0 ? AppColors.primary : const Color(0xFFDC2626);

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: AppColors.textPrimary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.danger, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    // Pastikan note adalah null jika kosong, bukan string kosong
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    try {
      if (widget.transaction != null) {
        // Edit mode - update transaction
        final updatedTx = widget.transaction!.copyWith(
          title: title,
          amount: amount,
          note: note, // Ini bisa null
          type: _transactionType,
          createdAt: _selectedDate,
        );

        await ref
            .read(keuanganControllerProvider.notifier)
            .updateTransaction(widget.transaction!.id!, updatedTx);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Transaksi berhasil diperbarui'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Create mode - add new transaction
        final newTx = KeuanganModel(
          title: title,
          amount: amount,
          note: note,
          type: _transactionType,
          createdAt: _selectedDate,
        );

        await ref
            .read(keuanganControllerProvider.notifier)
            .addTransaction(newTx);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Transaksi berhasil ditambahkan'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Gagal: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomTopBar(
        title: 'Buat $_appBarTitle',
        showBackButton: true,
        actions: [],
      ),
      body: Column(
        children: [
          // Tab Bar - Modern & Besar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(0);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _tabController.index == 0
                            ? AppColors.primary
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Pemasukan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _tabController.index == 0
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _tabController.index == 1
                            ? const Color(0xFFDC2626)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Pengeluaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _tabController.index == 1
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card wrapper untuk form
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Judul
                            _buildLabel('Judul Transaksi'),
                            _buildTextField(
                              controller: _titleController,
                              hintText: _tabController.index == 0
                                  ? 'Contoh: Sumbangan warga'
                                  : 'Contoh: Pembelian perlengkapan',
                              validator: (v) =>
                                  v!.isEmpty ? 'Judul wajib diisi' : null,
                            ),
                            const SizedBox(height: 18),

                            // Nominal
                            _buildLabel('Nominal'),
                            _buildTextField(
                              controller: _amountController,
                              hintText: 'Masukkan jumlah nominal',
                              prefixText: 'Rp ',
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Nominal wajib diisi';
                                }
                                final parsed = double.tryParse(
                                  v.replaceAll(',', '').replaceAll('.', ''),
                                );
                                if (parsed == null) {
                                  return 'Format nominal tidak valid';
                                }
                                if (parsed <= 0) {
                                  return 'Nominal harus lebih dari 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Tanggal
                            _buildLabel('Tanggal Transaksi'),
                            GestureDetector(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                      color: _primaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedDate != null
                                            ? DateFormat(
                                                'dd MMM yyyy',
                                                'id_ID',
                                              ).format(_selectedDate!)
                                            : 'Pilih tanggal transaksi',
                                        style: TextStyle(
                                          color: _selectedDate != null
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: _primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Keterangan
                            _buildLabel('Keterangan (Opsional)'),
                            _buildTextField(
                              controller: _noteController,
                              hintText: _tabController.index == 0
                                  ? 'Contoh: Sumbangan dari ibu Siti'
                                  : 'Contoh: Konsumsi acara minggu depan',
                              validator: (v) => null,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: _primaryColor
                                      .withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 3,
                                  shadowColor: _primaryColor.withOpacity(0.4),
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Colors.white),
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : Text(
                                        'Simpan $_transactionType',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

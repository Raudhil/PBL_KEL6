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
  const TransactionFormPage({super.key});

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
    _tabController = TabController(length: 2, vsync: this);
    _selectedDate = DateTime.now();

    // Initialize locale data untuk DateFormat
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
  String get _appBarTitle => _transactionType;
  Color get _primaryColor =>
      _tabController.index == 0 ? AppColors.success : AppColors.danger;

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
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
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
    final amount =
        double.tryParse(
          _amountController.text.replaceAll(',', '').replaceAll('.', ''),
        ) ??
        0.0;
    final note = _noteController.text.trim();
    final createdAt = _selectedDate ?? DateTime.now();

    final tx = KeuanganModel(
      title: title.isEmpty ? _transactionType : title,
      amount: amount.abs(),
      type: _transactionType,
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
    } catch (_) {}

    try {
      await ref
          .read(keuanganControllerProvider.notifier)
          .addTransaction(tx, idRt: idRt);

      // Refresh data setelah transaksi ditambahkan
      await ref.read(keuanganControllerProvider.notifier).fetchTransactions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_transactionType berhasil ditambahkan'),
            backgroundColor: _primaryColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (index) => setState(() {}),
              labelColor: _tabController.index == 0
                  ? AppColors.success
                  : AppColors.danger,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: _tabController.index == 0
                  ? AppColors.success
                  : AppColors.danger,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_card_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text('Pemasukan'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text('Pengeluaran'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Judul
                      _buildLabel('Judul'),
                      _buildTextField(
                        controller: _titleController,
                        hintText: _tabController.index == 0
                            ? 'Contoh: Sumbangan warga'
                            : 'Contoh: Pembelian perlengkapan',
                        validator: (v) =>
                            v!.isEmpty ? 'Judul wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),

                      // Nominal
                      _buildLabel('Nominal'),
                      _buildTextField(
                        controller: _amountController,
                        hintText: 'Contoh: 100000',
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
                      const SizedBox(height: 16),

                      // Tanggal
                      _buildLabel('Tanggal'),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
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
                                      : 'Pilih tanggal',
                                  style: TextStyle(
                                    color: _selectedDate != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: _primaryColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 28),

                      // Submit Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _primaryColor.withOpacity(
                              0.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Simpan $_transactionType',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
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

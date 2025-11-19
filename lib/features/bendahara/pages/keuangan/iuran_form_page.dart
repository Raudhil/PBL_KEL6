import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../controllers/iuran_controllers.dart';
import '../../../../data/models/iuran_model.dart';

class IuranFormPage extends ConsumerStatefulWidget {
  final IuranModel? iuran;

  const IuranFormPage({super.key, this.iuran});

  @override
  ConsumerState<IuranFormPage> createState() => _IuranFormPageState();
}

class _IuranFormPageState extends ConsumerState<IuranFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _jenisController;
  late TextEditingController _nominalController;
  late TextEditingController _dateController;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _jenisController = TextEditingController(text: widget.iuran?.jenis ?? '');
    _nominalController = TextEditingController(
      text: widget.iuran != null
          ? widget.iuran!.nominal.toStringAsFixed(0)
          : '',
    );
    _selectedDate = widget.iuran?.jatuhTempo;
    _dateController = TextEditingController(
      text: _selectedDate != null
          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
          : '',
    );
  }

  @override
  void dispose() {
    _jenisController.dispose();
    _nominalController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary600),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal jatuh tempo')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newIuran = IuranModel(
        jenis: _jenisController.text,
        nominal: double.parse(_nominalController.text),
        jatuhTempo: _selectedDate!,
      );

      if (widget.iuran == null) {
        // Create
        await ref.read(iuranControllerProvider.notifier).addIuran(newIuran);
      } else {
        // Update
        await ref
            .read(iuranControllerProvider.notifier)
            .updateIuran(widget.iuran!.id!, newIuran);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil menyimpan data'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.iuran != null;

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      // Custom Top Bar khusus halaman Form
      appBar: CustomTopBar(
        title: isEdit ? 'Edit Iuran' : 'Buat Iuran Baru',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Jenis Iuran'),
              TextFormField(
                controller: _jenisController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Iuran Kebersihan November',
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Nominal (Rp)'),
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 50000',
                  prefixText: 'Rp ',
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Jatuh Tempo'),
              InkWell(
                onTap: _pickDate,
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      hintText: 'Pilih Tanggal',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? 'Simpan Perubahan' : 'Buat Tagihan',
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

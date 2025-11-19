import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/warga_model.dart';
import '../../../core/providers/warga_provider.dart';

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
  }

  @override
  void dispose() {
    _nikCtrl.dispose();
    _namaCtrl.dispose();
    _tglCtrl.dispose();
    _hpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
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
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.warga != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Warga' : 'Tambah Warga')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nikCtrl,
                decoration: const InputDecoration(labelText: 'NIK'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'NIK wajib diisi';
                  if (v.trim().length != 16) return 'NIK harus 16 digit';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _jenisKel,
                decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
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
              TextFormField(
                controller: _tglCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir (YYYY-MM-DD)',
                ),
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
              TextFormField(
                controller: _hpCtrl,
                decoration: const InputDecoration(labelText: 'Nomor HP'),
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
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(isEdit ? 'Update' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../data/models/warga_model.dart';

class WargaDetailPage extends StatelessWidget {
  final WargaModel warga;

  const WargaDetailPage({super.key, required this.warga});

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime dt) =>
        dt.toLocal().toIso8601String().split('T').first;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Warga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (warga.fotoKtp != null && warga.fotoKtp!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    warga.fotoKtp!,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 80),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildRow('Nama Lengkap', warga.namaLengkap),
            _buildRow('NIK', warga.nik),
            _buildRow('Jenis Kelamin', warga.jenisKelamin),
            _buildRow('Tanggal Lahir', formatDate(warga.tanggalLahir)),
            _buildRow('Nomor HP', warga.nomorHp ?? '-'),
            _buildRow('ID KK', warga.idKk.toString()),
            _buildRow('Created At', formatDate(warga.createdAt)),
            _buildRow('Updated At', formatDate(warga.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
// Simplified detail page: no provider or routing changes needed
import '../../../data/models/warga_model.dart';
import '../../../theme/app_colors.dart';
import '../../../core/widgets/custom_top_bar.dart';
// no provider import needed for read-only detail view

class WargaDetailPage extends StatelessWidget {
  final WargaModel warga;

  const WargaDetailPage({super.key, required this.warga});

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime dt) =>
        dt.toLocal().toIso8601String().split('T').first;

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(title: 'Detail Warga', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo and basic header
            Center(
              child: Column(
                children: [
                  if (warga.fotoKtp != null && warga.fotoKtp!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        warga.fotoKtp!,
                        height: 160,
                        width: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 80),
                      ),
                    )
                  else
                    Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Info list
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _infoTile(
                    icon: Icons.person_outline,
                    label: 'Nama Lengkap',
                    value: warga.namaLengkap,
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    icon: Icons.credit_card,
                    label: 'NIK',
                    value: warga.nik,
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    icon: Icons.wc,
                    label: 'Jenis Kelamin',
                    value: warga.jenisKelamin,
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    icon: Icons.cake,
                    label: 'Tanggal Lahir',
                    value: formatDate(warga.tanggalLahir),
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    icon: Icons.phone,
                    label: 'Nomor HP',
                    value: warga.nomorHp ?? '-',
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    icon: Icons.group,
                    label: 'ID KK',
                    value: warga.idKk.toString(),
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    icon: Icons.calendar_today,
                    label: 'Created At',
                    value: formatDate(warga.createdAt),
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    icon: Icons.update,
                    label: 'Updated At',
                    value: formatDate(warga.updatedAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _infoTile({
  required IconData icon,
  required String label,
  required String value,
}) {
  return ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text(value, style: const TextStyle(fontSize: 15)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );
}

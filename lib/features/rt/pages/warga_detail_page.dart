import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/warga_model.dart';
import '../../../theme/app_colors.dart';
import '../../../core/widgets/custom_top_bar.dart';
import '../../../core/providers/warga_provider.dart';
import 'edit_warga_page.dart';

class WargaDetailPage extends ConsumerWidget {
  final WargaModel warga;

  const WargaDetailPage({super.key, required this.warga});

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.year}-${months[dt.month - 1].padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String statusText = warga.userStatus ?? 'Tidak Aktif';
    final bool isActive = statusText == 'Aktif';
    final Color statusColor = isActive ? AppColors.success : AppColors.danger;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Warga',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Button Edit - More prominent with outlined style
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditWargaPage(warga: warga),
                  ),
                );

                // Jika edit berhasil, refresh provider dan pop ke list
                if (result == true && context.mounted) {
                  ref.invalidate(wargaNotifierProvider);
                  Navigator.of(context).pop(); // Kembali ke list
                }
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section dengan Avatar dan Status
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama
                  Text(
                    warga.namaLengkap,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Alamat jika ada
                  if (warga.alamat != null && warga.alamat!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              warga.alamat!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Informasi
                  _buildSectionTitle('Informasi'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _InfoItem(
                      label: 'NIK',
                      value: warga.nik,
                      icon: Icons.badge_outlined,
                    ),
                    _InfoItem(
                      label: 'No. KK',
                      value: 'KK${warga.idKk.toString().padLeft(9, '0')}',
                      icon: Icons.family_restroom,
                    ),
                    _InfoItem(
                      label: 'Alamat',
                      value: warga.alamat ?? '-',
                      icon: Icons.home_outlined,
                    ),
                    _InfoItem(
                      label: 'RT/RW',
                      value:
                          'RT 03/RW 05', // TODO: Ambil dari database via join
                      icon: Icons.location_on_outlined,
                    ),
                    _InfoItem(
                      label: 'Tanggal Terdaftar',
                      value: _formatDate(warga.createdAt),
                      icon: Icons.calendar_today,
                    ),
                    _InfoItem(
                      label: 'Peran',
                      value: 'Kepala Keluarga', // TODO: Ambil dari database
                      icon: Icons.person_outline,
                    ),
                    _InfoItem(
                      label: 'Jenis Kelamin',
                      value: warga.jenisKelamin,
                      icon: Icons.wc,
                    ),
                    _InfoItem(
                      label: 'Status Kehidupan',
                      value: 'Hidup', // TODO: Ambil dari database
                      icon: Icons.favorite,
                    ),
                    _InfoItem(
                      label: 'Tempat Lahir',
                      value: 'Kota Contoh', // TODO: Ambil dari database
                      icon: Icons.location_city,
                    ),
                    _InfoItem(
                      label: 'Tanggal Lahir',
                      value: _formatDate(warga.tanggalLahir),
                      icon: Icons.cake,
                      additionalInfo:
                          '${_calculateAge(warga.tanggalLahir)} tahun',
                    ),
                    _InfoItem(
                      label: 'Pekerjaan',
                      value: 'Karyawan', // TODO: Ambil dari database
                      icon: Icons.work,
                    ),
                    _InfoItem(
                      label: 'Status Perkawinan',
                      value: 'Kawin', // TODO: Ambil dari database
                      icon: Icons.favorite_border,
                    ),
                    _InfoItem(
                      label: 'Pendidikan',
                      value: 'SMP', // TODO: Ambil dari database
                      icon: Icons.school,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Section: Kontak (jika ada nomor HP)
                  if (warga.nomorHp != null && warga.nomorHp!.isNotEmpty) ...[
                    _buildSectionTitle('Kontak'),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      _InfoItem(
                        label: 'Nomor HP',
                        value: warga.nomorHp!,
                        icon: Icons.phone,
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final item = items[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (item.additionalInfo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.additionalInfo!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  final String? additionalInfo;

  _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.additionalInfo,
  });
}

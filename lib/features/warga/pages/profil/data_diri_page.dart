import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import 'package:jawara/features/warga/controllers/profil_controller.dart';

class DataDiriPage extends ConsumerWidget {
  const DataDiriPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilControllerProvider);

    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: const CustomTopBar(
          title: 'Data Diri',
          showBackButton: true,
          actions: [],
        ),
        body: Center(child: Text('Error: $e')),
      ),
      data: (profil) {
        final warga = profil.warga;

        String formatDate(DateTime? d) =>
            d == null ? '-' : d.toLocal().toString().split(' ')[0];

        final noKkStr = profil.noKk ?? warga?.idKk.toString() ?? '-';

        return Scaffold(
          backgroundColor: AppColors.creamWhite,
          appBar: const CustomTopBar(
            title: 'Data Diri',
            showBackButton: true,
            actions: [],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card dengan foto profil
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary600, AppColors.primary400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child:
                            profil.fotoProfile != null &&
                                profil.fotoProfile!.isNotEmpty
                            ? CircleAvatar(
                                radius: 45,
                                backgroundImage: NetworkImage(
                                  profil.fotoProfile!,
                                ),
                                backgroundColor: AppColors.white,
                              )
                            : const CircleAvatar(
                                radius: 45,
                                backgroundColor: AppColors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 45,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      // Nama
                      Text(
                        warga?.namaLengkap ?? profil.namaLengkap ?? 'User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      // NIK
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 16,
                              color: AppColors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'NIK: ${warga?.nik ?? '-'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section: Informasi Pribadi
                _buildSectionTitle('Informasi Pribadi'),
                const SizedBox(height: 12),
                _buildModernCard(
                  items: [
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: "Nama Lengkap",
                      value: warga?.namaLengkap ?? profil.namaLengkap ?? '-',
                      iconColor: AppColors.primary,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.cake_outlined,
                      label: "Tanggal Lahir",
                      value: (() {
                        final d = warga?.tanggalLahir;
                        if (d == null) return '-';
                        final local = d.toLocal();
                        final dd = local.day.toString().padLeft(2, '0');
                        final mm = local.month.toString().padLeft(2, '0');
                        final yyyy = local.year.toString();
                        return '$dd-$mm-$yyyy';
                      })(),
                      iconColor: AppColors.primary400,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.wc_outlined,
                      label: "Jenis Kelamin",
                      value: warga?.jenisKelamin ?? '-',
                      iconColor: AppColors.primary600,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: "Nomor HP",
                      value: warga?.nomorHp ?? '-',
                      iconColor: AppColors.primary600,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section: Informasi Keluarga
                _buildSectionTitle('Informasi Keluarga'),
                const SizedBox(height: 12),
                _buildModernCard(
                  items: [
                    _buildInfoRow(
                      icon: Icons.family_restroom_outlined,
                      label: "No. Kartu Keluarga",
                      value: noKkStr,
                      iconColor: AppColors.primary,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section: Alamat
                _buildSectionTitle('Alamat'),
                const SizedBox(height: 12),
                _buildModernCard(
                  items: [
                    _buildInfoRow(
                      icon: Icons.home_outlined,
                      label: "Alamat Lengkap",
                      value: profil.alamat ?? '-',
                      iconColor: AppColors.primary,
                      isMultiline: true,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      label: "RT / RW",
                      value: '${profil.rt ?? '-'} / ${profil.rw ?? '-'}',
                      iconColor: AppColors.primary400,
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper: Section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Helper: Modern card container
  Widget _buildModernCard({required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  // Helper: Info row dengan icon
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: isMultiline ? null : 1,
                  overflow: isMultiline ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Divider
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, thickness: 1, color: AppColors.greyLight),
    );
  }
}

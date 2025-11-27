import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import '../../controllers/profil_controller.dart';
import 'edit_profil_page.dart';
import 'data_diri_page.dart';

class WargaProfilPage extends ConsumerWidget {
  const WargaProfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilState = ref.watch(profilControllerProvider);

    return profilState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text("Error: $e"))),
      data: (profil) {
        final profileImage = profil.fotoProfile ?? "";
        final displayName = profil.namaLengkap ?? profil.email.split('@')[0];

        return Scaffold(
          backgroundColor: AppColors.creamWhite,
          body: CustomScrollView(
            slivers: [
              // Header dengan gradient dan profile
              SliverAppBar(
                expandedHeight: 280,
                pinned: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Gradient background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary600,
                              AppColors.primary400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      // Decorative circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      // Profile content
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // Avatar dengan border gradient
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.white.withOpacity(0.8),
                                    AppColors.white.withOpacity(0.3),
                                  ],
                                ),
                              ),
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: profileImage.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 55,
                                        backgroundImage: NetworkImage(
                                          profileImage,
                                        ),
                                        backgroundColor: AppColors.white,
                                      )
                                    : CircleAvatar(
                                        radius: 55,
                                        backgroundColor: AppColors.white,
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppColors.primary,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Name
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            // Email dengan icon
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 16,
                                    color: AppColors.white.withOpacity(0.9),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    profil.email,
                                    style: TextStyle(
                                      fontSize: 14,
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
                    ],
                  ),
                ),
              ),

              // Menu items
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Section: Akun
                    _buildSectionTitle('Akun'),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profil',
                      subtitle: 'Ubah password dan foto profil',
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                      iconColor: AppColors.primary,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) => const EditAkunProfilPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.person_outline,
                      title: 'Data Diri',
                      subtitle: 'Lihat informasi pribadi Anda',
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary400.withOpacity(0.1),
                          AppColors.primary400.withOpacity(0.05),
                        ],
                      ),
                      iconColor: AppColors.primary400,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) => const DataDiriPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Section: Lainnya
                    _buildSectionTitle('Lainnya'),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.logout_outlined,
                      title: 'Keluar',
                      subtitle: 'Logout dari akun Anda',
                      gradient: LinearGradient(
                        colors: [
                          AppColors.danger.withOpacity(0.1),
                          AppColors.danger.withOpacity(0.05),
                        ],
                      ),
                      iconColor: AppColors.danger,
                      onTap: () async {
                        final confirmed = await _showLogoutDialog(context);
                        if (confirmed == true && context.mounted) {
                          await ref.read(authProvider.notifier).signOut();
                          ref.invalidate(profilControllerProvider);
                        }
                      },
                    ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
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

  // Helper: Menu card dengan gradient
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greyLight, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon dengan background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper: Logout confirmation dialog
  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_outlined,
                color: AppColors.danger,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keluar dari Akun?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.greyLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.danger,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Keluar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

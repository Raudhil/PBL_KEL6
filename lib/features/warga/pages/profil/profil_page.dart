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
              // Header dengan gradient dan profile - CENTERED
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
                      // Profile content - CENTERED
                      SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 5),
                              // Avatar dengan border gradient - CENTERED & BIGGER & CLICKABLE
                              GestureDetector(
                                onTap: profileImage.isNotEmpty
                                    ? () => _showPhotoPreview(
                                        context,
                                        profileImage,
                                      )
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.white.withOpacity(0.9),
                                        AppColors.white.withOpacity(0.4),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 25,
                                        offset: const Offset(0, 12),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: profileImage.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 70,
                                            backgroundImage: NetworkImage(
                                              profileImage,
                                            ),
                                            backgroundColor: AppColors.white,
                                          )
                                        : CircleAvatar(
                                            radius: 70,
                                            backgroundColor: AppColors.white,
                                            child: Icon(
                                              Icons.person,
                                              size: 65,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Name - CENTERED
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
                              // Email dengan icon - CENTERED
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
                                        color: AppColors.white.withOpacity(
                                          0.95,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white],
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
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white],
                      ),
                      iconColor: AppColors.primary,
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
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white],
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

  // Helper: Menu card - STRONG & TEGAS
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.greyLight.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Icon - Clean Modern
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.75),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary.withOpacity(0.5),
                    size: 22,
                  ),
                ],
              ),
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

  // Helper: Show photo preview in modal
  static void _showPhotoPreview(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                iconSize: 28,
                color: AppColors.textPrimary,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text("Error: $e")),
      ),
      data: (profil) {
        final profileImage = profil.fotoProfile ?? "";
        final displayName = profil.namaLengkap ?? profil.email.split('@')[0];
        const double profileRadius = 60;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              // Background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 220,
                  color: AppColors.primary,
                ),
              ),

              // Card
              Positioned(
                top: 180,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: profileRadius + 20),
                        // Nama
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email
                        Text(
                          profil.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Menu
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Edit Password dan Profil',
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (_) => const EditAkunProfilPage(),
                              ),
                            );
                          },

                        ),
                        _MenuItem(
                          icon: Icons.person_outline,
                          title: 'Data Diri',
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                  builder: (_) => const DataDiriPage()),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.logout_outlined,
                          title: 'Log Out',
                          menuColor: AppColors.danger,
                          trailingColor: AppColors.danger,
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.white,
                                title: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.directions_run,
                                      color: AppColors.primary,
                                      size: 50,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                                content: const Text(
                                  'Apakah Anda yakin ingin keluar dari aplikasi?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                                actionsPadding: const EdgeInsets.only(bottom: 10),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.textSecondary,
                                        ),
                                        child: const Text('Batal'),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: AppColors.white,
                                          backgroundColor: AppColors.primary,
                                        ),
                                        child: const Text('Logout'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );

                            if (confirmed == true && context.mounted) {
                              await ref.read(authProvider.notifier).signOut();
                              ref.invalidate(profilControllerProvider);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Avatar
              Positioned(
                top: 100,
                left: MediaQuery.of(context).size.width / 2 - profileRadius,
                child: Container(
                  width: profileRadius * 2,
                  height: profileRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: profileImage.isNotEmpty
                      ? CircleAvatar(
                          radius: profileRadius,
                          backgroundImage: NetworkImage(profileImage),
                        )
                      : CircleAvatar(
                          radius: profileRadius,
                          backgroundColor: AppColors.primary.withAlpha(26),
                          child: Icon(
                            Icons.person,
                            size: profileRadius,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color menuColor;
  final Color trailingColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.menuColor = AppColors.textPrimary,
    this.trailingColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: ListTile(
        leading: Icon(icon, color: menuColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: menuColor,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: trailingColor),
        onTap: onTap,
      ),
    );
  }
}

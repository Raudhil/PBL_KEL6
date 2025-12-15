import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/providers/role_provider.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../core/widgets/under_development_dialog.dart';
import '../../../../../core/services/error_handler_service.dart';

class QuickAccessWidget extends ConsumerWidget {
  const QuickAccessWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(roleProvider);

    return roleAsync.maybeWhen(
      data: (role) => KeyedSubtree(
        key: ValueKey('quick_access_$role'),
        child: _buildQuickAccess(context, role),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildQuickAccess(BuildContext context, String role) {
    // Role checking - tampilkan hanya untuk perangkat
    final normalizedRole = role.toLowerCase().trim();

    // DEBUG: Print untuk melihat role yang diterima
    print('🔍 Quick Access - Role diterima: "$role"');
    print('🔍 Quick Access - Role normalized: "$normalizedRole"');

    const roleLabels = {
      'rt': 'RT',
      'rw': 'RW',
      'bendahara': 'Bendahara',
      'sekretaris': 'Sekretaris',
      'admin': 'Admin',
    };

    String? matchedKey;
    for (final entry in roleLabels.entries) {
      if (normalizedRole == entry.key || normalizedRole.contains(entry.key)) {
        matchedKey = entry.key;
        print('✅ Quick Access - Role MATCH: $matchedKey');
        break;
      }
    }

    // Jika bukan perangkat, jangan tampilkan quick access
    if (matchedKey == null) {
      print('❌ Quick Access - Role TIDAK MATCH, widget disembunyikan');
      return const SizedBox.shrink();
    }

    print('✅ Quick Access - Widget DITAMPILKAN untuk role: $matchedKey');

    // Konfigurasi per role
    final roleConfig = _getQuickAccessConfig(matchedKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   'Quick Access',
        //   style: TextStyle(
        //     fontSize: 20,
        //     fontWeight: FontWeight.bold,
        //     color: AppColors.textPrimary,
        //   ),
        // ),
        const SizedBox(height: 12),
        // Strong card header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: (roleConfig['gradient'] as List<Color>),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (roleConfig['gradient'] as List<Color>)[0].withOpacity(
                  0.25,
                ),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  roleConfig['icon'] as IconData,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleConfig['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleConfig['subtitle'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FeatureGrid(role: matchedKey),
        const SizedBox(height: 8),
      ],
    );
  }

  Map<String, dynamic> _getQuickAccessConfig(String role) {
    switch (role) {
      case 'rt':
        return {
          'title': 'Akses Cepat RT',
          'subtitle': 'Kelola data dan warga RT',
          'icon': Icons.people,
          'gradient': [AppColors.primary600, AppColors.primary400],
        };
      case 'rw':
        return {
          'title': 'Akses Cepat RW',
          'subtitle': 'Koordinasi dan kelola RW',
          'icon': Icons.groups,
          'gradient': [AppColors.primary600, AppColors.primary400],
        };
      case 'bendahara':
        return {
          'title': 'Akses Cepat Bendahara',
          'subtitle': 'Kelola keuangan dan iuran',
          'icon': Icons.payments,
          'gradient': [AppColors.primary600, AppColors.primary400],
        };
      case 'sekretaris':
        return {
          'title': 'Akses Cepat Sekretaris',
          'subtitle': 'Kelola administrasi dan dokumen',
          'icon': Icons.edit_document,
          'gradient': [AppColors.primary600, AppColors.primary400],
        };
      case 'admin':
        return {
          'title': 'Akses Cepat Admin',
          'subtitle': 'Kelola sistem dan pengguna',
          'icon': Icons.admin_panel_settings,
          'gradient': [AppColors.primary600, AppColors.primary400],
        };
      default:
        return {
          'title': 'Akses Cepat',
          'subtitle': 'Kelola fitur khusus perangkat',
          'icon': Icons.admin_panel_settings,
          'gradient': [AppColors.primary600, AppColors.primary400],
        };
    }
  }

  List<Map<String, dynamic>> _getMenusByRole(String role) {
    switch (role) {
      case 'rt':
        return [
          {
            'icon': Icons.people_alt,
            'label': 'Data Warga',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.assessment,
            'label': 'Laporan Keuangan',
            'color': AppColors.primary500,
          },
          {
            'icon': Icons.campaign,
            'label': 'Pengumuman',
            'color': AppColors.primary400,
          },
          {
            'icon': Icons.event,
            'label': 'Kegiatan',
            'color': AppColors.primary300,
          },
        ];
      case 'rw':
        return [
          {
            'icon': Icons.account_balance_wallet,
            'label': 'Laporan Keuangan',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.people_outline,
            'label': 'Data Warga',
            'color': AppColors.primary500,
          },
        ];
      case 'bendahara':
        return [
          {
            'icon': Icons.receipt_long,
            'label': 'Kelola Iuran',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.assessment,
            'label': 'Laporan Keuangan',
            'color': AppColors.primary500,
          },
          {
            'icon': Icons.campaign,
            'label': 'Pengumuman',
            'color': AppColors.primary400,
          },
          {
            'icon': Icons.event,
            'label': 'Kegiatan',
            'color': AppColors.primary300,
          },
        ];
      case 'sekretaris':
        return [
          {
            'icon': Icons.campaign,
            'label': 'Pengumuman',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.event_note,
            'label': 'Kegiatan',
            'color': AppColors.primary500,
          },
        ];
      case 'admin':
        return [
          {
            'icon': Icons.manage_accounts,
            'label': 'Kelola Pengguna',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.history,
            'label': 'Log Aktivitas',
            'color': AppColors.warning,
          },
          {
            'icon': Icons.settings_suggest,
            'label': 'Pengaturan Sistem',
            'color': AppColors.primary,
          },
          {
            'icon': Icons.bar_chart_rounded,
            'label': 'Statistik Warga',
            'color': AppColors.info,
          },
        ];
      default:
        return [];
    }
  }
}

class _FeatureGrid extends StatelessWidget {
  final String role;
  const _FeatureGrid({required this.role});

  @override
  Widget build(BuildContext context) {
    final menus = _getMenus(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return _MenuCard(
          icon: menu['icon'] as IconData,
          label: menu['label'] as String,
          color: menu['color'] as Color,
          onTap: () =>
              _onTap(context, menu['label'] as String, menu['color'] as Color),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMenus(BuildContext context) {
    switch (role) {
      case 'rt':
        return [
          {
            'icon': Icons.people_alt,
            'label': 'Data Warga',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.assessment,
            'label': 'Laporan Keuangan',
            'color': AppColors.primary500,
          },
          {
            'icon': Icons.campaign,
            'label': 'Pengumuman',
            'color': AppColors.primary400,
          },
          {
            'icon': Icons.event,
            'label': 'Kegiatan',
            'color': AppColors.primary300,
          },
        ];
      case 'rw':
        return [
          {
            'icon': Icons.account_balance_wallet,
            'label': 'Laporan Keuangan',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.people_outline,
            'label': 'Data Warga',
            'color': AppColors.primary500,
          },
        ];
      case 'bendahara':
        return [
          {
            'icon': Icons.receipt_long,
            'label': 'Kelola Iuran',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.assessment,
            'label': 'Laporan Keuangan',
            'color': AppColors.primary500,
          },
          {
            'icon': Icons.campaign,
            'label': 'Pengumuman',
            'color': AppColors.primary400,
          },
          {
            'icon': Icons.event,
            'label': 'Kegiatan',
            'color': AppColors.primary300,
          },
        ];
      case 'sekretaris':
        return [
          {
            'icon': Icons.campaign,
            'label': 'Pengumuman',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.event_note,
            'label': 'Kegiatan',
            'color': AppColors.primary500,
          },
        ];
      case 'admin':
        return [
          {
            'icon': Icons.manage_accounts,
            'label': 'Kelola Pengguna',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.history,
            'label': 'Log Aktivitas',
            'color': AppColors.warning,
          },
          {
            'icon': Icons.settings_suggest,
            'label': 'Pengaturan Sistem',
            'color': AppColors.primary,
          },
          {
            'icon': Icons.bar_chart_rounded,
            'label': 'Statistik Warga',
            'color': AppColors.info,
          },
        ];
      default:
        return [];
    }
  }

  void _onTap(BuildContext context, String label, Color color) {
    try {
      // Use GoRouter for navigation with error handling
      if (label == 'Data Warga') {
        // Check role to determine which route
        if (role == 'rw') {
          GoRouter.of(context).go('/rw/data-warga');
        } else {
          GoRouter.of(context).go('/rt/data-warga');
        }
        return;
      }
      if (label == 'Kelola Iuran') {
        GoRouter.of(context).go('/bendahara/kelola-iuran');
        return;
      }
      if (label == 'Laporan Keuangan') {
        // Check role to determine which route
        if (role == 'rw') {
          GoRouter.of(context).go('/rw/laporan-keuangan');
        } else {
          GoRouter.of(context).go('/bendahara/keuangan');
        }
        return;
      }
      if (label == 'Kelola Pengguna') {
        GoRouter.of(context).go('/admin/kelola-pengguna');
        return;
      }
      if (label == 'Log Aktivitas') {
        GoRouter.of(context).go('/admin/log-aktivitas');
        return;
      }
      if (label == 'Pengaturan Sistem') {
        GoRouter.of(context).go('/admin/pengaturan-sistem');
        return;
      }
      if (label == 'Statistik Warga') {
        // Fitur dalam pengembangan - tampilkan modal
        showUnderDevelopmentDialog(
          context,
          featureName: label,
          description:
              'Fitur $label sedang dalam tahap pengembangan dan akan segera tersedia untuk Anda.',
        );
        return;
      }
      if (label == 'Kegiatan') {
        GoRouter.of(context).go('/sekretaris/kegiatan');
        return;
      }
      if (label == 'Pengumuman') {
        GoRouter.of(context).go('/sekretaris/pengumuman');
        return;
      }

      // Fitur dalam pengembangan - tampilkan modal
      showUnderDevelopmentDialog(
        context,
        featureName: label,
        description:
            'Fitur $label sedang dalam tahap pengembangan dan akan segera tersedia untuk Anda.',
      );
    } catch (e) {
      // Tangkap error dan tampilkan dialog user-friendly menggunakan error handler
      ErrorHandlerService.handleError(
        context,
        e,
        customMessage:
            'Maaf, terjadi kesalahan saat membuka fitur $label. Silakan coba lagi nanti atau hubungi admin jika masalah berlanjut.',
        onRetry: () => _onTap(context, label, color),
      );
    }
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.greyDark.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.08), width: 1),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

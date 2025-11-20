import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../../../core/providers/role_provider.dart';
import '../../../bendahara/pages/keuangan/kelola_iuran.dart';
import '../../../admin/pages/kelola_pengguna_page.dart';

class PerangkatPage extends ConsumerWidget {
  const PerangkatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(roleProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(
        title: 'Fitur Perangkat',
        showBackButton: true,
      ),
      body: roleAsync.when(
        data: (role) {
          final userRole = role.toLowerCase().trim();
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(userRole),
                  const SizedBox(height: 24),
                  _buildMenuGrid(context, userRole),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildHeader(String role) {
    final roleInfo = _getRoleInfo(role);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: roleInfo['gradient'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (roleInfo['gradient'] as List<Color>)[0].withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              roleInfo['icon'] as IconData,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleInfo['title'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roleInfo['subtitle'] as String,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, String role) {
    final menus = _getMenusByRole(role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Perangkat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
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
              onTap: () {
                final label = menu['label'] as String;

                // ROUTING KHUSUS
                // Data Warga untuk RT
                if (label == 'Data Warga') {
                  context.go('/rt/data-warga');
                  return;
                }

                // Kelola Tagihan untuk Bendahara
                if (label == 'Kelola Tagihan') {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const KelolaIuranPage()),
                  );
                  return;
                }

                // Kelola Pengguna untuk Admin
                if (label == 'Kelola Pengguna') {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => const KelolaPenggunaPage(),
                    ),
                  );
                  return;
                }

                // Default: Tampilkan snackbar "Dalam Pengembangan"
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label - Dalam Pengembangan'),
                    backgroundColor: menu['color'] as Color,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Map<String, dynamic> _getRoleInfo(String role) {
    switch (role) {
      case 'rt':
        return {
          'title': 'Dashboard RT',
          'subtitle': 'Kelola data dan warga RT',
          'icon': Icons.people,
          'gradient': [AppColors.success, const Color(0xFF10B981)],
        };
      case 'rw':
        return {
          'title': 'Dashboard RW',
          'subtitle': 'Koordinasi dan kelola RW',
          'icon': Icons.groups,
          'gradient': [AppColors.success, const Color(0xFF10B981)],
        };
      case 'bendahara':
        return {
          'title': 'Dashboard Bendahara',
          'subtitle': 'Kelola keuangan dan iuran',
          'icon': Icons.payments,
          'gradient': [AppColors.success, const Color(0xFF10B981)],
        };
      case 'sekretaris':
        return {
          'title': 'Dashboard Sekretaris',
          'subtitle': 'Kelola administrasi dan surat',
          'icon': Icons.edit_document,
          'gradient': [AppColors.success, const Color(0xFF10B981)],
        };
      case 'admin':
        return {
          'title': 'Dashboard Admin',
          'subtitle': 'Kelola sistem dan pengguna',
          'icon': Icons.admin_panel_settings,
          'gradient': [AppColors.success, const Color(0xFF10B981)],
        };
      default:
        return {
          'title': 'Dashboard Perangkat',
          'subtitle': 'Kelola data perangkat',
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
            'icon': Icons.campaign,
            'label': 'Pengumuman RT',
            'color': Color(0xFF3B82F6),
          },
          {
            'icon': Icons.event,
            'label': 'Kegiatan RT',
            'color': Color(0xFF06B6D4),
          },
          {
            'icon': Icons.bar_chart,
            'label': 'Statistik RT',
            'color': Color(0xFF8B5CF6),
          },
        ];
      case 'rw':
        return [
          {
            'icon': Icons.domain,
            'label': 'Data per RT',
            'color': Color(0xFF6366F1),
          },
          {
            'icon': Icons.payments,
            'label': 'Status Iuran',
            'color': AppColors.success,
          },
          {
            'icon': Icons.assessment,
            'label': 'Laporan Warga',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.people_outline,
            'label': 'Daftar Warga',
            'color': Color(0xFF8B5CF6),
          },
        ];
      case 'bendahara':
        return [
          {
            'icon': Icons.receipt_long,
            'label': 'Kelola Tagihan',
            'color': AppColors.success,
          },
          {
            'icon': Icons.account_balance_wallet,
            'label': 'Keuangan',
            'color': Color(0xFF10B981),
          },
          {
            'icon': Icons.account_balance,
            'label': 'Channel Transfer',
            'color': Color(0xFF3B82F6),
          },
          {
            'icon': Icons.campaign,
            'label': 'Pengumuman',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.event,
            'label': 'Kegiatan',
            'color': Color(0xFF06B6D4),
          },
        ];
      case 'sekretaris':
        return [
          {
            'icon': Icons.campaign,
            'label': 'Kelola Pengumuman',
            'color': AppColors.warning,
          },
          {
            'icon': Icons.event_note,
            'label': 'Kelola Kegiatan',
            'color': Color(0xFFF59E0B),
          },
          {
            'icon': Icons.folder_open,
            'label': 'Arsip Dokumen',
            'color': AppColors.primary600,
          },
          {
            'icon': Icons.print,
            'label': 'Cetak Dokumen',
            'color': Color(0xFF8B5CF6),
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
            'icon': Icons.person_add,
            'label': 'Tambah Pengguna',
            'color': Color(0xFF10B981),
          },
          {
            'icon': Icons.security,
            'label': 'Hak Akses',
            'color': Color(0xFF3B82F6),
          },
          {
            'icon': Icons.settings,
            'label': 'Pengaturan Sistem',
            'color': Color(0xFF8B5CF6),
          },
        ];
      default:
        return [];
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyDark.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

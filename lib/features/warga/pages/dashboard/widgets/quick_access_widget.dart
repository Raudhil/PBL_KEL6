import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/role_provider.dart';
import '../../../../../theme/app_colors.dart';
import '../../perangkat/perangkat_page.dart';

class QuickAccessWidget extends ConsumerWidget {
  const QuickAccessWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(roleProvider);

    return roleAsync.maybeWhen(
      data: (role) => _buildQuickAccess(context, role),
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
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            // Navigate ke halaman perangkat (keluar dari WargaMainPage)
            Navigator.of(
              context,
              rootNavigator: true,
            ).push(MaterialPageRoute(builder: (_) => const PerangkatPage()));
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.success, Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.25),
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
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Map<String, dynamic> _getQuickAccessConfig(String role) {
    switch (role) {
      case 'rt':
        return {
          'title': 'Akses Fitur RT',
          'subtitle': 'Kelola data dan warga RT',
          'icon': Icons.people,
          'gradient': [AppColors.primary600, AppColors.primary400],
        };
      case 'rw':
        return {
          'title': 'Akses Fitur RW',
          'subtitle': 'Koordinasi dan kelola RW',
          'icon': Icons.groups,
          'gradient': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        };
      case 'bendahara':
        return {
          'title': 'Akses Fitur Bendahara',
          'subtitle': 'Kelola keuangan dan iuran',
          'icon': Icons.payments,
          'gradient': [AppColors.success, const Color(0xFF10B981)],
        };
      case 'sekretaris':
        return {
          'title': 'Akses Fitur Sekretaris',
          'subtitle': 'Kelola administrasi dan dokumen',
          'icon': Icons.edit_document,
          'gradient': [AppColors.warning, const Color(0xFFF59E0B)],
        };
      case 'admin':
        return {
          'title': 'Akses Fitur Admin',
          'subtitle': 'Kelola sistem dan pengguna',
          'icon': Icons.admin_panel_settings,
          'gradient': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
        };
      default:
        return {
          'title': 'Akses Fitur Perangkat',
          'subtitle': 'Kelola fitur khusus perangkat',
          'icon': Icons.admin_panel_settings,
          'gradient': [AppColors.primary600, AppColors.primary400],
        };
    }
  }
}

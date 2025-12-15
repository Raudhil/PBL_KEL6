import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../../../core/config/app_config.dart';

class SystemSettingsPage extends ConsumerStatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  ConsumerState<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends ConsumerState<SystemSettingsPage> {
  bool _isDevelopmentMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    _isDevelopmentMode = AppConfig.isDevelopmentMode;
    setState(() => _isLoading = false);
  }

  Future<void> _toggleDevelopmentMode(bool value) async {
    setState(() => _isLoading = true);

    await AppConfig.setDevelopmentMode(value);

    setState(() {
      _isDevelopmentMode = value;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? '🔧 Mode Pengembang Diaktifkan - Error detail akan ditampilkan'
                : '🔒 Mode Production Diaktifkan - Error user-friendly',
          ),
          backgroundColor: value ? AppColors.warning : AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(
        title: 'Pengaturan Sistem',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mode Development Section
                  _buildSectionCard(
                    title: 'Mode Aplikasi',
                    icon: Icons.developer_mode,
                    iconColor: AppColors.warning,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mode Pengembang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isDevelopmentMode
                                      ? 'Error detail akan ditampilkan'
                                      : 'Error user-friendly akan ditampilkan',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isDevelopmentMode,
                            onChanged: _toggleDevelopmentMode,
                            activeColor: AppColors.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              (_isDevelopmentMode
                                      ? AppColors.warning
                                      : AppColors.success)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                (_isDevelopmentMode
                                        ? AppColors.warning
                                        : AppColors.success)
                                    .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isDevelopmentMode
                                  ? Icons.warning_amber
                                  : Icons.check_circle,
                              color: _isDevelopmentMode
                                  ? AppColors.warning
                                  : AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isDevelopmentMode
                                    ? 'Mode ini menampilkan detail teknis error untuk debugging. Nonaktifkan untuk production.'
                                    : 'Mode ini menampilkan pesan error yang ramah pengguna. Cocok untuk production.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isDevelopmentMode
                                      ? AppColors.warning
                                      : AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Example Comparison
                  _buildSectionCard(
                    title: 'Perbandingan Mode',
                    icon: Icons.compare_arrows,
                    iconColor: AppColors.primary,
                    children: [
                      _buildComparisonRow('Mode Development', [
                        '• Menampilkan tipe error',
                        '• Menampilkan detail teknis',
                        '• Stack trace visible',
                        '• Console logging aktif',
                      ], AppColors.warning),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildComparisonRow('Mode Production', [
                        '• Pesan user-friendly',
                        '• Detail teknis tersembunyi',
                        '• Stack trace hidden',
                        '• Console logging minimal',
                      ], AppColors.success),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info Section
                  _buildSectionCard(
                    title: 'Informasi',
                    icon: Icons.info_outline,
                    iconColor: AppColors.primary,
                    children: [
                      _buildInfoRow('Versi Aplikasi', '1.0.0'),
                      const Divider(),
                      _buildInfoRow(
                        'Mode Saat Ini',
                        _isDevelopmentMode ? 'Development' : 'Production',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Status',
                        _isDevelopmentMode ? 'Debug Mode' : 'Release Mode',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Warning Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.danger,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Peringatan!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pastikan Mode Production AKTIF sebelum release aplikasi ke user!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.danger.withOpacity(0.8),
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

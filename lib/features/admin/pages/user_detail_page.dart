import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../core/providers/user_management_provider.dart';
import 'change_user_role_page.dart';

class UserDetailPage extends ConsumerWidget {
  final int userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.greyLight,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User tidak ditemukan'));
          }
          return _buildContent(context, ref, user);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UserModel user) {
    final isActive = user.status == StatusUser.aktif;

    return CustomScrollView(
      slivers: [
        // App bar dengan gradient
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary600, AppColors.primary400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
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
                          user.fotoProfile != null &&
                              user.fotoProfile!.isNotEmpty
                          ? CircleAvatar(
                              radius: 45,
                              backgroundImage: NetworkImage(user.fotoProfile!),
                              backgroundColor: AppColors.white,
                            )
                          : CircleAvatar(
                              radius: 45,
                              backgroundColor: AppColors.white,
                              child: Text(
                                user.displayName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    // Nama
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Role badge
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.role != null
                              ? AppColors.white.withOpacity(0.2)
                              : AppColors.warning.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (user.role == null)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  size: 14,
                                  color: AppColors.white,
                                ),
                              ),
                            Text(
                              user.role?.nama ?? 'Belum Ada Role',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [
                              AppColors.success.withOpacity(0.1),
                              AppColors.success.withOpacity(0.05),
                            ]
                          : [
                              AppColors.danger.withOpacity(0.1),
                              AppColors.danger.withOpacity(0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? AppColors.success : AppColors.danger,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.danger.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isActive
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: isActive
                              ? AppColors.success
                              : AppColors.danger,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Akun',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.status.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Toggle status button
                      ElevatedButton.icon(
                        onPressed: () => _showStatusDialog(context, ref, user),
                        icon: Icon(
                          isActive ? Icons.block : Icons.check_circle,
                          size: 18,
                        ),
                        label: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive
                              ? AppColors.danger
                              : AppColors.success,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Informasi Pribadi
                _buildSectionTitle('Informasi Pribadi'),
                const SizedBox(height: 12),
                _buildModernCard(
                  items: [
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'NIK',
                      value: user.nik ?? '-',
                      iconColor: AppColors.primary,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Nama Lengkap',
                      value: user.warga?.namaLengkap ?? user.fullName ?? '-',
                      iconColor: AppColors.primary400,
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.wc_outlined,
                      label: 'Jenis Kelamin',
                      value: user.warga?.jenisKelamin ?? '-',
                      iconColor: AppColors.primary600,
                    ),
                    if (user.warga?.tanggalLahir != null) ...[
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.cake_outlined,
                        label: 'Tanggal Lahir',
                        value: _formatDate(user.warga!.tanggalLahir!),
                        iconColor: AppColors.success,
                      ),
                    ],
                    if (user.warga?.nomorHp != null) ...[
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Nomor HP',
                        value: user.warga!.nomorHp!,
                        iconColor: AppColors.warning,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                // Informasi Akun
                _buildSectionTitle('Informasi Akun'),
                const SizedBox(height: 12),
                _buildModernCard(
                  items: [
                    _buildInfoRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Role',
                      value: user.role?.nama ?? 'Belum ditentukan',
                      iconColor: user.role != null
                          ? AppColors.primary
                          : AppColors.warning,
                      trailing: Material(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeUserRolePage(user: user),
                              ),
                            );
                            if (result == true && context.mounted) {
                              ref.invalidate(userDetailProvider(user.id));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Ubah',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Bergabung Sejak',
                      value: user.createdAt != null
                          ? _formatDate(user.createdAt!)
                          : '-',
                      iconColor: AppColors.textSecondary,
                    ),
                    if (user.updatedAt != null) ...[
                      _buildDivider(),
                      _buildInfoRow(
                        icon: Icons.update_outlined,
                        label: 'Terakhir Diupdate',
                        value: _formatDate(user.updatedAt!),
                        iconColor: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, thickness: 1, color: AppColors.greyLight),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _showStatusDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) async {
    final isActive = user.status == StatusUser.aktif;
    final newStatus = isActive ? StatusUser.tidakAktif : StatusUser.aktif;

    final confirmed = await showDialog<bool>(
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
                color: (isActive ? AppColors.danger : AppColors.success)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.block : Icons.check_circle,
                color: isActive ? AppColors.danger : AppColors.success,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${isActive ? 'Nonaktifkan' : 'Aktifkan'} User?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'User tidak akan bisa login ke aplikasi.'
                  : 'User akan dapat login ke aplikasi.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
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
                      backgroundColor: isActive
                          ? AppColors.danger
                          : AppColors.success,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(userListProvider.notifier)
            .updateUserStatus(user.id, newStatus);

        if (context.mounted) {
          // Refresh user detail
          ref.invalidate(userDetailProvider(user.id));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Status user berhasil di${isActive ? 'nonaktifkan' : 'aktifkan'}',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengupdate status: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }
}

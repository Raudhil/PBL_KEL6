import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';
import '../../features/notification/pages/notification_page.dart';

class CustomTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const CustomTopBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.email?.split('@')[0] ?? 'User';

    // Cek apakah ini halaman Dashboard untuk menampilkan foto profil
    final isDashboard = title == 'Selamat Datang';
    final isMarketplace = title == 'Marketplace';
    final isIuran = title == 'Iuran';

    // Semua halaman menggunakan background hijau
    final isGreenBackButton =
        title.contains('Laporan') ||
        title.contains('Kelola') ||
        title.contains('Iuran') ||
        title.contains('Keuangan');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary600, AppColors.primary500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: AppBar(
          leading: showBackButton
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () {
                    if (onBack != null) {
                      onBack!();
                      return;
                    }
                    try {
                      context.pop();
                    } catch (_) {
                      context.go('/warga/dashboard');
                    }
                  },
                )
              : null,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: showBackButton ? 8 : 16,
          title: _buildTitle(
            context,
            ref,
            isDashboard,
            isMarketplace,
            isIuran,
            userName,
            isGreenBackButton,
          ),
          actions: isDashboard
              ? _buildDashboardActions(context, ref)
              : (isMarketplace
                    ? _buildMarketplaceActions(context)
                    : (isIuran ? _buildIuranActions(context) : actions)),
        ),
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    WidgetRef ref,
    bool isDashboard,
    bool isMarketplace,
    bool isIuran,
    String userName,
    bool isGreenBackButton,
  ) {
    // Desain khusus untuk Kelola Iuran dan Laporan Keuangan
    if (isGreenBackButton && !isDashboard && !isMarketplace && !isIuran) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    title.contains('Laporan')
                        ? Icons.assessment_rounded
                        : Icons.account_balance_wallet_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        title.contains('Laporan')
                            ? 'Monitoring Keuangan'
                            : 'Manajemen Pembayaran',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white.withOpacity(0.85),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (isDashboard) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Halo, $userName',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.white.withOpacity(0.9),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    } else if (isMarketplace) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Pasar Warga',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.white.withOpacity(0.9),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    } else if (isIuran) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Kelola Pembayaran',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.white.withOpacity(0.9),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            letterSpacing: 0.3,
          ),
        ),
      );
    }
  }

  List<Widget> _buildDashboardActions(BuildContext context, WidgetRef ref) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  List<Widget>? _buildMarketplaceActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  List<Widget>? _buildIuranActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
        ),
      ),
    ];
  }
}

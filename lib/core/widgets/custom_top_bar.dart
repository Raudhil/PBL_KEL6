import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';

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
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.email?.split('@')[0] ?? 'User';

    // Tentukan apakah menampilkan subtitle
    final showSubtitle =
        !showBackButton && title != 'Marketplace' && title != 'Iuran';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary600, AppColors.primary400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: AppBar(
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
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
          titleSpacing: showBackButton ? 0 : 16,
          title: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                if (showSubtitle)
                  Text(
                    'Halo, $userName',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white.withOpacity(0.95),
                      letterSpacing: 0.2,
                    ),
                  ),
              ],
            ),
          ),
          actions: actions,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_top_bar.dart';
import '../../theme/app_colors.dart';

/// Shell page untuk Seller Mode
/// Seller mode memiliki navbar dan fitur yang berbeda dari warga mode
///
/// TODO: Implementasi pages:
/// - SellerProductsPage (manage produk)
/// - SellerOrdersPage (manage pesanan)
/// - SellerAnalyticsPage (lihat statistik penjualan)
/// - SellerSettingsPage (pengaturan toko)

class SellerMainPage extends ConsumerWidget {
  final Widget child;

  const SellerMainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current route to determine active tab
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    String title = 'Produk Saya';

    if (location.contains('/products')) {
      currentIndex = 0;
      title = 'Produk Saya';
    } else if (location.contains('/orders')) {
      currentIndex = 1;
      title = 'Pesanan';
    } else if (location.contains('/analytics')) {
      currentIndex = 2;
      title = 'Statistik';
    } else if (location.contains('/settings')) {
      currentIndex = 3;
      title = 'Pengaturan Toko';
    }

    return Scaffold(
      appBar: CustomTopBar(title: title),
      body: child,
      bottomNavigationBar: _SellerBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/seller/products');
              break;
            case 1:
              context.go('/seller/orders');
              break;
            case 2:
              context.go('/seller/analytics');
              break;
            case 3:
              context.go('/seller/settings');
              break;
          }
        },
      ),
    );
  }
}

/// Custom Bottom NavBar untuk Seller Mode
/// Berbeda dengan warga mode - fokus ke penjualan
class _SellerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _SellerBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.greyDark.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Produk',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag,
                label: 'Pesanan',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
                badge: '3', // TODO: Dynamic badge from orders
              ),
              _NavBarItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'Statistik',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Pengaturan',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? badge;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.mint : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.primary : AppColors.greyMedium,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppColors.primary : AppColors.greyMedium,
                  ),
                ),
              ],
            ),
          ),
          // Badge notification
          if (badge != null && badge!.isNotEmpty)
            Positioned(
              top: -4,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

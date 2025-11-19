import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.store_outlined, 'activeIcon': Icons.store, 'label': 'Market'},
      {'icon': Icons.payments_outlined, 'activeIcon': Icons.payments, 'label': 'Iuran'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profil'},
    ];

    return SafeArea(
      child: Container(
      color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.greyLight,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.asMap().entries.map((entry) {
                int idx = entry.key;
                Map<String, dynamic> item = entry.value;

                return Flexible(
                  fit: FlexFit.loose,
                  child: _NavBarItem(
                    icon: item['icon'],
                    activeIcon: item['activeIcon'],
                    label: item['label'],
                    isActive: currentIndex == idx,
                    onTap: () => onTap(idx),
                  ),
                );
              }).toList(),
            ),
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

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.primary; 
    final Color inactiveColor = AppColors.primary; 
    final Color activeContentColor = AppColors.white; 

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(15),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8), 
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 0,
          ),
          child: Row( 
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? activeContentColor : inactiveColor,
                size: 24,
              ),
              
              // Teks hanya tampil jika item aktif
              if (isActive) ...[
                const SizedBox(width: 4), // Jarak antara ikon dan teks
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: activeContentColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
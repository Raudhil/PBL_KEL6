import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class UserStatisticsCards extends StatelessWidget {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const UserStatisticsCards({
    super.key,
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Semua',
              count: totalUsers,
              color: AppColors.primary,
              icon: Icons.people,
              isSelected: selectedFilter == 'Semua',
              onTap: () => onFilterChanged('Semua'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Aktif',
              count: activeUsers,
              color: AppColors.success,
              icon: Icons.check_circle,
              isSelected: selectedFilter == 'Aktif',
              onTap: () => onFilterChanged('Aktif'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Tidak Aktif',
              count: inactiveUsers,
              color: AppColors.danger,
              icon: Icons.cancel,
              isSelected: selectedFilter == 'Tidak Aktif',
              onTap: () => onFilterChanged('Tidak Aktif'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 4),
                spreadRadius: isSelected ? 1 : 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../core/providers/marketplace_provider.dart';

class CategoryFilter extends ConsumerWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    const categories = [
      _CategoryItem(label: 'All', emoji: '📦', accent: AppColors.primary600),
      _CategoryItem(label: 'Kentang', emoji: '🥔', accent: AppColors.warning),
      _CategoryItem(label: 'Wortel', emoji: '🥕', accent: AppColors.primary400),
      _CategoryItem(label: 'Tomat', emoji: '🍅', accent: AppColors.yellowGold),
    ];

    // Calculate responsive card width dengan padding consideration
    final horizontalPadding =
        32.0; // 16px left + 16px right padding dari parent
    final availableWidth = screenWidth - horizontalPadding;
    final totalGap = (categories.length - 1) * 8.0;
    final cardWidth = (availableWidth - totalGap) / categories.length;

    // Ensure minimum width untuk prevent overflow
    final safeCardWidth = cardWidth.clamp(70.0, 100.0);

    return SizedBox(
      height: 106,
      child: ListView.separated(
        padding: const EdgeInsets.only(right: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category.label;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 4 : 0,
              top: 4,
              bottom: 4,
            ),
            child: _CategoryCard(
              label: category.label,
              emoji: category.emoji,
              accent: category.accent,
              isSelected: isSelected,
              width: safeCardWidth,
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state =
                    category.label;
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final String emoji;
  final Color accent;

  const _CategoryItem({
    required this.label,
    required this.emoji,
    required this.accent,
  });
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final String emoji;
  final Color accent;
  final bool isSelected;
  final double width;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.emoji,
    required this.accent,
    required this.isSelected,
    required this.width,
    required this.onTap,
  });

  double get cardWidth => width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accent : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accent.withOpacity(0.2)
                  : AppColors.greyDark.withOpacity(0.04),
              blurRadius: isSelected ? 16 : 8,
              offset: Offset(0, isSelected ? 6 : 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withOpacity(0.1)
                    : accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                emoji,
                style: TextStyle(fontSize: cardWidth > 75 ? 28 : 24),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? accent : AppColors.textPrimary,
                  fontSize: 10 + (cardWidth - 70) / 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

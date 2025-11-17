import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../core/providers/marketplace_provider.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final int ordersCount;
  final VoidCallback onOrdersTap;

  const SearchBarWidget({
    super.key,
    required this.ordersCount,
    required this.onOrdersTap,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greyDark.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                        setState(() {});
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: AppColors.primary600,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Cari produk...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                      setState(() {});
                    },
                  ),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _OrderBadge(count: widget.ordersCount, onTap: widget.onOrdersTap),
      ],
    );
  }
}

class _OrderBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _OrderBadge({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary600, AppColors.primary400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: const Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18),
              height: 18,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

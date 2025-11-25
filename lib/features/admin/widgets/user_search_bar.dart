import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class UserSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onClear;

  const UserSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.greyLight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Cari nama atau NIK pengguna...',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 22,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      controller.clear();
                      if (onClear != null) onClear!();
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

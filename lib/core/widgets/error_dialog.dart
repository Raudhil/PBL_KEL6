import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Reusable dialog untuk error navigasi atau fitur
/// Usage: showErrorDialog(context, message: 'Halaman tidak ditemukan')
void showErrorDialog(
  BuildContext context, {
  String? title,
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _ErrorDialogContent(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    ),
  );
}

class _ErrorDialogContent extends StatelessWidget {
  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ErrorDialogContent({
    this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon dengan decorative elements
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
              // Icon container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.danger.withOpacity(0.15),
                      AppColors.danger.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.danger.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title ?? 'Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),

          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                actionLabel ?? 'Tutup',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

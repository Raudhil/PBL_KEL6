import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Reusable dialog untuk fitur yang masih dalam pengembangan
/// Usage: showUnderDevelopmentDialog(context, featureName: 'Laporan Keuangan');
void showUnderDevelopmentDialog(
  BuildContext context, {
  required String featureName,
  String? description,
}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _UnderDevelopmentContent(
        featureName: featureName,
        description: description,
      ),
    ),
  );
}

class _UnderDevelopmentContent extends StatelessWidget {
  final String featureName;
  final String? description;

  const _UnderDevelopmentContent({required this.featureName, this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary600.withOpacity(0.1),
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
                  color: AppColors.warning.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
              // Icon container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning.withOpacity(0.15),
                      AppColors.warning.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: 40,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Dalam Pengembangan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Feature name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary600.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary600.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Text(
              featureName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description ??
                'Fitur ini sedang dalam tahap pengembangan dan akan segera tersedia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mengerti',
                style: TextStyle(
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

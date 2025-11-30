import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Reusable placeholder image widget untuk pengumuman tanpa foto
///
/// Menampilkan gradient background dengan icon dan text
class PengumumanPlaceholder extends StatelessWidget {
  /// Ukuran widget (width dan height sama untuk square)
  final double size;

  /// Border radius untuk rounded corners
  final double borderRadius;

  /// Apakah menampilkan text (untuk placeholder kecil, text bisa di-hide)
  final bool showText;

  /// Custom text (default dari AppConstants)
  final String? customText;

  /// Icon size (default 36% dari size)
  final double? iconSize;

  const PengumumanPlaceholder({
    super.key,
    this.size = AppConstants.pengumumanThumbnailSize,
    this.borderRadius = AppConstants.pengumumanCardRadius,
    this.showText = true,
    this.customText,
    this.iconSize,
  });

  /// Factory constructor untuk thumbnail kecil (90x90)
  factory PengumumanPlaceholder.thumbnail() {
    return const PengumumanPlaceholder(
      size: AppConstants.pengumumanThumbnailSize,
      borderRadius: 10,
      showText: true,
      iconSize: 32,
    );
  }

  /// Factory constructor untuk preview besar (full width, 180 height)
  factory PengumumanPlaceholder.preview() {
    return const PengumumanPlaceholder(
      size: AppConstants.pengumumanPreviewHeight,
      borderRadius: 0,
      showText: true,
      iconSize: 64,
    );
  }

  /// Factory constructor untuk hero header (250 height)
  factory PengumumanPlaceholder.hero() {
    return const PengumumanPlaceholder(
      size: AppConstants.pengumumanDetailHeaderHeight,
      borderRadius: 0,
      showText: true,
      iconSize: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculatedIconSize = iconSize ?? (size * 0.36);
    final fontSize = size > 100 ? 14.0 : 9.0;
    final textOpacity = size > 100 ? 0.95 : 0.5;
    final iconOpacity = size > 100 ? 0.85 : 0.6;

    return Container(
      width:
          size == AppConstants.pengumumanPreviewHeight ||
              size == AppConstants.pengumumanDetailHeaderHeight
          ? double.infinity
          : size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: size > 100
              ? [
                  AppColors.primary.withOpacity(0.12),
                  AppColors.primary.withOpacity(0.05),
                ]
              : [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius > 0
            ? BorderRadius.circular(borderRadius)
            : null,
        border: size < 100
            ? Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_rounded,
              color: size > 100
                  ? AppColors.white.withOpacity(iconOpacity)
                  : AppColors.primary.withOpacity(iconOpacity),
              size: calculatedIconSize,
            ),
            if (showText) ...[
              SizedBox(height: size > 100 ? 12 : 4),
              Text(
                customText ??
                    (size < 100
                        ? AppConstants.pengumumanNoPhotoShort
                        : AppConstants.pengumumanNoPhotoText),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  color: size > 100
                      ? AppColors.white.withOpacity(textOpacity)
                      : AppColors.primary.withOpacity(textOpacity),
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: size > 100 ? 0.5 : 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Placeholder untuk error loading foto
class PengumumanErrorPlaceholder extends StatelessWidget {
  /// Ukuran widget
  final double size;

  /// Border radius
  final double borderRadius;

  const PengumumanErrorPlaceholder({
    super.key,
    this.size = AppConstants.pengumumanPreviewHeight,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size > 100 ? 48.0 : 32.0;
    final fontSize = size > 100 ? 14.0 : 10.0;

    return Container(
      width:
          size == AppConstants.pengumumanPreviewHeight ||
              size == AppConstants.pengumumanDetailHeaderHeight
          ? double.infinity
          : size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius > 0
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              size: iconSize,
              color: size > 100
                  ? AppColors.white.withOpacity(0.8)
                  : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.pengumumanPhotoErrorText,
              style: TextStyle(
                fontSize: fontSize,
                color: size > 100
                    ? AppColors.white.withOpacity(0.9)
                    : Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// 🌿 Palette — Modern Green Clean
/// Cocok untuk tema hijau yang fresh, profesional, dan elegan
class AppColors {
  AppColors._(); // Private constructor

  // 🎨 Primary Colors
  static const Color primary600 = Color(0xFF1B8A5A);
  static const Color primary500 = Color(0xFF20B886);
  static const Color primary400 = Color(0xFF4ED7A8);
  static const Color primary = primary500; // Default primary

  // 🌿 Secondary Colors
  static const Color mint = Color(0xFFC8F3E0);
  static const Color leafSoft = Color(0xFFE6FFF5);
  static const Color secondary = mint; // Default secondary

  // ⚪ Neutral / Background Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color creamWhite = Color(0xFFFAFDFB);
  static const Color greyLight = Color(0xFFF3F4F6);
  static const Color greyMedium = Color(0xFF6B7280);
  static const Color greyDark = Color(0xFF374151);

  // 🔘 Accent Colors
  static const Color yellowGold = Color(0xFFF4C430);
  static const Color skySoft = Color(0xFFA7E3FF);

  // 🔺 Status Colors
  static const Color success = Color(0xFF20B886);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color error = danger; // Alias

  // Text Colors
  static const Color textPrimary = greyDark;
  static const Color textSecondary = greyMedium;
  static const Color textLight = white;

  // Additional Shades for Primary (for better theming)
  static const Color primary50 = Color(0xFFE6FFF5);
  static const Color primary100 = Color(0xFFC8F3E0);
  static const Color primary200 = Color(0xFF8FE8C7);
  static const Color primary300 = Color(0xFF67DEBF);
  static const Color primary700 = Color(0xFF187350);
  static const Color primary800 = Color(0xFF145C42);
  static const Color primary900 = Color(0xFF0F4532);
}

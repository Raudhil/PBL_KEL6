import 'package:flutter/material.dart';

/// 🎨 Palette — Modern Teal Clean
/// Inspired by modern service app design with #155B5B as primary color
class AppColors {
  AppColors._(); // Private constructor

  // 🎨 Primary Colors (Teal/Dark Cyan) - Based on #155B5B
  static const Color primary900 = Color(0xFF0A2E2E); // Darkest
  static const Color primary800 = Color(0xFF0F4040);
  static const Color primary700 = Color(0xFF124A4A);
  static const Color primary600 = Color(0xFF155B5B); // Main color
  static const Color primary500 = Color(0xFF1A7070);
  static const Color primary400 = Color(0xFF2D8A8A);
  static const Color primary300 = Color(0xFF4DA5A5);
  static const Color primary200 = Color(0xFF7FC4C4);
  static const Color primary100 = Color(0xFFB3DEDE);
  static const Color primary50 = Color(0xFFE5F5F5);
  static const Color primary = primary600; // Default primary

  // 🌿 Secondary Colors (Light Teal/Mint)
  static const Color secondary = Color(0xFFB3DEDE);
  static const Color secondaryLight = Color(0xFFD4EDED);
  static const Color secondarySoft = Color(0xFFE5F5F5);

  // ⚪ Neutral / Background Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(
    0xFFF9FCFE,
  ); // Light blue-teal background
  static const Color cardBackground = white;
  static const Color greyLight = Color(0xFFF3F4F6);
  static const Color greyMedium = Color(0xFF6B7280);
  static const Color greyDark = Color(0xFF374151);
  static const Color border = Color(0xFFE5E7EB);

  // 🔘 Accent Colors
  static const Color accent = Color(
    0xFF155B5B,
  ); // Same as primary for consistency
  static const Color accentLight = Color(0xFF4DA5A5);

  // 🔺 Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color error = danger; // Alias
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // 📝 Text Colors
  static const Color textPrimary = Color(0xFF111827); // Almost black
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = white;
  static const Color textOnPrimary = white;

  // 🎨 UI Element Colors
  static const Color shadow = Color(0x1A000000); // 10% black
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color divider = Color(0xFFE5E7EB);

  // Legacy aliases (untuk backward compatibility sementara)
  static const Color mint = secondary;
  static const Color leafSoft = secondarySoft;
  static const Color creamWhite = background;
  static const Color yellowGold = Color(0xFFF59E0B); // Changed to warning color
  static const Color skySoft = infoLight;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme Mode Notifier
/// Mengelola state tema aplikasi (fixed to light mode only)
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    // Fixed to light mode - no dark mode support
  }

  // Theme is always light - no dark mode support
  // Methods below are kept for compatibility but do nothing

  /// Always returns light mode
  Future<void> setLightMode() async {
    state = ThemeMode.light;
  }

  /// Disabled - no dark mode
  Future<void> setDarkMode() async {
    // Do nothing - stay in light mode
  }

  /// Disabled - no system mode
  Future<void> setSystemMode() async {
    // Do nothing - stay in light mode
  }

  /// Disabled - toggle does nothing
  Future<void> toggleTheme() async {
    // Do nothing - always light mode
  }

  /// Always false - no dark mode
  bool get isDarkMode => false;

  /// Always true - always light mode
  bool get isLightMode => true;

  /// Always false - no system mode
  bool get isSystemMode => false;
}

/// Theme Provider
/// Provider untuk mengakses dan mengubah tema aplikasi
final themeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Is Dark Mode Provider (computed)
/// Provider untuk mengecek apakah sedang dark mode
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  return themeMode == ThemeMode.dark;
});

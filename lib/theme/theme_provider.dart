import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Mode Notifier
/// Mengelola state tema aplikasi (light/dark/system)
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const String _themeModeKey = 'theme_mode';

  /// Load theme mode dari SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);

    if (themeModeString != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }
  }

  /// Save theme mode ke SharedPreferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
  }

  /// Set theme mode ke Light
  Future<void> setLightMode() async {
    state = ThemeMode.light;
    await _saveThemeMode(ThemeMode.light);
  }

  /// Set theme mode ke Dark
  Future<void> setDarkMode() async {
    state = ThemeMode.dark;
    await _saveThemeMode(ThemeMode.dark);
  }

  /// Set theme mode ke System (mengikuti sistem)
  Future<void> setSystemMode() async {
    state = ThemeMode.system;
    await _saveThemeMode(ThemeMode.system);
  }

  /// Toggle antara Light dan Dark mode
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }

  /// Check apakah sedang dark mode
  bool get isDarkMode => state == ThemeMode.dark;

  /// Check apakah sedang light mode
  bool get isLightMode => state == ThemeMode.light;

  /// Check apakah mengikuti sistem
  bool get isSystemMode => state == ThemeMode.system;
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

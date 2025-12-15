import 'package:shared_preferences/shared_preferences.dart';

/// Konfigurasi aplikasi untuk mode debug dan release
///
/// Mode dapat diubah secara dinamis melalui Pengaturan Sistem di Admin
/// - `true` (Development): Tampilkan detail error teknis untuk debugging
/// - `false` (Production/Release): Sembunyikan detail error, tampilkan pesan user-friendly saja
class AppConfig {
  static const String _keyDevelopmentMode = 'app_development_mode';
  static bool _isDevelopmentMode = true; // Default mode

  /// Initialize app config dari SharedPreferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDevelopmentMode = prefs.getBool(_keyDevelopmentMode) ?? false;
  }

  /// Get current development mode status
  static bool get isDevelopmentMode => _isDevelopmentMode;

  /// Set development mode
  static Future<void> setDevelopmentMode(bool enabled) async {
    _isDevelopmentMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDevelopmentMode, enabled);
  }

  /// Toggle development mode
  static Future<void> toggleDevelopmentMode() async {
    await setDevelopmentMode(!_isDevelopmentMode);
  }

  /// Check if production mode
  static bool get isProductionMode => !_isDevelopmentMode;

  /// Helper method untuk mendapatkan pesan error
  ///
  /// Contoh:
  /// ```dart
  /// catch (e) {
  ///   final errorMsg = AppConfig.getErrorMessage(
  ///     'Gagal memuat data',
  ///     e,
  ///   );
  ///   showDialog(...);
  /// }
  /// ```
  static String getErrorMessage(String userMessage, dynamic error) {
    if (_isDevelopmentMode) {
      return '$userMessage\n\n📋 Detail Error (Development Mode):\n$error';
    }
    return userMessage;
  }

  /// Get database error message (untuk error connection, query, dll)
  static String getDatabaseErrorMessage(String operation, dynamic error) {
    if (_isDevelopmentMode) {
      return '🗄️ Database Error [$operation]\n\nDetail:\n$error\n\nTipe Error: ${error.runtimeType}';
    }
    return 'Terjadi kesalahan koneksi database. Silakan periksa koneksi internet Anda atau coba lagi nanti.';
  }

  /// Helper method untuk log error
  static void logError(
    String context,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    if (_isDevelopmentMode) {
      print('❌ ERROR [$context]: $error');
      if (stackTrace != null) {
        print('📚 Stack Trace:\n$stackTrace');
      }
    }
  }

  /// Helper method untuk log database error
  static void logDatabaseError(
    String operation,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    if (_isDevelopmentMode) {
      print('🗄️ DATABASE ERROR [$operation]: $error');
      print('Error Type: ${error.runtimeType}');
      if (stackTrace != null) {
        print('📚 Stack Trace:\n$stackTrace');
      }
    }
  }

  /// Helper method untuk log info
  static void logInfo(String message) {
    if (_isDevelopmentMode) {
      print('ℹ️ INFO: $message');
    }
  }

  /// Helper method untuk log debug
  static void logDebug(String message) {
    if (_isDevelopmentMode) {
      print('🔍 DEBUG: $message');
    }
  }

  /// Helper method untuk log API call
  static void logApi(String endpoint, {String? method, dynamic data}) {
    if (_isDevelopmentMode) {
      print('🌐 API ${method ?? 'CALL'}: $endpoint');
      if (data != null) {
        print('📤 Data: $data');
      }
    }
  }

  /// Helper method untuk log success
  static void logSuccess(String message) {
    if (_isDevelopmentMode) {
      print('✅ SUCCESS: $message');
    }
  }

  /// Helper method untuk log warning
  static void logWarning(String message) {
    if (_isDevelopmentMode) {
      print('⚠️ WARNING: $message');
    }
  }
}

/// Konfigurasi aplikasi untuk mode debug dan release
///
/// Ubah nilai [isDebugMode] untuk mengontrol tampilan error:
/// - `true` (Development): Tampilkan detail error teknis untuk debugging
/// - `false` (Production/Release): Sembunyikan detail error, tampilkan pesan user-friendly saja
class AppConfig {
  /// Debug mode - tampilkan detail error teknis
  ///
  /// **PENTING**: Set ke `false` sebelum release ke production!
  ///
  /// Contoh penggunaan:
  /// ```dart
  /// catch (e) {
  ///   final errorMsg = AppConfig.isDebugMode
  ///     ? 'Error: $e'  // Detail error untuk developer
  ///     : 'Terjadi kesalahan. Silakan coba lagi.'; // User-friendly message
  ///   showDialog(...);
  /// }
  /// ```
  static const bool isDebugMode = true; // Ubah ke false untuk production

  /// Helper method untuk mendapatkan pesan error
  static String getErrorMessage(String userMessage, dynamic error) {
    if (isDebugMode) {
      return '$userMessage\n\nDetail Error:\n$error';
    }
    return userMessage;
  }

  /// Helper method untuk log error
  static void logError(
    String context,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    if (isDebugMode) {
      print('❌ ERROR [$context]: $error');
      if (stackTrace != null) {
        print('Stack Trace:\n$stackTrace');
      }
    }
  }

  /// Helper method untuk log info
  static void logInfo(String message) {
    if (isDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  /// Helper method untuk log debug
  static void logDebug(String message) {
    if (isDebugMode) {
      print('🔍 DEBUG: $message');
    }
  }
}

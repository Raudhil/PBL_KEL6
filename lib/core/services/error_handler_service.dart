import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_error_dialog.dart';

/// Service untuk handle semua error di aplikasi
class ErrorHandlerService {
  /// Handle error secara umum
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final errorInfo = _parseError(error);

    showAppErrorDialog(
      context,
      title: errorInfo.title,
      message: customMessage ?? errorInfo.message,
      errorType: errorInfo.type,
      technicalDetails: errorInfo.technicalDetails,
      onRetry: onRetry,
    );
  }

  /// Parse error ke error info
  static ErrorInfo _parseError(dynamic error) {
    // Supabase errors
    if (error is PostgrestException) {
      return _handlePostgrestError(error);
    }

    // Auth errors
    if (error is AuthException) {
      return _handleAuthError(error);
    }

    // Storage errors
    if (error is StorageException) {
      return _handleStorageError(error);
    }

    // Network/HTTP errors
    if (error is Exception && error.toString().contains('SocketException')) {
      return ErrorInfo(
        type: ErrorType.network,
        title: 'Tidak Ada Koneksi',
        message: 'Periksa koneksi internet Anda dan coba lagi.',
        technicalDetails: error.toString(),
      );
    }

    // Route/Navigation errors
    if (error.toString().contains('GoException')) {
      return ErrorInfo(
        type: ErrorType.navigation,
        title: 'Halaman Tidak Ditemukan',
        message: 'Halaman yang Anda cari tidak tersedia.',
        technicalDetails: error.toString(),
      );
    }

    // Generic error
    return ErrorInfo(
      type: ErrorType.unknown,
      title: 'Terjadi Kesalahan',
      message: 'Maaf, terjadi kesalahan. Silakan coba lagi.',
      technicalDetails: error.toString(),
    );
  }

  /// Handle Postgrest (database) errors
  static ErrorInfo _handlePostgrestError(PostgrestException error) {
    // Error codes: https://postgrest.org/en/stable/errors.html
    final code = error.code;
    final message = error.message;

    switch (code) {
      case '404':
        return ErrorInfo(
          type: ErrorType.notFound,
          title: 'Data Tidak Ditemukan',
          message: 'Data yang Anda cari tidak ada atau telah dihapus.',
          technicalDetails: message,
        );

      case '500':
      case '503':
        return ErrorInfo(
          type: ErrorType.server,
          title: 'Server Bermasalah',
          message:
              'Server sedang mengalami gangguan. Mohon coba beberapa saat lagi.',
          technicalDetails: message,
        );

      case '400':
        return ErrorInfo(
          type: ErrorType.validation,
          title: 'Data Tidak Valid',
          message: 'Data yang Anda masukkan tidak sesuai. Periksa kembali.',
          technicalDetails: message,
        );

      case '401':
      case '403':
        return ErrorInfo(
          type: ErrorType.permission,
          title: 'Akses Ditolak',
          message: 'Anda tidak memiliki izin untuk mengakses fitur ini.',
          technicalDetails: message,
        );

      case '409':
        return ErrorInfo(
          type: ErrorType.conflict,
          title: 'Data Konflik',
          message: 'Data yang sama sudah ada di sistem.',
          technicalDetails: message,
        );

      default:
        return ErrorInfo(
          type: ErrorType.database,
          title: 'Kesalahan Database',
          message: 'Terjadi kesalahan saat mengakses data. Silakan coba lagi.',
          technicalDetails: message,
        );
    }
  }

  /// Handle auth errors
  static ErrorInfo _handleAuthError(AuthException error) {
    final message = error.message;

    if (message.contains('Invalid login credentials')) {
      return ErrorInfo(
        type: ErrorType.auth,
        title: 'Login Gagal',
        message: 'Email atau password salah. Silakan coba lagi.',
        technicalDetails: message,
      );
    }

    if (message.contains('User already registered')) {
      return ErrorInfo(
        type: ErrorType.auth,
        title: 'Email Sudah Terdaftar',
        message:
            'Email ini sudah digunakan. Silakan login atau gunakan email lain.',
        technicalDetails: message,
      );
    }

    if (message.contains('Email not confirmed')) {
      return ErrorInfo(
        type: ErrorType.auth,
        title: 'Email Belum Dikonfirmasi',
        message: 'Silakan cek email Anda untuk konfirmasi akun.',
        technicalDetails: message,
      );
    }

    return ErrorInfo(
      type: ErrorType.auth,
      title: 'Kesalahan Autentikasi',
      message: 'Terjadi kesalahan saat login. Silakan coba lagi.',
      technicalDetails: message,
    );
  }

  /// Handle storage errors
  static ErrorInfo _handleStorageError(StorageException error) {
    return ErrorInfo(
      type: ErrorType.storage,
      title: 'Kesalahan Storage',
      message: 'Gagal mengunggah atau mengunduh file. Silakan coba lagi.',
      technicalDetails: error.message,
    );
  }

  /// Log error (bisa diperluas dengan Sentry, Firebase Crashlytics, dll)
  static void logError(dynamic error, StackTrace? stackTrace) {
    debugPrint('=== ERROR LOG ===');
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
    debugPrint('=================');

    // TODO: Kirim ke error tracking service (Sentry, Firebase, dll)
  }
}

/// Info detail error
class ErrorInfo {
  final ErrorType type;
  final String title;
  final String message;
  final String technicalDetails;

  ErrorInfo({
    required this.type,
    required this.title,
    required this.message,
    required this.technicalDetails,
  });
}

/// Tipe error
enum ErrorType {
  network, // Tidak ada internet
  server, // Server error (500, 503)
  notFound, // Data tidak ditemukan (404)
  validation, // Validasi gagal (400)
  permission, // Tidak punya akses (401, 403)
  conflict, // Data konflik (409)
  database, // Error database lainnya
  auth, // Error autentikasi
  storage, // Error upload/download file
  navigation, // Error routing/navigasi
  unknown, // Error tidak diketahui
}

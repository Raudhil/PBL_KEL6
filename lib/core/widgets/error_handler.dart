import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/error_logger_service.dart';

/// Widget helper untuk menampilkan error dialog
/// dengan mode development/production
class ErrorHandler {
  /// Show error dialog dengan format sesuai mode
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String userMessage,
    dynamic error,
    StackTrace? stackTrace,
    String? userId,
    VoidCallback? onRetry,
  }) async {
    // Log error (hanya di dev mode)
    if (error != null) {
      ErrorLoggerService.logError(
        context: title,
        errorType: error.runtimeType.toString(),
        errorMessage: error.toString(),
        stackTrace: stackTrace,
        userId: userId,
      );
    }

    if (!context.mounted) return;

    final errorMessage = AppConfig.getErrorMessage(userMessage, error);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMessage, style: const TextStyle(fontSize: 14)),
              if (AppConfig.isDevelopmentMode && error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.code, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tipe: ${error.runtimeType}',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Coba Lagi'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Show database error dialog
  static Future<void> showDatabaseError(
    BuildContext context, {
    required String operation,
    required dynamic error,
    StackTrace? stackTrace,
    String? userId,
    VoidCallback? onRetry,
  }) async {
    // Log database error
    ErrorLoggerService.logDatabaseError(
      operation: operation,
      error: error,
      stackTrace: stackTrace,
      userId: userId,
    );

    if (!context.mounted) return;

    final errorMessage = AppConfig.getDatabaseErrorMessage(operation, error);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.storage, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Error Database', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(errorMessage, style: const TextStyle(fontSize: 14)),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Coba Lagi'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Show API error dialog
  static Future<void> showApiError(
    BuildContext context, {
    required String endpoint,
    required String method,
    required dynamic error,
    StackTrace? stackTrace,
    String? userId,
    int? statusCode,
    VoidCallback? onRetry,
  }) async {
    // Log API error
    ErrorLoggerService.logApiError(
      endpoint: endpoint,
      method: method,
      error: error,
      stackTrace: stackTrace,
      userId: userId,
      statusCode: statusCode,
    );

    if (!context.mounted) return;

    final errorMessage = AppConfig.isDevelopmentMode
        ? '🌐 API Error [$method $endpoint]\n\nStatus: $statusCode\nError: $error'
        : 'Terjadi kesalahan saat menghubungi server. Silakan periksa koneksi internet Anda.';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.blue.shade700, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Error Koneksi', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Text(errorMessage, style: const TextStyle(fontSize: 14)),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Coba Lagi'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Show SnackBar error (untuk error kecil)
  static void showSnackBar(
    BuildContext context, {
    required String message,
    dynamic error,
  }) {
    final errorMessage = error != null
        ? AppConfig.getErrorMessage(message, error)
        : message;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

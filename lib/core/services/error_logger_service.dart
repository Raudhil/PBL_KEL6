import '../config/app_config.dart';

/// Service untuk logging error (hanya console, tidak ke database)
/// Digunakan untuk debugging saja
class ErrorLoggerService {
  /// Log general error (hanya console)
  static void logError({
    required String context,
    required String errorType,
    required String errorMessage,
    StackTrace? stackTrace,
    String? userId,
  }) {
    AppConfig.logError(context, errorMessage, stackTrace);
  }

  /// Log database error (hanya console)
  static void logDatabaseError({
    required String operation,
    required dynamic error,
    StackTrace? stackTrace,
    String? userId,
  }) {
    AppConfig.logDatabaseError(operation, error, stackTrace);
  }

  /// Log API error (hanya console)
  static void logApiError({
    required String endpoint,
    required String method,
    required dynamic error,
    StackTrace? stackTrace,
    String? userId,
    int? statusCode,
  }) {
    AppConfig.logError('API: $method $endpoint', error, stackTrace);
  }

  /// Log authentication error (hanya console)
  static void logAuthError({
    required String action,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    AppConfig.logError('Auth: $action', error, stackTrace);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Interceptor untuk handle error dari Supabase
class SupabaseErrorInterceptor {
  /// Wrap Supabase query dengan error handling
  static Future<T> handleQuery<T>(
    Future<T> Function() query, {
    String? customErrorMessage,
  }) async {
    try {
      return await query();
    } on PostgrestException catch (e) {
      _logError('PostgrestException', e);
      rethrow;
    } on AuthException catch (e) {
      _logError('AuthException', e);
      rethrow;
    } on StorageException catch (e) {
      _logError('StorageException', e);
      rethrow;
    } catch (e) {
      _logError('UnknownException', e);
      rethrow;
    }
  }

  /// Wrap Supabase stream dengan error handling
  static Stream<T> handleStream<T>(
    Stream<T> stream, {
    String? customErrorMessage,
  }) {
    return stream.handleError((error) {
      _logError('StreamError', error);
      throw error;
    });
  }

  /// Log error untuk debugging
  static void _logError(String type, dynamic error) {
    if (kDebugMode) {
      debugPrint('=== SUPABASE ERROR ($type) ===');
      debugPrint('Error: $error');
      if (error is PostgrestException) {
        debugPrint('Code: ${error.code}');
        debugPrint('Message: ${error.message}');
        debugPrint('Details: ${error.details}');
        debugPrint('Hint: ${error.hint}');
      } else if (error is AuthException) {
        debugPrint('Message: ${error.message}');
        debugPrint('StatusCode: ${error.statusCode}');
      } else if (error is StorageException) {
        debugPrint('Message: ${error.message}');
        debugPrint('StatusCode: ${error.statusCode}');
      }
      debugPrint('================================');
    }

    // TODO: Kirim ke error tracking service (Sentry, Firebase Crashlytics)
  }
}

/// Extension untuk Supabase client
extension SupabaseErrorHandling on SupabaseClient {
  /// Helper untuk query dengan error handling
  Future<PostgrestResponse<T>> queryWithErrorHandling<T>(
    PostgrestBuilder builder,
  ) async {
    try {
      final response = await builder as PostgrestResponse<T>;
      return response;
    } catch (e) {
      SupabaseErrorInterceptor._logError('QueryError', e);
      rethrow;
    }
  }
}

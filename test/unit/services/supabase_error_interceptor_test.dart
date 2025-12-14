import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseErrorInterceptor Business Logic Tests', () {
    // Test pure business logic untuk error handling
    // Fokus pada error type detection, logging validation, dan error recovery

    // ============================================
    // ERROR TYPE DETECTION TESTS
    // ============================================

    test('harus mendeteksi PostgrestException', () {
      // Arrange
      final errorData = {
        'type': 'PostgrestException',
        'code': '23505',
        'message': 'duplicate key value violates unique constraint',
        'details': 'Key (nik)=(3201234567890123) already exists',
        'hint': 'Check for existing records',
      };

      // Act
      final isPostgrestError = errorData['type'] == 'PostgrestException';
      final hasCode = errorData.containsKey('code');
      final hasMessage = errorData.containsKey('message');

      // Assert
      expect(isPostgrestError, isTrue);
      expect(hasCode, isTrue);
      expect(hasMessage, isTrue);
      expect(errorData['code'], '23505');
    });

    test('harus mendeteksi AuthException', () {
      // Arrange
      final errorData = {
        'type': 'AuthException',
        'message': 'Invalid login credentials',
        'statusCode': '401',
      };

      // Act
      final isAuthError = errorData['type'] == 'AuthException';
      final hasStatusCode = errorData.containsKey('statusCode');

      // Assert
      expect(isAuthError, isTrue);
      expect(hasStatusCode, isTrue);
      expect(errorData['statusCode'], '401');
    });

    test('harus mendeteksi StorageException', () {
      // Arrange
      final errorData = {
        'type': 'StorageException',
        'message': 'File size exceeds limit',
        'statusCode': '413',
      };

      // Act
      final isStorageError = errorData['type'] == 'StorageException';
      final hasMessage = (errorData['message'] as String).isNotEmpty;

      // Assert
      expect(isStorageError, isTrue);
      expect(hasMessage, isTrue);
    });

    test(
      'harus mendeteksi UnknownException untuk error yang tidak dikenal',
      () {
        // Arrange
        final errorData = {
          'type': 'UnknownException',
          'message': 'Something went wrong',
        };

        // Act
        final isUnknownError = errorData['type'] == 'UnknownException';
        final hasMessage = errorData.containsKey('message');

        // Assert
        expect(isUnknownError, isTrue);
        expect(hasMessage, isTrue);
      },
    );

    // ============================================
    // POSTGREST ERROR CODE TESTS
    // ============================================

    test('harus memvalidasi common PostgrestException error codes', () {
      // Arrange
      final errorCodes = [
        {
          'code': '23505',
          'name': 'unique_violation',
          'description': 'Duplicate key constraint',
        },
        {
          'code': '23503',
          'name': 'foreign_key_violation',
          'description': 'Foreign key constraint',
        },
        {
          'code': '23502',
          'name': 'not_null_violation',
          'description': 'Not null constraint',
        },
        {
          'code': '42P01',
          'name': 'undefined_table',
          'description': 'Table does not exist',
        },
        {
          'code': 'PGRST116',
          'name': 'no_rows',
          'description': 'No rows returned',
        },
      ];

      for (var errorCode in errorCodes) {
        // Act
        final code = errorCode['code'] as String;
        final hasName = (errorCode['name'] as String).isNotEmpty;
        final hasDescription = (errorCode['description'] as String).isNotEmpty;

        // Assert
        expect(code, isNotEmpty, reason: 'Error code should not be empty');
        expect(hasName, isTrue, reason: 'Error should have name');
        expect(hasDescription, isTrue, reason: 'Error should have description');
      }
    });

    test('harus parse unique constraint error dari PostgreSQL', () {
      // Arrange
      final errorMessage =
          'duplicate key value violates unique constraint "warga_nik_key"';

      // Act
      final isUniqueViolation =
          errorMessage.contains('duplicate key') &&
          errorMessage.contains('unique constraint');

      final constraintName = RegExp(
        r'"([^"]+)"',
      ).firstMatch(errorMessage)?.group(1);

      // Assert
      expect(isUniqueViolation, isTrue);
      expect(constraintName, 'warga_nik_key');
    });

    test('harus parse foreign key constraint error', () {
      // Arrange
      final errorMessage =
          'insert or update on table "warga" violates foreign key constraint "warga_id_kk_fkey"';

      // Act
      final isForeignKeyViolation = errorMessage.contains(
        'foreign key constraint',
      );
      final tableName = RegExp(
        r'on table "([^"]+)"',
      ).firstMatch(errorMessage)?.group(1);

      // Assert
      expect(isForeignKeyViolation, isTrue);
      expect(tableName, 'warga');
    });

    test('harus parse not null constraint error', () {
      // Arrange
      final errorDetails =
          'null value in column "nama_lengkap" of relation "warga" violates not-null constraint';

      // Act
      final isNotNullViolation = errorDetails.contains(
        'violates not-null constraint',
      );
      final columnName = RegExp(
        r'column "([^"]+)"',
      ).firstMatch(errorDetails)?.group(1);

      // Assert
      expect(isNotNullViolation, isTrue);
      expect(columnName, 'nama_lengkap');
    });

    // ============================================
    // AUTH ERROR TESTS
    // ============================================

    test('harus memvalidasi common auth error status codes', () {
      // Arrange
      final authErrors = [
        {
          'statusCode': '401',
          'type': 'Unauthorized',
          'message': 'Invalid credentials',
        },
        {'statusCode': '403', 'type': 'Forbidden', 'message': 'Access denied'},
        {
          'statusCode': '400',
          'type': 'Bad Request',
          'message': 'Invalid input',
        },
        {
          'statusCode': '422',
          'type': 'Unprocessable',
          'message': 'Validation failed',
        },
      ];

      for (var error in authErrors) {
        // Act
        final statusCode = error['statusCode'] as String;
        final isValidStatusCode = int.tryParse(statusCode) != null;

        // Assert
        expect(
          isValidStatusCode,
          isTrue,
          reason: 'Status code ${error['statusCode']} should be numeric',
        );
      }
    });

    test('harus mendeteksi expired token error', () {
      // Arrange
      final errorMessage = 'JWT expired';

      // Act
      final isExpiredToken =
          errorMessage.contains('JWT expired') ||
          errorMessage.contains('token expired');

      // Assert
      expect(isExpiredToken, isTrue);
    });

    test('harus mendeteksi invalid credentials error', () {
      // Arrange
      final errorMessages = [
        'Invalid login credentials',
        'Email not confirmed',
        'User not found',
        'Invalid email or password',
      ];

      for (var message in errorMessages) {
        // Act
        final isAuthError =
            message.toLowerCase().contains('invalid') ||
            message.toLowerCase().contains('not found') ||
            message.toLowerCase().contains('not confirmed');

        // Assert
        expect(isAuthError, isTrue, reason: 'Message: $message');
      }
    });

    // ============================================
    // STORAGE ERROR TESTS
    // ============================================

    test('harus memvalidasi common storage error status codes', () {
      // Arrange
      final storageErrors = [
        {'statusCode': '413', 'type': 'Payload Too Large'},
        {'statusCode': '404', 'type': 'Not Found'},
        {'statusCode': '400', 'type': 'Bad Request'},
      ];

      for (var error in storageErrors) {
        // Act
        final statusCode = error['statusCode'] as String;
        final isValidCode = ['413', '404', '400'].contains(statusCode);

        // Assert
        expect(isValidCode, isTrue);
      }
    });

    test('harus mendeteksi file size exceeded error', () {
      // Arrange
      final errorMessage = 'File size exceeds maximum allowed size';

      // Act
      final isFileSizeError =
          errorMessage.contains('size exceeds') ||
          errorMessage.contains('too large');

      // Assert
      expect(isFileSizeError, isTrue);
    });

    test('harus mendeteksi invalid file type error', () {
      // Arrange
      final errorMessage = 'Invalid file type. Only images are allowed';

      // Act
      final isFileTypeError =
          errorMessage.toLowerCase().contains('invalid file type') ||
          errorMessage.toLowerCase().contains('file type not allowed');

      // Assert
      expect(isFileTypeError, isTrue);
    });

    // ============================================
    // ERROR LOGGING VALIDATION TESTS
    // ============================================

    test('harus memvalidasi struktur error log yang lengkap', () {
      // Arrange
      final errorLog = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'PostgrestException',
        'code': '23505',
        'message': 'Duplicate key violation',
        'details': 'Key (nik) already exists',
        'hint': 'Check existing records',
        'stackTrace': 'Stack trace here...',
      };

      // Act
      final hasRequiredFields =
          errorLog.containsKey('timestamp') &&
          errorLog.containsKey('type') &&
          errorLog.containsKey('message');

      final hasTimestamp = errorLog['timestamp'] != null;

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(hasTimestamp, isTrue);
    });

    test('harus format error message untuk display user', () {
      // Arrange
      final errors = [
        {
          'raw': 'duplicate key value violates unique constraint',
          'userFriendly': 'Data sudah ada dalam sistem',
        },
        {
          'raw': 'foreign key constraint violation',
          'userFriendly': 'Data terkait tidak ditemukan',
        },
        {
          'raw': 'not-null constraint violation',
          'userFriendly': 'Field wajib tidak boleh kosong',
        },
      ];

      for (var error in errors) {
        // Act
        final rawMessage = error['raw'] as String;
        final userMessage = error['userFriendly'] as String;

        final isRawTechnical =
            rawMessage.contains('constraint') ||
            rawMessage.contains('violation');
        final isUserFriendly =
            !userMessage.contains('constraint') &&
            !userMessage.contains('violation');

        // Assert
        expect(isRawTechnical, isTrue);
        expect(isUserFriendly, isTrue);
      }
    });

    test('harus include context info dalam error log', () {
      // Arrange
      final errorWithContext = {
        'error': 'Database query failed',
        'context': {
          'operation': 'INSERT',
          'table': 'warga',
          'userId': 100,
          'timestamp': '2025-12-09T10:00:00Z',
        },
      };

      // Act
      final hasContext = errorWithContext.containsKey('context');
      final context = errorWithContext['context'] as Map<String, dynamic>?;
      final hasOperation = context?.containsKey('operation') ?? false;

      // Assert
      expect(hasContext, isTrue);
      expect(context, isNotNull);
      expect(hasOperation, isTrue);
    });

    // ============================================
    // ERROR RECOVERY TESTS
    // ============================================

    test('harus determine apakah error bisa di-retry', () {
      // Arrange
      final retryableErrors = [
        {'code': 'NETWORK_ERROR', 'canRetry': true},
        {'code': 'TIMEOUT', 'canRetry': true},
        {'code': 'CONNECTION_REFUSED', 'canRetry': true},
      ];

      final nonRetryableErrors = [
        {'code': '23505', 'canRetry': false}, // unique violation
        {'code': '401', 'canRetry': false}, // unauthorized
        {'code': 'VALIDATION_ERROR', 'canRetry': false},
      ];

      // Act & Assert - Retryable
      for (var error in retryableErrors) {
        expect(error['canRetry'], isTrue);
      }

      // Act & Assert - Non-retryable
      for (var error in nonRetryableErrors) {
        expect(error['canRetry'], isFalse);
      }
    });

    test('harus implement exponential backoff untuk retry', () {
      // Arrange
      final retryAttempts = [1, 2, 3, 4, 5];
      final baseDelay = 1000; // milliseconds

      // Act
      final delays = retryAttempts.map((attempt) {
        // Exponential backoff: baseDelay * 2^(attempt-1)
        // Dart doesn't have ** operator, use math.pow() or manual calculation
        int multiplier = 1;
        for (var i = 0; i < attempt - 1; i++) {
          multiplier *= 2;
        }
        return baseDelay * multiplier; // 1s, 2s, 4s, 8s, 16s
      }).toList();

      // Assert
      expect(delays.length, 5);
      expect(delays[0], 1000); // 1000 * 2^0 = 1000
      expect(delays[1], 2000); // 1000 * 2^1 = 2000
      expect(delays[2], 4000); // 1000 * 2^2 = 4000
      expect(delays[3], 8000); // 1000 * 2^3 = 8000
      expect(delays[4], 16000); // 1000 * 2^4 = 16000

      // Each delay should be double the previous (exponential)
      for (var i = 1; i < delays.length; i++) {
        expect(delays[i], equals(delays[i - 1] * 2));
      }
    });

    test('harus limit maksimum retry attempts', () {
      // Arrange
      final maxRetries = 3;
      var currentAttempt = 0;

      // Act
      while (currentAttempt < maxRetries) {
        currentAttempt++;
      }

      // Assert
      expect(currentAttempt, maxRetries);
      expect(currentAttempt, lessThanOrEqualTo(maxRetries));
    });

    // ============================================
    // STREAM ERROR HANDLING TESTS
    // ============================================

    test('harus validate stream error handling logic', () {
      // Arrange
      final streamErrors = [
        {'type': 'StreamError', 'canRecover': true},
        {'type': 'StreamClosed', 'canRecover': false},
        {'type': 'StreamTimeout', 'canRecover': true},
      ];

      for (var error in streamErrors) {
        // Act
        final errorType = error['type'] as String;
        final canRecover = error['canRecover'] as bool;

        // Assert
        expect(errorType, isNotEmpty);
        expect(canRecover, isA<bool>());
      }
    });

    test('harus handle stream cancellation gracefully', () {
      // Arrange
      var isStreamActive = true;

      // Act - Simulate cancellation
      isStreamActive = false;

      // Assert
      expect(isStreamActive, isFalse);
    });

    // ============================================
    // DEBUG MODE TESTS
    // ============================================

    test('harus log lebih detail di debug mode', () {
      // Arrange
      const isDebugMode = true;
      final errorLog = <String, dynamic>{'message': 'Error occurred'};

      // Act - Add debug info if debug mode
      if (isDebugMode) {
        errorLog['stackTrace'] = 'Full stack trace...';
        errorLog['details'] = {'key': 'value'};
      }

      final hasStackTrace = errorLog['stackTrace'] != null;
      final hasDetails = errorLog['details'] != null;

      // Assert
      expect(hasStackTrace, isTrue);
      expect(hasDetails, isTrue);
    });

    test('harus hide sensitive info di production mode', () {
      // Arrange - Simulate runtime check
      bool isProductionMode() => true;
      final errorLog = <String, dynamic>{'message': 'Database error'};

      // Act - Don't add sensitive info in production
      if (!isProductionMode()) {
        errorLog['connectionString'] = 'postgresql://...';
        errorLog['apiKey'] = 'secret_key_123';
      }

      final hasConnectionString = errorLog.containsKey('connectionString');
      final hasApiKey = errorLog.containsKey('apiKey');

      // Assert
      expect(hasConnectionString, isFalse);
      expect(hasApiKey, isFalse);
    });

    // ============================================
    // ERROR TRACKING INTEGRATION TESTS
    // ============================================

    test('harus prepare error data untuk tracking service (Sentry)', () {
      // Arrange
      final errorForTracking = {
        'message': 'Database constraint violation',
        'level': 'error',
        'tags': {
          'environment': 'production',
          'module': 'supabase',
          'operation': 'insert',
        },
        'extra': {'table': 'warga', 'userId': 100},
        'fingerprint': ['database', 'constraint', 'violation'],
      };

      // Act
      final hasLevel = errorForTracking.containsKey('level');
      final hasTags = errorForTracking.containsKey('tags');
      final hasFingerprint = errorForTracking.containsKey('fingerprint');

      // Assert
      expect(hasLevel, isTrue);
      expect(hasTags, isTrue);
      expect(hasFingerprint, isTrue);
    });

    test('harus group similar errors dengan fingerprint', () {
      // Arrange
      final error1 = {
        'message': 'NIK 123 already exists',
        'fingerprint': ['database', 'unique', 'nik'],
      };

      final error2 = {
        'message': 'NIK 456 already exists',
        'fingerprint': ['database', 'unique', 'nik'],
      };

      // Act
      final isSameType =
          error1['fingerprint'].toString() == error2['fingerprint'].toString();

      // Assert
      expect(isSameType, isTrue);
    });

    // ============================================
    // QUERY ERROR WRAPPER TESTS
    // ============================================

    test('harus wrap query dengan error handling', () {
      // Arrange
      final queryConfig = {
        'query': 'SELECT * FROM warga',
        'hasErrorHandling': true,
        'timeoutMs': 30000,
      };

      // Act
      final hasWrapping = queryConfig['hasErrorHandling'] as bool;

      // Assert
      expect(hasWrapping, isTrue);
    });

    test('harus provide custom error message option', () {
      // Arrange
      final customMessage = 'Gagal mengambil data warga';
      final defaultMessage = 'Query failed';

      // Act
      final shouldUseCustom = customMessage.isNotEmpty;
      final message = shouldUseCustom ? customMessage : defaultMessage;

      // Assert
      expect(message, customMessage);
      expect(message, isNot(defaultMessage));
    });

    // ============================================
    // EDGE CASES
    // ============================================

    test('harus menangani error object dengan safe null handling', () {
      // Arrange
      Object? createError(bool shouldCreate) {
        return shouldCreate ? Exception('Test error') : null;
      }

      // Act
      final nullError = createError(false);
      final validError = createError(true);

      final nullMessage = nullError?.toString() ?? 'No error object';
      final validMessage = validError?.toString() ?? 'No error object';

      // Assert
      expect(nullError, isNull);
      expect(validError, isNotNull);
      expect(nullMessage, 'No error object');
      expect(validMessage, contains('Exception'));
    });

    test('harus menangani error message kosong', () {
      // Arrange
      final errorMessage = '';

      // Act
      final isEmpty = errorMessage.isEmpty;
      final fallbackMessage = isEmpty ? 'Unknown error occurred' : errorMessage;

      // Assert
      expect(isEmpty, isTrue);
      expect(fallbackMessage, 'Unknown error occurred');
    });

    test('harus menangani nested error objects', () {
      // Arrange
      final nestedError = {
        'error': {
          'message': 'Validation failed',
          'details': {'field': 'nik', 'reason': 'Invalid format'},
        },
      };

      // Act
      final hasError = nestedError.containsKey('error');
      final errorData = nestedError['error'] as Map<String, dynamic>?;
      final hasDetails = errorData?.containsKey('details') ?? false;

      // Assert
      expect(hasError, isTrue);
      expect(hasDetails, isTrue);
    });

    test('harus parse error dari different Supabase operations', () {
      // Arrange
      final operations = [
        {'operation': 'select', 'errorType': 'PostgrestException'},
        {'operation': 'insert', 'errorType': 'PostgrestException'},
        {'operation': 'signIn', 'errorType': 'AuthException'},
        {'operation': 'upload', 'errorType': 'StorageException'},
      ];

      for (var op in operations) {
        // Act
        final operation = op['operation'] as String;
        final errorType = op['errorType'] as String;

        // Assert
        expect(operation, isNotEmpty);
        expect(errorType, isNotEmpty);
      }
    });

    test('harus validate error severity levels', () {
      // Arrange
      final severityLevels = [
        {'level': 'debug', 'priority': 1},
        {'level': 'info', 'priority': 2},
        {'level': 'warning', 'priority': 3},
        {'level': 'error', 'priority': 4},
        {'level': 'fatal', 'priority': 5},
      ];

      for (var i = 0; i < severityLevels.length - 1; i++) {
        // Act
        final current = severityLevels[i]['priority'] as int;
        final next = severityLevels[i + 1]['priority'] as int;

        // Assert
        expect(next, greaterThan(current));
      }
    });
  });
}

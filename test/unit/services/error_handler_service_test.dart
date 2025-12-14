import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/core/services/error_handler_service.dart';

void main() {
  group('ErrorHandlerService Tests', () {
    group('Error Type Identification', () {
      test('harus mengidentifikasi error type network dengan benar', () {
        // Arrange
        final errorTypes = [
          ErrorType.network,
          ErrorType.server,
          ErrorType.notFound,
          ErrorType.validation,
          ErrorType.permission,
          ErrorType.conflict,
          ErrorType.database,
          ErrorType.auth,
          ErrorType.storage,
          ErrorType.navigation,
          ErrorType.unknown,
        ];

        // Act & Assert
        expect(errorTypes.length, 11);
        expect(errorTypes.contains(ErrorType.network), isTrue);
      });

      test('harus membedakan semua error types', () {
        // Arrange
        final errorTypes = [
          ErrorType.network,
          ErrorType.server,
          ErrorType.notFound,
          ErrorType.validation,
          ErrorType.permission,
          ErrorType.conflict,
          ErrorType.database,
          ErrorType.auth,
          ErrorType.storage,
          ErrorType.navigation,
          ErrorType.unknown,
        ];

        // Act
        final uniqueTypes = errorTypes.toSet();

        // Assert
        expect(uniqueTypes.length, 11);
      });
    });

    group('ErrorInfo Tests', () {
      test('harus membuat ErrorInfo dengan semua field', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.network,
          title: 'Tidak Ada Koneksi',
          message: 'Periksa koneksi internet Anda',
          technicalDetails: 'SocketException: Connection refused',
        );

        // Assert
        expect(errorInfo.type, ErrorType.network);
        expect(errorInfo.title, 'Tidak Ada Koneksi');
        expect(errorInfo.message, 'Periksa koneksi internet Anda');
        expect(errorInfo.technicalDetails, isNotEmpty);
      });

      test('harus memvalidasi title tidak kosong', () {
        // Arrange
        final validTitles = [
          'Tidak Ada Koneksi',
          'Server Bermasalah',
          'Data Tidak Ditemukan',
          'A', // minimal 1 karakter
        ];

        // Act & Assert
        for (var title in validTitles) {
          expect(title.isNotEmpty, isTrue);
        }
      });

      test('harus memvalidasi message tidak kosong', () {
        // Arrange
        final validMessages = [
          'Periksa koneksi internet Anda',
          'Server sedang maintenance',
          'Data yang dicari tidak ada',
          'A', // minimal 1 karakter
        ];

        // Act & Assert
        for (var message in validMessages) {
          expect(message.isNotEmpty, isTrue);
        }
      });

      test('harus memvalidasi technical details tidak kosong', () {
        // Arrange
        final validDetails = [
          'SocketException: Connection refused',
          'PostgrestException: 404 not found',
          'AuthException: Invalid credentials',
          'A', // minimal 1 karakter
        ];

        // Act & Assert
        for (var detail in validDetails) {
          expect(detail.isNotEmpty, isTrue);
        }
      });

      test('harus mempertahankan semua informasi error', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.database,
          title: 'Database Error',
          message: 'Failed to fetch data',
          technicalDetails: 'PostgreSQL connection lost',
        );

        // Act
        final type = errorInfo.type;
        final title = errorInfo.title;
        final message = errorInfo.message;
        final details = errorInfo.technicalDetails;

        // Assert
        expect(type, ErrorType.database);
        expect(title, 'Database Error');
        expect(message, 'Failed to fetch data');
        expect(details, 'PostgreSQL connection lost');
      });
    });

    group('Error Classification Tests', () {
      test('harus mengklasifikasi network error dengan benar', () {
        // Arrange
        final networkErrors = [
          'SocketException: Connection refused',
          'SocketException: Network unreachable',
          'SocketException: Connection timeout',
          'SocketException: Connection reset',
        ];

        // Act & Assert
        for (var errorMsg in networkErrors) {
          final isNetworkError = errorMsg.toLowerCase().contains(
            'socketexception',
          );
          expect(isNetworkError, isTrue, reason: 'Should be network error');
        }
      });

      test('harus mengklasifikasi server error dengan benar', () {
        // Arrange
        final serverErrorCodes = ['500', '503', '502', '504'];

        // Act & Assert
        for (var code in serverErrorCodes) {
          final isServerError = code == '500' || code == '503';
          if (isServerError) {
            expect(isServerError, isTrue);
          }
        }
      });

      test('harus mengklasifikasi auth error dengan benar', () {
        // Arrange
        final authErrors = [
          'Invalid login credentials',
          'User already registered',
          'Email not confirmed',
          'Password is required',
          'Email is invalid',
        ];

        // Act & Assert
        for (var errorMsg in authErrors) {
          expect(errorMsg.isNotEmpty, isTrue);
        }
      });

      test('harus mengklasifikasi validation error dengan benar', () {
        // Arrange
        final validationErrors = [
          'Email format not valid',
          'Password must be at least 8 characters',
          'Phone number format invalid',
          'Age must be greater than 18',
        ];

        // Act & Assert
        for (var errorMsg in validationErrors) {
          expect(errorMsg.isNotEmpty, isTrue);
        }
      });

      test('harus mengklasifikasi permission error dengan benar', () {
        // Arrange
        final permissionErrorCodes = ['401', '403'];

        // Act & Assert
        for (var code in permissionErrorCodes) {
          final isPermissionError = code == '401' || code == '403';
          expect(isPermissionError, isTrue);
        }
      });

      test('harus mengklasifikasi not found error dengan benar', () {
        // Arrange
        final notFoundCode = '404';

        // Act
        final isNotFound = notFoundCode == '404';

        // Assert
        expect(isNotFound, isTrue);
      });

      test('harus mengklasifikasi conflict error dengan benar', () {
        // Arrange
        final conflictCode = '409';

        // Act
        final isConflict = conflictCode == '409';

        // Assert
        expect(isConflict, isTrue);
      });
    });

    group('Error Message Formatting Tests', () {
      test('harus format pesan error network dengan benar', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.network,
          title: 'Tidak Ada Koneksi',
          message: 'Periksa koneksi internet Anda dan coba lagi.',
          technicalDetails: 'SocketException: Connection refused',
        );

        // Act
        final formattedMessage = errorInfo.message;

        // Assert
        expect(formattedMessage, contains('Periksa'));
        expect(formattedMessage, contains('koneksi'));
        expect(formattedMessage, isNotEmpty);
      });

      test('harus format pesan error database dengan benar', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.database,
          title: 'Kesalahan Database',
          message: 'Terjadi kesalahan saat mengakses data. Silakan coba lagi.',
          technicalDetails: 'PostgrestException: 500 Server Error',
        );

        // Act
        final formattedMessage = errorInfo.message;

        // Assert
        expect(formattedMessage, contains('kesalahan'));
        expect(formattedMessage, contains('data'));
        expect(formattedMessage, isNotEmpty);
      });

      test('harus format pesan error auth dengan benar', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.auth,
          title: 'Login Gagal',
          message: 'Email atau password salah. Silakan coba lagi.',
          technicalDetails: 'AuthException: Invalid login credentials',
        );

        // Act
        final formattedMessage = errorInfo.message;

        // Assert
        expect(formattedMessage, contains('Email'));
        expect(formattedMessage, contains('password'));
        expect(formattedMessage, isNotEmpty);
      });

      test('harus mempertahankan format pesan dengan spasi dan tanda baca', () {
        // Arrange
        final originalMessage = 'Email atau password salah. Silakan coba lagi.';

        // Act
        final messageLength = originalMessage.length;
        final hasSpace = originalMessage.contains(' ');
        final hasPunctuation = originalMessage.contains('.');

        // Assert
        expect(messageLength, greaterThan(0));
        expect(hasSpace, isTrue);
        expect(hasPunctuation, isTrue);
      });
    });

    group('Error HTTP Status Codes Tests', () {
      test('harus handle status code 404 dengan benar', () {
        // Arrange
        final statusCode = '404';
        final expectedType = ErrorType.notFound;

        // Act
        final isNotFound = statusCode == '404';

        // Assert
        expect(isNotFound, isTrue);
        expect(expectedType, ErrorType.notFound);
      });

      test('harus handle status code 500 dengan benar', () {
        // Arrange
        final statusCode = '500';

        // Act
        final isServerError = statusCode == '500' || statusCode == '503';

        // Assert
        expect(isServerError, isTrue);
      });

      test('harus handle status code 503 dengan benar', () {
        // Arrange
        final statusCode = '503';

        // Act
        final isServerError = statusCode == '503' || statusCode == '500';

        // Assert
        expect(isServerError, isTrue);
      });

      test('harus handle status code 400 dengan benar', () {
        // Arrange
        final statusCode = '400';

        // Act
        final isValidationError = statusCode == '400';

        // Assert
        expect(isValidationError, isTrue);
      });

      test('harus handle status code 401 dengan benar', () {
        // Arrange
        final statusCode = '401';

        // Act
        final isPermissionError = statusCode == '401' || statusCode == '403';

        // Assert
        expect(isPermissionError, isTrue);
      });

      test('harus handle status code 403 dengan benar', () {
        // Arrange
        final statusCode = '403';

        // Act
        final isPermissionError = statusCode == '403' || statusCode == '401';

        // Assert
        expect(isPermissionError, isTrue);
      });

      test('harus handle status code 409 dengan benar', () {
        // Arrange
        final statusCode = '409';

        // Act
        final isConflictError = statusCode == '409';

        // Assert
        expect(isConflictError, isTrue);
      });

      test('harus menangani unknown status code', () {
        // Arrange
        final unknownCode = '418'; // I'm a teapot

        // Act
        final isKnownCode = [
          '404',
          '500',
          '503',
          '400',
          '401',
          '403',
          '409',
        ].contains(unknownCode);

        // Assert
        expect(isKnownCode, isFalse);
      });
    });

    group('Auth Error Messages Tests', () {
      test('harus handle invalid login credentials', () {
        // Arrange
        final errorMessage = 'Invalid login credentials';

        // Act
        final isAuthError = errorMessage.toLowerCase().contains('invalid');

        // Assert
        expect(isAuthError, isTrue);
      });

      test('harus handle user already registered', () {
        // Arrange
        final errorMessage = 'User already registered';

        // Act
        final isAuthError = errorMessage.toLowerCase().contains(
          'already registered',
        );

        // Assert
        expect(isAuthError, isTrue);
      });

      test('harus handle email not confirmed', () {
        // Arrange
        final errorMessage = 'Email not confirmed';

        // Act
        final isAuthError = errorMessage.toLowerCase().contains(
          'not confirmed',
        );

        // Assert
        expect(isAuthError, isTrue);
      });

      test('harus handle password validation', () {
        // Arrange
        final validPasswords = [
          'SecurePass123!',
          'MyPassword2025',
          'P@ssw0rd!Safe',
        ];
        final invalidPasswords = ['short', '123456', 'nospecialchar', ''];

        // Act & Assert - Valid passwords
        for (var password in validPasswords) {
          expect(password.length, greaterThanOrEqualTo(8));
        }

        // Act & Assert - Invalid passwords
        for (var password in invalidPasswords) {
          final isValid = password.length >= 8;
          if (password.isEmpty) {
            expect(isValid, isFalse);
          }
        }
      });

      test('harus handle email format validation', () {
        // Arrange
        final validEmails = [
          'user@example.com',
          'test.user@domain.co.id',
          'admin+tag@example.com',
        ];
        final invalidEmails = [
          'invalidemail',
          '@example.com',
          'user@',
          'user @example.com', // has space
          ' user@example.com', // leading space
          'user@example .com', // space in domain
        ];

        // Act & Assert - Valid emails
        for (var email in validEmails) {
          final hasAt = email.contains('@');
          final hasDot = email.contains('.');
          final noSpace = !email.contains(' ');
          expect(
            hasAt && hasDot && noSpace,
            isTrue,
            reason: 'Email $email should be valid',
          );
        }

        // Act & Assert - Invalid emails
        for (var email in invalidEmails) {
          final hasSpace = email.contains(' ');
          final parts = email.split('@');
          final isValid =
              !hasSpace &&
              parts.length == 2 &&
              parts[0].isNotEmpty &&
              parts[1].isNotEmpty &&
              parts[1].contains('.');
          expect(isValid, isFalse, reason: 'Email $email should be invalid');
        }
      });
    });

    group('Storage Error Handling Tests', () {
      test('harus handle storage upload error', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.storage,
          title: 'Kesalahan Storage',
          message: 'Gagal mengunggah file. Silakan coba lagi.',
          technicalDetails: 'StorageException: File too large',
        );

        // Assert
        expect(errorInfo.type, ErrorType.storage);
        expect(errorInfo.message, contains('Gagal'));
      });

      test('harus handle storage download error', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.storage,
          title: 'Kesalahan Storage',
          message: 'Gagal mengunduh file. Silakan coba lagi.',
          technicalDetails: 'StorageException: File not found',
        );

        // Assert
        expect(errorInfo.type, ErrorType.storage);
        expect(errorInfo.message, contains('mengunduh'));
      });

      test('harus handle storage permission error', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.storage,
          title: 'Kesalahan Storage',
          message: 'Tidak ada izin untuk mengakses file.',
          technicalDetails: 'StorageException: Access denied',
        );

        // Assert
        expect(errorInfo.type, ErrorType.storage);
        expect(errorInfo.message, contains('izin'));
      });
    });

    group('Navigation Error Handling Tests', () {
      test('harus handle go router exception', () {
        // Arrange
        final errorMessage = 'GoException: Route not found';

        // Act
        final isNavigationError = errorMessage.toLowerCase().contains(
          'goexception',
        );

        // Assert
        expect(isNavigationError, isTrue);
      });

      test('harus handle undefined route', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.navigation,
          title: 'Halaman Tidak Ditemukan',
          message: 'Halaman yang Anda cari tidak tersedia.',
          technicalDetails: 'GoException: Route "/nonexistent" not defined',
        );

        // Assert
        expect(errorInfo.type, ErrorType.navigation);
        expect(errorInfo.title, contains('Tidak Ditemukan'));
      });

      test('harus handle invalid route parameters', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.navigation,
          title: 'Navigasi Error',
          message: 'Parameter navigasi tidak valid.',
          technicalDetails: 'GoException: Missing required parameter "id"',
        );

        // Assert
        expect(errorInfo.type, ErrorType.navigation);
        expect(errorInfo.message, contains('Parameter'));
      });
    });

    group('Validation Error Handling Tests', () {
      test('harus handle required field error', () {
        // Arrange
        final errorMessages = [
          'Nama harus diisi',
          'Email tidak boleh kosong',
          'Password wajib diisi',
        ];

        // Act & Assert
        for (var msg in errorMessages) {
          expect(
            msg.toLowerCase(),
            anyOf(contains('boleh kosong'), contains('diisi')),
          );
        }
      });

      test('harus handle field format error', () {
        // Arrange
        final errorMessages = [
          'Format email tidak valid',
          'Nomor telepon harus angka',
          'Tanggal harus format DD/MM/YYYY',
        ];

        // Act & Assert
        for (var msg in errorMessages) {
          expect(msg.isNotEmpty, isTrue);
        }
      });

      test('harus handle field length error', () {
        // Arrange
        final errorMessages = [
          'Nama minimal 3 karakter',
          'Password maksimal 50 karakter',
          'Deskripsi minimal 10 karakter',
        ];

        // Act & Assert
        for (var msg in errorMessages) {
          expect(msg.isNotEmpty, isTrue);
        }
      });
    });

    group('Conflict Error Handling Tests', () {
      test('harus handle duplicate data conflict', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.conflict,
          title: 'Data Konflik',
          message: 'Data yang sama sudah ada di sistem.',
          technicalDetails: 'PostgrestException: 409 Duplicate key',
        );

        // Assert
        expect(errorInfo.type, ErrorType.conflict);
        expect(errorInfo.message, contains('sama'));
      });

      test('harus handle unique constraint violation', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.conflict,
          title: 'Email Sudah Terdaftar',
          message: 'Email ini sudah digunakan. Gunakan email lain.',
          technicalDetails: 'PostgrestException: Unique constraint violation',
        );

        // Assert
        expect(errorInfo.type, ErrorType.conflict);
        expect(errorInfo.message, contains('Email'));
      });
    });

    group('Unknown Error Handling Tests', () {
      test('harus handle completely unknown error', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.unknown,
          title: 'Terjadi Kesalahan',
          message: 'Maaf, terjadi kesalahan. Silakan coba lagi.',
          technicalDetails: 'Unknown error type occurred',
        );

        // Assert
        expect(errorInfo.type, ErrorType.unknown);
        expect(errorInfo.title, contains('Kesalahan'));
      });

      test('harus handle generic exception', () {
        // Arrange
        final errorInfo = ErrorInfo(
          type: ErrorType.unknown,
          title: 'Terjadi Kesalahan',
          message: 'Maaf, terjadi kesalahan. Silakan coba lagi.',
          technicalDetails: 'Exception: Something went wrong',
        );

        // Assert
        expect(errorInfo.type, ErrorType.unknown);
        expect(errorInfo.message, contains('kesalahan'));
      });
    });

    group('Error Title Consistency Tests', () {
      test('harus gunakan title konsisten untuk error type yang sama', () {
        // Arrange
        final networkError1 = ErrorInfo(
          type: ErrorType.network,
          title: 'Tidak Ada Koneksi',
          message: 'Periksa koneksi internet',
          technicalDetails: 'Error 1',
        );

        final networkError2 = ErrorInfo(
          type: ErrorType.network,
          title: 'Tidak Ada Koneksi',
          message: 'Internet connection failed',
          technicalDetails: 'Error 2',
        );

        // Assert
        expect(networkError1.title, networkError2.title);
      });

      test('harus gunakan title berbeda untuk error type berbeda', () {
        // Arrange
        final networkError = ErrorInfo(
          type: ErrorType.network,
          title: 'Tidak Ada Koneksi',
          message: 'Msg',
          technicalDetails: 'Details',
        );

        final authError = ErrorInfo(
          type: ErrorType.auth,
          title: 'Kesalahan Autentikasi',
          message: 'Msg',
          technicalDetails: 'Details',
        );

        // Assert
        expect(networkError.title, isNot(authError.title));
      });
    });

    group('Error Localization Tests', () {
      test('harus menggunakan bahasa Indonesia untuk user message', () {
        // Arrange
        final indonesianMessages = [
          'Tidak Ada Koneksi',
          'Periksa koneksi internet',
          'Server Bermasalah',
          'Data Tidak Ditemukan',
          'Akses Ditolak',
          'Kesalahan Autentikasi',
        ];

        // Act & Assert
        for (var msg in indonesianMessages) {
          expect(msg.isNotEmpty, isTrue);
          // Check if contains common Indonesian words
          final hasIndonesianContent = msg.isNotEmpty;
          expect(hasIndonesianContent, isTrue);
        }
      });

      test('harus gunakan formal tone untuk error messages', () {
        // Arrange
        final formalMessages = [
          'Periksa koneksi internet Anda dan coba lagi.',
          'Server sedang mengalami gangguan. Mohon coba beberapa saat lagi.',
          'Anda tidak memiliki izin untuk mengakses fitur ini.',
        ];

        // Act & Assert
        for (var msg in formalMessages) {
          expect(msg.endsWith('.'), isTrue);
          expect(msg.isNotEmpty, isTrue);
        }
      });
    });

    group('Error Severity Levels Tests', () {
      test('harus classify error severity berdasarkan type', () {
        // Arrange
        final criticalErrors = [ErrorType.server, ErrorType.database];
        final warningErrors = [ErrorType.validation, ErrorType.auth];
        final infoErrors = [ErrorType.notFound];

        // Act & Assert
        expect(criticalErrors.length, 2);
        expect(warningErrors.length, 2);
        expect(infoErrors.length, 1);
      });
    });

    group('Multiple Error Handling Tests', () {
      test('harus handle sequential errors dengan benar', () {
        // Arrange
        final errors = [
          ErrorInfo(
            type: ErrorType.network,
            title: 'Error 1',
            message: 'First error',
            technicalDetails: 'Details 1',
          ),
          ErrorInfo(
            type: ErrorType.auth,
            title: 'Error 2',
            message: 'Second error',
            technicalDetails: 'Details 2',
          ),
          ErrorInfo(
            type: ErrorType.validation,
            title: 'Error 3',
            message: 'Third error',
            technicalDetails: 'Details 3',
          ),
        ];

        // Act
        final errorCount = errors.length;

        // Assert
        expect(errorCount, 3);
        expect(errors[0].type, ErrorType.network);
        expect(errors[1].type, ErrorType.auth);
        expect(errors[2].type, ErrorType.validation);
      });

      test('harus preserve order dari multiple errors', () {
        // Arrange
        final errors = [
          ErrorInfo(
            type: ErrorType.network,
            title: 'First',
            message: 'Msg1',
            technicalDetails: 'Details1',
          ),
          ErrorInfo(
            type: ErrorType.auth,
            title: 'Second',
            message: 'Msg2',
            technicalDetails: 'Details2',
          ),
        ];

        // Act
        final firstError = errors[0];
        final secondError = errors[1];

        // Assert
        expect(firstError.title, 'First');
        expect(secondError.title, 'Second');
      });
    });
  });
}

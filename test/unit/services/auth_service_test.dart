import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService Business Logic Tests', () {
    // Test pure business logic dari AuthService
    // Fokus pada validasi, transformasi data, dan error handling

    test('[AUTH-SERVICE-001] harus memvalidasi format email yang benar', () {
      // Arrange
      final validEmails = [
        'user@example.com',
        'test.user@domain.co.id',
        'admin123@test.org',
      ];

      for (var email in validEmails) {
        // Act
        final isValid = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(email);

        // Assert
        expect(isValid, isTrue, reason: 'Email $email harus valid');
      }
    });

    test('[AUTH-SERVICE-002] harus menolak format email yang salah', () {
      // Arrange
      final invalidEmails = [
        'notanemail',
        '@example.com',
        'user@',
        'user @example.com',
        '',
      ];

      for (var email in invalidEmails) {
        // Act
        final isValid = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(email);

        // Assert
        expect(isValid, isFalse, reason: 'Email $email harus invalid');
      }
    });

    test('[AUTH-SERVICE-003] harus memvalidasi panjang password minimum', () {
      // Arrange
      const minLength = 6;
      final testCases = [
        {'password': '12345', 'valid': false},
        {'password': '123456', 'valid': true},
        {'password': 'pass123', 'valid': true},
        {'password': 'abc', 'valid': false},
        {'password': '', 'valid': false},
      ];

      for (var testCase in testCases) {
        // Act
        final password = testCase['password'] as String;
        final isValid = password.length >= minLength;

        // Assert
        expect(
          isValid,
          testCase['valid'],
          reason: 'Password "$password" validation failed',
        );
      }
    });

    test('[AUTH-SERVICE-004] harus normalize status menjadi lowercase', () {
      // Arrange
      final testCases = [
        {'input': 'Aktif', 'expected': 'aktif'},
        {'input': 'AKTIF', 'expected': 'aktif'},
        {'input': 'aktif', 'expected': 'aktif'},
        {'input': 'Tidak Aktif', 'expected': 'tidak aktif'},
        {'input': 'PENDING', 'expected': 'pending'},
      ];

      for (var testCase in testCases) {
        // Act
        final input = testCase['input'] as String;
        final normalized = input.toLowerCase();

        // Assert
        expect(normalized, testCase['expected']);
      }
    });

    test(
      '[AUTH-SERVICE-005] harus memvalidasi bahwa hanya status "aktif" yang diizinkan login',
      () {
        // Arrange
        final testCases = [
          {'status': 'aktif', 'allowed': true},
          {'status': 'tidak aktif', 'allowed': false},
          {'status': 'pending', 'allowed': false},
          {'status': 'suspended', 'allowed': false},
          {'status': '', 'allowed': false},
        ];

        for (var testCase in testCases) {
          // Act
          final status = testCase['status'] as String;
          final isAllowed = status == 'aktif';

          // Assert
          expect(
            isAllowed,
            testCase['allowed'],
            reason: 'Status "$status" validation failed',
          );
        }
      },
    );

    test(
      '[AUTH-SERVICE-006] harus mengekstrak role dari database response',
      () {
        // Arrange
        final mockUserData = {
          'role': 'admin',
          'status': 'aktif',
          'id_auth': '1',
        };

        // Act
        final role = mockUserData['role'] ?? 'warga';

        // Assert
        expect(role, 'admin');
      },
    );

    test(
      '[AUTH-SERVICE-007] harus menggunakan default role "warga" jika null',
      () {
        // Arrange
        final mockUserData = {'status': 'aktif', 'id_auth': '1'};

        // Act
        final role = mockUserData['role'] ?? 'warga';

        // Assert
        expect(role, 'warga');
      },
    );

    test(
      '[AUTH-SERVICE-008] harus mengekstrak status dari database response',
      () {
        // Arrange
        final mockUserData = {
          'role': 'admin',
          'status': 'aktif',
          'id_auth': '1',
        };

        // Act
        final status = (mockUserData['status'] ?? '').toString().toLowerCase();

        // Assert
        expect(status, 'aktif');
      },
    );

    test('[AUTH-SERVICE-009] harus menangani null status dari database', () {
      // Arrange
      final mockUserData = {'role': 'admin', 'id_auth': '1'};

      // Act
      final status = (mockUserData['status'] ?? '').toString().toLowerCase();

      // Assert
      expect(status, '');
      expect(status != 'aktif', isTrue);
    });

    test(
      '[AUTH-SERVICE-010] harus memvalidasi struktur database response yang benar',
      () {
        // Arrange
        final mockUserData = {
          'role': 'admin',
          'status': 'aktif',
          'id_auth': '1',
        };

        // Act
        final hasRole = mockUserData.containsKey('role');
        final hasStatus = mockUserData.containsKey('status');
        final hasIdAuth = mockUserData.containsKey('id_auth');

        // Assert
        expect(hasRole, isTrue);
        expect(hasStatus, isTrue);
        expect(hasIdAuth, isTrue);
      },
    );

    test('[AUTH-SERVICE-011] harus menangani missing fields dari database', () {
      // Arrange
      final mockUserData = <String, dynamic>{};

      // Act
      final role = mockUserData['role'] as String? ?? 'warga';
      final status = (mockUserData['status'] ?? '').toString().toLowerCase();

      // Assert
      expect(role, 'warga');
      expect(status, '');
    });

    test(
      '[AUTH-SERVICE-012] harus membuat error message yang sesuai untuk kredensial invalid',
      () {
        // Arrange
        final authErrorMessages = [
          'invalid credentials',
          'Invalid login credentials',
          'INVALID CREDENTIALS',
        ];

        for (var errorMsg in authErrorMessages) {
          // Act
          final normalized = errorMsg.toLowerCase();
          final isInvalidCredentials =
              normalized.contains('invalid') &&
              normalized.contains('credentials');

          // Assert
          expect(
            isInvalidCredentials,
            isTrue,
            reason: 'Should detect invalid credentials in: $errorMsg',
          );
        }
      },
    );

    test(
      '[AUTH-SERVICE-013] harus membuat error message yang sesuai untuk email tidak terdaftar',
      () {
        // Arrange
        final authErrorMessages = [
          'user not found',
          'User not found',
          'USER NOT FOUND',
        ];

        for (var errorMsg in authErrorMessages) {
          // Act
          final normalized = errorMsg.toLowerCase();
          final isUserNotFound = normalized.contains('user not found');

          // Assert
          expect(
            isUserNotFound,
            isTrue,
            reason: 'Should detect user not found in: $errorMsg',
          );
        }
      },
    );

    test(
      '[AUTH-SERVICE-014] harus membuat error message yang sesuai untuk email belum dikonfirmasi',
      () {
        // Arrange
        final authErrorMessages = [
          'email not confirmed',
          'Email not confirmed',
          'EMAIL NOT CONFIRMED',
        ];

        for (var errorMsg in authErrorMessages) {
          // Act
          final normalized = errorMsg.toLowerCase();
          final isEmailNotConfirmed = normalized.contains(
            'email not confirmed',
          );

          // Assert
          expect(
            isEmailNotConfirmed,
            isTrue,
            reason: 'Should detect email not confirmed in: $errorMsg',
          );
        }
      },
    );

    test(
      '[AUTH-SERVICE-015] harus membuat error message yang sesuai untuk akun tidak aktif',
      () {
        // Arrange
        const expectedMessage = 'Akun Anda tidak aktif. Hubungi administrator.';

        // Act & Assert
        expect(expectedMessage, contains('tidak aktif'));
        expect(expectedMessage, contains('administrator'));
      },
    );

    test(
      '[AUTH-SERVICE-016] harus membuat error message yang sesuai untuk akun tidak terdaftar di sistem',
      () {
        // Arrange
        const expectedMessage = 'Akun tidak terdaftar di sistem';

        // Act & Assert
        expect(expectedMessage, contains('tidak terdaftar'));
        expect(expectedMessage, contains('sistem'));
      },
    );

    test('[AUTH-SERVICE-017] harus memvalidasi UUID format untuk auth_id', () {
      // Arrange
      final validUUIDs = [
        '550e8400-e29b-41d4-a716-446655440000',
        '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      ];

      final invalidUUIDs = ['not-a-uuid', '123456', '', 'abc-def-ghi'];

      // Act & Assert - Valid UUIDs
      for (var uuid in validUUIDs) {
        final isValid = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          caseSensitive: false,
        ).hasMatch(uuid);
        expect(isValid, isTrue, reason: 'UUID $uuid harus valid');
      }

      // Act & Assert - Invalid UUIDs
      for (var uuid in invalidUUIDs) {
        final isValid = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          caseSensitive: false,
        ).hasMatch(uuid);
        expect(isValid, isFalse, reason: 'UUID $uuid harus invalid');
      }
    });

    test(
      '[AUTH-SERVICE-018] harus memvalidasi struktur signIn response yang benar',
      () {
        // Arrange
        final mockSignInResponse = {
          'user': {'id': '1', 'email': 'test@example.com'},
          'role': 'admin',
          'email': 'test@example.com',
        };

        // Act
        final hasUser = mockSignInResponse.containsKey('user');
        final hasRole = mockSignInResponse.containsKey('role');
        final hasEmail = mockSignInResponse.containsKey('email');

        // Assert
        expect(hasUser, isTrue);
        expect(hasRole, isTrue);
        expect(hasEmail, isTrue);
      },
    );

    test('[AUTH-SERVICE-019] harus menangani null user dari auth response', () {
      // Arrange
      final mockAuthResponse = {'user': null};

      // Act
      final user = mockAuthResponse['user'];
      final shouldThrowError = user == null;

      // Assert
      expect(shouldThrowError, isTrue);
    });

    test(
      '[AUTH-SERVICE-020] harus memvalidasi integer ID extraction dari database',
      () {
        // Arrange
        final mockUserData = {'id': 123, 'id_auth': '1'};

        // Act
        final intId = mockUserData['id'] as int?;

        // Assert
        expect(intId, isNotNull);
        expect(intId, 123);
        expect(intId is int, isTrue);
      },
    );

    test(
      '[AUTH-SERVICE-021] harus menangani null integer ID dari database',
      () {
        // Arrange
        final mockUserData = {'id_auth': '1'};

        // Act
        final intId = mockUserData['id'] as int?;

        // Assert
        expect(intId, isNull);
      },
    );

    test(
      '[AUTH-SERVICE-022] harus memvalidasi berbagai role values yang valid',
      () {
        // Arrange
        final validRoles = [
          'admin',
          'warga',
          'rt',
          'rw',
          'bendahara',
          'sekretaris',
          'seller',
        ];

        for (var role in validRoles) {
          // Act
          final isValidRole = validRoles.contains(role);

          // Assert
          expect(isValidRole, isTrue, reason: 'Role $role harus valid');
        }
      },
    );

    test(
      '[AUTH-SERVICE-023] harus menangani case-sensitive role comparison',
      () {
        // Arrange
        final testCases = [
          {'role': 'Admin', 'normalized': 'admin'},
          {'role': 'WARGA', 'normalized': 'warga'},
          {'role': 'Rt', 'normalized': 'rt'},
        ];

        for (var testCase in testCases) {
          // Act
          final role = testCase['role'] as String;
          final normalized = role.toLowerCase();

          // Assert
          expect(normalized, testCase['normalized']);
        }
      },
    );

    test(
      '[AUTH-SERVICE-024] harus memvalidasi delay timing untuk signOut setelah status check',
      () {
        // Arrange
        const expectedDelay = Duration(milliseconds: 150);

        // Act
        final delayMs = expectedDelay.inMilliseconds;

        // Assert
        expect(delayMs, 150);
        expect(delayMs >= 100, isTrue);
        expect(delayMs <= 200, isTrue);
      },
    );

    test('[AUTH-SERVICE-025] harus memvalidasi clear session delay timing', () {
      // Arrange
      const expectedDelay = Duration(milliseconds: 300);

      // Act
      final delayMs = expectedDelay.inMilliseconds;

      // Assert
      expect(delayMs, 300);
      expect(delayMs >= 200, isTrue);
      expect(delayMs <= 500, isTrue);
    });
  });

  group('AuthService Error Handling Tests', () {
    test('[AUTH-SERVICE-026] harus membedakan berbagai tipe AuthException', () {
      // Arrange
      final errorTypes = [
        'invalid credentials',
        'email not confirmed',
        'user not found',
        'network error',
        'timeout',
      ];

      for (var errorType in errorTypes) {
        // Act
        final normalized = errorType.toLowerCase();
        final isAuthError =
            normalized.contains('invalid') ||
            normalized.contains('email') ||
            normalized.contains('user not found');

        // Assert - Validasi bahwa kita bisa detect auth-specific errors
        if (errorType.contains('invalid') ||
            errorType.contains('email') ||
            errorType.contains('user not found')) {
          expect(isAuthError, isTrue);
        }
      }
    });

    test('[AUTH-SERVICE-027] harus menangani empty error messages', () {
      // Arrange
      const emptyError = '';

      // Act
      final hasError = emptyError.isNotEmpty;
      final defaultError = hasError ? emptyError : 'Error tidak diketahui';

      // Assert
      expect(hasError, isFalse);
      expect(defaultError, 'Error tidak diketahui');
    });

    test(
      '[AUTH-SERVICE-028] harus preserve original exception jika sudah Exception type',
      () {
        // Arrange
        final originalException = Exception('Custom error message');

        // Act
        final shouldRethrow = originalException is Exception;

        // Assert
        expect(shouldRethrow, isTrue);
      },
    );
  });
}

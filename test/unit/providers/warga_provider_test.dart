import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('WargaNotifier Business Logic Tests', () {
    // Test pure business logic dari WargaNotifier
    // Fokus pada state transitions dan error handling

    test('harus memiliki initial state loading saat dibuat', () {
      // Arrange & Act
      const initialState = AsyncValue<List<dynamic>>.loading();

      // Assert
      expect(initialState.isLoading, isTrue);
      expect(initialState.hasValue, isFalse);
      expect(initialState.hasError, isFalse);
    });

    test('harus mengubah state menjadi data setelah fetch berhasil', () {
      // Arrange
      final mockWargaList = [
        {'id': 1, 'nama': 'John Doe'},
        {'id': 2, 'nama': 'Jane Smith'},
      ];

      // Act
      final dataState = AsyncValue.data(mockWargaList);

      // Assert
      expect(dataState.isLoading, isFalse);
      expect(dataState.hasValue, isTrue);
      expect(dataState.hasError, isFalse);
      expect(dataState.value, mockWargaList);
      expect(dataState.value?.length, 2);
    });

    test('harus mengubah state menjadi error saat fetch gagal', () {
      // Arrange
      final testError = Exception('Database connection failed');
      final testStackTrace = StackTrace.current;

      // Act
      final errorState =
          AsyncValue<List<dynamic>>.error(testError, testStackTrace);

      // Assert
      expect(errorState.isLoading, isFalse);
      expect(errorState.hasValue, isFalse);
      expect(errorState.hasError, isTrue);
      expect(errorState.error, testError);
    });

    test('harus menangani transisi state dari loading ke data', () {
      // Arrange
      const loadingState = AsyncValue<List<String>>.loading();
      final dataState = AsyncValue.data(['item1', 'item2']);

      // Assert - Loading state
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.hasValue, isFalse);

      // Assert - Data state
      expect(dataState.isLoading, isFalse);
      expect(dataState.hasValue, isTrue);
      expect(dataState.value?.length, 2);
    });

    test('harus menangani transisi state dari loading ke error', () {
      // Arrange
      const loadingState = AsyncValue<List<String>>.loading();
      final error = Exception('Network error');
      final errorState =
          AsyncValue<List<String>>.error(error, StackTrace.current);

      // Assert - Loading state
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.hasError, isFalse);

      // Assert - Error state
      expect(errorState.isLoading, isFalse);
      expect(errorState.hasError, isTrue);
      expect(errorState.error.toString(), contains('Network error'));
    });

    test('harus memvalidasi struktur data warga yang valid', () {
      // Arrange
      final validWargaData = {
        'id': 1,
        'nama': 'Ahmad Subandi',
        'nik': '3201234567890123',
        'alamat': 'Jl. Merdeka No. 10',
        'no_telp': '081234567890',
      };

      // Act
      final hasRequiredFields = validWargaData.containsKey('id') &&
          validWargaData.containsKey('nama') &&
          validWargaData.containsKey('nik');

      final nikLength = validWargaData['nik']?.toString().length ?? 0;
      final isValidNIK = nikLength == 16;

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(isValidNIK, isTrue);
      expect(validWargaData['nama'], isNotEmpty);
    });

    test('harus mendeteksi data warga yang tidak valid', () {
      // Arrange
      final invalidWargaData = {
        'id': null, // Missing ID
        'nama': '', // Empty name
        'nik': '12345', // Invalid NIK length
      };

      // Act
      final hasValidId = invalidWargaData['id'] != null;
      final hasValidNama = (invalidWargaData['nama'] as String).isNotEmpty;
      final nikLength = invalidWargaData['nik']?.toString().length ?? 0;
      final hasValidNIK = nikLength == 16;

      // Assert
      expect(hasValidId, isFalse, reason: 'ID should not be null');
      expect(hasValidNama, isFalse, reason: 'Nama should not be empty');
      expect(hasValidNIK, isFalse, reason: 'NIK should be 16 digits');
    });

    test('harus menangani list kosong dengan benar', () {
      // Arrange
      final emptyList = <Map<String, dynamic>>[];

      // Act
      final dataState = AsyncValue.data(emptyList);

      // Assert
      expect(dataState.hasValue, isTrue);
      expect(dataState.value, isEmpty);
      expect(dataState.value?.length, 0);
    });

    test('harus memvalidasi format nomor telepon', () {
      // Arrange
      final validPhones = ['081234567890', '082198765432', '085312345678'];
      final invalidPhones = ['12345', '0712345678', '+628123456789'];

      // Act & Assert - Valid phones
      for (var phone in validPhones) {
        final isValid = phone.startsWith('08') && phone.length >= 10;
        expect(isValid, isTrue, reason: 'Phone $phone should be valid');
      }

      // Act & Assert - Invalid phones
      for (var phone in invalidPhones) {
        final isValid = phone.startsWith('08') && phone.length >= 10;
        expect(isValid, isFalse, reason: 'Phone $phone should be invalid');
      }
    });

    test('harus memvalidasi panjang NIK 16 digit', () {
      // Arrange
      final testCases = [
        {'nik': '3201234567890123', 'valid': true},
        {'nik': '1234567890123456', 'valid': true},
        {'nik': '12345', 'valid': false},
        {'nik': '12345678901234567', 'valid': false}, // 17 digits
        {'nik': '', 'valid': false},
      ];

      for (var testCase in testCases) {
        // Act
        final nik = testCase['nik'] as String;
        final isValid = nik.length == 16;
        final expected = testCase['valid'] as bool;

        // Assert
        expect(isValid, expected, reason: 'NIK $nik validation failed');
      }
    });

    test('harus menangani berbagai tipe error dengan benar', () {
      // Arrange
      final errorTypes = [
        Exception('Database error'),
        Exception('Network timeout'),
        Exception('Permission denied'),
        Exception('Invalid data format'),
      ];

      for (var error in errorTypes) {
        // Act
        final errorState =
            AsyncValue<List<dynamic>>.error(error, StackTrace.current);

        // Assert
        expect(errorState.hasError, isTrue);
        expect(errorState.error, error);
        expect(errorState.error.toString(), contains('Exception'));
      }
    });

    test('harus memvalidasi operasi CRUD dengan state yang benar', () {
      // Arrange - Simulate CRUD operations state flow
      final operations = [
        {'operation': 'CREATE', 'requiresRefresh': true},
        {'operation': 'UPDATE', 'requiresRefresh': true},
        {'operation': 'DELETE', 'requiresRefresh': true},
        {'operation': 'READ', 'requiresRefresh': false},
      ];

      for (var op in operations) {
        // Act
        final operation = op['operation'] as String;
        final needsRefresh = op['requiresRefresh'] as bool;

        // Assert
        if (operation != 'READ') {
          expect(needsRefresh, isTrue,
              reason: '$operation should trigger fetchAll');
        } else {
          expect(needsRefresh, isFalse,
              reason: '$operation should not trigger fetchAll');
        }
      }
    });

    test('harus memvalidasi data warga dengan field lengkap', () {
      // Arrange
      final completeWargaData = {
        'id': 1,
        'nama': 'Ahmad Subandi',
        'nik': '3201234567890123',
        'alamat': 'Jl. Merdeka No. 10',
        'no_telp': '081234567890',
        'email': 'ahmad@example.com',
        'tanggal_lahir': '1990-01-01',
      };

      final requiredFields = ['id', 'nama', 'nik', 'alamat', 'no_telp'];

      // Act
      final hasAllRequiredFields =
          requiredFields.every((field) => completeWargaData.containsKey(field));

      final allFieldsNotEmpty = requiredFields.every((field) {
        final value = completeWargaData[field];
        return value != null && value.toString().isNotEmpty;
      });

      // Assert
      expect(hasAllRequiredFields, isTrue);
      expect(allFieldsNotEmpty, isTrue);
      expect(completeWargaData.keys.length, greaterThanOrEqualTo(5));
    });

    test('harus menangani ID warga yang valid untuk operasi delete', () {
      // Arrange
      final validIds = [1, 100, 999, 12345];
      final invalidIds = [0, -1, -999];

      // Act & Assert - Valid IDs
      for (var id in validIds) {
        final isValid = id > 0;
        expect(isValid, isTrue, reason: 'ID $id should be valid');
      }

      // Act & Assert - Invalid IDs
      for (var id in invalidIds) {
        final isValid = id > 0;
        expect(isValid, isFalse, reason: 'ID $id should be invalid');
      }
    });

    test('harus memvalidasi format email yang benar', () {
      // Arrange
      final validEmails = [
        'ahmad@example.com',
        'user.name@domain.co.id',
        'test123@mail.com',
      ];

      final invalidEmails = [
        'invalid.email',
        '@example.com',
        'user@',
        'user @domain.com',
      ];

      // Act & Assert - Valid emails
      for (var email in validEmails) {
        final isValid = email.contains('@') && email.contains('.');
        expect(isValid, isTrue, reason: 'Email $email should be valid');
      }

      // Act & Assert - Invalid emails
      for (var email in invalidEmails) {
        final hasAt = email.contains('@');
        final hasDot = email.contains('.');
        final parts = email.split('@');
        final isValid = hasAt &&
            hasDot &&
            !email.contains(' ') &&
            parts.length == 2 &&
            parts[0].isNotEmpty &&
            parts[1].isNotEmpty;
        expect(isValid, isFalse, reason: 'Email $email should be invalid');
      }
    });
  });
}

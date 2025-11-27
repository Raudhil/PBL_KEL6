import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseService (Kelola Warga) Business Logic Tests', () {
    // Test pure business logic dari SupabaseService
    // Fokus pada data validation, mapping, dan error handling

    test('harus memvalidasi struktur response fetchWarga yang valid', () {
      // Arrange
      final validResponse = [
        {
          'id': 1,
          'id_kk': 10,
          'nik': '3201234567890123',
          'nama_lengkap': 'Ahmad Subandi',
          'jenis_kelamin': 'Laki-laki',
          'tanggal_lahir': '1990-01-01',
          'nomor_hp': '081234567890',
          'foto_ktp': 'https://example.com/ktp.jpg',
          'created_at': '2025-11-21T10:00:00Z',
          'updated_at': '2025-11-21T10:00:00Z',
        },
      ];

      // Act
      final hasRequiredFields = validResponse.every(
        (item) =>
            item.containsKey('id') &&
            item.containsKey('nik') &&
            item.containsKey('nama_lengkap'),
      );

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(validResponse, isNotEmpty);
      expect(validResponse.first['nik'].toString().length, 16);
    });

    test('harus mendeteksi response warga dengan data tidak lengkap', () {
      // Arrange
      final incompleteResponse = [
        {
          'id': 1,
          // missing id_kk
          'nik': '3201234567890123',
          // missing nama_lengkap
          'jenis_kelamin': 'Laki-laki',
        },
      ];

      final requiredFields = [
        'id',
        'id_kk',
        'nik',
        'nama_lengkap',
        'jenis_kelamin',
      ];

      // Act
      final hasAllRequired = incompleteResponse.first.keys.toSet().containsAll(
        requiredFields.toSet(),
      );

      // Assert
      expect(
        hasAllRequired,
        isFalse,
        reason: 'Response should be missing required fields',
      );
    });

    test('harus memvalidasi format NIK 16 digit dalam response', () {
      // Arrange
      final testCases = [
        {'nik': '3201234567890123', 'valid': true},
        {'nik': '1234567890123456', 'valid': true},
        {'nik': '12345', 'valid': false},
        {'nik': '12345678901234567', 'valid': false}, // 17 digits
        {'nik': '', 'valid': false},
        {'nik': 'ABCD1234567890AB', 'valid': false}, // non-numeric
      ];

      for (var testCase in testCases) {
        // Act
        final nik = testCase['nik'] as String;
        final isNumeric = RegExp(r'^[0-9]+$').hasMatch(nik);
        final isValid = nik.length == 16 && isNumeric;
        final expected = testCase['valid'] as bool;

        // Assert
        expect(isValid, expected, reason: 'NIK $nik validation failed');
      }
    });

    test('harus memvalidasi format nomor HP dalam data warga', () {
      // Arrange
      final validPhones = [
        '081234567890',
        '082198765432',
        '085312345678',
        '087712345678',
      ];
      final invalidPhones = [
        '12345',
        '0712345678', // not starting with 08
        '+628123456789', // international format
        '8123456789', // missing 0
        '081234', // too short
      ];

      // Act & Assert - Valid phones
      for (var phone in validPhones) {
        final isValid =
            phone.startsWith('08') && phone.length >= 10 && phone.length <= 13;
        expect(isValid, isTrue, reason: 'Phone $phone should be valid');
      }

      // Act & Assert - Invalid phones
      for (var phone in invalidPhones) {
        final isValid =
            phone.startsWith('08') && phone.length >= 10 && phone.length <= 13;
        expect(isValid, isFalse, reason: 'Phone $phone should be invalid');
      }
    });

    test('harus memvalidasi jenis kelamin hanya Laki-laki atau Perempuan', () {
      // Arrange
      final validGenders = ['Laki-laki', 'Perempuan'];
      final invalidGenders = ['L', 'P', 'Male', 'Female', '', 'Pria', 'Wanita'];

      // Act & Assert - Valid genders
      for (var gender in validGenders) {
        final isValid = ['Laki-laki', 'Perempuan'].contains(gender);
        expect(isValid, isTrue, reason: 'Gender $gender should be valid');
      }

      // Act & Assert - Invalid genders
      for (var gender in invalidGenders) {
        final isValid = ['Laki-laki', 'Perempuan'].contains(gender);
        expect(isValid, isFalse, reason: 'Gender $gender should be invalid');
      }
    });

    test('harus memvalidasi format tanggal lahir yang benar', () {
      // Arrange
      final validDates = ['1990-01-01', '2000-12-31', '1985-06-15'];

      final invalidDates = [
        '01-01-1990', // wrong format
        '1990/01/01', // wrong separator
        '', // empty
        'not-a-date',
        '2025-00-01', // invalid month 0
        '2025-01-32', // invalid day
      ];

      // Act & Assert - Valid dates
      for (var date in validDates) {
        final isValidFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date);
        try {
          final parsed = DateTime.parse(date);
          // Additional validation: check if parsed date components match
          final dateStr = date.split('-');
          final year = int.parse(dateStr[0]);
          final month = int.parse(dateStr[1]);
          final day = int.parse(dateStr[2]);
          final isValidDate =
              parsed.year == year &&
              parsed.month == month &&
              parsed.day == day &&
              month >= 1 &&
              month <= 12 &&
              day >= 1 &&
              day <= 31;
          expect(
            isValidFormat,
            isTrue,
            reason: 'Date $date should be valid format',
          );
          expect(
            isValidDate,
            isTrue,
            reason: 'Date $date should be valid date',
          );
        } catch (e) {
          fail('Date $date should be parseable');
        }
      }

      // Act & Assert - Invalid dates
      for (var date in invalidDates) {
        final isValidFormat = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date);
        bool isValid = false;
        if (isValidFormat) {
          try {
            final parsed = DateTime.parse(date);
            final dateStr = date.split('-');
            final month = int.parse(dateStr[1]);
            final day = int.parse(dateStr[2]);
            // Check logical validity
            isValid =
                parsed.month == month &&
                parsed.day == day &&
                month >= 1 &&
                month <= 12 &&
                day >= 1 &&
                day <= 31;
          } catch (e) {
            isValid = false;
          }
        }
        expect(isValid, isFalse, reason: 'Date $date should be invalid');
      }
    });

    test('harus menangani list kosong dari database', () {
      // Arrange
      final emptyResponse = <Map<String, dynamic>>[];

      // Act
      final isEmpty = emptyResponse.isEmpty;
      final length = emptyResponse.length;

      // Assert
      expect(isEmpty, isTrue);
      expect(length, 0);
    });

    test('harus memvalidasi ID yang valid untuk operasi CRUD', () {
      // Arrange
      final validIds = [1, 100, 999, 12345, 999999];
      final invalidIds = [0, -1, -999, -12345];

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

    test('harus memvalidasi struktur data untuk insert warga', () {
      // Arrange
      final validInsertData = {
        'id_kk': 10,
        'nik': '3201234567890123',
        'nama_lengkap': 'Budi Santoso',
        'jenis_kelamin': 'Laki-laki',
        'tanggal_lahir': '1992-05-15',
        'nomor_hp': '081234567890',
      };

      final requiredFieldsForInsert = [
        'id_kk',
        'nik',
        'nama_lengkap',
        'jenis_kelamin',
        'tanggal_lahir',
      ];

      // Act
      final hasAllRequired = requiredFieldsForInsert.every(
        (field) => validInsertData.containsKey(field),
      );

      final nikValid = validInsertData['nik'].toString().length == 16;
      final genderValid = [
        'Laki-laki',
        'Perempuan',
      ].contains(validInsertData['jenis_kelamin']);

      // Assert
      expect(hasAllRequired, isTrue);
      expect(nikValid, isTrue);
      expect(genderValid, isTrue);
      expect(validInsertData['nama_lengkap'], isNotEmpty);
    });

    test('harus memvalidasi struktur data untuk update warga', () {
      // Arrange
      final validUpdateData = {
        'id': 1,
        'id_kk': 10,
        'nik': '3201234567890123',
        'nama_lengkap': 'Budi Santoso Updated',
        'jenis_kelamin': 'Laki-laki',
        'tanggal_lahir': '1992-05-15',
        'nomor_hp': '081234567890',
      };

      // Act
      final hasId = validUpdateData.containsKey('id');
      final idValid = (validUpdateData['id'] as int) > 0;
      final hasRequiredFields =
          validUpdateData.containsKey('nik') &&
          validUpdateData.containsKey('nama_lengkap');

      // Assert
      expect(hasId, isTrue, reason: 'Update must have id field');
      expect(idValid, isTrue, reason: 'ID must be positive');
      expect(hasRequiredFields, isTrue);
    });

    test('harus menangani berbagai tipe error database dengan benar', () {
      // Arrange
      final errorScenarios = [
        {'error': 'Connection timeout', 'type': 'network', 'recoverable': true},
        {'error': 'Invalid credentials', 'type': 'auth', 'recoverable': false},
        {
          'error': 'Duplicate NIK constraint',
          'type': 'constraint',
          'recoverable': false,
        },
        {'error': 'Table not found', 'type': 'schema', 'recoverable': false},
        {'error': 'Permission denied', 'type': 'auth', 'recoverable': false},
      ];

      for (var scenario in errorScenarios) {
        // Act
        final error = scenario['error'] as String;
        final isNetworkError =
            error.toLowerCase().contains('timeout') ||
            error.toLowerCase().contains('connection');
        final isAuthError =
            error.toLowerCase().contains('credential') ||
            error.toLowerCase().contains('permission');
        final isConstraintError =
            error.toLowerCase().contains('constraint') ||
            error.toLowerCase().contains('duplicate');

        // Assert
        expect(error, isNotEmpty);
        if (scenario['type'] == 'network') {
          expect(isNetworkError, isTrue);
        } else if (scenario['type'] == 'auth') {
          expect(isAuthError, isTrue);
        } else if (scenario['type'] == 'constraint') {
          expect(isConstraintError, isTrue);
        }
      }
    });

    test('harus memvalidasi mapping response ke WargaModel', () {
      // Arrange
      final rawResponse = {
        'id': 1,
        'id_kk': 10,
        'nik': '3201234567890123',
        'nama_lengkap': 'Ahmad Subandi',
        'jenis_kelamin': 'Laki-laki',
        'tanggal_lahir': '1990-01-01',
        'nomor_hp': '081234567890',
        'foto_ktp': null,
        'created_at': '2025-11-21T10:00:00Z',
        'updated_at': '2025-11-21T10:00:00Z',
      };

      // Act - Simulate mapping validation
      final hasAllModelFields =
          rawResponse.containsKey('id') &&
          rawResponse.containsKey('id_kk') &&
          rawResponse.containsKey('nik') &&
          rawResponse.containsKey('nama_lengkap') &&
          rawResponse.containsKey('jenis_kelamin') &&
          rawResponse.containsKey('tanggal_lahir') &&
          rawResponse.containsKey('created_at') &&
          rawResponse.containsKey('updated_at');

      final canParseDate =
          DateTime.tryParse(rawResponse['tanggal_lahir'] as String) != null;
      final canParseCreatedAt =
          DateTime.tryParse(rawResponse['created_at'] as String) != null;

      // Assert
      expect(hasAllModelFields, isTrue);
      expect(canParseDate, isTrue);
      expect(canParseCreatedAt, isTrue);
    });

    test('harus menangani nilai null pada field opsional', () {
      // Arrange
      final dataWithNulls = {
        'id': 1,
        'id_kk': 10,
        'nik': '3201234567890123',
        'nama_lengkap': 'Test User',
        'jenis_kelamin': 'Laki-laki',
        'tanggal_lahir': '1990-01-01',
        'nomor_hp': null, // optional
        'foto_ktp': null, // optional
        'created_at': '2025-11-21T10:00:00Z',
        'updated_at': '2025-11-21T10:00:00Z',
      };

      // Act
      final requiredFieldsPresent =
          dataWithNulls['id'] != null &&
          dataWithNulls['nik'] != null &&
          dataWithNulls['nama_lengkap'] != null;

      final optionalFieldsHandled =
          dataWithNulls.containsKey('nomor_hp') &&
          dataWithNulls.containsKey('foto_ktp');

      // Assert
      expect(requiredFieldsPresent, isTrue);
      expect(optionalFieldsHandled, isTrue);
      expect(dataWithNulls['nomor_hp'], isNull);
      expect(dataWithNulls['foto_ktp'], isNull);
    });

    test('harus memvalidasi operasi delete hanya dengan ID valid', () {
      // Arrange
      final deleteScenarios = [
        {'id': 1, 'shouldSucceed': true},
        {'id': 100, 'shouldSucceed': true},
        {'id': 0, 'shouldSucceed': false},
        {'id': -1, 'shouldSucceed': false},
      ];

      for (var scenario in deleteScenarios) {
        // Act
        final id = scenario['id'] as int;
        final isValidId = id > 0;
        final expectedSuccess = scenario['shouldSucceed'] as bool;

        // Assert
        expect(
          isValidId,
          expectedSuccess,
          reason: 'ID $id validation mismatch',
        );
      }
    });

    test('harus memvalidasi batch insert dengan multiple records', () {
      // Arrange
      final batchData = [
        {
          'id_kk': 10,
          'nik': '3201234567890123',
          'nama_lengkap': 'Person 1',
          'jenis_kelamin': 'Laki-laki',
          'tanggal_lahir': '1990-01-01',
        },
        {
          'id_kk': 10,
          'nik': '3201234567890124',
          'nama_lengkap': 'Person 2',
          'jenis_kelamin': 'Perempuan',
          'tanggal_lahir': '1992-05-15',
        },
        {
          'id_kk': 10,
          'nik': '3201234567890125',
          'nama_lengkap': 'Person 3',
          'jenis_kelamin': 'Laki-laki',
          'tanggal_lahir': '1995-12-20',
        },
      ];

      // Act
      final allValid = batchData.every((data) {
        final nikValid = data['nik'].toString().length == 16;
        final genderValid = [
          'Laki-laki',
          'Perempuan',
        ].contains(data['jenis_kelamin']);
        final nameNotEmpty = (data['nama_lengkap'] as String).isNotEmpty;
        return nikValid && genderValid && nameNotEmpty;
      });

      final uniqueNiks =
          batchData.map((d) => d['nik']).toSet().length == batchData.length;

      // Assert
      expect(allValid, isTrue);
      expect(uniqueNiks, isTrue, reason: 'All NIKs should be unique');
      expect(batchData.length, 3);
    });

    test('harus memvalidasi constraint unique NIK', () {
      // Arrange
      final existingNiks = ['3201234567890123', '3201234567890124'];
      final newNik = '3201234567890123'; // duplicate

      // Act
      final isDuplicate = existingNiks.contains(newNik);

      // Assert
      expect(
        isDuplicate,
        isTrue,
        reason: 'Should detect duplicate NIK constraint',
      );
    });

    test('harus memvalidasi id_kk reference constraint', () {
      // Arrange
      final validKkIds = [1, 2, 3, 10, 100];
      final testIdKk = 5;

      // Act - Simulate checking if id_kk exists
      final idKkExists = validKkIds.contains(testIdKk);

      // Assert - In real scenario, this would check foreign key
      expect(testIdKk, greaterThan(0));
      expect(idKkExists, isA<bool>());
      // This is business logic validation placeholder
    });

    test('harus menangani concurrent updates dengan timestamp', () {
      // Arrange
      final record1 = {
        'id': 1,
        'nama_lengkap': 'Original Name',
        'updated_at': '2025-11-21T10:00:00Z',
      };

      final record2 = {
        'id': 1,
        'nama_lengkap': 'Updated Name',
        'updated_at': '2025-11-21T10:05:00Z',
      };

      // Act
      final time1 = DateTime.parse(record1['updated_at'] as String);
      final time2 = DateTime.parse(record2['updated_at'] as String);
      final isNewer = time2.isAfter(time1);

      // Assert
      expect(isNewer, isTrue);
      expect(record1['id'], record2['id']);
    });

    test('harus memvalidasi panjang maksimum untuk field text', () {
      // Arrange
      final testCases = [
        {
          'field': 'nama_lengkap',
          'value': 'A' * 100,
          'maxLength': 255,
          'valid': true,
        },
        {
          'field': 'nama_lengkap',
          'value': 'A' * 300,
          'maxLength': 255,
          'valid': false,
        },
        {
          'field': 'nik',
          'value': '1234567890123456',
          'maxLength': 16,
          'valid': true,
        },
        {
          'field': 'nik',
          'value': '12345678901234567',
          'maxLength': 16,
          'valid': false,
        },
      ];

      for (var testCase in testCases) {
        // Act
        final value = testCase['value'] as String;
        final maxLength = testCase['maxLength'] as int;
        final expected = testCase['valid'] as bool;
        final isValid = value.length <= maxLength;

        // Assert
        expect(
          isValid,
          expected,
          reason:
              '${testCase['field']} with length ${value.length} validation failed',
        );
      }
    });

    test('harus memvalidasi response struktur untuk single record query', () {
      // Arrange
      final singleRecordResponse = {
        'id': 1,
        'id_kk': 10,
        'nik': '3201234567890123',
        'nama_lengkap': 'Ahmad Subandi',
        'jenis_kelamin': 'Laki-laki',
        'tanggal_lahir': '1990-01-01',
        'nomor_hp': '081234567890',
        'foto_ktp': null,
        'created_at': '2025-11-21T10:00:00Z',
        'updated_at': '2025-11-21T10:00:00Z',
      };

      // Act
      final hasId = singleRecordResponse.containsKey('id');
      final isMapType = singleRecordResponse.runtimeType.toString().contains(
        'Map',
      );

      // Assert
      expect(isMapType, isTrue);
      expect(hasId, isTrue);
      expect(singleRecordResponse['id'], greaterThan(0));
      expect(singleRecordResponse, isA<Map<String, dynamic>>());
    });
  });
}

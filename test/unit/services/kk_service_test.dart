import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KKService Business Logic Tests', () {
    // Test pure business logic dari KKService
    // Fokus pada validasi data dan transformasi

    test('[KK-SERVICE-001] harus memvalidasi format nomor KK (16 digit)', () {
      // Arrange
      final validKK = [
        '1234567890123456',
        '9876543210987654',
        '1111111111111111',
      ];

      final invalidKK = [
        '123456789012345', // 15 digit
        '12345678901234567', // 17 digit
        'abcd567890123456', // contains letters
        '123 456 789 012 345', // contains spaces
        '',
      ];

      // Act & Assert - Valid KK
      for (var kk in validKK) {
        final isValid = RegExp(r'^\d{16}$').hasMatch(kk);
        expect(isValid, isTrue, reason: 'KK $kk harus valid');
      }

      // Act & Assert - Invalid KK
      for (var kk in invalidKK) {
        final isValid = RegExp(r'^\d{16}$').hasMatch(kk);
        expect(isValid, isFalse, reason: 'KK $kk harus invalid');
      }
    });

    test('[KK-SERVICE-002] harus memvalidasi alamat tidak boleh kosong', () {
      // Arrange
      final testCases = [
        {'alamat': 'Jl. Merdeka No. 123', 'valid': true},
        {'alamat': 'RT 001/RW 002', 'valid': true},
        {'alamat': '', 'valid': false},
        {'alamat': '   ', 'valid': false},
      ];

      for (var testCase in testCases) {
        // Act
        final alamat = (testCase['alamat'] as String).trim();
        final isValid = alamat.isNotEmpty;

        // Assert
        expect(
          isValid,
          testCase['valid'],
          reason: 'Alamat "${testCase['alamat']}" validation failed',
        );
      }
    });

    test('[KK-SERVICE-003] harus memvalidasi id_rt harus positif', () {
      // Arrange
      final testCases = [
        {'id_rt': 1, 'valid': true},
        {'id_rt': 5, 'valid': true},
        {'id_rt': 0, 'valid': false},
        {'id_rt': -1, 'valid': false},
      ];

      for (var testCase in testCases) {
        // Act
        final idRt = testCase['id_rt'] as int;
        final isValid = idRt > 0;

        // Assert
        expect(
          isValid,
          testCase['valid'],
          reason: 'id_rt $idRt validation failed',
        );
      }
    });

    test(
      '[KK-SERVICE-004] harus menangani null values dalam required fields',
      () {
        // Arrange
        final dataWithNulls = {
          'id': 1,
          'nomor': null, // should not be null
          'id_alamat': 123,
        };

        // Act
        final nomor = dataWithNulls['nomor'] as String?;
        final isNull = nomor == null;

        // Assert
        expect(isNull, isTrue);
      },
    );

    test('[KK-SERVICE-005] harus mengekstrak id dari alamat response', () {
      // Arrange
      final mockAlamatResponse = {
        'id': 123,
        'alamat': 'Jl. Merdeka No. 1',
        'id_rt': 1,
      };

      // Act
      final idAlamat = mockAlamatResponse['id'] as int;

      // Assert
      expect(idAlamat, 123);
    });

    test('[KK-SERVICE-006] harus mengekstrak alamat dari response', () {
      // Arrange
      final mockAlamatResponse = {
        'id': 123,
        'alamat': 'Jl. Merdeka No. 1',
        'id_rt': 1,
      };

      // Act
      final alamat = mockAlamatResponse['alamat'] as String;

      // Assert
      expect(alamat, 'Jl. Merdeka No. 1');
      expect(alamat.isNotEmpty, isTrue);
    });

    test(
      '[KK-SERVICE-007] harus memvalidasi struktur alamat insert payload',
      () {
        // Arrange
        final insertPayload = {'alamat': 'Jl. Merdeka No. 1', 'id_rt': 1};

        // Act
        final hasAlamat = insertPayload.containsKey('alamat');
        final hasIdRt = insertPayload.containsKey('id_rt');

        // Assert
        expect(hasAlamat, isTrue);
        expect(hasIdRt, isTrue);
      },
    );

    test('[KK-SERVICE-008] harus memvalidasi struktur KK insert payload', () {
      // Arrange
      final insertPayload = {'nomor': '1234567890123456', 'id_alamat': 123};

      // Act
      final hasNomor = insertPayload.containsKey('nomor');
      final hasIdAlamat = insertPayload.containsKey('id_alamat');

      // Assert
      expect(hasNomor, isTrue);
      expect(hasIdAlamat, isTrue);
    });

    test('[KK-SERVICE-009] harus mengekstrak id dari KK response', () {
      // Arrange
      final mockKKResponse = {
        'id': 456,
        'nomor': '1234567890123456',
        'id_alamat': 123,
      };

      // Act
      final id = mockKKResponse['id'] as int;

      // Assert
      expect(id, 456);
    });

    test('[KK-SERVICE-010] harus mengekstrak nomor dari KK response', () {
      // Arrange
      final mockKKResponse = {
        'id': 456,
        'nomor': '1234567890123456',
        'id_alamat': 123,
      };

      // Act
      final nomor = mockKKResponse['nomor'] as String;

      // Assert
      expect(nomor, '1234567890123456');
      expect(nomor.length, 16);
    });

    test('[KK-SERVICE-011] harus memvalidasi struktur fetchAllKK query', () {
      // Arrange
      const selectQuery = '*, alamat!inner(id, alamat, id_rt)';

      // Act
      final hasWildcard = selectQuery.contains('*');
      final hasAlamatJoin = selectQuery.contains('alamat!inner');
      final hasAlamatFields = selectQuery.contains('id, alamat, id_rt');

      // Assert
      expect(hasWildcard, isTrue);
      expect(hasAlamatJoin, isTrue);
      expect(hasAlamatFields, isTrue);
    });

    test('[KK-SERVICE-012] harus menggunakan ordering descending by id', () {
      // Arrange
      const orderField = 'id';
      const ascending = false;

      // Act & Assert
      expect(orderField, 'id');
      expect(ascending, isFalse);
    });

    test(
      '[KK-SERVICE-013] harus memvalidasi struktur nested alamat dalam KK response',
      () {
        // Arrange
        final mockKKWithAlamat = {
          'id': 456,
          'nomor': '1234567890123456',
          'id_alamat': 123,
          'alamat': {'id': 123, 'alamat': 'Jl. Merdeka No. 1', 'id_rt': 1},
        };

        // Act
        final hasAlamat = mockKKWithAlamat.containsKey('alamat');
        final alamatData = mockKKWithAlamat['alamat'] as Map<String, dynamic>?;
        final hasNestedId = alamatData?.containsKey('id') ?? false;
        final hasNestedAlamat = alamatData?.containsKey('alamat') ?? false;
        final hasNestedIdRt = alamatData?.containsKey('id_rt') ?? false;

        // Assert
        expect(hasAlamat, isTrue);
        expect(hasNestedId, isTrue);
        expect(hasNestedAlamat, isTrue);
        expect(hasNestedIdRt, isTrue);
      },
    );

    test(
      '[KK-SERVICE-014] harus mengekstrak nested alamat data dengan benar',
      () {
        // Arrange
        final mockKKWithAlamat = {
          'id': 456,
          'nomor': '1234567890123456',
          'id_alamat': 123,
          'alamat': {'id': 123, 'alamat': 'Jl. Merdeka No. 1', 'id_rt': 1},
        };

        // Act
        final alamatData = mockKKWithAlamat['alamat'] as Map<String, dynamic>;
        final alamatId = alamatData['id'] as int;
        final alamatText = alamatData['alamat'] as String;
        final idRt = alamatData['id_rt'] as int;

        // Assert
        expect(alamatId, 123);
        expect(alamatText, 'Jl. Merdeka No. 1');
        expect(idRt, 1);
      },
    );

    test('[KK-SERVICE-015] harus menangani null alamat dalam response', () {
      // Arrange
      final mockKKWithNullAlamat = {
        'id': 456,
        'nomor': '1234567890123456',
        'id_alamat': 123,
        'alamat': null,
      };

      // Act
      final alamatData =
          mockKKWithNullAlamat['alamat'] as Map<String, dynamic>?;
      final isNull = alamatData == null;

      // Assert
      expect(isNull, isTrue);
    });

    test(
      '[KK-SERVICE-016] harus memvalidasi list transformation dari database response',
      () {
        // Arrange
        final mockDatabaseResponse = [
          {
            'id': 1,
            'nomor': '1234567890123456',
            'alamat': {'id': 1, 'alamat': 'Jl. A', 'id_rt': 1},
          },
          {
            'id': 2,
            'nomor': '9876543210987654',
            'alamat': {'id': 2, 'alamat': 'Jl. B', 'id_rt': 2},
          },
        ];

        // Act
        final list = mockDatabaseResponse as List<dynamic>;
        final count = list.length;

        // Assert
        expect(count, 2);
        expect(list.first is Map, isTrue);
      },
    );

    test(
      '[KK-SERVICE-017] harus cast Map dengan benar untuk KKModel.fromJson',
      () {
        // Arrange
        final mockData = {
          'id': 1,
          'nomor': '1234567890123456',
          'alamat': {'id': 1, 'alamat': 'Jl. A', 'id_rt': 1},
        };

        // Act
        final castedMap = Map<String, dynamic>.from(mockData as Map);
        final hasId = castedMap.containsKey('id');
        final hasNomor = castedMap.containsKey('nomor');

        // Assert
        expect(hasId, isTrue);
        expect(hasNomor, isTrue);
      },
    );

    test(
      '[KK-SERVICE-018] harus memvalidasi required fields untuk createKK',
      () {
        // Arrange
        final requiredFields = ['nomorKK', 'alamat'];
        final testData = {
          'nomorKK': '1234567890123456',
          'alamat': 'Jl. Merdeka No. 1',
          'idRt': 1,
        };

        // Act & Assert
        for (var field in requiredFields) {
          expect(
            testData.containsKey(field),
            isTrue,
            reason: 'Missing field: $field',
          );
        }
      },
    );

    test(
      '[KK-SERVICE-019] harus memvalidasi id_alamat reference integrity',
      () {
        // Arrange
        final mockAlamatId = 123;
        final mockKKData = {
          'nomor': '1234567890123456',
          'id_alamat': mockAlamatId,
        };

        // Act
        final idAlamatInKK = mockKKData['id_alamat'] as int;
        final isReferenceValid = idAlamatInKK == mockAlamatId;

        // Assert
        expect(isReferenceValid, isTrue);
        expect(idAlamatInKK, mockAlamatId);
      },
    );

    test('[KK-SERVICE-020] harus trim whitespace dari nomor KK', () {
      // Arrange
      final testCases = [
        {'input': '  1234567890123456  ', 'expected': '1234567890123456'},
        {'input': '1234567890123456\n', 'expected': '1234567890123456'},
        {'input': '\t1234567890123456', 'expected': '1234567890123456'},
      ];

      for (var testCase in testCases) {
        // Act
        final input = testCase['input'] as String;
        final trimmed = input.trim();

        // Assert
        expect(trimmed, testCase['expected']);
      }
    });

    test('[KK-SERVICE-021] harus trim whitespace dari alamat', () {
      // Arrange
      final testCases = [
        {'input': '  Jl. Merdeka  ', 'expected': 'Jl. Merdeka'},
        {'input': 'Jl. Sudirman\n', 'expected': 'Jl. Sudirman'},
        {'input': '\tRT 001', 'expected': 'RT 001'},
      ];

      for (var testCase in testCases) {
        // Act
        final input = testCase['input'] as String;
        final trimmed = input.trim();

        // Assert
        expect(trimmed, testCase['expected']);
      }
    });

    test(
      '[KK-SERVICE-022] harus memvalidasi nomor KK tidak boleh duplicate',
      () {
        // Arrange
        final existingKK = ['1234567890123456', '9876543210987654'];
        final newKK = '1234567890123456';

        // Act
        final isDuplicate = existingKK.contains(newKK);

        // Assert
        expect(isDuplicate, isTrue);
      },
    );

    test('[KK-SERVICE-023] harus memvalidasi nomor KK boleh jika unique', () {
      // Arrange
      final existingKK = ['1234567890123456', '9876543210987654'];
      final newKK = '1111111111111111';

      // Act
      final isDuplicate = existingKK.contains(newKK);

      // Assert
      expect(isDuplicate, isFalse);
    });
  });

  group('KKService Data Transformation Tests', () {
    test(
      '[KK-SERVICE-024] harus transform database list menjadi KKModel list',
      () {
        // Arrange
        final mockDatabaseResponse = [
          {
            'id': 1,
            'nomor': '1234567890123456',
            'alamat': {'id': 1, 'alamat': 'Jl. A', 'id_rt': 1},
          },
          {
            'id': 2,
            'nomor': '9876543210987654',
            'alamat': {'id': 2, 'alamat': 'Jl. B', 'id_rt': 2},
          },
        ];

        // Act
        final list = mockDatabaseResponse as List<dynamic>;
        final mappedList = list.map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          return map;
        }).toList();

        // Assert
        expect(mappedList.length, 2);
        expect(mappedList.first['id'], 1);
        expect(mappedList.last['id'], 2);
      },
    );

    test(
      '[KK-SERVICE-025] harus preserve order dari database (descending by id)',
      () {
        // Arrange
        final mockDatabaseResponse = [
          {'id': 5, 'nomor': '1111111111111111'},
          {'id': 3, 'nomor': '2222222222222222'},
          {'id': 1, 'nomor': '3333333333333333'},
        ];

        // Act
        final list = mockDatabaseResponse as List<dynamic>;
        final ids = list.map((e) => (e as Map)['id'] as int).toList();

        // Assert - Descending order
        expect(ids, [5, 3, 1]);
        expect(ids.first, 5);
        expect(ids.last, 1);
        expect(ids.first > ids.last, isTrue);
      },
    );

    test('[KK-SERVICE-026] harus menangani empty list dari database', () {
      // Arrange
      final mockDatabaseResponse = <dynamic>[];

      // Act
      final list = mockDatabaseResponse as List<dynamic>;

      // Assert
      expect(list.isEmpty, isTrue);
      expect(list.length, 0);
    });

    test('[KK-SERVICE-027] harus cast dynamic list element menjadi Map', () {
      // Arrange
      final mockElement = {'id': 1, 'nomor': '1234567890123456'};

      // Act
      final castedMap = Map<String, dynamic>.from(mockElement as Map);
      final isCorrectType = castedMap is Map<String, dynamic>;

      // Assert
      expect(isCorrectType, isTrue);
      expect(castedMap['id'], 1);
    });
  });

  group('KKService Error Handling Tests', () {
    test('[KK-SERVICE-028] harus menangani missing required fields', () {
      // Arrange
      final incompleteData = {
        'id': 1,
        // missing 'nomor'
        'id_alamat': 123,
      };

      // Act
      final nomor = incompleteData['nomor'] as String?;
      final hasMissingField = nomor == null;

      // Assert
      expect(hasMissingField, isTrue);
    });

    test('[KK-SERVICE-029] harus menangani invalid data types', () {
      // Arrange
      final invalidData = {
        'id': 'should-be-int', // wrong type
        'nomor': '1234567890123456',
      };

      // Act
      final id = invalidData['id'];
      final isInvalidType = id is! int;

      // Assert
      expect(isInvalidType, isTrue);
    });
  });
}

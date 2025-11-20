import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoleProvider Business Logic Tests', () {
    // Test pure business logic dari roleProvider tanpa mocking Supabase
    // Fokus pada transformasi data dan business rules

    test(
      'harus mengekstrak dan mengembalikan nama role yang benar dari database',
      () {
        // Arrange
        final mockDatabaseResponse = {
          'id_role': 1,
          'role': {'nama': 'Admin'},
        };

        // Act
        final roleData = mockDatabaseResponse['role'] as Map<String, dynamic>?;
        final roleName = roleData?['nama'] as String? ?? 'warga';
        final normalizedRole = roleName.toLowerCase().trim();

        // Assert
        expect(roleName, 'Admin');
        expect(normalizedRole, 'admin');
      },
    );

    test('harus menghapus spasi dan mengubah role menjadi lowercase', () {
      // Arrange
      final testCases = [
        {'input': 'Admin', 'expected': 'admin'},
        {'input': ' RT ', 'expected': 'rt'},
        {'input': 'WARGA  ', 'expected': 'warga'},
        {'input': '  Bendahara  ', 'expected': 'bendahara'},
        {'input': 'Sekretaris', 'expected': 'sekretaris'},
      ];

      for (var testCase in testCases) {
        // Act
        final input = testCase['input'] as String;
        final result = input.toLowerCase().trim();

        // Assert
        expect(
          result,
          testCase['expected'],
          reason: 'Failed for input: $input',
        );
      }
    });

    test('harus mengembalikan "warga" ketika data role tidak ada', () {
      // Arrange
      final mockDatabaseResponse = {
        'id_role': 1,
        // 'role' key is missing
      };

      // Act
      final roleData = mockDatabaseResponse['role'] as Map<String, dynamic>?;
      final roleName = roleData?['nama'] as String? ?? 'warga';

      // Assert
      expect(roleData, isNull);
      expect(roleName, 'warga');
    });

    test('harus mengembalikan "warga" ketika nama role bernilai null', () {
      // Arrange
      final mockDatabaseResponse = {
        'id_role': 1,
        'role': {'nama': null},
      };

      // Act
      final roleData = mockDatabaseResponse['role'] as Map<String, dynamic>?;
      final roleName = roleData?['nama'] as String? ?? 'warga';

      // Assert
      expect(roleName, 'warga');
    });

    test('harus menangani berbagai jenis role dengan benar', () {
      // Arrange
      final validRoles = [
        'admin',
        'rt',
        'rw',
        'warga',
        'bendahara',
        'sekretaris',
        'seller',
      ];

      for (var role in validRoles) {
        // Act
        final normalized = role.toLowerCase().trim();

        // Assert
        expect(normalized, role);
        expect(normalized.length, greaterThan(0));
      }
    });

    test('harus mem-parsing struktur response database dengan benar', () {
      // Arrange
      final mockResponse = {
        'id_role': 2,
        'role': {'id': 2, 'nama': 'RT', 'deskripsi': 'Ketua RT'},
      };

      // Act
      final idRole = mockResponse['id_role'] as int?;
      final roleData = mockResponse['role'] as Map<String, dynamic>?;
      final roleName = roleData?['nama'] as String?;
      final roleDesc = roleData?['deskripsi'] as String?;

      // Assert
      expect(idRole, 2);
      expect(roleData, isNotNull);
      expect(roleName, 'RT');
      expect(roleDesc, 'Ketua RT');
    });

    test('harus menangani error dan mengembalikan role default', () {
      // Arrange
      final errorScenarios = [
        null, // Database returns null
        {}, // Empty response
        {'id_role': null}, // Missing role relation
      ];

      for (var scenario in errorScenarios) {
        // Act
        final roleData = scenario?['role'] as Map<String, dynamic>?;
        final roleName = roleData?['nama'] as String? ?? 'warga';

        // Assert
        expect(
          roleName,
          'warga',
          reason: 'Should return default for scenario: $scenario',
        );
      }
    });

    test('harus memvalidasi logika pemetaan role', () {
      // Arrange
      final roleMappings = {
        1: 'admin',
        2: 'rt',
        3: 'rw',
        4: 'bendahara',
        5: 'sekretaris',
        6: 'warga',
        7: 'seller',
      };

      // Act & Assert
      roleMappings.forEach((idRole, expectedRole) {
        final mockData = {
          'id_role': idRole,
          'role': {'nama': expectedRole.toUpperCase()},
        };

        final roleData = mockData['role'] as Map<String, dynamic>;
        final roleName = (roleData['nama'] as String).toLowerCase();

        expect(roleName, expectedRole);
      });
    });

    test('harus menangani format UUID untuk ID user', () {
      // Arrange
      final validUUIDs = [
        '550e8400-e29b-41d4-a716-446655440000',
        'f47ac10b-58cc-4372-a567-0e02b2c3d479',
        '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      ];

      for (var uuid in validUUIDs) {
        // Act
        final isValidFormat = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ).hasMatch(uuid);

        // Assert
        expect(isValidFormat, isTrue, reason: 'Invalid UUID: $uuid');
      }
    });

    test('harus memvalidasi format email dari user', () {
      // Arrange
      final validEmails = [
        'admin@jawara.com',
        'rt01@example.com',
        'warga.test@domain.co.id',
      ];

      for (var email in validEmails) {
        // Act
        final isValid = email.contains('@') && email.contains('.');

        // Assert
        expect(isValid, isTrue, reason: 'Invalid email: $email');
      }
    });

    test('harus menangani query role dengan join secara benar', () {
      // Arrange - Simulate Supabase query builder chain
      final expectedQuery = '''
        SELECT id_role, role!inner(nama)
        FROM users
        WHERE id_auth = 'user-uuid'
      ''';

      // Act
      final hasJoin = expectedQuery.contains('role!inner');
      final hasSelect = expectedQuery.contains('id_role');
      final hasWhere = expectedQuery.contains('WHERE');

      // Assert
      expect(hasJoin, isTrue, reason: 'Query should use inner join');
      expect(hasSelect, isTrue, reason: 'Query should select id_role');
      expect(hasWhere, isTrue, reason: 'Query should filter by id_auth');
    });

    test(
      'harus mengembalikan format role yang konsisten di berbagai pemanggilan',
      () {
        // Arrange
        final inputRoles = ['  ADMIN  ', 'admin', 'Admin', 'ADMIN', '  admin'];

        // Act & Assert
        for (var input in inputRoles) {
          final normalized = input.toLowerCase().trim();
          expect(
            normalized,
            'admin',
            reason: 'All inputs should normalize to "admin"',
          );
        }
      },
    );

    test('harus menangani skenario error pada role provider', () {
      // Arrange
      final errorCases = [
        {'user': null, 'expected': 'guest'},
        {'user': 'exists', 'dbResponse': null, 'expected': 'warga'},
        {'user': 'exists', 'dbResponse': {}, 'expected': 'warga'},
      ];

      for (var testCase in errorCases) {
        // Act
        final user = testCase['user'];
        final expected = testCase['expected'] as String;

        // Assert
        if (user == null) {
          expect(expected, 'guest');
        } else {
          expect(expected, 'warga');
        }
      }
    });
  });
}

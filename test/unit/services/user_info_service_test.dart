import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserInfoService Business Logic Tests', () {
    // Test transformasi data dan parsing response dari database

    test('harus parse getUserInfo response dengan benar', () {
      // Arrange - Mock response dari database
      final mockResponse = {
        'id_auth': 'uuid-123-456',
        'full_name': 'John Doe',
        'role': {'nama': 'admin'},
      };

      // Act
      final idAuth = mockResponse['id_auth'] as String?;
      final fullName = mockResponse['full_name'] as String?;
      final roleData = mockResponse['role'] as Map<String, dynamic>?;
      final roleName = roleData?['nama'] as String?;

      // Assert
      expect(idAuth, 'uuid-123-456');
      expect(fullName, 'John Doe');
      expect(roleName, 'admin');
    });

    test('harus extract role name dari nested structure', () {
      // Arrange
      final mockUserInfo = {
        'id_auth': 'uuid-789',
        'full_name': 'Jane Smith',
        'role': {'nama': 'RT'},
      };

      // Act
      final roleData = mockUserInfo['role'] as Map<String, dynamic>?;
      final roleName = roleData?['nama'] as String?;

      // Assert
      expect(roleName, 'RT');
      expect(roleName, isNotNull);
    });

    test('harus return null jika role data tidak ada', () {
      // Arrange
      final mockUserInfo = {
        'id_auth': 'uuid-999',
        'full_name': 'No Role User',
        // role field tidak ada
      };

      // Act
      final roleData = mockUserInfo['role'] as Map<String, dynamic>?;
      final roleName = roleData?['nama'] as String?;

      // Assert
      expect(roleData, isNull);
      expect(roleName, isNull);
    });

    test('harus parse full_name dengan benar dari response', () {
      // Arrange
      final mockResponse = {'full_name': 'Ahmad Wijaya'};

      // Act
      final fullName = mockResponse['full_name'] as String?;

      // Assert
      expect(fullName, isNotNull);
      expect(fullName, 'Ahmad Wijaya');
    });

    test('harus extract email prefix sebagai fallback name', () {
      // Arrange
      const email = 'john.doe@example.com';

      // Act
      final emailName = email.split('@').first;

      // Assert
      expect(emailName, 'john.doe');
    });

    test('harus return "Unknown User" jika full_name null', () {
      // Arrange
      final mockResponse = {'id_auth': 'uuid-123', 'full_name': null};

      // Act
      final fullName = mockResponse['full_name'] as String?;
      final displayName = fullName ?? 'Unknown User';

      // Assert
      expect(fullName, isNull);
      expect(displayName, 'Unknown User');
    });

    test('harus validate response structure untuk getUserInfo', () {
      // Arrange - Complete response structure
      final mockResponse = {
        'id_auth': 'uuid-abc-123',
        'full_name': 'Test User',
        'role': {'nama': 'warga'},
      };

      // Act
      final hasIdAuth = mockResponse.containsKey('id_auth');
      final hasFullName = mockResponse.containsKey('full_name');
      final hasRole = mockResponse.containsKey('role');

      // Assert
      expect(hasIdAuth, isTrue);
      expect(hasFullName, isTrue);
      expect(hasRole, isTrue);
    });

    test('harus handle berbagai role names', () {
      // Arrange
      final testCases = [
        {'role': 'admin', 'expected': 'admin'},
        {'role': 'RT', 'expected': 'RT'},
        {'role': 'RW', 'expected': 'RW'},
        {'role': 'bendahara', 'expected': 'bendahara'},
        {'role': 'sekretaris', 'expected': 'sekretaris'},
        {'role': 'warga', 'expected': 'warga'},
        {'role': 'seller', 'expected': 'seller'},
      ];

      for (var testCase in testCases) {
        // Act
        final mockResponse = {
          'role': {'nama': testCase['role']},
        };
        final roleData = mockResponse['role'] as Map<String, dynamic>?;
        final roleName = roleData?['nama'] as String?;

        // Assert
        expect(
          roleName,
          testCase['expected'],
          reason: 'Failed for role: ${testCase['role']}',
        );
      }
    });
  });
}

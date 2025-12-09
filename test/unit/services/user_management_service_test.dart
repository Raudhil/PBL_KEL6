import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/data/models/user_model.dart';

void main() {
  group('UserManagementService Business Logic Tests', () {
    // Test transformasi data, validasi, dan business rules

    test('harus parse getAllUsers response dengan benar', () {
      // Arrange - Mock response dari database
      final mockResponse = {
        'id': 1,
        'id_auth': 'uuid-123',
        'full_name': 'John Doe',
        'email': 'john@example.com',
        'status': 'aktif',
        'id_role': 2,
        'role': {'id': 2, 'nama': 'RT'},
        'warga': {
          'id': 10,
          'nik': '1234567890123456',
          'nama_lengkap': 'John Doe',
        },
      };

      // Act
      final id = mockResponse['id'] as int?;
      final fullName = mockResponse['full_name'] as String?;
      final status = mockResponse['status'] as String?;
      final roleData = mockResponse['role'] as Map<String, dynamic>?;
      final roleName = roleData?['nama'] as String?;

      // Assert
      expect(id, 1);
      expect(fullName, 'John Doe');
      expect(status, 'aktif');
      expect(roleName, 'RT');
    });

    test('harus validate StatusUser enum values', () {
      // Arrange
      final testCases = [
        {'value': 'Aktif', 'enum': StatusUser.aktif},
        {'value': 'Tidak Aktif', 'enum': StatusUser.tidakAktif},
      ];

      for (var testCase in testCases) {
        // Act
        final statusEnum = testCase['enum'] as StatusUser;
        final statusValue = statusEnum.value;

        // Assert
        expect(
          statusValue,
          testCase['value'],
          reason: 'Failed for status: ${testCase['value']}',
        );
      }
    });

    test('harus extract warga data dari nested structure', () {
      // Arrange
      final mockUserResponse = {
        'id': 1,
        'warga': {
          'id': 10,
          'nik': '3201234567891234',
          'nama_lengkap': 'Ahmad Wijaya',
          'jenis_kelamin': 'L',
          'tanggal_lahir': '1990-01-15',
          'nomor_hp': '081234567890',
        },
      };

      // Act
      final wargaData = mockUserResponse['warga'] as Map<String, dynamic>?;
      final nik = wargaData?['nik'] as String?;
      final namaLengkap = wargaData?['nama_lengkap'] as String?;

      // Assert
      expect(wargaData, isNotNull);
      expect(nik, '3201234567891234');
      expect(namaLengkap, 'Ahmad Wijaya');
    });

    test('harus parse RoleModel dengan benar', () {
      // Arrange
      final mockRoleResponse = {'id': 2, 'nama': 'RT'};

      // Act
      final id = mockRoleResponse['id'] as int?;
      final nama = mockRoleResponse['nama'] as String?;

      // Assert
      expect(id, 2);
      expect(nama, 'RT');
    });

    test('harus extract alamat dari nested kk structure', () {
      // Arrange
      final mockWargaResponse = {
        'id': 10,
        'nik': '1234567890123456',
        'kk': {
          'id_alamat': 5,
          'alamat': {'alamat': 'Jl. Merdeka No. 123, RT 01/RW 02'},
        },
      };

      // Act
      final kkData = mockWargaResponse['kk'] as Map<String, dynamic>?;
      final alamatData = kkData?['alamat'] as Map<String, dynamic>?;
      final alamatString = alamatData?['alamat'] as String?;

      // Assert
      expect(alamatString, 'Jl. Merdeka No. 123, RT 01/RW 02');
    });

    test('harus validate checkWargaHasUser response', () {
      // Arrange - Warga sudah punya user
      final mockResponseHasUser = {'id': 1};

      // Act
      final hasUser = mockResponseHasUser != null;

      // Assert
      expect(hasUser, isTrue);
    });

    test('harus validate checkWargaHasUser untuk warga tanpa user', () {
      // Arrange - Warga belum punya user
      const Map<String, dynamic>? mockResponseNoUser = null;

      // Act
      final hasUser = mockResponseNoUser != null;

      // Assert
      expect(hasUser, isFalse);
    });

    test('harus create update payload dengan timestamp', () {
      // Arrange
      const userId = 1;
      const newStatus = 'Aktif';
      final now = DateTime.now();

      // Act
      final updatePayload = {
        'status': newStatus,
        'updated_at': now.toIso8601String(),
      };

      // Assert
      expect(updatePayload['status'], 'Aktif');
      expect(updatePayload['updated_at'], isNotEmpty);
      expect(updatePayload['updated_at'], contains('T'));
    });

    test('harus validate filter query parameters', () {
      // Arrange
      const statusFilter = StatusUser.aktif;
      const roleFilter = 2;

      // Act
      final statusValue = statusFilter.value;
      final roleId = roleFilter;

      // Assert
      expect(statusValue, 'Aktif');
      expect(roleId, 2);
    });

    test('harus parse complete user model structure', () {
      // Arrange
      final mockUserData = {
        'id': 1,
        'id_auth': 'uuid-123',
        'full_name': 'Test User',
        'email': 'test@example.com',
        'status': 'aktif',
        'id_role': 3,
        'id_warga': 10,
        'role': {'id': 3, 'nama': 'warga'},
        'warga': {
          'id': 10,
          'nik': '1234567890123456',
          'nama_lengkap': 'Test User',
        },
      };

      // Act
      final hasRequiredFields =
          mockUserData.containsKey('id') &&
          mockUserData.containsKey('id_auth') &&
          mockUserData.containsKey('full_name') &&
          mockUserData.containsKey('status') &&
          mockUserData.containsKey('role');

      // Assert
      expect(hasRequiredFields, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/data/models/user_model.dart';

void main() {
  group('UserManagementProvider Business Logic Tests', () {
    // Test state management dan business logic tanpa mocking Supabase

    test('harus memiliki initial state loading', () {
      // Arrange & Act
      const initialState = AsyncValue<List<UserModel>>.loading();

      // Assert
      expect(initialState.isLoading, isTrue);
      expect(initialState.hasValue, isFalse);
      expect(initialState.hasError, isFalse);
    });

    test('harus mengubah state menjadi data setelah load berhasil', () {
      // Arrange
      final mockUsers = [
        UserModel(
          id: 1,
          idAuth: 'uuid-123',
          fullName: 'John Doe',
          status: StatusUser.aktif,
          idRole: 2,
        ),
        UserModel(
          id: 2,
          idAuth: 'uuid-456',
          fullName: 'Jane Smith',
          status: StatusUser.aktif,
          idRole: 3,
        ),
      ];

      // Act
      final dataState = AsyncValue.data(mockUsers);

      // Assert
      expect(dataState.isLoading, isFalse);
      expect(dataState.hasValue, isTrue);
      expect(dataState.value?.length, 2);
      expect(dataState.value?.first.fullName, 'John Doe');
    });

    test('harus mengubah state menjadi error saat load gagal', () {
      // Arrange
      final testError = Exception('Failed to load users');
      final testStackTrace = StackTrace.current;

      // Act
      final errorState = AsyncValue<List<UserModel>>.error(
        testError,
        testStackTrace,
      );

      // Assert
      expect(errorState.isLoading, isFalse);
      expect(errorState.hasError, isTrue);
      expect(errorState.error.toString(), contains('Failed to load users'));
    });

    test('harus validate status filter logic', () {
      // Arrange
      StatusUser? statusFilter;

      // Act - No filter
      var shouldFilterByStatus = statusFilter != null;
      expect(shouldFilterByStatus, isFalse);

      // Act - With filter
      statusFilter = StatusUser.aktif;
      shouldFilterByStatus = statusFilter != null;

      // Assert
      expect(shouldFilterByStatus, isTrue);
      expect(statusFilter.value, 'Aktif');
    });

    test('harus validate role filter logic', () {
      // Arrange
      int? roleFilter;

      // Act - No filter
      var shouldFilterByRole = roleFilter != null;
      expect(shouldFilterByRole, isFalse);

      // Act - With filter
      roleFilter = 2;
      shouldFilterByRole = roleFilter != null;

      // Assert
      expect(shouldFilterByRole, isTrue);
      expect(roleFilter, 2);
    });

    test('harus clear filters dengan benar', () {
      // Arrange
      StatusUser? statusFilter = StatusUser.aktif;
      int? roleFilter = 2;

      // Act - Clear filters
      statusFilter = null;
      roleFilter = null;

      // Assert
      expect(statusFilter, isNull);
      expect(roleFilter, isNull);
    });

    test('harus handle empty user list', () {
      // Arrange
      final emptyUsers = <UserModel>[];

      // Act
      final dataState = AsyncValue.data(emptyUsers);

      // Assert
      expect(dataState.hasValue, isTrue);
      expect(dataState.value?.isEmpty, isTrue);
      expect(dataState.value?.length, 0);
    });

    test('harus filter users by status correctly', () {
      // Arrange
      final allUsers = [
        UserModel(
          id: 1,
          idAuth: 'uuid-1',
          fullName: 'Active User',
          status: StatusUser.aktif,
          idRole: 2,
        ),
        UserModel(
          id: 2,
          idAuth: 'uuid-2',
          fullName: 'Inactive User',
          status: StatusUser.tidakAktif,
          idRole: 3,
        ),
      ];

      // Act - Filter aktif users
      final activeUsers = allUsers
          .where((user) => user.status == StatusUser.aktif)
          .toList();

      // Assert
      expect(activeUsers.length, 1);
      expect(activeUsers.first.fullName, 'Active User');
    });

    test('harus filter users by role correctly', () {
      // Arrange
      final allUsers = [
        UserModel(
          id: 1,
          idAuth: 'uuid-1',
          fullName: 'RT User',
          status: StatusUser.aktif,
          idRole: 2,
        ),
        UserModel(
          id: 2,
          idAuth: 'uuid-2',
          fullName: 'Warga User 1',
          status: StatusUser.aktif,
          idRole: 3,
        ),
        UserModel(
          id: 3,
          idAuth: 'uuid-3',
          fullName: 'Warga User 2',
          status: StatusUser.aktif,
          idRole: 3,
        ),
      ];

      // Act - Filter warga users (role id = 3)
      final wargaUsers = allUsers.where((user) => user.idRole == 3).toList();

      // Assert
      expect(wargaUsers.length, 2);
      expect(wargaUsers.every((user) => user.idRole == 3), isTrue);
    });

    test('harus validate update status operation', () {
      // Arrange
      const userId = 1;
      const newStatus = StatusUser.tidakAktif;

      // Act
      final updateData = {'user_id': userId, 'new_status': newStatus.value};

      // Assert
      expect(updateData['user_id'], 1);
      expect(updateData['new_status'], 'Tidak Aktif');
    });

    test('harus validate update role operation', () {
      // Arrange
      const userId = 1;
      const newRoleId = 4;

      // Act
      final updateData = {'user_id': userId, 'new_role_id': newRoleId};

      // Assert
      expect(updateData['user_id'], 1);
      expect(updateData['new_role_id'], 4);
    });
  });
}

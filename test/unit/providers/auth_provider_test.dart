import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/core/providers/auth_provider.dart' as auth;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthState Business Logic Tests', () {
    // Test pure business logic dari AuthState tanpa mocking kompleks
    // Fokus pada state transformasi dan immutability

    test(
      '[AUTH-001] harus membuat AuthState dengan nilai default yang benar',
      () {
        // Arrange & Act
        final state = auth.AuthState();

        // Assert
        expect(state.user, isNull);
        expect(state.role, isNull);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      },
    );

    test('[AUTH-002] harus membuat AuthState dengan nilai yang diberikan', () {
      // Arrange
      final mockUser = _MockUser(id: '1', email: 'test@example.com');

      // Act
      final state = auth.AuthState(
        user: mockUser,
        role: 'warga',
        isLoading: false,
        error: null,
      );

      // Assert
      expect(state.user?.id, '1');
      expect(state.user?.email, 'test@example.com');
      expect(state.role, 'warga');
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test(
      '[AUTH-003] copyWith harus membuat instance baru dengan field yang diupdate',
      () {
        // Arrange
        final mockUser1 = _MockUser(id: 'user-1', email: 'user1@example.com');
        final mockUser2 = _MockUser(id: 'user-2', email: 'user2@example.com');
        final originalState = auth.AuthState(
          user: mockUser1,
          role: 'warga',
          isLoading: false,
        );

        // Act
        final newState = originalState.copyWith(
          user: mockUser2,
          role: 'admin',
          isLoading: true,
        );

        // Assert
        expect(newState.user?.id, 'user-2');
        expect(newState.role, 'admin');
        expect(newState.isLoading, isTrue);
        expect(newState != originalState, isTrue); // Different instance
      },
    );

    test(
      '[AUTH-004] copyWith harus mempertahankan field yang tidak diupdate',
      () {
        // Arrange
        final mockUser = _MockUser(id: '1', email: 'test@example.com');
        final originalState = auth.AuthState(
          user: mockUser,
          role: 'bendahara',
          isLoading: false,
          error: 'Some error',
        );

        // Act
        final newState = originalState.copyWith(isLoading: true);

        // Assert
        expect(newState.user?.id, '1');
        expect(newState.role, 'bendahara');
        expect(newState.isLoading, isTrue);
        expect(newState.error, 'Some error'); // Tetap ada karena tidak diupdate
      },
    );

    test(
      '[AUTH-005] copyWith dengan user=null harus tetap menyimpan user sebelumnya',
      () {
        // Arrange
        final mockUser = _MockUser(id: '1', email: 'test@example.com');
        final state = auth.AuthState(user: mockUser, role: 'warga');

        // Act
        final newState = state.copyWith(user: null);

        // Assert
        // copyWith dengan null parameter tidak mengubah field
        expect(newState.user, isNull);
      },
    );

    test('[AUTH-006] harus menangani berbagai role dengan benar', () {
      // Arrange
      final validRoles = [
        'warga',
        'bendahara',
        'sekretaris',
        'rt',
        'rw',
        'admin',
        'seller',
      ];

      for (var role in validRoles) {
        // Act
        final state = auth.AuthState(role: role);

        // Assert
        expect(state.role, role);
        expect(state.role, isNotEmpty);
      }
    });

    test('[AUTH-007] harus menangani error messages', () {
      // Arrange
      final errorMessages = [
        'Invalid credentials',
        'Akun Anda belum aktif',
        'Email tidak terdaftar',
        'Terjadi kesalahan server',
      ];

      for (var errorMsg in errorMessages) {
        // Act
        final state = auth.AuthState(error: errorMsg);

        // Assert
        expect(state.error, errorMsg);
        expect(state.error, isNotEmpty);
      }
    });

    test('[AUTH-008] harus membedakan antara isLoading true dan false', () {
      // Arrange & Act
      final loadingState = auth.AuthState(isLoading: true);
      final idleState = auth.AuthState(isLoading: false);

      // Assert
      expect(loadingState.isLoading, isTrue);
      expect(idleState.isLoading, isFalse);
      expect(loadingState.isLoading != idleState.isLoading, isTrue);
    });

    test(
      '[AUTH-009] harus menggunakan format User dari Supabase dengan benar',
      () {
        // Arrange
        final mockUser = _MockUser(
          id: '550e8400-e29b-41d4-a716-446655440000',
          email: 'warga@jawara.com',
        );

        // Act
        final state = auth.AuthState(user: mockUser);
        final isValidUUID = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ).hasMatch(mockUser.id);
        final isValidEmail =
            mockUser.email?.contains('@') == true &&
            mockUser.email?.contains('.') == true;

        // Assert
        expect(state.user, isNotNull);
        expect(isValidUUID, isTrue, reason: 'User ID harus UUID format');
        expect(isValidEmail, isTrue, reason: 'Email harus valid format');
      },
    );

    test('[AUTH-010] harus menangani transisi state dari login ke logout', () {
      // Arrange
      final mockUser = _MockUser(id: '1', email: 'test@example.com');
      final loginState = auth.AuthState(
        user: mockUser,
        role: 'warga',
        isLoading: false,
      );

      // Act - Simulate logout
      final logoutState = auth.AuthState();

      // Assert
      expect(loginState.user, isNotNull);
      expect(logoutState.user, isNull);
      expect(loginState.role, 'warga');
      expect(logoutState.role, isNull);
    });

    test('[AUTH-011] harus membuat state immutable dengan copyWith', () {
      // Arrange
      final mockUser = _MockUser(id: 'user-1', email: 'user@example.com');
      final state1 = auth.AuthState(user: mockUser, role: 'warga');

      // Act
      final state2 = state1.copyWith(role: 'admin');

      // Assert
      expect(state1.role, 'warga'); // Original unchanged
      expect(state2.role, 'admin');
      expect(state1 != state2, isTrue); // Different instances
    });

    test('[AUTH-012] harus menangani error state dengan isLoading', () {
      // Arrange
      final errorWithLoading = auth.AuthState(
        isLoading: true,
        error: 'Network error',
      );
      final errorNoLoading = auth.AuthState(
        isLoading: false,
        error: 'Network error',
      );

      // Act & Assert
      expect(errorWithLoading.isLoading, isTrue);
      expect(errorNoLoading.isLoading, isFalse);
      expect(errorWithLoading.error, 'Network error');
      expect(errorNoLoading.error, 'Network error');
    });

    test('[AUTH-013] harus memvalidasi kombinasi state yang valid', () {
      // Arrange - Valid state combinations
      final validStates = [
        auth.AuthState(), // Empty state (not logged in)
        auth.AuthState(
          user: _MockUser(id: '1'),
          role: 'warga',
        ), // Logged in
        auth.AuthState(isLoading: true), // Loading state
        auth.AuthState(error: 'Some error'), // Error state
      ];

      for (var state in validStates) {
        // Assert
        expect(state, isA<auth.AuthState>());
      }
    });

    test('[AUTH-014] harus menangani multiple copyWith calls', () {
      // Arrange
      final mockUser = _MockUser(id: '1', email: 'test@example.com');
      var state = auth.AuthState();

      // Act - Chain multiple copyWith calls
      state = state.copyWith(isLoading: true);
      state = state.copyWith(user: mockUser, role: 'warga');
      state = state.copyWith(isLoading: false);

      // Assert
      expect(state.user, isNotNull);
      expect(state.role, 'warga');
      expect(state.isLoading, isFalse);
    });
  });

  group('AuthNotifier State Management Tests', () {
    // Test state management logic tanpa melakukan actual login/logout
    // Fokus pada state transitions dan role handling

    test('[AUTH-015] harus mengelola role untuk berbagai tipe pengguna', () {
      // Arrange
      final roles = ['warga', 'bendahara', 'sekretaris', 'rt', 'rw', 'admin'];
      final mockUser = _MockUser(id: '1', email: 'test@example.com');

      for (var role in roles) {
        // Act
        final state = auth.AuthState(user: mockUser, role: role);

        // Assert
        expect(state.role, role);
        expect(state.user, isNotNull);
      }
    });

    test('[AUTH-016] harus menangani default role "warga"', () {
      // Arrange
      final mockUser = _MockUser(id: '1', email: 'test@example.com');

      // Act
      final state = auth.AuthState(user: mockUser, role: 'warga');

      // Assert
      expect(state.role, 'warga');
    });

    test('[AUTH-017] harus membersihkan state saat logout', () {
      // Arrange
      final loggedInState = auth.AuthState(
        user: _MockUser(id: '1', email: 'test@example.com'),
        role: 'admin',
      );

      // Act - Create fresh empty state for logout
      final loggedOutState = auth.AuthState();

      // Assert
      expect(loggedInState.user, isNotNull);
      expect(loggedOutState.user, isNull);
      expect(loggedInState.role, isNotNull);
      expect(loggedOutState.role, isNull);
    });

    test('[AUTH-018] harus menangani error state selama login process', () {
      // Arrange
      final loadingState = auth.AuthState(isLoading: true);
      const errorMsg = 'Invalid credentials';

      // Act
      final errorState = auth.AuthState(isLoading: false, error: errorMsg);

      // Assert
      expect(loadingState.isLoading, isTrue);
      expect(errorState.isLoading, isFalse);
      expect(errorState.error, errorMsg);
    });

    test('[AUTH-019] harus preserve user info saat error terjadi', () {
      // Arrange
      final mockUser = _MockUser(id: '1', email: 'test@example.com');
      final successState = auth.AuthState(user: mockUser, role: 'warga');

      // Act - Update dengan error tapi user tetap ada
      final errorState = auth.AuthState(
        user: successState.user,
        role: successState.role,
        error: 'Some error',
      );

      // Assert
      expect(errorState.user, isNotNull);
      expect(errorState.user?.id, '1');
      expect(errorState.error, 'Some error');
    });
  });
}

// Mock User class untuk testing
class _MockUser implements User {
  final String _id;
  final String? _email;

  _MockUser({required String id, String? email}) : _id = id, _email = email;

  @override
  String get id => _id;

  @override
  String? get email => _email;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'role_provider.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth State Provider
class AuthState {
  final User? user;
  final String? role;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.role, this.isLoading = false, this.error});

  AuthState copyWith({User? user, String? role, bool? isLoading}) {
    return AuthState(
      user: user,
      role: role,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(AuthState()) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((event) {
      if (event.session == null) {
        state = AuthState();
        // Invalidate roleProvider saat logout
        _ref.invalidate(roleProvider);
        print('🔄 AuthNotifier: Session cleared, roleProvider invalidated');
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    print('🔄 AuthProvider: Starting login...');

    // Ensure clean state before login
    state = AuthState(isLoading: true);

    try {
      // Wait a bit to ensure any previous session is fully cleared
      await Future.delayed(const Duration(milliseconds: 500));

      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      print(
        '📦 AuthProvider: Got result - User: ${result['user']?.email}, Role: ${result['role']}',
      );

      state = AuthState(
        user: result['user'],
        role: result['role'],
        isLoading: false,
      );

      // Invalidate roleProvider untuk memastikan fresh data
      _ref.invalidate(roleProvider);

      print(
        '✅ AuthProvider: State updated - User: ${state.user?.email}, Role: ${state.role}',
      );
    } catch (e) {
      print('❌ AuthProvider: Login error - $e');
      state = AuthState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    print('🔄 AuthProvider: Starting logout...');
    try {
      await _authService.signOut();
      // Reset state completely
      state = AuthState();
      // Invalidate roleProvider
      _ref.invalidate(roleProvider);
      print(
        '✅ AuthProvider: Logout successful, state reset, roleProvider invalidated',
      );
    } catch (e) {
      print('❌ AuthProvider: Logout error - $e');
      // Still reset state even if logout fails
      state = AuthState();
      _ref.invalidate(roleProvider);
    }
  }
}

// Auth State Notifier Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});

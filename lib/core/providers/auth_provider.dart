import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

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

  AuthNotifier(this._authService) : super(AuthState()) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((event) {
      if (event.session == null) {
        state = AuthState();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    print('🔄 AuthProvider: Starting login...');
    state = state.copyWith(isLoading: true);
    try {
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

      print(
        '✅ AuthProvider: State updated - User: ${state.user?.email}, Role: ${state.role}',
      );
    } catch (e) {
      print('❌ AuthProvider: Login error - $e');
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = AuthState();
  }
}

// Auth State Notifier Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Clear any existing session first
      final existingSession = _supabase.auth.currentSession;
      if (existingSession != null) {
        print('⚠️ Found existing session, clearing...');
        await _supabase.auth.signOut();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login gagal - user null');
      }

      // Ambil data user dari tabel users berdasarkan id_auth
      final authId = response.user!.id;
      final userData = await _supabase
          .from('users')
          .select('role, status, id_auth')
          .eq('id_auth', authId)
          .maybeSingle();

      if (userData == null) {
        // pastikan tidak ada session tersisa
        await _supabase.auth.signOut();
        throw Exception('Data akun tidak ditemukan');
      }

      final status = (userData['status'] ?? '').toString().toLowerCase();
      if (status == 'tidak aktif' || status != 'aktif') {
        await _supabase.auth.signOut();
        throw Exception('Akun Anda tidak aktif atau status tidak valid');
      }

      final userRole = userData['role'] as String? ?? 'warga';
      // Log berhasil
      print('✅ Login berhasil - Email: $email, Role: $userRole');

      return {
        'user': response.user,
        'role': userRole,
        'email': response.user!.email,
      };
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      throw Exception('Login gagal: ${e.message}');
    } catch (e) {
      print('❌ Error during login: $e');
      throw Exception('Error: $e');
    }
  }

  /// Register an auth user and return the newly created auth id.
  /// This does not create the application `users` record — callers
  /// should insert into their `users` table as required.
  Future<String> register({required String email, required String password}) async {
    try {
      final res = await _supabase.auth.signUp(email: email, password: password);
      final authId = res.user?.id;
      if (authId == null) {
        throw Exception('Gagal membuat akun Auth');
      }
      return authId;
    } on AuthException catch (e) {
      throw Exception('Register gagal: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      print('🔄 Signing out from Supabase...');
      await _supabase.auth.signOut();
      print('✅ Supabase sign out successful');
    } catch (e) {
      print('❌ Error during sign out: $e');
      // Don't rethrow - logout should always succeed from UI perspective
    }
  }

  Future<String?> getUserRole() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final userData = await _supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      return userData?['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get integer ID dari tabel users berdasarkan UUID auth
  Future<int?> getUserIntId(String authId) async {
    try {
      final userData = await _supabase
          .from('users')
          .select('id')
          .eq('id_auth', authId)
          .maybeSingle();

      return userData?['id'] as int?;
    } catch (e) {
      print('❌ Error getting user int ID: $e');
      return null;
    }
  }

  /// Get integer ID for current user
  Future<int?> getCurrentUserIntId() async {
    final user = currentUser;
    if (user == null) return null;
    return await getUserIntId(user.id);
  }
}

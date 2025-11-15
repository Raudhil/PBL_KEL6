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
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login gagal');
      }

      // Ambil role dari tabel users
      final userData = await _supabase
          .from('users')
          .select('role')
          .eq('email', email)
          .maybeSingle();

      final userRole = userData?['role'] as String? ?? 'warga';

      print('✅ Login berhasil - Email: $email, Role: $userRole');

      return {
        'user': response.user,
        'role': userRole,
        'email': response.user!.email,
      };
    } on AuthException catch (e) {
      throw Exception('Login gagal: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
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
}

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
      print('❌ AuthException: ${e.message}');
      throw Exception('Login gagal: ${e.message}');
    } catch (e) {
      print('❌ Error during login: $e');
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

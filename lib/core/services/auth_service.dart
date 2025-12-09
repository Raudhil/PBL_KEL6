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

      // STRATEGI: Sign in dulu untuk validasi kredensial dan dapat auth_id,
      // TAPI langsung cek status dan batalkan session jika tidak aktif
      // SEBELUM authEnforcerProvider punya kesempatan bereaksi

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login gagal - user null');
      }

      final authId = response.user!.id;

      // LANGSUNG query status - INI HARUS CEPAT sebelum UI bereaksi
      final userData = await _supabase
          .from('users')
          .select('role, status, id_auth')
          .eq('id_auth', authId)
          .maybeSingle();

      if (userData == null) {
        // Tidak ada di tabel users - LANGSUNG batalkan session
        await _supabase.auth.signOut();
        await Future.delayed(
          const Duration(milliseconds: 100),
        ); // Pastikan signOut selesai
        throw Exception('Akun tidak terdaftar di sistem');
      }

      // CEK STATUS - INI CRITICAL POINT
      final status = (userData['status'] ?? '').toString().toLowerCase();
      if (status != 'aktif') {
        // BATALKAN SESSION SEGERA - Ini yang paling penting!
        print('❌ Status tidak aktif: $status - MEMBATALKAN LOGIN');
        await _supabase.auth.signOut();
        // Delay kecil untuk memastikan signOut benar-benar selesai
        // sebelum throw exception ke UI
        await Future.delayed(const Duration(milliseconds: 150));
        throw Exception('Akun Anda tidak aktif. Hubungi administrator.');
      }

      // Jika sampai sini = status aktif, session valid
      final userRole = userData['role'] as String? ?? 'warga';
      print(
        '✅ Login berhasil - Email: $email, Role: $userRole, Status: $status',
      );

      return {
        'user': response.user,
        'role': userRole,
        'email': response.user!.email,
      };
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');

      // Handle specific auth errors
      final errorMsg = e.message.toLowerCase();
      if (errorMsg.contains('invalid') && errorMsg.contains('credentials')) {
        throw Exception('Password salah');
      } else if (errorMsg.contains('email not confirmed')) {
        throw Exception('Email belum dikonfirmasi');
      } else if (errorMsg.contains('user not found')) {
        throw Exception('Email tidak terdaftar');
      }

      throw Exception('Login gagal: ${e.message}');
    } catch (e) {
      print('❌ Error during login: $e');
      // Don't wrap if it's already an Exception with our custom message
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error: $e');
    }
  }

  /// Register an auth user and return the newly created auth id.
  /// This does not create the application `users` record — callers
  /// should insert into their `users` table as required.
  Future<String> register({
    required String email,
    required String password,
  }) async {
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

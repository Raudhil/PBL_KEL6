import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

// Custom exception untuk login error
class LoginException implements Exception {
  final String message;
  LoginException(this.message);

  @override
  String toString() => message;
}

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
        await _supabase.auth.signOut();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // PRECHECK via Edge Function: validate email existence and status
      // Requires an Edge Function named 'check_email_status' that accepts { email }
      // and returns { exists: bool, status: 'aktif' | 'nonaktif' | null }
      try {
        final precheck = await _supabase.functions.invoke('check_email_status',
            body: {
          'email': email,
        });
        
        // Parse JSON response (precheck.data might be String or Map)
        final data = precheck.data is String
            ? jsonDecode(precheck.data as String) as Map<String, dynamic>?
            : precheck.data as Map<String, dynamic>?;
            
        if (data == null) {
        } else {
          final exists = (data['exists'] == true);
          final status = (data['status'] ?? '').toString().toLowerCase();
          
          if (!exists) {
            // Case 1: email tidak ditemukan
            throw LoginException('Email tidak ditemukan');
          }
          if (status.isNotEmpty && status != 'aktif') {
            // Case 3: email ditemukan tapi status tidak aktif
            throw LoginException('Status akun tidak aktif');
          }
        }
      } on LoginException {
        // Don't suppress LoginException - re-throw immediately
        rethrow;
      } catch (preErr) {
        // Precheck unavailable, continue to password auth
      }

      // STEP 1: Login terlebih dahulu untuk mendapatkan auth_id (UUID)
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw LoginException('Login gagal - user null');
      }

      final authId = response.user!.id;

      // STEP 2: Cari record di public.users berdasarkan id_auth (final validation)
      final userRecord = await _supabase
          .from('users')
          .select('id_role, status')
          .eq('id_auth', authId)
          .maybeSingle();

      if (userRecord == null) {
        await _supabase.auth.signOut();
        throw LoginException('Data akun tidak ditemukan');
      }

      // Status sudah di-check di precheck, tapi validasi lagi untuk safety
      final status = (userRecord['status'] ?? '').toString().toLowerCase();
      if (status != 'aktif') {
        throw LoginException('Status akun tidak aktif');
      }

      final userRole = userRecord['id_role'] ?? 1;

      return {
        'user': response.user,
        'role': userRole,
        'email': response.user!.email,
      };
    } on LoginException {
      // Pass through custom login exceptions
      rethrow;
    } on AuthException catch (e) {

      final errorMsg = e.message.toLowerCase();
      if (errorMsg.contains('user not found') ||
          errorMsg.contains('email not found')) {
        // Case 1: email tidak ditemukan (fallback if precheck failed)
        throw LoginException('Email tidak ditemukan');
      } else if (errorMsg.contains('invalid') &&
          errorMsg.contains('credentials')) {
        // Case 2: email ditemukan tapi password salah
        throw LoginException('Password salah');
      } else if (errorMsg.contains('email not confirmed')) {
        throw LoginException('Email belum dikonfirmasi');
      }

      throw LoginException(e.message);
    } catch (e) {
      // Check if it's a database/server error
      String errStr = e.toString().toLowerCase();
      if (errStr.contains('postgrest') ||
          errStr.contains('column') ||
          errStr.contains('400') ||
          errStr.contains('500') ||
          errStr.contains('server')) {
        // Database or server error
        throw LoginException('Kesalahan server. Coba lagi nanti.');
      } else if (errStr.contains('network') ||
          errStr.contains('connection') ||
          errStr.contains('timeout')) {
        throw LoginException('Kesalahan koneksi. Periksa internet Anda.');
      }

      throw LoginException('Error: $e');
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
      await _supabase.auth.signOut();
    } catch (e) {
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/role_provider.dart';
import '../../../core/services/auth_service.dart';

class AuthController extends StateNotifier<bool> {
  AuthController(this.ref) : super(false);

  final Ref ref;
  final _supabase = Supabase.instance.client;
  final AuthService _service = AuthService();

  // =========================
  //        REGISTER
  // =========================
  Future<void> register({
    required String email,
    required String password,
    required String nama,
    required String nik,
  }) async {
    state = true;

    try {
      // 1. Cari warga berdasarkan NIK (cek terlebih dahulu sebelum membuat Auth)
      final warga = await _supabase
          .from('warga')
          .select()
          .eq('nik', nik)
          .maybeSingle();

      if (warga == null) {
        throw Exception("NIK tidak ditemukan");
      }

      // Ambil id_warga dari record warga (dukungan beberapa skema kolom)
      final Map<String, dynamic> wargaMap = Map<String, dynamic>.from(
        warga as Map,
      );
      final dynamic idWarga =
          wargaMap['id'] ?? wargaMap['id_warga'] ?? wargaMap['idWarga'];
      if (idWarga == null) {
        throw Exception("Kolom id pada tabel warga tidak ditemukan");
      }

      // 3. Cek apakah warga sudah memiliki akun users
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('id_warga', idWarga)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception("NIK ini sudah terdaftar di akun lain");
      }

      // 4. Buat akun Auth via AuthService: service hanya membuat auth user
      final authId = await _service.register(email: email, password: password);

      // 5. Insert ke tabel USERS dengan id_warga dari warga
      final insertRes = await _supabase
          .from('users')
          .insert({
            'id_auth': authId,
            'id_warga': idWarga,
            'full_name': nama,
            'status': 'Tidak Aktif', // optional, default-nya 'Tidak Aktif'
          })
          .select()
          .maybeSingle();

      if (insertRes == null) {
        // Jika insert gagal setelah Auth dibuat, sign out dan informasikan
        try {
          await _supabase.auth.signOut();
        } catch (_) {}
        throw Exception("Gagal menyimpan data user ke tabel users");
      }

      // IMPORTANT: Ensure the client is NOT logged in after registration.
      // Supabase may create a session during signUp depending on settings,
      // so explicitly sign out so the user must log in.
      try {
        await _supabase.auth.signOut();
      } catch (_) {}

      print("Register berhasil (user must login)");
    } catch (e) {
      print("Register gagal: $e");
      rethrow;
    } finally {
      state = false;
    }
  }

  // =========================
  //          LOGIN
  // =========================
  Future<void> login(String email, String password) async {
    state = true;

    try {
      // Delegate sign-in and validation to AuthService
      final result = await _service.signIn(email: email, password: password);

      // At this point signIn already validated status/role. Refresh role provider
      ref.invalidate(roleProvider);
      print("✅ Login berhasil - roleProvider di-refresh (email: ${result['email']})");
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();

      if (msg.contains("invalid") && msg.contains("credentials")) {
        throw Exception("Email atau password salah");
      }

      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    } finally {
      state = false;
    }
  }

  // =========================
  //          LOGOUT
  // =========================
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();

      // Refresh roleProvider setelah logout
      ref.invalidate(roleProvider);
      print("✅ Logout berhasil - roleProvider di-refresh");
    } catch (e) {
      print("Logout gagal: $e");
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref);
});

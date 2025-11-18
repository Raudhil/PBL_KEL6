import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false);

  final _supabase = Supabase.instance.client;

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
      final Map<String, dynamic> wargaMap = Map<String, dynamic>.from(warga as Map);
      final dynamic idWarga = wargaMap['id'] ?? wargaMap['id_warga'] ?? wargaMap['idWarga'];
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

      // 4. Setelah semua pemeriksaan DB berhasil, buat akun Auth
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final authId = res.user?.id;
      if (authId == null) {
        throw Exception("Gagal membuat akun Auth");
      }

      // 5. Insert ke tabel USERS dengan id_warga dari warga
      final insertRes = await _supabase.from('users').insert({
        'id_auth': authId,
        'id_warga': idWarga,
        'full_name': nama,
        'status': 'Tidak Aktif', // optional, default-nya 'Tidak Aktif'
      }).select().maybeSingle();

      if (insertRes == null) {
        // Jika insert gagal setelah Auth dibuat, sign out dan informasikan
        // Catatan: Menghapus record Auth yang baru dibuat dari client memerlukan
        // service role/admin privileges (sebaiknya dilakukan server-side).
        try {
          await _supabase.auth.signOut();
        } catch (_) {}
        throw Exception("Gagal menyimpan data user ke tabel users");
      }

      print("Register berhasil");
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
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Login invalid tapi Supabase tidak melempar error → handle manual
    if (res.user == null) {
      throw Exception("Email atau password salah");
    }

    final authId = res.user!.id;

    final data = await _supabase
        .from('users')
        .select()
        .eq('id_auth', authId)
        .maybeSingle();

    if (data == null) {
      await _supabase.auth.signOut();
      throw Exception("Data akun tidak ditemukan");
    }

    final status = data['status']?.toString().trim().toLowerCase();

    if (status == 'tidak aktif') {
      await _supabase.auth.signOut();
      throw Exception("Akun Anda tidak aktif, silakan hubungi admin");
    }

    if (status != 'aktif') {
      await _supabase.auth.signOut();
      throw Exception("Status akun tidak valid");
    }

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
      print("Logout berhasil");
    } catch (e) {
      print("Logout gagal: $e");
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController();
});

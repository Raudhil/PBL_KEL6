import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false);

  final _supabase = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    state = true; // loading
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('✅ AuthController: Login berhasil');
    } catch (e) {
      print('❌ AuthController: Login gagal - $e');
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    print('👋 AuthController: Logout berhasil');
  }
}

final authProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController();
});

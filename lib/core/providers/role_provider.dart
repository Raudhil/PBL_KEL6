import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final roleProvider = FutureProvider<String>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    print('❌ RoleProvider: User belum login');
    return 'guest';
  }

  final userId = user.id;
  final email = user.email ?? '';

  try {
    // JOIN tabel users dengan tabel role berdasarkan id_auth (UUID dari auth)
    final data = await supabase
        .from('users')
        .select('id_role, role!inner(nama)')
        .eq('id_auth', userId)
        .maybeSingle();

    if (data == null) {
      print(
        '🔍 RoleProvider: User tidak ditemukan di public.users untuk UUID: $userId',
      );
      return 'warga';
    }

    // Ambil nama role dari relasi
    final roleData = data['role'] as Map<String, dynamic>?;
    final roleName = roleData?['nama'] as String? ?? 'warga';

    print('✅ RoleProvider: User $email (UUID: $userId) → Role: $roleName');
    return roleName.toLowerCase().trim();
  } catch (e) {
    print('❌ RoleProvider: Error - $e');
    return 'warga';
  }
});

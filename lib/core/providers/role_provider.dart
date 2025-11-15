import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final roleProvider = FutureProvider<String>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return 'guest';

  final email = user.email ?? '';

  if (email.isEmpty) return 'warga';

  try {
    final data = await supabase
        .from('users')
        .select('role')
        .eq('email', email)
        .maybeSingle();

    final role = data?['role'] as String? ?? 'warga';
    print(' RoleProvider: Role untuk $email = $role');
    return role;
  } catch (e) {
    print(' RoleProvider: Error - $e');
    return 'warga';
  }
});

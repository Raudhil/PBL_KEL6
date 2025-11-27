import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Exposes Supabase auth state change stream so UI can react to auth events.
final authStateProvider = StreamProvider.autoDispose((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Holds an optional authentication-related error message that UI can show.
final authErrorProvider = StateProvider<String?>((ref) => null);

/// Enforces that only users with `status` == 'aktif' remain signed in.
///
/// This provider listens to auth state changes and when a session appears
/// it checks the `users` table for the account status. If the status is
/// not 'aktif' it signs out the client. The provider is auto-disposed
/// with the widget tree so the listener is cleaned up when no longer needed.
final authEnforcerProvider = Provider.autoDispose((ref) {
  final stream = ref.watch(authStateProvider.stream);
  final sub = stream.listen((event) async {
    try {
      final session = event.session;
      if (session == null) return;

      final authId = session.user.id;

      final db = Supabase.instance.client;
      final userData = await db.from('users').select('status').eq('id_auth', authId).maybeSingle();
      final status = (userData?['status'] ?? '').toString().toLowerCase();

      // Expect stored statuses like 'aktif' or 'tidak aktif' (case-insensitive).
      if (status != 'aktif') {
        // Sign out if account is not active
        // set an error message so UI can display why we signed out
        try {
          ref.read(authErrorProvider.notifier).state = 'Akun Anda belum aktif';
        } catch (_) {}
        await db.auth.signOut();
        debugPrint('[AuthEnforcer] Signed out user $authId because status="$status"');
      } else {
        // clear any previous auth error when status is active
        try {
          ref.read(authErrorProvider.notifier).state = null;
        } catch (_) {}
      }
    } catch (e, st) {
      debugPrint('[AuthEnforcer] error checking user status: $e\n$st');
    }
  });

  ref.onDispose(() {
    sub.cancel();
  });

  // The provider itself doesn't expose a value; it's used for side-effects.
  return null;
});

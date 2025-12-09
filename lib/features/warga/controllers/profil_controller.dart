import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/data/models/profil_model.dart';
import 'package:jawara/core/services/profil_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profilControllerProvider =
    StateNotifierProvider<ProfilController, AsyncValue<ProfilModel>>(
      (ref) => ProfilController(),
    );

class ProfilController extends StateNotifier<AsyncValue<ProfilModel>> {
  ProfilController() : super(const AsyncValue.loading()) {
    loadData();
    _setupRealtimeSubscription();
    // listen to auth state changes so UI updates automatically when user switches account
    _authSub = service.supabase.auth.onAuthStateChange.listen((_) {
      loadData();
    });
  }

  StreamSubscription<dynamic>? _authSub;
  RealtimeChannel? _realtimeChannel;

  final service = ProfilService();

  File? newAvatarFile;
  Uint8List? newAvatarBytes;

  void _setupRealtimeSubscription() {
    final userId = service.supabase.auth.currentUser?.id;
    if (userId == null) return;

    _realtimeChannel = service.supabase
        .channel('profil_realtime_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id_auth',
            value: userId,
          ),
          callback: (payload) {
            debugPrint('Realtime update detected: ${payload.eventType}');
            loadData();
          },
        )
        .subscribe();
  }

  Future<void> loadData() async {
    // set loading state so UI shows loader while fetching
    state = const AsyncValue.loading();
    try {
      final result = await service.getFullUserData();

      state = AsyncValue.data(
        ProfilModel.fromData(
          user: result["user"],
          publicUser: result["publicUser"],
          warga: result["warga"],
          kk: result["kk"],
          alamat: result["alamat"],
          rt: result["rt"],
          rw: result["rw"],
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  void setAvatar(File? f, Uint8List? b) {
    newAvatarFile = f;
    newAvatarBytes = b;
  }

  Future<void> deleteAvatar() async {
    final data = state.value;
    if (data == null) return;

    // Hapus file dari storage jika ada
    if (data.avatarUrl != null && data.avatarUrl!.isNotEmpty) {
      try {
        // Extract filename from URL
        final uri = Uri.parse(data.avatarUrl!);
        final fileName = uri.pathSegments.last;

        await service.deleteAvatarFromStorage(fileName);
      } catch (e) {
        debugPrint("Error deleting avatar from storage: $e");
      }
    }

    // Update database to set avatar to null
    await service.updateUserData(password: null, avatarUrl: null);

    // Clear local state
    newAvatarBytes = null;
    newAvatarFile = null;

    // Update UI state
    state = AsyncValue.data(data.copyWith(fotoProfile: null, avatarUrl: null));
  }

  Future<void> saveProfile({required String? password}) async {
    final data = state.value;
    if (data == null) return;

    String? avatarUrl = data.avatarUrl;

    // Upload foto baru jika ada
    if (newAvatarFile != null || newAvatarBytes != null) {
      // Hapus foto lama dari storage jika ada
      if (data.avatarUrl != null && data.avatarUrl!.isNotEmpty) {
        try {
          final uri = Uri.parse(data.avatarUrl!);
          final oldFileName = uri.pathSegments.last;
          await service.deleteAvatarFromStorage(oldFileName);
        } catch (e) {
          debugPrint("Error deleting old avatar: $e");
        }
      }

      // Upload foto baru
      avatarUrl = await service.uploadAvatar(
        file: newAvatarFile,
        bytes: newAvatarBytes,
        userId: data.id,
      );
    }

    await service.updateUserData(password: password, avatarUrl: avatarUrl);

    // Clear temporary files
    newAvatarBytes = null;
    newAvatarFile = null;

    // Force reload data dari database untuk memastikan sinkronisasi
    await loadData();
  }
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/data/models/profil_model.dart';
import 'package:jawara/core/services/profil_service.dart';

final profilControllerProvider =
    StateNotifierProvider<ProfilController, AsyncValue<ProfilModel>>(
      (ref) => ProfilController(),
    );

class ProfilController extends StateNotifier<AsyncValue<ProfilModel>> {
  ProfilController() : super(const AsyncValue.loading()) {
    loadData();
    // listen to auth state changes so UI updates automatically when user switches account
    _authSub = service.supabase.auth.onAuthStateChange.listen((_) {
      loadData();
    });
  }

  StreamSubscription<dynamic>? _authSub;

  final service = ProfilService();

  File? newAvatarFile;
  Uint8List? newAvatarBytes;

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

    // update state untuk UI
    state = AsyncValue.data(
      data.copyWith(fotoProfile: avatarUrl, avatarUrl: avatarUrl),
    );

    newAvatarBytes = null;
    newAvatarFile = null;
  }
}

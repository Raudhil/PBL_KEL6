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

  Future<void> saveProfile({
    required String? password,
  }) async {
    final data = state.value;
    if (data == null) return;

    String? avatarUrl;

    if (newAvatarFile != null || newAvatarBytes != null) {
      avatarUrl = await service.uploadAvatar(
        file: newAvatarFile,
        bytes: newAvatarBytes,
        userId: data.id,
      );
    } else {
      avatarUrl = data.avatarUrl;
    }

    await service.updateUserData(
      password: password,
      avatarUrl: avatarUrl,
    );

    // update state untuk UI
    state = AsyncValue.data(
      data.copyWith(
        fotoProfile: avatarUrl,
        avatarUrl: avatarUrl,
      ),
    );

    newAvatarBytes = null;
    newAvatarFile = null;
  }
}

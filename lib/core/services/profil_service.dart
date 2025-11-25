import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getFullUserData() async {
  final user = supabase.auth.currentUser;
  if (user == null) throw "User tidak ditemukan";

  final publicUser = await supabase
      .from("users")
      .select()
      .eq("id_auth", user.id)
      .maybeSingle();

  if (publicUser == null) {
    throw "Data users tidak ditemukan";
  }

  final warga = publicUser["id_warga"] != null
      ? await supabase
          .from("warga")
          .select()
          .eq("id", publicUser["id_warga"])
          .maybeSingle()
      : null;

  // jika warga tidak punya id_kk (kasus tertentu)
  if (warga == null) {
    return {
      "user": user,
      "publicUser": publicUser,
      "warga": null,
      "kk": null,
      "alamat": null,
      "rt": null,
      "rw": null,
    };
  }

  final kk = await supabase
      .from("kk")
      .select()
      .eq("id", warga["id_kk"])
      .maybeSingle();

  if (kk == null) {
    return {
      "user": user,
      "publicUser": publicUser,
      "warga": warga,
      "kk": null,
      "alamat": null,
      "rt": null,
      "rw": null,
    };
  }

  final alamat = await supabase
      .from("alamat")
      .select()
      .eq("id", kk["id_alamat"])
      .maybeSingle();

  if (alamat == null) {
    return {
      "user": user,
      "publicUser": publicUser,
      "warga": warga,
      "kk": kk,
      "alamat": null,
      "rt": null,
      "rw": null,
    };
  }

  final rt = await supabase
      .from("rt")
      .select()
      .eq("id", alamat["id_rt"])
      .maybeSingle();

  if (rt == null) {
    return {
      "user": user,
      "publicUser": publicUser,
      "warga": warga,
      "kk": kk,
      "alamat": alamat,
      "rt": null,
      "rw": null,
    };
  }

  final rw = await supabase
      .from("rw")
      .select()
      .eq("id", rt["id_rw"])
      .maybeSingle();

  return {
    "user": user,
    "publicUser": publicUser,
    "warga": warga,
    "kk": kk,
    "alamat": alamat,
    "rt": rt,
    "rw": rw,
  };
}

  Future<String?> uploadAvatar({
    File? file,
    Uint8List? bytes,
    required String userId,
  }) async {
    final fileName = "avatar_$userId-${DateTime.now().millisecondsSinceEpoch}.jpg";
    final storage = supabase.storage.from("foto_profile");

    try {
      if (bytes != null) {
        await storage.uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
      } else if (file != null) {
        await storage.upload(
          fileName,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
      }

      return storage.getPublicUrl(fileName);
    } catch (e) {
      debugPrint("Upload avatar error: $e");
      return null;
    }
  }

  Future<void> updateUserData({
    required String? password,
    required String? avatarUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw "User tidak ditemukan";

    if (password != null) {
      await supabase.auth.updateUser(
        UserAttributes(
          password: password,
        ),
      );
    }

    // Simpan URL ke tabel users
    if (avatarUrl != null) {
      await supabase
          .from("users")
          .update({"foto_profile": avatarUrl})
          .eq("id_auth", user.id);
    }
  }
}

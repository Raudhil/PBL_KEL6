import 'package:supabase_flutter/supabase_flutter.dart';
import 'warga_model.dart';

class ProfilModel {
  final String id;
  final String email;
  final String? avatarUrl;
  final String? namaLengkap;
  final WargaModel? warga;
  final String? fotoProfile;

  // Tambahan baru
  final int? noKk;
  final String? alamat;
  final int? rt;
  final int? rw;

  ProfilModel({
    required this.id,
    required this.email,
    this.avatarUrl,
    this.namaLengkap,
    this.warga,
    this.fotoProfile,
    this.noKk,
    this.alamat,
    this.rt,
    this.rw,
  });

  factory ProfilModel.fromData({
    required User user,
    Map<String, dynamic>? publicUser,
    Map<String, dynamic>? warga,
    Map<String, dynamic>? kk,
    Map<String, dynamic>? alamat,
    Map<String, dynamic>? rt,
    Map<String, dynamic>? rw,
  }) {
    final foto = publicUser?["foto_profile"];

    return ProfilModel(
      id: publicUser?["id"].toString() ?? "",
      email: user.email ?? "",
      avatarUrl: foto,
      fotoProfile: foto,
      namaLengkap: warga?["nama_lengkap"],
      warga: warga != null ? WargaModel.fromJson(Map<String, dynamic>.from(warga)) : null,

      // Tambahan
      noKk: kk?["nomor"],
      alamat: alamat?["alamat"],
      rt: rt?["nomor"],
      rw: rw?["nomor"],
    );
  }

  ProfilModel copyWith({
    String? id,
    String? email,
    String? avatarUrl,
    String? namaLengkap,
    WargaModel? warga,
    String? fotoProfile,

    int? noKk,
    String? alamat,
    int? rt,
    int? rw,
  }) {
    return ProfilModel(
      id: id ?? this.id,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      warga: warga ?? this.warga,
      fotoProfile: fotoProfile ?? this.fotoProfile,

      noKk: noKk ?? this.noKk,
      alamat: alamat ?? this.alamat,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
    );
  }
}

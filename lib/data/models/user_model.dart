/// Enum untuk status user
enum StatusUser { aktif, tidakAktif }

/// Extension untuk status user
extension StatusUserExt on StatusUser {
  String get label {
    switch (this) {
      case StatusUser.aktif:
        return 'Aktif';
      case StatusUser.tidakAktif:
        return 'Tidak Aktif';
    }
  }

  String get value {
    switch (this) {
      case StatusUser.aktif:
        return 'Aktif';
      case StatusUser.tidakAktif:
        return 'Tidak Aktif';
    }
  }
}

/// Model untuk User dengan data lengkap dari join table
class UserModel {
  final int id;
  final String? idAuth;
  final int? idRole;
  final int? idWarga;
  final String? fullName;
  final StatusUser status;
  final String? fotoProfile;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relasi
  final RoleModel? role;
  final WargaModel? warga;

  UserModel({
    required this.id,
    this.idAuth,
    this.idRole,
    this.idWarga,
    this.fullName,
    required this.status,
    this.fotoProfile,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.warga,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      idAuth: json['id_auth'] as String?,
      idRole: json['id_role'] as int?,
      idWarga: json['id_warga'] as int?,
      fullName: json['full_name'] as String?,
      status: _statusFromString(json['status'] as String? ?? 'Tidak Aktif'),
      fotoProfile: json['foto_profile'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      role: json['role'] != null
          ? RoleModel.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      warga: json['warga'] != null
          ? WargaModel.fromJson(json['warga'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_auth': idAuth,
      'id_role': idRole,
      'id_warga': idWarga,
      'full_name': fullName,
      'status': status.value,
      'foto_profile': fotoProfile,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static StatusUser _statusFromString(String value) {
    switch (value) {
      case 'Aktif':
        return StatusUser.aktif;
      case 'Tidak Aktif':
        return StatusUser.tidakAktif;
      default:
        return StatusUser.tidakAktif;
    }
  }

  /// Helper getter untuk email dari warga
  String get email => warga?.nomorHp ?? '-';

  /// Helper getter untuk nama display
  String get displayName => fullName ?? warga?.namaLengkap ?? 'Unknown User';

  /// Helper getter untuk NIK
  String? get nik => warga?.nik;
}

/// Model untuk Role
class RoleModel {
  final int id;
  final String nama;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoleModel({
    required this.id,
    required this.nama,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Model untuk Warga (simplified untuk user management)
class WargaModel {
  final int id;
  final int? idKk; // ✅ Nullable karena bisa null dari database
  final String nik;
  final String namaLengkap;
  final String? jenisKelamin;
  final DateTime? tanggalLahir;
  final String? nomorHp;
  final String? fotoKtp;

  WargaModel({
    required this.id,
    this.idKk, // ✅ Optional parameter
    required this.nik,
    required this.namaLengkap,
    this.jenisKelamin,
    this.tanggalLahir,
    this.nomorHp,
    this.fotoKtp,
  });

  factory WargaModel.fromJson(Map<String, dynamic> json) {
    return WargaModel(
      id: json['id'] as int,
      idKk: json['id_kk'] as int?, // ✅ Cast ke int? untuk handle null
      nik: json['nik'] as String,
      namaLengkap: json['nama_lengkap'] as String,
      jenisKelamin: json['jenis_kelamin'] as String?,
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.parse(json['tanggal_lahir'] as String)
          : null,
      nomorHp: json['nomor_hp'] as String?,
      fotoKtp: json['foto_ktp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_kk': idKk,
      'nik': nik,
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir?.toIso8601String().split('T')[0],
      'nomor_hp': nomorHp,
      'foto_ktp': fotoKtp,
    };
  }
}

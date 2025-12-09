/// Model untuk Pengumuman
class PengumumanModel {
  final int id;
  final String judul;
  final String isi;
  final String? fotoUrl;
  final String? dokumenUrl;
  final int idPembuat;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Relasi dengan users (pembuat)
  final PembuatPengumuman? pembuat;

  PengumumanModel({
    required this.id,
    required this.judul,
    required this.isi,
    this.fotoUrl,
    this.dokumenUrl,
    required this.idPembuat,
    required this.createdAt,
    this.updatedAt,
    this.pembuat,
  });

  factory PengumumanModel.fromJson(Map<String, dynamic> json) {
    return PengumumanModel(
      id: json['id'] as int,
      judul: json['judul'] as String,
      isi: json['isi'] as String,
      fotoUrl: json['foto_url'] as String?,
      dokumenUrl: json['dokumen_url'] as String?,
      idPembuat: json['id_pembuat'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      pembuat: json['pembuat'] != null
          ? PembuatPengumuman.fromJson(json['pembuat'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'foto_url': fotoUrl,
      'dokumen_url': dokumenUrl,
      'id_pembuat': idPembuat,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PengumumanModel copyWith({
    int? id,
    String? judul,
    String? isi,
    String? fotoUrl,
    String? dokumenUrl,
    int? idPembuat,
    DateTime? createdAt,
    DateTime? updatedAt,
    PembuatPengumuman? pembuat,
  }) {
    return PengumumanModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      dokumenUrl: dokumenUrl ?? this.dokumenUrl,
      idPembuat: idPembuat ?? this.idPembuat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pembuat: pembuat ?? this.pembuat,
    );
  }

  /// Check apakah pengumuman punya foto
  bool get hasFoto => fotoUrl != null && fotoUrl!.isNotEmpty;

  /// Check apakah pengumuman punya dokumen
  bool get hasDokumen => dokumenUrl != null && dokumenUrl!.isNotEmpty;

  /// Get nama pembuat
  String get namaPembuat => pembuat?.fullName ?? 'Unknown';

  /// Get role pembuat
  String get rolePembuat => pembuat?.role ?? 'Unknown';
}

/// Model untuk data pembuat pengumuman (dari relasi users)
class PembuatPengumuman {
  final int id;
  final String fullName;
  final String? role;

  PembuatPengumuman({required this.id, required this.fullName, this.role});

  factory PembuatPengumuman.fromJson(Map<String, dynamic> json) {
    return PembuatPengumuman(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      role: json['role'] != null
          ? (json['role'] as Map<String, dynamic>)['nama'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'role': role};
  }
}

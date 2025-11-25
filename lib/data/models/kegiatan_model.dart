/// Enum untuk status kegiatan
enum StatusKegiatan { akanDatang, sedangBerlangsung, selesai, dibatalkan }

/// Enum untuk kategori kegiatan
enum KategoriKegiatan {
  sosial,
  kebersihan,
  kesehatan,
  pendidikan,
  keagamaan,
  olahraga,
  budaya,
  lainnya,
}

/// Extension untuk label kategori
extension KategoriKegiatanExt on KategoriKegiatan {
  String get label {
    switch (this) {
      case KategoriKegiatan.sosial:
        return 'Sosial';
      case KategoriKegiatan.kebersihan:
        return 'Kebersihan';
      case KategoriKegiatan.kesehatan:
        return 'Kesehatan';
      case KategoriKegiatan.pendidikan:
        return 'Pendidikan';
      case KategoriKegiatan.keagamaan:
        return 'Keagamaan';
      case KategoriKegiatan.olahraga:
        return 'Olahraga';
      case KategoriKegiatan.budaya:
        return 'Budaya';
      case KategoriKegiatan.lainnya:
        return 'Lainnya';
    }
  }

  String get value {
    switch (this) {
      case KategoriKegiatan.sosial:
        return 'sosial';
      case KategoriKegiatan.kebersihan:
        return 'kebersihan';
      case KategoriKegiatan.kesehatan:
        return 'kesehatan';
      case KategoriKegiatan.pendidikan:
        return 'pendidikan';
      case KategoriKegiatan.keagamaan:
        return 'keagamaan';
      case KategoriKegiatan.olahraga:
        return 'olahraga';
      case KategoriKegiatan.budaya:
        return 'budaya';
      case KategoriKegiatan.lainnya:
        return 'lainnya';
    }
  }
}

/// Extension untuk label status
extension StatusKegiatanExt on StatusKegiatan {
  String get label {
    switch (this) {
      case StatusKegiatan.akanDatang:
        return 'Akan Datang';
      case StatusKegiatan.sedangBerlangsung:
        return 'Sedang Berlangsung';
      case StatusKegiatan.selesai:
        return 'Selesai';
      case StatusKegiatan.dibatalkan:
        return 'Dibatalkan';
    }
  }

  String get value {
    switch (this) {
      case StatusKegiatan.akanDatang:
        return 'akan_datang';
      case StatusKegiatan.sedangBerlangsung:
        return 'sedang_berlangsung';
      case StatusKegiatan.selesai:
        return 'selesai';
      case StatusKegiatan.dibatalkan:
        return 'dibatalkan';
    }
  }
}

class KegiatanModel {
  final String id;
  final String judul;
  final String? deskripsi;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;
  final String? lokasi;
  final String penyelenggara;
  final KategoriKegiatan kategori;
  final StatusKegiatan status;
  final int? kuotaPeserta;
  final String? fotoUrl;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KegiatanModel({
    required this.id,
    required this.judul,
    this.deskripsi,
    required this.tanggalMulai,
    this.tanggalSelesai,
    this.lokasi,
    required this.penyelenggara,
    required this.kategori,
    required this.status,
    this.kuotaPeserta,
    this.fotoUrl,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory KegiatanModel.fromJson(Map<String, dynamic> json) {
    return KegiatanModel(
      id: json['id'] as String,
      judul: json['judul'] as String,
      deskripsi: json['deskripsi'] as String?,
      tanggalMulai: DateTime.parse(json['tanggal_mulai'] as String),
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.parse(json['tanggal_selesai'] as String)
          : null,
      lokasi: json['lokasi'] as String?,
      penyelenggara: json['penyelenggara'] as String,
      kategori: _kategoriFromString(json['kategori'] as String),
      status: _statusFromString(json['status'] as String),
      kuotaPeserta: json['kuota_peserta'] as int?,
      fotoUrl: json['foto_url'] as String?,
      createdBy: json['created_by'] as String?,
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
      'judul': judul,
      'deskripsi': deskripsi,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'lokasi': lokasi,
      'penyelenggara': penyelenggara,
      'kategori': kategori.value,
      'status': status.value,
      'kuota_peserta': kuotaPeserta,
      'foto_url': fotoUrl,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static KategoriKegiatan _kategoriFromString(String value) {
    switch (value) {
      case 'sosial':
        return KategoriKegiatan.sosial;
      case 'kebersihan':
        return KategoriKegiatan.kebersihan;
      case 'kesehatan':
        return KategoriKegiatan.kesehatan;
      case 'pendidikan':
        return KategoriKegiatan.pendidikan;
      case 'keagamaan':
        return KategoriKegiatan.keagamaan;
      case 'olahraga':
        return KategoriKegiatan.olahraga;
      case 'budaya':
        return KategoriKegiatan.budaya;
      default:
        return KategoriKegiatan.lainnya;
    }
  }

  static StatusKegiatan _statusFromString(String value) {
    switch (value) {
      case 'akan_datang':
        return StatusKegiatan.akanDatang;
      case 'sedang_berlangsung':
        return StatusKegiatan.sedangBerlangsung;
      case 'selesai':
        return StatusKegiatan.selesai;
      case 'dibatalkan':
        return StatusKegiatan.dibatalkan;
      default:
        return StatusKegiatan.akanDatang;
    }
  }

  /// Helper untuk format tanggal
  String get formattedTanggalMulai {
    return _formatDate(tanggalMulai);
  }

  String? get formattedTanggalSelesai {
    return tanggalSelesai != null ? _formatDate(tanggalSelesai!) : null;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Helper untuk durasi kegiatan
  String get durasi {
    if (tanggalSelesai == null) {
      return formattedTanggalMulai;
    }
    return '$formattedTanggalMulai - $formattedTanggalSelesai';
  }

  /// Helper untuk cek apakah kegiatan sudah lewat
  bool get isPast {
    final now = DateTime.now();
    if (tanggalSelesai != null) {
      return tanggalSelesai!.isBefore(now);
    }
    return tanggalMulai.isBefore(now);
  }

  /// Helper untuk cek apakah kegiatan sedang berlangsung
  bool get isOngoing {
    final now = DateTime.now();
    if (tanggalSelesai != null) {
      return tanggalMulai.isBefore(now) && tanggalSelesai!.isAfter(now);
    }
    return false;
  }
}

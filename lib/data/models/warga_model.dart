class WargaModel {
  final int id;
  final int idKk;
  final String? nomorKk; // Nomor KK dari tabel kk
  final String nik;
  final String namaLengkap;
  final String jenisKelamin;
  final DateTime tanggalLahir;
  final String? nomorHp;
  final String? fotoKtp;
  final String? alamat;
  final String? peranKeluarga; // Kepala Keluarga, Istri, Anak, dll
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userStatus; // Status dari tabel users

  WargaModel({
    required this.id,
    required this.idKk,
    this.nomorKk,
    required this.nik,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.tanggalLahir,
    this.nomorHp,
    this.fotoKtp,
    this.alamat,
    this.peranKeluarga,
    required this.createdAt,
    required this.updatedAt,
    this.userStatus,
  });

  factory WargaModel.fromJson(Map<String, dynamic> json) {
    // Extract user status jika ada join dengan tabel users
    String? userStatus;
    if (json['users'] != null) {
      final users = json['users'];
      // Handle both array dan object
      if (users is List && users.isNotEmpty) {
        userStatus = users[0]['status'];
      } else if (users is Map) {
        userStatus = users['status'];
      }
    }

    // Extract alamat dan nomor KK dari relasi kk -> alamat
    String? alamatValue;
    String? nomorKkValue;
    if (json['kk'] != null) {
      final kk = json['kk'];
      if (kk is Map) {
        // Extract nomor KK
        nomorKkValue = kk['nomor'];

        // Extract alamat
        if (kk['alamat'] != null) {
          final alamatData = kk['alamat'];
          if (alamatData is Map && alamatData['alamat'] != null) {
            alamatValue = alamatData['alamat'];
          }
        }
      }
    }

    return WargaModel(
      id: json['id'],
      idKk: json['id_kk'],
      nomorKk: nomorKkValue,
      nik: json['nik'],
      namaLengkap: json['nama_lengkap'],
      jenisKelamin: json['jenis_kelamin'],
      tanggalLahir: DateTime.parse(json['tanggal_lahir']),
      nomorHp: json['nomor_hp'],
      fotoKtp: json['foto_ktp'],
      alamat: alamatValue,
      peranKeluarga: json['peran_keluarga'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userStatus: userStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id, // Only include id if not 0 (for updates)
      'id_kk': idKk,
      'nik': nik,
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir.toIso8601String(),
      'nomor_hp': nomorHp,
      'foto_ktp': fotoKtp,
      'peran_keluarga': peranKeluarga,
      // Alamat tidak disimpan langsung di tabel warga, tapi di tabel alamat via kk
      // 'alamat': alamat,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (userStatus != null) 'user_status': userStatus,
    };
  }
}

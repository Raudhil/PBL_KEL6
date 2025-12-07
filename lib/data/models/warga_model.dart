class WargaModel {
  final int id;
  final int idKk;
  final String nik;
  final String namaLengkap;
  final String jenisKelamin;
  final DateTime tanggalLahir;
  final String? nomorHp;
  final String? fotoKtp;
  final String? alamat;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userStatus; // Status dari tabel users

  WargaModel({
    required this.id,
    required this.idKk,
    required this.nik,
    required this.namaLengkap,
    required this.jenisKelamin,
    required this.tanggalLahir,
    this.nomorHp,
    this.fotoKtp,
    this.alamat,
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

    return WargaModel(
      id: json['id'],
      idKk: json['id_kk'],
      nik: json['nik'],
      namaLengkap: json['nama_lengkap'],
      jenisKelamin: json['jenis_kelamin'],
      tanggalLahir: DateTime.parse(json['tanggal_lahir']),
      nomorHp: json['nomor_hp'],
      fotoKtp: json['foto_ktp'],
      alamat: json['alamat'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userStatus: userStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_kk': idKk,
      'nik': nik,
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir.toIso8601String(),
      'nomor_hp': nomorHp,
      'foto_ktp': fotoKtp,
      'alamat': alamat,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (userStatus != null) 'user_status': userStatus,
    };
  }
}

class TransaksiIuran {
  final int id;
  final int idIuran;
  final String? status;
  final DateTime? tanggalBayar;
  final String? metode;
  final String? buktiTransaksi;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? idUser;

  TransaksiIuran({
    required this.id,
    required this.idIuran,
    this.status,
    this.tanggalBayar,
    this.metode,
    this.buktiTransaksi,
    this.createdAt,
    this.updatedAt,
    this.idUser,
  });

  factory TransaksiIuran.fromMap(Map<String, dynamic> map) {
    return TransaksiIuran(
      id: map['id'],
      idIuran: map['id_iuran'],
      status: map['status'],
      tanggalBayar: map['tanggal_bayar'] != null
          ? DateTime.parse(map['tanggal_bayar'])
          : null,
      metode: map['metode'],
      buktiTransaksi: map['bukti_transaksi'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      idUser: map['id_user'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_iuran': idIuran,
      'status': status,
      'tanggal_bayar': tanggalBayar?.toIso8601String(),
      'metode': metode,
      'bukti_transaksi': buktiTransaksi,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'id_user': idUser,
    };
  }
}

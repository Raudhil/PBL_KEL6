class KeuanganModel {
  final int? id;
  final String title;
  final double amount;
  final String? type; // 'pemasukan' or 'pengeluaran'
  final String? note;
  final DateTime? createdAt;

  KeuanganModel({
    this.id,
    required this.title,
    required this.amount,
    this.type,
    this.note,
    this.createdAt,
  });

  factory KeuanganModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse numbers coming as int, double or string
    double parseAmount(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    // Try common field names used in different schemas
    final idVal = json['id'];
    final titleVal = json['sumber_transaksi'] ?? '';
    final amountVal = json['jumlah'];
    // Prefer the database `created_at` timestamp for display and ordering.
    // If not present, fall back to the explicit `tanggal` field.
    final createdAtVal = json['created_at'] ?? json['tanggal'];

    // Normalize transaction type to 'Pemasukan' or 'Pengeluaran' when possible
    String? rawType = (json['jenis_transaksi'])?.toString();
    String? normalizeType(String? v) {
      if (v == null) return null;
      final s = v.trim().toLowerCase();
      if (s == 'pemasukan' || s == 'income' || s == 'masuk') return 'Pemasukan';
      if (s == 'pengeluaran' || s == 'expense' || s == 'keluar') return 'Pengeluaran';
      // Some APIs use single-letter flags
      if (s == 'p' || s == 'in') return 'Pemasukan';
      if (s == 'k' || s == 'out') return 'Pengeluaran';
      // unknown -> keep original casing
      return v;
    }

    final normalizedType = normalizeType(rawType);

    return KeuanganModel(
      id: idVal is int ? idVal : (idVal is String ? int.tryParse(idVal) : null),
      title: titleVal is String ? titleVal : titleVal.toString(),
      amount: parseAmount(amountVal),
      type: normalizedType,
      note: json['deskripsi'],
        createdAt: createdAtVal != null
          ? (createdAtVal is DateTime
            ? createdAtVal
            : DateTime.tryParse(createdAtVal.toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sumber_transaksi': title,
      'jumlah': amount,
      'jenis_transaksi': type,
      'deskripsi': note,
    };
  }
}

class KeuanganTotals {
  final double total;
  final double pemasukan;
  final double pengeluaran;

  KeuanganTotals({required this.total, required this.pemasukan, required this.pengeluaran});
}

class Keuangan {
  final int id;
  final String? jenisTransaksi;
  final String? sumberTransaksi;
  final double? jumlah;
  final String? deskripsi;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? idTransaksiIuran;
  final int idRt;

  Keuangan({
    required this.id,
    this.jenisTransaksi,
    this.sumberTransaksi,
    this.jumlah,
    this.deskripsi,
    required this.createdAt,
    this.updatedAt,
    this.idTransaksiIuran,
    required this.idRt,
  });

  factory Keuangan.fromMap(Map<String, dynamic> map) {
    return Keuangan(
      id: map['id'],
      jenisTransaksi: map['jenis_transaksi'],
      sumberTransaksi: map['sumber_transaksi'],
      jumlah: map['jumlah'] != null
          ? double.tryParse(map['jumlah'].toString())
          : null,
      deskripsi: map['deskripsi'],
      // Prefer the `created_at` timestamp for createdAt; fall back to
      // `tanggal` if `created_at` is not present.
      createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'])
        : (map['tanggal'] != null ? DateTime.parse(map['tanggal']) : DateTime.now()),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      idTransaksiIuran: map['id_transaksi_iuran'],
      idRt: map['id_rt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis_transaksi': jenisTransaksi,
      'sumber_transaksi': sumberTransaksi,
      'jumlah': jumlah,
      'deskripsi': deskripsi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'id_transaksi_iuran': idTransaksiIuran,
      'id_rt': idRt,
    };
  }
}

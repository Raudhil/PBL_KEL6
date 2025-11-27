/// Status transaksi marketplace
enum StatusTransaksi {
  pending('pending', 'Menunggu Konfirmasi'),
  dikonfirmasi('dikonfirmasi', 'Dikonfirmasi'),
  selesai('selesai', 'Selesai'),
  dibatalkan('dibatalkan', 'Dibatalkan');

  final String value;
  final String label;
  const StatusTransaksi(this.value, this.label);

  static StatusTransaksi fromString(String value) {
    return StatusTransaksi.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StatusTransaksi.pending,
    );
  }
}

/// Model untuk transaksi marketplace
class TransaksiMarketplaceModel {
  final int id;
  final int idPembeli;
  final int? idPenjual;
  final double total;
  final StatusTransaksi status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final String? namaPembeli;
  final String? namaPenjual;
  final List<DetailTransaksiModel>? items;

  const TransaksiMarketplaceModel({
    required this.id,
    required this.idPembeli,
    this.idPenjual,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.namaPembeli,
    this.namaPenjual,
    this.items,
  });

  factory TransaksiMarketplaceModel.fromJson(Map<String, dynamic> json) {
    return TransaksiMarketplaceModel(
      id: json['id'] as int,
      idPembeli: json['id_pembeli'] as int,
      idPenjual: json['id_penjual'] as int?,
      total: (json['total'] as num).toDouble(),
      status: json['status'] != null
          ? StatusTransaksi.fromString(json['status'] as String)
          : StatusTransaksi.pending,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      namaPembeli: json['nama_pembeli'] as String?,
      namaPenjual: json['nama_penjual'] as String?,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => DetailTransaksiModel.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pembeli': idPembeli,
      if (idPenjual != null) 'id_penjual': idPenjual,
      'total': total,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (namaPembeli != null) 'nama_pembeli': namaPembeli,
      if (namaPenjual != null) 'nama_penjual': namaPenjual,
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id_pembeli': idPembeli,
      if (idPenjual != null) 'id_penjual': idPenjual,
      'total': total,
      'status': status.value,
    };
  }

  int get jumlahItem => items?.length ?? 0;

  bool get isPending => status == StatusTransaksi.pending;
  bool get isDikonfirmasi => status == StatusTransaksi.dikonfirmasi;
  bool get isSelesai => status == StatusTransaksi.selesai;
  bool get isDibatalkan => status == StatusTransaksi.dibatalkan;
  bool get canBeRated => status == StatusTransaksi.selesai;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransaksiMarketplaceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model untuk detail item transaksi
class DetailTransaksiModel {
  final int id;
  final int idTransaksi;
  final int idProduk;
  final int qty;
  final double harga;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final String? namaProduk;
  final String? fotoProduk;

  const DetailTransaksiModel({
    required this.id,
    required this.idTransaksi,
    required this.idProduk,
    required this.qty,
    required this.harga,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
    this.namaProduk,
    this.fotoProduk,
  });

  factory DetailTransaksiModel.fromJson(Map<String, dynamic> json) {
    return DetailTransaksiModel(
      id: json['id'] as int,
      idTransaksi: json['id_transaksi'] as int,
      idProduk: json['id_produk'] as int,
      qty: json['qty'] as int,
      harga: (json['harga'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      namaProduk: json['nama_produk'] as String?,
      fotoProduk: json['foto_produk'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_transaksi': idTransaksi,
      'id_produk': idProduk,
      'qty': qty,
      'harga': harga,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (namaProduk != null) 'nama_produk': namaProduk,
      if (fotoProduk != null) 'foto_produk': fotoProduk,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id_transaksi': idTransaksi,
      'id_produk': idProduk,
      'qty': qty,
      'harga': harga,
      'subtotal': subtotal,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetailTransaksiModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model untuk produk di marketplace
class ProdukMarketplaceModel {
  final int id;
  final int idToko;
  final String nama;
  final String? kategori;
  final String? deskripsi;
  final double harga;
  final String? fotoProduk;
  final int stok;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations (optional)
  final String? namaToko;
  final double? rating;
  final int? jumlahReview;

  const ProdukMarketplaceModel({
    required this.id,
    required this.idToko,
    required this.nama,
    this.kategori,
    this.deskripsi,
    required this.harga,
    this.fotoProduk,
    this.stok = 0,
    required this.createdAt,
    required this.updatedAt,
    this.namaToko,
    this.rating,
    this.jumlahReview,
  });

  factory ProdukMarketplaceModel.fromJson(Map<String, dynamic> json) {
    return ProdukMarketplaceModel(
      id: json['id'] as int,
      idToko: json['id_toko'] as int,
      nama: json['nama'] as String,
      kategori: json['kategori'] as String?,
      deskripsi: json['deskripsi'] as String?,
      harga: (json['harga'] as num).toDouble(),
      fotoProduk: json['foto_produk'] as String?,
      stok: json['stok'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      namaToko: json['nama_toko'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      jumlahReview: json['jumlah_review'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_toko': idToko,
      'nama': nama,
      if (kategori != null) 'kategori': kategori,
      'deskripsi': deskripsi,
      'harga': harga,
      'foto_produk': fotoProduk,
      'stok': stok,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (namaToko != null) 'nama_toko': namaToko,
      if (rating != null) 'rating': rating,
      if (jumlahReview != null) 'jumlah_review': jumlahReview,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id_toko': idToko,
      'nama': nama,
      if (kategori != null) 'kategori': kategori,
      if (deskripsi != null) 'deskripsi': deskripsi,
      'harga': harga,
      if (fotoProduk != null) 'foto_produk': fotoProduk,
      'stok': stok,
    };
  }

  bool get tersedia => stok > 0;

  ProdukMarketplaceModel copyWith({
    int? id,
    int? idToko,
    String? nama,
    String? kategori,
    String? deskripsi,
    double? harga,
    String? fotoProduk,
    int? stok,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? namaToko,
    double? rating,
    int? jumlahReview,
  }) {
    return ProdukMarketplaceModel(
      id: id ?? this.id,
      idToko: idToko ?? this.idToko,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      deskripsi: deskripsi ?? this.deskripsi,
      harga: harga ?? this.harga,
      fotoProduk: fotoProduk ?? this.fotoProduk,
      stok: stok ?? this.stok,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      namaToko: namaToko ?? this.namaToko,
      rating: rating ?? this.rating,
      jumlahReview: jumlahReview ?? this.jumlahReview,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProdukMarketplaceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

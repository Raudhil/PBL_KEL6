/// Model untuk review produk
class ReviewProdukModel {
  final int id;
  final int idProduk;
  final int idTransaksi;
  final int rating;
  final String? komentar;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final String? namaPembeli;
  final String? namaProduk;

  const ReviewProdukModel({
    required this.id,
    required this.idProduk,
    required this.idTransaksi,
    required this.rating,
    this.komentar,
    required this.createdAt,
    required this.updatedAt,
    this.namaPembeli,
    this.namaProduk,
  });

  factory ReviewProdukModel.fromJson(Map<String, dynamic> json) {
    // Parse rating - bisa berupa String atau int dari database
    int ratingValue;
    if (json['rating'] is String) {
      ratingValue = int.parse(json['rating'] as String);
    } else if (json['rating'] is int) {
      ratingValue = json['rating'] as int;
    } else {
      ratingValue = 0; // default
    }

    return ReviewProdukModel(
      id: json['id'] as int,
      idProduk: json['id_produk'] as int,
      idTransaksi: json['id_transaksi'] as int,
      rating: ratingValue,
      komentar: json['komentar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      namaPembeli: json['nama_pembeli'] as String?,
      namaProduk: json['nama_produk'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_produk': idProduk,
      'id_transaksi': idTransaksi,
      'rating': rating,
      'komentar': komentar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (namaPembeli != null) 'nama_pembeli': namaPembeli,
      if (namaProduk != null) 'nama_produk': namaProduk,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id_produk': idProduk,
      'id_transaksi': idTransaksi,
      'rating': rating,
      if (komentar != null) 'komentar': komentar,
    };
  }

  ReviewProdukModel copyWith({
    int? id,
    int? idProduk,
    int? idTransaksi,
    int? rating,
    String? komentar,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? namaPembeli,
    String? namaProduk,
  }) {
    return ReviewProdukModel(
      id: id ?? this.id,
      idProduk: idProduk ?? this.idProduk,
      idTransaksi: idTransaksi ?? this.idTransaksi,
      rating: rating ?? this.rating,
      komentar: komentar ?? this.komentar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      namaPembeli: namaPembeli ?? this.namaPembeli,
      namaProduk: namaProduk ?? this.namaProduk,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewProdukModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

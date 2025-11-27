/// Model untuk toko marketplace
class TokoModel {
  final int id;
  final String nama;
  final int idPemilik;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations (optional, di-load terpisah)
  final String? namaPemilik;
  final int? jumlahProduk;
  final double? rating;

  const TokoModel({
    required this.id,
    required this.nama,
    required this.idPemilik,
    required this.createdAt,
    required this.updatedAt,
    this.namaPemilik,
    this.jumlahProduk,
    this.rating,
  });

  factory TokoModel.fromJson(Map<String, dynamic> json) {
    return TokoModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      idPemilik: json['id_pemilik'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      namaPemilik: json['nama_pemilik'] as String?,
      jumlahProduk: json['jumlah_produk'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'id_pemilik': idPemilik,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (namaPemilik != null) 'nama_pemilik': namaPemilik,
      if (jumlahProduk != null) 'jumlah_produk': jumlahProduk,
      if (rating != null) 'rating': rating,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {'nama': nama, 'id_pemilik': idPemilik};
  }

  TokoModel copyWith({
    int? id,
    String? nama,
    int? idPemilik,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? namaPemilik,
    int? jumlahProduk,
    double? rating,
  }) {
    return TokoModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      idPemilik: idPemilik ?? this.idPemilik,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      namaPemilik: namaPemilik ?? this.namaPemilik,
      jumlahProduk: jumlahProduk ?? this.jumlahProduk,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class KKModel {
  final int id;
  final String nomor;
  final int idAlamat;
  final String? alamat;

  KKModel({
    required this.id,
    required this.nomor,
    required this.idAlamat,
    this.alamat,
  });

  factory KKModel.fromJson(Map<String, dynamic> json) {
    return KKModel(
      id: json['id'],
      nomor: json['nomor'],
      idAlamat: json['id_alamat'],
      alamat: json['alamat'] is Map
          ? json['alamat']['alamat']
          : json['alamat'] as String?,
    );
  }
}

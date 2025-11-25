class AlamatModel {
  final int id;
  final int idRt;
  final String? alamat;

  AlamatModel({
    required this.id,
    required this.idRt,
    this.alamat,
  });

  factory AlamatModel.fromJson(Map<String, dynamic> json) {
    return AlamatModel(
      id: json['id'],
      idRt: json['id_rt'],
      alamat: json['alamat'],
    );
  }
}

class KKModel {
  final int id;
  final int nomor;
  final int idAlamat;

  KKModel({
    required this.id,
    required this.nomor,
    required this.idAlamat,
  });

  factory KKModel.fromJson(Map<String, dynamic> json) {
    return KKModel(
      id: json['id'],
      nomor: json['nomor'],
      idAlamat: json['id_alamat'],
    );
  }
}

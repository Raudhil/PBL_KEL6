class RTModel {
  final int id;
  final int nomor;
  final int idRw;

  RTModel({
    required this.id,
    required this.nomor,
    required this.idRw,
  });

  factory RTModel.fromJson(Map<String, dynamic> json) {
    return RTModel(
      id: json['id'],
      nomor: json['nomor'],
      idRw: json['id_rw'],
    );
  }
}

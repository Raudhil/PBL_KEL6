class RWModel {
  final int id;
  final int nomor;

  RWModel({
    required this.id,
    required this.nomor,
  });

  factory RWModel.fromJson(Map<String, dynamic> json) {
    return RWModel(
      id: json['id'],
      nomor: json['nomor'],
    );
  }
}

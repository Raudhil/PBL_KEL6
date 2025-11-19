class IuranModel {
  final int? id;
  final String jenis;
  final double nominal;
  final DateTime jatuhTempo;
  final DateTime? createdAt;

  IuranModel({
    this.id,
    required this.jenis,
    required this.nominal,
    required this.jatuhTempo,
    this.createdAt,
  });

  factory IuranModel.fromJson(Map<String, dynamic> json) {
    return IuranModel(
      id: json['id'],
      jenis: json['jenis'] ?? '',
      nominal: (json['nominal'] as num).toDouble(),
      jatuhTempo: DateTime.parse(json['jatuh_tempo']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jenis': jenis,
      'nominal': nominal,
      'jatuh_tempo': jatuhTempo.toIso8601String(),
    };
  }
}

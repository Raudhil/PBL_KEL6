import '../../../data/models/iuran_model.dart';

class IuranWargaModel {
  final IuranModel iuran;
  final String status;
  final DateTime? tanggalBayar;

  IuranWargaModel({
    required this.iuran,
    this.status = 'Belum Lunas',
    this.tanggalBayar,
  });

  // Helper untuk cek apakah sudah lunas
  bool get isPaid => status == 'Lunas';
  bool get isPending => status == 'Belum Lunas';
}

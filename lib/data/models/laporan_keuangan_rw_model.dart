class LaporanKeuanganRTModel {
  final String rt;
  final String ketuaRT;
  final int jumlahKK;
  final int jumlahWarga;
  final List<TransaksiBulananModel> transaksiPerBulan;

  LaporanKeuanganRTModel({
    required this.rt,
    required this.ketuaRT,
    required this.jumlahKK,
    required this.jumlahWarga,
    required this.transaksiPerBulan,
  });

  double get totalPemasukan =>
      transaksiPerBulan.fold(0, (sum, t) => sum + t.totalPemasukan);
  double get totalPengeluaran =>
      transaksiPerBulan.fold(0, (sum, t) => sum + t.totalPengeluaran);
  double get saldo => totalPemasukan - totalPengeluaran;
  double get totalIuranTerkumpul =>
      transaksiPerBulan.fold(0, (sum, t) => sum + t.iuranTerkumpul);
  double get totalTunggakan =>
      transaksiPerBulan.fold(0, (sum, t) => sum + t.tunggakan);
  int get wargaBayar =>
      transaksiPerBulan.isNotEmpty ? transaksiPerBulan.last.wargaBayar : 0;
  double get persentaseBayar =>
      jumlahWarga > 0 ? (wargaBayar / jumlahWarga) * 100 : 0;
}

class TransaksiBulananModel {
  final String bulan;
  final int tahun;
  final double totalPemasukan;
  final double totalPengeluaran;
  final double saldo;
  final double iuranTerkumpul;
  final double tunggakan;
  final int wargaBayar;
  final List<DetailTransaksiModel> detailPemasukan;
  final List<DetailTransaksiModel> detailPengeluaran;

  TransaksiBulananModel({
    required this.bulan,
    required this.tahun,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.saldo,
    required this.iuranTerkumpul,
    required this.tunggakan,
    required this.wargaBayar,
    required this.detailPemasukan,
    required this.detailPengeluaran,
  });
}

class DetailTransaksiModel {
  final String keterangan;
  final double jumlah;
  final DateTime tanggal;

  DetailTransaksiModel({
    required this.keterangan,
    required this.jumlah,
    required this.tanggal,
  });
}

// Dummy Data Generator
class DummyLaporanKeuanganRW {
  static List<LaporanKeuanganRTModel> generateData() {
    return [
      LaporanKeuanganRTModel(
        rt: 'RT 001',
        ketuaRT: 'Budi Santoso',
        jumlahKK: 42,
        jumlahWarga: 125,
        transaksiPerBulan: [
          TransaksiBulananModel(
            bulan: 'November',
            tahun: 2024,
            totalPemasukan: 5250000,
            totalPengeluaran: 2800000,
            saldo: 2450000,
            iuranTerkumpul: 4200000,
            tunggakan: 800000,
            wargaBayar: 95,
            detailPemasukan: [
              DetailTransaksiModel(
                keterangan: 'Iuran Kebersihan',
                jumlah: 2100000,
                tanggal: DateTime(2024, 11, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Iuran Keamanan',
                jumlah: 2100000,
                tanggal: DateTime(2024, 11, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Sumbangan Warga',
                jumlah: 1050000,
                tanggal: DateTime(2024, 11, 15),
              ),
            ],
            detailPengeluaran: [
              DetailTransaksiModel(
                keterangan: 'Gaji Satpam',
                jumlah: 1500000,
                tanggal: DateTime(2024, 11, 1),
              ),
              DetailTransaksiModel(
                keterangan: 'Pembelian Perlengkapan',
                jumlah: 800000,
                tanggal: DateTime(2024, 11, 10),
              ),
              DetailTransaksiModel(
                keterangan: 'Listrik & Air',
                jumlah: 500000,
                tanggal: DateTime(2024, 11, 20),
              ),
            ],
          ),
          TransaksiBulananModel(
            bulan: 'Desember',
            tahun: 2024,
            totalPemasukan: 5500000,
            totalPengeluaran: 2900000,
            saldo: 2600000,
            iuranTerkumpul: 4300000,
            tunggakan: 700000,
            wargaBayar: 100,
            detailPemasukan: [
              DetailTransaksiModel(
                keterangan: 'Iuran Kebersihan',
                jumlah: 2150000,
                tanggal: DateTime(2024, 12, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Iuran Keamanan',
                jumlah: 2150000,
                tanggal: DateTime(2024, 12, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Sumbangan Warga',
                jumlah: 1200000,
                tanggal: DateTime(2024, 12, 10),
              ),
            ],
            detailPengeluaran: [
              DetailTransaksiModel(
                keterangan: 'Gaji Satpam',
                jumlah: 1500000,
                tanggal: DateTime(2024, 12, 1),
              ),
              DetailTransaksiModel(
                keterangan: 'Perawatan Jalan',
                jumlah: 900000,
                tanggal: DateTime(2024, 12, 12),
              ),
              DetailTransaksiModel(
                keterangan: 'Listrik & Air',
                jumlah: 500000,
                tanggal: DateTime(2024, 12, 20),
              ),
            ],
          ),
        ],
      ),
      LaporanKeuanganRTModel(
        rt: 'RT 002',
        ketuaRT: 'Ahmad Fauzi',
        jumlahKK: 50,
        jumlahWarga: 150,
        transaksiPerBulan: [
          TransaksiBulananModel(
            bulan: 'November',
            tahun: 2024,
            totalPemasukan: 6150000,
            totalPengeluaran: 3050000,
            saldo: 3100000,
            iuranTerkumpul: 5000000,
            tunggakan: 600000,
            wargaBayar: 128,
            detailPemasukan: [
              DetailTransaksiModel(
                keterangan: 'Iuran Kebersihan',
                jumlah: 2500000,
                tanggal: DateTime(2024, 11, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Iuran Keamanan',
                jumlah: 2500000,
                tanggal: DateTime(2024, 11, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Sumbangan Warga',
                jumlah: 1150000,
                tanggal: DateTime(2024, 11, 15),
              ),
            ],
            detailPengeluaran: [
              DetailTransaksiModel(
                keterangan: 'Gaji Satpam',
                jumlah: 1600000,
                tanggal: DateTime(2024, 11, 1),
              ),
              DetailTransaksiModel(
                keterangan: 'Pembelian Perlengkapan',
                jumlah: 850000,
                tanggal: DateTime(2024, 11, 10),
              ),
              DetailTransaksiModel(
                keterangan: 'Listrik & Air',
                jumlah: 600000,
                tanggal: DateTime(2024, 11, 20),
              ),
            ],
          ),
          TransaksiBulananModel(
            bulan: 'Desember',
            tahun: 2024,
            totalPemasukan: 6350000,
            totalPengeluaran: 3150000,
            saldo: 3200000,
            iuranTerkumpul: 5000000,
            tunggakan: 600000,
            wargaBayar: 135,
            detailPemasukan: [
              DetailTransaksiModel(
                keterangan: 'Iuran Kebersihan',
                jumlah: 2550000,
                tanggal: DateTime(2024, 12, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Iuran Keamanan',
                jumlah: 2550000,
                tanggal: DateTime(2024, 12, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Sumbangan Warga',
                jumlah: 1250000,
                tanggal: DateTime(2024, 12, 10),
              ),
            ],
            detailPengeluaran: [
              DetailTransaksiModel(
                keterangan: 'Gaji Satpam',
                jumlah: 1600000,
                tanggal: DateTime(2024, 12, 1),
              ),
              DetailTransaksiModel(
                keterangan: 'Perawatan Taman',
                jumlah: 950000,
                tanggal: DateTime(2024, 12, 12),
              ),
              DetailTransaksiModel(
                keterangan: 'Listrik & Air',
                jumlah: 600000,
                tanggal: DateTime(2024, 12, 20),
              ),
            ],
          ),
        ],
      ),
      LaporanKeuanganRTModel(
        rt: 'RT 003',
        ketuaRT: 'Siti Aminah',
        jumlahKK: 35,
        jumlahWarga: 105,
        transaksiPerBulan: [
          TransaksiBulananModel(
            bulan: 'November',
            tahun: 2024,
            totalPemasukan: 4400000,
            totalPengeluaran: 2600000,
            saldo: 1800000,
            iuranTerkumpul: 3500000,
            tunggakan: 1100000,
            wargaBayar: 80,
            detailPemasukan: [
              DetailTransaksiModel(
                keterangan: 'Iuran Kebersihan',
                jumlah: 1750000,
                tanggal: DateTime(2024, 11, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Iuran Keamanan',
                jumlah: 1750000,
                tanggal: DateTime(2024, 11, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Sumbangan Warga',
                jumlah: 900000,
                tanggal: DateTime(2024, 11, 15),
              ),
            ],
            detailPengeluaran: [
              DetailTransaksiModel(
                keterangan: 'Gaji Satpam',
                jumlah: 1400000,
                tanggal: DateTime(2024, 11, 1),
              ),
              DetailTransaksiModel(
                keterangan: 'Pembelian Perlengkapan',
                jumlah: 700000,
                tanggal: DateTime(2024, 11, 10),
              ),
              DetailTransaksiModel(
                keterangan: 'Listrik & Air',
                jumlah: 500000,
                tanggal: DateTime(2024, 11, 20),
              ),
            ],
          ),
          TransaksiBulananModel(
            bulan: 'Desember',
            tahun: 2024,
            totalPemasukan: 4400000,
            totalPengeluaran: 2600000,
            saldo: 1800000,
            iuranTerkumpul: 3500000,
            tunggakan: 1100000,
            wargaBayar: 87,
            detailPemasukan: [
              DetailTransaksiModel(
                keterangan: 'Iuran Kebersihan',
                jumlah: 1750000,
                tanggal: DateTime(2024, 12, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Iuran Keamanan',
                jumlah: 1750000,
                tanggal: DateTime(2024, 12, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Sumbangan Warga',
                jumlah: 900000,
                tanggal: DateTime(2024, 12, 10),
              ),
            ],
            detailPengeluaran: [
              DetailTransaksiModel(
                keterangan: 'Gaji Satpam',
                jumlah: 1400000,
                tanggal: DateTime(2024, 12, 1),
              ),
              DetailTransaksiModel(
                keterangan: 'Pengecatan Pos',
                jumlah: 700000,
                tanggal: DateTime(2024, 12, 12),
              ),
              DetailTransaksiModel(
                keterangan: 'Listrik & Air',
                jumlah: 500000,
                tanggal: DateTime(2024, 12, 20),
              ),
            ],
          ),
        ],
      ),
      LaporanKeuanganRTModel(
        rt: 'RT 004',
        ketuaRT: 'Joko Widodo',
        jumlahKK: 45,
        jumlahWarga: 135,
        transaksiPerBulan: [
          TransaksiBulananModel(
            bulan: 'November',
            tahun: 2024,
            totalPemasukan: 5600000,
            totalPengeluaran: 2950000,
            saldo: 2650000,
            iuranTerkumpul: 4500000,
            tunggakan: 700000,
            wargaBayar: 110,
            detailPemasukan: [
              DetailTransaksiModel(
                keterangan: 'Iuran Kebersihan',
                jumlah: 2250000,
                tanggal: DateTime(2024, 11, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Iuran Keamanan',
                jumlah: 2250000,
                tanggal: DateTime(2024, 11, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Sumbangan Warga',
                jumlah: 1100000,
                tanggal: DateTime(2024, 11, 15),
              ),
            ],
            detailPengeluaran: [
              DetailTransaksiModel(
                keterangan: 'Gaji Satpam',
                jumlah: 1550000,
                tanggal: DateTime(2024, 11, 1),
              ),
              DetailTransaksiModel(
                keterangan: 'Pembelian Perlengkapan',
                jumlah: 800000,
                tanggal: DateTime(2024, 11, 10),
              ),
              DetailTransaksiModel(
                keterangan: 'Listrik & Air',
                jumlah: 600000,
                tanggal: DateTime(2024, 11, 20),
              ),
            ],
          ),
          TransaksiBulananModel(
            bulan: 'Desember',
            tahun: 2024,
            totalPemasukan: 5600000,
            totalPengeluaran: 2950000,
            saldo: 2650000,
            iuranTerkumpul: 4500000,
            tunggakan: 700000,
            wargaBayar: 118,
            detailPemasukan: [
              DetailTransaksiModel(
                keterangan: 'Iuran Kebersihan',
                jumlah: 2250000,
                tanggal: DateTime(2024, 12, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Iuran Keamanan',
                jumlah: 2250000,
                tanggal: DateTime(2024, 12, 5),
              ),
              DetailTransaksiModel(
                keterangan: 'Sumbangan Warga',
                jumlah: 1100000,
                tanggal: DateTime(2024, 12, 10),
              ),
            ],
            detailPengeluaran: [
              DetailTransaksiModel(
                keterangan: 'Gaji Satpam',
                jumlah: 1550000,
                tanggal: DateTime(2024, 12, 1),
              ),
              DetailTransaksiModel(
                keterangan: 'Perbaikan Drainase',
                jumlah: 800000,
                tanggal: DateTime(2024, 12, 12),
              ),
              DetailTransaksiModel(
                keterangan: 'Listrik & Air',
                jumlah: 600000,
                tanggal: DateTime(2024, 12, 20),
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

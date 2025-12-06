import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/quick_access_widget.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/pengumuman_widget.dart';
import '../../../../core/providers/kegiatan_provider.dart';
import '../../../../data/models/kegiatan_model.dart';

class WargaDashboardPage extends ConsumerStatefulWidget {
  const WargaDashboardPage({super.key});

  @override
  ConsumerState<WargaDashboardPage> createState() => _WargaDashboardPageState();
}

class _WargaDashboardPageState extends ConsumerState<WargaDashboardPage> {
  @override
  Widget build(BuildContext context) {
    // Fetch kegiatan dari Supabase dengan realtime updates
    final kegiatanAsync = ref.watch(kegiatanStreamProvider);

    return kegiatanAsync.when(
      data: (kegiatanList) {
        // Filter hanya kegiatan upcoming (akan datang dan sedang berlangsung)
        final upcomingKegiatan = kegiatanList
            .where(
              (k) =>
                  k.status == StatusKegiatan.akanDatang ||
                  k.status == StatusKegiatan.sedangBerlangsung,
            )
            .toList();

        // Convert ke AgendaItem
        final agendaItems = upcomingKegiatan
            .map(
              (kegiatan) => AgendaItem(
                kegiatanId: kegiatan.id,
                title: kegiatan.judul,
                category: _getKategoriLabel(kegiatan.kategori),
                pic: kegiatan.penyelenggara,
                description: kegiatan.deskripsi ?? 'Tidak ada deskripsi',
                date: kegiatan.tanggalMulai,
                location: kegiatan.lokasi ?? 'Lokasi akan ditentukan',
              ),
            )
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Access - Modular widget
              const QuickAccessWidget(),
              const SizedBox(height: 30),

              // Kalender Kegiatan - From Supabase
              CalendarWidget(agendaItems: agendaItems),
              const SizedBox(height: 30),

              // Pengumuman Terbaru - From Supabase
              const PengumumanWidget(),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        // Tampilkan error dan fallback ke data kosong
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const QuickAccessWidget(),
              const SizedBox(height: 30),

              // Error message untuk kegiatan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gagal memuat kegiatan. Silakan refresh halaman.',
                        style: TextStyle(color: Colors.red[900], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Pengumuman Terbaru - Tetap tampil meski kegiatan error
              const PengumumanWidget(),
            ],
          ),
        );
      },
    );
  }

  // Helper method untuk convert kategori ke label
  String _getKategoriLabel(KategoriKegiatan kategori) {
    switch (kategori) {
      case KategoriKegiatan.sosial:
        return 'Sosial';
      case KategoriKegiatan.kebersihan:
        return 'Kebersihan';
      case KategoriKegiatan.kesehatan:
        return 'Kesehatan';
      case KategoriKegiatan.pendidikan:
        return 'Pendidikan';
      case KategoriKegiatan.keagamaan:
        return 'Keagamaan';
      case KategoriKegiatan.olahraga:
        return 'Olahraga';
      case KategoriKegiatan.budaya:
        return 'Budaya';
      case KategoriKegiatan.lainnya:
        return 'Lainnya';
    }
  }
}

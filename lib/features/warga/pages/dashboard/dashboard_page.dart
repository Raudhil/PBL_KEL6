import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/quick_access_widget.dart';
import 'widgets/announcement_list_widget.dart';
import 'widgets/calendar_widget.dart';

class WargaDashboardPage extends ConsumerStatefulWidget {
  const WargaDashboardPage({super.key});

  @override
  ConsumerState<WargaDashboardPage> createState() => _WargaDashboardPageState();
}

class _WargaDashboardPageState extends ConsumerState<WargaDashboardPage> {
  final List<_AgendaItem> _agendaItems = [
    _AgendaItem(
      title: 'Kerja Bakti Lingkungan RW 05',
      category: 'Lingkungan',
      pic: 'Pak Budi · Ketua RT 05',
      description:
          'Membersihkan saluran air, memotong rumput liar, dan pengecatan portal kampung.',
      date: DateTime(2025, 11, 12, 07, 30),
      location: 'Jl. Mawar 3 Blok B',
    ),
    _AgendaItem(
      title: 'Rapat Koordinasi RT/RW',
      category: 'Rapat',
      pic: 'Bu Siti · Ketua RW',
      description:
          'Membahas jadwal ronda malam, keamanan lingkungan, dan evaluasi pembayaran iuran.',
      date: DateTime(2025, 11, 18, 19, 00),
      location: 'Balai Pertemuan Warga',
    ),
    _AgendaItem(
      title: 'Pembagian Bantuan Sembako',
      category: 'Sosial',
      pic: 'Pak Anton · Bendahara RW',
      description:
          'Distribusi paket sembako bagi warga lansia dan keluarga rentan. Harap membawa Kartu Keluarga.',
      date: DateTime(2025, 11, 24, 09, 00),
      location: 'Posko RW 05',
    ),
    _AgendaItem(
      title: 'Posyandu Balita & Lansia',
      category: 'Kesehatan',
      pic: 'Bu Rani · Sekretaris Posyandu',
      description:
          'Pemeriksaan kesehatan rutin, imunisasi balita, serta konsultasi gizi keluarga.',
      date: DateTime(2025, 12, 5, 08, 30),
      location: 'Rumah Ketua RT 03',
    ),
  ];

  final List<_AnnouncementItem> _announcements = [
    _AnnouncementItem(
      title: 'Perbaikan Saluran Air Utama',
      description:
          'Pengerjaan akan dilakukan pada 15–17 Nov. Mohon warga memindahkan kendaraan dari depan rumah untuk memudahkan alat berat.',
      date: DateTime(2025, 11, 9, 10, 00),
      imageUrl: 'https://picsum.photos/seed/saluran/640/360',
      documentName: 'Surat_Edaran_Saluran_Air.pdf',
    ),
    _AnnouncementItem(
      title: 'Distribusi Air Bersih dari PDAM',
      description:
          'Armada tangki PDAM hadir 11 Nov pukul 13.00 di lapangan RW 05. Setiap KK dimohon membawa maksimal 3 galon kosong.',
      date: DateTime(2025, 11, 10, 13, 00),
      imageUrl: 'https://picsum.photos/seed/airbersih/640/360',
    ),
    _AnnouncementItem(
      title: 'Lomba Kreasi Pangan Sehat PKK',
      description:
          'Dalam rangka HUT ke-50, PKK mengadakan lomba kreasi pangan lokal. Pendaftaran dibuka hingga 25 Nov.',
      date: DateTime(2025, 11, 8, 16, 00),
      imageUrl: 'https://picsum.photos/seed/lomba/640/360',
      documentName: 'Formulir_Lomba_Pangan.docx',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Access - Modular widget
          const QuickAccessWidget(),
          const SizedBox(height: 30),

          // Kalender Kegiatan - Modular widget
          CalendarWidget(
            agendaItems: _agendaItems
                .map(
                  (e) => AgendaItem(
                    title: e.title,
                    category: e.category,
                    pic: e.pic,
                    description: e.description,
                    date: e.date,
                    location: e.location,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 30),

          // Pengumuman Terbaru - Modular widget
          AnnouncementListWidget(
            announcements: _announcements
                .map(
                  (e) => AnnouncementItem(
                    title: e.title,
                    description: e.description,
                    date: e.date,
                    imageUrl: e.imageUrl,
                    documentName: e.documentName,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AgendaItem {
  final String title;
  final String category;
  final String pic;
  final String description;
  final DateTime date;
  final String location;

  const _AgendaItem({
    required this.title,
    required this.category,
    required this.pic,
    required this.description,
    required this.date,
    required this.location,
  });
}

class _AnnouncementItem {
  final String title;
  final String description;
  final DateTime date;
  final String imageUrl;
  final String? documentName;

  const _AnnouncementItem({
    required this.title,
    required this.description,
    required this.date,
    required this.imageUrl,
    this.documentName,
  });
}

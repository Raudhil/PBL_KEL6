import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/role_provider.dart';
import '../../../../theme/app_colors.dart';
import 'pengumuman_detail_page.dart';
import 'kegiatan_detail_page.dart';
import '../perangkat/perangkat_page.dart';

String _formatDateTime(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final day = date.day;
  final month = months[date.month - 1];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day $month ${date.year}, $hour:$minute';
}

class WargaDashboardPage extends ConsumerStatefulWidget {
  const WargaDashboardPage({super.key});

  @override
  ConsumerState<WargaDashboardPage> createState() => _WargaDashboardPageState();
}

class _WargaDashboardPageState extends ConsumerState<WargaDashboardPage> {
  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _weekDays = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

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

  final DateTime _today = DateTime.now();
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_today.year, _today.month);
    _selectedDate = DateTime(_today.year, _today.month, _today.day);
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(roleProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Access - DEMO: Sementara tampil untuk semua warga
          // TODO: Nanti aktifkan role checking setelah backend ready
          // roleAsync.maybeWhen(
          //   data: (role) => _buildPerangkatQuickAccess(context, role),
          //   orElse: () => const SizedBox.shrink(),
          // ),
          _buildPerangkatQuickAccess(context, 'demo'),

          // Kalender & Kegiatan
          const Text(
            'Kalender Kegiatan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildCalendarCard(context),
          const SizedBox(height: 24),

          // Pengumuman Terbaru
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengumuman Terbaru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnnouncementsList(context),
        ],
      ),
    );
  }

  Widget _buildPerangkatQuickAccess(BuildContext context, String role) {
    // DEMO MODE: Sementara tampilkan untuk semua user
    // TODO: Aktifkan role checking ini setelah backend ready
    // print('🔍 Dashboard - Checking role: "$role"');
    // final normalizedRole = role.toLowerCase().trim();
    // print('🔍 Dashboard - Normalized role: "$normalizedRole"');
    // const roleLabels = {
    //   'rt': 'RT',
    //   'rw': 'RW',
    //   'bendahara': 'Bendahara',
    //   'sekretaris': 'Sekretaris',
    // };
    // String? matchedKey;
    // String? displayRole;
    // for (final entry in roleLabels.entries) {
    //   if (normalizedRole == entry.key || normalizedRole.contains(entry.key)) {
    //     matchedKey = entry.key;
    //     displayRole = entry.value;
    //     break;
    //   }
    // }
    // if (matchedKey == null) {
    //   return const SizedBox.shrink();
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            // Navigate ke halaman perangkat (keluar dari WargaMainPage)
            Navigator.of(
              context,
              rootNavigator: true,
            ).push(MaterialPageRoute(builder: (_) => const PerangkatPage()));
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary600, AppColors.primary400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Akses Fitur Perangkat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Kelola fitur khusus perangkat',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAnnouncementsList(BuildContext context) {
    return Column(
      children: _announcements.map((announcement) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AnnouncementCard(
            announcement: announcement,
            onTap: () => _openAnnouncementDetail(
              context,
              judul: announcement.title,
              deskripsi: announcement.description,
              foto: announcement.imageUrl,
              dokumen: announcement.documentName,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    final calendarDays = _generateCalendarDays();
    final monthLabel =
        '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}';
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.white, AppColors.creamWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary600, AppColors.primary400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              const Expanded(
                child: Text(
                  'Kalender Kegiatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _CalendarButton(
                icon: Icons.chevron_left,
                onPressed: () => _onMonthChanged(-1),
              ),
              SizedBox(width: screenWidth * 0.02),
              _CalendarButton(
                icon: Icons.chevron_right,
                onPressed: () => _onMonthChanged(1),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          Text(
            'Tap tanggal untuk melihat detail kegiatan',
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.025,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary600.withOpacity(0.1),
                  AppColors.primary400.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary200, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event,
                  color: AppColors.primary700,
                  size: screenWidth * 0.045,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  monthLabel,
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          Row(
            children: _weekDays
                .map(
                  (weekday) => Expanded(
                    child: Text(
                      weekday,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: screenWidth * 0.025),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: calendarDays.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: screenWidth * 0.02,
              crossAxisSpacing: screenWidth * 0.02,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final date = calendarDays[index];

              if (date == null) {
                return const SizedBox.shrink();
              }

              final bool isSelected = _isSameDay(date, _selectedDate);
              final bool isToday = _isSameDay(date, _today);
              final bool hasEvent = _agendaItems.any(
                (item) => _isSameDay(item.date, date),
              );

              return GestureDetector(
                onTap: () => _onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              AppColors.primary600,
                              AppColors.primary400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : isToday
                        ? LinearGradient(
                            colors: [AppColors.primary100, AppColors.primary50],
                          )
                        : null,
                    color: !isSelected && !isToday ? AppColors.white : null,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary600
                          : hasEvent
                          ? AppColors.primary400
                          : AppColors.greyLight,
                      width: isSelected || hasEvent ? 2 : 1,
                    ),
                    boxShadow: isSelected || hasEvent
                        ? [
                            BoxShadow(
                              color:
                                  (isSelected
                                          ? AppColors.primary600
                                          : AppColors.primary400)
                                      .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.037,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : isToday
                              ? AppColors.primary700
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (hasEvent) ...[
                        SizedBox(height: screenWidth * 0.012),
                        Container(
                          width: screenWidth * 0.018,
                          height: screenWidth * 0.018,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [AppColors.white, AppColors.white],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      AppColors.warning,
                                      AppColors.yellowGold,
                                    ],
                                  ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isSelected
                                            ? AppColors.white
                                            : AppColors.warning)
                                        .withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: screenWidth * 0.04),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildSelectedEventList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedEventList(BuildContext context) {
    final events = _selectedEvents;
    final screenWidth = MediaQuery.of(context).size.width;

    if (events.isEmpty) {
      return Container(
        key: const ValueKey('empty-events'),
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.greyLight.withOpacity(0.3),
              AppColors.creamWhite,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary100, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: screenWidth * 0.12,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: screenWidth * 0.03),
            Text(
              'Tidak ada kegiatan',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: screenWidth * 0.015),
            Text(
              'Silakan pilih tanggal lain untuk melihat\npengumuman atau agenda',
              style: TextStyle(
                fontSize: screenWidth * 0.032,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      key: const ValueKey('event-list'),
      children: events
          .map(
            (event) => Padding(
              padding: EdgeInsets.only(bottom: screenWidth * 0.03),
              child: _AgendaEventCard(
                agenda: event,
                dateLabel: _formatFullDate(event.date),
                timeLabel: _formatTime(event.date),
                screenWidth: screenWidth,
                onTap: () => _openKegiatanDetail(
                  context,
                  namaKegiatan: event.title,
                  kategori: event.category,
                  penanggungJawab: 'RW 05', // TODO: Get from data
                  tanggalPelaksanaan: event.date,
                  lokasi: event.location,
                  deskripsi: event.description,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void _openAnnouncementDetail(
    BuildContext context, {
    required String judul,
    required String deskripsi,
    String? foto,
    String? dokumen,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailPage(
          judul: judul,
          deskripsi: deskripsi,
          foto: foto,
          dokumen: dokumen,
        ),
      ),
    );
  }

  void _openKegiatanDetail(
    BuildContext context, {
    required String namaKegiatan,
    required String kategori,
    required String penanggungJawab,
    required DateTime tanggalPelaksanaan,
    required String lokasi,
    required String deskripsi,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => KegiatanDetailPage(
          namaKegiatan: namaKegiatan,
          kategori: kategori,
          penanggungJawab: penanggungJawab,
          tanggalPelaksanaan: tanggalPelaksanaan,
          lokasi: lokasi,
          deskripsi: deskripsi,
        ),
      ),
    );
  }

  void _onMonthChanged(int offset) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
      _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  List<DateTime?> _generateCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final daysBefore = (firstDay.weekday + 6) % 7;
    final totalCells = daysBefore + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final itemCount = rows * 7;

    return List<DateTime?>.generate(itemCount, (index) {
      final dayNumber = index - daysBefore + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) {
        return null;
      }
      return DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
    });
  }

  List<_AgendaItem> get _selectedEvents {
    final filtered = _agendaItems
        .where((item) => _isSameDay(item.date, _selectedDate))
        .toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatFullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final monthName = _monthNames[date.month - 1];
    return '$day $monthName ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  String _formatDateTime(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = date.day;
    final month = months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month ${date.year}, $hour:$minute';
  }
}

class _AnnouncementCard extends StatelessWidget {
  final _AnnouncementItem announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyDark.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                announcement.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    announcement.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDateTime(announcement.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.9),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.primary600,
                        size: 20,
                      ),
                    ],
                  ),
                  if (announcement.documentName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.attach_file,
                            size: 16,
                            color: AppColors.primary700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            announcement.documentName!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CalendarButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary600, AppColors.primary400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary600.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: AppColors.white),
      ),
    );
  }
}

class _AgendaEventCard extends StatelessWidget {
  final _AgendaItem agenda;
  final String dateLabel;
  final String timeLabel;
  final double screenWidth;
  final VoidCallback onTap;

  const _AgendaEventCard({
    required this.agenda,
    required this.dateLabel,
    required this.timeLabel,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.white, AppColors.primary50.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenWidth * 0.015,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary600, AppColors.primary400],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary600.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    agenda.category,
                    style: TextStyle(
                      fontSize: screenWidth * 0.028,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary700,
                    size: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.035),
            Text(
              agenda.title,
              style: TextStyle(
                fontSize: screenWidth * 0.042,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            SizedBox(height: screenWidth * 0.025),
            _buildInfoRow(
              Icons.person_outline,
              'Penanggung jawab: ${agenda.pic}',
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.02),
            _buildInfoRow(Icons.event, '$dateLabel - $timeLabel', screenWidth),
            SizedBox(height: screenWidth * 0.02),
            _buildInfoRow(
              Icons.location_on_outlined,
              agenda.location,
              screenWidth,
            ),
            SizedBox(height: screenWidth * 0.03),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyLight),
              ),
              child: Text(
                agenda.description,
                style: TextStyle(
                  fontSize: screenWidth * 0.034,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, double screenWidth) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: screenWidth * 0.04,
            color: AppColors.primary700,
          ),
        ),
        SizedBox(width: screenWidth * 0.025),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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

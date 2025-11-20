import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../kegiatan_detail_page.dart';

class AgendaItem {
  final String title;
  final String category;
  final String pic;
  final String description;
  final DateTime date;
  final String location;

  AgendaItem({
    required this.title,
    required this.category,
    required this.pic,
    required this.description,
    required this.date,
    required this.location,
  });
}

class CalendarWidget extends StatefulWidget {
  final List<AgendaItem> agendaItems;

  const CalendarWidget({super.key, required this.agendaItems});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
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
    final calendarDays = _generateCalendarDays();
    final monthLabel =
        '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}';
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kalender Kegiatan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
                      'Agenda Warga',
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
                  final bool hasEvent = widget.agendaItems.any(
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
                                colors: [
                                  AppColors.primary100,
                                  AppColors.primary50,
                                ],
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
                                        colors: [
                                          AppColors.white,
                                          AppColors.white,
                                        ],
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
                child: _buildSelectedEventList(context, screenWidth),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedEventList(BuildContext context, double screenWidth) {
    final events = _selectedEvents;

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

    return Container(
      key: ValueKey('events-${_selectedDate.toString()}'),
      child: Column(
        children: events.map((agenda) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AgendaEventCard(
              agenda: agenda,
              dateLabel: _formatFullDate(agenda.date),
              timeLabel: _formatTime(agenda.date),
              screenWidth: screenWidth,
              onTap: () => _openKegiatanDetail(
                context,
                namaKegiatan: agenda.title,
                kategori: agenda.category,
                penanggungJawab: agenda.pic,
                tanggalPelaksanaan: agenda.date,
                lokasi: agenda.location,
                deskripsi: agenda.description,
              ),
            ),
          );
        }).toList(),
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

  List<AgendaItem> get _selectedEvents {
    final filtered = widget.agendaItems
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
  final AgendaItem agenda;
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'rapat':
        return AppColors.primary600;
      case 'sosial':
        return AppColors.success;
      case 'lingkungan':
        return const Color(0xFF10B981);
      case 'kesehatan':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(agenda.category);

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor, categoryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.event, color: AppColors.white, size: 28),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      agenda.category,
                      style: TextStyle(
                        fontSize: screenWidth * 0.028,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    agenda.title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.015),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: screenWidth * 0.035,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: screenWidth * 0.035,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Expanded(
                        child: Text(
                          agenda.location,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.primary600,
              size: screenWidth * 0.06,
            ),
          ],
        ),
      ),
    );
  }
}

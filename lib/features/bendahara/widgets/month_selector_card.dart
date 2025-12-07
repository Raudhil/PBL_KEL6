import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';

typedef MonthChangedCallback = void Function(DateTime newMonth);
typedef MonthPickerCallback = void Function();

class MonthSelectorCard extends ConsumerWidget {
  final DateTime selectedMonth;
  final MonthChangedCallback onPreviousMonth;
  final MonthChangedCallback onNextMonth;
  final MonthPickerCallback onTapMonth;

  const MonthSelectorCard({
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onTapMonth,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(color: AppColors.background),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Month Button
                GestureDetector(
                  onTap: () {
                    final newMonth = DateTime(
                      selectedMonth.year,
                      selectedMonth.month - 1,
                    );
                    onPreviousMonth(newMonth);
                  },
                  child: Icon(
                    Icons.chevron_left,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),

                // Current Month Display
                Expanded(
                  child: GestureDetector(
                    onTap: onTapMonth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatMonthYear(selectedMonth),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_getFirstDayOfMonth(selectedMonth)} - ${_getLastDayOfMonth(selectedMonth)}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Next Month Button
                GestureDetector(
                  onTap: () {
                    final newMonth = DateTime(
                      selectedMonth.year,
                      selectedMonth.month + 1,
                    );
                    onNextMonth(newMonth);
                  },
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatMonthShort(int month) {
    final months = [
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
    return months[month - 1];
  }

  String _getFirstDayOfMonth(DateTime date) {
    return '1 ${_formatMonthShort(date.month)} ${date.year}';
  }

  String _getLastDayOfMonth(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return '${lastDay.day} ${_formatMonthShort(date.month)} ${date.year}';
  }
}

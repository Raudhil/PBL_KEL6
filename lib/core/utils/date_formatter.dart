/// Utility class for formatting dates consistently across the app
class DateFormatter {
  // Private constructor to prevent instantiation
  DateFormatter._();

  /// Indonesian month names (short form)
  static const List<String> _monthsShort = [
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

  /// Format DateTime to "DD MMM YYYY, HH:mm"
  ///
  /// Example: "30 Nov 2025, 07:26"
  static String formatDateTime(DateTime date) {
    final day = date.day;
    final month = _monthsShort[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  /// Format DateTime to "DD MMM YYYY"
  ///
  /// Example: "30 Nov 2025"
  static String formatDate(DateTime date) {
    final day = date.day;
    final month = _monthsShort[date.month - 1];
    final year = date.year;

    return '$day $month $year';
  }

  /// Format DateTime to relative time (e.g., "5m lalu", "2h lalu", "Kemarin")
  ///
  /// Returns:
  /// - "Baru saja" if < 1 minute
  /// - "Xm lalu" if < 1 hour
  /// - "Xj lalu" if today
  /// - "Kemarin" if yesterday
  /// - "Xh lalu" if < 7 days
  /// - "DD/MM/YYYY" if >= 7 days
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes}m lalu';
      }
      return '${difference.inHours}j lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}h lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawara/theme/app_colors.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final DateTime? date;
  final double amount;
  final String? type; // 'Pemasukan' or 'Pengeluaran'
  final String? note;

  const TransactionCard({
    Key? key,
    required this.title,
    this.date,
    required this.amount,
    this.type,
    this.note,
  }) : super(key: key);

  String _formatDate(DateTime? d) => d == null ? '' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // Determine if income
    bool isIncome;
    if (type != null) {
      final t = type!.trim().toLowerCase();
      if (t == 'pemasukan') {
        isIncome = true;
      } else if (t == 'pengeluaran') {
        isIncome = false;
      } else {
        isIncome = amount >= 0;
      }
    } else {
      isIncome = amount >= 0;
    }

    final amountText = formatter.format(amount.abs()); // no +/-, just number

    final leadingColor = isIncome ? AppColors.success : AppColors.danger;
    final leadingIcon = isIncome ? Icons.trending_up : Icons.trending_down;

    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // Icon
              SizedBox(
                width: 48,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: leadingColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Icon(leadingIcon, color: leadingColor, size: 18)),
                  ),
                )
              ),
              const SizedBox(width: 12),

              // title + note + date (left)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (note != null && note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(note!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                    if (date != null) ...[
                      const SizedBox(height: 6),
                      Text(_formatDate(date), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),

              // amount aligned top-right
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amountText, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

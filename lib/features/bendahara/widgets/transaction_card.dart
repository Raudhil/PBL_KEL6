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

  String _formatDate(DateTime? d) =>
      d == null ? '' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

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

    final amountText = formatter.format(amount.abs());
    final leadingColor = isIncome ? AppColors.success : AppColors.danger;
    final leadingIcon = isIncome ? Icons.trending_up : Icons.trending_down;
    final hasNote = note != null && note!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon dengan background lebih prominent
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: leadingColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: leadingColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(leadingIcon, color: leadingColor, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Title + Note + Date (DYNAMIC HEIGHT - TIDAK FIXED)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Note (jika ada)
                  if (hasNote) ...[
                    const SizedBox(height: 6),
                    Text(
                      note!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Date
                  if (date != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Amount - LEBIH MENONJOL (TOP ALIGNED)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amountText,
                    style: TextStyle(
                      color: leadingColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: leadingColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isIncome ? 'Masuk' : 'Keluar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: leadingColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

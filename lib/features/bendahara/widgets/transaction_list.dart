import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import 'transaction_card.dart';

final _currencyFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

class TransactionListSection extends StatelessWidget {
  final List<dynamic> filteredTransactions;
  final bool isLoading;
  final String? error;

  const TransactionListSection({
    required this.filteredTransactions,
    this.isLoading = false,
    this.error,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada transaksi',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Transaksi bulan ini akan muncul di sini',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group transactions by date
    final groupedTransactions = <String, List<dynamic>>{};
    for (var tx in filteredTransactions) {
      final dateKey =
          '${tx.createdAt!.year}-${tx.createdAt!.month.toString().padLeft(2, '0')}-${tx.createdAt!.day.toString().padLeft(2, '0')}';
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final transactions = groupedTransactions[dateKey]!;
        final dateParts = dateKey.split('-');
        final date = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );

        // Calculate daily totals
        double dailyIncome = 0;
        double dailyExpense = 0;
        for (var tx in transactions) {
          final type = tx.type?.trim().toLowerCase();
          if (type == 'pemasukan') {
            dailyIncome += tx.amount;
          } else if (type == 'pengeluaran') {
            dailyExpense += tx.amount;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDateHeader(date),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (dailyIncome > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '+${_currencyFormatter.format(dailyIncome)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  if (dailyExpense > 0)
                    Text(
                      '-${_currencyFormatter.format(dailyExpense)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                ],
              ),
            ),

            // Transactions for this date
            ...transactions.map(
              (tx) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TransactionCard(
                  title: tx.title,
                  date: tx.createdAt,
                  amount: tx.amount,
                  type: tx.type,
                  note: tx.note,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
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
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

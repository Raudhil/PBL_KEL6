import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import 'expandable_transaction_card.dart';

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
      itemCount: groupedTransactions.keys.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final transactions = groupedTransactions[dateKey]!;

        // Parse date
        final parts = dateKey.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        // Format date header
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final isToday = date == today;
        final isYesterday = date == yesterday;

        String dateHeader;
        if (isToday) {
          dateHeader = 'Hari Ini';
        } else if (isYesterday) {
          dateHeader = 'Kemarin';
        } else {
          final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
          dateHeader = formatter.format(date);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 24, bottom: 12),
              child: Text(
                dateHeader,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Transactions for this date
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, txIndex) {
                final tx = transactions[txIndex];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ExpandableTransactionCard(transaction: tx),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

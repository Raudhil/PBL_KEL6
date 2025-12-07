import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../controllers/keuangan_controller.dart';
import '../../widgets/transaction_card.dart';

final _currencyFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

final _selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Helper functions for date formatting without locale issues
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

String _formatMonthName(int month) {
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
  return months[month - 1];
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

String _formatDayName(DateTime date) {
  final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  return days[date.weekday - 1];
}

String _formatFullDate(DateTime date) {
  return '${_formatDayName(date)}, ${date.day} ${_formatMonthName(date.month)}';
}

class KeuanganPage extends ConsumerWidget {
  const KeuanganPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(_selectedMonthProvider);
    final keuanganState = ref.watch(keuanganControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomTopBar(
        title: 'Laporan Keuangan',
        showBackButton: true,
        actions: [],
      ),
      body: Column(
        children: [
          // Month Selector Card
          Container(
            decoration: BoxDecoration(color: AppColors.background),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                          ref.read(_selectedMonthProvider.notifier).state =
                              newMonth;
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
                          onTap: () =>
                              _showMonthPicker(context, ref, selectedMonth),
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
                          ref.read(_selectedMonthProvider.notifier).state =
                              newMonth;
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
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(keuanganControllerProvider.notifier)
                  .fetchTransactions(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Financial Summary Card
                      _buildFinancialSummary(ref, selectedMonth, keuanganState),

                      const SizedBox(height: 24),

                      // Transactions Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Rincian Transaksi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Bulan Ini',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Transaction List
                      keuanganState.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, st) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppColors.danger,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: $e',
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        data: (allTransactions) {
                          // Filter transactions by selected month
                          final filteredTransactions =
                              allTransactions.where((tx) {
                                if (tx.createdAt == null) return false;
                                return tx.createdAt!.year ==
                                        selectedMonth.year &&
                                    tx.createdAt!.month == selectedMonth.month;
                              }).toList()..sort(
                                (a, b) => (b.createdAt ?? DateTime.now())
                                    .compareTo(a.createdAt ?? DateTime.now()),
                              );

                          if (filteredTransactions.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.3),
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
                                        color: AppColors.textSecondary
                                            .withOpacity(0.7),
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
                              final dateKey = groupedTransactions.keys
                                  .elementAt(index);
                              final transactions =
                                  groupedTransactions[dateKey]!;
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
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 8,
                                      top: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
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
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(
    WidgetRef ref,
    DateTime selectedMonth,
    AsyncValue<List<dynamic>> keuanganState,
  ) {
    return keuanganState.when(
      loading: () =>
          _SummaryCard(pemasukan: 0, pengeluaran: 0, saldo: 0, isLoading: true),
      error: (e, st) => _SummaryCard(
        pemasukan: 0,
        pengeluaran: 0,
        saldo: 0,
        isLoading: false,
      ),
      data: (allTransactions) {
        // Calculate monthly totals
        double monthlyIncome = 0;
        double monthlyExpense = 0;

        for (var tx in allTransactions) {
          if (tx.createdAt == null) continue;
          if (tx.createdAt!.year != selectedMonth.year ||
              tx.createdAt!.month != selectedMonth.month)
            continue;

          final type = tx.type?.trim().toLowerCase();
          if (type == 'pemasukan') {
            monthlyIncome += tx.amount;
          } else if (type == 'pengeluaran') {
            monthlyExpense += tx.amount;
          }
        }

        final monthlySaldo = monthlyIncome - monthlyExpense;

        return _SummaryCard(
          pemasukan: monthlyIncome,
          pengeluaran: monthlyExpense,
          saldo: monthlySaldo,
          isLoading: false,
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    // final now = DateTime.now();
    // final today = DateTime(now.year, now.month, now.day);
    // final yesterday = today.subtract(const Duration(days: 1));
    // final targetDate = DateTime(date.year, date.month, date.day);

    return _formatFullDate(date);
  }

  String _getFirstDayOfMonth(DateTime date) {
    return '1 ${_formatMonthShort(date.month)} ${date.year}';
  }

  String _getLastDayOfMonth(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return '${lastDay.day} ${_formatMonthShort(date.month)} ${date.year}';
  }

  void _showMonthPicker(BuildContext context, WidgetRef ref, DateTime current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Pilih Bulan',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Month Grid
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = DateTime(current.year, index + 1);
                  final isSelected = month.month == current.month;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ref.read(_selectedMonthProvider.notifier).state = month;
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _formatMonthName(index + 1),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double pemasukan;
  final double pengeluaran;
  final double saldo;
  final bool isLoading;

  const _SummaryCard({
    required this.pemasukan,
    required this.pengeluaran,
    required this.saldo,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ringkasan Keuangan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Bulan Ini',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Income and Expense Row
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        icon: Icons.arrow_downward,
                        label: 'Total Pemasukan',
                        amount: pemasukan,
                        isLoading: isLoading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryItem(
                        icon: Icons.arrow_upward,
                        label: 'Total Pengeluaran',
                        amount: pengeluaran,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Saldo Akhir
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Saldo Akhir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _currencyFormatter.format(saldo),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final bool isLoading;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.amount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _currencyFormatter.format(amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }
}

class _MonthNavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavigationButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

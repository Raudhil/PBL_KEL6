import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../controllers/keuangan_controller.dart';
import '../../widgets/month_selector_card.dart';
import '../../widgets/financial_summary_card.dart';
import '../../widgets/transaction_list.dart';
import '../keuangan_warga/transaction_form.dart';

final _selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final _transactionFilterProvider = StateProvider<String>((ref) => 'semua');

class KeuanganPage extends ConsumerWidget {
  const KeuanganPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(_selectedMonthProvider);
    final transactionFilter = ref.watch(_transactionFilterProvider);
    final keuanganState = ref.watch(keuanganControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomTopBar(
        title: 'Laporan Keuangan',
        showBackButton: true,
        actions: [],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionFormPage()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Transaksi Baru'),
        elevation: 4,
      ),
      body: Column(
        children: [
          // Filter Tab Bar
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildFilterTab(
                      ref,
                      label: 'Semua',
                      value: 'semua',
                      isSelected: transactionFilter == 'semua',
                    ),
                    _buildFilterTab(
                      ref,
                      label: 'Pemasukan',
                      value: 'pemasukan',
                      isSelected: transactionFilter == 'pemasukan',
                    ),
                    _buildFilterTab(
                      ref,
                      label: 'Pengeluaran',
                      value: 'pengeluaran',
                      isSelected: transactionFilter == 'pengeluaran',
                    ),
                  ],
                ),
                Container(height: 1, color: Colors.grey[300]),
              ],
            ),
          ),

          // Month Selector Card
          MonthSelectorCard(
            selectedMonth: selectedMonth,
            onPreviousMonth: (newMonth) {
              ref.read(_selectedMonthProvider.notifier).state = newMonth;
            },
            onNextMonth: (newMonth) {
              ref.read(_selectedMonthProvider.notifier).state = newMonth;
            },
            onTapMonth: () => _showMonthPicker(context, ref, selectedMonth),
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
                        loading: () => const TransactionListSection(
                          filteredTransactions: [],
                          isLoading: true,
                        ),
                        error: (e, st) => TransactionListSection(
                          filteredTransactions: [],
                          error: e.toString(),
                        ),
                        data: (allTransactions) {
                          var filteredTransactions = allTransactions.where((
                            tx,
                          ) {
                            if (tx.createdAt == null) return false;
                            return tx.createdAt!.year == selectedMonth.year &&
                                tx.createdAt!.month == selectedMonth.month;
                          }).toList();

                          // Apply type filter
                          if (transactionFilter != 'semua') {
                            filteredTransactions = filteredTransactions.where((
                              tx,
                            ) {
                              final type = tx.type?.trim().toLowerCase();
                              return type == transactionFilter;
                            }).toList();
                          }

                          filteredTransactions.sort(
                            (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
                              a.createdAt ?? DateTime.now(),
                            ),
                          );

                          return TransactionListSection(
                            filteredTransactions: filteredTransactions,
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

  Widget _buildFilterTab(
    WidgetRef ref, {
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(_transactionFilterProvider.notifier).state = value;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                ),
              ),
            ),
            if (isSelected)
              Container(height: 3, color: AppColors.primary)
            else
              Container(height: 3, color: Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(
    WidgetRef ref,
    DateTime selectedMonth,
    AsyncValue<List<dynamic>> keuanganState,
  ) {
    return keuanganState.when(
      loading: () => const FinancialSummaryCard(
        pemasukan: 0,
        pengeluaran: 0,
        saldo: 0,
        isLoading: true,
      ),
      error: (e, st) => const FinancialSummaryCard(
        pemasukan: 0,
        pengeluaran: 0,
        saldo: 0,
        isLoading: false,
      ),
      data: (allTransactions) {
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

        return FinancialSummaryCard(
          pemasukan: monthlyIncome,
          pengeluaran: monthlyExpense,
          saldo: monthlySaldo,
          isLoading: false,
        );
      },
    );
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
}

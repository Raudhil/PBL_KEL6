import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import 'package:intl/intl.dart';
import 'package:jawara/features/bendahara/controllers/keuangan_controller.dart';
import 'package:jawara/features/bendahara/pages/keuangan_warga/pemasukan_page.dart';
import 'package:jawara/features/bendahara/pages/keuangan_warga/pengeluaran_page.dart';

final _currencyFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

class KeuanganPage extends ConsumerWidget {
  const KeuanganPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keuanganState = ref.watch(keuanganControllerProvider);
    final totalsFuture = ref
        .read(keuanganControllerProvider.notifier)
        .fetchTotals();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomTopBar(
        title: 'Keuangan',
        showBackButton: true,
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal swipeable cards
            SizedBox(
              height: 120,
              child: FutureBuilder<Map<String, double>>(
                future: totalsFuture,
                builder: (context, snapshot) {
                  final totals = snapshot.data;
                  final total = totals?['total'] ?? 0.0;
                  final pemasukan = totals?['pemasukan'] ?? 0.0;
                  final pengeluaran = totals?['pengeluaran'] ?? 0.0;

                  return PageView(
                    controller: PageController(viewportFraction: 0.88),
                    children: [
                      _FinancialCard(
                        title: 'Saldo',
                        amount: total,
                        description: 'Total saldo RT saat ini',
                        icon: Icons.account_balance_wallet,
                        gradient: LinearGradient(
                          colors: [Colors.blue[900]!, Colors.blue[200]!],
                        ),
                      ),
                      _FinancialCard(
                        title: 'Pemasukan',
                        amount: pemasukan,
                        description: 'Total seluruh pemasukan RT',
                        icon: Icons.add_card_outlined,
                        gradient: LinearGradient(
                          colors: [Colors.green[900]!, Colors.green[200]!],
                        ),
                      ),
                      _FinancialCard(
                        title: 'Pengeluaran',
                        amount: pengeluaran,
                        description: 'Total seluruh pengeluaran RT',
                        icon: Icons.shopping_cart_outlined,
                        gradient: LinearGradient(
                          colors: [Colors.red[900]!, Colors.red[200]!],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Menu header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Improved menu buttons with gradients
            Row(
              children: [
                Expanded(
                  child: _MenuButton(
                    label: 'Pemasukan',
                    icon: Icons.add_card_outlined,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PemasukanPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MenuButton(
                    label: 'Pengeluaran',
                    icon: Icons.shopping_cart_outlined,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PengeluaranPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transactions header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaksi Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Transaction items (individual cards, not inside a larger card)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: keuanganState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (list) {
                  if (list.isEmpty)
                    return const Center(child: Text('Belum ada transaksi'));
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: _TransactionCard(
                          title: item.title,
                          date: item.createdAt ?? DateTime.now(),
                          amount: item.amount,
                          type: item.type,
                          note: item.note,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Gradient gradient;
  final String? description;

  const _FinancialCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.gradient,
    this.description,
  });

  String _formatCurrency(double value) {
    final sign = value < 0 ? '-' : '';
    return '$sign${_currencyFormatter.format(value.abs())}';
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Colors.white;
    final Color iconBg = gradient.colors.last.withOpacity(0.9);

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 84.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatCurrency(amount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        description!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // icon top-right
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Icon(icon, color: iconColor, size: 28)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final double amount;
  final String? type;
  final String? note;

  const _TransactionCard({
    required this.title,
    required this.date,
    required this.amount,
    this.type,
    this.note,
  });

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    // Determine income/expense from `type` (enum: 'Pemasukan' / 'Pengeluaran')
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

    final amountText =
        '${isIncome ? '+' : '-'}${_currencyFormatter.format(amount.abs())}';

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(12),
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
                      color: (isIncome ? AppColors.success : AppColors.danger)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        isIncome
                            ? Icons.trending_up_outlined
                            : Icons.trending_down_outlined,
                        color: isIncome ? AppColors.success : AppColors.danger,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title + note + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          amountText,
                          style: TextStyle(
                            color: isIncome
                                ? AppColors.success
                                : AppColors.danger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (note != null && note!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        note!,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = color;
    final Color iconBg = (color).withOpacity(0.12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

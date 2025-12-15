import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jawara/theme/app_colors.dart';
import '../../../data/models/keuangan_model.dart';
import '../controllers/keuangan_controller.dart';
import '../pages/keuangan_warga/transaction_form.dart';

class ExpandableTransactionCard extends ConsumerStatefulWidget {
  final KeuanganModel transaction;

  const ExpandableTransactionCard({Key? key, required this.transaction})
    : super(key: key);

  @override
  ConsumerState<ExpandableTransactionCard> createState() =>
      _ExpandableTransactionCardState();
}

class _ExpandableTransactionCardState
    extends ConsumerState<ExpandableTransactionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    final expandedId = ref.read(expandedTransactionIdProvider);

    if (expandedId == widget.transaction.id) {
      // Jika card ini yang expand, tutup dia
      ref.read(expandedTransactionIdProvider.notifier).state = null;
      _expandController.reverse();
    } else {
      // Buka card ini dan tutup yang lain
      ref.read(expandedTransactionIdProvider.notifier).state =
          widget.transaction.id;
      _expandController.forward();
    }
  }

  void _handleEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormPage(transaction: widget.transaction),
      ),
    );
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi "${widget.transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTransaction();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction() async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menghapus transaksi...')));

      await ref
          .read(keuanganControllerProvider.notifier)
          .deleteTransaction(widget.transaction.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Transaksi berhasil dihapus'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Gagal menghapus: ${e.toString()}'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? d) =>
      d == null ? '' : '${d.day}/${d.month}/${d.year}';

  String _formatDateTime(DateTime? d) {
    if (d == null) return '';
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(d);
  }

  @override
  Widget build(BuildContext context) {
    final expandedId = ref.watch(expandedTransactionIdProvider);
    final isExpanded = expandedId == widget.transaction.id;

    // Update animation sesuai state
    if (isExpanded && !_expandController.isAnimating) {
      _expandController.forward();
    } else if (!isExpanded &&
        _expandController.status == AnimationStatus.completed) {
      _expandController.reverse();
    }

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final isIncome =
        widget.transaction.type?.trim().toLowerCase() == 'pemasukan';
    final leadingColor = isIncome ? AppColors.success : AppColors.danger;
    final leadingIcon = isIncome ? Icons.trending_up : Icons.trending_down;
    final hasNote =
        widget.transaction.note != null && widget.transaction.note!.isNotEmpty;
    final amountText = formatter.format(widget.transaction.amount.abs());

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isExpanded ? AppColors.primary : Colors.grey[200]!,
              width: isExpanded ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isExpanded ? 0.15 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Main Card Content
              InkWell(
                onTap: _toggleExpand,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(14),
                  bottom: Radius.circular(isExpanded ? 0 : 14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
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
                            child: Icon(
                              leadingIcon,
                              color: leadingColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              widget.transaction.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hasNote) ...[
                              const SizedBox(height: 6),
                              Text(
                                widget.transaction.note!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (widget.transaction.createdAt != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(widget.transaction.createdAt),
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

                      // Amount & Expand Icon
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
              ),

              // Expanded Content dengan AnimatedCrossFade
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0, width: double.infinity),
                secondChild: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Detail Section
                        _buildDetailRow(
                          'Jenis Transaksi',
                          widget.transaction.type ?? '-',
                          isIncome ? AppColors.success : AppColors.danger,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Jumlah', amountText, leadingColor),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Tanggal & Waktu',
                          _formatDateTime(widget.transaction.createdAt),
                          AppColors.textSecondary,
                        ),
                        if (hasNote) ...[
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Catatan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.transaction.note!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _handleEdit,
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _handleDelete,
                                icon: const Icon(Icons.delete),
                                label: const Text('Hapus'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.danger.withOpacity(
                                    0.1,
                                  ),
                                  foregroundColor: AppColors.danger,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 400),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

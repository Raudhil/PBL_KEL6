import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../data/models/iuran_warga_model.dart';

class IuranListItem extends StatefulWidget {
  final IuranWargaModel data;
  final Function(int id) onPay;

  const IuranListItem({super.key, required this.data, required this.onPay});

  @override
  State<IuranListItem> createState() => _IuranListItemState();
}

class _IuranListItemState extends State<IuranListItem> {
  bool _isExpanded = false;

  String _formatRupiah(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Lunas':
        return AppColors.success;
      case 'Menunggu Verifikasi':
        return AppColors.warning;
      case 'Menunggak':
        return AppColors.danger;
      default:
        return AppColors.greyMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iuran = widget.data.iuran;
    final status = widget.data.status;
    final isPaid = widget.data.isPaid;
    final statusColor = _getStatusColor(status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.greyLight,
          width: _isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyDark.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (Selalu terlihat)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: Radius.circular(_isExpanded ? 0 : 16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.greyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPaid ? Icons.check_circle : Icons.receipt_long,
                      color: isPaid ? AppColors.success : AppColors.greyDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          iuran.jenis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jatuh Tempo: ${_formatDate(iuran.jatuhTempo)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${_formatRupiah(iuran.nominal)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content (Flow Pembayaran)
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0, width: double.infinity),
            secondChild: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.greyLight)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Nominal Tagihan',
                    'Rp ${_formatRupiah(iuran.nominal)}',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Biaya Admin', 'Rp 0'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rp ${_formatRupiah(iuran.nominal)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  if (!isPaid && status != 'Menunggu Verifikasi')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => widget.onPay(iuran.id!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Bayar Sekarang'),
                      ),
                    )
                  else if (status == 'Menunggu Verifikasi')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Pembayaran Sedang Diverifikasi',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Pembayaran Selesai',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

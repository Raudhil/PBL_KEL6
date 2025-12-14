import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../core/providers/warga_provider.dart';
import '../pages/warga_detail_page.dart';
import '../pages/edit_warga_page.dart';

class WargaCard extends ConsumerStatefulWidget {
  final dynamic warga;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final GlobalKey? cardKey;

  const WargaCard({
    super.key,
    required this.warga,
    this.isExpanded = false,
    this.onToggle,
    this.cardKey,
  });

  @override
  ConsumerState<WargaCard> createState() => _WargaCardState();
}

class _WargaCardState extends ConsumerState<WargaCard> {
  @override
  Widget build(BuildContext context) {
    // Tentukan status dari database users
    final String statusText = widget.warga.userStatus ?? 'Tidak Aktif';
    final bool isActive = statusText == 'Aktif';
    final Color statusColor = isActive ? AppColors.success : AppColors.danger;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      shadowColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            widget.onToggle?.call();
            // Auto-scroll after expansion
            if (!widget.isExpanded && widget.cardKey != null) {
              Future.delayed(const Duration(milliseconds: 300), () {
                Scrollable.ensureVisible(
                  widget.cardKey!.currentContext!,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: 0.1, // Position at 10% from top of viewport
                );
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Header - Nama dan NIK dengan Status di pojok kanan atas
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Nama dan NIK
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.warga.namaLengkap,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIK : ${widget.warga.nik}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge + Dropdown di pojok kanan atas
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Dropdown Icon
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            widget.isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Expanded Content
              if (widget.isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Divider
                      Divider(color: Colors.grey.shade200, height: 1),
                      const SizedBox(height: 16),

                      // RT/RW Info
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'RT/RW',
                        'RT 03/RW 05',
                      ),
                      const SizedBox(height: 12),

                      // KK Info
                      _buildInfoRow(
                        Icons.family_restroom_outlined,
                        'No. KK',
                        'KK${widget.warga.idKk.toString().padLeft(9, '0')}',
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons - Text only
                      Row(
                        children: [
                          // Button Detail
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WargaDetailPage(warga: widget.warga),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Detail',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Button Edit
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditWargaPage(warga: widget.warga),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                side: BorderSide(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Button Hapus
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _showDeleteConfirmation(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.danger,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                side: BorderSide(
                                  color: AppColors.danger.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Hapus',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_outlined,
                color: AppColors.danger,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hapus Warga',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus data warga berikut?',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.warga.namaLengkap,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIK: ${widget.warga.nik}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Data yang dihapus tidak dapat dikembalikan.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Menghapus data warga...'),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                ),
              );

              try {
                // Call delete from provider
                await ref
                    .read(wargaNotifierProvider.notifier)
                    .deleteWarga(widget.warga.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text('${widget.warga.namaLengkap} berhasil dihapus'),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Gagal menghapus: $e')),
                        ],
                      ),
                      backgroundColor: AppColors.danger,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

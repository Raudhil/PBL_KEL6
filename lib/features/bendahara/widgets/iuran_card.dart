import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/iuran_model.dart';
import '../pages/keuangan/iuran_form_page.dart';
import '../controllers/iuran_controllers.dart';

class IuranCard extends ConsumerStatefulWidget {
  final IuranModel item;

  const IuranCard({required this.item, super.key});

  @override
  ConsumerState<IuranCard> createState() => _IuranCardState();
}

class _IuranCardState extends ConsumerState<IuranCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _toggleExpand() {
    final expandedId = ref.read(expandedIuranIdProvider);

    if (expandedId == widget.item.id) {
      // Jika card ini yang expand, tutup dia
      ref.read(expandedIuranIdProvider.notifier).state = null;
      _controller.reverse();
    } else {
      // Buka card ini dan tutup yang lain
      ref.read(expandedIuranIdProvider.notifier).state = widget.item.id;
      _controller.forward();
    }
  }

  void _handleDelete(BuildContext context, WidgetRef ref, IuranModel item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Iuran'),
        content: Text('Yakin ingin menghapus "${item.jenis}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              try {
                // Await delete operation
                await ref
                    .read(iuranControllerProvider.notifier)
                    .deleteIuran(item.id!);

                if (dialogContext.mounted) Navigator.pop(dialogContext);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Iuran berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) Navigator.pop(dialogContext);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expandedId = ref.watch(expandedIuranIdProvider);
    final isExpanded = expandedId == widget.item.id;

    // Update animation sesuai state
    if (isExpanded && !_controller.isAnimating) {
      _controller.forward();
    } else if (!isExpanded && _controller.status == AnimationStatus.completed) {
      _controller.reverse();
    }

    return GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded ? AppColors.primary600 : AppColors.greyLight,
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyDark.withOpacity(isExpanded ? 0.1 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.item.jenis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                  child: const Icon(
                    Icons.expand_more,
                    color: AppColors.greyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Rp ${_formatRupiah(widget.item.nominal)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.event, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Jatuh Tempo: ${_formatDate(widget.item.jatuhTempo)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IuranFormPage(iuran: widget.item),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleDelete(context, ref, widget.item),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

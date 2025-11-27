import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../../../data/models/transaksi_marketplace_model.dart';
import '../../../../core/providers/marketplace_provider.dart';

class SellerOrderListPage extends ConsumerStatefulWidget {
  const SellerOrderListPage({super.key});

  @override
  ConsumerState<SellerOrderListPage> createState() =>
      _SellerOrderListPageState();
}

class _SellerOrderListPageState extends ConsumerState<SellerOrderListPage> {
  String _selectedFilter = 'Semua';

  Future<int?> _getUserIntId(String authId) async {
    try {
      final userData = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('id_auth', authId)
          .maybeSingle();
      return userData?['id'] as int?;
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.creamWhite,
        appBar: const CustomTopBar(
          title: 'Pesanan Masuk',
          showBackButton: true,
        ),
        body: const Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return FutureBuilder<int?>(
      future: _getUserIntId(currentUser.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.creamWhite,
            appBar: const CustomTopBar(
              title: 'Pesanan Masuk',
              showBackButton: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final userId = snapshot.data;
        if (userId == null) {
          return Scaffold(
            backgroundColor: AppColors.creamWhite,
            appBar: const CustomTopBar(
              title: 'Pesanan Masuk',
              showBackButton: true,
            ),
            body: const Center(child: Text('User ID tidak ditemukan')),
          );
        }

        return _buildOrdersPage(context, userId);
      },
    );
  }

  Widget _buildOrdersPage(BuildContext context, int userId) {
    // Get incoming orders for this seller
    final ordersAsync = ref.watch(incomingOrdersProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(title: 'Pesanan Masuk', showBackButton: true),
      body: ordersAsync.when(
        data: (orders) {
          // Filter orders by status
          List<TransaksiMarketplaceModel> filteredOrders = orders;
          if (_selectedFilter != 'Semua') {
            filteredOrders = orders.where((order) {
              switch (_selectedFilter) {
                case 'Pending':
                  return order.status == StatusTransaksi.pending;
                case 'Dikonfirmasi':
                  return order.status == StatusTransaksi.dikonfirmasi;
                case 'Selesai':
                  return order.status == StatusTransaksi.selesai;
                case 'Dibatalkan':
                  return order.status == StatusTransaksi.dibatalkan;
                default:
                  return true;
              }
            }).toList();
          }

          return Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(incomingOrdersProvider(userId));
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _OrderCard(
                              order: order,
                              onConfirm: () => _confirmOrder(order.id, userId),
                              onComplete: () =>
                                  _completeOrder(order.id, userId),
                              onCancel: () => _cancelOrder(order.id, userId),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => Scaffold(
          backgroundColor: AppColors.creamWhite,
          appBar: const CustomTopBar(
            title: 'Pesanan Masuk',
            showBackButton: true,
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          backgroundColor: AppColors.creamWhite,
          appBar: const CustomTopBar(
            title: 'Pesanan Masuk',
            showBackButton: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat pesanan\n${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(incomingOrdersProvider(userId)),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmOrder(int orderId, int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: const Text(
          'Stok produk akan dikurangi sesuai jumlah pesanan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ref.read(confirmOrderProvider(orderId).future);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dikonfirmasi & stok dikurangi'),
          backgroundColor: AppColors.success,
        ),
      );

      // Refresh orders
      ref.invalidate(incomingOrdersProvider(userId));
      ref.invalidate(todayOrdersCountProvider(userId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal konfirmasi pesanan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _completeOrder(int orderId, int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Pesanan'),
        content: const Text('Tandai pesanan ini sebagai selesai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ref.read(marketplaceRepositoryProvider).completeOrder(orderId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan diselesaikan'),
          backgroundColor: AppColors.success,
        ),
      );

      // Refresh orders
      ref.invalidate(incomingOrdersProvider(userId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyelesaikan pesanan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _cancelOrder(int orderId, int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text('Yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ref.read(marketplaceRepositoryProvider).cancelOrder(orderId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan dibatalkan'),
          backgroundColor: AppColors.warning,
        ),
      );

      // Refresh orders
      ref.invalidate(incomingOrdersProvider(userId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membatalkan pesanan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildFilterChips() {
    const filters = [
      'Semua',
      'Pending',
      'Dikonfirmasi',
      'Selesai',
      'Dibatalkan',
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary600 : AppColors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary600
                          : AppColors.greyLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppColors.greyMedium.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.greyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final TransaksiMarketplaceModel order;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const _OrderCard({
    required this.order,
    this.onConfirm,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statusDisplay = order.status.label;
    final statusColor = _getStatusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyDark.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    order.namaPembeli ?? 'Pembeli',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusDisplay,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.creamWhite,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: (order.items ?? []).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_basket,
                          color: AppColors.primary600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaProduk ?? 'Produk',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.qty} item × Rp ${_formatPrice(item.harga.toInt())}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Rp ${_formatPrice(order.total.toInt())}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Action buttons based on status
          if (order.isPending) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Terima'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (order.isDikonfirmasi) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text('Selesaikan Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(StatusTransaksi status) {
    switch (status) {
      case StatusTransaksi.pending:
        return AppColors.warning;
      case StatusTransaksi.dikonfirmasi:
        return AppColors.primary600;
      case StatusTransaksi.selesai:
        return AppColors.success;
      case StatusTransaksi.dibatalkan:
        return AppColors.error;
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

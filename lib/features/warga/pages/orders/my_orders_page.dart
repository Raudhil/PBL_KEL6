import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../../../data/models/transaksi_marketplace_model.dart';
import '../../../../core/providers/marketplace_provider.dart';
import 'order_detail_page.dart';

class MyOrdersPage extends ConsumerStatefulWidget {
  const MyOrdersPage({super.key});

  @override
  ConsumerState<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends ConsumerState<MyOrdersPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    // Get current user ID
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.creamWhite,
        appBar: const CustomTopBar(title: 'Pesanan Saya', showBackButton: true),
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
              title: 'Pesanan Saya',
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
              title: 'Pesanan Saya',
              showBackButton: true,
            ),
            body: const Center(child: Text('User ID tidak ditemukan')),
          );
        }

        return _buildOrdersPage(context, userId);
      },
    );
  }

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

  Widget _buildOrdersPage(BuildContext context, int userId) {
    final ordersAsync = ref.watch(transaksiHistoryProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(title: 'Pesanan Saya', showBackButton: true),
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

          if (orders.isEmpty) {
            return _buildEmptyOrders(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(transaksiHistoryProvider(userId));
            },
            child: Column(
              children: [
                _OrderFilterChips(
                  selected: _selectedFilter,
                  onSelected: (value) {
                    setState(() => _selectedFilter = value);
                  },
                ),
                Expanded(
                  child: filteredOrders.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada pesanan $_selectedFilter',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            return _OrderCard(
                              order: filteredOrders[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailPage(
                                      order: filteredOrders[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat pesanan\n${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(transaksiHistoryProvider(userId)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOrders(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: AppColors.greyMedium.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Pesanan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat pesanan Anda akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary600,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Mulai Belanja',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderFilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _OrderFilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const filters = [
      'Semua',
      'Pending',
      'Dikonfirmasi',
      'Selesai',
      'Dibatalkan',
    ];

    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((filter) {
            final isActive = filter == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: isActive,
                backgroundColor: AppColors.greyLight,
                selectedColor: AppColors.primary600,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.white : AppColors.textPrimary,
                ),
                onSelected: (_) => onSelected(filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final TransaksiMarketplaceModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Use actual status from order
    final statusDisplay = order.status.label;
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyDark.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 20,
                            color: AppColors.primary600,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '#${order.id}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor, width: 1),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            statusDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.payment,
                      size: 14,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'COD',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Display items
                if (order.items != null && order.items!.isNotEmpty) ...[
                  const Text(
                    'Produk Dipesan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items!
                      .take(2)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.greyLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: item.fotoProduk != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item.fotoProduk!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.image,
                                                size: 20,
                                                color: AppColors.greyMedium,
                                              ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.shopping_bag,
                                        size: 20,
                                        color: AppColors.greyMedium,
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.namaProduk ?? 'Produk',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${item.qty}x',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${_formatPrice(item.subtotal.toInt())}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (order.items!.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${order.items!.length - 2} produk lainnya',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Rp ${_formatPrice(order.total.toInt())}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary600,
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
      ),
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Color _getStatusColor(StatusTransaksi status) {
    switch (status) {
      case StatusTransaksi.pending:
        return AppColors.warning;
      case StatusTransaksi.dikonfirmasi:
        return Colors.blue;
      case StatusTransaksi.selesai:
        return AppColors.success;
      case StatusTransaksi.dibatalkan:
        return AppColors.error;
    }
  }
}

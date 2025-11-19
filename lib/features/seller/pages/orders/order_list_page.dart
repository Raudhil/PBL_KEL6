import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import 'order_detail_page.dart';

class SellerOrderListPage extends ConsumerStatefulWidget {
  const SellerOrderListPage({super.key});

  @override
  ConsumerState<SellerOrderListPage> createState() =>
      _SellerOrderListPageState();
}

class _SellerOrderListPageState extends ConsumerState<SellerOrderListPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual provider
    final allOrders = _dummyOrders;
    final filteredOrders = _selectedFilter == 'Semua'
        ? allOrders
        : allOrders
              .where((order) => order['status'] == _selectedFilter)
              .toList();

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(title: 'Pesanan Masuk', showBackButton: true),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _OrderCard(
                        order: order,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SellerOrderDetailPage(order: order),
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
  }

  Widget _buildFilterChips() {
    const filters = ['Semua', 'Pending', 'Diproses', 'Selesai', 'Dibatalkan'];

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
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;
    final paymentMethod = order['paymentMethod'] as String;
    final paymentStatus = order['paymentStatus'] as String;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
                      '#${order['id']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      order['buyerName'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.circular(14),
              ),
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
                          order['productName'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order['quantity']} item / $paymentMethod',
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
                      'Rp ${order['total']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: paymentStatus == 'Sudah Dibayar'
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        paymentStatus == 'Sudah Dibayar'
                            ? Icons.verified_outlined
                            : Icons.pending_actions,
                        size: 14,
                        color: paymentStatus == 'Sudah Dibayar'
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        paymentStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: paymentStatus == 'Sudah Dibayar'
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Pending':
        color = AppColors.warning;
        break;
      case 'Diproses':
        color = AppColors.primary600;
        break;
      case 'Selesai':
        color = AppColors.success;
        break;
      case 'Dibatalkan':
        color = AppColors.error;
        break;
      default:
        color = AppColors.greyDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// Dummy data
final _dummyOrders = [
  {
    'id': '001',
    'buyerName': 'Budi Santoso',
    'productName': 'Kentang Organik',
    'quantity': 2,
    'total': '30.000',
    'status': 'Pending',
    'paymentMethod': 'COD',
    'paymentStatus': 'Belum Dibayar',
  },
  {
    'id': '002',
    'buyerName': 'Siti Aminah',
    'productName': 'Wortel Segar',
    'quantity': 1,
    'total': '12.000',
    'status': 'Diproses',
    'paymentMethod': 'QRIS',
    'paymentStatus': 'Sudah Dibayar',
  },
  {
    'id': '003',
    'buyerName': 'Ahmad Rizki',
    'productName': 'Kentang Premium',
    'quantity': 3,
    'total': '60.000',
    'status': 'Selesai',
    'paymentMethod': 'COD',
    'paymentStatus': 'Sudah Dibayar',
  },
];

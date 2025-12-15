import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../../../core/providers/marketplace_provider.dart';
import '../products/product_list_page.dart';
import '../orders/order_list_page.dart';
import '../reviews/review_list_page.dart';
import '../settings/store_settings_page.dart';

class SellerHomePage extends ConsumerWidget {
  const SellerHomePage({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.creamWhite,
        appBar: const CustomTopBar(title: 'Kelola Toko', showBackButton: true),
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
              title: 'Kelola Toko',
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
              title: 'Kelola Toko',
              showBackButton: true,
            ),
            body: const Center(child: Text('User ID tidak ditemukan')),
          );
        }

        return _buildHomePage(context, ref, userId);
      },
    );
  }

  Future<void> _showNoStoreDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.store_outlined, color: AppColors.warning, size: 28),
            SizedBox(width: 12),
            Text('Toko Belum Tersedia'),
          ],
        ),
        content: Text(
          'Silakan atur informasi toko Anda terlebih dahulu sebelum melakukan penjualan. Anda akan diarahkan ke halaman Pengaturan Toko.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreSettingsPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary600,
              foregroundColor: Colors.white,
            ),
            child: Text('Atur Toko Sekarang'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage(BuildContext context, WidgetRef ref, int userId) {
    // Get store data
    final storeAsync = ref.watch(myStoreProvider(userId));
    final todayOrdersAsync = ref.watch(todayOrdersCountProvider(userId));
    final pendingOrdersListAsync = ref.watch(pendingOrdersProvider(userId));

    // Convert List to count for pending orders
    final pendingOrdersAsync = pendingOrdersListAsync.when(
      data: (list) => AsyncData<int>(list.length),
      loading: () => const AsyncLoading<int>(),
      error: (error, stack) => AsyncError<int>(error, stack),
    );
    return storeAsync.when(
      data: (store) {
        final storeName = store?.nama ?? 'Toko Saya';

        return Scaffold(
          backgroundColor: AppColors.creamWhite,
          appBar: const CustomTopBar(
            title: 'Kelola Toko',
            showBackButton: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStoreHeader(storeName),
                const SizedBox(height: 24),
                _buildSummaryCards(todayOrdersAsync, pendingOrdersAsync),
                const SizedBox(height: 24),
                const Text(
                  'Kelola Toko',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuGrid(context, ref, userId),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.creamWhite,
        appBar: const CustomTopBar(title: 'Kelola Toko', showBackButton: true),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.creamWhite,
        appBar: const CustomTopBar(title: 'Kelola Toko', showBackButton: true),
        body: Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }

  Widget _buildStoreHeader(String storeName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary600, AppColors.primary400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.store, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelola Toko Anda',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    AsyncValue<int> todayOrdersAsync,
    AsyncValue<int> pendingOrdersAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: todayOrdersAsync.when(
            data: (count) => _SummaryCard(
              icon: Icons.shopping_bag,
              label: 'Pesanan Diterima',
              value: count.toString(),
              color: AppColors.success,
            ),
            loading: () => const _SummaryCard(
              icon: Icons.shopping_bag,
              label: 'Pesanan Diterima',
              value: '...',
              color: AppColors.success,
            ),
            error: (_, __) => const _SummaryCard(
              icon: Icons.shopping_bag,
              label: 'Pesanan Diterima',
              value: '-',
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: pendingOrdersAsync.when(
            data: (count) => _SummaryCard(
              icon: Icons.pending_actions,
              label: 'Menunggu Konfirmasi',
              value: count.toString(),
              color: AppColors.warning,
            ),
            loading: () => const _SummaryCard(
              icon: Icons.pending_actions,
              label: 'Menunggu Konfirmasi',
              value: '...',
              color: AppColors.warning,
            ),
            error: (_, __) => const _SummaryCard(
              icon: Icons.pending_actions,
              label: 'Menunggu Konfirmasi',
              value: '-',
              color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context, WidgetRef ref, int userId) {
    final menus = [
      {
        'icon': Icons.inventory_2,
        'label': 'Produk Saya',
        'color': AppColors.primary600,
        'page': const SellerProductListPage(),
        'requiresStore': true,
      },
      {
        'icon': Icons.receipt_long,
        'label': 'Pesanan Masuk',
        'color': AppColors.success,
        'page': const SellerOrderListPage(),
        'requiresStore': true,
      },
      {
        'icon': Icons.star,
        'label': 'Ulasan Pembeli',
        'color': AppColors.warning,
        'page': const SellerReviewListPage(),
        'requiresStore': true,
      },
      {
        'icon': Icons.settings,
        'label': 'Pengaturan Toko',
        'color': AppColors.greyDark,
        'page': const StoreSettingsPage(),
        'requiresStore': false,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        final requiresStore = menu['requiresStore'] as bool;

        return _MenuCard(
          icon: menu['icon'] as IconData,
          label: menu['label'] as String,
          color: menu['color'] as Color,
          onTap: () async {
            if (requiresStore) {
              // Check if user has a store
              final store = await ref.read(myStoreProvider(userId).future);
              if (store == null) {
                if (context.mounted) {
                  _showNoStoreDialog(context);
                }
                return;
              }
            }

            if (context.mounted) {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => menu['page'] as Widget));

              // Refresh data setelah kembali dari halaman lain
              if (requiresStore) {
                ref.invalidate(todayOrdersCountProvider(userId));
                ref.invalidate(pendingOrdersProvider(userId));
              }
            }
          },
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyDark.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyDark.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/widgets/custom_top_bar.dart';
import '../../../../core/providers/marketplace_provider.dart';
import '../../../../data/models/produk_marketplace_model.dart';
import 'product_form_page.dart';

class SellerProductListPage extends ConsumerStatefulWidget {
  const SellerProductListPage({super.key});

  @override
  ConsumerState<SellerProductListPage> createState() =>
      _SellerProductListPageState();
}

class _SellerProductListPageState extends ConsumerState<SellerProductListPage> {
  int? _storeId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreId();
  }

  Future<void> _loadStoreId() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      // Get user integer ID
      final userData = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('id_auth', currentUser.id)
          .maybeSingle();

      if (userData == null) return;

      final userId = userData['id'] as int;

      // Get store
      final myStoreAsync = ref.read(myStoreProvider(userId));
      myStoreAsync.when(
        data: (store) {
          if (mounted && store != null) {
            setState(() {
              _storeId = store.id;
              _isLoading = false;
            });
          }
        },
        loading: () {},
        error: (_, __) {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.creamWhite,
        appBar: const CustomTopBar(title: 'Produk Saya', showBackButton: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_storeId == null) {
      return Scaffold(
        backgroundColor: AppColors.creamWhite,
        appBar: const CustomTopBar(title: 'Produk Saya', showBackButton: true),
        body: const Center(child: Text('Toko tidak ditemukan')),
      );
    }

    final productsAsync = ref.watch(produkByTokoProvider(_storeId!));

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: const CustomTopBar(title: 'Produk Saya', showBackButton: true),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: AppColors.greyMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada produk',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(produkByTokoProvider(_storeId!));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductFormPage(
                          product: product,
                          storeId: _storeId!,
                        ),
                      ),
                    ).then((_) {
                      // Refresh after edit
                      ref.invalidate(produkByTokoProvider(_storeId!));
                    });
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductFormPage(storeId: _storeId!),
            ),
          ).then((_) {
            // Refresh after add
            ref.invalidate(produkByTokoProvider(_storeId!));
          });
        },
        backgroundColor: AppColors.primary600,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProdukMarketplaceModel product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'kentang':
        return '🥔';
      case 'wortel':
        return '🥕';
      case 'tomat':
        return '🍅';
      default:
        return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stok == 0;
    final emoji = _getCategoryEmoji(product.nama);
    final hasPhoto =
        product.fotoProduk != null && product.fotoProduk!.isNotEmpty;
    final isNetworkImage = hasPhoto && product.fotoProduk!.startsWith('http');
    final isAssetImage = hasPhoto && product.fotoProduk!.startsWith('assets/');

    return Opacity(
      opacity: isOutOfStock ? 0.5 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.greyDark.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.greyLight,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isNetworkImage
                      ? Image.network(
                          product.fotoProduk!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        )
                      : isAssetImage
                      ? Image.asset(
                          product.fotoProduk!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nama,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${product.harga}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stok ${product.stok}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (isOutOfStock) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Habis',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

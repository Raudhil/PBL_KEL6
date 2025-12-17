import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../data/models/toko_model.dart';
import '../../data/models/produk_marketplace_model.dart';
import '../../data/models/transaksi_marketplace_model.dart';
import '../../data/models/review_produk_model.dart';

// ============================================
// REPOSITORY PROVIDER
// ============================================

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository();
});

// ============================================
// TOKO PROVIDERS
// ============================================

/// Provider untuk list semua toko
final tokoListProvider = FutureProvider.autoDispose<List<TokoModel>>((
  ref,
) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.getAllToko();
});

/// Provider untuk toko berdasarkan ID
final tokoByIdProvider = FutureProvider.autoDispose.family<TokoModel, int>((
  ref,
  id,
) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.getTokoById(id);
});

/// Provider untuk toko milik user (pemilik)
final myTokoProvider = FutureProvider.autoDispose.family<List<TokoModel>, int>((
  ref,
  userId,
) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.getTokoByPemilik(userId);
});

/// Provider untuk toko tunggal milik user (my store)
final myStoreProvider = FutureProvider.autoDispose.family<TokoModel?, int>((
  ref,
  userId,
) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.getMyStore(userId);
});

/// Provider untuk pesanan hari ini (count)
final todayOrdersCountProvider = FutureProvider.autoDispose.family<int, int>((
  ref,
  idPenjual,
) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.countTodayOrders(idPenjual);
});

// ============================================
// PRODUK PROVIDERS
// ============================================

/// Provider untuk list semua produk (realtime)
final produkListProvider =
    StreamProvider.autoDispose<List<ProdukMarketplaceModel>>((ref) {
      final repository = ref.read(marketplaceRepositoryProvider);
      return repository.streamAllProduk();
    });

/// Provider untuk produk berdasarkan toko (realtime)
final produkByTokoProvider = StreamProvider.autoDispose
    .family<List<ProdukMarketplaceModel>, int>((ref, tokoId) {
      final repository = ref.read(marketplaceRepositoryProvider);
      return repository.streamProdukByToko(tokoId);
    });

/// Provider untuk detail produk
final produkDetailProvider = FutureProvider.autoDispose
    .family<ProdukMarketplaceModel, int>((ref, id) async {
      final repository = ref.read(marketplaceRepositoryProvider);
      return await repository.getProdukById(id);
    });

/// Provider untuk search/filter produk
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider untuk kategori yang dipilih
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredProdukProvider =
    Provider.autoDispose<AsyncValue<List<ProdukMarketplaceModel>>>((ref) {
      final produkAsync = ref.watch(produkListProvider);
      final query = ref.watch(searchQueryProvider).toLowerCase();
      final category = ref.watch(selectedCategoryProvider);

      return produkAsync.whenData((produkList) {
        var filtered = produkList;

        // Filter by search query
        if (query.isNotEmpty) {
          filtered = filtered
              .where(
                (p) =>
                    p.nama.toLowerCase().contains(query) ||
                    (p.deskripsi?.toLowerCase().contains(query) ?? false) ||
                    (p.namaToko?.toLowerCase().contains(query) ?? false),
              )
              .toList();
        }

        // Filter by category
        if (category != 'All') {
          filtered = filtered
              .where(
                (p) => p.nama.toLowerCase().contains(category.toLowerCase()),
              )
              .toList();
        }

        return filtered;
      });
    });

/// Provider untuk filtered products (alias untuk compatibility)
final filteredProductsProvider =
    Provider.autoDispose<List<ProdukMarketplaceModel>>((ref) {
      final filteredAsync = ref.watch(filteredProdukProvider);
      return filteredAsync.maybeWhen(
        data: (products) => products,
        orElse: () => [],
      );
    });

/// Provider untuk orders history (alias untuk compatibility)
final ordersHistoryProvider =
    Provider.autoDispose<List<TransaksiMarketplaceModel>>((ref) {
      // Get current user ID dari auth atau parameter
      // Untuk sementara return empty list
      return [];
    });

// ============================================
// KERANJANG (CART) PROVIDER
// ============================================

class CartItem {
  final ProdukMarketplaceModel produk;
  final int quantity;

  CartItem({required this.produk, required this.quantity});

  CartItem copyWith({ProdukMarketplaceModel? produk, int? quantity}) {
    return CartItem(
      produk: produk ?? this.produk,
      quantity: quantity ?? this.quantity,
    );
  }

  double get subtotal => produk.harga * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(ProdukMarketplaceModel produk, {int quantity = 1}) {
    final existingIndex = state.indexWhere(
      (item) => item.produk.id == produk.id,
    );

    if (existingIndex >= 0) {
      // Update quantity jika sudah ada
      final updatedCart = [...state];
      updatedCart[existingIndex] = updatedCart[existingIndex].copyWith(
        quantity: updatedCart[existingIndex].quantity + quantity,
      );
      state = updatedCart;
    } else {
      // Tambah item baru
      state = [...state, CartItem(produk: produk, quantity: quantity)];
    }
  }

  void removeFromCart(int produkId) {
    state = state.where((item) => item.produk.id != produkId).toList();
  }

  void updateQuantity(int produkId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(produkId);
      return;
    }

    state = state.map((item) {
      if (item.produk.id == produkId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Computed providers untuk cart
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

// ============================================
// TRANSAKSI PROVIDERS
// ============================================

/// Provider untuk riwayat transaksi user
final transaksiHistoryProvider = FutureProvider.autoDispose
    .family<List<TransaksiMarketplaceModel>, int>((ref, userId) async {
      final repository = ref.read(marketplaceRepositoryProvider);
      return await repository.getTransaksiByPembeli(userId);
    });

/// Provider untuk detail transaksi
final transaksiDetailProvider = FutureProvider.autoDispose
    .family<TransaksiMarketplaceModel, int>((ref, id) async {
      final repository = ref.read(marketplaceRepositoryProvider);
      return await repository.getTransaksiById(id);
    });

/// Provider untuk transaksi masuk ke toko penjual
final incomingOrdersProvider = FutureProvider.autoDispose
    .family<List<TransaksiMarketplaceModel>, int>((ref, idPenjual) async {
      final repository = ref.read(marketplaceRepositoryProvider);
      return await repository.getTransaksiByPenjual(idPenjual);
    });

/// Provider untuk transaksi pending
final pendingOrdersProvider = FutureProvider.autoDispose
    .family<List<TransaksiMarketplaceModel>, int>((ref, idPenjual) async {
      final repository = ref.read(marketplaceRepositoryProvider);
      return await repository.getTransaksiByPenjual(
        idPenjual,
        status: 'Pending',
      );
    });

/// Provider untuk confirm order
final confirmOrderProvider = FutureProvider.autoDispose
    .family<TransaksiMarketplaceModel, int>((ref, idTransaksi) async {
      final repository = ref.read(marketplaceRepositoryProvider);
      return await repository.confirmOrder(idTransaksi);
    });

// ============================================
// REVIEW PROVIDERS
// ============================================

/// Provider untuk review produk (realtime dengan limit 7 terbaru)
final reviewByProdukProvider = StreamProvider.autoDispose
    .family<List<ReviewProdukModel>, int>((ref, produkId) {
      final repository = ref.read(marketplaceRepositoryProvider);
      return repository.streamReviewByProduk(produkId);
    });

/// Provider untuk rata-rata rating produk (realtime)
final averageRatingProvider = StreamProvider.autoDispose.family<double, int>((
  ref,
  produkId,
) {
  final repository = ref.read(marketplaceRepositoryProvider);
  return repository.streamAverageRating(produkId);
});

/// Provider untuk review toko (semua review produk di toko)
final storeReviewsProvider =
    FutureProvider.family<List<ReviewProdukModel>, int>((ref, idToko) async {
      final repository = ref.read(marketplaceRepositoryProvider);
      return await repository.getReviewByToko(idToko);
    });

// ============================================
// KATEGORI PROVIDERS
// ============================================

/// Provider untuk list kategori produk dari database
final kategoriListProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return await repository.getDistinctKategori();
});

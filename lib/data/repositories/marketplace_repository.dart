import 'dart:typed_data';
import '../../core/services/marketplace_service.dart';
import '../../data/models/toko_model.dart';
import '../../data/models/produk_marketplace_model.dart';
import '../../data/models/transaksi_marketplace_model.dart';
import '../../data/models/review_produk_model.dart';

/// Repository untuk marketplace (wraps service calls)
class MarketplaceRepository {
  final MarketplaceService _service;

  MarketplaceRepository({MarketplaceService? service})
    : _service = service ?? MarketplaceService();

  // ============================================
  // TOKO
  // ============================================

  Future<List<TokoModel>> getAllToko() async {
    return await _service.fetchAllToko();
  }

  Future<TokoModel> getTokoById(int id) async {
    return await _service.fetchTokoById(id);
  }

  Future<List<TokoModel>> getTokoByPemilik(int idPemilik) async {
    return await _service.fetchTokoByPemilik(idPemilik);
  }

  Future<TokoModel?> getMyStore(int idPemilik) async {
    return await _service.fetchMyStore(idPemilik);
  }

  Future<TokoModel> createToko(TokoModel toko) async {
    return await _service.createToko(toko);
  }

  Future<TokoModel> updateToko(int id, Map<String, dynamic> updates) async {
    return await _service.updateToko(id, updates);
  }

  Future<void> deleteToko(int id) async {
    await _service.deleteToko(id);
  }

  // ============================================
  // PRODUK
  // ============================================

  Future<List<ProdukMarketplaceModel>> getAllProduk() async {
    return await _service.fetchAllProduk();
  }

  Future<List<ProdukMarketplaceModel>> getProdukByToko(int idToko) async {
    return await _service.fetchProdukByToko(idToko);
  }

  Future<ProdukMarketplaceModel> getProdukById(int id) async {
    return await _service.fetchProdukById(id);
  }

  Future<ProdukMarketplaceModel> createProduk(
    ProdukMarketplaceModel produk,
  ) async {
    return await _service.createProduk(produk);
  }

  Future<ProdukMarketplaceModel> updateProduk(
    int id,
    Map<String, dynamic> updates,
  ) async {
    return await _service.updateProduk(id, updates);
  }

  Future<void> deleteProduk(int id) async {
    await _service.deleteProduk(id);
  }

  Future<String> uploadFotoProduk(Uint8List imageBytes, int produkId) async {
    return await _service.uploadFotoProduk(imageBytes, produkId);
  }

  // ============================================
  // TRANSAKSI
  // ============================================

  Future<TransaksiMarketplaceModel> createTransaksi({
    required int idPembeli,
    required int idPenjual,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    return await _service.createTransaksi(
      idPembeli: idPembeli,
      idPenjual: idPenjual,
      total: total,
      items: items,
    );
  }

  Future<TransaksiMarketplaceModel> getTransaksiById(int id) async {
    return await _service.fetchTransaksiById(id);
  }

  Future<List<TransaksiMarketplaceModel>> getTransaksiByPembeli(
    int idPembeli,
  ) async {
    return await _service.fetchTransaksiByPembeli(idPembeli);
  }

  Future<List<TransaksiMarketplaceModel>> getTransaksiByPenjual(
    int idPenjual, {
    String? status,
  }) async {
    return await _service.fetchTransaksiByPenjual(idPenjual, status: status);
  }

  Future<TransaksiMarketplaceModel> confirmOrder(int idTransaksi) async {
    return await _service.confirmOrder(idTransaksi);
  }

  Future<TransaksiMarketplaceModel> completeOrder(int idTransaksi) async {
    return await _service.completeOrder(idTransaksi);
  }

  Future<TransaksiMarketplaceModel> cancelOrder(int idTransaksi) async {
    return await _service.cancelOrder(idTransaksi);
  }

  Future<int> countTodayOrders(int idPenjual) async {
    return await _service.countTodayOrders(idPenjual);
  }

  // ============================================
  // REVIEW
  // ============================================

  Future<ReviewProdukModel> createReview(ReviewProdukModel review) async {
    return await _service.createReview(review);
  }

  Future<List<ReviewProdukModel>> getReviewByProduk(int idProduk) async {
    return await _service.fetchReviewByProduk(idProduk);
  }

  Future<List<ReviewProdukModel>> getReviewByToko(int idToko) async {
    return await _service.fetchReviewByToko(idToko);
  }

  Future<ReviewProdukModel?> getReviewByTransaksi(int idTransaksi) async {
    return await _service.fetchReviewByTransaksi(idTransaksi);
  }

  Future<ReviewProdukModel> updateReview(
    int id,
    Map<String, dynamic> updates,
  ) async {
    return await _service.updateReview(id, updates);
  }

  Future<void> deleteReview(int id) async {
    await _service.deleteReview(id);
  }

  Future<double> calculateAverageRating(int idProduk) async {
    return await _service.calculateAverageRating(idProduk);
  }

  // ============================================
  // KATEGORI
  // ============================================

  Future<List<String>> getDistinctKategori() async {
    return await _service.fetchDistinctKategori();
  }
}

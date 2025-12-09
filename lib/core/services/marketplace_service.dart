import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/toko_model.dart';
import '../../data/models/produk_marketplace_model.dart';
import '../../data/models/transaksi_marketplace_model.dart';
import '../../data/models/review_produk_model.dart';

/// Service untuk operasi marketplace (CRUD toko, produk, transaksi, review)
class MarketplaceService {
  final SupabaseClient _client;

  MarketplaceService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  // ============================================
  // TOKO (STORE) OPERATIONS
  // ============================================

  /// Fetch semua toko
  Future<List<TokoModel>> fetchAllToko() async {
    try {
      final response = await _client
          .from('toko')
          .select('*, users!toko_id_pemilik_fkey(full_name)')
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (item) => TokoModel.fromJson({
              ...item,
              'nama_pemilik': item['users']?['full_name'],
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Gagal fetch toko: $e');
    }
  }

  /// Fetch toko berdasarkan ID
  Future<TokoModel> fetchTokoById(int id) async {
    try {
      final response = await _client
          .from('toko')
          .select('*, users!toko_id_pemilik_fkey(full_name)')
          .eq('id', id)
          .single();

      return TokoModel.fromJson({
        ...response,
        'nama_pemilik': response['users']?['full_name'],
      });
    } catch (e) {
      throw Exception('Gagal fetch toko: $e');
    }
  }

  /// Fetch toko milik user tertentu
  Future<List<TokoModel>> fetchTokoByPemilik(int idPemilik) async {
    try {
      final response = await _client
          .from('toko')
          .select('*')
          .eq('id_pemilik', idPemilik)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => TokoModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Gagal fetch toko: $e');
    }
  }

  /// Fetch toko milik user yang sedang login (hanya 1 toko)
  Future<TokoModel?> fetchMyStore(int idPemilik) async {
    try {
      final response = await _client
          .from('toko')
          .select('*')
          .eq('id_pemilik', idPemilik)
          .maybeSingle();

      if (response == null) return null;
      return TokoModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal fetch toko saya: $e');
    }
  }

  /// Buat toko baru
  Future<TokoModel> createToko(TokoModel toko) async {
    try {
      final response = await _client
          .from('toko')
          .insert(toko.toInsertJson())
          .select()
          .single();

      return TokoModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat toko: $e');
    }
  }

  /// Update toko
  Future<TokoModel> updateToko(int id, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('toko')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return TokoModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal update toko: $e');
    }
  }

  /// Hapus toko
  Future<void> deleteToko(int id) async {
    try {
      await _client.from('toko').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal hapus toko: $e');
    }
  }

  // ============================================
  // PRODUK OPERATIONS
  // ============================================

  /// Fetch semua produk
  Future<List<ProdukMarketplaceModel>> fetchAllProduk() async {
    try {
      final response = await _client
          .from('produk')
          .select('*, toko!produk_id_toko_fkey(nama)')
          .eq('is_deleted', false) // Only fetch non-deleted products
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (item) => ProdukMarketplaceModel.fromJson({
              ...item,
              'nama_toko': item['toko']?['nama'],
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Gagal fetch produk: $e');
    }
  }

  /// Fetch produk berdasarkan toko
  Future<List<ProdukMarketplaceModel>> fetchProdukByToko(int idToko) async {
    try {
      final response = await _client
          .from('produk')
          .select('*')
          .eq('id_toko', idToko)
          .eq('is_deleted', false) // Only fetch non-deleted products
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ProdukMarketplaceModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Gagal fetch produk: $e');
    }
  }

  /// Fetch produk berdasarkan ID
  Future<ProdukMarketplaceModel> fetchProdukById(int id) async {
    try {
      final response = await _client
          .from('produk')
          .select('*, toko!produk_id_toko_fkey(nama)')
          .eq('id', id)
          .single();

      return ProdukMarketplaceModel.fromJson({
        ...response,
        'nama_toko': response['toko']?['nama'],
      });
    } catch (e) {
      throw Exception('Gagal fetch produk: $e');
    }
  }

  /// Buat produk baru
  Future<ProdukMarketplaceModel> createProduk(
    ProdukMarketplaceModel produk,
  ) async {
    try {
      final response = await _client
          .from('produk')
          .insert(produk.toInsertJson())
          .select()
          .single();

      return ProdukMarketplaceModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat produk: $e');
    }
  }

  /// Update produk
  Future<ProdukMarketplaceModel> updateProduk(
    int id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('produk')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return ProdukMarketplaceModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal update produk: $e');
    }
  }

  /// Hapus produk (soft delete)
  Future<void> deleteProduk(int id) async {
    try {
      await _client.from('produk').update({'is_deleted': true}).eq('id', id);
    } catch (e) {
      throw Exception('Gagal hapus produk: $e');
    }
  }

  /// Upload foto produk ke Supabase Storage (accepts bytes for web compatibility)
  Future<String> uploadFotoProduk(Uint8List imageBytes, int produkId) async {
    try {
      final fileName =
          'produk_${produkId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _client.storage
          .from('product-images')
          .uploadBinary(fileName, imageBytes);

      final publicUrl = _client.storage
          .from('product-images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload foto: $e');
    }
  }

  // ============================================
  // TRANSAKSI OPERATIONS
  // ============================================

  /// Buat transaksi baru dengan detail items
  Future<TransaksiMarketplaceModel> createTransaksi({
    required int idPembeli,
    required int idPenjual,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // Insert transaksi with status Pending (database enum value)
      final transaksiResponse = await _client
          .from('transaksi_marketplace')
          .insert({
            'id_pembeli': idPembeli,
            'total': total,
            'status': 'Pending',
          })
          .select()
          .single();

      final idTransaksi = transaksiResponse['id'] as int;

      // Insert detail items
      final detailItems = items.map((item) {
        return {
          'id_transaksi': idTransaksi,
          'id_produk': item['id_produk'],
          'qty': item['qty'],
          'harga': item['harga'],
          'subtotal': item['subtotal'],
        };
      }).toList();

      await _client.from('detail_t_marketplace').insert(detailItems);

      // NOTE: Stok TIDAK dikurangi di sini. Stok akan dikurangi saat penjual konfirmasi pesanan.
      // Ini mencegah stok berkurang untuk pesanan yang belum dikonfirmasi atau dibatalkan.

      return await fetchTransaksiById(idTransaksi);
    } catch (e) {
      throw Exception('Gagal membuat transaksi: $e');
    }
  }

  /// Fetch transaksi berdasarkan ID
  Future<TransaksiMarketplaceModel> fetchTransaksiById(int id) async {
    try {
      final transaksiResponse = await _client
          .from('transaksi_marketplace')
          .select('*, users!transaksi_marketplace_id_pembeli_fkey(full_name)')
          .eq('id', id)
          .single();

      final detailResponse = await _client
          .from('detail_t_marketplace')
          .select(
            '*, produk!detail_t_marketplace_id_produk_fkey(nama, foto_produk)',
          )
          .eq('id_transaksi', id);

      final items = (detailResponse as List)
          .map(
            (item) => DetailTransaksiModel.fromJson({
              ...item,
              'nama_produk': item['produk']?['nama'],
              'foto_produk': item['produk']?['foto_produk'],
            }),
          )
          .toList();

      return TransaksiMarketplaceModel.fromJson({
        ...transaksiResponse,
        'nama_pembeli': transaksiResponse['users']?['full_name'],
        'items': items.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Gagal fetch transaksi: $e');
    }
  }

  /// Fetch transaksi berdasarkan pembeli
  Future<List<TransaksiMarketplaceModel>> fetchTransaksiByPembeli(
    int idPembeli,
  ) async {
    try {
      final response = await _client
          .from('transaksi_marketplace')
          .select('*, users!transaksi_marketplace_id_pembeli_fkey(full_name)')
          .eq('id_pembeli', idPembeli)
          .order('created_at', ascending: false);

      final transactions = <TransaksiMarketplaceModel>[];

      for (final item in response as List) {
        // Fetch detail items untuk setiap transaksi
        final detailResponse = await _client
            .from('detail_t_marketplace')
            .select(
              '*, produk!detail_t_marketplace_id_produk_fkey(nama, foto_produk)',
            )
            .eq('id_transaksi', item['id']);

        final items = (detailResponse as List)
            .map(
              (d) => DetailTransaksiModel.fromJson({
                ...d,
                'nama_produk': d['produk']?['nama'],
                'foto_produk': d['produk']?['foto_produk'],
              }),
            )
            .toList();

        transactions.add(
          TransaksiMarketplaceModel.fromJson({
            ...item,
            'nama_pembeli': item['users']?['full_name'],
            'items': items.map((e) => e.toJson()).toList(),
          }),
        );
      }

      return transactions;
    } catch (e) {
      throw Exception('Gagal fetch transaksi: $e');
    }
  }

  /// Fetch transaksi yang masuk ke toko penjual
  Future<List<TransaksiMarketplaceModel>> fetchTransaksiByPenjual(
    int idPenjual, {
    String? status,
  }) async {
    try {
      // Step 1: Get toko ID from owner ID
      final tokoResponse = await _client
          .from('toko')
          .select('id')
          .eq('id_pemilik', idPenjual)
          .maybeSingle();

      if (tokoResponse == null) {
        // User doesn't have a store, return empty list
        return [];
      }

      final idToko = tokoResponse['id'] as int;

      // Step 2: Get all product IDs from this toko
      final storeProducts = await _client
          .from('produk')
          .select('id')
          .eq('id_toko', idToko);

      if ((storeProducts as List).isEmpty) {
        // Store has no products, return empty list
        return [];
      }

      final productIds = (storeProducts as List)
          .map((p) => p['id'] as int)
          .toList();

      // Step 3: Get transaction IDs that contain these products
      final detailResponse = await _client
          .from('detail_t_marketplace')
          .select('id_transaksi')
          .inFilter('id_produk', productIds);

      if ((detailResponse as List).isEmpty) {
        // No transactions with these products
        return [];
      }

      // Get unique transaction IDs
      final transactionIds = (detailResponse as List)
          .map((d) => d['id_transaksi'] as int)
          .toSet()
          .toList();

      // Step 4: Fetch the actual transactions
      var query = _client
          .from('transaksi_marketplace')
          .select('*, users!transaksi_marketplace_id_pembeli_fkey(full_name)')
          .inFilter('id', transactionIds);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);

      final transactions = <TransaksiMarketplaceModel>[];

      for (final item in response as List) {
        // Fetch detail items untuk setiap transaksi
        final detailItemResponse = await _client
            .from('detail_t_marketplace')
            .select(
              '*, produk!detail_t_marketplace_id_produk_fkey(nama, foto_produk)',
            )
            .eq('id_transaksi', item['id']);

        final items = (detailItemResponse as List)
            .map(
              (d) => DetailTransaksiModel.fromJson({
                ...d,
                'nama_produk': d['produk']?['nama'],
                'foto_produk': d['produk']?['foto_produk'],
              }),
            )
            .toList();

        transactions.add(
          TransaksiMarketplaceModel.fromJson({
            ...item,
            'nama_pembeli': item['users']?['full_name'],
            'items': items.map((e) => e.toJson()).toList(),
          }),
        );
      }

      return transactions;
    } catch (e) {
      throw Exception('Gagal fetch transaksi penjual: $e');
    }
  }

  /// Konfirmasi pesanan (ubah status dari pending ke dikonfirmasi)
  /// Confirm order (ubah status dari pending ke dikonfirmasi)
  /// Dan kurangi stok produk sesuai quantity yang dibeli
  Future<TransaksiMarketplaceModel> confirmOrder(int idTransaksi) async {
    try {
      // Fetch detail transaksi untuk kurangi stok
      final detailResponse = await _client
          .from('detail_t_marketplace')
          .select('id_produk, qty')
          .eq('id_transaksi', idTransaksi);

      // Kurangi stok untuk setiap item
      for (final item in detailResponse as List) {
        final produkId = item['id_produk'] as int;
        final qty = item['qty'] as int;

        // Fetch current stok
        final produkResponse = await _client
            .from('produk')
            .select('stok')
            .eq('id', produkId)
            .single();

        final currentStok = produkResponse['stok'] as int;
        final newStok = currentStok - qty;

        if (newStok < 0) {
          throw Exception('Stok produk tidak cukup (ID: $produkId)');
        }

        // Update stok
        await _client
            .from('produk')
            .update({'stok': newStok})
            .eq('id', produkId);
      }

      // Update status transaksi ke dikonfirmasi
      final response = await _client
          .from('transaksi_marketplace')
          .update({'status': 'Dikonfirmasi'})
          .eq('id', idTransaksi)
          .select()
          .single();

      return TransaksiMarketplaceModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal konfirmasi pesanan: $e');
    }
  }

  /// Selesaikan pesanan (ubah status ke selesai)
  Future<TransaksiMarketplaceModel> completeOrder(int idTransaksi) async {
    try {
      final response = await _client
          .from('transaksi_marketplace')
          .update({'status': 'Selesai'})
          .eq('id', idTransaksi)
          .select()
          .single();

      return TransaksiMarketplaceModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menyelesaikan pesanan: $e');
    }
  }

  /// Batalkan pesanan
  Future<TransaksiMarketplaceModel> cancelOrder(int idTransaksi) async {
    try {
      final response = await _client
          .from('transaksi_marketplace')
          .update({'status': 'Dibatalkan'})
          .eq('id', idTransaksi)
          .select()
          .single();

      return TransaksiMarketplaceModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membatalkan pesanan: $e');
    }
  }

  /// Hitung pesanan hari ini untuk toko
  Future<int> countTodayOrders(int idPenjual) async {
    try {
      // Step 1: Get toko ID from owner ID
      final tokoResponse = await _client
          .from('toko')
          .select('id')
          .eq('id_pemilik', idPenjual)
          .maybeSingle();

      if (tokoResponse == null) {
        return 0;
      }

      final idToko = tokoResponse['id'] as int;

      // Step 2: Get store products
      final storeProducts = await _client
          .from('produk')
          .select('id')
          .eq('id_toko', idToko);

      if ((storeProducts as List).isEmpty) {
        return 0;
      }

      final productIds = (storeProducts as List)
          .map((p) => p['id'] as int)
          .toList();

      // Step 3: Get transaction IDs that contain these products
      final detailResponse = await _client
          .from('detail_t_marketplace')
          .select('id_transaksi')
          .inFilter('id_produk', productIds);

      if ((detailResponse as List).isEmpty) {
        return 0;
      }

      final transactionIds = (detailResponse as List)
          .map((d) => d['id_transaksi'] as int)
          .toSet()
          .toList();

      // Step 4: Count transactions yang BUKAN pending (sudah dikonfirmasi/selesai)
      // Ini menghitung pesanan yang sudah di-ACC/diterima
      final response = await _client
          .from('transaksi_marketplace')
          .select('id')
          .inFilter('id', transactionIds)
          .neq('status', 'Pending');

      return (response as List).length;
    } catch (e) {
      print('❌ Error counting today orders: $e');
      return 0;
    }
  }

  // ============================================
  // REVIEW OPERATIONS
  // ============================================

  /// Buat review produk
  Future<ReviewProdukModel> createReview(ReviewProdukModel review) async {
    try {
      final response = await _client
          .from('review_produk')
          .insert(review.toInsertJson())
          .select()
          .single();

      return ReviewProdukModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat review: $e');
    }
  }

  /// Fetch review berdasarkan produk
  Future<List<ReviewProdukModel>> fetchReviewByProduk(int idProduk) async {
    try {
      final response = await _client
          .from('review_produk')
          .select('''
            *,
            transaksi_marketplace!review_produk_id_transaksi_fkey(
              users!transaksi_marketplace_id_pembeli_fkey(full_name)
            )
          ''')
          .eq('id_produk', idProduk)
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (item) => ReviewProdukModel.fromJson({
              ...item,
              'nama_pembeli':
                  item['transaksi_marketplace']?['users']?['full_name'],
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Gagal fetch review: $e');
    }
  }

  /// Fetch semua review untuk produk-produk di toko tertentu
  Future<List<ReviewProdukModel>> fetchReviewByToko(int idToko) async {
    try {
      final response = await _client
          .from('review_produk')
          .select('''
            *,
            produk!review_produk_id_produk_fkey(nama, id_toko),
            transaksi_marketplace!review_produk_id_transaksi_fkey(
              users!transaksi_marketplace_id_pembeli_fkey(full_name)
            )
          ''')
          .eq('produk.id_toko', idToko)
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (item) => ReviewProdukModel.fromJson({
              ...item,
              'nama_pembeli':
                  item['transaksi_marketplace']?['users']?['full_name'],
              'nama_produk': item['produk']?['nama'],
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Gagal fetch review toko: $e');
    }
  }

  /// Fetch review berdasarkan transaksi
  Future<ReviewProdukModel?> fetchReviewByTransaksi(int idTransaksi) async {
    try {
      final response = await _client
          .from('review_produk')
          .select('''
            *,
            produk!review_produk_id_produk_fkey(nama),
            transaksi_marketplace!review_produk_id_transaksi_fkey(
              users!transaksi_marketplace_id_pembeli_fkey(full_name)
            )
          ''')
          .eq('id_transaksi', idTransaksi)
          .maybeSingle();

      if (response == null) return null;

      return ReviewProdukModel.fromJson({
        ...response,
        'nama_pembeli':
            response['transaksi_marketplace']?['users']?['full_name'],
        'nama_produk': response['produk']?['nama'],
      });
    } catch (e) {
      throw Exception('Gagal fetch review transaksi: $e');
    }
  }

  /// Update review
  Future<ReviewProdukModel> updateReview(
    int id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('review_produk')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return ReviewProdukModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal update review: $e');
    }
  }

  /// Hapus review
  Future<void> deleteReview(int id) async {
    try {
      await _client.from('review_produk').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal hapus review: $e');
    }
  }

  // ============================================
  // HELPER FUNCTIONS
  // ============================================

  /// Hitung rating rata-rata produk
  Future<double> calculateAverageRating(int idProduk) async {
    try {
      final response = await _client
          .from('review_produk')
          .select('rating')
          .eq('id_produk', idProduk);

      if ((response as List).isEmpty) return 0.0;

      final ratings = response.map((e) => e['rating'] as int).toList();
      final sum = ratings.fold<int>(0, (prev, curr) => prev + curr);
      return sum / ratings.length;
    } catch (e) {
      return 0.0;
    }
  }
}

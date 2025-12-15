import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/data/models/keuangan_model.dart';
import 'package:jawara/core/services/profil_service.dart';
import '../../../core/services/keuangan_service.dart';

class KeuanganController
    extends StateNotifier<AsyncValue<List<KeuanganModel>>> {
  KeuanganController(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  final KeuanganService _service;
  int? _idRt;

  Future<void> _init() async {
    try {
      final profilService = ProfilService();
      final full = await profilService.getFullUserData();
      final rt = full['rt'];
      if (rt is Map && rt.containsKey('id')) {
        _idRt = rt['id'] as int?;
      } else if (full['alamat'] is Map &&
          (full['alamat'] as Map).containsKey('id_rt')) {
        _idRt = (full['alamat'] as Map)['id_rt'] as int?;
      }
    } catch (_) {
      // ignore errors retrieving profile; fallback will be to fetch without idRt
    }

    await fetchTransactions();
  }

  Future<void> fetchTransactions({int limit = 500}) async {
    try {
      state = const AsyncValue.loading();
      final list = await _service.fetchTransactions(limit: limit, idRt: _idRt);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Map<String, double>> fetchTotals() async {
    return _service.fetchTotals(idRt: _idRt);
  }

  Future<void> addTransaction(KeuanganModel tx, {int? idRt}) async {
    try {
      await _service.addTransaction(tx, idRt: idRt);
      await fetchTransactions();
    } catch (e) {
      throw Exception('Gagal menambah transaksi: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _service.deleteTransaction(id);
      state.whenData((value) {
        state = AsyncValue.data(value.where((e) => e.id != id).toList());
      });
    } catch (e) {
      throw Exception('Gagal menghapus transaksi: $e');
    }
  }

  Future<void> updateTransaction(int id, KeuanganModel tx) async {
    try {
      // Update di backend
      await _service.updateTransaction(id, tx);
      // Refresh data
      await fetchTransactions();
    } catch (e) {
      throw Exception('Gagal mengubah transaksi: $e');
    }
  }
}

final keuanganControllerProvider =
    StateNotifierProvider<KeuanganController, AsyncValue<List<KeuanganModel>>>((
      ref,
    ) {
      final service = ref.read(keuanganServiceProvider);
      return KeuanganController(service);
    });

final expandedTransactionIdProvider = StateProvider<int?>((ref) => null);

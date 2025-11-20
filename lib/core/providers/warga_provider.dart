import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/warga_model.dart';
import '../../data/repositories/warga_repository.dart';
import '../services/supabase_service.dart';

final wargaRepositoryProvider = Provider<WargaRepository>((ref) {
  final service = SupabaseService();
  return WargaRepository(service);
});

final wargaNotifierProvider =
    StateNotifierProvider<WargaNotifier, AsyncValue<List<WargaModel>>>(
      (ref) => WargaNotifier(ref.read(wargaRepositoryProvider)),
    );

class WargaNotifier extends StateNotifier<AsyncValue<List<WargaModel>>> {
  final WargaRepository _repo;
  WargaNotifier(this._repo) : super(const AsyncValue.loading()) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repo.getAllWarga();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addWarga(WargaModel warga) async {
    try {
      await _repo.addWarga(warga);
      await fetchAll();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWarga(WargaModel warga) async {
    try {
      await _repo.updateWarga(warga);
      await fetchAll();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteWarga(int id) async {
    try {
      await _repo.deleteWarga(id);
      await fetchAll();
    } catch (e) {
      rethrow;
    }
  }
}

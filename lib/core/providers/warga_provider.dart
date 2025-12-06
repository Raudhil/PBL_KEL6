import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/warga_model.dart';
import '../../data/repositories/warga_repository.dart';
import '../services/kelola_warga_service.dart';

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
  RealtimeChannel? _realtimeChannel;

  WargaNotifier(this._repo) : super(const AsyncValue.loading()) {
    _setupRealtimeSubscription();
    fetchAll();
  }

  /// Setup realtime subscription untuk auto-refresh
  void _setupRealtimeSubscription() {
    _realtimeChannel = Supabase.instance.client
        .channel('warga_realtime_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'warga',
          callback: (payload) {
            // Refresh data ketika ada perubahan
            fetchAll();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
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
      // Data akan otomatis refresh via realtime subscription
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWarga(WargaModel warga) async {
    try {
      await _repo.updateWarga(warga);
      // Data akan otomatis refresh via realtime subscription
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteWarga(int id) async {
    try {
      await _repo.deleteWarga(id);
      // Data akan otomatis refresh via realtime subscription
    } catch (e) {
      rethrow;
    }
  }
}

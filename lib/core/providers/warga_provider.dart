import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/warga_model.dart';
import '../../data/repositories/warga_repository.dart';
import '../services/kelola_warga_service.dart';

final wargaRepositoryProvider = Provider<WargaRepository>((ref) {
  final service = SupabaseService();
  return WargaRepository(service);
});

/// Provider untuk get RT ID user yang login
final userRtIdProvider = FutureProvider.family<int?, int>((ref, userId) async {
  final repo = ref.read(wargaRepositoryProvider);
  return await repo.getUserRtId(userId);
});

/// Provider untuk list warga filtered by RT
final wargaByRTProvider = FutureProvider.family<List<WargaModel>, int?>((
  ref,
  rtId,
) async {
  final repo = ref.read(wargaRepositoryProvider);
  if (rtId == null) {
    // Jika tidak ada RT ID (admin), tampilkan semua
    return await repo.getAllWarga();
  } else {
    // Jika ada RT ID (warga biasa), filter by RT
    return await repo.getWargaByRT(rtId);
  }
});

final wargaNotifierProvider =
    StateNotifierProvider<WargaNotifier, AsyncValue<List<WargaModel>>>(
      (ref) => WargaNotifier(ref.read(wargaRepositoryProvider)),
    );

class WargaNotifier extends StateNotifier<AsyncValue<List<WargaModel>>> {
  final WargaRepository _repo;
  RealtimeChannel? _realtimeChannel;
  int? _filterRtId;

  WargaNotifier(this._repo) : super(const AsyncValue.loading()) {
    _setupRealtimeSubscription();
    fetchAll();
  }

  /// Set filter RT ID
  void setRtFilter(int? rtId) {
    _filterRtId = rtId;
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
      final list = _filterRtId == null
          ? await _repo.getAllWarga()
          : await _repo.getWargaByRT(_filterRtId!);
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

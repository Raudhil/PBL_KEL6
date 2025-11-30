import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/pengumuman_service.dart';
import '../constants/app_constants.dart';
import '../../data/models/pengumuman_model.dart';

/// Service provider
final pengumumanServiceProvider = Provider<PengumumanService>((ref) {
  return PengumumanService();
});

/// Provider untuk list pengumuman dengan filter
final pengumumanListProvider =
    StateNotifierProvider<
      PengumumanListNotifier,
      AsyncValue<List<PengumumanModel>>
    >((ref) {
      return PengumumanListNotifier(ref.read(pengumumanServiceProvider), ref);
    });

class PengumumanListNotifier
    extends StateNotifier<AsyncValue<List<PengumumanModel>>> {
  PengumumanListNotifier(this._service, this._ref)
    : super(const AsyncValue.loading()) {
    _setupRealtimeSubscription();
    loadPengumuman();
  }

  final PengumumanService _service;
  final Ref _ref;
  String? _searchQuery;
  RealtimeChannel? _realtimeChannel;

  /// Setup realtime subscription untuk auto-refresh
  void _setupRealtimeSubscription() {
    _realtimeChannel = Supabase.instance.client
        .channel(AppConstants.realtimeChannelPengumumanUser)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pengumuman',
          callback: (payload) {
            // Refresh data ketika ada perubahan
            refresh();
          },
        )
        .subscribe();
  }

  /// Load pengumuman dengan filter (selalu hanya milik user)
  Future<void> loadPengumuman({String? searchQuery}) async {
    _searchQuery = searchQuery;

    state = const AsyncValue.loading();
    try {
      final pengumumanList = await _service.getAllPengumuman(
        searchQuery: searchQuery,
        createdByCurrentUser:
            true, // Selalu true untuk hanya tampilkan milik user
      );
      state = AsyncValue.data(pengumumanList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadPengumuman(searchQuery: _searchQuery);
  }

  /// Search pengumuman
  void search(String query) {
    loadPengumuman(searchQuery: query.isEmpty ? null : query);
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}

/// Provider untuk detail pengumuman by ID
final pengumumanDetailProvider = FutureProvider.family<PengumumanModel?, int>((
  ref,
  id,
) async {
  final service = ref.read(pengumumanServiceProvider);
  return await service.getPengumumanById(id);
});

/// Provider untuk pengumuman aktif (dashboard) - menampilkan 5 pengumuman terbaru
/// dengan realtime subscription
final pengumumanAktifProvider =
    StateNotifierProvider.autoDispose<
      PengumumanAktifNotifier,
      AsyncValue<List<PengumumanModel>>
    >((ref) {
      return PengumumanAktifNotifier(ref.read(pengumumanServiceProvider));
    });

class PengumumanAktifNotifier
    extends StateNotifier<AsyncValue<List<PengumumanModel>>> {
  PengumumanAktifNotifier(this._service) : super(const AsyncValue.loading()) {
    _setupRealtimeSubscription();
    _loadData();
  }

  final PengumumanService _service;
  RealtimeChannel? _realtimeChannel;

  /// Setup realtime subscription untuk auto-refresh
  void _setupRealtimeSubscription() {
    _realtimeChannel = Supabase.instance.client
        .channel(AppConstants.realtimeChannelPengumumanAktif)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pengumuman',
          callback: (payload) {
            // Refresh data ketika ada perubahan (insert, update, delete)
            _loadData();
          },
        )
        .subscribe();
  }

  /// Load data dengan relasi lengkap
  Future<void> _loadData() async {
    try {
      final pengumumanList = await _service.getPengumumanAktif(
        limit: AppConstants.dashboardPengumumanLimit,
      );
      state = AsyncValue.data(pengumumanList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Manual refresh
  Future<void> refresh() async {
    await _loadData();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}

/// Provider untuk semua pengumuman (untuk warga) - tanpa filter user
/// dengan realtime subscription
final allPengumumanProvider =
    StateNotifierProvider<
      AllPengumumanNotifier,
      AsyncValue<List<PengumumanModel>>
    >((ref) {
      return AllPengumumanNotifier(ref.read(pengumumanServiceProvider), ref);
    });

class AllPengumumanNotifier
    extends StateNotifier<AsyncValue<List<PengumumanModel>>> {
  AllPengumumanNotifier(this._service, this._ref)
    : super(const AsyncValue.loading()) {
    _setupRealtimeSubscription();
    loadAllPengumuman();
  }

  final PengumumanService _service;
  final Ref _ref;
  String? _searchQuery;
  RealtimeChannel? _realtimeChannel;

  /// Setup realtime subscription untuk auto-refresh
  void _setupRealtimeSubscription() {
    _realtimeChannel = Supabase.instance.client
        .channel(AppConstants.realtimeChannelPengumumanAll)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pengumuman',
          callback: (payload) {
            // Refresh data ketika ada perubahan
            refresh();
          },
        )
        .subscribe();
  }

  /// Load semua pengumuman (untuk warga - tidak ada filter user)
  Future<void> loadAllPengumuman({String? searchQuery}) async {
    _searchQuery = searchQuery;

    state = const AsyncValue.loading();
    try {
      final pengumumanList = await _service.getAllPengumuman(
        searchQuery: searchQuery,
        createdByCurrentUser: false, // Tampilkan semua pengumuman
      );
      state = AsyncValue.data(pengumumanList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadAllPengumuman(searchQuery: _searchQuery);
  }

  /// Search pengumuman
  void search(String query) {
    loadAllPengumuman(searchQuery: query.isEmpty ? null : query);
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}

/// Provider untuk form state (create/edit)
final pengumumanFormProvider =
    StateNotifierProvider<PengumumanFormNotifier, PengumumanFormState>((ref) {
      return PengumumanFormNotifier(ref.read(pengumumanServiceProvider), ref);
    });

class PengumumanFormState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final PengumumanModel? pengumumanData;

  PengumumanFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.pengumumanData,
  });

  PengumumanFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    PengumumanModel? pengumumanData,
  }) {
    return PengumumanFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      pengumumanData: pengumumanData ?? this.pengumumanData,
    );
  }
}

class PengumumanFormNotifier extends StateNotifier<PengumumanFormState> {
  PengumumanFormNotifier(this._service, this._ref)
    : super(PengumumanFormState());

  final PengumumanService _service;
  final Ref _ref;

  /// Create pengumuman
  Future<void> createPengumuman({
    required String judul,
    required String isi,
    String? fotoUrl,
    String? dokumenUrl,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final pengumuman = await _service.createPengumuman(
        judul: judul,
        isi: isi,
        fotoUrl: fotoUrl,
        dokumenUrl: dokumenUrl,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        pengumumanData: pengumuman,
      );

      // Refresh all providers untuk realtime update
      _ref.read(pengumumanListProvider.notifier).refresh();
      _ref.read(allPengumumanProvider.notifier).refresh();
      _ref.read(pengumumanAktifProvider.notifier).refresh();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Update pengumuman
  Future<void> updatePengumuman({
    required int id,
    String? judul,
    String? isi,
    String? fotoUrl,
    String? dokumenUrl,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final pengumuman = await _service.updatePengumuman(
        id: id,
        judul: judul,
        isi: isi,
        fotoUrl: fotoUrl,
        dokumenUrl: dokumenUrl,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        pengumumanData: pengumuman,
      );

      // Refresh all providers untuk realtime update
      _ref.read(pengumumanListProvider.notifier).refresh();
      _ref.read(allPengumumanProvider.notifier).refresh();
      _ref.read(pengumumanAktifProvider.notifier).refresh();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Delete pengumuman
  Future<void> deletePengumuman(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.deletePengumuman(id);

      state = state.copyWith(isLoading: false, isSuccess: true);

      // Refresh all providers untuk realtime update
      _ref.read(pengumumanListProvider.notifier).refresh();
      _ref.read(allPengumumanProvider.notifier).refresh();
      _ref.read(pengumumanAktifProvider.notifier).refresh();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Reset state
  void reset() {
    state = PengumumanFormState();
  }
}

/// Provider untuk check permission
final canManagePengumumanProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(pengumumanServiceProvider);
  return await service.canManagePengumuman();
});

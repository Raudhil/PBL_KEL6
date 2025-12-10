import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pengumuman_service.dart';
import '../../data/models/pengumuman_model.dart';

/// Service provider
final pengumumanServiceProvider = Provider<PengumumanService>((ref) {
  return PengumumanService();
});

/// Provider untuk list pengumuman user yang login
final pengumumanListProvider =
    StateNotifierProvider<
      PengumumanListNotifier,
      AsyncValue<List<PengumumanModel>>
    >((ref) {
      return PengumumanListNotifier(ref.read(pengumumanServiceProvider));
    });

class PengumumanListNotifier
    extends StateNotifier<AsyncValue<List<PengumumanModel>>> {
  PengumumanListNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPengumuman();
  }

  final PengumumanService _service;
  String? _searchQuery;

  /// Load pengumuman milik user yang login
  Future<void> loadPengumuman({String? searchQuery}) async {
    _searchQuery = searchQuery;
    state = const AsyncValue.loading();

    try {
      final pengumumanList = await _service.getAllPengumuman(
        searchQuery: searchQuery,
        createdByCurrentUser: true,
      );
      state = AsyncValue.data(pengumumanList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Search pengumuman
  void search(String query) {
    loadPengumuman(searchQuery: query.isEmpty ? null : query);
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

/// Provider untuk pengumuman aktif (dashboard) - 5 pengumuman terbaru
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
    _loadData();
  }

  final PengumumanService _service;

  /// Load data pengumuman aktif
  Future<void> _loadData() async {
    try {
      final pengumumanList = await _service.getPengumumanAktif(limit: 5);
      state = AsyncValue.data(pengumumanList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider untuk semua pengumuman (untuk warga)
final allPengumumanProvider =
    StateNotifierProvider<
      AllPengumumanNotifier,
      AsyncValue<List<PengumumanModel>>
    >((ref) {
      return AllPengumumanNotifier(ref.read(pengumumanServiceProvider));
    });

class AllPengumumanNotifier
    extends StateNotifier<AsyncValue<List<PengumumanModel>>> {
  AllPengumumanNotifier(this._service) : super(const AsyncValue.loading()) {
    loadAllPengumuman();
  }

  final PengumumanService _service;
  String? _searchQuery;

  /// Load semua pengumuman
  Future<void> loadAllPengumuman({String? searchQuery}) async {
    _searchQuery = searchQuery;
    state = const AsyncValue.loading();

    try {
      final pengumumanList = await _service.getAllPengumuman(
        searchQuery: searchQuery,
        createdByCurrentUser: false,
      );
      state = AsyncValue.data(pengumumanList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Search pengumuman
  void search(String query) {
    loadAllPengumuman(searchQuery: query.isEmpty ? null : query);
  }
}

/// Provider untuk form state (create/edit)
final pengumumanFormProvider =
    StateNotifierProvider<PengumumanFormNotifier, PengumumanFormState>((ref) {
      return PengumumanFormNotifier(ref.read(pengumumanServiceProvider));
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
  PengumumanFormNotifier(this._service) : super(PengumumanFormState());

  final PengumumanService _service;

  /// Create pengumuman
  void createPengumuman({
    required String judul,
    required String isi,
    String? fotoUrl,
    String? dokumenUrl,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.createPengumuman(
        judul: judul,
        isi: isi,
        fotoUrl: fotoUrl,
        dokumenUrl: dokumenUrl,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Update pengumuman
  void updatePengumuman({
    required int id,
    String? judul,
    String? isi,
    String? fotoUrl,
    String? dokumenUrl,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.updatePengumuman(
        id: id,
        judul: judul,
        isi: isi,
        fotoUrl: fotoUrl,
        dokumenUrl: dokumenUrl,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Delete pengumuman
  deletePengumuman(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _service.deletePengumuman(id);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Reset form state
  void resetFormState() {
    state = PengumumanFormState();
  }
}

/// Provider untuk check permission
final canManagePengumumanProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(pengumumanServiceProvider);
  return await service.canManagePengumuman();
});

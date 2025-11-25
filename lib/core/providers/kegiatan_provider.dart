import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/kegiatan_model.dart';
import '../services/kegiatan_service.dart';
import '../services/user_info_service.dart';

/// Provider untuk KegiatanService
final kegiatanServiceProvider = Provider<KegiatanService>((ref) {
  return KegiatanService();
});

/// Provider untuk UserInfoService
final userInfoServiceProvider = Provider<UserInfoService>((ref) {
  return UserInfoService();
});

/// Provider untuk list kegiatan dengan filter
final kegiatanListProvider =
    StateNotifierProvider<
      KegiatanListNotifier,
      AsyncValue<List<KegiatanModel>>
    >((ref) {
      final service = ref.watch(kegiatanServiceProvider);
      return KegiatanListNotifier(service);
    });

/// Notifier untuk manage list kegiatan
class KegiatanListNotifier
    extends StateNotifier<AsyncValue<List<KegiatanModel>>> {
  final KegiatanService _service;

  KegiatanListNotifier(this._service) : super(const AsyncValue.loading()) {
    loadKegiatan();
  }

  /// Filter state
  StatusKegiatan? _statusFilter;
  KategoriKegiatan? _kategoriFilter;
  String? _searchQuery;
  bool _createdByCurrentUser = false;

  /// Load kegiatan dengan filter
  Future<void> loadKegiatan({bool? createdByCurrentUser}) async {
    if (createdByCurrentUser != null) {
      _createdByCurrentUser = createdByCurrentUser;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.getAllKegiatan(
        status: _statusFilter,
        kategori: _kategoriFilter,
        searchQuery: _searchQuery,
        createdByCurrentUser: _createdByCurrentUser,
      ),
    );
  }

  /// Set created by current user filter
  void setCreatedByCurrentUser(bool value) {
    _createdByCurrentUser = value;
    loadKegiatan();
  }

  /// Set filter status
  void setStatusFilter(StatusKegiatan? status) {
    _statusFilter = status;
    loadKegiatan();
  }

  /// Set filter kategori
  void setKategoriFilter(KategoriKegiatan? kategori) {
    _kategoriFilter = kategori;
    loadKegiatan();
  }

  /// Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    loadKegiatan();
  }

  /// Clear all filters
  void clearFilters() {
    _statusFilter = null;
    _kategoriFilter = null;
    _searchQuery = null;
    loadKegiatan();
  }

  /// Delete kegiatan
  Future<void> deleteKegiatan(String id) async {
    try {
      await _service.deleteKegiatan(id);
      loadKegiatan();
    } catch (e) {
      throw Exception('Gagal menghapus kegiatan: $e');
    }
  }

  /// Update status kegiatan
  Future<void> updateStatus(String id, StatusKegiatan status) async {
    try {
      await _service.updateStatusKegiatan(id, status);
      loadKegiatan();
    } catch (e) {
      throw Exception('Gagal mengupdate status: $e');
    }
  }
}

/// Provider untuk detail kegiatan by ID
final kegiatanDetailProvider = FutureProvider.autoDispose
    .family<KegiatanModel?, String>((ref, id) async {
      final service = ref.watch(kegiatanServiceProvider);
      return service.getKegiatanById(id);
    });

/// Provider untuk upcoming kegiatan (dashboard)
final upcomingKegiatanProvider =
    FutureProvider.autoDispose<List<KegiatanModel>>((ref) async {
      final service = ref.watch(kegiatanServiceProvider);
      return service.getUpcomingKegiatan(limit: 5);
    });

/// Provider untuk stream realtime kegiatan
final kegiatanStreamProvider = StreamProvider.autoDispose<List<KegiatanModel>>((
  ref,
) {
  final service = ref.watch(kegiatanServiceProvider);
  return service.watchKegiatan();
});

/// Provider untuk form state (create/edit)
final kegiatanFormProvider =
    StateNotifierProvider.autoDispose<KegiatanFormNotifier, KegiatanFormState>((
      ref,
    ) {
      final service = ref.watch(kegiatanServiceProvider);
      return KegiatanFormNotifier(service);
    });

/// State untuk form kegiatan
class KegiatanFormState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final KegiatanModel? kegiatan;

  KegiatanFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.kegiatan,
  });

  KegiatanFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    KegiatanModel? kegiatan,
  }) {
    return KegiatanFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      kegiatan: kegiatan ?? this.kegiatan,
    );
  }
}

/// Notifier untuk form kegiatan
class KegiatanFormNotifier extends StateNotifier<KegiatanFormState> {
  final KegiatanService _service;

  KegiatanFormNotifier(this._service) : super(KegiatanFormState());

  /// Create kegiatan baru
  Future<void> createKegiatan({
    required String judul,
    String? deskripsi,
    required DateTime tanggalMulai,
    DateTime? tanggalSelesai,
    String? lokasi,
    required String penyelenggara,
    required KategoriKegiatan kategori,
    required StatusKegiatan status,
    int? kuotaPeserta,
    String? fotoUrl,
  }) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );

    try {
      final kegiatan = await _service.createKegiatan(
        judul: judul,
        deskripsi: deskripsi,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        lokasi: lokasi,
        penyelenggara: penyelenggara,
        kategori: kategori,
        status: status,
        kuotaPeserta: kuotaPeserta,
        fotoUrl: fotoUrl,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        kegiatan: kegiatan,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update kegiatan
  Future<void> updateKegiatan({
    required String id,
    String? judul,
    String? deskripsi,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    String? lokasi,
    String? penyelenggara,
    KategoriKegiatan? kategori,
    StatusKegiatan? status,
    int? kuotaPeserta,
    String? fotoUrl,
  }) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );

    try {
      final kegiatan = await _service.updateKegiatan(
        id: id,
        judul: judul,
        deskripsi: deskripsi,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        lokasi: lokasi,
        penyelenggara: penyelenggara,
        kategori: kategori,
        status: status,
        kuotaPeserta: kuotaPeserta,
        fotoUrl: fotoUrl,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        kegiatan: kegiatan,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset form state
  void reset() {
    state = KegiatanFormState();
  }
}

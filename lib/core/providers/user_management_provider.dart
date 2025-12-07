import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_model.dart';
import '../services/user_management_service.dart';

/// Provider untuk UserManagementService
final userManagementServiceProvider = Provider<UserManagementService>((ref) {
  return UserManagementService();
});

/// Provider untuk list users
final userListProvider =
    StateNotifierProvider<UserListNotifier, AsyncValue<List<UserModel>>>((ref) {
      final service = ref.watch(userManagementServiceProvider);
      return UserListNotifier(service);
    });

/// Notifier untuk manage user list
class UserListNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserManagementService _service;
  RealtimeChannel? _realtimeChannel;

  UserListNotifier(this._service) : super(const AsyncValue.loading()) {
    _setupRealtimeSubscription();
    loadUsers();
  }

  StatusUser? _statusFilter;
  int? _roleFilter;

  /// Setup realtime subscription untuk auto-refresh
  void _setupRealtimeSubscription() {
    _realtimeChannel = Supabase.instance.client
        .channel('users_realtime_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          callback: (payload) {
            // Refresh data ketika ada perubahan
            loadUsers();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  /// Load users dengan filter
  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.getAllUsers(
        statusFilter: _statusFilter,
        roleFilter: _roleFilter,
      ),
    );
  }

  /// Set status filter
  void setStatusFilter(StatusUser? status) {
    _statusFilter = status;
    loadUsers();
  }

  /// Set role filter
  void setRoleFilter(int? roleId) {
    _roleFilter = roleId;
    loadUsers();
  }

  /// Clear filters
  void clearFilters() {
    _statusFilter = null;
    _roleFilter = null;
    loadUsers();
  }

  /// Update user status
  Future<void> updateUserStatus(int userId, StatusUser status) async {
    try {
      await _service.updateUserStatus(userId, status);
      // Data akan otomatis refresh via realtime subscription
    } catch (e) {
      throw Exception('Gagal mengupdate status: $e');
    }
  }

  /// Update user role
  Future<void> updateUserRole(int userId, int roleId) async {
    try {
      await _service.updateUserRole(userId, roleId);
      // Data akan otomatis refresh via realtime subscription
    } catch (e) {
      throw Exception('Gagal mengupdate role: $e');
    }
  }
}

/// Provider untuk user detail by ID
final userDetailProvider = FutureProvider.autoDispose.family<UserModel?, int>((
  ref,
  userId,
) async {
  final service = ref.watch(userManagementServiceProvider);
  return service.getUserById(userId);
});

/// Provider untuk list roles
final rolesProvider = FutureProvider.autoDispose<List<RoleModel>>((ref) async {
  final service = ref.watch(userManagementServiceProvider);
  return service.getAllRoles();
});

/// Provider untuk register form (validasi NIK untuk registrasi warga)
final createUserFormProvider =
    StateNotifierProvider.autoDispose<
      CreateUserFormNotifier,
      CreateUserFormState
    >((ref) {
      final service = ref.watch(userManagementServiceProvider);
      return CreateUserFormNotifier(service);
    });

/// State untuk register form
class CreateUserFormState {
  final bool isLoading;
  final String? errorMessage;
  final WargaModel? wargaData;

  CreateUserFormState({
    this.isLoading = false,
    this.errorMessage,
    this.wargaData,
  });

  CreateUserFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    WargaModel? wargaData,
  }) {
    return CreateUserFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      wargaData: wargaData ?? this.wargaData,
    );
  }
}

/// Notifier untuk register form
class CreateUserFormNotifier extends StateNotifier<CreateUserFormState> {
  final UserManagementService _service;

  CreateUserFormNotifier(this._service) : super(CreateUserFormState());

  /// Search warga by NIK untuk registrasi
  Future<void> searchWargaByNik(String nik) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      wargaData: null,
    );

    try {
      final warga = await _service.searchWargaByNik(nik);

      if (warga == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'NIK tidak ditemukan dalam sistem',
        );
        return;
      }

      // Check if warga already has user
      final hasUser = await _service.checkWargaHasUser(warga.id);
      if (hasUser) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'NIK sudah terdaftar sebagai user',
        );
        return;
      }

      state = state.copyWith(isLoading: false, wargaData: warga);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Reset form
  void reset() {
    state = CreateUserFormState();
  }
}

/// Provider untuk user statistics
final userStatisticsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final service = ref.watch(userManagementServiceProvider);
  return service.getUserStatistics();
});

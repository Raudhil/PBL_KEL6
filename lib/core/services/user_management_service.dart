import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_model.dart';

/// Service untuk manage users di admin panel
class UserManagementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all users dengan filter optional
  Future<List<UserModel>> getAllUsers({
    StatusUser? statusFilter,
    int? roleFilter,
  }) async {
    try {
      var query = _supabase.from('users').select('''
        *,
        role:id_role(id, nama),
        warga:id_warga(id, id_kk, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, nomor_hp, foto_ktp)
      ''');

      // Apply filters if provided
      if (statusFilter != null) {
        query = query.eq('status', statusFilter.value);
      }
      if (roleFilter != null) {
        query = query.eq('id_role', roleFilter);
      }

      final response = await query.order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data users: $e');
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(int id) async {
    try {
      final response = await _supabase
          .from('users')
          .select('''
        *,
        role:id_role(id, nama),
        warga:id_warga(id, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, nomor_hp, foto_ktp)
      ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail user: $e');
    }
  }

  /// Get all roles
  Future<List<RoleModel>> getAllRoles() async {
    try {
      final response = await _supabase.from('role').select().order('nama');
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => RoleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data role: $e');
    }
  }

  /// Search warga by NIK (untuk registrasi)
  Future<WargaModel?> searchWargaByNik(String nik) async {
    try {
      final response = await _supabase
          .from('warga')
          .select('''
            *,
            kk!inner(
              id_alamat,
              alamat!inner(
                alamat
              )
            )
          ''')
          .eq('nik', nik)
          .maybeSingle();
      if (response == null) return null;

      // Extract alamat from nested structure
      final Map<String, dynamic> wargaData = Map<String, dynamic>.from(
        response,
      );
      if (response['kk'] != null && response['kk']['alamat'] != null) {
        wargaData['alamat'] = response['kk']['alamat']['alamat'];
      }

      return WargaModel.fromJson(wargaData);
    } catch (e) {
      throw Exception('Gagal mencari data warga: $e');
    }
  }

  /// Check if warga already has user account
  Future<bool> checkWargaHasUser(int idWarga) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('id_warga', idWarga)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Gagal mengecek user warga: $e');
    }
  }

  /// Update user status
  Future<UserModel> updateUserStatus(int userId, StatusUser status) async {
    try {
      final response = await _supabase
          .from('users')
          .update({
            'status': status.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select('''
            *,
            role:id_role(id, nama),
            warga:id_warga(id, id_kk, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, nomor_hp, foto_ktp)
          ''')
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate status user: $e');
    }
  }

  /// Update user role
  Future<UserModel> updateUserRole(int userId, int newRoleId) async {
    try {
      final response = await _supabase
          .from('users')
          .update({
            'id_role': newRoleId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select('''
            *,
            role:id_role(id, nama),
            warga:id_warga(id, id_kk, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, nomor_hp, foto_ktp)
          ''')
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate role user: $e');
    }
  }

  /// Delete user (soft delete)
  Future<void> deleteUser(int userId) async {
    try {
      await updateUserStatus(userId, StatusUser.tidakAktif);
    } catch (e) {
      throw Exception('Gagal menghapus user: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, int>> getUserStatistics() async {
    try {
      final allUsers = await _supabase.from('users').select('status, id_role');

      int totalUsers = allUsers.length;
      int activeUsers = allUsers.where((u) => u['status'] == 'Aktif').length;
      int inactiveUsers = totalUsers - activeUsers;

      return {
        'total': totalUsers,
        'active': activeUsers,
        'inactive': inactiveUsers,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik user: $e');
    }
  }
}

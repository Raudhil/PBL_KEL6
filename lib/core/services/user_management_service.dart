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

  /// Search warga by NIK
  Future<WargaModel?> searchWargaByNik(String nik) async {
    try {
      final response = await _supabase
          .from('warga')
          .select()
          .eq('nik', nik)
          .maybeSingle();
      if (response == null) return null;
      return WargaModel.fromJson(response);
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

  /// Create new user (buat di auth.users DAN public.users)
  Future<UserModel> createUser({
    required String nik,
    required int idRole,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Cari warga berdasarkan NIK
      final warga = await searchWargaByNik(nik);
      if (warga == null) {
        throw Exception('NIK tidak terdaftar dalam sistem');
      }

      // 2. Cek apakah warga sudah punya user
      final hasUser = await checkWargaHasUser(warga.id);
      if (hasUser) {
        throw Exception('NIK sudah terdaftar sebagai user');
      }

      // 3. Simpan admin session sebelum signUp
      final currentSession = _supabase.auth.currentSession;
      if (currentSession == null) {
        throw Exception('Admin session tidak ditemukan');
      }
      final adminRefreshToken = currentSession.refreshToken!;

      String? authUserId;

      // 4. Create auth user dengan signUp (buat di auth.users)
      try {
        final authResponse = await _supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (authResponse.user == null) {
          throw Exception('Gagal membuat akun autentikasi');
        }

        authUserId = authResponse.user!.id;
        print('✅ Auth user created: $authUserId');

        // 5. RESTORE admin session SEGERA setelah signUp
        await _supabase.auth.setSession(adminRefreshToken);
        print('✅ Admin session restored');
      } catch (e) {
        // Restore admin session jika error
        try {
          await _supabase.auth.setSession(adminRefreshToken);
        } catch (_) {}
        throw Exception('Gagal membuat akun autentikasi: $e');
      }

      // 6. Create user di tabel public.users (sinkronisasi dengan auth.users)
      final userData = {
        'id_auth': authUserId,
        'id_role': idRole,
        'id_warga': warga.id,
        'full_name': warga.namaLengkap,
        'status': 'Aktif',
      };

      print('📝 Inserting to public.users: $userData');

      final response = await _supabase.from('users').insert(userData).select('''
        *,
        role:id_role(id, nama),
        warga:id_warga(id, id_kk, nik, nama_lengkap, jenis_kelamin, tanggal_lahir, nomor_hp, foto_ktp)
      ''').single();

      print('✅ User created in public.users');

      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ Error creating user: $e');
      throw Exception('Gagal membuat user: $e');
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

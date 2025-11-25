import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk mendapatkan informasi user pembuat kegiatan
class UserInfoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get user info by ID dari tabel users (public schema)
  /// Schema: users.id_auth (UUID) → auth.users(id)
  /// Returns: {id_auth, full_name, role_name}
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id_auth, full_name, role:id_role(nama)')
          .eq('id_auth', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error in getUserInfo: $e');
      return null;
    }
  }

  /// Get nama user by ID
  Future<String> getUserName(String userId) async {
    try {
      print('🔍 Getting user name for ID: $userId');

      final response = await _supabase
          .from('users')
          .select('full_name')
          .eq('id_auth', userId)
          .maybeSingle();

      print('📦 Response from users: $response');

      if (response != null && response['full_name'] != null) {
        final nama = response['full_name'] as String;
        print('✅ Found full_name: $nama');
        return nama;
      }

      print('⚠️ User not found in users table');

      // Fallback: ambil email dari auth.users()
      final currentUser = _supabase.auth.currentUser;
      if (currentUser?.id == userId) {
        final emailName =
            currentUser?.email?.split('@').first ?? 'Unknown User';
        print('🔄 Using email fallback: $emailName');
        return emailName;
      }

      print('❌ No fallback available');
      return 'Unknown User';
    } catch (e) {
      print('❌ Error getting user name for $userId: $e');
      return 'Unknown User';
    }
  }

  /// Get role user by ID
  Future<String?> getUserRole(String userId) async {
    try {
      final userInfo = await getUserInfo(userId);
      if (userInfo == null) return null;

      // Response structure: {role: {nama: 'admin'}}
      final roleData = userInfo['role'] as Map<String, dynamic>?;
      return roleData?['nama'] as String?;
    } catch (e) {
      print('❌ Error in getUserRole: $e');
      return null;
    }
  }

  /// Get current user info
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      return await getUserInfo(userId);
    } catch (e) {
      return null;
    }
  }

  /// Get current user role
  Future<String?> getCurrentUserRole() async {
    try {
      final userInfo = await getCurrentUserInfo();
      if (userInfo == null) return null;

      // Response structure: {role: {nama: 'admin'}}
      final roleData = userInfo['role'] as Map<String, dynamic>?;
      return roleData?['nama'] as String?;
    } catch (e) {
      print('❌ Error in getCurrentUserRole: $e');
      return null;
    }
  }

  /// Check if current user can edit/delete kegiatan
  /// Rules:
  /// - Admin dapat edit/delete semua
  /// - Creator dapat edit/delete kegiatan sendiri
  /// - Sekretaris, Bendahara, RT hanya bisa edit/delete kegiatan sendiri
  Future<bool> canEditKegiatan(String kegiatanCreatedBy) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      final userInfo = await getCurrentUserInfo();
      if (userInfo == null) return false;

      // Get role nama from nested structure
      final roleData = userInfo['role'] as Map<String, dynamic>?;
      final role = (roleData?['nama'] as String?)?.toLowerCase();

      // Admin bisa edit semua
      if (role == 'admin') return true;

      // Creator bisa edit kegiatan sendiri
      if (currentUser.id == kegiatanCreatedBy) return true;

      return false;
    } catch (e) {
      print('❌ Error in canEditKegiatan: $e');
      return false;
    }
  }

  /// Check if current user can delete kegiatan
  /// Rules sama dengan edit
  Future<bool> canDeleteKegiatan(String kegiatanCreatedBy) async {
    return canEditKegiatan(kegiatanCreatedBy);
  }

  /// Check if current user has role untuk akses fitur kegiatan
  /// Allowed roles: sekretaris, bendahara, rt, admin
  Future<bool> canAccessKegiatanFeature() async {
    try {
      final role = await getCurrentUserRole();
      if (role == null) return false;

      final allowedRoles = ['sekretaris', 'bendahara', 'rt', 'admin'];
      return allowedRoles.contains(role.toLowerCase());
    } catch (e) {
      return false;
    }
  }
}

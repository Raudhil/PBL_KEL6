import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/pengumuman_model.dart';

class PengumumanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Storage bucket untuk file pengumuman
  static const String _storageBucket = 'pengumuman';

  /// Get all pengumuman dengan filter opsional
  Future<List<PengumumanModel>> getAllPengumuman({
    String? searchQuery,
    bool createdByCurrentUser = false,
  }) async {
    try {
      var query = _supabase.from('pengumuman').select('''
        *,
        pembuat:id_pembuat(
          id,
          full_name,
          role:id_role(nama)
        )
      ''');

      // Filter berdasarkan created_by (hanya pengumuman user yang login)
      if (createdByCurrentUser) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          query = query.eq('id_pembuat', userId);
        }
      }

      // Filter berdasarkan search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('judul.ilike.%$searchQuery%,isi.ilike.%$searchQuery%');
      }

      final response = await query.order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => PengumumanModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data pengumuman: $e');
    }
  }

  /// Get pengumuman by ID
  Future<PengumumanModel?> getPengumumanById(int id) async {
    try {
      final response = await _supabase
          .from('pengumuman')
          .select('''
        *,
        pembuat:id_pembuat(
          id,
          full_name,
          role:id_role(nama)
        )
      ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return PengumumanModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail pengumuman: $e');
    }
  }

  /// Get pengumuman aktif (untuk dashboard warga)
  Future<List<PengumumanModel>> getPengumumanAktif({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('pengumuman')
          .select('''
        *,
        pembuat:id_pembuat(
          id,
          full_name,
          role:id_role(nama)
        )
      ''')
          .order('created_at', ascending: false)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => PengumumanModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil pengumuman aktif: $e');
    }
  }

  /// Get pengumuman yang dibuat oleh user tertentu
  Future<List<PengumumanModel>> getMyPengumuman(int userId) async {
    try {
      final response = await _supabase
          .from('pengumuman')
          .select('''
        *,
        pembuat:id_pembuat(
          id,
          full_name,
          role:id_role(nama)
        )
      ''')
          .eq('id_pembuat', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => PengumumanModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil pengumuman saya: $e');
    }
  }

  /// Create pengumuman baru
  Future<PengumumanModel> createPengumuman({
    required String judul,
    required String isi,
    String? fotoUrl,
    String? dokumenUrl,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User belum login');
      }

      final now = DateTime.now().toIso8601String();
      final pengumumanData = {
        'judul': judul,
        'isi': isi,
        'foto_url': fotoUrl,
        'dokumen_url': dokumenUrl,
        'id_pembuat': userId,
        'created_at': now,
        'updated_at': now,
      };

      final response = await _supabase
          .from('pengumuman')
          .insert(pengumumanData)
          .select('''
        *,
        pembuat:id_pembuat(
          id,
          full_name,
          role:id_role(nama)
        )
      ''')
          .single();

      return PengumumanModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat pengumuman: $e');
    }
  }

  /// Update pengumuman
  Future<PengumumanModel> updatePengumuman({
    required int id,
    String? judul,
    String? isi,
    String? fotoUrl,
    String? dokumenUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update field dengan validasi proper
      if (judul != null && judul.isNotEmpty) {
        updateData['judul'] = judul;
      }
      if (isi != null && isi.isNotEmpty) {
        updateData['isi'] = isi;
      }

      // Untuk URL, null atau empty string akan di-set sebagai null di database
      // Tapi jika ada value, gunakan value tersebut
      updateData['foto_url'] = (fotoUrl != null && fotoUrl.isNotEmpty)
          ? fotoUrl
          : null;
      updateData['dokumen_url'] = (dokumenUrl != null && dokumenUrl.isNotEmpty)
          ? dokumenUrl
          : null;

      final response = await _supabase
          .from('pengumuman')
          .update(updateData)
          .eq('id', id)
          .select('''
        *,
        pembuat:id_pembuat(
          id,
          full_name,
          role:id_role(nama)
        )
      ''')
          .single();

      return PengumumanModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate pengumuman: $e');
    }
  }

  /// Delete pengumuman
  Future<void> deletePengumuman(int id) async {
    try {
      // Get pengumuman untuk hapus file-nya juga
      final pengumuman = await getPengumumanById(id);

      if (pengumuman != null) {
        // Hapus foto jika ada
        if (pengumuman.hasFoto) {
          await deleteFile(pengumuman.fotoUrl!);
        }

        // Hapus dokumen jika ada
        if (pengumuman.hasDokumen) {
          await deleteFile(pengumuman.dokumenUrl!);
        }
      }

      // Hapus data pengumuman
      await _supabase.from('pengumuman').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus pengumuman: $e');
    }
  }

  /// Upload foto ke Supabase Storage
  Future<String> uploadFoto(File file, String fileName) async {
    try {
      final bytes = await file.readAsBytes();
      final fileExt = fileName.split('.').last;
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final filePath = 'foto/$uniqueFileName';

      await _supabase.storage
          .from(_storageBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: false,
            ),
          );

      final publicUrl = _supabase.storage
          .from(_storageBucket)
          .getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Gagal mengupload foto: $e');
    }
  }

  /// Upload dokumen ke Supabase Storage
  Future<String> uploadDokumen(File file, String fileName) async {
    try {
      final bytes = await file.readAsBytes();
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final filePath = 'dokumen/$uniqueFileName';

      await _supabase.storage
          .from(_storageBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'application/pdf',
              upsert: false,
            ),
          );

      final publicUrl = _supabase.storage
          .from(_storageBucket)
          .getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Gagal mengupload dokumen: $e');
    }
  }

  /// Delete file dari storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Extract file path dari public URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;

      // Find bucket name and file path
      final bucketIndex = pathSegments.indexOf('storage');
      if (bucketIndex == -1 || bucketIndex + 3 >= pathSegments.length) {
        return; // Invalid URL, skip deletion
      }

      final filePath = pathSegments.sublist(bucketIndex + 3).join('/');

      await _supabase.storage.from(_storageBucket).remove([filePath]);
    } catch (e) {
      print('Warning: Gagal menghapus file: $e');
      // Don't throw error, just log warning
    }
  }

  /// Helper: Get current user ID dari public.users
  Future<int?> _getCurrentUserId() async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return null;

      final response = await _supabase
          .from('users')
          .select('id')
          .eq('id_auth', authUser.id)
          .maybeSingle();

      if (response == null) return null;
      return response['id'] as int;
    } catch (e) {
      return null;
    }
  }

  /// Check apakah user bisa manage pengumuman (RT, Sekretaris, Bendahara)
  Future<bool> canManagePengumuman() async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return false;

      final response = await _supabase
          .from('users')
          .select('role:id_role(nama)')
          .eq('id_auth', authUser.id)
          .maybeSingle();

      if (response == null) return false;

      final roleName =
          (response['role'] as Map<String, dynamic>)['nama'] as String;
      final allowedRoles = ['rt', 'sekretaris', 'bendahara'];

      return allowedRoles.contains(roleName.toLowerCase());
    } catch (e) {
      return false;
    }
  }
}

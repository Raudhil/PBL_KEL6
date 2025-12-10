import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../../data/models/kegiatan_model.dart';

class KegiatanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Helper untuk convert enum status ke string
  String _statusToString(StatusKegiatan status) {
    switch (status) {
      case StatusKegiatan.akanDatang:
        return 'akan_datang';
      case StatusKegiatan.sedangBerlangsung:
        return 'sedang_berlangsung';
      case StatusKegiatan.selesai:
        return 'selesai';
      case StatusKegiatan.dibatalkan:
        return 'dibatalkan';
    }
  }

  /// Helper untuk convert enum kategori ke string
  String _kategoriToString(KategoriKegiatan kategori) {
    switch (kategori) {
      case KategoriKegiatan.sosial:
        return 'sosial';
      case KategoriKegiatan.kebersihan:
        return 'kebersihan';
      case KategoriKegiatan.kesehatan:
        return 'kesehatan';
      case KategoriKegiatan.pendidikan:
        return 'pendidikan';
      case KategoriKegiatan.keagamaan:
        return 'keagamaan';
      case KategoriKegiatan.olahraga:
        return 'olahraga';
      case KategoriKegiatan.budaya:
        return 'budaya';
      case KategoriKegiatan.lainnya:
        return 'lainnya';
    }
  }

  /// Get all kegiatan dengan filter opsional
  Future<List<KegiatanModel>> getAllKegiatan({
    StatusKegiatan? status,
    KategoriKegiatan? kategori,
    String? searchQuery,
    bool createdByCurrentUser = false,
  }) async {
    try {
      PostgrestFilterBuilder query = _supabase.from('kegiatan').select();

      // Filter berdasarkan created_by (hanya kegiatan user yang login)
      if (createdByCurrentUser) {
        final userId = _supabase.auth.currentUser?.id;
        if (userId != null) {
          query = query.eq('created_by', userId);
        }
      }

      // Filter berdasarkan status
      if (status != null) {
        query = query.eq('status', _statusToString(status));
      }

      // Filter berdasarkan kategori
      if (kategori != null) {
        query = query.eq('kategori', _kategoriToString(kategori));
      }

      // Search berdasarkan judul atau deskripsi
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'judul.ilike.%$searchQuery%,deskripsi.ilike.%$searchQuery%',
        );
      }

      final response = await query.order('tanggal_mulai', ascending: false);
      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((json) => KegiatanModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data kegiatan: $e');
    }
  }

  /// Get kegiatan by ID
  Future<KegiatanModel?> getKegiatanById(String id) async {
    try {
      final response = await _supabase
          .from('kegiatan')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return KegiatanModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail kegiatan: $e');
    }
  }

  /// Create kegiatan baru
  Future<KegiatanModel> createKegiatan({
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
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      final data = {
        'judul': judul,
        'deskripsi': deskripsi,
        'tanggal_mulai': tanggalMulai.toIso8601String(),
        'tanggal_selesai': tanggalSelesai?.toIso8601String(),
        'lokasi': lokasi,
        'penyelenggara': penyelenggara,
        'kategori': _kategoriToString(kategori),
        'status': _statusToString(status),
        'kuota_peserta': kuotaPeserta,
        'foto_url': fotoUrl,
        'created_by': userId,
      };

      final response = await _supabase
          .from('kegiatan')
          .insert(data)
          .select()
          .single();

      return KegiatanModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat kegiatan: $e');
    }
  }

  /// Update kegiatan
  Future<KegiatanModel> updateKegiatan({
    required String id,
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
    try {
      final data = <String, dynamic>{
        'judul': judul,
        'deskripsi': deskripsi,
        'tanggal_mulai': tanggalMulai.toIso8601String(),
        'tanggal_selesai': tanggalSelesai?.toIso8601String(),
        'lokasi': lokasi,
        'penyelenggara': penyelenggara,
        'kategori': _kategoriToString(kategori),
        'status': _statusToString(status),
        'kuota_peserta': kuotaPeserta,
        'foto_url': fotoUrl,
      };

      final response = await _supabase
          .from('kegiatan')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return KegiatanModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate kegiatan: $e');
    }
  }

  /// Delete kegiatan
  Future<void> deleteKegiatan(String id) async {
    try {
      await _supabase.from('kegiatan').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus kegiatan: $e');
    }
  }

  /// Stream untuk realtime updates
  Stream<List<KegiatanModel>> watchKegiatan() {
    return _supabase
        .from('kegiatan')
        .stream(primaryKey: ['id'])
        .order('tanggal_mulai', ascending: false)
        .map((data) {
          return data.map((json) => KegiatanModel.fromJson(json)).toList();
        });
  }

  /// Stream untuk realtime updates (hanya kegiatan user yang login)
  Stream<List<KegiatanModel>> watchKegiatanByUser() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('kegiatan')
        .stream(primaryKey: ['id'])
        .eq('created_by', userId)
        .order('tanggal_mulai', ascending: false)
        .map((data) {
          return data.map((json) => KegiatanModel.fromJson(json)).toList();
        });
  }

  /// Get upcoming kegiatan (untuk dashboard)
  Future<List<KegiatanModel>> getUpcomingKegiatan({int limit = 5}) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('kegiatan')
          .select()
          .gte('tanggal_mulai', now)
          .order('tanggal_mulai', ascending: true)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((json) => KegiatanModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil kegiatan mendatang: $e');
    }
  }

  /// Get kegiatan by kategori
  Future<List<KegiatanModel>> getKegiatanByKategori(
    KategoriKegiatan kategori,
  ) async {
    try {
      final response = await _supabase
          .from('kegiatan')
          .select()
          .eq('kategori', _kategoriToString(kategori))
          .order('tanggal_mulai', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((json) => KegiatanModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil kegiatan berdasarkan kategori: $e');
    }
  }

  /// Update status kegiatan
  Future<KegiatanModel> updateStatusKegiatan(
    String id,
    StatusKegiatan status,
  ) async {
    try {
      final response = await _supabase
          .from('kegiatan')
          .update({'status': _statusToString(status)})
          .eq('id', id)
          .select()
          .single();

      return KegiatanModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate status kegiatan: $e');
    }
  }

  /// Upload foto kegiatan ke Supabase Storage
  Future<String> uploadFotoKegiatan(
    Uint8List imageBytes,
    String kegiatanId,
  ) async {
    try {
      final fileName =
          'kegiatan_${kegiatanId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('kegiatan-images')
          .uploadBinary(fileName, imageBytes);

      final publicUrl = _supabase.storage
          .from('kegiatan-images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload foto kegiatan: $e');
    }
  }
}

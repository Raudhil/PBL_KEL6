import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/warga_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  /// Get RT ID dari user yang sedang login
  Future<int?> getUserRtId(int userId) async {
    try {
      final result = await _client
          .from('users')
          .select('''
            id_warga,
            warga!inner(
              id_kk,
              kk!inner(
                id_alamat,
                alamat!inner(
                  id_rt
                )
              )
            )
          ''')
          .eq('id', userId)
          .maybeSingle();

      if (result == null || result['warga'] == null) {
        return null;
      }

      final warga = result['warga'];
      final kk = warga['kk'];
      final alamat = kk['alamat'];
      return alamat['id_rt'] as int?;
    } catch (e) {
      print('Error getting user RT ID: $e');
      return null;
    }
  }

  /// Fetch semua warga (untuk admin/super user)
  Future<List<WargaModel>> fetchWarga() async {
    final data = await _client.from('warga').select('''
      *,
      users!id_warga(status),
      kk!inner(
        id,
        nomor,
        alamat!inner(
          id,
          alamat,
          id_rt
        )
      )
    ''');
    final list = data as List<dynamic>;

    // Debug: Print data untuk cek struktur
    if (list.isNotEmpty) {
      print('DEBUG - Sample warga data: ${list.first}');
    }

    return list
        .map((e) => WargaModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Fetch warga berdasarkan RT (untuk warga biasa)
  Future<List<WargaModel>> fetchWargaByRT(int idRT) async {
    final data = await _client
        .from('warga')
        .select('''
      *,
      users!id_warga(status),
      kk!inner(
        id,
        nomor,
        alamat!inner(
          id,
          alamat,
          id_rt
        )
      )
    ''')
        .eq('kk.alamat.id_rt', idRT);

    final list = data as List<dynamic>;

    return list
        .map((e) => WargaModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<WargaModel> insertWarga(WargaModel warga) async {
    // Insert warga
    final inserted = await _client
        .from('warga')
        .insert(warga.toJson())
        .select()
        .single();

    // Auto-create user record dengan status 'Aktif'
    // id_auth akan di-set nanti saat warga melakukan registrasi
    final idWarga = inserted['id'] as int;
    try {
      await _client.from('users').insert({
        'id_warga': idWarga,
        'full_name': warga.namaLengkap,
        'status': 'Aktif', // Status otomatis Aktif saat dibuat RT
        'id_role': 1, // Default role Warga
        // id_auth akan null sampai user melakukan registrasi
      });
    } catch (e) {
      // Jika gagal create user, tidak perlu throw error
      // Karena warga sudah tercreate, user bisa dibuat manual nanti
      print('Warning: Gagal auto-create user untuk warga $idWarga: $e');
    }

    // Fetch ulang dengan JOIN users untuk mendapatkan status terbaru
    final result = await _client
        .from('warga')
        .select('''
      *,
      users!id_warga(status),
      kk!inner(
        id,
        nomor,
        alamat!inner(
          id,
          alamat
        )
      )
    ''')
        .eq('id', idWarga)
        .single();

    return WargaModel.fromJson(Map<String, dynamic>.from(result as Map));
  }

  Future<WargaModel> updateWarga(WargaModel warga) async {
    // Update warga
    await _client.from('warga').update(warga.toJson()).eq('id', warga.id);

    // Fetch ulang dengan JOIN users dan kk untuk mendapatkan data terbaru lengkap
    final result = await _client
        .from('warga')
        .select('''
      *,
      users!id_warga(status),
      kk!inner(
        id,
        nomor,
        alamat!inner(
          id,
          alamat
        )
      )
    ''')
        .eq('id', warga.id)
        .single();

    return WargaModel.fromJson(Map<String, dynamic>.from(result as Map));
  }

  Future<void> deleteWarga(int id) async {
    await _client.from('warga').delete().eq('id', id);
  }

  Future<bool> checkNikExists(String nik, {int? excludeId}) async {
    try {
      var query = _client.from('warga').select('id').eq('nik', nik);

      // Exclude current warga when editing
      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }

      final result = await query;
      return (result as List).isNotEmpty;
    } catch (e) {
      print('Error checking NIK: $e');
      return false;
    }
  }

  /// Check if KK already has Kepala Keluarga
  Future<Map<String, dynamic>?> getKepalaKeluargaByKK(int idKk) async {
    try {
      final result = await _client
          .from('warga')
          .select('id, nama_lengkap, nik')
          .eq('id_kk', idKk)
          .eq('peran_keluarga', 'Kepala Keluarga')
          .maybeSingle();
      return result;
    } catch (e) {
      print('Error checking Kepala Keluarga: $e');
      return null;
    }
  }

  /// Update peran keluarga warga lama saat ada kepala keluarga baru
  Future<void> updatePeranKeluarga(int wargaId, String peranBaru) async {
    try {
      await _client
          .from('warga')
          .update({
            'peran_keluarga': peranBaru,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', wargaId);
    } catch (e) {
      throw Exception('Gagal update peran keluarga: $e');
    }
  }
}

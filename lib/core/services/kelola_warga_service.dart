import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/warga_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<List<WargaModel>> fetchWarga() async {
    final data = await _client.from('warga').select('''
      *,
      users!id_warga(status)
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

  Future<WargaModel> insertWarga(WargaModel warga) async {
    // Insert warga
    final inserted = await _client
        .from('warga')
        .insert(warga.toJson())
        .select()
        .single();

    final wargaId = inserted['id'] as int;

    // Create user account with 'Aktif' status automatically
    // Check if user already exists for this warga
    final existingUser = await _client
        .from('users')
        .select('id')
        .eq('id_warga', wargaId)
        .maybeSingle();

    if (existingUser == null) {
      // Create new user with status 'Aktif'
      await _client.from('users').insert({
        'id_warga': wargaId,
        'id_role': 1, // Default role (Warga)
        'full_name': warga.namaLengkap,
        'status': 'Aktif', // Set status to Aktif by default when created by RT
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      // If user already exists, update status to Aktif
      await _client
          .from('users')
          .update({
            'status': 'Aktif',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id_warga', wargaId);
    }

    return WargaModel.fromJson(Map<String, dynamic>.from(inserted as Map));
  }

  Future<WargaModel> updateWarga(WargaModel warga) async {
    final updated = await _client
        .from('warga')
        .update(warga.toJson())
        .eq('id', warga.id)
        .select()
        .single();
    return WargaModel.fromJson(Map<String, dynamic>.from(updated as Map));
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
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/warga_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<List<WargaModel>> fetchWarga() async {
    final data = await _client.from('warga').select();
    final list = data as List<dynamic>;
    return list
        .map((e) => WargaModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<WargaModel> insertWarga(WargaModel warga) async {
    final inserted = await _client
        .from('warga')
        .insert(warga.toJson())
        .select()
        .single();
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
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/kk_model.dart';

class KKService {
  final _client = Supabase.instance.client;

  Future<List<KKModel>> fetchAllKK() async {
    final data = await _client
        .from('kk')
        .select('*, alamat!inner(id, alamat, id_rt)')
        .order('id', ascending: false);

    final list = data as List<dynamic>;
    return list
        .map((e) => KKModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<KKModel> createKK({
    required String nomorKK,
    required String alamat,
    int idRt = 1, // Default RT 1
  }) async {
    // 1. Create alamat first
    final alamatData = await _client
        .from('alamat')
        .insert({'alamat': alamat, 'id_rt': idRt})
        .select()
        .single();

    final idAlamat = alamatData['id'] as int;

    // 2. Create KK with alamat id
    final kkData = await _client
        .from('kk')
        .insert({'nomor': nomorKK, 'id_alamat': idAlamat})
        .select()
        .single();

    return KKModel.fromJson(Map<String, dynamic>.from(kkData as Map));
  }
}

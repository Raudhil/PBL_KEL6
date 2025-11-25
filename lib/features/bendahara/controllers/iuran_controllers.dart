import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/iuran_model.dart';

class IuranController extends StateNotifier<AsyncValue<List<IuranModel>>> {
  IuranController() : super(const AsyncValue.loading()) {
    fetchIuran();
  }

  final _supabase = Supabase.instance.client;

  // READ
  Future<void> fetchIuran() async {
    try {
      state = const AsyncValue.loading();
      final response = await _supabase
          .from('iuran')
          .select()
          .order('created_at', ascending: false);

      final iuranList = (response as List)
          .map((e) => IuranModel.fromJson(e))
          .toList();

      state = AsyncValue.data(iuranList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // CREATE
  Future<void> addIuran(IuranModel iuran) async {
    try {
      final authId = _supabase.auth.currentUser!.id;
      final user = await _supabase
          .from('users')
          .select('id')
          .eq('id_auth', authId)
          .single();

      final int idBendahara = user['id'];

      final data = {
        ...iuran.toJson(),
        'id_bendahara': idBendahara,
      };

      await _supabase.from('iuran').insert(data);
      await fetchIuran();
    } catch (e) {
      throw Exception('Gagal menambah iuran: $e');
    }
  }

  // UPDATE
  Future<void> updateIuran(int id, IuranModel iuran) async {
    try {
      await _supabase.from('iuran').update({
        'jenis': iuran.jenis,
        'nominal': iuran.nominal,
        'jatuh_tempo': iuran.jatuhTempo.toIso8601String(),
      }).eq('id', id);

      await fetchIuran(); // Refresh list
    } catch (e) {
      throw Exception('Gagal update iuran: $e');
    }
  }

  // DELETE
  Future<void> deleteIuran(int id) async {
    try {
      await _supabase.from('iuran').delete().eq('id', id);
      // Kita update state lokal langsung agar UI responsif tanpa fetch ulang
      state.whenData((value) {
        state = AsyncValue.data(
          value.where((element) => element.id != id).toList(),
        );
      });
    } catch (e) {
      throw Exception('Gagal menghapus iuran: $e');
    }
  }
}

final iuranControllerProvider =
    StateNotifierProvider<IuranController, AsyncValue<List<IuranModel>>>(
      (ref) => IuranController(),
    );
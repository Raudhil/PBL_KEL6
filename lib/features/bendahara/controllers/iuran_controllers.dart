import 'package:flutter/foundation.dart';
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

      final data = {...iuran.toJson(), 'id_bendahara': idBendahara};

      await _supabase.from('iuran').insert(data);
      await fetchIuran();
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE
  Future<void> updateIuran(int id, IuranModel iuran) async {
    try {
      await _supabase
          .from('iuran')
          .update({
            'jenis': iuran.jenis,
            'nominal': iuran.nominal,
            'jatuh_tempo': iuran.jatuhTempo.toIso8601String(),
          })
          .eq('id', id);

      await fetchIuran();
    } catch (e) {
      rethrow;
    }
  }

  // DELETE
  Future<void> deleteIuran(int id) async {
    try {
      if (kDebugMode) {
        print('🗑️ Deleting iuran with id: $id');
      }

      // Update state lokal dulu (optimistic update)
      final currentState = state;
      if (currentState is AsyncData) {
        final updatedList = currentState.value!
            .where((element) => element.id != id)
            .toList();
        state = AsyncValue.data(updatedList);
      }

      // PENTING: Hapus transaksi_iuran yang reference ke iuran ini dulu
      await _supabase.from('transaksi_iuran').delete().eq('id_iuran', id);

      if (kDebugMode) {
        print('✅ Deleted related transaksi_iuran');
      }

      // Baru hapus dari iuran
      await _supabase.from('iuran').delete().eq('id', id);

      if (kDebugMode) {
        print('✅ Iuran deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting iuran: $e');
      }

      // Kembalikan state sebelumnya jika error
      await fetchIuran();
      rethrow;
    }
  }
}

// Provider untuk tracking expanded card ID
final expandedIuranIdProvider = StateProvider<int?>((ref) => null);

final iuranControllerProvider =
    StateNotifierProvider<IuranController, AsyncValue<List<IuranModel>>>(
      (ref) => IuranController(),
    );

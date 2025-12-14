import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/data/models/keuangan_model.dart';

class KeuanganService {
  final _supabase = Supabase.instance.client;

  Future<List<KeuanganModel>> fetchTransactions({
    int limit = 50,
    int? idRt,
  }) async {
    final query = _supabase.from('keuangan').select();
    if (idRt != null) {
      query.eq('id_rt', idRt);
    }
    final dynamic resp = await query
        .order('created_at', ascending: false)
        .limit(limit);

    // Supabase client may return either a List or a Map containing 'data'.
    List rows;
    if (resp is Map && resp.containsKey('data')) {
      rows = resp['data'] as List;
    } else if (resp is List) {
      rows = resp;
    } else {
      rows = [];
    }

    final list = rows
        .map((e) => KeuanganModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return list;
  }

  Future<void> addTransaction(KeuanganModel tx, {int? idRt}) async {
    final data = tx.toJson();
    // Include id_rt if provided by the caller. The database enforces a NOT
    // NULL constraint on `id_rt`, so callers should pass the RT id.
    if (idRt != null) {
      data['id_rt'] = idRt;
    }
    await _supabase.from('keuangan').insert(data);
  }

  Future<void> updateTransaction(int id, KeuanganModel tx) async {
    final data = tx.toJson();
    // Add updated_at timestamp
    data['updated_at'] = DateTime.now().toIso8601String();

    await _supabase.from('keuangan').update(data).eq('id', id);
  }

  Future<void> deleteTransaction(int id) async {
    await _supabase.from('keuangan').delete().eq('id', id);
  }

  /// Fetch totals using client-side aggregation. For large datasets consider
  /// moving aggregation to the database via RPC or SQL.
  Future<Map<String, double>> fetchTotals({int? idRt}) async {
    final query = _supabase.from('keuangan').select();
    if (idRt != null) query.eq('id_rt', idRt);
    final dynamic resp = await query;

    List rows;
    if (resp is Map && resp.containsKey('data')) {
      rows = resp['data'] as List;
    } else if (resp is List) {
      rows = resp;
    } else {
      rows = [];
    }

    final list = rows
        .map((e) => KeuanganModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    double pemasukan = 0.0;
    double pengeluaran = 0.0;
    for (final t in list) {
      // Use normalized type if available; otherwise fallback to sign
      final type = t.type?.trim().toLowerCase();
      if (type != null) {
        if (type == 'pemasukan') {
          pemasukan += t.amount;
        } else if (type == 'pengeluaran') {
          pengeluaran += t.amount.abs();
        } else {
          // Unknown type -> fallback to sign
          if (t.amount >= 0) {
            pemasukan += t.amount;
          } else {
            pengeluaran += t.amount.abs();
          }
        }
      } else {
        if (t.amount >= 0) {
          pemasukan += t.amount;
        } else {
          pengeluaran += t.amount.abs();
        }
      }
    }
    final total = pemasukan - pengeluaran;
    return {'total': total, 'pemasukan': pemasukan, 'pengeluaran': pengeluaran};
  }
}

final keuanganServiceProvider = Provider((ref) => KeuanganService());

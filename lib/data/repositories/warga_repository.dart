import '../../core/services/supabase_service.dart';
import '../models/warga_model.dart';

class WargaRepository {
  final SupabaseService _service;
  WargaRepository(this._service);

  Future<List<WargaModel>> getAllWarga() => _service.fetchWarga();
  Future<WargaModel> addWarga(WargaModel warga) => _service.insertWarga(warga);
  Future<WargaModel> updateWarga(WargaModel warga) =>
      _service.updateWarga(warga);
  Future<void> deleteWarga(int id) => _service.deleteWarga(id);
}

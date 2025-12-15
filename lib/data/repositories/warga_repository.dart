import '../../core/services/kelola_warga_service.dart';
import '../models/warga_model.dart';

class WargaRepository {
  final SupabaseService _service;
  WargaRepository(this._service);

  Future<int?> getUserRtId(int userId) => _service.getUserRtId(userId);
  Future<List<WargaModel>> getAllWarga() => _service.fetchWarga();
  Future<List<WargaModel>> getWargaByRT(int idRT) =>
      _service.fetchWargaByRT(idRT);
  Future<WargaModel> addWarga(WargaModel warga) => _service.insertWarga(warga);
  Future<WargaModel> updateWarga(WargaModel warga) =>
      _service.updateWarga(warga);
  Future<void> deleteWarga(int id) => _service.deleteWarga(id);
  Future<bool> checkNikExists(String nik, {int? excludeId}) =>
      _service.checkNikExists(nik, excludeId: excludeId);
}

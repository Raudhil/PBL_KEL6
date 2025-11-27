import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/iuran_model.dart';
import '../../../data/models/iuran_warga_model.dart';

/// State untuk manajemen data iuran warga
class IuranWargaState {
  final List<IuranWargaModel> listIuran;
  final double totalTagihan;
  final DateTime? jatuhTempoTerdekat;
  final bool isLoading;
  final String? errorMessage;

  const IuranWargaState({
    this.listIuran = const [],
    this.totalTagihan = 0,
    this.jatuhTempoTerdekat,
    this.isLoading = true,
    this.errorMessage,
  });

  IuranWargaState copyWith({
    List<IuranWargaModel>? listIuran,
    double? totalTagihan,
    DateTime? jatuhTempoTerdekat,
    bool? isLoading,
    String? errorMessage,
  }) {
    return IuranWargaState(
      listIuran: listIuran ?? this.listIuran,
      totalTagihan: totalTagihan ?? this.totalTagihan,
      jatuhTempoTerdekat: jatuhTempoTerdekat ?? this.jatuhTempoTerdekat,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller untuk handle logika iuran warga
class IuranWargaController extends StateNotifier<IuranWargaState> {
  IuranWargaController() : super(const IuranWargaState()) {
    fetchData();
  }

  final _supabase = Supabase.instance.client;

  // ============== FETCH METHODS ==============

  /// Fetch semua data iuran dan transaksi user
  Future<void> fetchData() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        _setError('User tidak terautentikasi');
        return;
      }

      _logFetchStart(authUser);

      // 1. Ambil master iuran
      final masterIuran = await _fetchMasterIuran();
      if (masterIuran.isEmpty) {
        _setError('Tidak ada data iuran di database');
        return;
      }

      // 2. Cari user ID
      final userId = await _findUserId(authUser.id);
      if (userId == null) {
        _setError(
          'User tidak ditemukan di database. Hubungi admin untuk setup akun.',
        );
        return;
      }

      // 3. Ambil transaksi user
      final transaksiList = await _fetchUserTransaksi(userId);

      // 4. Gabungkan dan process data
      final (mergedList, totalTagihan, nearestDue) = _mergeIuranAndTransaksi(
        masterIuran,
        transaksiList,
      );

      _logFetchSummary(masterIuran.length, totalTagihan, nearestDue);

      state = state.copyWith(
        listIuran: mergedList,
        totalTagihan: totalTagihan,
        jatuhTempoTerdekat: nearestDue,
        isLoading: false,
      );
    } catch (e) {
      _logError('FETCH ERROR', e);
      _setError('Error: ${e.toString()}');
    }
  }

  /// Bayar iuran
  Future<void> bayarIuran(int idIuran) async {
    try {
      print('\n========== BAYAR IURAN START ==========');
      print('🔐 ID Iuran: $idIuran');

      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        throw Exception('User tidak terautentikasi');
      }

      final userId = await _findUserId(authUser.id);
      if (userId == null) {
        throw Exception('User tidak ditemukan');
      }

      print('👤 User ID: $userId');

      await _updateOrCreateTransaksi(idIuran, userId);

      print('========== BAYAR IURAN SUCCESS ==========\n');
      await fetchData();
    } catch (e) {
      _logError('BAYAR IURAN ERROR', e);
      rethrow;
    }
  }

  // ============== PRIVATE HELPER METHODS ==============

  /// Fetch master iuran dari database
  Future<List<IuranModel>> _fetchMasterIuran() async {
    print('\n1️⃣ Fetching master iuran...');

    final response = await _supabase
        .from('iuran')
        .select()
        .order('jatuh_tempo', ascending: true);

    final iuranList = (response as List)
        .map((e) => IuranModel.fromJson(e as Map<String, dynamic>))
        .toList();

    print('✅ Iuran count: ${iuranList.length}');
    if (iuranList.isNotEmpty) {
      print('📝 Sample iuran: ${response[0]}');
    }

    return iuranList;
  }

  /// Fetch transaksi iuran user
  Future<List<Map<String, dynamic>>> _fetchUserTransaksi(int userId) async {
    print('\n3️⃣ Fetching transaksi untuk user $userId...');

    final response = await _supabase
        .from('transaksi_iuran')
        .select()
        .eq('id_user', userId);

    final transaksiList = response as List<dynamic>;

    print('✅ Transaksi count: ${transaksiList.length}');
    if (transaksiList.isNotEmpty) {
      print('📝 Sample transaksi: ${transaksiList[0]}');
    }

    return transaksiList.cast<Map<String, dynamic>>();
  }

  /// Cari user ID berdasarkan auth ID
  Future<int?> _findUserId(String authId) async {
    print('🔍 Mencari User ID untuk auth: $authId');

    try {
      // Try id_auth field
      var result = await _supabase
          .from('users')
          .select('id')
          .eq('id_auth', authId)
          .maybeSingle();

      if (result != null) {
        final userId = result['id'] as int;
        print('✅ User ditemukan via id_auth: $userId');
        return userId;
      }

      // Try id field
      result = await _supabase
          .from('users')
          .select('id')
          .eq('id', authId)
          .maybeSingle();

      if (result != null) {
        final userId = result['id'] as int;
        print('✅ User ditemukan via id: $userId');
        return userId;
      }

      _logUserNotFound(authId);
      return null;
    } catch (e) {
      print('❌ Error mencari user: $e');
      return null;
    }
  }

  /// Merge iuran dan transaksi data
  (List<IuranWargaModel>, double, DateTime?) _mergeIuranAndTransaksi(
    List<IuranModel> masterIuran,
    List<Map<String, dynamic>> transaksiList,
  ) {
    print('\n4️⃣ Merging data...');

    List<IuranWargaModel> mergedList = [];
    double totalTagihan = 0;
    List<DateTime> unpaidDates = [];

    for (var iuran in masterIuran) {
      final transaksi = _findTransaksiForIuran(transaksiList, iuran.id);

      final status = transaksi?['status'] ?? 'Belum Lunas';
      final tglBayar = _parseDate(transaksi?['tanggal_bayar']);

      if (status == 'Belum Lunas') {
        totalTagihan += iuran.nominal;
        unpaidDates.add(iuran.jatuhTempo);
      }

      mergedList.add(
        IuranWargaModel(iuran: iuran, status: status, tanggalBayar: tglBayar),
      );

      print('  ✓ Iuran: ${iuran.jenis} | Status: $status');
    }

    unpaidDates.sort();
    final nearestDue = unpaidDates.isNotEmpty ? unpaidDates.first : null;

    return (mergedList, totalTagihan, nearestDue);
  }

  /// Cari transaksi untuk iuran tertentu
  Map<String, dynamic>? _findTransaksiForIuran(
    List<Map<String, dynamic>> transaksiList,
    int? iuranId,
  ) {
    try {
      return transaksiList.firstWhere((t) => t['id_iuran'] == iuranId);
    } catch (e) {
      return null;
    }
  }

  /// Parse date dengan error handling
  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      return DateTime.parse(dateValue.toString());
    } catch (e) {
      print('⚠️ Error parsing date: $e');
      return null;
    }
  }

  /// Update atau create transaksi iuran
  Future<void> _updateOrCreateTransaksi(int idIuran, int userId) async {
    final existingTransaksi = await _supabase
        .from('transaksi_iuran')
        .select()
        .eq('id_iuran', idIuran)
        .eq('id_user', userId)
        .maybeSingle();

    final updateData = {
      'status': 'Lunas',
      'tanggal_bayar': DateTime.now().toIso8601String(),
      'metode': 'Transfer Bank',
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existingTransaksi != null) {
      print('⚠️ Sudah ada transaksi untuk iuran ini');
      print('🔄 Update status → Lunas');

      await _supabase
          .from('transaksi_iuran')
          .update(updateData)
          .eq('id', existingTransaksi['id']);

      print('✅ Transaksi diupdate');
    } else {
      print('➕ Membuat transaksi baru...');

      final insertData = {
        'id_iuran': idIuran,
        'id_user': userId,
        ...updateData,
        'bukti_transaksi': null,
      };

      print('📤 Data: $insertData');

      await _supabase.from('transaksi_iuran').insert(insertData);

      print('✅ Transaksi berhasil dibuat');
    }
  }

  // ============== LOGGING METHODS ==============

  void _logFetchStart(User authUser) {
    print('========== FETCH IURAN START ==========');
    print('🔐 Auth User ID: ${authUser.id}');
    print('📧 Auth Email: ${authUser.email}');
  }

  void _logFetchSummary(
    int totalIuran,
    double totalTagihan,
    DateTime? nearestDue,
  ) {
    print('\n📊 SUMMARY:');
    print('  Total Iuran: $totalIuran');
    print('  Total Tagihan: Rp$totalTagihan');
    print('  Jatuh Tempo Terdekat: $nearestDue');
    print('========== FETCH IURAN SUCCESS ==========\n');
  }

  void _logUserNotFound(String authId) {
    print('📋 User dengan auth $authId tidak ditemukan');
  }

  void _logError(String title, Object error) {
    print('❌ $title: $error');
  }

  // ============== STATE SETTERS ==============

  void _setError(String message) {
    state = state.copyWith(isLoading: false, errorMessage: message);
  }
}

// ============== PROVIDER ==============

final iuranWargaProvider =
    StateNotifierProvider<IuranWargaController, IuranWargaState>((ref) {
      return IuranWargaController();
    });

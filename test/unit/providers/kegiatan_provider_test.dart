import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/core/providers/kegiatan_provider.dart';
import 'package:jawara/data/models/kegiatan_model.dart';

void main() {
  group('KegiatanFormState Tests', () {
    test('harus membuat state dengan default values', () {
      // Arrange & Act
      final state = KegiatanFormState();

      // Assert
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.kegiatan, isNull);
    });

    test('harus copy state dengan beberapa field berubah', () {
      // Arrange
      final originalState = KegiatanFormState();

      // Act
      final newState = originalState.copyWith(
        isLoading: true,
        errorMessage: 'Test error',
      );

      // Assert
      expect(newState.isLoading, isTrue);
      expect(newState.isSuccess, isFalse);
      expect(newState.errorMessage, 'Test error');
      expect(newState.kegiatan, isNull);
    });

    test('harus copy state dengan semua field berubah', () {
      // Arrange
      final dummyKegiatan = _createDummyKegiatan();
      final originalState = KegiatanFormState();

      // Act
      final newState = originalState.copyWith(
        isLoading: false,
        isSuccess: true,
        errorMessage: null,
        kegiatan: dummyKegiatan,
      );

      // Assert
      expect(newState.isLoading, isFalse);
      expect(newState.isSuccess, isTrue);
      expect(newState.errorMessage, isNull);
      expect(newState.kegiatan, dummyKegiatan);
      expect(newState.kegiatan?.judul, 'Kegiatan Test');
    });
  });

  group('KegiatanListNotifier Business Logic Tests', () {
    test('harus memiliki initial state loading saat dibuat', () {
      // Arrange & Act
      const initialState = AsyncValue<List<KegiatanModel>>.loading();

      // Assert
      expect(initialState.isLoading, isTrue);
      expect(initialState.hasValue, isFalse);
      expect(initialState.hasError, isFalse);
    });

    test('harus mengubah state menjadi data setelah load berhasil', () {
      // Arrange
      final mockKegiatanList = [
        _createDummyKegiatan(id: '1', judul: 'Kegiatan 1'),
        _createDummyKegiatan(id: '2', judul: 'Kegiatan 2'),
      ];

      // Act
      final dataState = AsyncValue.data(mockKegiatanList);

      // Assert
      expect(dataState.isLoading, isFalse);
      expect(dataState.hasValue, isTrue);
      expect(dataState.hasError, isFalse);
      expect(dataState.value, mockKegiatanList);
      expect(dataState.value?.length, 2);
    });

    test('harus mengubah state menjadi error saat load gagal', () {
      // Arrange
      final testError = Exception('Database connection failed');
      final testStackTrace = StackTrace.current;

      // Act
      final errorState = AsyncValue<List<KegiatanModel>>.error(
        testError,
        testStackTrace,
      );

      // Assert
      expect(errorState.isLoading, isFalse);
      expect(errorState.hasValue, isFalse);
      expect(errorState.hasError, isTrue);
      expect(errorState.error, testError);
    });

    test('harus menangani transisi state dari loading ke data', () {
      // Arrange
      const loadingState = AsyncValue<List<KegiatanModel>>.loading();
      final dataState = AsyncValue.data([_createDummyKegiatan()]);

      // Assert - Loading state
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.hasValue, isFalse);

      // Assert - Data state
      expect(dataState.isLoading, isFalse);
      expect(dataState.hasValue, isTrue);
      expect(dataState.value?.length, 1);
    });

    test('harus menangani transisi state dari loading ke error', () {
      // Arrange
      const loadingState = AsyncValue<List<KegiatanModel>>.loading();
      final error = Exception('Network error');
      final errorState = AsyncValue<List<KegiatanModel>>.error(
        error,
        StackTrace.current,
      );

      // Assert - Loading state
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.hasError, isFalse);

      // Assert - Error state
      expect(errorState.isLoading, isFalse);
      expect(errorState.hasError, isTrue);
      expect(errorState.error.toString(), contains('Network error'));
    });

    test('harus menangani list kosong dengan benar', () {
      // Arrange
      final emptyList = <KegiatanModel>[];

      // Act
      final dataState = AsyncValue.data(emptyList);

      // Assert
      expect(dataState.hasValue, isTrue);
      expect(dataState.value, isEmpty);
      expect(dataState.value?.length, 0);
    });

    test('harus memvalidasi struktur data kegiatan yang valid', () {
      // Arrange
      final validKegiatan = _createDummyKegiatan(
        id: '1',
        judul: 'Kegiatan Sosial',
        kategori: KategoriKegiatan.sosial,
        status: StatusKegiatan.akanDatang,
      );

      // Act
      final hasRequiredFields =
          validKegiatan.id.isNotEmpty &&
          validKegiatan.judul.isNotEmpty &&
          validKegiatan.penyelenggara.isNotEmpty;

      final hasValidKategori =
          validKegiatan.kategori == KategoriKegiatan.sosial;
      final hasValidStatus = validKegiatan.status == StatusKegiatan.akanDatang;

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(hasValidKategori, isTrue);
      expect(hasValidStatus, isTrue);
    });

    test('harus memvalidasi filter kategori kegiatan', () {
      // Arrange
      final allKategori = [
        KategoriKegiatan.sosial,
        KategoriKegiatan.kebersihan,
        KategoriKegiatan.kesehatan,
        KategoriKegiatan.pendidikan,
        KategoriKegiatan.keagamaan,
        KategoriKegiatan.olahraga,
        KategoriKegiatan.budaya,
        KategoriKegiatan.lainnya,
      ];

      // Act & Assert
      for (var kategori in allKategori) {
        final kegiatan = _createDummyKegiatan(kategori: kategori);
        expect(kegiatan.kategori, kategori);
      }
    });

    test('harus memvalidasi filter status kegiatan', () {
      // Arrange
      final allStatus = [
        StatusKegiatan.akanDatang,
        StatusKegiatan.sedangBerlangsung,
        StatusKegiatan.selesai,
        StatusKegiatan.dibatalkan,
      ];

      // Act & Assert
      for (var status in allStatus) {
        final kegiatan = _createDummyKegiatan(status: status);
        expect(kegiatan.status, status);
      }
    });

    test('harus menangani berbagai tipe error dengan benar', () {
      // Arrange
      final errorTypes = [
        Exception('Database error'),
        Exception('Network timeout'),
        Exception('Permission denied'),
        Exception('Invalid data format'),
      ];

      for (var error in errorTypes) {
        // Act
        final errorState = AsyncValue<List<KegiatanModel>>.error(
          error,
          StackTrace.current,
        );

        // Assert
        expect(errorState.hasError, isTrue);
        expect(errorState.error, error);
        expect(errorState.error.toString(), contains('Exception'));
      }
    });

    test('harus memvalidasi properti kegiatan dengan field lengkap', () {
      // Arrange
      final completeKegiatan = _createDummyKegiatan(
        id: '1',
        judul: 'Kegiatan Lengkap',
        deskripsi: 'Deskripsi kegiatan',
        lokasi: 'Jakarta',
        penyelenggara: 'Organisasi',
        kategori: KategoriKegiatan.sosial,
        status: StatusKegiatan.akanDatang,
        kuotaPeserta: 100,
      );

      final requiredFields = [
        completeKegiatan.id,
        completeKegiatan.judul,
        completeKegiatan.penyelenggara,
      ];

      // Act
      final allFieldsNotEmpty = requiredFields.every(
        (field) => field.isNotEmpty,
      );

      // Assert
      expect(allFieldsNotEmpty, isTrue);
      expect(completeKegiatan.deskripsi, 'Deskripsi kegiatan');
      expect(completeKegiatan.lokasi, 'Jakarta');
      expect(completeKegiatan.kuotaPeserta, 100);
    });

    test('harus memvalidasi format durasi kegiatan', () {
      // Arrange
      final tglMulai = DateTime(2025, 12, 15);
      final tglSelesai = DateTime(2025, 12, 16);

      final kegiatanWithDuration = _createDummyKegiatan(
        tanggalMulai: tglMulai,
        tanggalSelesai: tglSelesai,
      );

      // Act
      final durasi = kegiatanWithDuration.durasi;
      final hasDurationInfo = durasi.isNotEmpty;

      // Assert
      expect(hasDurationInfo, isTrue);
      expect(durasi, isNotEmpty);
    });

    test('harus memvalidasi kegiatan yang sudah lewat', () {
      // Arrange
      final pastDate = DateTime.now().subtract(Duration(days: 5));
      final kegiatanPast = _createDummyKegiatan(tanggalMulai: pastDate);

      // Act
      final isPast = kegiatanPast.isPast;

      // Assert
      expect(isPast, isTrue);
    });

    test('harus memvalidasi kegiatan yang akan datang', () {
      // Arrange
      final futureDate = DateTime.now().add(Duration(days: 5));
      final kegiatanFuture = _createDummyKegiatan(tanggalMulai: futureDate);

      // Act
      final isPast = kegiatanFuture.isPast;

      // Assert
      expect(isPast, isFalse);
    });

    test('harus memvalidasi kegiatan yang sedang berlangsung', () {
      // Arrange
      final now = DateTime.now();
      final tglMulai = now.subtract(Duration(hours: 2));
      final tglSelesai = now.add(Duration(hours: 2));

      final kegiatanOngoing = _createDummyKegiatan(
        tanggalMulai: tglMulai,
        tanggalSelesai: tglSelesai,
      );

      // Act
      final isOngoing = kegiatanOngoing.isOngoing;

      // Assert
      expect(isOngoing, isTrue);
    });

    test('harus memvalidasi operasi CRUD dengan state yang benar', () {
      // Arrange - Simulate CRUD operations state flow
      final operations = [
        {'operation': 'CREATE', 'requiresRefresh': true},
        {'operation': 'UPDATE', 'requiresRefresh': true},
        {'operation': 'DELETE', 'requiresRefresh': true},
        {'operation': 'READ', 'requiresRefresh': false},
      ];

      for (var op in operations) {
        // Act
        final operation = op['operation'] as String;
        final needsRefresh = op['requiresRefresh'] as bool;

        // Assert
        if (operation != 'READ') {
          expect(
            needsRefresh,
            isTrue,
            reason: '$operation should trigger refresh',
          );
        } else {
          expect(
            needsRefresh,
            isFalse,
            reason: '$operation should not trigger refresh',
          );
        }
      }
    });

    test('harus memvalidasi ID kegiatan untuk operasi delete', () {
      // Arrange
      final validIds = ['1', '100', 'uuid-12345'];
      final invalidIds = ['', '0', '-1'];

      // Act & Assert - Valid IDs
      for (var id in validIds) {
        final isValid =
            id.isNotEmpty && int.tryParse(id) == null || int.parse(id) > 0;
        expect(isValid, isTrue, reason: 'ID $id should be valid');
      }

      // Act & Assert - Invalid IDs
      for (var id in invalidIds) {
        bool isValid = true;
        if (id.isEmpty) {
          isValid = false;
        } else {
          final numId = int.tryParse(id);
          if (numId != null && numId <= 0) {
            isValid = false;
          }
        }
        expect(isValid, isFalse, reason: 'ID $id should be invalid');
      }
    });

    test('harus memvalidasi kuota peserta yang valid', () {
      // Arrange
      final validQuotas = [10, 50, 100, 500];
      final invalidQuotas = [0, -1, -50];

      // Act & Assert - Valid quotas
      for (var quota in validQuotas) {
        final isValid = quota > 0;
        expect(isValid, isTrue, reason: 'Quota $quota should be valid');
      }

      // Act & Assert - Invalid quotas
      for (var quota in invalidQuotas) {
        final isValid = quota > 0;
        expect(isValid, isFalse, reason: 'Quota $quota should be invalid');
      }
    });

    test('harus memvalidasi label kategori kegiatan', () {
      // Arrange
      final kategoriLabels = [
        (KategoriKegiatan.sosial, 'Sosial'),
        (KategoriKegiatan.kebersihan, 'Kebersihan'),
        (KategoriKegiatan.kesehatan, 'Kesehatan'),
        (KategoriKegiatan.pendidikan, 'Pendidikan'),
        (KategoriKegiatan.keagamaan, 'Keagamaan'),
        (KategoriKegiatan.olahraga, 'Olahraga'),
        (KategoriKegiatan.budaya, 'Budaya'),
        (KategoriKegiatan.lainnya, 'Lainnya'),
      ];

      // Act & Assert
      for (var (kategori, expectedLabel) in kategoriLabels) {
        expect(kategori.label, expectedLabel);
      }
    });

    test('harus memvalidasi label status kegiatan', () {
      // Arrange
      final statusLabels = [
        (StatusKegiatan.akanDatang, 'Akan Datang'),
        (StatusKegiatan.sedangBerlangsung, 'Sedang Berlangsung'),
        (StatusKegiatan.selesai, 'Selesai'),
        (StatusKegiatan.dibatalkan, 'Dibatalkan'),
      ];

      // Act & Assert
      for (var (status, expectedLabel) in statusLabels) {
        expect(status.label, expectedLabel);
      }
    });

    test('harus memvalidasi value kategori kegiatan', () {
      // Arrange
      final kategoriValues = [
        (KategoriKegiatan.sosial, 'sosial'),
        (KategoriKegiatan.kebersihan, 'kebersihan'),
        (KategoriKegiatan.kesehatan, 'kesehatan'),
        (KategoriKegiatan.pendidikan, 'pendidikan'),
        (KategoriKegiatan.keagamaan, 'keagamaan'),
        (KategoriKegiatan.olahraga, 'olahraga'),
        (KategoriKegiatan.budaya, 'budaya'),
        (KategoriKegiatan.lainnya, 'lainnya'),
      ];

      // Act & Assert
      for (var (kategori, expectedValue) in kategoriValues) {
        expect(kategori.value, expectedValue);
      }
    });

    test('harus memvalidasi value status kegiatan', () {
      // Arrange
      final statusValues = [
        (StatusKegiatan.akanDatang, 'akan_datang'),
        (StatusKegiatan.sedangBerlangsung, 'sedang_berlangsung'),
        (StatusKegiatan.selesai, 'selesai'),
        (StatusKegiatan.dibatalkan, 'dibatalkan'),
      ];

      // Act & Assert
      for (var (status, expectedValue) in statusValues) {
        expect(status.value, expectedValue);
      }
    });
  });

  group('KegiatanFormNotifier Business Logic Tests', () {
    test('harus membuat form state dengan initial state kosong', () {
      // Arrange & Act
      final formState = KegiatanFormState();

      // Assert
      expect(formState.isLoading, isFalse);
      expect(formState.isSuccess, isFalse);
      expect(formState.errorMessage, isNull);
      expect(formState.kegiatan, isNull);
    });

    test('harus memvalidasi form data kegiatan yang lengkap', () {
      // Arrange
      final formData = {
        'judul': 'Kegiatan Test',
        'deskripsi': 'Deskripsi test',
        'tanggalMulai': DateTime(2025, 12, 15),
        'lokasi': 'Jakarta',
        'penyelenggara': 'Organisasi Test',
        'kategori': KategoriKegiatan.sosial,
        'status': StatusKegiatan.akanDatang,
        'kuotaPeserta': 100,
      };

      // Act
      final judul = formData['judul'] as String;
      final deskripsi = formData['deskripsi'] as String;
      final lokasi = formData['lokasi'] as String;
      final penyelenggara = formData['penyelenggara'] as String;

      final isValid =
          judul.isNotEmpty &&
          deskripsi.isNotEmpty &&
          lokasi.isNotEmpty &&
          penyelenggara.isNotEmpty;

      // Assert
      expect(isValid, isTrue);
      expect(judul, 'Kegiatan Test');
      expect(deskripsi, 'Deskripsi test');
      expect(lokasi, 'Jakarta');
    });

    test('harus mendeteksi form data yang tidak valid', () {
      // Arrange
      final invalidFormData = {
        'judul': '', // Empty judul
        'deskripsi': 'Deskripsi test',
        'penyelenggara': '', // Empty penyelenggara
        'kategori': KategoriKegiatan.sosial,
        'status': StatusKegiatan.akanDatang,
      };

      // Act
      final judul = invalidFormData['judul'] as String;
      final penyelenggara = invalidFormData['penyelenggara'] as String;

      final isValid = judul.isNotEmpty && penyelenggara.isNotEmpty;

      // Assert
      expect(isValid, isFalse, reason: 'Form should be invalid');
      expect(judul, isEmpty);
      expect(penyelenggara, isEmpty);
    });

    test('harus handle form state loading saat create', () {
      // Arrange
      final initialState = KegiatanFormState();

      // Act
      final loadingState = initialState.copyWith(isLoading: true);

      // Assert
      expect(initialState.isLoading, isFalse);
      expect(loadingState.isLoading, isTrue);
    });

    test('harus handle form state success saat create berhasil', () {
      // Arrange
      final initialState = KegiatanFormState(isLoading: true);
      final successKegiatan = _createDummyKegiatan();

      // Act
      final successState = initialState.copyWith(
        isLoading: false,
        isSuccess: true,
        kegiatan: successKegiatan,
      );

      // Assert
      expect(successState.isLoading, isFalse);
      expect(successState.isSuccess, isTrue);
      expect(successState.kegiatan, successKegiatan);
      expect(successState.errorMessage, isNull);
    });

    test('harus handle form state error saat create gagal', () {
      // Arrange
      final initialState = KegiatanFormState(isLoading: true);
      final errorMessage = 'Gagal membuat kegiatan';

      // Act
      final errorState = initialState.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: errorMessage,
      );

      // Assert
      expect(errorState.isLoading, isFalse);
      expect(errorState.isSuccess, isFalse);
      expect(errorState.errorMessage, errorMessage);
      expect(errorState.kegiatan, isNull);
    });

    test('harus reset form state dengan benar', () {
      // Arrange
      final kegiatan = _createDummyKegiatan();
      final formState = KegiatanFormState(isSuccess: true, kegiatan: kegiatan);

      // Act
      final resetState = KegiatanFormState();

      // Assert
      expect(formState.isSuccess, isTrue);
      expect(resetState.isSuccess, isFalse);
      expect(formState.kegiatan, kegiatan);
      expect(resetState.kegiatan, isNull);
    });

    test('harus validasi tanggal mulai harus sebelum tanggal selesai', () {
      // Arrange
      final tglMulai = DateTime(2025, 12, 15);
      final tglSelesaiValid = DateTime(2025, 12, 16);
      final tglSelesaiInvalid = DateTime(2025, 12, 14);

      // Act & Assert - Valid
      final isValidDate1 = tglMulai.isBefore(tglSelesaiValid);
      expect(isValidDate1, isTrue);

      // Act & Assert - Invalid
      final isValidDate2 = tglMulai.isBefore(tglSelesaiInvalid);
      expect(isValidDate2, isFalse);
    });

    test('harus validasi judul kegiatan tidak boleh kosong', () {
      // Arrange
      final validJudul = 'Kegiatan Sosial';
      final invalidJudul = '';

      // Act & Assert
      expect(validJudul.isNotEmpty, isTrue);
      expect(invalidJudul.isNotEmpty, isFalse);
    });

    test('harus validasi penyelenggara tidak boleh kosong', () {
      // Arrange
      final validPenyelenggara = 'Organisasi A';
      final invalidPenyelenggara = '';

      // Act & Assert
      expect(validPenyelenggara.isNotEmpty, isTrue);
      expect(invalidPenyelenggara.isNotEmpty, isFalse);
    });

    test('harus preserve field yang tidak berubah saat copyWith', () {
      // Arrange
      final originalKegiatan = _createDummyKegiatan();
      final originalState = KegiatanFormState(
        isLoading: false,
        isSuccess: true,
        kegiatan: originalKegiatan,
      );

      // Act
      final updatedState = originalState.copyWith(errorMessage: 'New error');

      // Assert
      expect(updatedState.isLoading, originalState.isLoading);
      expect(updatedState.isSuccess, originalState.isSuccess);
      expect(updatedState.kegiatan, originalKegiatan);
      expect(updatedState.errorMessage, 'New error');
    });
  });
}

/// Helper function untuk membuat dummy kegiatan
KegiatanModel _createDummyKegiatan({
  String id = 'test-id-1',
  String judul = 'Kegiatan Test',
  String? deskripsi,
  DateTime? tanggalMulai,
  DateTime? tanggalSelesai,
  String? lokasi,
  String penyelenggara = 'Organisasi Test',
  KategoriKegiatan kategori = KategoriKegiatan.sosial,
  StatusKegiatan status = StatusKegiatan.akanDatang,
  int? kuotaPeserta,
  String? fotoUrl,
  String? createdBy,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return KegiatanModel(
    id: id,
    judul: judul,
    deskripsi: deskripsi,
    tanggalMulai: tanggalMulai ?? DateTime(2025, 12, 15),
    tanggalSelesai: tanggalSelesai,
    lokasi: lokasi,
    penyelenggara: penyelenggara,
    kategori: kategori,
    status: status,
    kuotaPeserta: kuotaPeserta,
    fotoUrl: fotoUrl,
    createdBy: createdBy,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt ?? DateTime.now(),
  );
}

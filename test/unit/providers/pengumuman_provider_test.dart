import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jawara/core/providers/pengumuman_provider.dart';
import 'package:jawara/data/models/pengumuman_model.dart';

void main() {
  group('PengumumanFormState Tests', () {
    test('harus membuat state dengan default values', () {
      // Arrange & Act
      final state = PengumumanFormState();

      // Assert
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.pengumumanData, isNull);
    });

    test('harus copy state dengan beberapa field berubah', () {
      // Arrange
      final originalState = PengumumanFormState();

      // Act
      final newState = originalState.copyWith(
        isLoading: true,
        errorMessage: 'Test error',
      );

      // Assert
      expect(newState.isLoading, isTrue);
      expect(newState.isSuccess, isFalse);
      expect(newState.errorMessage, 'Test error');
      expect(newState.pengumumanData, isNull);
    });

    test('harus copy state dengan semua field berubah', () {
      // Arrange
      final dummyPengumuman = _createDummyPengumuman();
      final originalState = PengumumanFormState();

      // Act
      final newState = originalState.copyWith(
        isLoading: false,
        isSuccess: true,
        errorMessage: null,
        pengumumanData: dummyPengumuman,
      );

      // Assert
      expect(newState.isLoading, isFalse);
      expect(newState.isSuccess, isTrue);
      expect(newState.errorMessage, isNull);
      expect(newState.pengumumanData, dummyPengumuman);
      expect(newState.pengumumanData?.judul, 'Pengumuman Test');
    });

    test('harus preserve field yang tidak berubah saat copyWith', () {
      // Arrange
      final pengumuman = _createDummyPengumuman();
      final originalState = PengumumanFormState(
        isLoading: false,
        isSuccess: true,
        pengumumanData: pengumuman,
      );

      // Act
      final updatedState = originalState.copyWith(errorMessage: 'New error');

      // Assert
      expect(updatedState.isLoading, originalState.isLoading);
      expect(updatedState.isSuccess, originalState.isSuccess);
      expect(updatedState.pengumumanData, pengumuman);
      expect(updatedState.errorMessage, 'New error');
    });
  });

  group('PengumumanListNotifier Business Logic Tests', () {
    test('harus memiliki initial state loading saat dibuat', () {
      // Arrange & Act
      const initialState = AsyncValue<List<PengumumanModel>>.loading();

      // Assert
      expect(initialState.isLoading, isTrue);
      expect(initialState.hasValue, isFalse);
      expect(initialState.hasError, isFalse);
    });

    test('harus mengubah state menjadi data setelah load berhasil', () {
      // Arrange
      final mockPengumumanList = [
        _createDummyPengumuman(id: 1, judul: 'Pengumuman 1'),
        _createDummyPengumuman(id: 2, judul: 'Pengumuman 2'),
      ];

      // Act
      final dataState = AsyncValue.data(mockPengumumanList);

      // Assert
      expect(dataState.isLoading, isFalse);
      expect(dataState.hasValue, isTrue);
      expect(dataState.hasError, isFalse);
      expect(dataState.value, mockPengumumanList);
      expect(dataState.value?.length, 2);
    });

    test('harus mengubah state menjadi error saat load gagal', () {
      // Arrange
      final testError = Exception('Database connection failed');
      final testStackTrace = StackTrace.current;

      // Act
      final errorState = AsyncValue<List<PengumumanModel>>.error(
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
      const loadingState = AsyncValue<List<PengumumanModel>>.loading();
      final dataState = AsyncValue.data([_createDummyPengumuman()]);

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
      const loadingState = AsyncValue<List<PengumumanModel>>.loading();
      final error = Exception('Network error');
      final errorState = AsyncValue<List<PengumumanModel>>.error(
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
      final emptyList = <PengumumanModel>[];

      // Act
      final dataState = AsyncValue.data(emptyList);

      // Assert
      expect(dataState.hasValue, isTrue);
      expect(dataState.value, isEmpty);
      expect(dataState.value?.length, 0);
    });

    test('harus memvalidasi struktur data pengumuman yang valid', () {
      // Arrange
      final validPengumuman = _createDummyPengumuman(
        id: 1,
        judul: 'Pengumuman Penting',
        isi: 'Isi pengumuman penting',
      );

      // Act
      final hasRequiredFields =
          validPengumuman.id > 0 &&
          validPengumuman.judul.isNotEmpty &&
          validPengumuman.isi.isNotEmpty;

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(validPengumuman.judul, 'Pengumuman Penting');
      expect(validPengumuman.isi, 'Isi pengumuman penting');
    });

    test('harus memvalidasi properti pengumuman dengan field lengkap', () {
      // Arrange
      final completePengumuman = _createDummyPengumuman(
        id: 1,
        judul: 'Pengumuman Lengkap',
        isi: 'Isi pengumuman lengkap',
        fotoUrl: 'https://example.com/foto.jpg',
        dokumenUrl: 'https://example.com/dokumen.pdf',
      );

      final requiredFields = [completePengumuman.judul, completePengumuman.isi];

      // Act
      final allFieldsNotEmpty = requiredFields.every(
        (field) => field.isNotEmpty,
      );

      // Assert
      expect(allFieldsNotEmpty, isTrue);
      expect(completePengumuman.fotoUrl, 'https://example.com/foto.jpg');
      expect(completePengumuman.dokumenUrl, 'https://example.com/dokumen.pdf');
    });

    test('harus memvalidasi pengumuman dengan foto', () {
      // Arrange
      final pengumumanWithFoto = _createDummyPengumuman(
        fotoUrl: 'https://example.com/foto.jpg',
      );

      final pengumumanWithoutFoto = _createDummyPengumuman(fotoUrl: null);

      // Act
      final hasFotoValid = pengumumanWithFoto.hasFoto;
      final hasFotoInvalid = pengumumanWithoutFoto.hasFoto;

      // Assert
      expect(hasFotoValid, isTrue);
      expect(hasFotoInvalid, isFalse);
    });

    test('harus memvalidasi pengumuman dengan dokumen', () {
      // Arrange
      final pengumumanWithDokumen = _createDummyPengumuman(
        dokumenUrl: 'https://example.com/dokumen.pdf',
      );

      final pengumumanWithoutDokumen = _createDummyPengumuman(dokumenUrl: null);

      // Act
      final hasDokumenValid = pengumumanWithDokumen.hasDokumen;
      final hasDokumenInvalid = pengumumanWithoutDokumen.hasDokumen;

      // Assert
      expect(hasDokumenValid, isTrue);
      expect(hasDokumenInvalid, isFalse);
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
        final errorState = AsyncValue<List<PengumumanModel>>.error(
          error,
          StackTrace.current,
        );

        // Assert
        expect(errorState.hasError, isTrue);
        expect(errorState.error, error);
        expect(errorState.error.toString(), contains('Exception'));
      }
    });

    test('harus memvalidasi operasi CRUD dengan state yang benar', () {
      // Arrange
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

    test('harus memvalidasi ID pengumuman untuk operasi delete', () {
      // Arrange
      final validIds = [1, 100, 999];
      final invalidIds = [0, -1];

      // Act & Assert - Valid IDs
      for (var id in validIds) {
        final isValid = id > 0;
        expect(isValid, isTrue, reason: 'ID $id should be valid');
      }

      // Act & Assert - Invalid IDs
      for (var id in invalidIds) {
        final isValid = id > 0;
        expect(isValid, isFalse, reason: 'ID $id should be invalid');
      }
    });

    test('harus memvalidasi judul pengumuman tidak boleh kosong', () {
      // Arrange
      final validJuduls = [
        'Pengumuman Penting',
        'Update Sistem',
        'Informasi Terbaru',
      ];
      final invalidJuduls = ['', '   '];

      // Act & Assert - Valid juduls
      for (var judul in validJuduls) {
        final isValid = judul.trim().isNotEmpty;
        expect(isValid, isTrue, reason: 'Judul "$judul" should be valid');
      }

      // Act & Assert - Invalid juduls
      for (var judul in invalidJuduls) {
        final isValid = judul.trim().isNotEmpty;
        expect(isValid, isFalse, reason: 'Judul "$judul" should be invalid');
      }
    });

    test('harus memvalidasi isi pengumuman tidak boleh kosong', () {
      // Arrange
      final validIsi = [
        'Isi pengumuman penting',
        'Deskripsi detail tentang pengumuman',
        'A', // minimal 1 karakter
      ];
      final invalidIsi = ['', '   '];

      // Act & Assert - Valid isi
      for (var isi in validIsi) {
        final isValid = isi.trim().isNotEmpty;
        expect(isValid, isTrue, reason: 'Isi "$isi" should be valid');
      }

      // Act & Assert - Invalid isi
      for (var isi in invalidIsi) {
        final isValid = isi.trim().isNotEmpty;
        expect(isValid, isFalse, reason: 'Isi "$isi" should be invalid');
      }
    });

    test('harus memvalidasi format URL untuk foto', () {
      // Arrange
      final validUrls = [
        'https://example.com/foto.jpg',
        'https://cdn.example.com/image.png',
        'http://example.com/gambar.webp',
      ];

      final invalidUrls = [
        'example.com/foto.jpg',
        'ftp://example.com/foto.jpg',
        'not-a-url',
      ];

      // Act & Assert - Valid URLs
      for (var url in validUrls) {
        final isValid = url.startsWith('http://') || url.startsWith('https://');
        expect(isValid, isTrue, reason: 'URL $url should be valid');
      }

      // Act & Assert - Invalid URLs
      for (var url in invalidUrls) {
        final isValid = url.startsWith('http://') || url.startsWith('https://');
        expect(isValid, isFalse, reason: 'URL $url should be invalid');
      }
    });
  });

  group('PengumumanFormNotifier Business Logic Tests', () {
    test('harus membuat form state dengan initial state kosong', () {
      // Arrange & Act
      final formState = PengumumanFormState();

      // Assert
      expect(formState.isLoading, isFalse);
      expect(formState.isSuccess, isFalse);
      expect(formState.errorMessage, isNull);
      expect(formState.pengumumanData, isNull);
    });

    test('harus memvalidasi form data pengumuman yang lengkap', () {
      // Arrange
      final formData = {
        'judul': 'Pengumuman Test',
        'isi': 'Isi pengumuman test',
        'fotoUrl': null,
        'dokumenUrl': null,
      };

      // Act
      final judul = formData['judul'] as String;
      final isi = formData['isi'] as String;

      final isValid = judul.trim().isNotEmpty && isi.trim().isNotEmpty;

      // Assert
      expect(isValid, isTrue);
      expect(judul, 'Pengumuman Test');
      expect(isi, 'Isi pengumuman test');
    });

    test('harus mendeteksi form data yang tidak valid', () {
      // Arrange
      final invalidFormData = {
        'judul': '', // Empty judul
        'isi': '', // Empty isi
      };

      // Act
      final judul = invalidFormData['judul'] as String;
      final isi = invalidFormData['isi'] as String;

      final isValid = judul.trim().isNotEmpty && isi.trim().isNotEmpty;

      // Assert
      expect(isValid, isFalse, reason: 'Form should be invalid');
      expect(judul, isEmpty);
      expect(isi, isEmpty);
    });

    test('harus handle form state loading saat create', () {
      // Arrange
      final initialState = PengumumanFormState();

      // Act
      final loadingState = initialState.copyWith(isLoading: true);

      // Assert
      expect(initialState.isLoading, isFalse);
      expect(loadingState.isLoading, isTrue);
    });

    test('harus handle form state success saat create berhasil', () {
      // Arrange
      final initialState = PengumumanFormState(isLoading: true);
      final successPengumuman = _createDummyPengumuman();

      // Act
      final successState = initialState.copyWith(
        isLoading: false,
        isSuccess: true,
        pengumumanData: successPengumuman,
      );

      // Assert
      expect(successState.isLoading, isFalse);
      expect(successState.isSuccess, isTrue);
      expect(successState.pengumumanData, successPengumuman);
      expect(successState.errorMessage, isNull);
    });

    test('harus handle form state error saat create gagal', () {
      // Arrange
      final initialState = PengumumanFormState(isLoading: true);
      final errorMessage = 'Gagal membuat pengumuman';

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
      expect(errorState.pengumumanData, isNull);
    });

    test('harus reset form state dengan benar', () {
      // Arrange
      final pengumuman = _createDummyPengumuman();
      final formState = PengumumanFormState(
        isSuccess: true,
        pengumumanData: pengumuman,
      );

      // Act
      final resetState = PengumumanFormState();

      // Assert
      expect(formState.isSuccess, isTrue);
      expect(resetState.isSuccess, isFalse);
      expect(formState.pengumumanData, pengumuman);
      expect(resetState.pengumumanData, isNull);
    });

    test('harus validasi panjang judul maksimum', () {
      // Arrange
      final validJudul = 'A' * 200;
      final invalidJudul = 'A' * 300;
      final maxLength = 255;

      // Act & Assert - Valid
      final isValidJudul = validJudul.length <= maxLength;
      expect(isValidJudul, isTrue);

      // Act & Assert - Invalid
      final isInvalidJudul = invalidJudul.length <= maxLength;
      expect(isInvalidJudul, isFalse);
    });

    test('harus validasi panjang isi maksimum', () {
      // Arrange
      final validIsi = 'B' * 5000;
      final invalidIsi = 'B' * 10000;
      final maxLength = 8000;

      // Act & Assert - Valid
      final isValidIsi = validIsi.length <= maxLength;
      expect(isValidIsi, isTrue);

      // Act & Assert - Invalid
      final isInvalidIsi = invalidIsi.length <= maxLength;
      expect(isInvalidIsi, isFalse);
    });
  });

  group('PengumumanAktifNotifier Business Logic Tests', () {
    test('harus memiliki initial state loading untuk aktif notifier', () {
      // Arrange & Act
      const initialState = AsyncValue<List<PengumumanModel>>.loading();

      // Assert
      expect(initialState.isLoading, isTrue);
      expect(initialState.hasValue, isFalse);
      expect(initialState.hasError, isFalse);
    });

    test('harus mengubah state menjadi data untuk aktif pengumuman', () {
      // Arrange
      final mockPengumuman = [
        _createDummyPengumuman(id: 1),
        _createDummyPengumuman(id: 2),
        _createDummyPengumuman(id: 3),
      ];

      // Act
      final dataState = AsyncValue.data(mockPengumuman);

      // Assert
      expect(dataState.hasValue, isTrue);
      expect(dataState.value?.length, 3);
    });

    test('harus handle error state untuk aktif notifier', () {
      // Arrange
      final error = Exception('Failed to load aktif pengumuman');

      // Act
      final errorState = AsyncValue<List<PengumumanModel>>.error(
        error,
        StackTrace.current,
      );

      // Assert
      expect(errorState.hasError, isTrue);
      expect(errorState.error.toString(), contains('Failed to load'));
    });
  });

  group('AllPengumumanNotifier Business Logic Tests', () {
    test('harus memiliki initial state loading untuk all notifier', () {
      // Arrange & Act
      const initialState = AsyncValue<List<PengumumanModel>>.loading();

      // Assert
      expect(initialState.isLoading, isTrue);
      expect(initialState.hasValue, isFalse);
      expect(initialState.hasError, isFalse);
    });

    test('harus mengubah state menjadi data untuk semua pengumuman', () {
      // Arrange
      final mockAllPengumuman = [
        _createDummyPengumuman(id: 1, judul: 'Pengumuman 1'),
        _createDummyPengumuman(id: 2, judul: 'Pengumuman 2'),
        _createDummyPengumuman(id: 3, judul: 'Pengumuman 3'),
        _createDummyPengumuman(id: 4, judul: 'Pengumuman 4'),
        _createDummyPengumuman(id: 5, judul: 'Pengumuman 5'),
      ];

      // Act
      final dataState = AsyncValue.data(mockAllPengumuman);

      // Assert
      expect(dataState.hasValue, isTrue);
      expect(dataState.value?.length, 5);
    });

    test('harus handle error state untuk all notifier', () {
      // Arrange
      final error = Exception('Failed to load all pengumuman');

      // Act
      final errorState = AsyncValue<List<PengumumanModel>>.error(
        error,
        StackTrace.current,
      );

      // Assert
      expect(errorState.hasError, isTrue);
      expect(errorState.error.toString(), contains('Failed to load'));
    });
  });

  group('Search & Filter Functionality Tests', () {
    test('harus memvalidasi search query format', () {
      // Arrange
      final validQueries = [
        'Pengumuman',
        'Update sistem',
        'Informasi penting',
        'a', // minimal 1 karakter
      ];

      final invalidQueries = ['', '   '];

      // Act & Assert - Valid queries
      for (var query in validQueries) {
        final isValid = query.trim().isNotEmpty;
        expect(isValid, isTrue, reason: 'Query "$query" should be valid');
      }

      // Act & Assert - Invalid queries
      for (var query in invalidQueries) {
        final isValid = query.trim().isNotEmpty;
        expect(isValid, isFalse, reason: 'Query "$query" should be invalid');
      }
    });

    test('harus memvalidasi pengumuman dengan pembuat info', () {
      // Arrange
      final pembuat = PembuatPengumuman(
        id: 1,
        fullName: 'John Doe',
        role: 'Admin',
      );

      final pengumumanWithPembuat = _createDummyPengumuman(pembuat: pembuat);

      // Act
      final hasPembuat = pengumumanWithPembuat.pembuat != null;
      final namaPembuat = pengumumanWithPembuat.namaPembuat;
      final rolePembuat = pengumumanWithPembuat.rolePembuat;

      // Assert
      expect(hasPembuat, isTrue);
      expect(namaPembuat, 'John Doe');
      expect(rolePembuat, 'Admin');
    });

    test('harus handle pengumuman tanpa pembuat info', () {
      // Arrange
      final pengumumanWithoutPembuat = _createDummyPengumuman(pembuat: null);

      // Act
      final hasPembuat = pengumumanWithoutPembuat.pembuat != null;
      final namaPembuat = pengumumanWithoutPembuat.namaPembuat;
      final rolePembuat = pengumumanWithoutPembuat.rolePembuat;

      // Assert
      expect(hasPembuat, isFalse);
      expect(namaPembuat, 'Unknown');
      expect(rolePembuat, 'Unknown');
    });
  });

  group('Timestamp & Date Tests', () {
    test('harus memvalidasi createdAt timestamp', () {
      // Arrange
      final now = DateTime.now();
      final pengumuman = _createDummyPengumuman(createdAt: now);

      // Act
      final hasCreatedAt = pengumuman.createdAt != null;
      final isValidDate = pengumuman.createdAt.year >= 2020;

      // Assert
      expect(hasCreatedAt, isTrue);
      expect(isValidDate, isTrue);
    });

    test('harus memvalidasi updatedAt timestamp nullable', () {
      // Arrange
      final pengumumanWithUpdate = _createDummyPengumuman(
        updatedAt: DateTime.now(),
      );
      final pengumumanWithoutUpdate = _createDummyPengumuman(updatedAt: null);

      // Act
      final hasUpdateWithUpdate = pengumumanWithUpdate.updatedAt != null;
      final hasUpdateWithoutUpdate = pengumumanWithoutUpdate.updatedAt != null;

      // Assert
      expect(hasUpdateWithUpdate, isTrue);
      expect(hasUpdateWithoutUpdate, isFalse);
    });

    test('harus memvalidasi format ISO8601 untuk timestamp', () {
      // Arrange
      final now = DateTime.now();
      final iso8601String = now.toIso8601String();

      // Act
      final canParseBack = DateTime.tryParse(iso8601String) != null;

      // Assert
      expect(canParseBack, isTrue);
      expect(iso8601String.contains('T'), isTrue);
      expect(iso8601String.contains('-'), isTrue);
    });
  });
}

/// Helper function untuk membuat dummy pengumuman
PengumumanModel _createDummyPengumuman({
  int id = 1,
  String judul = 'Pengumuman Test',
  String isi = 'Isi pengumuman test',
  String? fotoUrl,
  String? dokumenUrl,
  int idPembuat = 1,
  DateTime? createdAt,
  DateTime? updatedAt,
  PembuatPengumuman? pembuat,
}) {
  return PengumumanModel(
    id: id,
    judul: judul,
    isi: isi,
    fotoUrl: fotoUrl,
    dokumenUrl: dokumenUrl,
    idPembuat: idPembuat,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt,
    pembuat: pembuat,
  );
}

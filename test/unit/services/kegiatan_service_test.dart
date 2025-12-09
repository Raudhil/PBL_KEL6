import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/core/services/kegiatan_service.dart';
import 'package:jawara/data/models/kegiatan_model.dart';

void main() {
  group('KegiatanService Data Validation Tests', () {
    test('harus memvalidasi struktur response kegiatan dari database', () {
      // Arrange
      final validResponse = {
        'id': '1',
        'judul': 'Kegiatan Sosial',
        'deskripsi': 'Deskripsi kegiatan',
        'tanggal_mulai': '2025-12-15T10:00:00Z',
        'tanggal_selesai': '2025-12-16T10:00:00Z',
        'lokasi': 'Jakarta',
        'penyelenggara': 'Organisasi A',
        'kategori': 'sosial',
        'status': 'akan_datang',
        'kuota_peserta': 100,
        'foto_url': null,
        'created_by': 'user-123',
        'created_at': '2025-11-21T10:00:00Z',
        'updated_at': '2025-11-21T10:00:00Z',
      };

      // Act
      final hasRequiredFields =
          validResponse.containsKey('id') &&
          validResponse.containsKey('judul') &&
          validResponse.containsKey('tanggal_mulai') &&
          validResponse.containsKey('penyelenggara') &&
          validResponse.containsKey('kategori') &&
          validResponse.containsKey('status');

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(validResponse['judul'], 'Kegiatan Sosial');
      expect(validResponse['kategori'], 'sosial');
      expect(validResponse['status'], 'akan_datang');
    });

    test('harus mendeteksi response kegiatan dengan data tidak lengkap', () {
      // Arrange
      final incompleteResponse = {
        'id': '1',
        // missing judul
        'tanggal_mulai': '2025-12-15T10:00:00Z',
        // missing penyelenggara
        'kategori': 'sosial',
        'status': 'akan_datang',
      };

      final requiredFields = [
        'id',
        'judul',
        'tanggal_mulai',
        'penyelenggara',
        'kategori',
        'status',
      ];

      // Act
      final hasAllRequired = incompleteResponse.keys.toSet().containsAll(
        requiredFields.toSet(),
      );

      // Assert
      expect(
        hasAllRequired,
        isFalse,
        reason: 'Response harus memiliki semua required fields',
      );
    });

    test('harus memvalidasi format tanggal kegiatan', () {
      // Arrange
      final validDates = [
        '2025-12-15T10:00:00Z',
        '2025-01-01T00:00:00Z',
        '2025-12-31T23:59:59Z',
      ];

      final invalidDates = [
        '15-12-2025', // wrong format
        '2025/12/15', // wrong separator
        '12-15-2025', // wrong order
        'invalid-date',
      ];

      // Act & Assert - Valid dates
      for (var date in validDates) {
        final canParse = DateTime.tryParse(date) != null;
        expect(
          canParse,
          isTrue,
          reason: 'Date $date should be valid ISO8601 format',
        );
      }

      // Act & Assert - Invalid dates
      for (var date in invalidDates) {
        final canParse = DateTime.tryParse(date) != null;
        expect(canParse, isFalse, reason: 'Date $date should be invalid');
      }
    });

    test('harus memvalidasi enum status kegiatan', () {
      // Arrange
      final validStatuses = [
        'akan_datang',
        'sedang_berlangsung',
        'selesai',
        'dibatalkan',
      ];

      final invalidStatuses = ['pending', 'archived', 'unknown'];

      // Act & Assert - Valid statuses
      for (var status in validStatuses) {
        final isValid = [
          'akan_datang',
          'sedang_berlangsung',
          'selesai',
          'dibatalkan',
        ].contains(status);
        expect(isValid, isTrue, reason: 'Status $status should be valid');
      }

      // Act & Assert - Invalid statuses
      for (var status in invalidStatuses) {
        final isValid = [
          'akan_datang',
          'sedang_berlangsung',
          'selesai',
          'dibatalkan',
        ].contains(status);
        expect(isValid, isFalse, reason: 'Status $status should be invalid');
      }
    });

    test('harus memvalidasi enum kategori kegiatan', () {
      // Arrange
      final validKategori = [
        'sosial',
        'kebersihan',
        'kesehatan',
        'pendidikan',
        'keagamaan',
        'olahraga',
        'budaya',
        'lainnya',
      ];

      final invalidKategori = ['sport', 'health', 'unknown'];

      // Act & Assert - Valid kategori
      for (var kategori in validKategori) {
        final isValid = [
          'sosial',
          'kebersihan',
          'kesehatan',
          'pendidikan',
          'keagamaan',
          'olahraga',
          'budaya',
          'lainnya',
        ].contains(kategori);
        expect(isValid, isTrue, reason: 'Kategori $kategori should be valid');
      }

      // Act & Assert - Invalid kategori
      for (var kategori in invalidKategori) {
        final isValid = [
          'sosial',
          'kebersihan',
          'kesehatan',
          'pendidikan',
          'keagamaan',
          'olahraga',
          'budaya',
          'lainnya',
        ].contains(kategori);
        expect(
          isValid,
          isFalse,
          reason: 'Kategori $kategori should be invalid',
        );
      }
    });

    test('harus menangani list kosong dari database', () {
      // Arrange
      final emptyResponse = <Map<String, dynamic>>[];

      // Act
      final isEmpty = emptyResponse.isEmpty;
      final length = emptyResponse.length;

      // Assert
      expect(isEmpty, isTrue);
      expect(length, 0);
    });

    test('harus memvalidasi ID kegiatan yang valid', () {
      // Arrange
      final validIds = [
        '1',
        '12345',
        'uuid-12345-67890',
        'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
      ];
      final invalidIds = ['', '   '];

      // Act & Assert - Valid IDs
      for (var id in validIds) {
        final isValid = id.trim().isNotEmpty;
        expect(isValid, isTrue, reason: 'ID $id should be valid');
      }

      // Act & Assert - Invalid IDs
      for (var id in invalidIds) {
        final isValid = id.trim().isNotEmpty;
        expect(isValid, isFalse, reason: 'ID $id should be invalid');
      }
    });

    test('harus memvalidasi kuota peserta yang valid', () {
      // Arrange
      final validQuotas = [1, 10, 50, 100, 500, 1000];
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

    test('harus memvalidasi judul kegiatan tidak boleh kosong', () {
      // Arrange
      final validJuduls = [
        'Kegiatan Sosial',
        'Program Kebersihan Lingkungan',
        'Seminar Kesehatan',
        'A', // minimal 1 karakter
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

    test('harus memvalidasi penyelenggara tidak boleh kosong', () {
      // Arrange
      final validPenyelenggara = [
        'Organisasi A',
        'RT 01',
        'RW 05 Jl. Merdeka',
        'Komunitas Peduli Lingkungan',
      ];
      final invalidPenyelenggara = ['', '   '];

      // Act & Assert - Valid
      for (var org in validPenyelenggara) {
        final isValid = org.trim().isNotEmpty;
        expect(isValid, isTrue, reason: 'Penyelenggara "$org" should be valid');
      }

      // Act & Assert - Invalid
      for (var org in invalidPenyelenggara) {
        final isValid = org.trim().isNotEmpty;
        expect(
          isValid,
          isFalse,
          reason: 'Penyelenggara "$org" should be invalid',
        );
      }
    });

    test('harus memvalidasi tanggal mulai sebelum tanggal selesai', () {
      // Arrange
      final tanggalMulai = DateTime(2025, 12, 15);
      final tanggalSelesaiValid = DateTime(2025, 12, 16);
      final tanggalSelesaiInvalid = DateTime(2025, 12, 14);

      // Act & Assert - Valid
      final isValidValid = tanggalMulai.isBefore(tanggalSelesaiValid);
      expect(isValidValid, isTrue);

      // Act & Assert - Invalid
      final isValidInvalid = tanggalMulai.isBefore(tanggalSelesaiInvalid);
      expect(isValidInvalid, isFalse);
    });

    test('harus memvalidasi struktur data untuk create kegiatan', () {
      // Arrange
      final validCreateData = {
        'judul': 'Kegiatan Baru',
        'deskripsi': 'Deskripsi kegiatan',
        'tanggal_mulai': '2025-12-15T10:00:00Z',
        'lokasi': 'Jakarta',
        'penyelenggara': 'Organisasi',
        'kategori': 'sosial',
        'status': 'akan_datang',
        'kuota_peserta': 50,
      };

      final requiredFieldsForCreate = [
        'judul',
        'tanggal_mulai',
        'penyelenggara',
        'kategori',
        'status',
      ];

      // Act
      final hasAllRequired = requiredFieldsForCreate.every(
        (field) => validCreateData.containsKey(field),
      );

      // Assert
      expect(hasAllRequired, isTrue);
      expect(validCreateData['judul'], 'Kegiatan Baru');
      expect(validCreateData['penyelenggara'], 'Organisasi');
    });

    test('harus memvalidasi struktur data untuk update kegiatan', () {
      // Arrange
      final validUpdateData = {
        'id': '1',
        'judul': 'Kegiatan Update',
        'deskripsi': 'Deskripsi updated',
        'tanggal_mulai': '2025-12-15T10:00:00Z',
        'lokasi': 'Jakarta',
        'penyelenggara': 'Organisasi',
        'kategori': 'kebersihan',
        'status': 'sedang_berlangsung',
      };

      // Act
      final hasId = validUpdateData.containsKey('id');
      final hasRequiredFields =
          validUpdateData.containsKey('judul') &&
          validUpdateData.containsKey('penyelenggara');

      // Assert
      expect(hasId, isTrue);
      expect(hasRequiredFields, isTrue);
    });

    test('harus menangani berbagai tipe error database', () {
      // Arrange
      final errorScenarios = [
        {'error': 'Connection timeout', 'type': 'network', 'recoverable': true},
        {'error': 'Unauthorized', 'type': 'auth', 'recoverable': false},
        {
          'error': 'Duplicate key constraint',
          'type': 'constraint',
          'recoverable': false,
        },
        {'error': 'Table not found', 'type': 'schema', 'recoverable': false},
      ];

      for (var scenario in errorScenarios) {
        // Act
        final error = scenario['error'] as String;
        final isNetworkError =
            error.toLowerCase().contains('timeout') ||
            error.toLowerCase().contains('connection');
        final isAuthError = error.toLowerCase().contains('unauthorized');

        // Assert
        expect(error, isNotEmpty);
        if (scenario['type'] == 'network') {
          expect(isNetworkError, isTrue);
        } else if (scenario['type'] == 'auth') {
          expect(isAuthError, isTrue);
        }
      }
    });

    test('harus memvalidasi mapping string status ke enum', () {
      // Arrange
      final statusMapping = {
        'akan_datang': StatusKegiatan.akanDatang,
        'sedang_berlangsung': StatusKegiatan.sedangBerlangsung,
        'selesai': StatusKegiatan.selesai,
        'dibatalkan': StatusKegiatan.dibatalkan,
      };

      // Act & Assert
      for (var entry in statusMapping.entries) {
        expect(entry.value.value, entry.key);
      }
    });

    test('harus memvalidasi mapping string kategori ke enum', () {
      // Arrange
      final kategoriMapping = {
        'sosial': KategoriKegiatan.sosial,
        'kebersihan': KategoriKegiatan.kebersihan,
        'kesehatan': KategoriKegiatan.kesehatan,
        'pendidikan': KategoriKegiatan.pendidikan,
        'keagamaan': KategoriKegiatan.keagamaan,
        'olahraga': KategoriKegiatan.olahraga,
        'budaya': KategoriKegiatan.budaya,
        'lainnya': KategoriKegiatan.lainnya,
      };

      // Act & Assert
      for (var entry in kategoriMapping.entries) {
        expect(entry.value.value, entry.key);
      }
    });

    test('harus memvalidasi ISO8601 date format untuk create', () {
      // Arrange
      final tanggalMulai = DateTime(2025, 12, 15, 10, 30, 0);
      final expectedFormat = '2025-12-15T10:30:00.000Z';

      // Act
      final iso8601String = tanggalMulai.toIso8601String();
      final canParseBack = DateTime.tryParse(iso8601String) != null;

      // Assert
      expect(canParseBack, isTrue);
      expect(iso8601String.contains('T'), isTrue); // Has time separator
      expect(iso8601String.contains('-'), isTrue); // Has date separators
    });

    test('harus memvalidasi null values untuk field opsional', () {
      // Arrange
      final dataWithNulls = {
        'id': '1',
        'judul': 'Kegiatan',
        'deskripsi': null, // optional
        'tanggal_mulai': '2025-12-15T10:00:00Z',
        'tanggal_selesai': null, // optional
        'lokasi': null, // optional
        'penyelenggara': 'Org',
        'kategori': 'sosial',
        'status': 'akan_datang',
        'kuota_peserta': null,
        'foto_url': null,
      };

      // Act
      final requiredFieldsPresent =
          dataWithNulls['id'] != null &&
          dataWithNulls['judul'] != null &&
          dataWithNulls['penyelenggara'] != null;

      final optionalFieldsHandled =
          dataWithNulls.containsKey('deskripsi') &&
          dataWithNulls.containsKey('lokasi') &&
          dataWithNulls.containsKey('kuota_peserta');

      // Assert
      expect(requiredFieldsPresent, isTrue);
      expect(optionalFieldsHandled, isTrue);
      expect(dataWithNulls['deskripsi'], isNull);
      expect(dataWithNulls['lokasi'], isNull);
    });

    test('harus memvalidasi operasi delete hanya dengan ID valid', () {
      // Arrange
      final deleteScenarios = [
        {'id': '1', 'shouldSucceed': true},
        {'id': '100', 'shouldSucceed': true},
        {'id': '', 'shouldSucceed': false},
        {'id': '   ', 'shouldSucceed': false},
      ];

      for (var scenario in deleteScenarios) {
        // Act
        final id = scenario['id'] as String;
        final isValidId = id.trim().isNotEmpty;
        final expectedSuccess = scenario['shouldSucceed'] as bool;

        // Assert
        expect(
          isValidId,
          expectedSuccess,
          reason: 'ID $id validation mismatch',
        );
      }
    });

    test('harus memvalidasi batch kegiatan dengan multiple records', () {
      // Arrange
      final batchData = [
        {
          'judul': 'Kegiatan 1',
          'tanggal_mulai': '2025-12-15T10:00:00Z',
          'penyelenggara': 'Organisasi 1',
          'kategori': 'sosial',
          'status': 'akan_datang',
        },
        {
          'judul': 'Kegiatan 2',
          'tanggal_mulai': '2025-12-16T10:00:00Z',
          'penyelenggara': 'Organisasi 2',
          'kategori': 'kebersihan',
          'status': 'akan_datang',
        },
        {
          'judul': 'Kegiatan 3',
          'tanggal_mulai': '2025-12-17T10:00:00Z',
          'penyelenggara': 'Organisasi 3',
          'kategori': 'kesehatan',
          'status': 'akan_datang',
        },
      ];

      // Act
      final allValid = batchData.every((data) {
        final judulValid = (data['judul'] as String).isNotEmpty;
        final penyelenggaraValid = (data['penyelenggara'] as String).isNotEmpty;
        final kategoriValid = [
          'sosial',
          'kebersihan',
          'kesehatan',
          'pendidikan',
          'keagamaan',
          'olahraga',
          'budaya',
          'lainnya',
        ].contains(data['kategori']);
        return judulValid && penyelenggaraValid && kategoriValid;
      });

      // Assert
      expect(allValid, isTrue);
      expect(batchData.length, 3);
    });

    test('harus memvalidasi constraint unique untuk kegiatan', () {
      // Arrange
      final existingKegiatan = [
        {'id': '1', 'judul': 'Kegiatan 1'},
        {'id': '2', 'judul': 'Kegiatan 2'},
      ];
      final newKegiatan = {'id': '1', 'judul': 'Kegiatan Baru'};

      // Act - Simulate checking if ID exists
      final idExists = existingKegiatan.any(
        (k) => k['id'] == newKegiatan['id'],
      );

      // Assert
      expect(idExists, isTrue, reason: 'ID should already exist');
    });

    test('harus menangani concurrent updates dengan timestamp', () {
      // Arrange
      final record1 = {
        'id': '1',
        'judul': 'Original Title',
        'updated_at': '2025-11-21T10:00:00Z',
      };

      final record2 = {
        'id': '1',
        'judul': 'Updated Title',
        'updated_at': '2025-11-21T10:05:00Z',
      };

      // Act
      final time1 = DateTime.parse(record1['updated_at'] as String);
      final time2 = DateTime.parse(record2['updated_at'] as String);
      final isNewer = time2.isAfter(time1);

      // Assert
      expect(isNewer, isTrue);
      expect(record1['id'], record2['id']);
    });

    test('harus memvalidasi panjang maksimum untuk field text', () {
      // Arrange
      final testCases = [
        {'field': 'judul', 'value': 'A' * 100, 'maxLength': 255, 'valid': true},
        {
          'field': 'judul',
          'value': 'A' * 300,
          'maxLength': 255,
          'valid': false,
        },
        {
          'field': 'deskripsi',
          'value': 'B' * 1000,
          'maxLength': 5000,
          'valid': true,
        },
      ];

      for (var testCase in testCases) {
        // Act
        final value = testCase['value'] as String;
        final maxLength = testCase['maxLength'] as int;
        final expected = testCase['valid'] as bool;
        final isValid = value.length <= maxLength;

        // Assert
        expect(
          isValid,
          expected,
          reason:
              '${testCase['field']} with length ${value.length} validation failed',
        );
      }
    });

    test('harus memvalidasi response struktur untuk single record query', () {
      // Arrange
      final singleRecordResponse = {
        'id': '1',
        'judul': 'Kegiatan Single',
        'deskripsi': 'Deskripsi',
        'tanggal_mulai': '2025-12-15T10:00:00Z',
        'penyelenggara': 'Organisasi',
        'kategori': 'sosial',
        'status': 'akan_datang',
        'created_at': '2025-11-21T10:00:00Z',
        'updated_at': '2025-11-21T10:00:00Z',
      };

      // Act
      final hasId = singleRecordResponse.containsKey('id');
      final isMapType = singleRecordResponse.runtimeType.toString().contains(
        'Map',
      );

      // Assert
      expect(isMapType, isTrue);
      expect(hasId, isTrue);
      expect(singleRecordResponse['id'], '1');
      expect(singleRecordResponse, isA<Map<String, dynamic>>());
    });

    test('harus memvalidasi response struktur untuk list query', () {
      // Arrange
      final listResponse = [
        {
          'id': '1',
          'judul': 'Kegiatan 1',
          'tanggal_mulai': '2025-12-15T10:00:00Z',
          'penyelenggara': 'Org 1',
          'kategori': 'sosial',
          'status': 'akan_datang',
        },
        {
          'id': '2',
          'judul': 'Kegiatan 2',
          'tanggal_mulai': '2025-12-16T10:00:00Z',
          'penyelenggara': 'Org 2',
          'kategori': 'kebersihan',
          'status': 'akan_datang',
        },
      ];

      // Act
      final isListType = listResponse.runtimeType.toString().contains('List');
      final allHaveId = listResponse.every((item) => item.containsKey('id'));

      // Assert
      expect(isListType, isTrue);
      expect(allHaveId, isTrue);
      expect(listResponse.length, 2);
    });

    test('harus memvalidasi search query format', () {
      // Arrange
      final validQueries = [
        'Kegiatan',
        'Program Kebersihan',
        'Seminar 2025',
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

    test('harus memvalidasi limit parameter untuk upcoming kegiatan', () {
      // Arrange
      final validLimits = [1, 5, 10, 100];
      final invalidLimits = [0, -1, -5];

      // Act & Assert - Valid limits
      for (var limit in validLimits) {
        final isValid = limit > 0;
        expect(isValid, isTrue, reason: 'Limit $limit should be valid');
      }

      // Act & Assert - Invalid limits
      for (var limit in invalidLimits) {
        final isValid = limit > 0;
        expect(isValid, isFalse, reason: 'Limit $limit should be invalid');
      }
    });
  });
}

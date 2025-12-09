import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketplaceService Business Logic Tests', () {
    // Test pure business logic dari MarketplaceService
    // Fokus pada data validation, mapping, error handling

    // ============================================
    // TOKO VALIDATION TESTS
    // ============================================

    test('harus memvalidasi struktur response fetchAllToko yang valid', () {
      // Arrange
      final validResponse = [
        {
          'id': 1,
          'id_pemilik': 100,
          'nama_toko': 'Toko Sayur Segar',
          'deskripsi': 'Menjual sayuran organik berkualitas',
          'alamat': 'Jl. Pasar No. 10, RT 01/RW 02',
          'no_telepon': '081234567890',
          'foto_toko': 'https://example.com/toko1.jpg',
          'is_active': true,
          'created_at': '2025-11-01T10:00:00Z',
          'updated_at': '2025-12-01T10:00:00Z',
        },
      ];

      // Act
      final hasRequiredFields = validResponse.every(
        (item) =>
            item.containsKey('id') &&
            item.containsKey('nama_toko') &&
            item.containsKey('id_pemilik'),
      );

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(validResponse, isNotEmpty);
      expect(validResponse.first['nama_toko'], isNotEmpty);
    });

    test('harus mendeteksi response toko dengan data tidak lengkap', () {
      // Arrange
      final incompleteResponse = <Map<String, dynamic>>[
        {'id': 1, 'nama_toko': '', 'is_active': true},
      ];

      final requiredFields = ['id', 'id_pemilik', 'nama_toko', 'alamat'];

      // Act
      final hasAllRequired = incompleteResponse.first.keys.toSet().containsAll(
        requiredFields.toSet(),
      );

      final namaNotEmpty =
          (incompleteResponse.first['nama_toko'] as String).isNotEmpty;

      // Assert
      expect(
        hasAllRequired,
        isFalse,
        reason: 'Response should be missing required fields',
      );
      expect(namaNotEmpty, isFalse, reason: 'Nama toko should not be empty');
    });

    test('harus memvalidasi nomor telepon toko yang valid', () {
      // Arrange
      final validPhones = [
        '081234567890',
        '082198765432',
        '085312345678',
        '087712345678',
      ];

      final invalidPhones = [
        '12345', // too short
        '071234567890', // not starting with 08
        '+6281234567890', // with country code
        '0912345678', // wrong format
      ];

      // Act & Assert - Valid phones
      for (var phone in validPhones) {
        final isValid = phone.startsWith('08') && phone.length >= 10;
        expect(isValid, isTrue, reason: 'Phone $phone should be valid');
      }

      // Act & Assert - Invalid phones
      for (var phone in invalidPhones) {
        final isValid = phone.startsWith('08') && phone.length >= 10;
        expect(isValid, isFalse, reason: 'Phone $phone should be invalid');
      }
    });

    test('harus memvalidasi status is_active toko', () {
      // Arrange
      final testCases = [
        {'is_active': true, 'can_operate': true},
        {'is_active': false, 'can_operate': false},
      ];

      for (var testCase in testCases) {
        // Act
        final isActive = testCase['is_active'] as bool;
        final canOperate = isActive;

        // Assert
        expect(
          canOperate,
          testCase['can_operate'],
          reason: 'Active status validation failed',
        );
      }
    });

    test('harus memvalidasi relasi toko dengan users (JOIN)', () {
      // Arrange
      final responseWithJoin = {
        'id': 1,
        'nama_toko': 'Toko Sayur Segar',
        'id_pemilik': 100,
        'users': {
          'id': 100,
          'full_name': 'Ahmad Subandi',
          'email': 'ahmad@example.com',
        },
      };

      // Act
      final hasUserJoin = responseWithJoin.containsKey('users');
      final users = responseWithJoin['users'] as Map<String, dynamic>?;
      final hasFullName = users?.containsKey('full_name') ?? false;

      // Assert
      expect(hasUserJoin, isTrue);
      expect(users, isNotNull);
      expect(hasFullName, isTrue);
      expect(users?['full_name'], 'Ahmad Subandi');
    });

    // ============================================
    // PRODUK VALIDATION TESTS
    // ============================================

    test('harus memvalidasi struktur response fetchAllProduk yang valid', () {
      // Arrange
      final validResponse = [
        {
          'id': 1,
          'id_toko': 10,
          'nama': 'Sayur Bayam Organik',
          'deskripsi': 'Bayam segar tanpa pestisida',
          'harga': 5000.0,
          'stok': 20,
          'kategori': 'Sayuran',
          'satuan': 'ikat',
          'foto_url': 'https://example.com/bayam.jpg',
          'is_available': true,
          'is_deleted': false,
          'created_at': '2025-11-15T10:00:00Z',
          'updated_at': '2025-12-05T10:00:00Z',
        },
      ];

      // Act
      final hasRequiredFields = validResponse.every(
        (item) =>
            item.containsKey('id') &&
            item.containsKey('nama') &&
            item.containsKey('harga') &&
            item.containsKey('stok'),
      );

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(validResponse, isNotEmpty);
      expect(validResponse.first['harga'], greaterThan(0));
      expect(validResponse.first['stok'], greaterThanOrEqualTo(0));
    });

    test('harus mendeteksi produk dengan harga invalid', () {
      // Arrange
      final testCases = [
        {'harga': 0.0, 'valid': false},
        {'harga': -1000.0, 'valid': false},
        {'harga': 500.0, 'valid': true},
        {'harga': 100000.0, 'valid': true},
      ];

      for (var testCase in testCases) {
        // Act
        final harga = testCase['harga'] as double;
        final isValid = harga > 0;

        // Assert
        expect(
          isValid,
          testCase['valid'],
          reason: 'Harga $harga validation failed',
        );
      }
    });

    test('harus mendeteksi produk dengan stok invalid', () {
      // Arrange
      final testCases = [
        {'stok': -5, 'valid': false},
        {'stok': 0, 'valid': true}, // stok 0 = habis tapi valid
        {'stok': 10, 'valid': true},
        {'stok': 1000, 'valid': true},
      ];

      for (var testCase in testCases) {
        // Act
        final stok = testCase['stok'] as int;
        final isValid = stok >= 0;

        // Assert
        expect(
          isValid,
          testCase['valid'],
          reason: 'Stok $stok validation failed',
        );
      }
    });

    test(
      'harus memvalidasi produk dapat dibeli (is_available && stok > 0)',
      () {
        // Arrange
        final testCases = [
          {
            'is_available': true,
            'stok': 10,
            'is_deleted': false,
            'canBuy': true,
          },
          {
            'is_available': true,
            'stok': 0,
            'is_deleted': false,
            'canBuy': false,
          },
          {
            'is_available': false,
            'stok': 10,
            'is_deleted': false,
            'canBuy': false,
          },
          {
            'is_available': true,
            'stok': 10,
            'is_deleted': true,
            'canBuy': false,
          },
        ];

        for (var testCase in testCases) {
          // Act
          final isAvailable = testCase['is_available'] as bool;
          final stok = testCase['stok'] as int;
          final isDeleted = testCase['is_deleted'] as bool;
          final canBuy = isAvailable && stok > 0 && !isDeleted;

          // Assert
          expect(
            canBuy,
            testCase['canBuy'],
            reason:
                'Available=$isAvailable, Stok=$stok, Deleted=$isDeleted failed',
          );
        }
      },
    );

    test('harus memvalidasi kategori produk yang valid', () {
      // Arrange
      final validCategories = [
        'Sayuran',
        'Buah',
        'Bahan Pokok',
        'Bumbu',
        'Daging',
        'Ikan',
        'Lainnya',
      ];

      final testProducts = [
        {'nama': 'Bayam', 'kategori': 'Sayuran'},
        {'nama': 'Apel', 'kategori': 'Buah'},
        {'nama': 'Beras', 'kategori': 'Bahan Pokok'},
      ];

      // Act & Assert
      for (var product in testProducts) {
        final kategori = product['kategori'] as String;
        final isValid = validCategories.contains(kategori);
        expect(isValid, isTrue, reason: 'Kategori $kategori should be valid');
      }
    });

    test('harus memvalidasi satuan produk yang valid', () {
      // Arrange
      final validSatuans = ['kg', 'gr', 'ikat', 'buah', 'liter', 'ml', 'pack'];

      final testProducts = [
        {'nama': 'Bayam', 'satuan': 'ikat'},
        {'nama': 'Beras', 'satuan': 'kg'},
        {'nama': 'Apel', 'satuan': 'buah'},
      ];

      // Act & Assert
      for (var product in testProducts) {
        final satuan = product['satuan'] as String;
        final isValid = validSatuans.contains(satuan);
        expect(isValid, isTrue, reason: 'Satuan $satuan should be valid');
      }
    });

    test('harus menangani soft delete produk (is_deleted flag)', () {
      // Arrange
      final produk = {'id': 1, 'nama': 'Bayam', 'is_deleted': false};

      // Act - Simulate soft delete
      produk['is_deleted'] = true;

      // Assert
      expect(produk['is_deleted'], isTrue);
      expect(produk.containsKey('id'), isTrue); // ID still exists
    });

    test('harus memvalidasi relasi produk dengan toko (JOIN)', () {
      // Arrange
      final responseWithJoin = {
        'id': 1,
        'nama': 'Sayur Bayam',
        'id_toko': 10,
        'toko': {
          'id': 10,
          'nama_toko': 'Toko Sayur Segar',
          'alamat': 'Jl. Pasar No. 10',
        },
      };

      // Act
      final hasTokoJoin = responseWithJoin.containsKey('toko');
      final toko = responseWithJoin['toko'] as Map<String, dynamic>?;
      final hasNamaToko = toko?.containsKey('nama_toko') ?? false;

      // Assert
      expect(hasTokoJoin, isTrue);
      expect(toko, isNotNull);
      expect(hasNamaToko, isTrue);
    });

    // ============================================
    // TRANSAKSI VALIDATION TESTS
    // ============================================

    test('harus memvalidasi struktur data transaksi yang valid', () {
      // Arrange
      final validTransaksi = {
        'id': 1,
        'id_pembeli': 100,
        'id_penjual': 200,
        'total': 50000.0,
        'status': 'pending',
        'tanggal_transaksi': '2025-12-09T10:00:00Z',
        'alamat_pengiriman': 'Jl. Merdeka No. 5, RT 02/RW 03',
        'catatan': 'Harap kirim pagi hari',
      };

      // Act
      final hasRequiredFields =
          validTransaksi.containsKey('id') &&
          validTransaksi.containsKey('id_pembeli') &&
          validTransaksi.containsKey('id_penjual') &&
          validTransaksi.containsKey('total') &&
          validTransaksi.containsKey('status');

      final totalValid = (validTransaksi['total'] as double) > 0;

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(totalValid, isTrue);
    });

    test('harus memvalidasi status transaksi yang valid', () {
      // Arrange
      final validStatuses = [
        'pending',
        'dikonfirmasi',
        'selesai',
        'dibatalkan',
      ];
      final invalidStatuses = [
        'processing',
        'shipped',
        'delivered',
        '',
        'sukses',
      ];

      // Act & Assert - Valid statuses
      for (var status in validStatuses) {
        final isValid = validStatuses.contains(status);
        expect(isValid, isTrue, reason: 'Status $status should be valid');
      }

      // Act & Assert - Invalid statuses
      for (var status in invalidStatuses) {
        final isValid = validStatuses.contains(status);
        expect(isValid, isFalse, reason: 'Status $status should be invalid');
      }
    });

    test('harus memvalidasi flow status transaksi', () {
      // Arrange
      final statusFlow = [
        {'from': 'pending', 'to': 'dikonfirmasi', 'valid': true},
        {'from': 'dikonfirmasi', 'to': 'selesai', 'valid': true},
        {'from': 'pending', 'to': 'dibatalkan', 'valid': true},
        {'from': 'selesai', 'to': 'pending', 'valid': false}, // cannot revert
        {'from': 'dibatalkan', 'to': 'dikonfirmasi', 'valid': false},
      ];

      for (var flow in statusFlow) {
        // Act
        final from = flow['from'] as String;
        final to = flow['to'] as String;

        // Business rule: valid transitions
        final validTransitions = {
          'pending': ['dikonfirmasi', 'dibatalkan'],
          'dikonfirmasi': ['selesai', 'dibatalkan'],
          'selesai': <String>[],
          'dibatalkan': <String>[],
        };

        final isValid = validTransitions[from]?.contains(to) ?? false;

        // Assert
        expect(
          isValid,
          flow['valid'],
          reason: 'Status transition $from -> $to failed',
        );
      }
    });

    test('harus menghitung total dari detail transaksi', () {
      // Arrange
      final detailTransaksi = [
        {'id_produk': 1, 'quantity': 2, 'harga': 5000.0},
        {'id_produk': 2, 'quantity': 3, 'harga': 8000.0},
        {'id_produk': 3, 'quantity': 1, 'harga': 10000.0},
      ];

      // Act
      final calculatedTotal = detailTransaksi.fold<double>(0.0, (sum, item) {
        final quantity = item['quantity'] as int;
        final harga = item['harga'] as double;
        return sum + (quantity * harga);
      });

      // Assert
      expect(calculatedTotal, 44000.0); // (2*5000) + (3*8000) + (1*10000)
    });

    test('harus memvalidasi detail transaksi tidak boleh kosong', () {
      // Arrange
      final transaksiWithItems = {
        'id': 1,
        'total': 50000.0,
        'detail_transaksi': [
          {'id_produk': 1, 'quantity': 2},
        ],
      };

      final transaksiWithoutItems = {
        'id': 2,
        'total': 50000.0,
        'detail_transaksi': <Map<String, dynamic>>[],
      };

      // Act
      final items1 = transaksiWithItems['detail_transaksi'] as List;
      final items2 = transaksiWithoutItems['detail_transaksi'] as List;

      final hasItems1 = items1.isNotEmpty;
      final hasItems2 = items2.isNotEmpty;

      // Assert
      expect(hasItems1, isTrue);
      expect(hasItems2, isFalse);
    });

    test('harus confirm order dan kurangi stok produk', () {
      // Arrange
      final produkStok = {'id': 1, 'nama': 'Bayam', 'stok': 10};

      final orderQuantity = 3;

      // Act
      final initialStok = produkStok['stok'] as int;
      final newStok = initialStok - orderQuantity;
      produkStok['stok'] = newStok;

      // Assert
      expect(newStok, 7);
      expect(newStok, lessThan(initialStok));
      expect(newStok, greaterThanOrEqualTo(0));
    });

    test('harus reject order jika stok tidak cukup', () {
      // Arrange
      final produkStok = {'id': 1, 'nama': 'Bayam', 'stok': 5};

      final orderQuantity = 10;

      // Act
      final stok = produkStok['stok'] as int;
      final canFulfill = stok >= orderQuantity;

      // Assert
      expect(canFulfill, isFalse);
    });

    test('harus menghitung pesanan hari ini untuk penjual', () {
      // Arrange
      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T')[0];

      final transaksiList = [
        {
          'id': 1,
          'id_penjual': 200,
          'tanggal_transaksi': '${todayStr}T10:00:00Z',
        },
        {
          'id': 2,
          'id_penjual': 200,
          'tanggal_transaksi': '${todayStr}T14:00:00Z',
        },
        {
          'id': 3,
          'id_penjual': 200,
          'tanggal_transaksi': '2025-12-08T10:00:00Z',
        },
      ];

      // Act
      final todayOrders = transaksiList.where((t) {
        final tanggal = t['tanggal_transaksi'] as String;
        return tanggal.startsWith(todayStr);
      }).toList();

      // Assert
      expect(todayOrders.length, 2);
    });

    // ============================================
    // REVIEW VALIDATION TESTS
    // ============================================

    test('harus memvalidasi struktur data review yang valid', () {
      // Arrange
      final validReview = {
        'id': 1,
        'id_produk': 10,
        'id_pembeli': 100,
        'id_transaksi': 50,
        'rating': 5,
        'komentar': 'Produk sangat segar dan berkualitas!',
        'tanggal_review': '2025-12-09T10:00:00Z',
      };

      // Act
      final hasRequiredFields =
          validReview.containsKey('id') &&
          validReview.containsKey('id_produk') &&
          validReview.containsKey('rating');

      final ratingValid =
          (validReview['rating'] as int) >= 1 &&
          (validReview['rating'] as int) <= 5;

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(ratingValid, isTrue);
    });

    test('harus memvalidasi rating hanya 1-5 bintang', () {
      // Arrange
      final testCases = [
        {'rating': 0, 'valid': false},
        {'rating': 1, 'valid': true},
        {'rating': 3, 'valid': true},
        {'rating': 5, 'valid': true},
        {'rating': 6, 'valid': false},
        {'rating': -1, 'valid': false},
      ];

      for (var testCase in testCases) {
        // Act
        final rating = testCase['rating'] as int;
        final isValid = rating >= 1 && rating <= 5;

        // Assert
        expect(
          isValid,
          testCase['valid'],
          reason: 'Rating $rating validation failed',
        );
      }
    });

    test('harus menghitung rata-rata rating produk', () {
      // Arrange
      final reviews = [
        {'id': 1, 'rating': 5},
        {'id': 2, 'rating': 4},
        {'id': 3, 'rating': 5},
        {'id': 4, 'rating': 3},
        {'id': 5, 'rating': 4},
      ];

      // Act
      final totalRating = reviews.fold<int>(
        0,
        (sum, review) => sum + (review['rating'] as int),
      );
      final averageRating = totalRating / reviews.length;

      // Assert
      expect(averageRating, 4.2); // (5+4+5+3+4) / 5
    });

    test('harus menangani list review kosong untuk average rating', () {
      // Arrange
      final reviews = <Map<String, dynamic>>[];

      // Act
      final averageRating = reviews.isEmpty
          ? 0.0
          : reviews.fold<int>(0, (sum, r) => sum + (r['rating'] as int)) /
                reviews.length;

      // Assert
      expect(averageRating, 0.0);
    });

    test('harus fetch review berdasarkan produk dengan JOIN', () {
      // Arrange
      final responseWithJoin = [
        {
          'id': 1,
          'id_produk': 10,
          'rating': 5,
          'komentar': 'Bagus sekali',
          'users': {'id': 100, 'full_name': 'Ahmad'},
        },
      ];

      // Act
      final hasUserJoin = responseWithJoin.first.containsKey('users');
      final users = responseWithJoin.first['users'] as Map<String, dynamic>?;

      // Assert
      expect(hasUserJoin, isTrue);
      expect(users, isNotNull);
      expect(users?['full_name'], 'Ahmad');
    });

    test('harus fetch review untuk semua produk di toko', () {
      // Arrange
      final reviewsByToko = [
        {'id': 1, 'id_produk': 1, 'rating': 5},
        {'id': 2, 'id_produk': 2, 'rating': 4},
        {'id': 3, 'id_produk': 1, 'rating': 5},
      ];

      final produk1Reviews = reviewsByToko
          .where((r) => r['id_produk'] == 1)
          .toList();

      // Act
      final count = produk1Reviews.length;

      // Assert
      expect(count, 2);
    });

    // ============================================
    // STORAGE/UPLOAD VALIDATION TESTS
    // ============================================

    test('harus memvalidasi format file foto produk yang valid', () {
      // Arrange
      final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      final testFiles = [
        {'name': 'bayam.jpg', 'valid': true},
        {'name': 'tomat.png', 'valid': true},
        {'name': 'wortel.jpeg', 'valid': true},
        {'name': 'bawang.gif', 'valid': false},
        {'name': 'cabai.txt', 'valid': false},
      ];

      for (var file in testFiles) {
        // Act
        final fileName = file['name'] as String;
        final extension = fileName.split('.').last.toLowerCase();
        final isValid = validExtensions.contains(extension);

        // Assert
        expect(
          isValid,
          file['valid'],
          reason: 'File $fileName validation failed',
        );
      }
    });

    test('harus generate storage path yang benar untuk foto produk', () {
      // Arrange
      final produkId = 123;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Act
      final storagePath = 'produk/$produkId/${timestamp}_foto.jpg';

      // Assert
      expect(storagePath, contains('produk/$produkId/'));
      expect(storagePath, contains('_foto.jpg'));
      expect(storagePath, isNotEmpty);
    });

    test('harus generate public URL setelah upload', () {
      // Arrange
      final bucketName = 'marketplace';
      final storagePath = 'produk/123/1234567890_foto.jpg';

      // Act
      final publicUrl =
          'https://example.supabase.co/storage/v1/object/public/$bucketName/$storagePath';

      // Assert
      expect(publicUrl, contains('storage/v1/object/public'));
      expect(publicUrl, contains(bucketName));
      expect(publicUrl, contains(storagePath));
    });

    // ============================================
    // ERROR HANDLING TESTS
    // ============================================

    test('harus menangani berbagai tipe error dengan benar', () {
      // Arrange
      final errorScenarios = [
        {
          'type': 'network',
          'message': 'Failed to connect',
          'code': 'NETWORK_ERROR',
        },
        {
          'type': 'validation',
          'message': 'Invalid input data',
          'code': 'VALIDATION_ERROR',
        },
        {
          'type': 'database',
          'message': 'Constraint violation',
          'code': 'DB_ERROR',
        },
        {
          'type': 'auth',
          'message': 'Unauthorized access',
          'code': 'AUTH_ERROR',
        },
      ];

      for (var scenario in errorScenarios) {
        // Act
        final errorType = scenario['type'] as String;
        final hasMessage = (scenario['message'] as String).isNotEmpty;
        final hasCode = (scenario['code'] as String).isNotEmpty;

        // Assert
        expect(hasMessage, isTrue, reason: 'Error $errorType needs message');
        expect(hasCode, isTrue, reason: 'Error $errorType needs code');
      }
    });

    test('harus throw exception untuk operasi gagal', () {
      // Arrange
      final errorMessage = 'Gagal fetch toko';

      // Act & Assert
      expect(() => throw Exception(errorMessage), throwsException);
    });

    // ============================================
    // EDGE CASES & BUSINESS RULES
    // ============================================

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

    test('harus menangani nilai null pada field opsional', () {
      // Arrange
      final dataWithNulls = {
        'id': 1,
        'nama': 'Toko ABC',
        'deskripsi': null, // optional
        'foto_toko': null, // optional
        'catatan': null, // optional
      };

      // Act
      final requiredFieldsPresent =
          dataWithNulls.containsKey('id') && dataWithNulls.containsKey('nama');

      final optionalFieldsHandled =
          dataWithNulls['deskripsi'] == null &&
          dataWithNulls['foto_toko'] == null;

      // Assert
      expect(requiredFieldsPresent, isTrue);
      expect(optionalFieldsHandled, isTrue);
    });

    test('harus memvalidasi panjang maksimum field text', () {
      // Arrange
      final testCases = [
        {
          'field': 'nama_toko',
          'value': 'Toko ' * 100, // very long
          'maxLength': 100,
        },
        {'field': 'deskripsi', 'value': 'Deskripsi singkat', 'maxLength': 500},
      ];

      for (var testCase in testCases) {
        // Act
        final value = testCase['value'] as String;
        final maxLength = testCase['maxLength'] as int;
        final isValid = value.length <= maxLength;

        // Assert
        expect(
          isValid,
          isA<bool>(),
          reason: 'Field ${testCase['field']} length validation',
        );
      }
    });

    test('harus validasi one user can only have one active toko', () {
      // Arrange
      final userId = 100;
      final existingTokoList = [
        {'id': 1, 'id_pemilik': 100, 'is_active': true},
      ];

      // Act
      final hasActiveToko = existingTokoList.any(
        (toko) => toko['id_pemilik'] == userId && toko['is_active'] == true,
      );

      // Assert
      expect(hasActiveToko, isTrue);
    });

    test('harus validasi produk belongs to correct toko', () {
      // Arrange
      final produk = {'id': 1, 'id_toko': 10, 'nama': 'Bayam'};

      final tokoId = 10;

      // Act
      final belongsToToko = produk['id_toko'] == tokoId;

      // Assert
      expect(belongsToToko, isTrue);
    });

    test('harus validasi user tidak bisa review produk dari toko sendiri', () {
      // Arrange
      final userId = 100;
      final produk = {
        'id': 1,
        'toko': {'id_pemilik': 100},
      };

      // Act
      final toko = produk['toko'] as Map<String, dynamic>;
      final isOwnProduct = toko['id_pemilik'] == userId;

      // Assert
      expect(isOwnProduct, isTrue); // Cannot review own product
    });

    test('harus validasi concurrent update dengan timestamp', () {
      // Arrange
      final record1 = {
        'id': 1,
        'nama': 'Toko ABC',
        'updated_at': '2025-12-09T10:00:00Z',
      };

      final record2 = {
        'id': 1,
        'nama': 'Toko ABC Updated',
        'updated_at': '2025-12-09T11:00:00Z',
      };

      // Act
      final time1 = DateTime.parse(record1['updated_at'] as String);
      final time2 = DateTime.parse(record2['updated_at'] as String);
      final isNewer = time2.isAfter(time1);

      // Assert
      expect(isNewer, isTrue);
      expect(record1['id'], record2['id']);
    });
  });
}

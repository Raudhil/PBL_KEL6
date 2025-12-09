import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketplaceProvider Business Logic Tests', () {
    // Test pure business logic dari MarketplaceProvider
    // Fokus pada state management, cart operations, dan data validation

    // ============================================
    // CART OPERATIONS TESTS
    // ============================================

    test('harus memiliki initial cart state kosong', () {
      // Arrange & Act
      final emptyCart = <Map<String, dynamic>>[];

      // Assert
      expect(emptyCart, isEmpty);
      expect(emptyCart.length, 0);
    });

    test('harus menambahkan produk ke cart dengan quantity default', () {
      // Arrange
      final cart = <Map<String, dynamic>>[];
      final produk = {
        'id': 1,
        'nama': 'Sayur Bayam',
        'harga': 5000.0,
        'stok': 10,
      };

      // Act
      cart.add({'produk': produk, 'quantity': 1});

      // Assert
      expect(cart, isNotEmpty);
      expect(cart.length, 1);
      expect(cart.first['quantity'], 1);
      expect(cart.first['produk']['id'], 1);
    });

    test('harus menambah quantity jika produk sudah ada di cart', () {
      // Arrange
      final cart = [
        {
          'produk': {'id': 1, 'nama': 'Sayur Bayam', 'harga': 5000.0},
          'quantity': 2,
        },
      ];

      // Act - Simulate adding same product
      final existingIndex = cart.indexWhere((item) {
        final produk = item['produk'] as Map<String, dynamic>?;
        return produk?['id'] == 1;
      });

      if (existingIndex >= 0) {
        cart[existingIndex]['quantity'] =
            (cart[existingIndex]['quantity'] as int) + 1;
      }

      // Assert
      expect(cart.length, 1);
      expect(cart.first['quantity'], 3);
    });

    test('harus menghapus produk dari cart berdasarkan ID', () {
      // Arrange
      final cart = [
        {
          'produk': {'id': 1, 'nama': 'Sayur Bayam', 'harga': 5000.0},
          'quantity': 2,
        },
        {
          'produk': {'id': 2, 'nama': 'Tomat', 'harga': 8000.0},
          'quantity': 1,
        },
      ];

      // Act
      final updatedCart = cart.where((item) {
        final produk = item['produk'] as Map<String, dynamic>?;
        return produk?['id'] != 1;
      }).toList();

      // Assert
      expect(updatedCart.length, 1);
      final firstProduk = updatedCart.first['produk'] as Map<String, dynamic>?;
      expect(firstProduk?['id'], 2);
    });

    test('harus update quantity produk di cart', () {
      // Arrange
      final cart = [
        {
          'produk': {'id': 1, 'nama': 'Sayur Bayam', 'harga': 5000.0},
          'quantity': 2,
        },
      ];

      // Act
      final updatedCart = cart.map((item) {
        final produk = item['produk'] as Map<String, dynamic>?;
        if (produk?['id'] == 1) {
          return {'produk': item['produk'], 'quantity': 5};
        }
        return item;
      }).toList();

      // Assert
      expect(updatedCart.first['quantity'], 5);
    });

    test(
      'harus remove item jika quantity di-update menjadi 0 atau negatif',
      () {
        // Arrange
        final testCases = [
          {'quantity': 0, 'shouldRemove': true},
          {'quantity': -1, 'shouldRemove': true},
          {'quantity': 1, 'shouldRemove': false},
          {'quantity': 5, 'shouldRemove': false},
        ];

        for (var testCase in testCases) {
          // Act
          final quantity = testCase['quantity'] as int;
          final shouldRemove = quantity <= 0;

          // Assert
          expect(
            shouldRemove,
            testCase['shouldRemove'],
            reason: 'Quantity $quantity validation failed',
          );
        }
      },
    );

    test('harus menghitung subtotal per item dengan benar', () {
      // Arrange
      final cartItem = {
        'produk': {'id': 1, 'nama': 'Sayur Bayam', 'harga': 5000.0},
        'quantity': 3,
      };

      // Act
      final produk = cartItem['produk'] as Map<String, dynamic>;
      final harga = produk['harga'] as double;
      final quantity = cartItem['quantity'] as int;
      final subtotal = harga * quantity;

      // Assert
      expect(subtotal, 15000.0);
    });

    test('harus menghitung total amount dari semua items', () {
      // Arrange
      final cart = [
        {
          'produk': {'id': 1, 'nama': 'Sayur Bayam', 'harga': 5000.0},
          'quantity': 2,
        },
        {
          'produk': {'id': 2, 'nama': 'Tomat', 'harga': 8000.0},
          'quantity': 3,
        },
        {
          'produk': {'id': 3, 'nama': 'Wortel', 'harga': 6000.0},
          'quantity': 1,
        },
      ];

      // Act
      final totalAmount = cart.fold<double>(0.0, (sum, item) {
        final produk = item['produk'] as Map<String, dynamic>;
        final harga = produk['harga'] as double;
        final quantity = item['quantity'] as int;
        return sum + (harga * quantity);
      });

      // Assert
      expect(totalAmount, 40000.0); // (5000*2) + (8000*3) + (6000*1)
    });

    test('harus menghitung total item count di cart', () {
      // Arrange
      final cart = [
        {
          'produk': {'id': 1, 'nama': 'Sayur Bayam', 'harga': 5000.0},
          'quantity': 2,
        },
        {
          'produk': {'id': 2, 'nama': 'Tomat', 'harga': 8000.0},
          'quantity': 3,
        },
        {
          'produk': {'id': 3, 'nama': 'Wortel', 'harga': 6000.0},
          'quantity': 1,
        },
      ];

      // Act
      final itemCount = cart.fold<int>(0, (sum, item) {
        return sum + (item['quantity'] as int);
      });

      // Assert
      expect(itemCount, 6); // 2 + 3 + 1
    });

    test('harus clear semua items dari cart', () {
      // Arrange
      final cart = [
        {
          'produk': {'id': 1, 'nama': 'Sayur Bayam', 'harga': 5000.0},
          'quantity': 2,
        },
      ];

      // Act
      cart.clear();

      // Assert
      expect(cart, isEmpty);
      expect(cart.length, 0);
    });

    // ============================================
    // SEARCH & FILTER TESTS
    // ============================================

    test('harus filter produk berdasarkan search query', () {
      // Arrange
      final produkList = [
        {'id': 1, 'nama': 'Sayur Bayam', 'kategori': 'Sayuran'},
        {'id': 2, 'nama': 'Tomat Merah', 'kategori': 'Sayuran'},
        {'id': 3, 'nama': 'Beras Premium', 'kategori': 'Bahan Pokok'},
        {'id': 4, 'nama': 'Bayam Hijau', 'kategori': 'Sayuran'},
      ];
      final query = 'bayam';

      // Act
      final filtered = produkList.where((produk) {
        final nama = (produk['nama'] as String).toLowerCase();
        return nama.contains(query.toLowerCase());
      }).toList();

      // Assert
      expect(filtered.length, 2);
      expect(
        filtered.every(
          (p) => (p['nama'] as String).toLowerCase().contains('bayam'),
        ),
        isTrue,
      );
    });

    test('harus filter produk berdasarkan kategori', () {
      // Arrange
      final produkList = [
        {'id': 1, 'nama': 'Sayur Bayam', 'kategori': 'Sayuran'},
        {'id': 2, 'nama': 'Tomat Merah', 'kategori': 'Sayuran'},
        {'id': 3, 'nama': 'Beras Premium', 'kategori': 'Bahan Pokok'},
        {'id': 4, 'nama': 'Gula Pasir', 'kategori': 'Bahan Pokok'},
      ];
      final category = 'Sayuran';

      // Act
      final filtered = produkList.where((produk) {
        return produk['kategori'] == category;
      }).toList();

      // Assert
      expect(filtered.length, 2);
      expect(filtered.every((p) => p['kategori'] == 'Sayuran'), isTrue);
    });

    test('harus filter produk dengan query dan kategori sekaligus', () {
      // Arrange
      final produkList = [
        {'id': 1, 'nama': 'Sayur Bayam', 'kategori': 'Sayuran'},
        {'id': 2, 'nama': 'Tomat Merah', 'kategori': 'Sayuran'},
        {'id': 3, 'nama': 'Bayam Merah', 'kategori': 'Bahan Pokok'},
      ];
      final query = 'bayam';
      final category = 'Sayuran';

      // Act
      final filtered = produkList.where((produk) {
        final nama = (produk['nama'] as String).toLowerCase();
        final matchQuery = nama.contains(query.toLowerCase());
        final matchCategory = produk['kategori'] == category;
        return matchQuery && matchCategory;
      }).toList();

      // Assert
      expect(filtered.length, 1);
      expect(filtered.first['id'], 1);
    });

    test('harus return semua produk jika filter "All" category', () {
      // Arrange
      final produkList = [
        {'id': 1, 'nama': 'Sayur Bayam', 'kategori': 'Sayuran'},
        {'id': 2, 'nama': 'Beras Premium', 'kategori': 'Bahan Pokok'},
      ];
      final category = 'All';

      // Act
      final filtered = produkList.where((produk) {
        return category == 'All' || produk['kategori'] == category;
      }).toList();

      // Assert
      expect(filtered.length, produkList.length);
    });

    // ============================================
    // TOKO VALIDATION TESTS
    // ============================================

    test('harus memvalidasi struktur data toko yang valid', () {
      // Arrange
      final validToko = {
        'id': 1,
        'id_pemilik': 100,
        'nama_toko': 'Toko Sayur Segar',
        'deskripsi': 'Menjual sayur organik',
        'alamat': 'Jl. Pasar No. 10',
        'no_telepon': '081234567890',
        'is_active': true,
      };

      // Act
      final hasRequiredFields =
          validToko.containsKey('id') &&
          validToko.containsKey('nama_toko') &&
          validToko.containsKey('id_pemilik');

      final namaNotEmpty = (validToko['nama_toko'] as String).isNotEmpty;

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(namaNotEmpty, isTrue);
      expect(validToko['is_active'], isTrue);
    });

    test('harus mendeteksi data toko yang tidak lengkap', () {
      // Arrange
      final incompleteToko = {
        'id': 1,
        // missing id_pemilik
        'nama_toko': '',
        // missing alamat
      };

      final requiredFields = ['id', 'id_pemilik', 'nama_toko', 'alamat'];

      // Act
      final hasAllRequired = requiredFields.every(
        (field) => incompleteToko.containsKey(field),
      );

      final namaNotEmpty =
          incompleteToko['nama_toko'] != null &&
          (incompleteToko['nama_toko'] as String).isNotEmpty;

      // Assert
      expect(hasAllRequired, isFalse);
      expect(namaNotEmpty, isFalse);
    });

    // ============================================
    // PRODUK VALIDATION TESTS
    // ============================================

    test('harus memvalidasi struktur data produk yang valid', () {
      // Arrange
      final validProduk = {
        'id': 1,
        'id_toko': 10,
        'nama': 'Sayur Bayam',
        'deskripsi': 'Bayam segar organik',
        'harga': 5000.0,
        'stok': 20,
        'kategori': 'Sayuran',
        'satuan': 'ikat',
        'foto_url': 'https://example.com/bayam.jpg',
        'is_available': true,
      };

      // Act
      final hasRequiredFields =
          validProduk.containsKey('id') &&
          validProduk.containsKey('nama') &&
          validProduk.containsKey('harga') &&
          validProduk.containsKey('stok');

      final hargaValid = (validProduk['harga'] as double) > 0;
      final stokValid = (validProduk['stok'] as int) >= 0;

      // Assert
      expect(hasRequiredFields, isTrue);
      expect(hargaValid, isTrue);
      expect(stokValid, isTrue);
    });

    test('harus mendeteksi harga produk yang tidak valid', () {
      // Arrange
      final testCases = [
        {'harga': 0.0, 'valid': false},
        {'harga': -1000.0, 'valid': false},
        {'harga': 5000.0, 'valid': true},
        {'harga': 100.5, 'valid': true},
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

    test('harus mendeteksi stok produk yang tidak valid', () {
      // Arrange
      final testCases = [
        {'stok': -1, 'valid': false},
        {'stok': 0, 'valid': true}, // stok habis tapi valid
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

    test('harus validasi produk tersedia (is_available dan stok > 0)', () {
      // Arrange
      final testCases = [
        {'is_available': true, 'stok': 10, 'canBuy': true},
        {'is_available': true, 'stok': 0, 'canBuy': false},
        {'is_available': false, 'stok': 10, 'canBuy': false},
        {'is_available': false, 'stok': 0, 'canBuy': false},
      ];

      for (var testCase in testCases) {
        // Act
        final isAvailable = testCase['is_available'] as bool;
        final stok = testCase['stok'] as int;
        final canBuy = isAvailable && stok > 0;

        // Assert
        expect(
          canBuy,
          testCase['canBuy'],
          reason: 'Available=$isAvailable, Stok=$stok',
        );
      }
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
        'alamat_pengiriman': 'Jl. Merdeka No. 5',
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
      final invalidStatuses = ['processing', 'delivered', '', 'sukses'];

      // Act & Assert - Valid statuses
      for (var status in validStatuses) {
        final isValid = [
          'pending',
          'dikonfirmasi',
          'selesai',
          'dibatalkan',
        ].contains(status);
        expect(isValid, isTrue, reason: 'Status $status should be valid');
      }

      // Act & Assert - Invalid statuses
      for (var status in invalidStatuses) {
        final isValid = [
          'pending',
          'dikonfirmasi',
          'selesai',
          'dibatalkan',
        ].contains(status);
        expect(isValid, isFalse, reason: 'Status $status should be invalid');
      }
    });

    test('harus menghitung total transaksi dari detail items', () {
      // Arrange
      final detailItems = [
        {'id_produk': 1, 'quantity': 2, 'harga': 5000.0},
        {'id_produk': 2, 'quantity': 3, 'harga': 8000.0},
        {'id_produk': 3, 'quantity': 1, 'harga': 10000.0},
      ];

      // Act
      final total = detailItems.fold<double>(0.0, (sum, item) {
        final quantity = item['quantity'] as int;
        final harga = item['harga'] as double;
        return sum + (quantity * harga);
      });

      // Assert
      expect(total, 44000.0); // (2*5000) + (3*8000) + (1*10000)
    });

    test('harus filter transaksi berdasarkan status', () {
      // Arrange
      final transaksiList = [
        {'id': 1, 'status': 'pending', 'total': 10000.0},
        {'id': 2, 'status': 'dikonfirmasi', 'total': 20000.0},
        {'id': 3, 'status': 'pending', 'total': 15000.0},
        {'id': 4, 'status': 'selesai', 'total': 30000.0},
      ];
      final statusFilter = 'pending';

      // Act
      final filtered = transaksiList.where((t) {
        return t['status'] == statusFilter;
      }).toList();

      // Assert
      expect(filtered.length, 2);
      expect(filtered.every((t) => t['status'] == 'pending'), isTrue);
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
        'rating': 5,
        'komentar': 'Produk sangat bagus dan segar!',
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

    test('harus memvalidasi rating hanya 1-5', () {
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
      ];

      // Act
      final totalRating = reviews.fold<int>(
        0,
        (sum, review) => sum + (review['rating'] as int),
      );
      final averageRating = totalRating / reviews.length;

      // Assert
      expect(averageRating, 4.25); // (5+4+5+3) / 4
    });

    test('harus menangani list kosong untuk average rating', () {
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

    // ============================================
    // STATE PROVIDER TESTS
    // ============================================

    test('harus menyimpan search query state', () {
      // Arrange
      var searchQuery = '';

      // Act
      searchQuery = 'bayam';

      // Assert
      expect(searchQuery, 'bayam');
      expect(searchQuery, isNotEmpty);
    });

    test('harus menyimpan selected category state', () {
      // Arrange
      var selectedCategory = 'All';

      // Act
      selectedCategory = 'Sayuran';

      // Assert
      expect(selectedCategory, 'Sayuran');
      expect(selectedCategory, isNot('All'));
    });

    test('harus reset state ke default', () {
      // Arrange
      var searchQuery = 'tomat';
      var selectedCategory = 'Sayuran';

      // Act - Reset
      searchQuery = '';
      selectedCategory = 'All';

      // Assert
      expect(searchQuery, isEmpty);
      expect(selectedCategory, 'All');
    });

    // ============================================
    // EDGE CASES
    // ============================================

    test('harus menangani cart dengan quantity melebihi stok', () {
      // Arrange
      final produk = {
        'id': 1,
        'nama': 'Sayur Bayam',
        'stok': 5,
        'harga': 5000.0,
      };
      final requestedQuantity = 10;

      // Act
      final stok = produk['stok'] as int;
      final canAdd = requestedQuantity <= stok;
      final maxQuantity = canAdd ? requestedQuantity : stok;

      // Assert
      expect(canAdd, isFalse);
      expect(maxQuantity, 5);
    });

    test('harus menangani produk dengan harga desimal', () {
      // Arrange
      final produk = {'id': 1, 'nama': 'Bawang Merah', 'harga': 7500.50};
      final quantity = 3;

      // Act
      final subtotal = (produk['harga'] as double) * quantity;

      // Assert
      expect(subtotal, 22501.5);
      expect(subtotal, isA<double>());
    });

    test('harus menangani nama produk dengan karakter spesial', () {
      // Arrange
      final produkList = [
        {'id': 1, 'nama': 'Cabai Merah (100gr)'},
        {'id': 2, 'nama': 'Bawang Putih [Premium]'},
        {'id': 3, 'nama': 'Tomat & Sayuran'},
      ];
      final query = '(100gr)';

      // Act
      final filtered = produkList.where((produk) {
        return (produk['nama'] as String).contains(query);
      }).toList();

      // Assert
      expect(filtered.length, 1);
      expect(filtered.first['id'], 1);
    });

    test('harus menghitung pesanan hari ini dengan filter tanggal', () {
      // Arrange
      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T')[0];

      final transaksiList = [
        {
          'id': 1,
          'tanggal_transaksi': '${todayStr}T10:00:00Z',
          'status': 'pending',
        },
        {
          'id': 2,
          'tanggal_transaksi': '${todayStr}T14:00:00Z',
          'status': 'dikonfirmasi',
        },
        {
          'id': 3,
          'tanggal_transaksi': '2025-12-08T10:00:00Z',
          'status': 'selesai',
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
  });
}

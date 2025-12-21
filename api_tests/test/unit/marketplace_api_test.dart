import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/test_config.dart';
import '../helpers/test_helper.dart';
import '../helpers/auth_helper.dart';

/// Test Marketplace API - Toko, Produk, Transaksi, Review
class MarketplaceApiTest {
  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
  int skippedTests = 0;

  Future<void> runAllTests() async {
    TestHelper.printTestHeader('MARKETPLACE API TESTS');

    // READ Operations
    await testGetAllToko();
    await testGetActiveProduk();
    await testGetProdukByToko();
    await testGetReviewByProduk();

    // CRUD Operations (Authenticated)
    if (TestConfig.enableAuthTests) {
      final hasAuth = await AuthHelper.isAuthAvailable();
      if (hasAuth) {
        await testCreateToko();
        await testUpdateProduk();
      } else {
        skippedTests += 2;
        print('\n⚠ CRUD tests skipped - Login failed');
      }
    } else {
      skippedTests += 2;
      print('\n⚠ CRUD tests disabled');
    }

    _printSummary();
  }

  /// Test: GET all toko
  Future<void> testGetAllToko() async {
    totalTests++;
    final testName = 'GET /toko - All stores';

    try {
      final response = await http
          .get(Uri.parse(TestConfig.tokoEndpoint), headers: TestConfig.headers)
          .timeout(TestConfig.timeout);

      final passed = TestHelper.isSuccessStatusCode(response.statusCode);

      if (passed) {
        final data = TestHelper.parseResponse(response) as List;
        print('✓ Retrieved ${data.length} toko records');
        passedTests++;
      } else {
        failedTests++;
      }

      TestHelper.printTestResult(testName, passed);
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Test: GET active produk (not deleted)
  Future<void> testGetActiveProduk() async {
    totalTests++;
    final testName = 'GET /produk?is_deleted=eq.false';

    try {
      final response = await http
          .get(
            Uri.parse('${TestConfig.produkEndpoint}?is_deleted=eq.false'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      final passed = TestHelper.isSuccessStatusCode(response.statusCode);

      if (passed) {
        final data = TestHelper.parseResponse(response) as List;
        print('✓ Retrieved ${data.length} active products');
        passedTests++;
      } else {
        failedTests++;
      }

      TestHelper.printTestResult(testName, passed);
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Test: GET produk by toko
  Future<void> testGetProdukByToko() async {
    totalTests++;
    final testName = 'GET /produk?id_toko=eq.{id}&is_deleted=eq.false';

    try {
      // Get first toko
      final tokoResponse = await http
          .get(
            Uri.parse('${TestConfig.tokoEndpoint}?limit=1'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      if (TestHelper.isSuccessStatusCode(tokoResponse.statusCode)) {
        final tokos = TestHelper.parseResponse(tokoResponse) as List;

        if (tokos.isNotEmpty) {
          final tokoId = tokos[0]['id'];

          final response = await http
              .get(
                Uri.parse(
                  '${TestConfig.produkEndpoint}?id_toko=eq.$tokoId&is_deleted=eq.false',
                ),
                headers: TestConfig.headers,
              )
              .timeout(TestConfig.timeout);

          final passed = TestHelper.isSuccessStatusCode(response.statusCode);

          if (passed) {
            final data = TestHelper.parseResponse(response) as List;
            print('✓ Retrieved ${data.length} products for toko $tokoId');
            passedTests++;
          } else {
            failedTests++;
          }

          TestHelper.printTestResult(testName, passed);
        } else {
          failedTests++;
          TestHelper.printTestResult(testName, false, message: 'No toko data');
        }
      } else {
        failedTests++;
        TestHelper.printTestResult(
          testName,
          false,
          message: 'Failed to fetch toko',
        );
      }
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Test: GET review by produk
  Future<void> testGetReviewByProduk() async {
    totalTests++;
    final testName = 'GET /review_produk?id_produk=eq.{id}';

    try {
      // Get first product
      final produkResponse = await http
          .get(
            Uri.parse('${TestConfig.produkEndpoint}?limit=1'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      if (TestHelper.isSuccessStatusCode(produkResponse.statusCode)) {
        final produks = TestHelper.parseResponse(produkResponse) as List;

        if (produks.isNotEmpty) {
          final produkId = produks[0]['id'];

          final response = await http
              .get(
                Uri.parse(
                  '${TestConfig.reviewProdukEndpoint}?id_produk=eq.$produkId',
                ),
                headers: TestConfig.headers,
              )
              .timeout(TestConfig.timeout);

          final passed = TestHelper.isSuccessStatusCode(response.statusCode);

          if (passed) {
            final data = TestHelper.parseResponse(response) as List;
            print('✓ Retrieved ${data.length} reviews for produk $produkId');
            passedTests++;
          } else {
            failedTests++;
          }

          TestHelper.printTestResult(testName, passed);
        } else {
          failedTests++;
          TestHelper.printTestResult(
            testName,
            false,
            message: 'No produk data',
          );
        }
      } else {
        failedTests++;
        TestHelper.printTestResult(
          testName,
          false,
          message: 'Failed to fetch produk',
        );
      }
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Test: CREATE new toko (Authenticated)
  Future<void> testCreateToko() async {
    totalTests++;
    final testName = 'POST /toko (Authenticated)';

    try {
      final accessToken = await AuthHelper.getAuthToken();
      if (accessToken == null) {
        skippedTests++;
        TestHelper.printTestResult(testName, false, message: 'No auth token');
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newToko = {
        'nama': 'Test Toko $timestamp',
        'id_pemilik': 5, // User ID yang valid dari schema
      };

      final response = await http
          .post(
            Uri.parse(TestConfig.tokoEndpoint),
            headers: TestConfig.headersWithAuth(accessToken),
            body: json.encode(newToko),
          )
          .timeout(TestConfig.timeout);

      final passed = response.statusCode == 201 || response.statusCode == 200;

      if (passed) {
        final data = TestHelper.parseResponse(response);
        print('✓ Created toko: ${newToko['nama_toko']}');

        if (data is List && data.isNotEmpty) {
          final createdId = data[0]['id'];
          await _cleanupToko(createdId, accessToken);
        }

        passedTests++;
      } else {
        print('✗ Failed: ${response.statusCode} - ${response.body}');
        failedTests++;
      }

      TestHelper.printTestResult(testName, passed);
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Test: UPDATE produk (Authenticated)
  Future<void> testUpdateProduk() async {
    totalTests++;
    final testName = 'PUT /produk/{id} (Authenticated)';

    try {
      final accessToken = await AuthHelper.getAuthToken();
      if (accessToken == null) {
        skippedTests++;
        TestHelper.printTestResult(testName, false, message: 'No auth token');
        return;
      }

      // Get existing produk to update
      final produkResponse = await http
          .get(
            Uri.parse(
              '${TestConfig.produkEndpoint}?limit=1&is_deleted=eq.false',
            ),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      if (TestHelper.isSuccessStatusCode(produkResponse.statusCode)) {
        final produkList = TestHelper.parseResponse(produkResponse) as List;

        if (produkList.isNotEmpty) {
          final produkId = produkList[0]['id'];
          final timestamp = DateTime.now().millisecondsSinceEpoch;

          final updateData = {
            'deskripsi': 'Updated description $timestamp',
            'harga': 75000,
          };

          final response = await http
              .patch(
                Uri.parse('${TestConfig.produkEndpoint}?id=eq.$produkId'),
                headers: TestConfig.headersWithAuth(accessToken),
                body: json.encode(updateData),
              )
              .timeout(TestConfig.timeout);

          final passed =
              response.statusCode == 200 || response.statusCode == 204;

          if (passed) {
            print('✓ Updated produk ID: $produkId');
            passedTests++;
          } else {
            print('✗ Failed: ${response.statusCode}');
            failedTests++;
          }

          TestHelper.printTestResult(testName, passed);
        } else {
          skippedTests++;
          TestHelper.printTestResult(
            testName,
            false,
            message: 'No produk to update',
          );
        }
      } else {
        skippedTests++;
        TestHelper.printTestResult(
          testName,
          false,
          message: 'Failed to fetch produk',
        );
      }
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Cleanup helper
  Future<void> _cleanupToko(dynamic id, String accessToken) async {
    try {
      await http
          .delete(
            Uri.parse('${TestConfig.tokoEndpoint}?id=eq.$id'),
            headers: TestConfig.headersWithAuth(accessToken),
          )
          .timeout(TestConfig.timeout);
      print('  ✓ Cleanup: Test data deleted');
    } catch (e) {
      print('  ⚠ Cleanup failed: $e');
    }
  }

  void _printSummary() {
    print(TestHelper.generateSummary(totalTests, passedTests, failedTests));
    if (skippedTests > 0) {
      print('⊘ Skipped: $skippedTests tests');
    }
  }
}

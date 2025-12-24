import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/test_config.dart';
import '../helpers/test_helper.dart';
import '../helpers/auth_helper.dart';

/// Test Iuran & Transaksi API - Critical Business Logic
class IuranApiTest {
  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
  int skippedTests = 0;

  Future<void> runAllTests() async {
    TestHelper.printTestHeader('IURAN & TRANSAKSI API TESTS');

    // READ Operations (No auth required)
    await testGetMasterIuran();
    await testGetTransaksiByUser();
    await testGetIuranById();

    // CRUD Operations (Requires auth)
    if (TestConfig.enableAuthTests) {
      final hasAuth = await AuthHelper.isAuthAvailable();
      if (hasAuth) {
        await testCreateIuran();
      } else {
        print('\n⚠ Auth tests skipped - Login failed');
        print(
          '  Set testEmail dan testPassword yang valid di test_config.dart',
        );
      }
    } else {
      print('\n⚠ Auth tests disabled');
      print('  Set TestConfig.enableAuthTests = true untuk test CRUD');
    }

    _printSummary();
  }

  /// Test: GET master iuran dengan order jatuh_tempo
  Future<void> testGetMasterIuran() async {
    totalTests++;
    final testName = 'GET /iuran?order=jatuh_tempo.asc';

    try {
      final response = await http
          .get(
            Uri.parse('${TestConfig.iuranEndpoint}?order=jatuh_tempo.asc'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      final passed =
          TestHelper.isSuccessStatusCode(response.statusCode) &&
          TestHelper.isValidJson(response.body);

      if (passed) {
        final data = TestHelper.parseResponse(response) as List;
        print('✓ Retrieved ${data.length} iuran records');
        if (data.isNotEmpty) {
          final first = data[0];
          print('  Sample: ${first['nama_iuran']} - Rp ${first['jumlah']}');
        }
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

  /// Test: GET transaksi iuran by user
  Future<void> testGetTransaksiByUser() async {
    totalTests++;
    final testName = 'GET /transaksi_iuran?id_user=eq.{userId}';

    try {
      // First, get a user ID to test with
      final usersResponse = await http
          .get(
            Uri.parse('${TestConfig.usersEndpoint}?limit=1'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      if (TestHelper.isSuccessStatusCode(usersResponse.statusCode)) {
        final users = TestHelper.parseResponse(usersResponse) as List;

        if (users.isNotEmpty) {
          final userId = users[0]['id'];

          final response = await http
              .get(
                Uri.parse(
                  '${TestConfig.transaksiIuranEndpoint}?id_user=eq.$userId',
                ),
                headers: TestConfig.headers,
              )
              .timeout(TestConfig.timeout);

          final passed = TestHelper.isSuccessStatusCode(response.statusCode);

          if (passed) {
            final data = TestHelper.parseResponse(response) as List;
            print('✓ Retrieved ${data.length} transaksi for user $userId');
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
            message: 'No users found for testing',
          );
        }
      } else {
        failedTests++;
        TestHelper.printTestResult(
          testName,
          false,
          message: 'Failed to fetch users',
        );
      }
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Test: GET iuran by ID
  Future<void> testGetIuranById() async {
    totalTests++;
    final testName = 'GET /iuran?id=eq.{id}';

    try {
      // Get first iuran
      final listResponse = await http
          .get(
            Uri.parse('${TestConfig.iuranEndpoint}?limit=1'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      if (TestHelper.isSuccessStatusCode(listResponse.statusCode)) {
        final data = TestHelper.parseResponse(listResponse) as List;

        if (data.isNotEmpty) {
          final iuranId = data[0]['id'];

          final response = await http
              .get(
                Uri.parse('${TestConfig.iuranEndpoint}?id=eq.$iuranId'),
                headers: TestConfig.headers,
              )
              .timeout(TestConfig.timeout);

          final passed = TestHelper.isSuccessStatusCode(response.statusCode);

          if (passed) {
            final result = TestHelper.parseResponse(response) as List;
            if (result.isNotEmpty) {
              print('✓ Found iuran: ${result[0]['nama_iuran']}');
            }
            passedTests++;
          } else {
            failedTests++;
          }

          TestHelper.printTestResult(testName, passed);
        } else {
          failedTests++;
          TestHelper.printTestResult(testName, false, message: 'No iuran data');
        }
      } else {
        failedTests++;
        TestHelper.printTestResult(
          testName,
          false,
          message: 'Failed to fetch iuran list',
        );
      }
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Test: CREATE new iuran (Authenticated)
  Future<void> testCreateIuran() async {
    totalTests++;
    final testName = 'POST /iuran (Authenticated)';

    try {
      final accessToken = await AuthHelper.getAuthToken();
      if (accessToken == null) {
        skippedTests++;
        TestHelper.printTestResult(testName, false, message: 'No auth token');
        return;
      }

      final newIuran = {
        'jenis': 'Test Iuran ${DateTime.now().millisecondsSinceEpoch}',
        'nominal': 50000,
        'jatuh_tempo': DateTime.now()
            .add(Duration(days: 30))
            .toIso8601String()
            .split('T')[0],
        'id_rt': 1,
        'id_bendahara': 3, // User ID bendahara dari schema
      };

      final response = await http
          .post(
            Uri.parse(TestConfig.iuranEndpoint),
            headers: TestConfig.headersWithAuth(accessToken),
            body: json.encode(newIuran),
          )
          .timeout(TestConfig.timeout);

      final passed = response.statusCode == 201 || response.statusCode == 200;

      if (passed) {
        final data = TestHelper.parseResponse(response);
        print('✓ Created iuran: ${newIuran['nama_iuran']}');

        // Cleanup - hapus test data
        if (data is List && data.isNotEmpty) {
          final createdId = data[0]['id'];
          await _cleanupIuran(createdId, accessToken);
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

  /// Cleanup helper - hapus test iuran
  Future<void> _cleanupIuran(dynamic id, String accessToken) async {
    try {
      await http
          .delete(
            Uri.parse('${TestConfig.iuranEndpoint}?id=eq.$id'),
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

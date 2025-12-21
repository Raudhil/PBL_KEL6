import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/test_config.dart';
import '../helpers/test_helper.dart';
import '../helpers/auth_helper.dart';

/// Test Keuangan RT API
class KeuanganApiTest {
  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
  int skippedTests = 0;

  Future<void> runAllTests() async {
    TestHelper.printTestHeader('KEUANGAN RT API TESTS');

    // READ Operations
    await testGetKeuanganByRT();

    // CRUD Operations (Authenticated)
    if (TestConfig.enableAuthTests) {
      final hasAuth = await AuthHelper.isAuthAvailable();
      if (hasAuth) {
        await testCreateKeuangan();
        await testUpdateKeuangan();
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

  /// Test: GET keuangan by RT
  Future<void> testGetKeuanganByRT() async {
    totalTests++;
    final testName = 'GET /keuangan?id_rt=eq.{idRt}';

    try {
      const testRtId = 1;

      final response = await http
          .get(
            Uri.parse('${TestConfig.keuanganEndpoint}?id_rt=eq.$testRtId'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      final passed = TestHelper.isSuccessStatusCode(response.statusCode);

      if (passed) {
        final data = TestHelper.parseResponse(response) as List;
        print('✓ Retrieved ${data.length} keuangan records for RT $testRtId');
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

  /// Test: CREATE new keuangan (Authenticated)
  Future<void> testCreateKeuangan() async {
    totalTests++;
    final testName = 'POST /keuangan (Authenticated)';

    try {
      final accessToken = await AuthHelper.getAuthToken();
      if (accessToken == null) {
        skippedTests++;
        TestHelper.printTestResult(testName, false, message: 'No auth token');
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newKeuangan = {
        'jenis_transaksi': 'Pemasukan',
        'sumber_transaksi': 'Test transaction $timestamp',
        'jumlah': 100000,
        'deskripsi': 'Test keuangan description',
        'id_rt': 1,
      };

      final response = await http
          .post(
            Uri.parse(TestConfig.keuanganEndpoint),
            headers: TestConfig.headersWithAuth(accessToken),
            body: json.encode(newKeuangan),
          )
          .timeout(TestConfig.timeout);

      final passed = response.statusCode == 201 || response.statusCode == 200;

      if (passed) {
        final data = TestHelper.parseResponse(response);
        print('✓ Created keuangan: ${newKeuangan['keterangan']}');

        if (data is List && data.isNotEmpty) {
          final createdId = data[0]['id'];
          await _cleanupKeuangan(createdId, accessToken);
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

  /// Test: UPDATE keuangan (Authenticated)
  Future<void> testUpdateKeuangan() async {
    totalTests++;
    final testName = 'PUT /keuangan/{id} (Authenticated)';

    try {
      final accessToken = await AuthHelper.getAuthToken();
      if (accessToken == null) {
        skippedTests++;
        TestHelper.printTestResult(testName, false, message: 'No auth token');
        return;
      }

      // Create test data first
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final createData = {
        'jenis_transaksi': 'Pengeluaran',
        'sumber_transaksi': 'Test update $timestamp',
        'jumlah': 50000,
        'deskripsi': 'Test keuangan update',
        'id_rt': 1,
      };

      final createResponse = await http
          .post(
            Uri.parse(TestConfig.keuanganEndpoint),
            headers: TestConfig.headersWithAuth(accessToken),
            body: json.encode(createData),
          )
          .timeout(TestConfig.timeout);

      if (createResponse.statusCode == 201 ||
          createResponse.statusCode == 200) {
        final created = TestHelper.parseResponse(createResponse) as List;
        final keuanganId = created[0]['id'];

        // Update the data
        final updateData = {
          'jumlah': 75000,
          'deskripsi': 'Updated transaction $timestamp',
        };

        final response = await http
            .patch(
              Uri.parse('${TestConfig.keuanganEndpoint}?id=eq.$keuanganId'),
              headers: TestConfig.headersWithAuth(accessToken),
              body: json.encode(updateData),
            )
            .timeout(TestConfig.timeout);

        final passed = response.statusCode == 200 || response.statusCode == 204;

        if (passed) {
          print('✓ Updated keuangan ID: $keuanganId');
          await _cleanupKeuangan(keuanganId, accessToken);
          passedTests++;
        } else {
          print('✗ Failed: ${response.statusCode}');
          await _cleanupKeuangan(keuanganId, accessToken);
          failedTests++;
        }

        TestHelper.printTestResult(testName, passed);
      } else {
        failedTests++;
        TestHelper.printTestResult(
          testName,
          false,
          message: 'Failed to create test data',
        );
      }
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Cleanup helper
  Future<void> _cleanupKeuangan(dynamic id, String accessToken) async {
    try {
      await http
          .delete(
            Uri.parse('${TestConfig.keuanganEndpoint}?id=eq.$id'),
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

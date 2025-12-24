import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/test_config.dart';
import '../helpers/test_helper.dart';
import '../helpers/auth_helper.dart';

/// Test Warga API - Data Master Management
class WargaApiTest {
  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
  int skippedTests = 0;

  Future<void> runAllTests() async {
    TestHelper.printTestHeader('WARGA API TESTS');

    // READ Operations
    await testGetAllWarga();
    await testCheckNikExists();
    await testGetWargaById();

    // CRUD Operations (Authenticated)
    if (TestConfig.enableAuthTests) {
      final hasAuth = await AuthHelper.isAuthAvailable();
      if (hasAuth) {
        await testCreateWarga();
        await testUpdateWarga();
      } else {
        skippedTests += 2;
        print('\n⚠ CRUD tests skipped - Login failed');
      }
    } else {
      skippedTests += 2;
      print('\n⚠ CRUD tests disabled - Set enableAuthTests = true');
    }

    _printSummary();
  }

  /// Test: GET all warga dengan join users
  Future<void> testGetAllWarga() async {
    totalTests++;
    final testName = 'GET /warga - Fetch all with users join';

    try {
      final response = await http
          .get(
            Uri.parse('${TestConfig.wargaEndpoint}?select=*,users(*)'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      final passed =
          TestHelper.isSuccessStatusCode(response.statusCode) &&
          TestHelper.isValidJson(response.body);

      if (passed) {
        final data = TestHelper.parseResponse(response) as List;
        print('✓ Retrieved ${data.length} warga records');
        if (data.isNotEmpty && data[0]['users'] != null) {
          print('  ✓ User relation working');
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

  /// Test: GET warga by ID
  Future<void> testGetWargaById() async {
    totalTests++;
    final testName = 'GET /warga?id=eq.{id}';

    try {
      // Get first warga
      final listResponse = await http
          .get(
            Uri.parse('${TestConfig.wargaEndpoint}?limit=1'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      if (TestHelper.isSuccessStatusCode(listResponse.statusCode)) {
        final data = TestHelper.parseResponse(listResponse) as List;

        if (data.isNotEmpty) {
          final wargaId = data[0]['id'];

          final response = await http
              .get(
                Uri.parse('${TestConfig.wargaEndpoint}?id=eq.$wargaId'),
                headers: TestConfig.headers,
              )
              .timeout(TestConfig.timeout);

          final passed = TestHelper.isSuccessStatusCode(response.statusCode);

          if (passed) {
            final result = TestHelper.parseResponse(response) as List;
            if (result.isNotEmpty) {
              print('✓ Found warga: ${result[0]['nama_lengkap']}');
            }
            passedTests++;
          } else {
            failedTests++;
          }

          TestHelper.printTestResult(testName, passed);
        } else {
          failedTests++;
          TestHelper.printTestResult(testName, false, message: 'No warga data');
        }
      } else {
        failedTests++;
        TestHelper.printTestResult(
          testName,
          false,
          message: 'Failed to fetch warga',
        );
      }
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Test: Check NIK exists
  Future<void> testCheckNikExists() async {
    totalTests++;
    final testName = 'GET /warga?nik=eq.{nik} - Check duplicate';

    try {
      // Get first warga to get a real NIK
      final listResponse = await http
          .get(
            Uri.parse('${TestConfig.wargaEndpoint}?limit=1'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      if (TestHelper.isSuccessStatusCode(listResponse.statusCode)) {
        final data = TestHelper.parseResponse(listResponse) as List;

        if (data.isNotEmpty) {
          final nik = data[0]['nik'];

          final response = await http
              .get(
                Uri.parse('${TestConfig.wargaEndpoint}?nik=eq.$nik'),
                headers: TestConfig.headers,
              )
              .timeout(TestConfig.timeout);

          final passed = TestHelper.isSuccessStatusCode(response.statusCode);

          if (passed) {
            final result = TestHelper.parseResponse(response) as List;
            print('✓ NIK check: ${result.isNotEmpty ? "Found" : "Not found"}');
            passedTests++;
          } else {
            failedTests++;
          }

          TestHelper.printTestResult(testName, passed);
        } else {
          failedTests++;
          TestHelper.printTestResult(testName, false, message: 'No warga data');
        }
      } else {
        failedTests++;
        TestHelper.printTestResult(
          testName,
          false,
          message: 'Failed to fetch warga',
        );
      }
    } catch (e) {
      failedTests++;
      TestHelper.printTestResult(testName, false, message: e.toString());
    }
  }

  /// Test: CREATE new warga (Authenticated)
  /// Uses existing id_kk and NIK as unique identifier
  Future<void> testCreateWarga() async {
    totalTests++;
    final testName = 'POST /warga (Authenticated)';

    try {
      final accessToken = await AuthHelper.getAuthToken();
      if (accessToken == null) {
        skippedTests++;
        TestHelper.printTestResult(testName, false, message: 'No auth token');
        return;
      }

      // Get existing id_kk from database (avoid FK constraint)
      final kkResponse = await http
          .get(
            Uri.parse('${TestConfig.baseUrl}/kk?limit=1'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      if (!TestHelper.isSuccessStatusCode(kkResponse.statusCode)) {
        failedTests++;
        TestHelper.printTestResult(
          testName,
          false,
          message: 'No KK data available',
        );
        return;
      }

      final kkData = TestHelper.parseResponse(kkResponse) as List;
      if (kkData.isEmpty) {
        failedTests++;
        TestHelper.printTestResult(
          testName,
          false,
          message: 'KK table is empty',
        );
        return;
      }

      final validIdKk = kkData[0]['id'];

      // Generate unique NIK (16 digits)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueNik =
          '9900${timestamp.toString().substring(timestamp.toString().length - 12)}';

      final newWarga = {
        // NO 'id' field - let database auto-increment
        'nik': uniqueNik,
        'nama_lengkap': 'Test Warga API $timestamp',
        'tanggal_lahir': '1995-06-15',
        'jenis_kelamin': 'Laki-laki',
        'nomor_hp': '08123456${(timestamp % 10000).toString().padLeft(4, '0')}',
        'peran_keluarga': 'Anak',
        'id_kk': validIdKk, // Use existing KK ID
      };

      final response = await http
          .post(
            Uri.parse(TestConfig.wargaEndpoint),
            headers: TestConfig.headersWithAuth(accessToken),
            body: json.encode(newWarga),
          )
          .timeout(TestConfig.timeout);

      final passed = response.statusCode == 201 || response.statusCode == 200;

      if (passed) {
        final data = TestHelper.parseResponse(response);
        print('✓ Created warga: ${newWarga['nama_lengkap']} (NIK: $uniqueNik)');

        if (data is List && data.isNotEmpty) {
          final createdNik = data[0]['nik'];
          await _cleanupWargaByNik(createdNik, accessToken);
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

  /// Test: UPDATE warga (Authenticated)
  /// Uses NIK as unique identifier (not ID)
  Future<void> testUpdateWarga() async {
    totalTests++;
    final testName = 'PATCH /warga?nik=eq.{nik} (Authenticated)';

    try {
      final accessToken = await AuthHelper.getAuthToken();
      if (accessToken == null) {
        skippedTests++;
        TestHelper.printTestResult(testName, false, message: 'No auth token');
        return;
      }

      // Get existing id_kk
      final kkResponse = await http
          .get(
            Uri.parse('${TestConfig.baseUrl}/kk?limit=1'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      if (!TestHelper.isSuccessStatusCode(kkResponse.statusCode)) {
        failedTests++;
        TestHelper.printTestResult(testName, false, message: 'No KK data');
        return;
      }

      final kkData = TestHelper.parseResponse(kkResponse) as List;
      final validIdKk = kkData[0]['id'];

      // Create test data first
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueNik =
          '9901${timestamp.toString().substring(timestamp.toString().length - 12)}';

      final createData = {
        'nik': uniqueNik,
        'nama_lengkap': 'Test For Update $timestamp',
        'tanggal_lahir': '1992-03-20',
        'jenis_kelamin': 'Perempuan',
        'nomor_hp': '08567890${(timestamp % 1000).toString().padLeft(3, '0')}',
        'peran_keluarga': 'Istri',
        'id_kk': validIdKk,
      };

      final createResponse = await http
          .post(
            Uri.parse(TestConfig.wargaEndpoint),
            headers: TestConfig.headersWithAuth(accessToken),
            body: json.encode(createData),
          )
          .timeout(TestConfig.timeout);

      if (createResponse.statusCode == 201 ||
          createResponse.statusCode == 200) {
        final created = TestHelper.parseResponse(createResponse) as List;
        final createdNik = created[0]['nik'];

        // Update the data using NIK (unique identifier)
        final updateData = {
          'nama_lengkap': 'UPDATED NAME $timestamp',
          'nomor_hp': '085999888777',
          'peran_keluarga': 'Anggota Keluarga',
        };

        final response = await http
            .patch(
              Uri.parse('${TestConfig.wargaEndpoint}?nik=eq.$createdNik'),
              headers: TestConfig.headersWithAuth(accessToken),
              body: json.encode(updateData),
            )
            .timeout(TestConfig.timeout);

        final passed = response.statusCode == 200 || response.statusCode == 204;

        if (passed) {
          print('✓ Updated warga NIK: $createdNik');
          await _cleanupWargaByNik(createdNik, accessToken);
          passedTests++;
        } else {
          print('✗ Failed: ${response.statusCode} - ${response.body}');
          await _cleanupWargaByNik(createdNik, accessToken);
          failedTests++;
        }

        TestHelper.printTestResult(testName, passed);
      } else {
        print(
          '✗ Create failed: ${createResponse.statusCode} - ${createResponse.body}',
        );
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

  /// Cleanup helper - Delete by NIK (unique identifier)
  Future<void> _cleanupWargaByNik(String nik, String accessToken) async {
    try {
      await http
          .delete(
            Uri.parse('${TestConfig.wargaEndpoint}?nik=eq.$nik'),
            headers: TestConfig.headersWithAuth(accessToken),
          )
          .timeout(TestConfig.timeout);
      print('  ✓ Cleanup: Test warga deleted (NIK: $nik)');
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

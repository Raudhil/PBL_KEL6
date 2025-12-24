import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/test_config.dart';
import '../helpers/test_helper.dart';

/// Test Community API - Pengumuman & Kegiatan
class CommunityApiTest {
  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;

  Future<void> runAllTests() async {
    TestHelper.printTestHeader('COMMUNITY API TESTS (Pengumuman & Kegiatan)');

    await testGetPengumuman();
    await testGetKegiatan();

    _printSummary();
  }

  /// Test: GET pengumuman ordered by created_at
  Future<void> testGetPengumuman() async {
    totalTests++;
    final testName = 'GET /pengumuman?order=created_at.desc';

    try {
      final response = await http
          .get(
            Uri.parse('${TestConfig.pengumumanEndpoint}?order=created_at.desc'),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      final passed = TestHelper.isSuccessStatusCode(response.statusCode);

      if (passed) {
        final data = TestHelper.parseResponse(response) as List;
        print('✓ Retrieved ${data.length} pengumuman records');
        if (data.isNotEmpty) {
          print('  Latest: ${data[0]['judul']}');
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

  /// Test: GET kegiatan ordered by tanggal_mulai
  Future<void> testGetKegiatan() async {
    totalTests++;
    final testName = 'GET /kegiatan?order=tanggal_mulai.desc';

    try {
      final response = await http
          .get(
            Uri.parse(
              '${TestConfig.kegiatanEndpoint}?order=tanggal_mulai.desc',
            ),
            headers: TestConfig.headers,
          )
          .timeout(TestConfig.timeout);

      final passed = TestHelper.isSuccessStatusCode(response.statusCode);

      if (passed) {
        final data = TestHelper.parseResponse(response) as List;
        print('✓ Retrieved ${data.length} kegiatan records');
        if (data.isNotEmpty) {
          print('  Latest: ${data[0]['nama_kegiatan']}');
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

  void _printSummary() {
    print(TestHelper.generateSummary(totalTests, passedTests, failedTests));
  }
}

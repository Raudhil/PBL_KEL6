import 'unit/warga_api_test.dart';
import 'unit/iuran_api_test.dart';
import 'unit/marketplace_api_test.dart';
import 'unit/community_api_test.dart';
import 'unit/keuangan_api_test.dart';
import 'helpers/test_helper.dart';
import 'helpers/test_config.dart';
import 'dart:io';
import 'dart:convert';

/// Master Test Runner
/// Runs all API tests and generates summary report
void main() async {
  final startTime = DateTime.now();

  print('\n');
  print('╔${'═' * 58}╗');
  print('║${' ' * 10}TERASWARGA API TESTING SUITE${' ' * 20}║');
  print('║${' ' * 10}Comprehensive API Test Report${' ' * 19}║');
  print('╚${'═' * 58}╝');
  print('\nTest Started: ${startTime.toString().substring(0, 19)}');
  print('Target: Supabase REST API');
  print('Base URL: https://qocwwkkirsscsxtfsrpk.supabase.co/rest/v1');
  print('${'=' * 60}\n');

  // Collect all test results
  int totalTests = 0;
  int totalPassed = 0;
  int totalFailed = 0;

  // Run Warga Tests
  print('\n📋 Running Warga API Tests...');
  final wargaTest = WargaApiTest();
  await wargaTest.runAllTests();
  totalTests += wargaTest.totalTests;
  totalPassed += wargaTest.passedTests;
  totalFailed += wargaTest.failedTests;

  await TestHelper.sleep(Duration(seconds: 1));

  // Run Iuran Tests
  print('\n💰 Running Iuran & Transaksi API Tests...');
  final iuranTest = IuranApiTest();
  await iuranTest.runAllTests();
  totalTests += iuranTest.totalTests;
  totalPassed += iuranTest.passedTests;
  totalFailed += iuranTest.failedTests;

  await TestHelper.sleep(Duration(seconds: 1));

  // Run Marketplace Tests
  print('\n🏪 Running Marketplace API Tests...');
  final marketplaceTest = MarketplaceApiTest();
  await marketplaceTest.runAllTests();
  totalTests += marketplaceTest.totalTests;
  totalPassed += marketplaceTest.passedTests;
  totalFailed += marketplaceTest.failedTests;

  await TestHelper.sleep(Duration(seconds: 1));

  // Run Community Tests
  print('\n📢 Running Community API Tests (Pengumuman & Kegiatan)...');
  final communityTest = CommunityApiTest();
  await communityTest.runAllTests();
  totalTests += communityTest.totalTests;
  totalPassed += communityTest.passedTests;
  totalFailed += communityTest.failedTests;

  await TestHelper.sleep(Duration(seconds: 1));

  // Run Keuangan Tests
  print('\n💵 Running Keuangan RT API Tests...');
  final keuanganTest = KeuanganApiTest();
  await keuanganTest.runAllTests();
  totalTests += keuanganTest.totalTests;
  totalPassed += keuanganTest.passedTests;
  totalFailed += keuanganTest.failedTests;

  await TestHelper.sleep(Duration(seconds: 1));

  await TestHelper.sleep(Duration(seconds: 1));

  // Final Summary
  final endTime = DateTime.now();
  final duration = endTime.difference(startTime);

  print('\n');
  print('╔${'═' * 58}╗');
  print('║${' ' * 15}FINAL TEST SUMMARY${' ' * 25}║');
  print('╚${'═' * 58}╝');

  // Show auth mode status
  print(
    '\nTest Mode: ${TestConfig.enableAuthTests ? "🔐 Full CRUD (Authenticated)" : "📖 READ Only"}',
  );

  print('\nTotal API Endpoints Tested: $totalTests');
  print('✓ Passed: $totalPassed');
  print('✗ Failed: $totalFailed');

  final passRate = totalTests > 0
      ? (totalPassed / totalTests * 100).toStringAsFixed(2)
      : '0.00';
  print('Success Rate: $passRate%');

  print('\nTest Duration: ${duration.inSeconds} seconds');
  print('Test Completed: ${endTime.toString().substring(0, 19)}');

  // Generate JSON Report
  await _generateJsonReport(
    totalTests,
    totalPassed,
    totalFailed,
    startTime,
    endTime,
  );

  print('\n${'=' * 60}');
  print('✅ Test report saved to: ../results/test_results.json');
  print('${'=' * 60}\n');
}

Future<void> _generateJsonReport(
  int total,
  int passed,
  int failed,
  DateTime startTime,
  DateTime endTime,
) async {
  final report = {
    'test_suite': 'TerasWarga API Testing',
    'timestamp': DateTime.now().toIso8601String(),
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'duration_seconds': endTime.difference(startTime).inSeconds,
    'mode': TestConfig.enableAuthTests ? 'authenticated' : 'read-only',
    'summary': {
      'total_tests': total,
      'passed': passed,
      'failed': failed,
      'pass_rate': total > 0
          ? (passed / total * 100).toStringAsFixed(2)
          : '0.00',
    },
    'test_categories': [
      'Warga API (CRUD)',
      'Iuran & Transaksi API (CRUD)',
      'Marketplace API (CRUD)',
      'Community API (Read Only)',
      'Keuangan RT API (CRUD)',
    ],
  };

  final file = File('../results/test_results.json');
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(report));
}

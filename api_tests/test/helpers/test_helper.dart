import 'dart:convert';
import 'package:http/http.dart' as http;
import 'test_config.dart';

/// Helper class untuk API testing
class TestHelper {
  /// Print test header
  static void printTestHeader(String testName) {
    print('\n${'=' * 60}');
    print('TEST: $testName');
    print('=' * 60);
  }

  /// Print test result
  static void printTestResult(String testName, bool passed, {String? message}) {
    final status = passed ? '✓ PASSED' : '✗ FAILED';
    final color = passed ? '\x1B[32m' : '\x1B[31m';
    final reset = '\x1B[0m';

    print('$color$status$reset: $testName');
    if (message != null) {
      print('  Message: $message');
    }
  }

  /// Print response details
  static void printResponse(http.Response response) {
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');

    try {
      final body = json.decode(response.body);
      print('Body: ${json.encode(body)}');
    } catch (e) {
      print('Body: ${response.body}');
    }
  }

  /// Validate response status code
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Validate JSON response
  static bool isValidJson(String responseBody) {
    try {
      json.decode(responseBody);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extract data from response
  static dynamic parseResponse(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Check if response contains required fields
  static bool hasRequiredFields(
    Map<String, dynamic> data,
    List<String> fields,
  ) {
    for (var field in fields) {
      if (!data.containsKey(field)) {
        return false;
      }
    }
    return true;
  }

  /// Generate test report summary
  static String generateSummary(int total, int passed, int failed) {
    final passRate = total > 0
        ? (passed / total * 100).toStringAsFixed(2)
        : '0.00';

    return '''
${'=' * 60}
TEST SUMMARY
${'=' * 60}
Total Tests: $total
Passed: $passed
Failed: $failed
Pass Rate: $passRate%
${'=' * 60}
''';
  }

  /// Sleep helper
  static Future<void> sleep(Duration duration) {
    return Future.delayed(duration);
  }

  /// Retry helper
  static Future<T> retry<T>(
    Future<T> Function() fn, {
    int maxAttempts = TestConfig.maxRetries,
    Duration delay = TestConfig.retryDelay,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          rethrow;
        }
        print('Attempt $attempt failed, retrying in ${delay.inSeconds}s...');
        await sleep(delay);
      }
    }
  }
}

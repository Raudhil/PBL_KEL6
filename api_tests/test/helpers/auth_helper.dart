import 'dart:convert';
import 'package:http/http.dart' as http;
import 'test_config.dart';

/// Helper untuk Supabase Authentication
/// Digunakan untuk login dan mendapatkan access token untuk CRUD operations
class AuthHelper {
  /// Login dengan email dan password
  /// Returns access token jika berhasil, null jika gagal
  static Future<String?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(TestConfig.loginEndpoint),
            headers: {
              'apikey': TestConfig.supabaseAnonKey,
              'Content-Type': 'application/json',
            },
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(TestConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'] as String?;

        if (accessToken != null) {
          // Cache token untuk reuse
          TestConfig.cachedAccessToken = accessToken;
          print('✓ Login berhasil: ${email.split('@')[0]}@***');
          return accessToken;
        }
      }

      print('✗ Login gagal: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('✗ Login error: $e');
      return null;
    }
  }

  /// Get cached token atau login jika belum ada
  static Future<String?> getAuthToken() async {
    if (TestConfig.cachedAccessToken != null) {
      return TestConfig.cachedAccessToken;
    }

    return await login(TestConfig.testEmail, TestConfig.testPassword);
  }

  /// Check apakah auth tests enabled dan token tersedia
  static Future<bool> isAuthAvailable() async {
    if (!TestConfig.enableAuthTests) {
      return false;
    }

    final token = await getAuthToken();
    return token != null;
  }

  /// Logout - hapus cached token
  static void logout() {
    TestConfig.cachedAccessToken = null;
    print('✓ Logged out');
  }
}

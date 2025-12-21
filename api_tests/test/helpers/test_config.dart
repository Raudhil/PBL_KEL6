/// API Test Configuration
/// Konfigurasi untuk testing API Supabase
class TestConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://qocwwkkirsscsxtfsrpk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFvY3d3a2tpcnNzY3N4dGZzcnBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjY3NTMsImV4cCI6MjA3ODUwMjc1M30.5jQmIjT8K6iBRwoTELoBe8joP36rwfiIAusGNzT2JMA';

  // API Endpoints
  static const String baseUrl = '$supabaseUrl/rest/v1';

  // Table Endpoints
  static const String wargaEndpoint = '$baseUrl/warga';
  static const String iuranEndpoint = '$baseUrl/iuran';
  static const String transaksiIuranEndpoint = '$baseUrl/transaksi_iuran';
  static const String tokoEndpoint = '$baseUrl/toko';
  static const String produkEndpoint = '$baseUrl/produk';
  static const String reviewProdukEndpoint = '$baseUrl/review_produk';
  static const String pengumumanEndpoint = '$baseUrl/pengumuman';
  static const String kegiatanEndpoint = '$baseUrl/kegiatan';
  static const String keuanganEndpoint = '$baseUrl/keuangan';
  static const String usersEndpoint = '$baseUrl/users';

  // ML Model API (Railway)
  static const String mlApiUrl =
      'https://modelannkel6-production.up.railway.app';

  // Auth Endpoint
  static const String authEndpoint = '$supabaseUrl/auth/v1';
  static const String loginEndpoint = '$authEndpoint/token?grant_type=password';
  static const String signupEndpoint = '$authEndpoint/signup';

  // Headers - Anon Key (Read Only)
  static Map<String, String> get headers => {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  // Headers - Authenticated (for CRUD operations)
  static Map<String, String> headersWithAuth(String accessToken) => {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  // Test Mode Configuration
  static bool enableAuthTests =
      true; // Set true untuk test CRUD (requires valid credentials)
  static String? cachedAccessToken; // Cache token setelah login

  // Test Data - User credentials dari README.md (Akun Testing)
  // Using RT account for warga CRUD operations (RT has permission to create warga)
  static const String testEmail =
      'rt@gmail.com'; // RT account (can CREATE warga)
  static const String testPassword = 'password'; // Password dari README

  // Test Data untuk CREATE operations
  static const String testNik =
      '9999999999999999'; // NIK untuk testing (16 digit)
  static const String testRtId = '1'; // ID RT yang valid

  // Timeout Configuration
  static const Duration timeout = Duration(seconds: 30);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}

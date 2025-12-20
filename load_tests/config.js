/**
 * ⚙️ Load Testing Configuration
 * TerasWarga (JAWARA) - Supabase API Configuration
 */

export const config = {
  // Supabase Configuration
  supabaseUrl: 'https://qocwwkkirsscsxtfsrpk.supabase.co',
  supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFvY3d3a2tpcnNzY3N4dGZzcnBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjY3NTMsImV4cCI6MjA3ODUwMjc1M30.5jQmIjT8K6iBRwoTELoBe8joP36rwfiIAusGNzT2JMA',
  
  // API Endpoints
  endpoints: {
    warga: '/rest/v1/warga',
    iuran: '/rest/v1/iuran',
    transaksiIuran: '/rest/v1/transaksi_iuran',
    toko: '/rest/v1/toko',
    produk: '/rest/v1/produk',
    reviewProduk: '/rest/v1/review_produk',
    pengumuman: '/rest/v1/pengumuman',
    kegiatan: '/rest/v1/kegiatan',
    auth: '/auth/v1/token',
  },
  
  // Headers untuk Supabase REST API
  getHeaders: function() {
    return {
      'Content-Type': 'application/json',
      'apikey': this.supabaseAnonKey,
      'Authorization': `Bearer ${this.supabaseAnonKey}`,
    };
  },
  
  // Performance Thresholds
  thresholds: {
    responseTime: {
      fast: 200,      // < 200ms = Excellent
      good: 500,      // < 500ms = Good
      acceptable: 1000, // < 1000ms = Acceptable
      slow: 2000      // > 2000ms = Too Slow
    },
    errorRate: {
      excellent: 0.01,  // < 1% errors
      good: 0.05,       // < 5% errors
      acceptable: 0.10  // < 10% errors
    }
  },
  
  // Test Data Samples (untuk POST requests)
  testData: {
    warga: {
      nik: '3573010101900001',
      nama: 'Load Test User',
      tanggal_lahir: '1990-01-01',
      jenis_kelamin: 'Laki-laki',
      no_telepon: '081234567890',
      pekerjaan: 'Testing',
      id_rt: 1
    },
    transaksiIuran: {
      id_warga: 1,
      id_iuran: 1,
      jumlah_bayar: 50000,
      tanggal_bayar: new Date().toISOString().split('T')[0],
      status_bayar: 'Lunas'
    }
  }
};

export default config;

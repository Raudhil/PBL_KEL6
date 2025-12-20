/**
 * 🔥 Peak Load Test - TerasWarga (JAWARA)
 * 
 * Test Description:
 * - Simulates peak traffic conditions (rush hour)
 * - Gradually increases from 50 to 200 concurrent users
 * - Duration: 5 minutes
 * - Purpose: Test system under high load
 * 
 * Expected Results:
 * - Response time < 1000ms (p95)
 * - Error rate < 5%
 * - System should remain stable under peak load
 */

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';
import { htmlReport } from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js";
import { textSummary } from "https://jslib.k6.io/k6-summary/0.0.1/index.js";

// Import configuration
import { config } from '../config.js';

// Custom metrics
const errorRate = new Rate('errors');
const successRate = new Rate('success');
const apiCalls = new Counter('api_calls');

// Load Test Configuration
export const options = {
  stages: [
    { duration: '1m', target: 50 },    // Ramp-up to 50 users
    { duration: '2m', target: 200 },   // Ramp-up to peak 200 users
    { duration: '1m', target: 200 },   // Stay at 200 users
    { duration: '1m', target: 50 },    // Ramp-down to 50 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'], // 95% of requests should be below 1s
    http_req_failed: ['rate<0.05'],     // Error rate should be below 5%
    errors: ['rate<0.05'],
  },
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(90)', 'p(95)', 'p(99)'],
};

// Simulate realistic user behavior
export default function () {
  const baseUrl = config.supabaseUrl;
  const headers = config.getHeaders();
  
  // Random user behavior
  const scenarios = [
    browseMarketplace,
    checkIuran,
    viewPengumuman,
    browseWarga,
  ];
  
  // Execute random scenario
  const scenario = scenarios[Math.floor(Math.random() * scenarios.length)];
  scenario(baseUrl, headers);
}

// Scenario: Browse Marketplace
function browseMarketplace(baseUrl, headers) {
  apiCalls.add(1);
  
  // Get all stores
  let tokoRes = http.get(`${baseUrl}${config.endpoints.toko}?limit=20`, {
    headers: headers,
    tags: { name: 'Browse_Marketplace_Toko' },
  });
  
  const success = check(tokoRes, {
    'Marketplace: status is 200': (r) => r.status === 200,
    'Marketplace: response time OK': (r) => r.timings.duration < 1000,
  });
  
  if (success) {
    successRate.add(1);
  } else {
    errorRate.add(1);
  }
  
  sleep(1);
  
  // Get products
  let produkRes = http.get(`${baseUrl}${config.endpoints.produk}?limit=30`, {
    headers: headers,
    tags: { name: 'Browse_Marketplace_Produk' },
  });
  
  check(produkRes, {
    'Products: status is 200': (r) => r.status === 200,
  }) ? successRate.add(1) : errorRate.add(1);
  
  sleep(2);
}

// Scenario: Check Iuran
function checkIuran(baseUrl, headers) {
  apiCalls.add(1);
  
  // Get iuran list
  let iuranRes = http.get(`${baseUrl}${config.endpoints.iuran}?limit=20`, {
    headers: headers,
    tags: { name: 'Check_Iuran' },
  });
  
  const success = check(iuranRes, {
    'Iuran: status is 200': (r) => r.status === 200,
    'Iuran: response time OK': (r) => r.timings.duration < 1000,
  });
  
  if (success) {
    successRate.add(1);
  } else {
    errorRate.add(1);
  }
  
  sleep(1);
  
  // Get transactions
  let transaksiRes = http.get(`${baseUrl}${config.endpoints.transaksiIuran}?limit=20`, {
    headers: headers,
    tags: { name: 'Check_Transaksi' },
  });
  
  check(transaksiRes, {
    'Transaksi: status is 200': (r) => r.status === 200,
  }) ? successRate.add(1) : errorRate.add(1);
  
  sleep(2);
}

// Scenario: View Pengumuman
function viewPengumuman(baseUrl, headers) {
  apiCalls.add(1);
  
  let pengumumanRes = http.get(`${baseUrl}${config.endpoints.pengumuman}?limit=15`, {
    headers: headers,
    tags: { name: 'View_Pengumuman' },
  });
  
  const success = check(pengumumanRes, {
    'Pengumuman: status is 200': (r) => r.status === 200,
    'Pengumuman: has content': (r) => r.body.length > 0,
  });
  
  if (success) {
    successRate.add(1);
  } else {
    errorRate.add(1);
  }
  
  sleep(2);
  
  // View kegiatan
  let kegiatanRes = http.get(`${baseUrl}${config.endpoints.kegiatan}?limit=10`, {
    headers: headers,
    tags: { name: 'View_Kegiatan' },
  });
  
  check(kegiatanRes, {
    'Kegiatan: status is 200': (r) => r.status === 200,
  }) ? successRate.add(1) : errorRate.add(1);
  
  sleep(1);
}

// Scenario: Browse Warga
function browseWarga(baseUrl, headers) {
  apiCalls.add(1);
  
  let wargaRes = http.get(`${baseUrl}${config.endpoints.warga}?limit=25`, {
    headers: headers,
    tags: { name: 'Browse_Warga' },
  });
  
  const success = check(wargaRes, {
    'Warga: status is 200': (r) => r.status === 200,
    'Warga: response time OK': (r) => r.timings.duration < 1000,
  });
  
  if (success) {
    successRate.add(1);
  } else {
    errorRate.add(1);
  }
  
  sleep(3);
}

// Generate HTML report
export function handleSummary(data) {
  return {
    "./results/peak_load_test_summary.html": htmlReport(data),
    "./results/peak_load_test_summary.json": JSON.stringify(data),
    stdout: textSummary(data, { indent: " ", enableColors: true }),
  };
}

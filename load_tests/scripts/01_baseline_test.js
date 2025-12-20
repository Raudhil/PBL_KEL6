/**
 * 📊 Baseline Load Test - TerasWarga (JAWARA)
 * 
 * Test Description:
 * - Simulates normal/baseline traffic conditions
 * - Gradually increases from 10 to 50 concurrent users
 * - Duration: 2 minutes
 * - Purpose: Establish baseline performance metrics
 * 
 * Expected Results:
 * - Response time < 500ms (p95)
 * - Error rate < 1%
 * - All endpoints should handle load smoothly
 */

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';
import { htmlReport } from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js";
import { textSummary } from "https://jslib.k6.io/k6-summary/0.0.1/index.js";

// Import configuration
import { config } from '../config.js';

// Custom metrics
const errorRate = new Rate('errors');
const getWargaDuration = new Trend('get_warga_duration');
const getIuranDuration = new Trend('get_iuran_duration');
const getTokoDuration = new Trend('get_toko_duration');

// Load Test Configuration
export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Ramp-up to 10 users
    { duration: '1m', target: 50 },   // Ramp-up to 50 users
    { duration: '30s', target: 10 },  // Ramp-down to 10 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests should be below 500ms
    http_req_failed: ['rate<0.01'],     // Error rate should be below 1%
    errors: ['rate<0.01'],
  },
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(90)', 'p(95)', 'p(99)'],
};

// Test scenarios
export default function () {
  const baseUrl = config.supabaseUrl;
  const headers = config.getHeaders();
  
  // Scenario 1: GET Warga (Most common operation)
  let wargaResponse = http.get(`${baseUrl}${config.endpoints.warga}?limit=20`, {
    headers: headers,
    tags: { name: 'GET_Warga' },
  });
  
  getWargaDuration.add(wargaResponse.timings.duration);
  
  check(wargaResponse, {
    'GET Warga: status is 200': (r) => r.status === 200,
    'GET Warga: response time < 500ms': (r) => r.timings.duration < 500,
    'GET Warga: has data': (r) => {
      try {
        const body = JSON.parse(r.body);
        return Array.isArray(body);
      } catch (e) {
        return false;
      }
    },
  }) || errorRate.add(1);
  
  sleep(1);
  
  // Scenario 2: GET Iuran
  let iuranResponse = http.get(`${baseUrl}${config.endpoints.iuran}?limit=20`, {
    headers: headers,
    tags: { name: 'GET_Iuran' },
  });
  
  getIuranDuration.add(iuranResponse.timings.duration);
  
  check(iuranResponse, {
    'GET Iuran: status is 200': (r) => r.status === 200,
    'GET Iuran: response time < 500ms': (r) => r.timings.duration < 500,
  }) || errorRate.add(1);
  
  sleep(1);
  
  // Scenario 3: GET Toko (Marketplace)
  let tokoResponse = http.get(`${baseUrl}${config.endpoints.toko}?limit=20`, {
    headers: headers,
    tags: { name: 'GET_Toko' },
  });
  
  getTokoDuration.add(tokoResponse.timings.duration);
  
  check(tokoResponse, {
    'GET Toko: status is 200': (r) => r.status === 200,
    'GET Toko: response time < 500ms': (r) => r.timings.duration < 500,
  }) || errorRate.add(1);
  
  sleep(1);
  
  // Scenario 4: GET Pengumuman
  let pengumumanResponse = http.get(`${baseUrl}${config.endpoints.pengumuman}?limit=10`, {
    headers: headers,
    tags: { name: 'GET_Pengumuman' },
  });
  
  check(pengumumanResponse, {
    'GET Pengumuman: status is 200': (r) => r.status === 200,
    'GET Pengumuman: response time < 500ms': (r) => r.timings.duration < 500,
  }) || errorRate.add(1);
  
  sleep(2); // Think time between user actions
}

// Generate HTML report
export function handleSummary(data) {
  return {
    "./results/baseline_test_summary.html": htmlReport(data),
    "./results/baseline_test_summary.json": JSON.stringify(data),
    stdout: textSummary(data, { indent: " ", enableColors: true }),
  };
}

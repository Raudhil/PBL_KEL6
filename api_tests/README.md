# TerasWarga API Testing Suite

## 📊 Test Report Summary

**Test Date**: December 21, 2025  
**Test Mode**: Authenticated  
**Duration**: 12 seconds  
**Total Tests**: 20 tests  
**Result**: ✅ **100% PASSED**

```
╔═══════════════════════════════════════════════════╗
║  TERASWARGA API TEST REPORT                      ║
╠═══════════════════════════════════════════════════╣
║  Total Tests     : 20                            ║
║  Passed          : 20 ✓                          ║
║  Failed          : 0                             ║
║  Skipped         : 0                             ║
║  Success Rate    : 100%                          ║
╚═══════════════════════════════════════════════════╝
```

---

## 🎯 Test Coverage Overview

| No  | API Category              | Endpoints Tested | Status | Pass Rate  |
| --- | ------------------------- | ---------------- | ------ | ---------- |
| 1   | **Warga API**             | 5 endpoints      | ✅     | 5/5 (100%) |
| 2   | **Iuran & Transaksi API** | 4 endpoints      | ✅     | 4/4 (100%) |
| 3   | **Marketplace API**       | 6 endpoints      | ✅     | 6/6 (100%) |
| 4   | **Community API**         | 2 endpoints      | ✅     | 2/2 (100%) |
| 5   | **Keuangan RT API**       | 3 endpoints      | ✅     | 3/3 (100%) |

---

## 📋 Detailed Test Results

### 1. Warga API (Citizens Data)

| Test Case                           | Method  | Endpoint                   | Expected Result                | Actual Result                  | Status  |
| ----------------------------------- | ------- | -------------------------- | ------------------------------ | ------------------------------ | ------- |
| Get all citizens with user relation | `GET`   | `/warga?select=*,users(*)` | Retrieve all records with join | Retrieved 58 records           | ✅ PASS |
| Check NIK duplicate                 | `GET`   | `/warga?nik=eq.{nik}`      | Find by NIK                    | Found matching record          | ✅ PASS |
| Get citizen by ID                   | `GET`   | `/warga?id=eq.{id}`        | Retrieve single record         | Retrieved 1 record             | ✅ PASS |
| Create new citizen                  | `POST`  | `/warga`                   | Create record & auto cleanup   | Created NIK 9900\*, cleaned up | ✅ PASS |
| Update citizen data                 | `PATCH` | `/warga?nik=eq.{nik}`      | Update record & auto cleanup   | Updated NIK 9901\*, cleaned up | ✅ PASS |

**Schema Validated**:

```json
{
  "nik": "string (16 digits)",
  "nama": "string",
  "id_kk": "integer (foreign key)",
  "tanggal_lahir": "date",
  "jenis_kelamin": "enum (Laki-laki/Perempuan)",
  "status_perkawinan": "enum",
  "id": "auto-generated (sequence)"
}
```

**Note**: Database sequence `warga_id_seq` has been synchronized with existing data.

---

### 2. Iuran & Transaksi API (Fees & Payments)

| Test Case                | Method | Endpoint                           | Expected Result      | Actual Result                 | Status  |
| ------------------------ | ------ | ---------------------------------- | -------------------- | ----------------------------- | ------- |
| Get all fees ordered     | `GET`  | `/iuran?order=jatuh_tempo.asc`     | Retrieve sorted list | Retrieved 76 records          | ✅ PASS |
| Get transactions by user | `GET`  | `/transaksi_iuran?id_user=eq.{id}` | Filter by user       | Retrieved 15 transactions     | ✅ PASS |
| Get fee by ID            | `GET`  | `/iuran?id=eq.{id}`                | Retrieve single fee  | Retrieved 1 record            | ✅ PASS |
| Create new fee           | `POST` | `/iuran`                           | Create & cleanup     | Created successfully, deleted | ✅ PASS |

**Schema Validated**:

```json
{
  "jenis": "string",
  "nominal": "number",
  "jatuh_tempo": "date",
  "id_rt": "integer",
  "id_bendahara": "integer"
}
```

---

### 3. Marketplace API (Stores & Products)

| Test Case             | Method | Endpoint                           | Expected Result     | Actual Result                 | Status  |
| --------------------- | ------ | ---------------------------------- | ------------------- | ----------------------------- | ------- |
| Get all stores        | `GET`  | `/toko`                            | Retrieve all stores | Retrieved 3 stores            | ✅ PASS |
| Get active products   | `GET`  | `/produk?is_deleted=eq.false`      | Filter active only  | Retrieved 10 products         | ✅ PASS |
| Get products by store | `GET`  | `/produk?id_toko=eq.{id}`          | Filter by store     | Retrieved 8 products          | ✅ PASS |
| Get product reviews   | `GET`  | `/review_produk?id_produk=eq.{id}` | Retrieve reviews    | Retrieved 10 reviews          | ✅ PASS |
| Create new store      | `POST` | `/toko`                            | Create & cleanup    | Created successfully, deleted | ✅ PASS |
| Update product        | `PUT`  | `/produk/{id}`                     | Update & verify     | Updated ID 33 successfully    | ✅ PASS |

**Key Validation**:

- Soft delete filter: `is_deleted=eq.false` working correctly
- Foreign key relationships validated
- Auto cleanup after test completion

---

### 4. Community API (Announcements & Activities)

| Test Case                 | Method | Endpoint                             | Expected Result      | Actual Result        | Status  |
| ------------------------- | ------ | ------------------------------------ | -------------------- | -------------------- | ------- |
| Get announcements ordered | `GET`  | `/pengumuman?order=created_at.desc`  | Latest announcements | Retrieved 18 records | ✅ PASS |
| Get activities ordered    | `GET`  | `/kegiatan?order=tanggal_mulai.desc` | Latest activities    | Retrieved 18 records | ✅ PASS |

**Data Sample**:

- Latest announcement: "Informasi Perbaikan Jalan RT"
- Ordering by date working correctly

---

### 5. Keuangan RT API (Neighborhood Finances)

| Test Case          | Method | Endpoint                    | Expected Result  | Actual Result               | Status  |
| ------------------ | ------ | --------------------------- | ---------------- | --------------------------- | ------- |
| Get finances by RT | `GET`  | `/keuangan?id_rt=eq.{idRt}` | Filter by RT     | Retrieved 1 record for RT 1 | ✅ PASS |
| Create transaction | `POST` | `/keuangan`                 | Create & cleanup | Created Rp 100,000, deleted | ✅ PASS |
| Update transaction | `PUT`  | `/keuangan/{id}`            | Update & cleanup | Updated ID 2178, deleted    | ✅ PASS |

**Enum Validation**:

- Transaction types: `"Pemasukan"` / `"Pengeluaran"` (case-sensitive)
- All enum values validated successfully

---

## 🔧 Test Configuration

### Authentication

- **Mode**: Authenticated (Supabase JWT)
- **Test User**: `rt@gmail.com`
- **Role**: RT (Ketua RT)
- **Token Caching**: Enabled for performance

### Environment

- **Base URL**: `https://qocwwkkirsscsxtfsrpk.supabase.co/rest/v1`
- **Timeout**: 30 seconds per request
- **Auto Cleanup**: Enabled for all CREATE/UPDATE operations

---

## 📈 Performance Metrics

| Metric              | Value            |
| ------------------- | ---------------- |
| Total Test Duration | 12 seconds       |
| Average per Test    | 0.6 seconds      |
| Total API Calls     | 25 requests      |
| Authentication Time | < 1 second       |
| Data Created        | 7 records        |
| Data Cleaned Up     | 7 records (100%) |

---

## 🚀 How to Run Tests

```powershell
# 1. Navigate to test directory
cd api_tests

# 2. Install dependencies
dart pub get

# 3. Run all tests
dart run test/run_all_tests.dart

# 4. View JSON results
cat results\test_results.json
```

---

---

**Built by**: PBL Kelompok 6  
**Tech Stack**: Dart 3.9.0 + Supabase REST API + PostgreSQL  
**Last Updated**: December 21, 2025

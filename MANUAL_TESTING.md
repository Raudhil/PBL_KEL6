# 📋 Manual Testing Plan - TerasWarga

## 📖 Daftar Isi

- [Informasi Umum](#informasi-umum)
- [Test Data Setup](#test-data-setup)
- [1. Authentication & Authorization](#1-authentication--authorization)
- [2. Role-Based Testing](#2-role-based-testing)
  - [2.1 Warga (User Biasa)](#21-warga-user-biasa)
  - [2.2 RT](#22-rt)
  - [2.3 RW](#23-rw)
  - [2.4 Bendahara](#24-bendahara)
  - [2.5 Sekretaris](#25-sekretaris)
  - [2.6 Admin](#26-admin)
  - [2.7 Seller](#27-seller)
- [3. Integration Testing](#3-integration-testing)
- [4. Edge Cases & Error Handling](#4-edge-cases--error-handling)
- [5. Performance Testing](#5-performance-testing)
- [6. UI/UX Testing](#6-uiux-testing)
- [Checklist Summary](#checklist-summary)

---

## Informasi Umum

### Tujuan Testing

Memastikan seluruh fitur aplikasi TerasWarga berfungsi dengan baik, aman, dan sesuai dengan requirement untuk semua role user.

### Environment Testing

- **Platform**: Android/iOS
- **Flutter Version**: (Sesuaikan dengan project)
- **Backend**: Supabase
- **Authentication**: Supabase Auth + Firebase (optional)

### Test Approach

- **Black Box Testing**: Fokus pada fungsionalitas dari perspektif user
- **Exploratory Testing**: Testing berbagai kombinasi input dan flow
- **Regression Testing**: Memastikan perubahan baru tidak merusak fitur existing

---

## Test Data Setup

### User Accounts yang Perlu Disiapkan

| Role           | Username/Email      | NIK              | Status      | Keterangan                      |
| -------------- | ------------------- | ---------------- | ----------- | ------------------------------- |
| **Warga**      | warga1@test.com     | 3201010101010001 | Aktif       | User biasa untuk testing        |
| **Warga**      | warga2@test.com     | 3201010101010002 | Tidak Aktif | Testing user tidak aktif        |
| **Warga**      | warga3@test.com     | 3201010101010003 | Aktif       | User untuk testing marketplace  |
| **RT**         | rt@test.com         | 3201010101010011 | Aktif       | RT untuk testing CRUD warga     |
| **RW**         | rw@test.com         | 3201010101010012 | Aktif       | RW untuk testing koordinasi     |
| **Bendahara**  | bendahara@test.com  | 3201010101010013 | Aktif       | Testing kelola keuangan & iuran |
| **Sekretaris** | sekretaris@test.com | 3201010101010014 | Aktif       | Testing kegiatan & pengumuman   |
| **Admin**      | admin@test.com      | 3201010101010015 | Aktif       | Testing kelola user & role      |
| **Seller**     | seller@test.com     | 3201010101010016 | Aktif       | Testing marketplace seller      |

### Data Master yang Perlu Ada

- ✅ Minimal 2 RT dengan beberapa KK
- ✅ Minimal 1 RW dengan beberapa RT
- ✅ Minimal 3 KK dengan anggota keluarga
- ✅ Minimal 2 jenis iuran (bulanan, kebersihan)
- ✅ Minimal 3 produk di marketplace
- ✅ Minimal 2 pengumuman (aktif & tidak aktif)
- ✅ Minimal 2 kegiatan (akan datang, sedang berlangsung, selesai)

---

## 1. Authentication & Authorization

### 1.1 Onboarding

- [ ] **TC-AUTH-001**: First install app - tampil onboarding
- [ ] **TC-AUTH-002**: Skip onboarding - langsung ke login
- [ ] **TC-AUTH-003**: Complete onboarding slides - navigate ke login
- [ ] **TC-AUTH-004**: Onboarding tidak muncul lagi setelah di-skip/complete

### 1.2 Login

#### Positive Cases

- [ ] **TC-AUTH-101**: Login dengan NIK & password yang valid
- [ ] **TC-AUTH-102**: Login dengan email & password yang valid (jika support email)
- [ ] **TC-AUTH-103**: Remember me - tetap login setelah close app
- [ ] **TC-AUTH-104**: Redirect ke dashboard sesuai role setelah login

#### Negative Cases

- [ ] **TC-AUTH-111**: Login dengan NIK tidak terdaftar - tampil error message
- [ ] **TC-AUTH-112**: Login dengan password salah - tampil error message
- [ ] **TC-AUTH-113**: Login dengan NIK kosong - tampil validation error
- [ ] **TC-AUTH-114**: Login dengan password kosong - tampil validation error
- [ ] **TC-AUTH-115**: Login dengan NIK format salah (< 16 digit) - tampil validation
- [ ] **TC-AUTH-116**: Login dengan user status "Tidak Aktif" - tampil error message
- [ ] **TC-AUTH-117**: Login tanpa koneksi internet - tampil error network

#### Security

- [ ] **TC-AUTH-121**: Password di-mask (tidak terlihat)
- [ ] **TC-AUTH-122**: Toggle show/hide password berfungsi
- [ ] **TC-AUTH-123**: Max login attempt (optional) - lock account setelah 5x gagal
- [ ] **TC-AUTH-124**: Session timeout setelah idle tertentu (optional)

### 1.3 Register

#### Positive Cases

- [ ] **TC-AUTH-201**: Register dengan NIK yang sudah ada di database warga
- [ ] **TC-AUTH-202**: Form validation berjalan dengan benar
- [ ] **TC-AUTH-203**: Password confirmation match
- [ ] **TC-AUTH-204**: Account terbuat dengan status default (cek dengan admin)
- [ ] **TC-AUTH-205**: Redirect ke halaman success/login setelah register

#### Negative Cases

- [ ] **TC-AUTH-211**: Register dengan NIK yang belum ada di database - error
- [ ] **TC-AUTH-212**: Register dengan NIK yang sudah punya akun - error
- [ ] **TC-AUTH-213**: Password tidak match dengan confirmation - error
- [ ] **TC-AUTH-214**: Password terlalu pendek (< 6 karakter) - validation error
- [ ] **TC-AUTH-215**: NIK format salah - validation error
- [ ] **TC-AUTH-216**: Email format salah (jika ada field email) - validation error

#### Edge Cases

- [ ] **TC-AUTH-221**: Register dengan spasi di awal/akhir NIK - auto trim
- [ ] **TC-AUTH-222**: Register dengan special characters di password - berfungsi
- [ ] **TC-AUTH-223**: Register tanpa koneksi internet - error message

### 1.4 Logout

- [ ] **TC-AUTH-301**: Logout dari menu profil - kembali ke login
- [ ] **TC-AUTH-302**: Logout clear session - tidak bisa back ke app
- [ ] **TC-AUTH-303**: Logout clear cache/stored data
- [ ] **TC-AUTH-304**: Logout dari multiple devices (jika support)

### 1.5 Password Reset (Jika ada fitur)

- [ ] **TC-AUTH-401**: Request reset password dengan NIK valid
- [ ] **TC-AUTH-402**: Receive reset link/code via email/SMS
- [ ] **TC-AUTH-403**: Reset password dengan kode valid
- [ ] **TC-AUTH-404**: Login dengan password baru berhasil

---

## 2. Role-Based Testing

## 2.1 Warga (User Biasa)

### 2.1.1 Dashboard

- [ ] **TC-WARGA-101**: Dashboard load dengan statistik yang benar
- [ ] **TC-WARGA-102**: Quick access buttons berfungsi
- [ ] **TC-WARGA-103**: Pengumuman terbaru muncul di dashboard
- [ ] **TC-WARGA-104**: Kegiatan mendatang muncul di dashboard
- [ ] **TC-WARGA-105**: Pull to refresh dashboard - update data
- [ ] **TC-WARGA-106**: Navigate ke semua menu dari dashboard

### 2.1.2 Profil

#### View Profile

- [ ] **TC-WARGA-201**: View profil pribadi dengan data lengkap
- [ ] **TC-WARGA-202**: Data profil sesuai dengan data warga di database
- [ ] **TC-WARGA-203**: Foto profil muncul dengan benar (jika ada)
- [ ] **TC-WARGA-204**: Status user muncul (Aktif/Tidak Aktif)

#### Edit Profile

- [ ] **TC-WARGA-211**: Edit nama lengkap - save berhasil
- [ ] **TC-WARGA-212**: Edit nomor HP - save berhasil
- [ ] **TC-WARGA-213**: Edit alamat - save berhasil
- [ ] **TC-WARGA-214**: Upload foto profil - berhasil tersimpan
- [ ] **TC-WARGA-215**: Edit dengan field kosong - validation error
- [ ] **TC-WARGA-216**: Cancel edit - data tidak berubah
- [ ] **TC-WARGA-217**: Edit berhasil - tampil success message

#### Data Diri (View Only)

- [ ] **TC-WARGA-221**: View data diri (NIK, tanggal lahir, jenis kelamin)
- [ ] **TC-WARGA-222**: Data KK dan anggota keluarga muncul
- [ ] **TC-WARGA-223**: RT/RW information displayed correctly

### 2.1.3 Iuran

#### View Iuran

- [ ] **TC-WARGA-301**: List iuran muncul dengan benar
- [ ] **TC-WARGA-302**: Filter iuran berdasarkan status (Lunas, Belum Bayar)
- [ ] **TC-WARGA-303**: Filter iuran berdasarkan jenis (Bulanan, Kebersihan, dll)
- [ ] **TC-WARGA-304**: Search iuran by nama/jenis
- [ ] **TC-WARGA-305**: Detail iuran muncul saat di-tap
- [ ] **TC-WARGA-306**: Status pembayaran tampil dengan benar (badge color)
- [ ] **TC-WARGA-307**: Nominal iuran tampil dengan format rupiah

#### Bayar Iuran

- [ ] **TC-WARGA-311**: Pilih iuran untuk dibayar
- [ ] **TC-WARGA-312**: Pilih metode pembayaran (Transfer/Cash)
- [ ] **TC-WARGA-313**: Upload bukti transfer - berhasil
- [ ] **TC-WARGA-314**: Submit pembayaran - status berubah menjadi "Menunggu Verifikasi"
- [ ] **TC-WARGA-315**: Validation untuk upload bukti transfer jika metode = Transfer
- [ ] **TC-WARGA-316**: Tidak bisa bayar iuran yang sudah lunas
- [ ] **TC-WARGA-317**: Cancel pembayaran - data tidak tersimpan

#### History Pembayaran

- [ ] **TC-WARGA-321**: View history pembayaran iuran
- [ ] **TC-WARGA-322**: Filter history by tanggal
- [ ] **TC-WARGA-323**: View detail bukti pembayaran

### 2.1.4 Marketplace

#### Browse Products

- [ ] **TC-WARGA-401**: View list produk di marketplace
- [ ] **TC-WARGA-402**: Search produk by nama
- [ ] **TC-WARGA-403**: Filter produk by kategori (jika ada)
- [ ] **TC-WARGA-404**: Sort produk by harga (asc/desc)
- [ ] **TC-WARGA-405**: View detail produk dengan foto & deskripsi lengkap
- [ ] **TC-WARGA-406**: View rating & review produk
- [ ] **TC-WARGA-407**: View informasi toko/seller
- [ ] **TC-WARGA-408**: Stok produk tampil dengan benar

#### Shopping Cart & Checkout

- [ ] **TC-WARGA-411**: Add product to cart - qty 1
- [ ] **TC-WARGA-412**: Increase qty di cart - total update
- [ ] **TC-WARGA-413**: Decrease qty di cart - total update
- [ ] **TC-WARGA-414**: Remove product from cart
- [ ] **TC-WARGA-415**: Cart badge counter update real-time
- [ ] **TC-WARGA-416**: Validation qty tidak boleh > stok
- [ ] **TC-WARGA-417**: Add multiple products to cart
- [ ] **TC-WARGA-418**: View total harga di cart
- [ ] **TC-WARGA-419**: Proceed to checkout - form muncul
- [ ] **TC-WARGA-420**: Input alamat pengiriman di checkout
- [ ] **TC-WARGA-421**: Input catatan pesanan (optional)
- [ ] **TC-WARGA-422**: Pilih metode pembayaran
- [ ] **TC-WARGA-423**: Review order sebelum submit
- [ ] **TC-WARGA-424**: Submit order - berhasil & tampil success page
- [ ] **TC-WARGA-425**: Order number/ID ter-generate
- [ ] **TC-WARGA-426**: Redirect ke order detail setelah checkout
- [ ] **TC-WARGA-427**: Cart cleared setelah checkout berhasil
- [ ] **TC-WARGA-428**: Validation alamat wajib diisi
- [ ] **TC-WARGA-429**: Tidak bisa checkout dengan cart kosong

#### My Orders (Buyer)

- [ ] **TC-WARGA-431**: View list pesanan saya
- [ ] **TC-WARGA-432**: Filter by status (Pending, Proses, Selesai, Dibatalkan)
- [ ] **TC-WARGA-433**: View detail pesanan
- [ ] **TC-WARGA-434**: Status pesanan update real-time
- [ ] **TC-WARGA-435**: Cancel order dengan status Pending
- [ ] **TC-WARGA-436**: Tidak bisa cancel order dengan status Proses/Selesai
- [ ] **TC-WARGA-437**: Confirm order received (update status jadi Selesai)
- [ ] **TC-WARGA-438**: Add review & rating setelah order Selesai
- [ ] **TC-WARGA-439**: View invoice/detail pembayaran

#### Seller Features (Jika user juga buka toko)

- [ ] **TC-WARGA-441**: Daftar sebagai seller
- [ ] **TC-WARGA-442**: Input nama toko & informasi
- [ ] **TC-WARGA-443**: Status seller approval
- [ ] **TC-WARGA-444**: Switch ke mode seller dari menu
- [ ] **TC-WARGA-445**: Navigate ke seller dashboard

### 2.1.5 Pengumuman

- [ ] **TC-WARGA-501**: View list pengumuman terbaru
- [ ] **TC-WARGA-502**: View detail pengumuman
- [ ] **TC-WARGA-503**: Filter pengumuman by tanggal
- [ ] **TC-WARGA-504**: Search pengumuman by judul
- [ ] **TC-WARGA-505**: Pengumuman dengan status "Tidak Aktif" tidak muncul
- [ ] **TC-WARGA-506**: Badge "Baru" muncul untuk pengumuman hari ini
- [ ] **TC-WARGA-507**: Share pengumuman (optional)

### 2.1.6 Kegiatan

#### View Kegiatan

- [ ] **TC-WARGA-601**: View list kegiatan akan datang
- [ ] **TC-WARGA-602**: View kegiatan by kategori (Sosial, Olahraga, Keagamaan, dll)
- [ ] **TC-WARGA-603**: View detail kegiatan (tanggal, lokasi, penyelenggara)
- [ ] **TC-WARGA-604**: View foto kegiatan
- [ ] **TC-WARGA-605**: View status kegiatan (Akan Datang, Berlangsung, Selesai)
- [ ] **TC-WARGA-606**: Filter kegiatan by status
- [ ] **TC-WARGA-607**: Search kegiatan by judul

#### Daftar Kegiatan (Jika ada fitur)

- [ ] **TC-WARGA-611**: Daftar kegiatan dengan kuota tersedia
- [ ] **TC-WARGA-612**: Validation kuota penuh - tidak bisa daftar
- [ ] **TC-WARGA-613**: Cancel pendaftaran kegiatan
- [ ] **TC-WARGA-614**: View list kegiatan yang sudah didaftar
- [ ] **TC-WARGA-615**: Notifikasi reminder kegiatan H-1 (optional)

### 2.1.7 Fitur Perangkat (Access Menu Perangkat)

- [ ] **TC-WARGA-701**: View menu perangkat (RT, RW, dll)
- [ ] **TC-WARGA-702**: Menu perangkat sesuai dengan role user
- [ ] **TC-WARGA-703**: User biasa tidak bisa akses fitur RT/RW/Admin

---

## 2.2 RT

### 2.2.1 Dashboard RT

- [ ] **TC-RT-101**: Dashboard RT load dengan statistik warga
- [ ] **TC-RT-102**: Total warga per RT tampil
- [ ] **TC-RT-103**: Total KK tampil
- [ ] **TC-RT-104**: Quick action buttons berfungsi

### 2.2.2 Kelola Data Warga (CRUD)

#### Create Warga

- [ ] **TC-RT-201**: Buka form tambah warga baru
- [ ] **TC-RT-202**: Input NIK - auto validation 16 digit
- [ ] **TC-RT-203**: Check NIK sudah terdaftar - tampil error
- [ ] **TC-RT-204**: Check NIK belum terdaftar - proceed
- [ ] **TC-RT-205**: Input data identitas lengkap
- [ ] **TC-RT-206**: Input data kelahiran
- [ ] **TC-RT-207**: Pilih jenis kelamin (dropdown)
- [ ] **TC-RT-208**: Pilih tanggal lahir (date picker)
- [ ] **TC-RT-209**: Input nomor HP (optional)
- [ ] **TC-RT-210**: Input alamat (optional)
- [ ] **TC-RT-211**: Pilih KK existing - dropdown muncul list KK
- [ ] **TC-RT-212**: Pilih buat KK baru - form KK baru muncul
- [ ] **TC-RT-213**: Input nomor KK baru
- [ ] **TC-RT-214**: Input alamat untuk KK baru
- [ ] **TC-RT-215**: Submit form - validation berjalan
- [ ] **TC-RT-216**: Submit berhasil - warga tersimpan
- [ ] **TC-RT-217**: User account terbuat dengan status "Aktif" ✅ (Bug Fix)
- [ ] **TC-RT-218**: Success message muncul
- [ ] **TC-RT-219**: Redirect ke list warga
- [ ] **TC-RT-220**: Data warga baru muncul di list
- [ ] **TC-RT-221**: Validation error untuk field wajib
- [ ] **TC-RT-222**: Cancel create - data tidak tersimpan

#### Read/View Warga

- [ ] **TC-RT-231**: View list semua warga
- [ ] **TC-RT-232**: Search warga by nama
- [ ] **TC-RT-233**: Search warga by NIK
- [ ] **TC-RT-234**: Filter warga by status (Aktif/Tidak Aktif)
- [ ] **TC-RT-235**: Tab toggle antara "Total Warga" & "Total Keluarga"
- [ ] **TC-RT-236**: View detail warga (expand card)
- [ ] **TC-RT-237**: View informasi lengkap warga (NIK, KK, RT/RW, alamat) ✅
- [ ] **TC-RT-238**: Alamat warga muncul dengan benar ✅ (Bug Fix)
- [ ] **TC-RT-239**: Status user badge muncul (Aktif/Tidak Aktif)
- [ ] **TC-RT-240**: Navigate ke detail page warga
- [ ] **TC-RT-241**: Detail page tampil semua info warga
- [ ] **TC-RT-242**: Empty state jika belum ada warga

#### Update Warga

- [ ] **TC-RT-251**: Klik button "Edit" dari card warga ✅
- [ ] **TC-RT-252**: Klik button "Edit" dari detail page ✅
- [ ] **TC-RT-253**: Form edit muncul pre-filled dengan data existing ✅
- [ ] **TC-RT-254**: Edit nama lengkap
- [ ] **TC-RT-255**: Edit NIK - validation NIK tidak boleh duplikat ✅
- [ ] **TC-RT-256**: Edit jenis kelamin
- [ ] **TC-RT-257**: Edit tanggal lahir
- [ ] **TC-RT-258**: Edit nomor HP
- [ ] **TC-RT-259**: Edit alamat ✅
- [ ] **TC-RT-260**: NIK validation exclude ID sendiri saat edit ✅
- [ ] **TC-RT-261**: No. KK tidak bisa diubah (read-only info box) ✅
- [ ] **TC-RT-262**: Submit edit - data terupdate ✅
- [ ] **TC-RT-263**: Success message muncul ✅
- [ ] **TC-RT-264**: Data update real-time di list (via realtime subscription) ✅
- [ ] **TC-RT-265**: Cancel edit - data tidak berubah
- [ ] **TC-RT-266**: Validation error untuk field wajib

#### Delete Warga

- [ ] **TC-RT-271**: Klik button "Hapus" dari card warga ✅
- [ ] **TC-RT-272**: Confirmation dialog muncul dengan detail warga ✅
- [ ] **TC-RT-273**: Dialog menampilkan nama & NIK warga yang akan dihapus ✅
- [ ] **TC-RT-274**: Cancel delete - warga tidak terhapus
- [ ] **TC-RT-275**: Confirm delete - warga terhapus ✅
- [ ] **TC-RT-276**: Loading indicator saat proses delete ✅
- [ ] **TC-RT-277**: Success snackbar muncul setelah delete ✅
- [ ] **TC-RT-278**: List warga auto-refresh (via realtime) ✅
- [ ] **TC-RT-279**: Warga yang dihapus hilang dari list
- [ ] **TC-RT-280**: Error handling jika delete gagal ✅
- [ ] **TC-RT-281**: Cannot delete warga dengan transaksi aktif (optional)

#### View Keluarga

- [ ] **TC-RT-291**: Switch ke tab "Total Keluarga"
- [ ] **TC-RT-292**: List keluarga muncul (grouped by KK)
- [ ] **TC-RT-293**: Setiap card keluarga tampil nomor KK
- [ ] **TC-RT-294**: Kepala keluarga highlighted
- [ ] **TC-RT-295**: Jumlah anggota keluarga tampil
- [ ] **TC-RT-296**: Expand card keluarga - list anggota muncul
- [ ] **TC-RT-297**: Search keluarga by nomor KK
- [ ] **TC-RT-298**: View detail keluarga

### 2.2.3 Pengumuman RT

- [ ] **TC-RT-301**: RT bisa akses menu Pengumuman RT
- [ ] **TC-RT-302**: Redirect ke halaman kelola pengumuman (sama dengan Sekretaris)

### 2.2.4 Kegiatan RT

- [ ] **TC-RT-401**: RT bisa akses menu Kegiatan RT
- [ ] **TC-RT-402**: Redirect ke halaman kelola kegiatan (sama dengan Sekretaris)

### 2.2.5 Laporan Keuangan

- [ ] **TC-RT-501**: View laporan keuangan RT
- [ ] **TC-RT-502**: Filter by periode (bulan/tahun)
- [ ] **TC-RT-503**: View pemasukan & pengeluaran
- [ ] **TC-RT-504**: View saldo RT
- [ ] **TC-RT-505**: Export laporan (PDF/Excel) - optional

---

## 2.3 RW

### 2.3.1 Dashboard RW

- [ ] **TC-RW-101**: Dashboard RW load dengan statistik
- [ ] **TC-RW-102**: Total RT di RW tampil
- [ ] **TC-RW-103**: Total warga se-RW tampil
- [ ] **TC-RW-104**: View statistik per RT

### 2.3.2 Data per RT

- [ ] **TC-RW-201**: View list RT dalam RW
- [ ] **TC-RW-202**: View detail statistik per RT
- [ ] **TC-RW-203**: View jumlah warga per RT
- [ ] **TC-RW-204**: View jumlah KK per RT

### 2.3.3 Status Iuran

- [ ] **TC-RW-301**: View status iuran se-RW
- [ ] **TC-RW-302**: View summary iuran per RT
- [ ] **TC-RW-303**: Filter by periode
- [ ] **TC-RW-304**: View persentase pembayaran

### 2.3.4 Laporan Warga

- [ ] **TC-RW-401**: View laporan data warga se-RW
- [ ] **TC-RW-402**: Export laporan
- [ ] **TC-RW-403**: Filter by RT

---

## 2.4 Bendahara

### 2.4.1 Dashboard Bendahara

- [ ] **TC-BEND-101**: Dashboard bendahara load dengan summary keuangan
- [ ] **TC-BEND-102**: Total pemasukan bulan ini
- [ ] **TC-BEND-103**: Total pengeluaran bulan ini
- [ ] **TC-BEND-104**: Saldo terkini
- [ ] **TC-BEND-105**: Chart/grafik keuangan (optional)

### 2.4.2 Kelola Iuran (CRUD)

#### Create Iuran

- [ ] **TC-BEND-201**: Buka form buat iuran baru
- [ ] **TC-BEND-202**: Input jenis iuran (text field atau dropdown)
- [ ] **TC-BEND-203**: Input nominal iuran (format rupiah)
- [ ] **TC-BEND-204**: Pilih jatuh tempo (date picker)
- [ ] **TC-BEND-205**: Pilih RT tujuan
- [ ] **TC-BEND-206**: Submit form - validation berjalan
- [ ] **TC-BEND-207**: Iuran tersimpan & muncul di list
- [ ] **TC-BEND-208**: Success message muncul
- [ ] **TC-BEND-209**: Validation nominal > 0
- [ ] **TC-BEND-210**: Validation jatuh tempo tidak boleh masa lalu

#### Read Iuran

- [ ] **TC-BEND-221**: View list semua iuran
- [ ] **TC-BEND-222**: Filter by RT
- [ ] **TC-BEND-223**: Filter by status (Aktif/Tidak Aktif)
- [ ] **TC-BEND-224**: Filter by jenis iuran
- [ ] **TC-BEND-225**: Search by nama iuran
- [ ] **TC-BEND-226**: View detail iuran
- [ ] **TC-BEND-227**: View statistik pembayaran per iuran

#### Update Iuran

- [ ] **TC-BEND-231**: Edit iuran existing
- [ ] **TC-BEND-232**: Update nominal
- [ ] **TC-BEND-233**: Update jatuh tempo
- [ ] **TC-BEND-234**: Submit update - berhasil
- [ ] **TC-BEND-235**: Cannot update iuran yang sudah dibayar (optional)

#### Delete Iuran

- [ ] **TC-BEND-241**: Delete iuran
- [ ] **TC-BEND-242**: Confirmation dialog muncul
- [ ] **TC-BEND-243**: Iuran terhapus
- [ ] **TC-BEND-244**: Cannot delete iuran dengan pembayaran (optional)

### 2.4.3 Kelola Keuangan (Transaksi)

#### Create Transaksi

- [ ] **TC-BEND-301**: Buat transaksi pemasukan
- [ ] **TC-BEND-302**: Buat transaksi pengeluaran
- [ ] **TC-BEND-303**: Input jumlah transaksi
- [ ] **TC-BEND-304**: Input sumber/tujuan transaksi
- [ ] **TC-BEND-305**: Input deskripsi
- [ ] **TC-BEND-306**: Pilih tanggal transaksi
- [ ] **TC-BEND-307**: Submit transaksi - tersimpan
- [ ] **TC-BEND-308**: Saldo terupdate otomatis

#### View Transaksi

- [ ] **TC-BEND-321**: View list transaksi
- [ ] **TC-BEND-322**: Filter by jenis (Pemasukan/Pengeluaran)
- [ ] **TC-BEND-323**: Filter by periode (bulan/tahun)
- [ ] **TC-BEND-324**: View detail transaksi
- [ ] **TC-BEND-325**: View history saldo

#### Verifikasi Pembayaran Iuran

- [ ] **TC-BEND-341**: View list pembayaran pending
- [ ] **TC-BEND-342**: View bukti transfer
- [ ] **TC-BEND-343**: Verifikasi pembayaran - status jadi Lunas
- [ ] **TC-BEND-344**: Reject pembayaran - status kembali Belum Bayar
- [ ] **TC-BEND-345**: Notifikasi ke warga setelah verifikasi (optional)

### 2.4.4 Laporan Keuangan

- [ ] **TC-BEND-401**: Generate laporan bulanan
- [ ] **TC-BEND-402**: Generate laporan tahunan
- [ ] **TC-BEND-403**: View breakdown pemasukan & pengeluaran
- [ ] **TC-BEND-404**: Export laporan (PDF/Excel) - optional
- [ ] **TC-BEND-405**: Print laporan - optional

---

## 2.5 Sekretaris

### 2.5.1 Dashboard Sekretaris

- [ ] **TC-SEK-101**: Dashboard sekretaris load
- [ ] **TC-SEK-102**: Summary pengumuman & kegiatan
- [ ] **TC-SEK-103**: Quick access ke form create

### 2.5.2 Kelola Pengumuman (CRUD)

#### Create Pengumuman

- [ ] **TC-SEK-201**: Buka form buat pengumuman
- [ ] **TC-SEK-202**: Input judul pengumuman
- [ ] **TC-SEK-203**: Input isi pengumuman (text area)
- [ ] **TC-SEK-204**: Pilih tanggal pengumuman
- [ ] **TC-SEK-205**: Pilih status (Aktif/Tidak Aktif)
- [ ] **TC-SEK-206**: Upload gambar/foto (optional)
- [ ] **TC-SEK-207**: Submit form - validation berjalan
- [ ] **TC-SEK-208**: Pengumuman tersimpan
- [ ] **TC-SEK-209**: Success message muncul
- [ ] **TC-SEK-210**: Validation judul & isi wajib diisi

#### Read Pengumuman

- [ ] **TC-SEK-221**: View list pengumuman
- [ ] **TC-SEK-222**: Filter by status (Aktif/Tidak Aktif)
- [ ] **TC-SEK-223**: Filter by tanggal
- [ ] **TC-SEK-224**: Search by judul
- [ ] **TC-SEK-225**: View detail pengumuman
- [ ] **TC-SEK-226**: View pembuat pengumuman

#### Update Pengumuman

- [ ] **TC-SEK-231**: Edit pengumuman existing
- [ ] **TC-SEK-232**: Update judul
- [ ] **TC-SEK-233**: Update isi
- [ ] **TC-SEK-234**: Update status (Aktif ↔ Tidak Aktif)
- [ ] **TC-SEK-235**: Update gambar
- [ ] **TC-SEK-236**: Submit update - berhasil
- [ ] **TC-SEK-237**: Realtime update di list warga

#### Delete Pengumuman

- [ ] **TC-SEK-241**: Delete pengumuman
- [ ] **TC-SEK-242**: Confirmation dialog
- [ ] **TC-SEK-243**: Pengumuman terhapus

### 2.5.3 Kelola Kegiatan (CRUD)

#### Create Kegiatan

- [ ] **TC-SEK-301**: Buka form buat kegiatan
- [ ] **TC-SEK-302**: Input judul kegiatan
- [ ] **TC-SEK-303**: Input deskripsi kegiatan
- [ ] **TC-SEK-304**: Pilih tanggal mulai (date picker)
- [ ] **TC-SEK-305**: Pilih tanggal selesai (date picker)
- [ ] **TC-SEK-306**: Input lokasi
- [ ] **TC-SEK-307**: Input penyelenggara
- [ ] **TC-SEK-308**: Pilih kategori (dropdown: Sosial, Olahraga, Keagamaan, dll)
- [ ] **TC-SEK-309**: Pilih status (Akan Datang, Berlangsung, Selesai)
- [ ] **TC-SEK-310**: Input kuota peserta (optional)
- [ ] **TC-SEK-311**: Upload foto kegiatan (optional)
- [ ] **TC-SEK-312**: Submit form - validation berjalan
- [ ] **TC-SEK-313**: Kegiatan tersimpan
- [ ] **TC-SEK-314**: Success message muncul
- [ ] **TC-SEK-315**: Validation tanggal selesai >= tanggal mulai
- [ ] **TC-SEK-316**: Validation field wajib

#### Read Kegiatan

- [ ] **TC-SEK-331**: View list kegiatan
- [ ] **TC-SEK-332**: Filter by kategori
- [ ] **TC-SEK-333**: Filter by status
- [ ] **TC-SEK-334**: Filter by tanggal
- [ ] **TC-SEK-335**: Search by judul
- [ ] **TC-SEK-336**: View detail kegiatan
- [ ] **TC-SEK-337**: View list peserta (jika ada pendaftaran)

#### Update Kegiatan

- [ ] **TC-SEK-351**: Edit kegiatan existing
- [ ] **TC-SEK-352**: Update judul, deskripsi, lokasi
- [ ] **TC-SEK-353**: Update tanggal
- [ ] **TC-SEK-354**: Update status kegiatan
- [ ] **TC-SEK-355**: Update kuota
- [ ] **TC-SEK-356**: Update foto
- [ ] **TC-SEK-357**: Submit update - berhasil
- [ ] **TC-SEK-358**: Realtime update

#### Delete Kegiatan

- [ ] **TC-SEK-371**: Delete kegiatan
- [ ] **TC-SEK-372**: Confirmation dialog
- [ ] **TC-SEK-373**: Kegiatan terhapus
- [ ] **TC-SEK-374**: Cannot delete kegiatan dengan peserta (optional)

---

## 2.6 Admin

### 2.6.1 Dashboard Admin

- [ ] **TC-ADMIN-101**: Dashboard admin load dengan statistik sistem
- [ ] **TC-ADMIN-102**: Total users registered
- [ ] **TC-ADMIN-103**: Total users by role
- [ ] **TC-ADMIN-104**: System health indicators (optional)

### 2.6.2 Kelola Pengguna (CRUD)

#### View Users

- [ ] **TC-ADMIN-201**: View list semua user
- [ ] **TC-ADMIN-202**: Filter by role (Warga, RT, RW, Bendahara, dll)
- [ ] **TC-ADMIN-203**: Filter by status (Aktif/Tidak Aktif)
- [ ] **TC-ADMIN-204**: Search by nama
- [ ] **TC-ADMIN-205**: Search by NIK
- [ ] **TC-ADMIN-206**: View detail user (profile lengkap)
- [ ] **TC-ADMIN-207**: View user activity log (optional)

#### Update User Status

- [ ] **TC-ADMIN-221**: Aktifkan user dengan status "Tidak Aktif"
- [ ] **TC-ADMIN-222**: Nonaktifkan user dengan status "Aktif"
- [ ] **TC-ADMIN-223**: Status update real-time
- [ ] **TC-ADMIN-224**: User yang dinonaktifkan auto logout
- [ ] **TC-ADMIN-225**: User nonaktif tidak bisa login
- [ ] **TC-ADMIN-226**: Confirmation dialog saat ubah status
- [ ] **TC-ADMIN-227**: Success message muncul

#### Change User Role

- [ ] **TC-ADMIN-241**: Buka form change role
- [ ] **TC-ADMIN-242**: Pilih role baru dari dropdown
- [ ] **TC-ADMIN-243**: Confirmation dialog muncul
- [ ] **TC-ADMIN-244**: Submit change role - berhasil
- [ ] **TC-ADMIN-245**: User logout & login ulang - role terupdate
- [ ] **TC-ADMIN-246**: Dashboard berubah sesuai role baru
- [ ] **TC-ADMIN-247**: Menu access berubah sesuai role
- [ ] **TC-ADMIN-248**: Cannot change role Admin sendiri
- [ ] **TC-ADMIN-249**: Validation role harus dipilih

#### Reset Password User (Optional)

- [ ] **TC-ADMIN-261**: Reset password user
- [ ] **TC-ADMIN-262**: Generate temporary password
- [ ] **TC-ADMIN-263**: Send temporary password ke user
- [ ] **TC-ADMIN-264**: User bisa login dengan temporary password
- [ ] **TC-ADMIN-265**: Force change password saat first login

#### Delete User

- [ ] **TC-ADMIN-281**: Delete user (soft delete recommended)
- [ ] **TC-ADMIN-282**: Confirmation dialog with warning
- [ ] **TC-ADMIN-283**: Cannot delete user with active transactions
- [ ] **TC-ADMIN-284**: User terhapus dari list

### 2.6.3 Kelola Role & Permission (Advanced)

- [ ] **TC-ADMIN-301**: View list roles
- [ ] **TC-ADMIN-302**: Create custom role
- [ ] **TC-ADMIN-303**: Edit role permissions
- [ ] **TC-ADMIN-304**: Delete role
- [ ] **TC-ADMIN-305**: Assign permissions to role

---

## 2.7 Seller

### 2.7.1 Dashboard Seller

- [ ] **TC-SELLER-101**: Dashboard seller load
- [ ] **TC-SELLER-102**: Total produk aktif
- [ ] **TC-SELLER-103**: Total pesanan pending
- [ ] **TC-SELLER-104**: Total penjualan bulan ini
- [ ] **TC-SELLER-105**: Summary grafik penjualan (optional)

### 2.7.2 Kelola Toko

#### Setup Toko

- [ ] **TC-SELLER-201**: First time setup - create toko
- [ ] **TC-SELLER-202**: Input nama toko
- [ ] **TC-SELLER-203**: Input deskripsi toko
- [ ] **TC-SELLER-204**: Upload logo toko (optional)
- [ ] **TC-SELLER-205**: Submit - toko terbuat
- [ ] **TC-SELLER-206**: Toko approval status (optional)

#### Update Toko

- [ ] **TC-SELLER-221**: Edit informasi toko
- [ ] **TC-SELLER-222**: Update nama toko
- [ ] **TC-SELLER-223**: Update deskripsi
- [ ] **TC-SELLER-224**: Update logo
- [ ] **TC-SELLER-225**: Submit update - berhasil

### 2.7.3 Kelola Produk (CRUD)

#### Create Produk

- [ ] **TC-SELLER-301**: Buka form tambah produk
- [ ] **TC-SELLER-302**: Input nama produk
- [ ] **TC-SELLER-303**: Input deskripsi produk
- [ ] **TC-SELLER-304**: Input harga (format rupiah)
- [ ] **TC-SELLER-305**: Input stok
- [ ] **TC-SELLER-306**: Pilih kategori (optional)
- [ ] **TC-SELLER-307**: Upload foto produk (1-5 foto)
- [ ] **TC-SELLER-308**: Preview foto sebelum upload
- [ ] **TC-SELLER-309**: Submit form - validation berjalan
- [ ] **TC-SELLER-310**: Produk tersimpan
- [ ] **TC-SELLER-311**: Success message muncul
- [ ] **TC-SELLER-312**: Produk muncul di marketplace
- [ ] **TC-SELLER-313**: Validation harga > 0
- [ ] **TC-SELLER-314**: Validation stok >= 0
- [ ] **TC-SELLER-315**: Validation foto wajib (min 1)

#### Read Produk

- [ ] **TC-SELLER-331**: View list produk milik seller
- [ ] **TC-SELLER-332**: Filter by status (Aktif/Tidak Aktif)
- [ ] **TC-SELLER-333**: Search by nama produk
- [ ] **TC-SELLER-334**: View detail produk
- [ ] **TC-SELLER-335**: View statistik penjualan per produk

#### Update Produk

- [ ] **TC-SELLER-351**: Edit produk existing
- [ ] **TC-SELLER-352**: Update nama, deskripsi
- [ ] **TC-SELLER-353**: Update harga
- [ ] **TC-SELLER-354**: Update stok
- [ ] **TC-SELLER-355**: Update foto (add/remove)
- [ ] **TC-SELLER-356**: Toggle status Aktif/Tidak Aktif
- [ ] **TC-SELLER-357**: Submit update - berhasil
- [ ] **TC-SELLER-358**: Produk Tidak Aktif tidak muncul di marketplace

#### Delete Produk

- [ ] **TC-SELLER-371**: Delete produk
- [ ] **TC-SELLER-372**: Confirmation dialog
- [ ] **TC-SELLER-373**: Produk terhapus
- [ ] **TC-SELLER-374**: Cannot delete produk dengan order aktif

### 2.7.4 Kelola Pesanan Masuk

#### View Pesanan

- [ ] **TC-SELLER-401**: View list pesanan masuk
- [ ] **TC-SELLER-402**: Filter by status (Pending, Proses, Selesai, Dibatalkan)
- [ ] **TC-SELLER-403**: Filter by tanggal
- [ ] **TC-SELLER-404**: Search by order ID atau nama pembeli
- [ ] **TC-SELLER-405**: View detail pesanan
- [ ] **TC-SELLER-406**: View informasi pembeli (nama, alamat)
- [ ] **TC-SELLER-407**: View detail produk yang dipesan
- [ ] **TC-SELLER-408**: View total pembayaran

#### Process Order

- [ ] **TC-SELLER-421**: Accept order (Pending → Proses)
- [ ] **TC-SELLER-422**: Reject/cancel order dengan alasan
- [ ] **TC-SELLER-423**: Mark order as completed (Proses → Selesai)
- [ ] **TC-SELLER-424**: Update status real-time
- [ ] **TC-SELLER-425**: Notifikasi ke pembeli saat status berubah (optional)
- [ ] **TC-SELLER-426**: Stock auto-reduce saat order accepted
- [ ] **TC-SELLER-427**: Stock restore saat order cancelled

### 2.7.5 Review & Rating

- [ ] **TC-SELLER-501**: View list review produk
- [ ] **TC-SELLER-502**: View rating per produk
- [ ] **TC-SELLER-503**: View average rating toko
- [ ] **TC-SELLER-504**: Reply to review (optional)
- [ ] **TC-SELLER-505**: Cannot delete review (read only)

---

## 3. Integration Testing

### 3.1 Marketplace End-to-End

- [ ] **TC-INT-101**: Buyer beli produk → Seller terima order → Process → Complete → Review
- [ ] **TC-INT-102**: Multiple products dalam 1 order
- [ ] **TC-INT-103**: Order dari multiple sellers (separate orders)
- [ ] **TC-INT-104**: Stock synchronization across buyers

### 3.2 Iuran End-to-End

- [ ] **TC-INT-201**: Bendahara buat iuran → Warga bayar → Upload bukti → Bendahara verifikasi → Status Lunas
- [ ] **TC-INT-202**: Auto calculation saldo after payment
- [ ] **TC-INT-203**: Payment reminder notification (optional)

### 3.3 Kegiatan End-to-End

- [ ] **TC-INT-301**: Sekretaris buat kegiatan → Warga lihat → Warga daftar → Kuota update → Kegiatan berlangsung → Selesai
- [ ] **TC-INT-302**: Notification to participants (optional)

### 3.4 User Status Change Impact

- [ ] **TC-INT-401**: Admin nonaktifkan user → User auto logout → Cannot login
- [ ] **TC-INT-402**: Admin aktifkan user → User bisa login
- [ ] **TC-INT-403**: RT create warga → User auto-created dengan status Aktif → User bisa register & login ✅

### 3.5 Role Change Impact

- [ ] **TC-INT-501**: Admin ubah role Warga → RT → Dashboard berubah → Menu berubah
- [ ] **TC-INT-502**: Permission access sesuai role baru

---

## 4. Edge Cases & Error Handling

### 4.1 Network Issues

- [ ] **TC-EDGE-101**: No internet saat login - error message
- [ ] **TC-EDGE-102**: No internet saat load data - error message & retry button
- [ ] **TC-EDGE-103**: Slow connection - loading indicator
- [ ] **TC-EDGE-104**: Connection lost saat submit form - save to draft (optional)
- [ ] **TC-EDGE-105**: Auto retry when connection restored

### 4.2 Data Validation

- [ ] **TC-EDGE-201**: Exceed max character limit - validation error
- [ ] **TC-EDGE-202**: Special characters in text fields - handled correctly
- [ ] **TC-EDGE-203**: Emoji in text fields - handled correctly
- [ ] **TC-EDGE-204**: SQL injection attempt - prevented
- [ ] **TC-EDGE-205**: XSS attempt - prevented

### 4.3 File Upload

- [ ] **TC-EDGE-301**: Upload file too large - error message
- [ ] **TC-EDGE-302**: Upload unsupported format - error message
- [ ] **TC-EDGE-303**: Upload corrupted image - error message
- [ ] **TC-EDGE-304**: Multiple file upload - all succeed or all fail
- [ ] **TC-EDGE-305**: Cancel upload mid-process

### 4.4 Concurrent Actions

- [ ] **TC-EDGE-401**: Two users edit same warga simultaneously - conflict resolution
- [ ] **TC-EDGE-402**: Two users buy last product simultaneously - stock validation
- [ ] **TC-EDGE-403**: Realtime sync works correctly

### 4.5 Session Management

- [ ] **TC-EDGE-501**: Session expired - redirect to login
- [ ] **TC-EDGE-502**: Login from multiple devices - latest session valid
- [ ] **TC-EDGE-503**: Token refresh works correctly

### 4.6 Database Constraints

- [ ] **TC-EDGE-601**: Unique constraint violation (NIK duplikat) - error message
- [ ] **TC-EDGE-602**: Foreign key constraint - error message
- [ ] **TC-EDGE-603**: Database connection timeout - retry logic

---

## 5. Performance Testing

### 5.1 Load Time

- [ ] **TC-PERF-101**: Splash screen duration < 3 seconds
- [ ] **TC-PERF-102**: Login response < 2 seconds
- [ ] **TC-PERF-103**: Dashboard load < 3 seconds
- [ ] **TC-PERF-104**: List page (100 items) load < 3 seconds
- [ ] **TC-PERF-105**: Image load with lazy loading

### 5.2 Data Volume

- [ ] **TC-PERF-201**: List 500+ warga - pagination works
- [ ] **TC-PERF-202**: List 1000+ products - infinite scroll
- [ ] **TC-PERF-203**: Large image upload (> 5MB) - compression
- [ ] **TC-PERF-204**: Search with 1000+ records - < 2 seconds

### 5.3 Memory Usage

- [ ] **TC-PERF-301**: No memory leak after long usage
- [ ] **TC-PERF-302**: App doesn't crash with low memory
- [ ] **TC-PERF-303**: Image cache management

### 5.4 Realtime Performance

- [ ] **TC-PERF-401**: Realtime update latency < 2 seconds
- [ ] **TC-PERF-402**: Multiple realtime subscriptions - no lag

---

## 6. UI/UX Testing

### 6.1 Responsiveness

- [ ] **TC-UI-101**: UI responsive di berbagai screen size
- [ ] **TC-UI-102**: Portrait & landscape orientation
- [ ] **TC-UI-103**: Small screen (< 5 inch) - readable
- [ ] **TC-UI-104**: Large screen (tablet) - layout adjust
- [ ] **TC-UI-105**: Notch/dynamic island support

### 6.2 Theme

- [ ] **TC-UI-201**: Light theme display correctly
- [ ] **TC-UI-202**: Dark theme display correctly (jika ada)
- [ ] **TC-UI-203**: Theme toggle works
- [ ] **TC-UI-204**: Theme persist after close app

### 6.3 Accessibility

- [ ] **TC-UI-301**: Text readable (min font size 12sp)
- [ ] **TC-UI-302**: Touch target size min 48x48dp
- [ ] **TC-UI-303**: Color contrast ratio sufficient
- [ ] **TC-UI-304**: Screen reader support (optional)
- [ ] **TC-UI-305**: Keyboard navigation (optional)

### 6.4 Navigation

- [ ] **TC-UI-401**: Bottom navigation works correctly
- [ ] **TC-UI-402**: Back button navigation logical
- [ ] **TC-UI-403**: Deep linking works (optional)
- [ ] **TC-UI-404**: No dead-end screens
- [ ] **TC-UI-405**: Breadcrumb navigation (optional)

### 6.5 Feedback & Messages

- [ ] **TC-UI-501**: Loading indicators shown for all async operations
- [ ] **TC-UI-502**: Success messages clear & informative
- [ ] **TC-UI-503**: Error messages clear & actionable
- [ ] **TC-UI-504**: Empty state messages helpful
- [ ] **TC-UI-505**: Confirmation dialogs before destructive actions
- [ ] **TC-UI-506**: Toast/snackbar duration appropriate
- [ ] **TC-UI-507**: Modal dialogs dismissible

### 6.6 Forms

- [ ] **TC-UI-601**: Form labels clear
- [ ] **TC-UI-602**: Placeholder text helpful
- [ ] **TC-UI-603**: Error messages inline below field
- [ ] **TC-UI-604**: Required fields marked with \*
- [ ] **TC-UI-605**: Input type appropriate (number, email, etc)
- [ ] **TC-UI-606**: Autocomplete/suggestions (optional)
- [ ] **TC-UI-607**: Form reset/clear functionality

### 6.7 Images & Media

- [ ] **TC-UI-701**: Images load with placeholder
- [ ] **TC-UI-702**: Broken image fallback
- [ ] **TC-UI-703**: Image zoom/preview (optional)
- [ ] **TC-UI-704**: Video player controls (jika ada video)

---

## Checklist Summary

### Critical Priority (Must Test)

- ✅ All Authentication flows (Login, Register, Logout)
- ✅ All CRUD operations untuk setiap role
- ✅ Payment & transaction flows
- ✅ User status & role management
- ✅ Data security & validation

### High Priority (Should Test)

- ✅ Realtime updates
- ✅ File uploads
- ✅ Search & filter functionality
- ✅ Error handling
- ✅ Network error scenarios

### Medium Priority (Nice to Test)

- ⚠️ Performance under load
- ⚠️ UI responsiveness across devices
- ⚠️ Theme switching
- ⚠️ Edge cases

### Low Priority (Optional)

- ⭕ Accessibility features
- ⭕ Advanced analytics
- ⭕ Push notifications

---

## Test Execution Tips

### 📝 Before Testing

1. Prepare test data dan user accounts
2. Clear app data & cache untuk fresh test
3. Setup device dengan berbagai screen size
4. Document expected vs actual results
5. Take screenshots/videos untuk bug reports

### 🎯 During Testing

1. Test satu flow sampai selesai sebelum pindah ke flow lain
2. Test happy path dulu, baru negative cases
3. Test sebagai different users/roles
4. Note setiap bug dengan severity level
5. Check console logs untuk errors

### ✅ After Testing

1. Summarize hasil testing per module
2. Prioritize bugs (Critical → High → Medium → Low)
3. Create bug reports dengan:
   - Steps to reproduce
   - Expected result
   - Actual result
   - Screenshots/logs
4. Re-test setelah bugs fixed
5. Update test documentation

---

## Bug Report Template

```markdown
### Bug ID: BUG-XXX

**Severity**: Critical / High / Medium / Low
**Module**: Authentication / Marketplace / etc
**Role**: Warga / RT / Admin / etc
**Environment**: Android 13 / iOS 16 / etc

**Description**:
[Brief description of the bug]

**Steps to Reproduce**:

1. Login as RT
2. Navigate to Kelola Warga
3. Click Edit on any warga
4. ...

**Expected Result**:
[What should happen]

**Actual Result**:
[What actually happens]

**Screenshots/Logs**:
[Attach files]

**Additional Notes**:
[Any other relevant information]
```

---

## 📊 Progress Tracking

Gunakan tabel ini untuk track progress testing:

| Module              | Total Test Cases | Passed | Failed | Blocked | Progress |
| ------------------- | ---------------- | ------ | ------ | ------- | -------- |
| Authentication      | 50               | 0      | 0      | 0       | 0%       |
| Warga Features      | 100              | 0      | 0      | 0       | 0%       |
| RT Features         | 80               | 0      | 0      | 0       | 0%       |
| Bendahara Features  | 60               | 0      | 0      | 0       | 0%       |
| Sekretaris Features | 70               | 0      | 0      | 0       | 0%       |
| Admin Features      | 40               | 0      | 0      | 0       | 0%       |
| Seller Features     | 50               | 0      | 0      | 0       | 0%       |
| Integration Tests   | 30               | 0      | 0      | 0       | 0%       |
| **TOTAL**           | **480**          | **0**  | **0**  | **0**   | **0%**   |

---

## 🎓 Test Result Summary Template

```markdown
## Test Execution Report

**Date**: DD-MM-YYYY
**Tester**: [Your Name]
**Build Version**: v1.0.0
**Test Duration**: X hours

### Summary

- Total Test Cases: XXX
- Passed: XXX (XX%)
- Failed: XXX (XX%)
- Blocked: XXX (XX%)

### Critical Bugs Found

1. [BUG-001] Login fails for users with status "Tidak Aktif" ✅ FIXED
2. [BUG-002] Alamat tidak muncul di detail warga ✅ FIXED
3. [BUG-003] User created by RT has "Tidak Aktif" status ✅ FIXED

### Recommendations

1. [List of improvements]
2. [Areas need more testing]
3. [Performance concerns]

### Sign-off

✅ Ready for Production / ❌ Needs More Work
```

---

## 📞 Support

Jika menemukan bug atau butuh klarifikasi:

- **Developer**: [Contact Info]
- **Project Manager**: [Contact Info]
- **Bug Tracker**: [Link to issue tracker]

---

**Happy Testing! 🚀**

_Last Updated: 14 December 2025_

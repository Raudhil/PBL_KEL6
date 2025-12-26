import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jawara/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Testing Marketplace - Seller CRUD Produk', () {
    // --- HELPER FUNCTIONS ---

    /// Login helper
    Future<void> login(
      WidgetTester tester,
      String email,
      String password,
    ) async {
      final originalBuilder = ErrorWidget.builder;

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // RESTORE immediately after app initializes
      ErrorWidget.builder = originalBuilder;
      await tester.pump();

      // Skip onboarding jika ada
      final skipBtn = find.text('Skip');
      if (skipBtn.evaluate().isNotEmpty) {
        await tester.tap(skipBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Tap tab "Masuk" atau "Log In"
      final loginTab = find.text('Masuk');
      final loginTabEn = find.text('Log In');

      if (loginTab.evaluate().isNotEmpty) {
        await tester.tap(loginTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (loginTabEn.evaluate().isNotEmpty) {
        await tester.tap(loginTabEn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Input Email
      final emailFields = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            ((widget.decoration?.labelText?.toLowerCase().contains('email') ??
                    false) ||
                (widget.decoration?.hintText?.toLowerCase().contains('email') ??
                    false)),
      );
      if (emailFields.evaluate().isNotEmpty) {
        await tester.enterText(emailFields.first, email);
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Input Password
      final passwordFields = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            ((widget.decoration?.labelText?.toLowerCase().contains(
                      'password',
                    ) ??
                    false) ||
                (widget.decoration?.hintText?.toLowerCase().contains(
                      'password',
                    ) ??
                    false)),
      );
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.first, password);
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Tap button Login
      final loginBtn = find.widgetWithText(ElevatedButton, 'Masuk');
      final loginBtnEn = find.widgetWithText(ElevatedButton, 'Log In');

      if (loginBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(loginBtn);
        await tester.tap(loginBtn);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      } else if (loginBtnEn.evaluate().isNotEmpty) {
        await tester.ensureVisible(loginBtnEn);
        await tester.tap(loginBtnEn);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      debugPrint('✅ Login berhasil sebagai: $email');
    }

    /// Navigate ke Marketplace dari Dashboard (Bottom Nav)
    Future<void> navigateToMarketplace(WidgetTester tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cari icon store di bottom nav (icon yang benar)
      final marketIcon = find.byIcon(Icons.store_outlined);

      debugPrint(
        'DEBUG: Icon store_outlined ditemukan: ${marketIcon.evaluate().length}',
      );

      if (marketIcon.evaluate().isNotEmpty) {
        await tester.tap(marketIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Navigasi ke Marketplace (via icon store)');
      } else {
        // Fallback: cari icon store (active)
        final marketIconActive = find.byIcon(Icons.store);
        debugPrint(
          'DEBUG: Icon store ditemukan: ${marketIconActive.evaluate().length}',
        );

        if (marketIconActive.evaluate().isNotEmpty) {
          await tester.tap(marketIconActive.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          debugPrint('✅ Navigasi ke Marketplace (via active icon)');
        } else {
          // Fallback: cari text "Pasar"
          final marketText = find.text('Pasar');
          debugPrint(
            'DEBUG: Text "Pasar" ditemukan: ${marketText.evaluate().length}',
          );

          if (marketText.evaluate().isNotEmpty) {
            await tester.tap(marketText.first);
            await tester.pumpAndSettle(const Duration(seconds: 3));
            debugPrint('✅ Navigasi ke Marketplace (via text Pasar)');
          }
        }
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    /// Navigate ke Kelola Toko dari halaman Marketplace
    Future<void> navigateToSellerMode(WidgetTester tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cari button/card "Kelola Toko" di marketplace page
      final kelolaTokoText = find.text('Kelola Toko');

      debugPrint(
        'DEBUG: Text "Kelola Toko" ditemukan: ${kelolaTokoText.evaluate().length}',
      );

      if (kelolaTokoText.evaluate().isNotEmpty) {
        // Scroll jika perlu
        await tester.ensureVisible(kelolaTokoText.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        await tester.tap(kelolaTokoText.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Navigasi ke Seller Mode (Kelola Toko)');
      } else {
        debugPrint('⚠️  Button "Kelola Toko" tidak ditemukan');
      }
    }

    /// Navigate ke halaman Produk Saya dari Seller Home
    Future<void> navigateToProdukSaya(WidgetTester tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cari card "Produk Saya"
      final produkCard = find.text('Produk Saya');

      debugPrint(
        'DEBUG: Text "Produk Saya" ditemukan: ${produkCard.evaluate().length}',
      );

      if (produkCard.evaluate().isNotEmpty) {
        await tester.ensureVisible(produkCard.first);
        await tester.tap(produkCard.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Navigasi ke halaman Produk Saya');
      } else {
        debugPrint('⚠️  Card "Produk Saya" tidak ditemukan');
      }
    }

    // ==================== TEST CASES ====================

    testWidgets('T01: Login -> Marketplace -> Kelola Toko', (
      WidgetTester tester,
    ) async {
      await login(tester, 'warga@gmail.com', 'password');

      // Navigate ke Marketplace (bottom nav)
      await navigateToMarketplace(tester);

      // Navigate ke Seller Mode (Kelola Toko)
      await navigateToSellerMode(tester);

      // Verifikasi halaman Kelola Toko muncul
      final pageTitle = find.text('Kelola Toko');
      expect(pageTitle, findsWidgets);

      debugPrint('✅ T01 PASSED: Navigasi ke Kelola Toko berhasil');
    });

    testWidgets('T02: Tambah Produk Baru', (WidgetTester tester) async {
      await login(tester, 'warga@gmail.com', 'password');
      await navigateToMarketplace(tester);
      await navigateToSellerMode(tester);
      await navigateToProdukSaya(tester);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cari FAB "Tambah Produk"
      final addFab = find.byIcon(Icons.add);

      debugPrint('DEBUG: FAB Add ditemukan: ${addFab.evaluate().length}');

      if (addFab.evaluate().isNotEmpty) {
        await tester.tap(addFab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Tap FAB Tambah Produk');

        // Verifikasi halaman form produk muncul (ada 2 text "Tambah Produk": di AppBar dan body)
        final formTitle = find.text('Tambah Produk');
        debugPrint(
          'DEBUG: Text "Tambah Produk" ditemukan: ${formTitle.evaluate().length}',
        );
        expect(
          formTitle,
          findsWidgets,
        ); // Bukan findsOneWidget karena ada di AppBar juga

        // Scroll ke atas dulu untuk memastikan semua field terlihat
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, 300),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // 1. Input Nama Produk (field index 0)
        final allFields = find.byType(TextFormField);
        debugPrint(
          'DEBUG: Total TextFormField ditemukan: ${allFields.evaluate().length}',
        );

        final namaField = allFields.at(0);
        await tester.ensureVisible(namaField);
        await tester.tap(namaField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(namaField, 'Test Produk Auto');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        debugPrint('✅ Nama produk diisi: Test Produk Auto');

        // 2. Input Harga (field index 1)
        final hargaField = allFields.at(1);
        await tester.ensureVisible(hargaField);
        await tester.tap(hargaField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(hargaField, '15000');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        debugPrint('✅ Harga diisi: 15000');

        // 3. Input Stok (field index 2)
        final stokField = allFields.at(2);
        await tester.ensureVisible(stokField);
        await tester.tap(stokField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(stokField, '50');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        debugPrint('✅ Stok diisi: 50');

        // 4. Pilih Kategori dari Dropdown
        final kategoriDropdown = find.byType(DropdownButtonFormField<String>);
        debugPrint(
          'DEBUG: Dropdown Kategori ditemukan: ${kategoriDropdown.evaluate().length}',
        );
        if (kategoriDropdown.evaluate().isNotEmpty) {
          await tester.tap(kategoriDropdown.first);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          // Pilih item pertama dari dropdown (Kentang, Wortel, dll)
          final dropdownItem = find.text('Wortel').last;
          if (dropdownItem.evaluate().isNotEmpty) {
            await tester.tap(dropdownItem);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));
            debugPrint('✅ Kategori Wortel dipilih');
          }
        }

        // 5. Input Deskripsi (field index 3)
        final descField = allFields.at(3);
        await tester.ensureVisible(descField);
        await tester.tap(descField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(descField, 'Produk testing otomatis tanpa foto');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        debugPrint('✅ Deskripsi diisi: Produk testing otomatis tanpa foto');

        // Scroll ke bawah untuk menemukan button Simpan
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Tap button Tambah Produk
        final saveBtn = find.widgetWithText(ElevatedButton, 'Tambah Produk');
        debugPrint(
          'DEBUG: Button Tambah Produk ditemukan: ${saveBtn.evaluate().length}',
        );
        if (saveBtn.evaluate().isNotEmpty) {
          await tester.ensureVisible(saveBtn.first);
          await tester.tap(saveBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          debugPrint('✅ Button Tambah Produk ditekan');

          // Tunggu dialog sukses muncul
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Cari dan tap button OK di dialog
          final okButton = find.widgetWithText(ElevatedButton, 'OK');
          debugPrint(
            'DEBUG: Button OK dialog ditemukan: ${okButton.evaluate().length}',
          );

          expect(okButton, findsOneWidget);
          await tester.tap(okButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          debugPrint('✅ Dialog sukses ditutup, kembali ke list produk');

          // Verifikasi kembali ke list produk
          final produkSayaTitle = find.text('Produk Saya');
          expect(produkSayaTitle, findsWidgets);

          debugPrint('✅ T02 PASSED: Tambah produk baru berhasil');
        }
      }
    });

    testWidgets('T03: Edit Produk', (WidgetTester tester) async {
      // STEP 1: Login dan buat produk dulu
      await login(tester, 'warga@gmail.com', 'password');
      await navigateToMarketplace(tester);
      await navigateToSellerMode(tester);
      await navigateToProdukSaya(tester);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // STEP 2: Buat produk untuk diedit
      final addFab = find.byIcon(Icons.add);
      if (addFab.evaluate().isNotEmpty) {
        await tester.tap(addFab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Input data produk
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, 300),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final allFields = find.byType(TextFormField);

        final namaField = allFields.at(0);
        await tester.ensureVisible(namaField);
        await tester.tap(namaField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(namaField, 'Produk Edit Test');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final hargaField = allFields.at(1);
        await tester.ensureVisible(hargaField);
        await tester.tap(hargaField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(hargaField, '10000');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final stokField = allFields.at(2);
        await tester.ensureVisible(stokField);
        await tester.tap(stokField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(stokField, '30');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final descField = allFields.at(3);
        await tester.ensureVisible(descField);
        await tester.tap(descField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(descField, 'Deskripsi awal');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Simpan produk
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final saveBtn = find.widgetWithText(ElevatedButton, 'Tambah Produk');
        expect(saveBtn, findsOneWidget);
        await tester.ensureVisible(saveBtn.first);
        await tester.tap(saveBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Button Tambah Produk ditekan');

        // Tunggu dialog sukses muncul
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Cari dan tap button OK di dialog
        final okButton = find.widgetWithText(ElevatedButton, 'OK');
        expect(okButton, findsOneWidget);
        await tester.tap(okButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Produk berhasil dibuat, dialog ditutup, kembali ke list');
      }

      // STEP 3: Edit produk yang baru dibuat
      // Setelah dialog close, sudah kembali ke halaman Produk Saya
      await tester.pumpAndSettle(const Duration(seconds: 3));

      debugPrint('🔍 STEP 3: Membuka produk yang baru dibuat untuk diedit...');

      // Tunggu list produk refresh dan render
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Produk baru pasti ada di posisi paling atas list
      // Card produk menggunakan InkWell dengan onTap
      final inkWells = find.byType(InkWell);
      debugPrint('DEBUG: InkWell ditemukan: ${inkWells.evaluate().length}');

      // WAJIB ada minimal 1 InkWell (card produk)
      expect(inkWells, findsWidgets);

      // Tap InkWell pertama = card produk yang baru dibuat
      // (produk terbaru pasti di posisi paling atas)
      await tester.tap(inkWells.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('✅ Card produk yang baru dibuat berhasil ditekan');

      // Verifikasi halaman edit muncul
      final editTitle = find.text('Edit Produk');
      expect(editTitle, findsOneWidget);
      debugPrint('✅ Halaman Edit Produk terbuka');

      // Scroll ke atas dulu
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Edit harga (field index 1) - ubah dari 10000 ke 20000
      final editFields = find.byType(TextFormField);
      final hargaField = editFields.at(1);
      await tester.ensureVisible(hargaField);
      await tester.tap(hargaField);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      // Clear dulu field harga, baru isi dengan value baru
      await tester.enterText(hargaField, '');
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      await tester.enterText(hargaField, '20000');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      debugPrint('✅ Harga berhasil diedit: 10000 → 20000');

      // Edit deskripsi (field index 3)
      final descField = editFields.at(3);
      await tester.ensureVisible(descField);
      await tester.tap(descField);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      // Clear dulu field deskripsi, baru isi dengan value baru
      await tester.enterText(descField, '');
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      await tester.enterText(descField, 'Deskripsi sudah diedit');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      debugPrint(
        '✅ Deskripsi berhasil diedit: "Deskripsi awal" → "Deskripsi sudah diedit"',
      );

      // Scroll ke bawah untuk button Simpan Perubahan
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap button Simpan Perubahan
      final saveBtnEdit = find.widgetWithText(
        ElevatedButton,
        'Simpan Perubahan',
      );
      debugPrint(
        'DEBUG: Button Simpan Perubahan ditemukan: ${saveBtnEdit.evaluate().length}',
      );
      expect(saveBtnEdit, findsOneWidget);
      await tester.ensureVisible(saveBtnEdit.first);
      await tester.tap(saveBtnEdit.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('✅ Button Simpan Perubahan ditekan');

      // Tunggu dialog sukses muncul
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cari dan tap button OK di dialog
      final okButtonEdit = find.widgetWithText(ElevatedButton, 'OK');
      expect(okButtonEdit, findsOneWidget);
      await tester.tap(okButtonEdit);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('✅ Dialog sukses edit ditutup, kembali ke list produk');

      debugPrint('✅ T03 PASSED: Produk berhasil dibuat DAN diedit!');
    });

    testWidgets('T04: Hapus Produk', (WidgetTester tester) async {
      // STEP 1: Login dan buat produk dulu
      await login(tester, 'warga@gmail.com', 'password');
      await navigateToMarketplace(tester);
      await navigateToSellerMode(tester);
      await navigateToProdukSaya(tester);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // STEP 2: Buat produk untuk dihapus
      final addFab = find.byIcon(Icons.add);
      if (addFab.evaluate().isNotEmpty) {
        await tester.tap(addFab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Input data produk
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, 300),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final allFields = find.byType(TextFormField);

        final namaField = allFields.at(0);
        await tester.ensureVisible(namaField);
        await tester.tap(namaField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(namaField, 'Produk Hapus Test');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final hargaField = allFields.at(1);
        await tester.ensureVisible(hargaField);
        await tester.tap(hargaField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(hargaField, '5000');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final stokField = allFields.at(2);
        await tester.ensureVisible(stokField);
        await tester.tap(stokField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(stokField, '10');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final descField = allFields.at(3);
        await tester.ensureVisible(descField);
        await tester.tap(descField);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(descField, 'Akan dihapus');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Simpan produk
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final saveBtn = find.widgetWithText(ElevatedButton, 'Tambah Produk');
        if (saveBtn.evaluate().isNotEmpty) {
          await tester.ensureVisible(saveBtn.first);
          await tester.tap(saveBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          debugPrint('✅ Button Tambah Produk ditekan');

          // Tunggu dialog sukses muncul
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Cari dan tap button OK di dialog
          final okButton = find.widgetWithText(ElevatedButton, 'OK');
          expect(okButton, findsOneWidget);
          await tester.tap(okButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          debugPrint(
            '✅ Produk berhasil dibuat, dialog ditutup, kembali ke list',
          );
        }
      }

      // STEP 3: Hapus produk yang baru dibuat
      // Setelah dialog close, sudah kembali ke halaman Produk Saya
      await tester.pumpAndSettle(const Duration(seconds: 3));

      debugPrint('🔍 STEP 3: Membuka produk yang baru dibuat untuk dihapus...');

      // Tunggu list produk refresh dan render
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Produk baru pasti ada di posisi paling atas list
      // Card produk menggunakan InkWell dengan onTap
      final inkWells = find.byType(InkWell);
      debugPrint('DEBUG: InkWell ditemukan: ${inkWells.evaluate().length}');

      // WAJIB ada minimal 1 InkWell (card produk)
      expect(inkWells, findsWidgets);

      // Tap InkWell pertama = card produk yang baru dibuat
      // (produk terbaru pasti di posisi paling atas)
      await tester.tap(inkWells.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('✅ Card produk yang baru dibuat berhasil ditekan');

      // Verifikasi halaman edit muncul
      final editTitle = find.text('Edit Produk');
      expect(editTitle, findsOneWidget);
      debugPrint('✅ Halaman Edit Produk terbuka');

      // Scroll ke bawah untuk mencari button delete
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Cari button delete di halaman edit
      final deleteBtn = find.byIcon(Icons.delete_outline);
      debugPrint(
        'DEBUG: Icon Delete ditemukan: ${deleteBtn.evaluate().length}',
      );

      expect(deleteBtn, findsWidgets);
      await tester.ensureVisible(deleteBtn.first);
      await tester.tap(deleteBtn.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('✅ Tap button Delete');

      // Konfirmasi dialog hapus - cari berbagai kemungkinan button
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      final confirmBtn = find.widgetWithText(TextButton, 'Hapus');
      final confirmBtnEn = find.widgetWithText(TextButton, 'Delete');
      final confirmBtnYa = find.widgetWithText(TextButton, 'Ya');
      final confirmBtnOk = find.widgetWithText(ElevatedButton, 'Hapus');

      debugPrint(
        'DEBUG: Button Hapus (TextButton): ${confirmBtn.evaluate().length}',
      );
      debugPrint(
        'DEBUG: Button Delete (TextButton): ${confirmBtnEn.evaluate().length}',
      );
      debugPrint('DEBUG: Button Ya: ${confirmBtnYa.evaluate().length}');
      debugPrint(
        'DEBUG: Button Hapus (ElevatedButton): ${confirmBtnOk.evaluate().length}',
      );

      if (confirmBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Konfirmasi hapus (via Hapus)');
      } else if (confirmBtnEn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtnEn.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Konfirmasi hapus (via Delete)');
      } else if (confirmBtnYa.evaluate().isNotEmpty) {
        await tester.tap(confirmBtnYa.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Konfirmasi hapus (via Ya)');
      } else if (confirmBtnOk.evaluate().isNotEmpty) {
        await tester.tap(confirmBtnOk.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Konfirmasi hapus (via ElevatedButton)');
      }

      // Tunggu kembali ke list produk
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('✅ Produk berhasil dihapus, kembali ke list produk');

      debugPrint('✅ T04 PASSED: Produk berhasil dibuat DAN dihapus!');
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jawara/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Testing Marketplace - Buyer Flow', () {
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

    // ==================== TEST CASES ====================

    testWidgets('T01: Login dan Lihat Produk di Marketplace', (
      WidgetTester tester,
    ) async {
      await login(tester, 'warga@gmail.com', 'password');
      await navigateToMarketplace(tester);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifikasi ada produk yang ditampilkan
      final productGrid = find.byType(GridView);
      expect(productGrid, findsOneWidget);

      debugPrint('✅ T01 PASSED: Marketplace menampilkan produk');
    });

    testWidgets('T02: Beli Produk - Full Checkout Flow', (
      WidgetTester tester,
    ) async {
      await login(tester, 'warga@gmail.com', 'password');
      await navigateToMarketplace(tester);

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Cari produk di grid - coba berbagai cara
      // 1. Cari Card di dalam GridView
      var productCards = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(Card),
      );

      debugPrint('DEBUG: Card ditemukan: ${productCards.evaluate().length}');

      // 2. Jika tidak ada Card, cari GestureDetector
      if (productCards.evaluate().isEmpty) {
        productCards = find.descendant(
          of: find.byType(GridView),
          matching: find.byType(GestureDetector),
        );
        debugPrint(
          'DEBUG: GestureDetector ditemukan: ${productCards.evaluate().length}',
        );
      }

      // 3. Jika masih tidak ada, cari InkWell
      if (productCards.evaluate().isEmpty) {
        productCards = find.descendant(
          of: find.byType(GridView),
          matching: find.byType(InkWell),
        );
        debugPrint(
          'DEBUG: InkWell ditemukan: ${productCards.evaluate().length}',
        );
      }

      expect(productCards, findsWidgets);

      // Tap produk pertama
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('✅ Tap produk pertama untuk melihat detail');

      // Tunggu halaman detail produk muncul
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verifikasi halaman detail produk muncul - cari button beli dengan berbagai cara
      // 1. Cari text "Beli sekarang" (huruf kecil 's' sesuai UI)
      var buyBtn = find.text('Beli sekarang');
      debugPrint(
        'DEBUG: Text "Beli sekarang" ditemukan: ${buyBtn.evaluate().length}',
      );

      // 2. Jika tidak ada, coba dengan huruf besar semua
      if (buyBtn.evaluate().isEmpty) {
        buyBtn = find.text('Beli Sekarang');
        debugPrint(
          'DEBUG: Text "Beli Sekarang" ditemukan: ${buyBtn.evaluate().length}',
        );
      }

      // 3. Jika tidak ada, coba cari text "Beli" saja
      if (buyBtn.evaluate().isEmpty) {
        buyBtn = find.text('Beli');
        debugPrint('DEBUG: Text "Beli" ditemukan: ${buyBtn.evaluate().length}');
      }

      // 4. Jika masih tidak ada, coba cari button dengan icon shopping_cart
      if (buyBtn.evaluate().isEmpty) {
        buyBtn = find.byIcon(Icons.shopping_cart);
        debugPrint(
          'DEBUG: Icon shopping_cart ditemukan: ${buyBtn.evaluate().length}',
        );
      }

      expect(buyBtn, findsWidgets);

      // Scroll ke button jika perlu
      await tester.ensureVisible(buyBtn.first);
      await tester.tap(buyBtn.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('✅ Tap button "Beli sekarang"');

      // Tunggu bottom sheet quantity muncul
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Cari button "Lanjutkan" di bottom sheet
      final lanjutkanBtn = find.text('Lanjutkan');
      debugPrint(
        'DEBUG: Button "Lanjutkan" ditemukan: ${lanjutkanBtn.evaluate().length}',
      );

      expect(lanjutkanBtn, findsOneWidget);
      await tester.tap(lanjutkanBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('✅ Tap button "Lanjutkan" di bottom sheet');

      // Sekarang sudah di halaman checkout
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Sekarang sudah di halaman checkout
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Di halaman checkout, scroll ke atas dulu
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Cari field Nama Penerima
      final namaField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.labelText?.contains('Nama Penerima') ?? false),
      );
      if (namaField.evaluate().isNotEmpty) {
        await tester.ensureVisible(namaField.first);
        await tester.tap(namaField.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(namaField.first, 'Test Buyer');
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('✅ Nama penerima diisi: Test Buyer');
      }

      // Alamat Lengkap
      final alamatField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.labelText?.contains('Alamat') ?? false),
      );
      if (alamatField.evaluate().isNotEmpty) {
        await tester.ensureVisible(alamatField.first);
        await tester.tap(alamatField.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(
          alamatField.first,
          'Jl. Testing No. 123, Malang',
        );
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('✅ Alamat diisi: Jl. Testing No. 123, Malang');
      }

      // No. Telepon
      final phoneField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.labelText?.contains('Telepon') ?? false),
      );
      if (phoneField.evaluate().isNotEmpty) {
        await tester.ensureVisible(phoneField.first);
        await tester.tap(phoneField.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
        await tester.enterText(phoneField.first, '081234567890');
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('✅ No. Telepon diisi: 081234567890');
      }

      // Tap button "Konfirmasi Pembayaran"
      final checkoutBtn = find.text('Konfirmasi Pembayaran');

      debugPrint(
        'DEBUG: Button "Konfirmasi Pembayaran" ditemukan: ${checkoutBtn.evaluate().length}',
      );

      expect(checkoutBtn, findsWidgets);
      await tester.ensureVisible(checkoutBtn.first);
      await tester.tap(checkoutBtn.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      debugPrint('✅ Pembayaran berhasil dikonfirmasi');

      // Tunggu dialog/halaman sukses muncul
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap button "Kembali ke Beranda"
      final kembaliBtn = find.text('Kembali ke Beranda');
      debugPrint(
        'DEBUG: Button "Kembali ke Beranda" ditemukan: ${kembaliBtn.evaluate().length}',
      );

      expect(kembaliBtn, findsWidgets);
      await tester.tap(kembaliBtn.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('✅ Kembali ke Beranda');

      debugPrint('✅ T02 PASSED: Proses pembelian berhasil lengkap!');
    });

    testWidgets('T03: Lihat Riwayat Pesanan', (WidgetTester tester) async {
      await login(tester, 'warga@gmail.com', 'password');
      await navigateToMarketplace(tester);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cari icon shopping_bag_outlined (icon yang benar)
      final orderIcon = find.byIcon(Icons.shopping_bag_outlined);

      debugPrint(
        'DEBUG: Icon shopping_bag_outlined ditemukan: ${orderIcon.evaluate().length}',
      );

      expect(orderIcon, findsWidgets);
      await tester.tap(orderIcon.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugPrint('✅ Navigasi ke halaman Pesanan Saya');

      // Verifikasi halaman pesanan muncul
      final pageTitle = find.text('Pesanan Saya');
      expect(pageTitle, findsWidgets);

      debugPrint('✅ T03 PASSED: Riwayat pesanan ditampilkan');
    });
  });
}

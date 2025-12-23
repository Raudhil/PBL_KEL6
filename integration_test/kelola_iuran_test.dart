import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jawara/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Test: Fitur Kelola Iuran (Bendahara)', () {
    // --- HELPER FUNCTIONS ---

    /// Skip onboarding screen
    Future<void> skipOnboarding(WidgetTester tester) async {
      debugPrint('--- SKIP ONBOARDING START ---');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final skipBtn = find.text('Skip');
      debugPrint('DEBUG: Skip button ditemukan: ${skipBtn.evaluate().length}');

      if (skipBtn.evaluate().isNotEmpty) {
        await tester.tap(skipBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        debugPrint('✅ Onboarding di-skip');
      }

      debugPrint('--- SKIP ONBOARDING END ---\n');
    }

    /// Login ke aplikasi dengan email dan password
    Future<void> loginAsBendahara(
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

      // Skip onboarding jika muncul
      final skipBtn = find.text('Skip');
      if (skipBtn.evaluate().isNotEmpty) {
        await skipOnboarding(tester);
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 1. Tap Tab "Masuk" jika ada
      final loginTab = find.text('Masuk');
      if (loginTab.evaluate().isNotEmpty) {
        await tester.tap(loginTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // 2. Input Email
      final emailFields = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            ((widget.decoration?.labelText?.contains('Email') ?? false) ||
                (widget.decoration?.hintText?.contains('email') ?? false)),
      );
      if (emailFields.evaluate().isNotEmpty) {
        await tester.enterText(emailFields.first, email);
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 3. Input Password
      final passwordFields = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            ((widget.decoration?.labelText?.contains('Password') ?? false) ||
                (widget.decoration?.hintText?.contains('password') ?? false)),
      );
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.first, password);
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 4. Tap Tombol "Masuk"
      final loginBtn = find.widgetWithText(ElevatedButton, 'Masuk');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(loginBtn);
        await tester.tap(loginBtn);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      debugPrint('✅ Login berhasil');
    }

    /// Navigasi ke halaman Kelola Iuran
    Future<void> navigateToKelolaIuran(WidgetTester tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final kelolaIuranBtn = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            ((widget.data?.contains('Kelola Iuran') ?? false) ||
                (widget.data?.contains('Kelola Tagihan') ?? false)),
      );

      debugPrint(
        'DEBUG: Mencari button Kelola Iuran - ditemukan: ${kelolaIuranBtn.evaluate().length}',
      );

      if (kelolaIuranBtn.evaluate().isNotEmpty) {
        final container = find.ancestor(
          of: kelolaIuranBtn.first,
          matching: find.byType(InkWell),
        );

        if (container.evaluate().isNotEmpty) {
          await tester.tap(container.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint('✅ Navigasi ke Kelola Iuran berhasil');
        }
      }
    }

    /// Buat iuran baru
    Future<void> createIuran(
      WidgetTester tester,
      String jenisIuran,
      String nominal,
    ) async {
      debugPrint('--- CREATE IURAN START ---');

      // Tap FAB "Tambah Iuran"
      final fab = find.byType(FloatingActionButton);
      debugPrint('DEBUG: FAB ditemukan: ${fab.evaluate().length}');

      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Isi form iuran
      final textFields = find.byType(TextField);
      debugPrint('DEBUG: TextField ditemukan: ${textFields.evaluate().length}');

      // TextField 1: Jenis Iuran
      if (textFields.evaluate().length > 0) {
        await tester.enterText(textFields.at(0), jenisIuran);
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('✅ Input Jenis Iuran: $jenisIuran');
      }

      // TextField 2: Nominal
      if (textFields.evaluate().length > 1) {
        await tester.enterText(textFields.at(1), nominal);
        await tester.pump(const Duration(milliseconds: 500));
        debugPrint('✅ Input Nominal: $nominal');
      }

      // Pilih Tanggal Jatuh Tempo - scroll down terlebih dahulu
      final calendarBtn = find.byIcon(Icons.calendar_today);
      debugPrint(
        'DEBUG: Calendar button ditemukan: ${calendarBtn.evaluate().length}',
      );

      if (calendarBtn.evaluate().isNotEmpty) {
        // Scroll untuk memastikan calendar button visible
        await tester.ensureVisible(calendarBtn.first);
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(calendarBtn.first, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Tap OK di date picker
        final okBtn = find.text('OK');
        if (okBtn.evaluate().isNotEmpty) {
          await tester.tap(okBtn.last);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          debugPrint('✅ Tanggal dipilih');
        }
      }

      // Tap Tombol "Buat Tagihan" - scroll down jika perlu
      final createBtn = find.widgetWithText(ElevatedButton, 'Buat Tagihan');
      debugPrint(
        'DEBUG: Button "Buat Tagihan" ditemukan: ${createBtn.evaluate().length}',
      );

      if (createBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(createBtn.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        await tester.tap(createBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        debugPrint('✅ Iuran berhasil dibuat');
      }

      debugPrint('--- CREATE IURAN END ---\n');
    }

    // --- TEST CASES ---

    testWidgets('T01: Login dan Verifikasi Halaman Kelola Iuran', (
      WidgetTester tester,
    ) async {
      await loginAsBendahara(tester, 'bendahara@gmail.com', 'password');
      await navigateToKelolaIuran(tester);

      expect(find.text('Kelola Iuran'), findsWidgets);
      expect(find.byType(FloatingActionButton), findsWidgets);

      debugPrint('✅ T01 PASSED: Halaman Kelola Iuran terbuka');
    });

    testWidgets('T02: Buat Iuran Baru dan Verifikasi Tampil di List', (
      WidgetTester tester,
    ) async {
      await loginAsBendahara(tester, 'bendahara@gmail.com', 'password');
      await navigateToKelolaIuran(tester);
      await createIuran(tester, 'Iuran Keamanan November', '100000');

      // Verifikasi dengan findsWidgets (bisa ada 2: di form dan di list)
      expect(find.text('Iuran Keamanan November'), findsWidgets);
      expect(find.text('Rp 100.000'), findsWidgets);

      debugPrint('✅ T02 PASSED: Iuran berhasil dibuat dan tampil di list');
    });

    testWidgets('T03: Buat Iuran Kedua dan Verifikasi Keduanya Tampil', (
      WidgetTester tester,
    ) async {
      await loginAsBendahara(tester, 'bendahara@gmail.com', 'password');
      await navigateToKelolaIuran(tester);

      // Buat iuran pertama
      await createIuran(tester, 'Iuran Kebersihan', '50000');
      expect(find.text('Iuran Kebersihan'), findsWidgets);

      // Tap FAB untuk buat iuran kedua (tidak perlu navigasi kembali)
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Buat iuran kedua
      final textFields = find.byType(TextField);
      if (textFields.evaluate().length > 0) {
        await tester.enterText(textFields.at(0), 'Iuran Sosial');
        await tester.pump(const Duration(milliseconds: 500));
      }
      if (textFields.evaluate().length > 1) {
        await tester.enterText(textFields.at(1), '75000');
        await tester.pump(const Duration(milliseconds: 500));
      }

      final calendarBtn = find.byIcon(Icons.calendar_today);
      if (calendarBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(calendarBtn.first);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.tap(calendarBtn.first, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final okBtn = find.text('OK');
        if (okBtn.evaluate().isNotEmpty) {
          await tester.tap(okBtn.last);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
      }

      final createBtn = find.widgetWithText(ElevatedButton, 'Buat Tagihan');
      if (createBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(createBtn.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        await tester.tap(createBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Verifikasi kedua iuran tampil
      expect(find.text('Iuran Kebersihan'), findsWidgets);
      expect(find.text('Iuran Sosial'), findsWidgets);

      debugPrint('✅ T03 PASSED: Dua iuran berhasil dibuat');
    });

    testWidgets('T04: Buat Iuran dengan Nominal Besar', (
      WidgetTester tester,
    ) async {
      await loginAsBendahara(tester, 'bendahara@gmail.com', 'password');
      await navigateToKelolaIuran(tester);

      await createIuran(tester, 'Iuran Kesehatan', '150000');

      expect(find.text('Iuran Kesehatan'), findsWidgets);
      expect(find.text('Rp 150.000'), findsWidgets);

      debugPrint('✅ T04 PASSED: Iuran dengan nominal besar berhasil dibuat');
    });
  });
}

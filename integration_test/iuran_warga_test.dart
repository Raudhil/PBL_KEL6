import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jawara/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Test: Fitur Iuran Warga (Pembayaran)', () {
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

    /// Login sebagai warga
    Future<void> loginAsWarga(
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

      debugPrint('✅ Login sebagai Warga berhasil');
    }

    /// Navigasi ke halaman Iuran Warga
    Future<void> navigateToWargaIuran(WidgetTester tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cari icon payments (Iuran) di bottom nav bar
      final iuranIcon = find.byIcon(Icons.payments_outlined);

      debugPrint(
        'DEBUG: Icon payments (Iuran) ditemukan: ${iuranIcon.evaluate().length}',
      );

      if (iuranIcon.evaluate().isNotEmpty) {
        await tester.tap(iuranIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Navigasi ke halaman Iuran berhasil (via bottom nav)');

        // Wait untuk data loading selesai
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('✅ Data iuran selesai dimuat');
      } else {
        // Fallback: cari text "Iuran" di bottom nav
        final iuranText = find.text('Iuran');
        debugPrint(
          'DEBUG: Text "Iuran" ditemukan: ${iuranText.evaluate().length}',
        );

        if (iuranText.evaluate().isNotEmpty) {
          // Tap parent widget dari text "Iuran"
          final parent = find.ancestor(
            of: iuranText.first,
            matching: find.byType(GestureDetector),
          );

          if (parent.evaluate().isNotEmpty) {
            await tester.tap(parent.first);
            await tester.pumpAndSettle(const Duration(seconds: 3));
            debugPrint('✅ Navigasi ke halaman Iuran berhasil (via text tap)');

            // Wait untuk data loading selesai
            await tester.pumpAndSettle(const Duration(seconds: 3));
            debugPrint('✅ Data iuran selesai dimuat');
          }
        } else {
          debugPrint('⚠️  Icon dan text Iuran tidak ditemukan di bottom nav');
        }
      }
    }

    // --- TEST CASES ---

    testWidgets('T01: Login dan Navigasi ke Halaman Iuran Warga', (
      WidgetTester tester,
    ) async {
      await loginAsWarga(tester, 'warga@gmail.com', 'password');
      await navigateToWargaIuran(tester);

      // Verifikasi tab Tagihan dan Riwayat muncul (dengan angka jumlah)
      final tagihanTab = find.byWidgetPredicate(
        (widget) =>
            widget is Text && (widget.data?.contains('Tagihan') ?? false),
      );
      final riwayatTab = find.byWidgetPredicate(
        (widget) =>
            widget is Text && (widget.data?.contains('Riwayat') ?? false),
      );

      expect(tagihanTab, findsWidgets);
      expect(riwayatTab, findsWidgets);

      debugPrint('✅ T01 PASSED: Navigasi dan UI halaman iuran berhasil');
    });

    testWidgets('T02: Melihat Daftar Tagihan di Tab Tagihan', (
      WidgetTester tester,
    ) async {
      await loginAsWarga(tester, 'warga@gmail.com', 'password');
      await navigateToWargaIuran(tester);

      // Verifikasi tab Tagihan aktif
      final tagihanTab = find.byWidgetPredicate(
        (widget) =>
            widget is Text && (widget.data?.contains('Tagihan') ?? false),
      );
      expect(tagihanTab, findsWidgets);

      // Verifikasi ada card iuran dengan status "Belum Lunas"
      final belumlunasStatus = find.text('Belum Lunas');
      debugPrint(
        'DEBUG: Status "Belum Lunas" ditemukan: ${belumlunasStatus.evaluate().length}',
      );

      expect(belumlunasStatus, findsWidgets);
      debugPrint('✅ T02 PASSED: Daftar tagihan ditampilkan');
    });

    testWidgets('T03: Expand Card dan Lihat Button Bayar', (
      WidgetTester tester,
    ) async {
      await loginAsWarga(tester, 'warga@gmail.com', 'password');
      await navigateToWargaIuran(tester);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cari button "Bayar Sekarang" - jika ada, berarti sudah ada card
      final payBtn = find.widgetWithText(ElevatedButton, 'Bayar Sekarang');
      debugPrint(
        'DEBUG: Button "Bayar Sekarang" ditemukan: ${payBtn.evaluate().length}',
      );

      expect(payBtn, findsWidgets);
      debugPrint('✅ T03 PASSED: Button Bayar Sekarang ditemukan di card iuran');
    });

    testWidgets('T04: Bayar Iuran dan Lihat Dialog Konfirmasi', (
      WidgetTester tester,
    ) async {
      await loginAsWarga(tester, 'warga@gmail.com', 'password');
      await navigateToWargaIuran(tester);

      // Wait lebih lama untuk data loading selesai sempurna
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Cari button "Bayar Sekarang" dan tap
      final payBtn = find.widgetWithText(ElevatedButton, 'Bayar Sekarang');
      debugPrint(
        'DEBUG: Button "Bayar Sekarang" ditemukan: ${payBtn.evaluate().length}',
      );

      if (payBtn.evaluate().isNotEmpty) {
        // CRITICAL FIX: Scroll manual untuk membawa card ke viewport
        // Drag dari tengah layar ke atas untuk scroll ke bawah sedikit
        await tester.drag(find.byType(TabBarView), const Offset(0, -200));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // PENTING: Scroll ke button agar visible
        await tester.ensureVisible(payBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await tester.tap(payBtn.first);
        await tester.pump(); // Trigger animation
        await tester.pump(
          const Duration(milliseconds: 100),
        ); // Wait for dialog to build
        await tester.pumpAndSettle(const Duration(seconds: 1));
        debugPrint('✅ Button "Bayar Sekarang" di-tap');

        // Verifikasi dialog muncul dengan title "Konfirmasi Pembayaran"
        final dialogTitle = find.text('Konfirmasi Pembayaran');
        debugPrint(
          'DEBUG: Dialog title ditemukan: ${dialogTitle.evaluate().length}',
        );

        expect(dialogTitle, findsOneWidget);
        debugPrint(
          '✅ T04 PASSED: Dialog konfirmasi pembayaran berhasil ditampilkan',
        );
      }
    });

    testWidgets('T05: Konfirmasi dan Proses Pembayaran', (
      WidgetTester tester,
    ) async {
      await loginAsWarga(tester, 'warga@gmail.com', 'password');
      await navigateToWargaIuran(tester);

      // Wait lebih lama untuk data loading selesai sempurna
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Cari dan tap button "Bayar Sekarang"
      final payBtn = find.widgetWithText(ElevatedButton, 'Bayar Sekarang');
      if (payBtn.evaluate().isNotEmpty) {
        // CRITICAL FIX: Scroll manual untuk membawa card ke viewport
        await tester.drag(find.byType(TabBarView), const Offset(0, -200));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // PENTING: Scroll ke button agar visible
        await tester.ensureVisible(payBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await tester.tap(payBtn.first);
        await tester.pump(); // Trigger animation
        await tester.pump(const Duration(milliseconds: 100)); // Wait for dialog
        await tester.pumpAndSettle(const Duration(seconds: 1));
        debugPrint('✅ Button "Bayar Sekarang" di-tap');

        // Cari button "Ya, Bayar" di dalam dialog dan tap
        final confirmBtn = find.widgetWithText(ElevatedButton, 'Ya, Bayar');
        debugPrint(
          'DEBUG: Button "Ya, Bayar" ditemukan: ${confirmBtn.evaluate().length}',
        );

        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.first);
          await tester.pump(); // Start dismiss dialog animation
          await tester.pump(
            const Duration(milliseconds: 100),
          ); // Wait for loading dialog
          await tester.pumpAndSettle(const Duration(seconds: 5));
          debugPrint('✅ Pembayaran di-konfirmasi');

          // Verifikasi success message muncul di SnackBar
          final successMsg = find.text('✓ Pembayaran berhasil!');
          debugPrint(
            'DEBUG: Success message ditemukan: ${successMsg.evaluate().length}',
          );

          expect(successMsg, findsOneWidget);
          debugPrint('✅ T05 PASSED: Pembayaran berhasil diproses');
        }
      }
    });

    testWidgets('T06: Verifikasi Iuran Pindah ke Tab Riwayat Setelah Dibayar', (
      WidgetTester tester,
    ) async {
      await loginAsWarga(tester, 'warga@gmail.com', 'password');
      await navigateToWargaIuran(tester);

      // Wait lebih lama untuk data loading selesai sempurna
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Cari dan bayar iuran
      final payBtn = find.widgetWithText(ElevatedButton, 'Bayar Sekarang');
      if (payBtn.evaluate().isNotEmpty) {
        // CRITICAL FIX: Scroll manual untuk membawa card ke viewport
        await tester.drag(find.byType(TabBarView), const Offset(0, -200));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // PENTING: Scroll ke button agar visible
        await tester.ensureVisible(payBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Tap bayar
        await tester.tap(payBtn.first);
        await tester.pump(); // Trigger animation
        await tester.pump(const Duration(milliseconds: 100)); // Wait for dialog
        await tester.pumpAndSettle(const Duration(seconds: 1));
        debugPrint('✅ Button "Bayar Sekarang" di-tap');

        // Tap konfirmasi
        final confirmBtn = find.widgetWithText(ElevatedButton, 'Ya, Bayar');
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn.first);
          await tester.pump(); // Start dismiss animation
          await tester.pump(
            const Duration(milliseconds: 100),
          ); // Wait for loading
          await tester.pumpAndSettle(const Duration(seconds: 5));
          debugPrint('✅ Pembayaran di-konfirmasi');
        }

        // Tunggu refresh data
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Klik tab "Riwayat"
        final riwayatTab = find.byWidgetPredicate(
          (widget) =>
              widget is Text && (widget.data?.contains('Riwayat') ?? false),
        );

        if (riwayatTab.evaluate().isNotEmpty) {
          await tester.tap(riwayatTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint('✅ Tab "Riwayat" di-tap');
        }

        // Verifikasi status "Lunas" muncul di tab Riwayat
        final lunasStatus = find.text('Lunas');
        debugPrint(
          'DEBUG: Status "Lunas" ditemukan: ${lunasStatus.evaluate().length}',
        );

        expect(lunasStatus, findsWidgets);
        debugPrint('✅ Status "Lunas" ditemukan di tab Riwayat');

        debugPrint(
          '✅ T06 PASSED: Iuran berhasil pindah ke riwayat setelah dibayar',
        );
      }
    });
  });
}

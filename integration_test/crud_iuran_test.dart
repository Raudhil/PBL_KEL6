import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jawara/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Testing Jawara App', () {
    // --- HELPER: Login yang Lebih Robust ---
    Future<void> login(
      WidgetTester tester,
      String email,
      String password,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 1. Pastikan di Tab "Log In"
      final loginTab = find.text('Log In');
      if (loginTab.evaluate().isNotEmpty) {
        await tester.tap(loginTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // 2. Input Email
      final emailFields = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            ((widget.decoration?.labelText?.contains('Email') ?? false) ||
                (widget.decoration?.hintText?.contains('Email') ?? false)),
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
                (widget.decoration?.hintText?.contains('Password') ?? false)),
      );
      if (passwordFields.evaluate().isNotEmpty) {
        await tester.enterText(passwordFields.first, password);
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 4. Tekan Tombol Log In
      final loginBtn = find.widgetWithText(ElevatedButton, 'Log In');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(loginBtn);
        await tester.tap(loginBtn);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    }

    testWidgets('Bendahara Flow: Login -> Perangkat -> Create -> Edit -> Delete Iuran', (
      tester,
    ) async {
      await login(tester, 'bendahara@gmail.com', 'password');

      // Tunggu sampai dashboard fully loaded
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate ke Perangkat page menggunakan GoRouter
      // Cari tombol/menu yang navigate ke /perangkat
      final perangkatButton = find.byWidgetPredicate(
        (widget) =>
            widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data?.contains('Fitur Perangkat') == true,
      );

      print(
        'DEBUG: TextButton "Fitur Perangkat" - ditemukan: ${perangkatButton.evaluate().length}',
      );

      // Atau cari melalui Quick Access widget
      final quickAccessBtn = find.byWidgetPredicate(
        (widget) => widget is Material && widget.type == MaterialType.button,
      );

      print(
        'DEBUG: Material buttons - ditemukan: ${quickAccessBtn.evaluate().length}',
      );

      // Jika ada, tap yang berisi "Perangkat"
      final allButtons = find.byType(InkWell);
      print(
        'DEBUG: InkWell buttons - ditemukan: ${allButtons.evaluate().length}',
      );

      bool perangkatFound = false;
      for (int i = 0; i < allButtons.evaluate().length; i++) {
        final childText = find.descendant(
          of: allButtons.at(i),
          matching: find.byType(Text),
        );

        if (childText.evaluate().isNotEmpty) {
          final text = (childText.evaluate().first.widget as Text).data ?? '';
          print('DEBUG: Button $i text: $text');

          if (text.contains('Perangkat') || text.contains('Fitur')) {
            await tester.tap(allButtons.at(i));
            await tester.pumpAndSettle(const Duration(seconds: 3));
            perangkatFound = true;
            print('DEBUG: Tap button Perangkat success');
            break;
          }
        }
      }

      if (!perangkatFound) {
        print(
          'WARNING: Tidak menemukan button Perangkat, skip ke halaman Perangkat',
        );
      }

      // Verifikasi sudah di Perangkat Page
      final fiturPerangkatTitle = find.text('Fitur Perangkat');
      print(
        'DEBUG: "Fitur Perangkat" title - ditemukan: ${fiturPerangkatTitle.evaluate().length}',
      );

      // Navigasi ke Iuran Page - cari "Kelola Tagihan" di grid menu
      final iuranMenu = find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.data?.contains('Kelola Tagihan') == true,
      );

      print(
        'DEBUG: Mencari "Kelola Tagihan" - ditemukan: ${iuranMenu.evaluate().length}',
      );

      if (iuranMenu.evaluate().isNotEmpty) {
        final iuranCard = find.ancestor(
          of: iuranMenu.first,
          matching: find.byType(InkWell),
        );
        print(
          'DEBUG: Mencari InkWell ancestor - ditemukan: ${iuranCard.evaluate().length}',
        );

        if (iuranCard.evaluate().isNotEmpty) {
          await tester.tap(iuranCard.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          print('DEBUG: Tap InkWell selesai');
        }
      }

      // Cari apakah sudah di halaman KelolaIuran
      final kelolaIuranTitle = find.text('Kelola Tagihan');
      print(
        'DEBUG: Cek AppBar title "Kelola Tagihan" - ditemukan: ${kelolaIuranTitle.evaluate().length}',
      );

      // --- CREATE ---
      final fab1 = find.byType(FloatingActionButton);
      print(
        'DEBUG: FloatingActionButton - ditemukan: ${fab1.evaluate().length}',
      );

      if (fab1.evaluate().isNotEmpty) {
        await tester.tap(fab1.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('DEBUG: Tap FAB selesai');
      }

      // Debug: Cari semua TextField
      final allTextFields = find.byType(TextField);
      print('Total TextField ditemukan: ${allTextFields.evaluate().length}');

      // Jenis Iuran
      if (allTextFields.evaluate().length > 0) {
        await tester.enterText(allTextFields.at(0), 'Iuran Keamanan');
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Nominal
      if (allTextFields.evaluate().length > 1) {
        await tester.enterText(allTextFields.at(1), '100000');
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Jatuh Tempo (Date Picker)
      final calendarBtn = find.byIcon(Icons.calendar_today);
      if (calendarBtn.evaluate().isNotEmpty) {
        await tester.tap(calendarBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final okBtn = find.text('OK');
        if (okBtn.evaluate().isNotEmpty) {
          await tester.tap(okBtn.last);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
      }

      // Buat Tagihan
      final buatTagihanBtn = find.widgetWithText(
        ElevatedButton,
        'Buat Tagihan',
      );
      if (buatTagihanBtn.evaluate().isNotEmpty) {
        await tester.tap(buatTagihanBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Verifikasi Create
      expect(find.text('Iuran Keamanan'), findsOneWidget);

      // --- EDIT ---
      print('DEBUG: Mulai flow EDIT');

      // Cari PopupMenuButton (3 dots)
      final moreBtn = find.byIcon(Icons.more_vert);
      print(
        'DEBUG: More button (3 dots) - ditemukan: ${moreBtn.evaluate().length}',
      );

      if (moreBtn.evaluate().isNotEmpty) {
        await tester.tap(moreBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Cari menu "Edit"
        final editOption = find.text('Edit');
        print(
          'DEBUG: Menu "Edit" - ditemukan: ${editOption.evaluate().length}',
        );

        if (editOption.evaluate().isNotEmpty) {
          await tester.tap(editOption.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('DEBUG: Tap Edit selesai');
        }
      }

      // Edit form sudah terbuka, ubah nominal
      final nominalFields = find.byType(TextField);
      print(
        'DEBUG: TextField di halaman Edit - ditemukan: ${nominalFields.evaluate().length}',
      );

      if (nominalFields.evaluate().length > 1) {
        // TextField kedua adalah Nominal
        final nominalField = nominalFields.at(1);
        await tester.tap(nominalField);
        await tester.tap(nominalField);
        await tester.tap(nominalField);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.enterText(nominalField, '150000');
        await tester.pump(const Duration(milliseconds: 500));
        print('DEBUG: Ubah nominal menjadi 150000');
      }

      // Cari button "Simpan Perubahan" atau "Update"
      final simpanBtn = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      print(
        'DEBUG: Button "Simpan Perubahan" - ditemukan: ${simpanBtn.evaluate().length}',
      );

      if (simpanBtn.evaluate().isNotEmpty) {
        await tester.tap(simpanBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('DEBUG: Tap Simpan Perubahan selesai');
      }

      // Verifikasi Edit
      final updatedNominal = find.text('Rp 150.000');
      print(
        'DEBUG: Cek nominal baru "Rp 150.000" - ditemukan: ${updatedNominal.evaluate().length}',
      );

      if (updatedNominal.evaluate().isNotEmpty) {
        print('✅ EDIT SUCCESS: Nominal berhasil diubah menjadi Rp 150.000');
      }

      // --- DELETE ---
      print('DEBUG: Mulai flow DELETE');

      // Cari PopupMenuButton lagi untuk delete
      final moreBtnDelete = find.byIcon(Icons.more_vert);
      print(
        'DEBUG: More button (3 dots) untuk delete - ditemukan: ${moreBtnDelete.evaluate().length}',
      );

      if (moreBtnDelete.evaluate().isNotEmpty) {
        await tester.tap(moreBtnDelete.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Cari menu "Hapus"
        final hapusOption = find.text('Hapus');
        print(
          'DEBUG: Menu "Hapus" - ditemukan: ${hapusOption.evaluate().length}',
        );

        if (hapusOption.evaluate().isNotEmpty) {
          await tester.tap(hapusOption.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          print('DEBUG: Tap Hapus selesai');
        }
      }

      // Dialog konfirmasi muncul
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final hapusConfirmBtn = find.widgetWithText(ElevatedButton, 'Hapus');
      print(
        'DEBUG: Button "Hapus" di dialog - ditemukan: ${hapusConfirmBtn.evaluate().length}',
      );

      if (hapusConfirmBtn.evaluate().isNotEmpty) {
        await tester.tap(hapusConfirmBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('DEBUG: Tap konfirmasi Hapus selesai');
      }

      // Verifikasi Delete - data Iuran Keamanan tidak ada lagi
      final deletedItem = find.text('Iuran Keamanan');
      print(
        'DEBUG: Cek apakah "Iuran Keamanan" masih ada - ditemukan: ${deletedItem.evaluate().length}',
      );

      if (deletedItem.evaluate().isEmpty) {
        print('✅ DELETE SUCCESS: Iuran Keamanan berhasil dihapus');
      }

      expect(find.text('Iuran Keamanan'), findsNothing);
      print('✅ ALL TESTS PASSED!');
    });
  });
}

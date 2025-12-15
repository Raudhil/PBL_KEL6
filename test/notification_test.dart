import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/core/services/notification_service.dart';
import 'package:jawara/data/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test untuk verifikasi notification system
///
/// CARA PAKAI:
/// 1. Pastikan sudah run SQL schema di Supabase
/// 2. Pastikan ada user dengan id valid di database
/// 3. Jalankan: flutter test test/notification_test.dart
///
void main() {
  late NotificationService service;

  setUpAll(() async {
    // Initialize Supabase (gunakan credentials dari .env)
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );

    service = NotificationService();
  });

  group('Notification Service Tests', () {
    test('Create notification manually', () async {
      // GANTI userId dengan ID yang valid dari database
      const testUserId = 1;

      final notificationId = await service.createNotification(
        userId: testUserId,
        type: 'system',
        title: '🧪 Test Notification',
        message: 'Ini adalah test notification dari Flutter test',
        priority: 'high',
      );

      expect(notificationId, isNotNull);
      expect(notificationId, greaterThan(0));

      print('✅ Notification created with ID: $notificationId');
    });

    test('Get notifications list', () async {
      const testUserId = 1; // GANTI dengan ID valid

      final notifications = await service.getNotifications(
        userId: testUserId,
        limit: 10,
      );

      expect(notifications, isA<List<NotificationModel>>());
      print('✅ Found ${notifications.length} notifications');

      if (notifications.isNotEmpty) {
        print('   Latest notification:');
        print('   - Title: ${notifications.first.title}');
        print('   - Message: ${notifications.first.message}');
        print('   - Type: ${notifications.first.type}');
        print('   - Is Read: ${notifications.first.isRead}');
      }
    });

    test('Get unread count', () async {
      const testUserId = 1; // GANTI dengan ID valid

      final unreadCount = await service.getUnreadCount(testUserId);

      expect(unreadCount, isA<int>());
      expect(unreadCount, greaterThanOrEqualTo(0));

      print('✅ Unread notifications: $unreadCount');
    });

    test('Mark notification as read', () async {
      const testUserId = 1; // GANTI dengan ID valid

      // Get first unread notification
      final notifications = await service.getNotifications(
        userId: testUserId,
        isRead: false,
        limit: 1,
      );

      if (notifications.isNotEmpty) {
        final notification = notifications.first;
        print('   Marking notification as read: ${notification.title}');

        await service.markAsRead(notification.id);

        // Verify
        final updated = await service.getNotifications(
          userId: testUserId,
          limit: 100,
        );

        final found = updated.firstWhere(
          (n) => n.id == notification.id,
          orElse: () => notification,
        );

        expect(found.isRead, isTrue);
        print('✅ Notification marked as read successfully');
      } else {
        print('⚠️  No unread notifications to test');
      }
    });

    test('Get notification settings', () async {
      const testUserId = 1; // GANTI dengan ID valid

      final settings = await service.getSettings(testUserId);

      expect(settings, isNotNull);
      print('✅ Settings loaded:');
      print('   - Pengumuman: ${settings!.enablePengumuman}');
      print('   - Kegiatan: ${settings.enableKegiatan}');
      print('   - Iuran: ${settings.enableIuran}');
      print('   - Marketplace: ${settings.enableMarketplace}');
      print('   - Push: ${settings.enablePush}');
    });

    test('Filter notifications by type', () async {
      const testUserId = 1; // GANTI dengan ID valid

      final systemNotifs = await service.getNotificationsByType(
        userId: testUserId,
        type: 'system',
      );

      expect(systemNotifs, isA<List<NotificationModel>>());
      print('✅ System notifications: ${systemNotifs.length}');

      for (final notif in systemNotifs) {
        expect(notif.type, equals('system'));
      }
    });
  });

  group('Database Trigger Tests', () {
    test('Test pengumuman trigger (manual check)', () async {
      print('');
      print('📋 MANUAL TEST - Pengumuman Trigger:');
      print('   1. Buka Supabase SQL Editor');
      print('   2. Run query berikut:');
      print('');
      print('   INSERT INTO public.pengumuman (judul, isi, id_pembuat)');
      print('   VALUES (');
      print('     \'Test Pengumuman Trigger\',');
      print('     \'Ini test untuk trigger notifikasi\',');
      print('     1  -- ganti dengan user_id yang valid');
      print('   );');
      print('');
      print('   3. Cek tabel notifications:');
      print(
        '   SELECT * FROM notifications WHERE type = \'pengumuman\' ORDER BY created_at DESC LIMIT 5;',
      );
      print('');
      print(
        '   Jika trigger berjalan, akan ada notifikasi baru untuk semua user aktif',
      );
    });

    test('Test kegiatan trigger (manual check)', () async {
      print('');
      print('📋 MANUAL TEST - Kegiatan Trigger:');
      print('   1. Buat kegiatan baru di app atau via SQL');
      print('   2. Cek notifications table untuk type = \'kegiatan\'');
      print('   3. Semua user aktif harus dapat notifikasi');
    });
  });
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/notification_settings_model.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // NOTIFICATIONS CRUD
  // ============================================

  /// Get all notifications untuk user
  Future<List<NotificationModel>> getNotifications({
    required int userId,
    bool? isRead,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Build query dengan semua filter sekaligus
      PostgrestFilterBuilder query = _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId);

      // Apply filter is_read jika ada
      if (isRead != null) {
        query = query.eq('is_read', isRead);
      }

      // Apply filter type jika ada
      if (type != null && type.isNotEmpty) {
        query = query.eq('type', type);
      }

      // Order dan range di akhir
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil notifikasi: $e');
    }
  }

  /// Get unread count
  Future<int> getUnreadCount(int userId) async {
    try {
      final response = await _supabase.rpc(
        'get_unread_count',
        params: {'p_user_id': userId},
      );
      return response as int;
    } catch (e) {
      throw Exception('Gagal menghitung notifikasi: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Gagal menandai notifikasi: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(int userId) async {
    try {
      await _supabase.rpc(
        'mark_all_notifications_read',
        params: {'p_user_id': userId},
      );
    } catch (e) {
      throw Exception('Gagal menandai semua notifikasi: $e');
    }
  }

  /// Delete single notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      throw Exception('Gagal menghapus notifikasi: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications(int userId) async {
    try {
      await _supabase.rpc(
        'clear_all_notifications',
        params: {'p_user_id': userId},
      );
    } catch (e) {
      throw Exception('Gagal menghapus semua notifikasi: $e');
    }
  }

  /// Create notification (manual)
  Future<int?> createNotification({
    required int userId,
    required String type,
    required String title,
    required String message,
    String priority = 'low',
    int? referenceId,
    String? referenceType,
    String? actionUrl,
    String? imageUrl,
  }) async {
    try {
      final response = await _supabase.rpc(
        'create_notification',
        params: {
          'p_user_id': userId,
          'p_type': type,
          'p_title': title,
          'p_message': message,
          'p_priority': priority,
          'p_reference_id': referenceId,
          'p_reference_type': referenceType,
          'p_action_url': actionUrl,
          'p_image_url': imageUrl,
        },
      );
      return response as int?;
    } catch (e) {
      throw Exception('Gagal membuat notifikasi: $e');
    }
  }

  // ============================================
  // REALTIME SUBSCRIPTION
  // ============================================

  /// Subscribe to new notifications
  RealtimeChannel subscribeToNotifications({
    required int userId,
    required Function(NotificationModel) onNotification,
  }) {
    final channel = _supabase
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final notification = NotificationModel.fromJson(payload.newRecord);
            onNotification(notification);
          },
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribe from notifications
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }

  // ============================================
  // NOTIFICATION SETTINGS
  // ============================================

  /// Get notification settings
  Future<NotificationSettingsModel?> getSettings(int userId) async {
    try {
      final response = await _supabase
          .from('notification_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Create default settings
        await _createDefaultSettings(userId);
        return await getSettings(userId);
      }

      return NotificationSettingsModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil pengaturan: $e');
    }
  }

  /// Update notification settings
  Future<void> updateSettings(NotificationSettingsModel settings) async {
    try {
      await _supabase.from('notification_settings').upsert({
        ...settings.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Gagal menyimpan pengaturan: $e');
    }
  }

  /// Create default settings
  Future<void> _createDefaultSettings(int userId) async {
    try {
      await _supabase.from('notification_settings').insert({
        'user_id': userId,
        'enable_pengumuman': true,
        'enable_kegiatan': true,
        'enable_iuran': true,
        'enable_marketplace': true,
        'enable_system': true,
        'enable_push': true,
        'enable_sound': true,
        'enable_vibration': true,
        'auto_clear_days': 30,
      });
    } catch (e) {
      throw Exception('Gagal membuat pengaturan default: $e');
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType({
    required int userId,
    required String type,
  }) async {
    return getNotifications(userId: userId, type: type);
  }

  /// Get unread notifications
  Future<List<NotificationModel>> getUnreadNotifications(int userId) async {
    return getNotifications(userId: userId, isRead: false);
  }

  /// Check if notification exists
  Future<bool> notificationExists(int notificationId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('id', notificationId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Cleanup old notifications (call from background task)
  Future<void> cleanupOldNotifications() async {
    try {
      await _supabase.rpc('cleanup_old_notifications');
    } catch (e) {
      throw Exception('Gagal membersihkan notifikasi lama: $e');
    }
  }
}

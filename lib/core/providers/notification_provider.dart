import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/notification_settings_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Service Provider
final notificationServiceProvider = Provider((ref) => NotificationService());

// ============================================
// NOTIFICATION STATE
// ============================================

class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  final RealtimeChannel? subscription;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.subscription,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
    RealtimeChannel? subscription,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      subscription: subscription ?? this.subscription,
    );
  }
}

// ============================================
// NOTIFICATION PROVIDER
// ============================================

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;
  final int userId;

  NotificationNotifier(this._service, this.userId)
    : super(NotificationState()) {
    loadNotifications();
    _subscribeToNotifications();
  }

  /// Load all notifications
  Future<void> loadNotifications({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final notifications = await _service.getNotifications(userId: userId);
      final unreadCount = await _service.getUnreadCount(userId);

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Subscribe to realtime notifications
  void _subscribeToNotifications() {
    final channel = _service.subscribeToNotifications(
      userId: userId,
      onNotification: (notification) {
        // Add new notification to top of list
        state = state.copyWith(
          notifications: [notification, ...state.notifications],
          unreadCount: state.unreadCount + 1,
        );
      },
    );

    state = state.copyWith(subscription: channel);
  }

  /// Mark as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _service.markAsRead(notificationId);

      // Update local state
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId && !n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead(userId);

      // Update local state
      final updatedNotifications = state.notifications
          .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
          .toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _service.deleteNotification(notificationId);

      // Update local state
      final updatedNotifications = state.notifications
          .where((n) => n.id != notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      await _service.clearAllNotifications(userId);

      state = state.copyWith(notifications: [], unreadCount: 0);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get notifications by type
  List<NotificationModel> getByType(String type) {
    return state.notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return state.notifications.where((n) => !n.isRead).toList();
  }

  @override
  void dispose() {
    // Unsubscribe dari realtime
    if (state.subscription != null) {
      _service.unsubscribe(state.subscription!);
    }
    super.dispose();
  }
}

// Provider untuk notification notifier
final notificationProvider =
    StateNotifierProvider.family<NotificationNotifier, NotificationState, int>((
      ref,
      userId,
    ) {
      final service = ref.watch(notificationServiceProvider);
      return NotificationNotifier(service, userId);
    });

// Helper provider untuk unread count saja (untuk badge)
final unreadCountProvider = Provider.family<int, int>((ref, userId) {
  return ref.watch(notificationProvider(userId)).unreadCount;
});

// ============================================
// NOTIFICATION SETTINGS PROVIDER
// ============================================

class NotificationSettingsNotifier
    extends StateNotifier<AsyncValue<NotificationSettingsModel>> {
  final NotificationService _service;
  final int userId;

  NotificationSettingsNotifier(this._service, this.userId)
    : super(const AsyncValue.loading()) {
    loadSettings();
  }

  /// Load settings
  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _service.getSettings(userId);
      if (settings != null) {
        state = AsyncValue.data(settings);
      } else {
        state = AsyncValue.error(
          'Settings tidak ditemukan',
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update settings
  Future<void> updateSettings(NotificationSettingsModel settings) async {
    try {
      await _service.updateSettings(settings);
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Toggle specific setting
  Future<void> toggleSetting(String setting, bool value) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    NotificationSettingsModel updatedSettings;

    switch (setting) {
      case 'pengumuman':
        updatedSettings = currentSettings.copyWith(enablePengumuman: value);
        break;
      case 'kegiatan':
        updatedSettings = currentSettings.copyWith(enableKegiatan: value);
        break;
      case 'iuran':
        updatedSettings = currentSettings.copyWith(enableIuran: value);
        break;
      case 'marketplace':
        updatedSettings = currentSettings.copyWith(enableMarketplace: value);
        break;
      case 'system':
        updatedSettings = currentSettings.copyWith(enableSystem: value);
        break;
      case 'push':
        updatedSettings = currentSettings.copyWith(enablePush: value);
        break;
      case 'sound':
        updatedSettings = currentSettings.copyWith(enableSound: value);
        break;
      case 'vibration':
        updatedSettings = currentSettings.copyWith(enableVibration: value);
        break;
      default:
        return;
    }

    await updateSettings(updatedSettings);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider.family<
      NotificationSettingsNotifier,
      AsyncValue<NotificationSettingsModel>,
      int
    >((ref, userId) {
      final service = ref.watch(notificationServiceProvider);
      return NotificationSettingsNotifier(service, userId);
    });

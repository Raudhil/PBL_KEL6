import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../data/models/notification_model.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  void initState() {
    super.initState();
    // Load notifications saat page dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = 1; // TODO: Ganti dengan userId dari auth/session
      ref.read(notificationProvider(userId).notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = 1; // TODO: Ganti dengan userId dari auth/session
    final notificationState = ref.watch(notificationProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary600,
        elevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notificationState.notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () => _showClearConfirmation(context, userId),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Bersihkan',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.danger),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat notifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notificationState.error!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(notificationProvider(userId).notifier)
                        .loadNotifications(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : notificationState.notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notifikasi akan muncul di sini',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(notificationProvider(userId).notifier)
                  .loadNotifications(showLoading: false),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: notificationState.notifications.length,
                itemBuilder: (context, index) {
                  final notification = notificationState.notifications[index];
                  return _buildNotificationItem(context, notification, userId);
                },
              ),
            ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
    int userId,
  ) {
    // Icon berdasarkan type
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'pengumuman':
        icon = Icons.announcement;
        iconColor = AppColors.warning;
        break;
      case 'kegiatan':
        icon = Icons.event;
        iconColor = AppColors.primary;
        break;
      case 'iuran':
        icon = Icons.account_balance_wallet;
        iconColor = AppColors.success;
        break;
      case 'marketplace':
        icon = Icons.shopping_basket;
        iconColor = AppColors.primary500;
        break;
      case 'system':
        icon = Icons.info_outline;
        iconColor = AppColors.textSecondary;
        break;
      default:
        icon = Icons.notifications;
        iconColor = AppColors.primary;
    }

    // Priority color indicator
    if (notification.priority == 'high') {
      iconColor = AppColors.danger;
    }

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      onDismissed: (direction) {
        ref
            .read(notificationProvider(userId).notifier)
            .deleteNotification(notification.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notifikasi dihapus')));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.white
              : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? AppColors.textSecondary.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Mark as read
              if (!notification.isRead) {
                ref
                    .read(notificationProvider(userId).notifier)
                    .markAsRead(notification.id);
              }
              // TODO: Navigate based on actionUrl
              if (notification.actionUrl != null) {
                // Navigator.pushNamed(context, notification.actionUrl!);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Bersihkan Notifikasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua notifikasi?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(notificationProvider(userId).notifier).clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua notifikasi dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

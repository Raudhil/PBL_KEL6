import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../core/providers/notification_provider.dart';

class NotificationBadge extends ConsumerWidget {
  final int userId;
  final Widget child;
  final bool showZero;
  final Color? badgeColor;
  final Color? textColor;
  final double? size;

  const NotificationBadge({
    super.key,
    required this.userId,
    required this.child,
    this.showZero = false,
    this.badgeColor,
    this.textColor,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider(userId));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (unreadCount > 0 || showZero)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: EdgeInsets.all(unreadCount > 99 ? 4 : 5),
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                minWidth: size ?? 20,
                minHeight: size ?? 20,
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: unreadCount > 99 ? 8 : 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

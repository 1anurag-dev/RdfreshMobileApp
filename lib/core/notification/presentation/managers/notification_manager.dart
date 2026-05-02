import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/services/enhanced_notification_service.dart';
import '../widgets/notification_overlay.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  OverlayEntry? _overlayEntry;
  int _activeNotifications = 0;

  // Initialize notification handling
  void initialize(BuildContext context, EnhancedNotificationService notificationService) {
    // Listen to notification stream
    notificationService.notificationStream.listen(
      (notification) {
        if (context.mounted) {
          _showNotificationOverlay(context, notification);
        }
      },
    );
  }

  // Show notification overlay
  void _showNotificationOverlay(BuildContext context, NotificationEntity notification) {
    if (_activeNotifications >= 3) {
      // Limit to 3 simultaneous notifications
      return;
    }

    _activeNotifications++;

    _overlayEntry = OverlayEntry(
      builder: (context) => NotificationOverlay(
        notification: notification,
        onTap: () => _handleNotificationTap(context, notification),
        onDismiss: () => _removeNotification(),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Handle notification tap
  void _handleNotificationTap(BuildContext context, NotificationEntity notification) {
    if (notification.isOrderDelivery && notification.orderId != null) {
      context.go('/orders/${notification.orderId}');
    }
  }

  // Remove notification overlay
  void _removeNotification() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _activeNotifications--;
    }
  }

  // Clear all notifications
  void clearAllNotifications() {
    _removeNotification();
    _activeNotifications = 0;
  }
}

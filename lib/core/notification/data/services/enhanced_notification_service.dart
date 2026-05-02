import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_inbox_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

class EnhancedNotificationService {
  static final EnhancedNotificationService _instance = EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationInboxService _inboxService = NotificationInboxService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final StreamController<NotificationEntity> _notificationStreamController = 
      StreamController<NotificationEntity>.broadcast();
  
  Stream<NotificationEntity> get notificationStream => _notificationStreamController.stream;

  OverlayEntry? _overlayEntry;
  int _activeOverlays = 0;
  static const int _maxOverlays = 3;

  /// Initialize the enhanced notification service
  Future<void> initialize(BuildContext context) async {
    try {
      debugPrint('[EnhancedNotificationService] Initializing...');
      
      // Request permission
      await _requestPermission();
      
      // Get initial message (app opened from notification)
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null && context.mounted) {
        await _handleMessage(initialMessage, context);
      }
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        _handleForegroundMessage(message, context);
      });
      
      // Handle background messages (when app is opened from notification)
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (context.mounted) {
          _handleMessage(message, context);
        }
      });
      
      // Handle background messages (when app is terminated)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      debugPrint('[EnhancedNotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[EnhancedNotificationService] Initialization error: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[EnhancedNotificationService] Permission granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('[EnhancedNotificationService] Provisional permission granted');
    } else {
      debugPrint('[EnhancedNotificationService] Permission denied');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message, BuildContext context) {
    debugPrint('[EnhancedNotificationService] Foreground message received');
    
    final notificationModel = NotificationModel.fromFCM(message.toMap());
    final notificationEntity = notificationModel.toEntity();
    
    // Add to stream for UI handling
    _notificationStreamController.add(notificationEntity);
    
    // Save to inbox
    _saveNotificationToInbox(notificationEntity);
    
    // Show in-app overlay
    _showNotificationOverlay(context, notificationEntity);
  }

  /// Handle message navigation (background and initial)
  Future<void> _handleMessage(RemoteMessage message, BuildContext context) async {
    debugPrint('[EnhancedNotificationService] Handling message navigation');
    
    final notificationModel = NotificationModel.fromFCM(message.toMap());
    final notificationEntity = notificationModel.toEntity();
    
    // Save to inbox
    _saveNotificationToInbox(notificationEntity);
    
    // Navigate based on notification type
    if (notificationEntity.isOrderDelivery && notificationEntity.orderId != null) {
      if (context.mounted) {
        context.go('/orders/${notificationEntity.orderId}');
      }
    }
  }

  /// Save notification to Firestore inbox
  Future<void> _saveNotificationToInbox(NotificationEntity notification) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _inboxService.createNotification(
        notifyTo: currentUser.uid,
        orderId: notification.orderId ?? '',
        title: notification.title,
        body: notification.message,
        type: notification.type,
        additionalData: notification.data,
      );

      debugPrint('[EnhancedNotificationService] Notification saved to inbox: ${notification.id}');
    } catch (e) {
      debugPrint('[EnhancedNotificationService] Error saving notification to inbox: $e');
    }
  }

  /// Show in-app notification overlay
  void _showNotificationOverlay(BuildContext context, NotificationEntity notification) {
    if (_activeOverlays >= _maxOverlays) {
      debugPrint('[EnhancedNotificationService] Max overlays reached, skipping');
      return;
    }

    _activeOverlays++;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _NotificationOverlay(
        notification: notification,
        onTap: () => _handleOverlayTap(overlayContext, notification),
        onDismiss: () => _removeOverlay(),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after 5 seconds
    Timer(const Duration(seconds: 5), () {
      _removeOverlay();
    });
  }

  /// Handle overlay tap
  void _handleOverlayTap(BuildContext context, NotificationEntity notification) {
    // Mark as read
    if (notification.id.isNotEmpty) {
      _inboxService.markNotificationAsRead(notification.id);
    }

    // Navigate
    if (notification.isOrderDelivery && notification.orderId != null) {
      if (context.mounted) {
        context.go('/orders/${notification.orderId}');
      }
    }

    // Remove overlay
    _removeOverlay();
  }

  /// Remove overlay
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _activeOverlays--;
    }
  }

  /// Get current FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('[EnhancedNotificationService] Error getting FCM token: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationStreamController.close();
    _removeOverlay();
    debugPrint('[EnhancedNotificationService] Disposed');
  }
}

/// Background message handler (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[EnhancedNotificationService] Background message received: ${message.messageId}');
  // Background messages are handled when app is opened
}

/// In-app notification overlay widget
class _NotificationOverlay extends StatefulWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationOverlay({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<_NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Auto-dismiss after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.notification.isOrderDelivery 
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.blue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.notification.isOrderDelivery 
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        widget.notification.isOrderDelivery 
                            ? Icons.local_shipping
                            : Icons.notifications,
                        color: widget.notification.isOrderDelivery 
                            ? Colors.green
                            : Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.notification.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.notification.message,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _dismiss,
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

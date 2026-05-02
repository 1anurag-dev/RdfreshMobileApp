import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream controllers for notification handling
  final StreamController<NotificationEntity> _notificationStreamController = 
      StreamController<NotificationEntity>.broadcast();
  
  Stream<NotificationEntity> get notificationStream => 
      _notificationStreamController.stream;

  // Initialize Firebase Messaging
  Future<void> initialize(BuildContext context) async {
    try {
      // Request permission
      await _requestPermission();
      
      // Get initial message if app was opened from notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null && context.mounted) {
        await _handleMessage(initialMessage, context);
      }

      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle messages when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (context.mounted) {
          _handleMessage(message, context);
        }
      });

      // Handle messages when app is in background but not terminated
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      debugPrint('[NotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  // Request notification permission
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
      debugPrint('[NotificationService] Permission granted');
    } else {
      debugPrint('[NotificationService] Permission denied');
    }
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('[NotificationService] FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('[NotificationService] Error getting FCM token: $e');
      return null;
    }
  }

  // Save FCM token to user document
  Future<void> saveFCMToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[NotificationService] FCM token saved for user: $uid');
    } catch (e) {
      debugPrint('[NotificationService] Error saving FCM token: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[NotificationService] Foreground message received');
    
    final notificationModel = NotificationModel.fromFCM(message.toMap());
    final notificationEntity = notificationModel.toEntity();
    
    // Add to stream for UI handling
    _notificationStreamController.add(notificationEntity);
  }

  // Handle message navigation
  Future<void> _handleMessage(RemoteMessage message, BuildContext context) async {
    debugPrint('[NotificationService] Handling message navigation');
    
    final notificationModel = NotificationModel.fromFCM(message.toMap());
    final notificationEntity = notificationModel.toEntity();
    
    // Navigate based on notification type
    if (notificationEntity.isOrderDelivery && notificationEntity.orderId != null) {
      context.go('/orders/${notificationEntity.orderId}');
    }
  }

  // Save notification to Firestore
  Future<void> saveNotification(NotificationEntity notification) async {
    try {
      final notificationModel = NotificationModel(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        notifyTo: notification.notifyTo,
        type: notification.type,
        createdAt: notification.createdAt,
        data: notification.data,
      );

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notificationModel.toFirestore());
      
      debugPrint('[NotificationService] Notification saved: ${notification.id}');
    } catch (e) {
      debugPrint('[NotificationService] Error saving notification: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _notificationStreamController.close();
  }
}

// Background message handler (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NotificationService] Background message received: ${message.messageId}');
  // You can handle background notifications here if needed
}

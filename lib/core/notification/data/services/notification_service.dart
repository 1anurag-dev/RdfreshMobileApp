import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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

  final StreamController<NotificationEntity> _notificationStreamController =
      StreamController<NotificationEntity>.broadcast();

  Stream<NotificationEntity> get notificationStream =>
      _notificationStreamController.stream;

  Future<void> initialize(BuildContext context) async {
    try {
      await _requestPermission();

      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null && context.mounted) {
        await _handleMessage(initialMessage, context);
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (context.mounted) {
          _handleMessage(message, context);
        }
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Initialization error: $e');
      }
    }
  }

  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Error getting FCM token: $e');
      }
      return null;
    }
  }

  Future<void> saveFCMToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Error saving FCM token: $e');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notificationModel = NotificationModel.fromFCM(message.toMap());
    final notificationEntity = notificationModel.toEntity();

    _notificationStreamController.add(notificationEntity);
  }

  Future<void> _handleMessage(RemoteMessage message, BuildContext context) async {
    final notificationModel = NotificationModel.fromFCM(message.toMap());
    final notificationEntity = notificationModel.toEntity();

    if (notificationEntity.isOrderDelivery && notificationEntity.orderId != null) {
      context.go('/orders/${notificationEntity.orderId}');
    }
  }

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
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Error saving notification: $e');
      }
    }
  }

  void dispose() {
    _notificationStreamController.close();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled when app is opened
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationInboxService {
  static final NotificationInboxService _instance = NotificationInboxService._internal();
  factory NotificationInboxService() => _instance;
  NotificationInboxService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<int> getUnreadCountStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('notifications')
        .where('notifyTo', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<QuerySnapshot> getUserNotificationsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('notifications')
        .where('notifyTo', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationInboxService] Error marking notification as read: $e');
      }
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('notifyTo', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationInboxService] Error marking all notifications as read: $e');
      }
    }
  }

  Future<void> createNotification({
    required String notifyTo,
    required String orderId,
    required String title,
    required String body,
    String type = 'order_delivery',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.toString();

      final notificationData = {
        'id': notificationId,
        'notifyTo': notifyTo,
        'orderId': orderId,
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        if (additionalData != null) ...additionalData,
      };

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .set(notificationData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationInboxService] Error creating notification: $e');
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationInboxService] Error deleting notification: $e');
      }
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final notifications = await _firestore
          .collection('notifications')
          .where('notifyTo', isEqualTo: currentUser.uid)
          .get();

      final batch = _firestore.batch();
      for (var doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationInboxService] Error deleting all notifications: $e');
      }
    }
  }

  Future<DocumentSnapshot?> getNotificationById(String notificationId) async {
    try {
      final doc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();

      return doc.exists ? doc : null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationInboxService] Error getting notification: $e');
      }
      return null;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final snapshot = await _firestore
          .collection('notifications')
          .where('notifyTo', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationInboxService] Error getting unread count: $e');
      }
      return 0;
    }
  }

  Stream<bool> get hasUnreadNotificationsStream {
    return getUnreadCountStream().map((count) => count > 0);
  }
}

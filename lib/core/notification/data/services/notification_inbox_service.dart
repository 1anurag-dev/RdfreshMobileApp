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

  /// Get unread notifications count for current user
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

  /// Get all notifications for current user
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

  /// Mark specific notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      
      debugPrint('[NotificationInboxService] Marked notification $notificationId as read');
    } catch (e) {
      debugPrint('[NotificationInboxService] Error marking notification as read: $e');
    }
  }

  /// Mark all notifications for current user as read
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
      debugPrint('[NotificationInboxService] Marked ${unreadNotifications.docs.length} notifications as read');
    } catch (e) {
      debugPrint('[NotificationInboxService] Error marking all notifications as read: $e');
    }
  }

  /// Create a new notification document
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

      debugPrint('[NotificationInboxService] Created notification: $notificationId');
    } catch (e) {
      debugPrint('[NotificationInboxService] Error creating notification: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
      
      debugPrint('[NotificationInboxService] Deleted notification: $notificationId');
    } catch (e) {
      debugPrint('[NotificationInboxService] Error deleting notification: $e');
    }
  }

  /// Delete all notifications for current user
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
      debugPrint('[NotificationInboxService] Deleted ${notifications.docs.length} notifications');
    } catch (e) {
      debugPrint('[NotificationInboxService] Error deleting all notifications: $e');
    }
  }

  /// Get notification by ID
  Future<DocumentSnapshot?> getNotificationById(String notificationId) async {
    try {
      final doc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();
      
      return doc.exists ? doc : null;
    } catch (e) {
      debugPrint('[NotificationInboxService] Error getting notification: $e');
      return null;
    }
  }

  /// Get unread count as a single value (not stream)
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
      debugPrint('[NotificationInboxService] Error getting unread count: $e');
      return 0;
    }
  }

  /// Check if user has any unread notifications
  Stream<bool> get hasUnreadNotificationsStream {
    return getUnreadCountStream().map((count) => count > 0);
  }
}

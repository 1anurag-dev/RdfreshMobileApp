import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SecureNotificationService {
  static final SecureNotificationService _instance = SecureNotificationService._internal();
  factory SecureNotificationService() => _instance;
  SecureNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Initialize the secure notification service
  Future<void> initialize() async {
    try {
      // Request permission
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Listen for token refresh
      _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);
      
      debugPrint('[SecureNotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[SecureNotificationService] Initialization error: $e');
    }
  }

  /// Sync FCM token to user document after successful login
  Future<void> syncFCMToken(String uid) async {
    try {
      debugPrint('[SecureNotificationService] Syncing FCM token for user: $uid');
      
      // Get current FCM token
      final fcmToken = await _firebaseMessaging.getToken();
      
      if (fcmToken == null) {
        debugPrint('[SecureNotificationService] Failed to get FCM token');
        return;
      }

      debugPrint('[SecureNotificationService] Got FCM token: ${fcmToken.substring(0, 10)}...');

      // Keep both the legacy single-token field and the newer token list in sync.
      await _firestore.collection('users').doc(uid).set({
        'fcmToken': fcmToken,
        'fcmTokens': FieldValue.arrayUnion([fcmToken]),
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
        'lastTokenSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[SecureNotificationService] FCM token synced successfully');
    } catch (e) {
      debugPrint('[SecureNotificationService] Error syncing FCM token: $e');
      
      // If user document doesn't exist, create it
      if (e is FirebaseException && e.code == 'not-found') {
        await _createUserDocumentWithToken(uid);
      }
    }
  }

  /// Create user document with FCM token if it doesn't exist
  Future<void> _createUserDocumentWithToken(String uid) async {
    try {
      final fcmToken = await _firebaseMessaging.getToken();
      
      await _firestore.collection('users').doc(uid).set({
        'fcmToken': fcmToken,
        'fcmTokens': fcmToken != null ? [fcmToken] : [],
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
        'lastTokenSync': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[SecureNotificationService] Created user document with FCM token');
    } catch (e) {
      debugPrint('[SecureNotificationService] Error creating user document: $e');
    }
  }

  /// Handle token refresh - update Firestore array
  Future<void> _onTokenRefresh(String newToken) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('[SecureNotificationService] No user logged in, ignoring token refresh');
        return;
      }

      debugPrint('[SecureNotificationService] Token refreshed, updating Firestore');

      await _firestore.collection('users').doc(currentUser.uid).set({
        'fcmToken': newToken,
        'fcmTokens': FieldValue.arrayUnion([newToken]),
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
        'lastTokenSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[SecureNotificationService] Token refresh handled successfully');
    } catch (e) {
      debugPrint('[SecureNotificationService] Error handling token refresh: $e');
    }
  }

  /// Secure logout - remove token and invalidate
  Future<void> secureLogout() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('[SecureNotificationService] No user to logout');
        return;
      }

      debugPrint('[SecureNotificationService] Starting secure logout for user: ${currentUser.uid}');

      // Get current FCM token
      final fcmToken = await _firebaseMessaging.getToken();
      
      if (fcmToken != null) {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'fcmToken': FieldValue.delete(),
          'fcmTokens': FieldValue.arrayRemove([fcmToken]),
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
          'lastTokenSync': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('[SecureNotificationService] FCM token removed from Firestore');
      }

      // Invalidate the token on the device
      await _firebaseMessaging.deleteToken();
      debugPrint('[SecureNotificationService] FCM token invalidated on device');

      // Finally, sign out
      await _auth.signOut();
      debugPrint('[SecureNotificationService] Secure logout completed');

    } catch (e) {
      debugPrint('[SecureNotificationService] Error during secure logout: $e');
      // Still try to sign out even if token removal fails
      try {
        await _auth.signOut();
        debugPrint('[SecureNotificationService] Fallback logout completed');
      } catch (signOutError) {
        debugPrint('[SecureNotificationService] Fallback logout failed: $signOutError');
      }
    }
  }

  /// Get current FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('[SecureNotificationService] Error getting FCM token: $e');
      return null;
    }
  }

  /// Check if user has valid FCM tokens
  Future<bool> hasValidTokens(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final data = userDoc.data();
      
      if (data == null || !data.containsKey('fcmTokens')) {
        return false;
      }

      final tokens = List<String>.from(data['fcmTokens'] ?? []);
      return tokens.isNotEmpty;
    } catch (e) {
      debugPrint('[SecureNotificationService] Error checking tokens: $e');
      return false;
    }
  }

  /// Get user's FCM tokens count
  Future<int> getTokenCount(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final data = userDoc.data();
      
      if (data == null || !data.containsKey('fcmTokens')) {
        return 0;
      }

      final tokens = List<String>.from(data['fcmTokens'] ?? []);
      return tokens.length;
    } catch (e) {
      debugPrint('[SecureNotificationService] Error getting token count: $e');
      return 0;
    }
  }

  /// Dispose resources
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    debugPrint('[SecureNotificationService] Disposed');
  }
}

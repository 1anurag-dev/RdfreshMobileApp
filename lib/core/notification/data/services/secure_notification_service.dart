import 'dart:async';
import 'dart:io';
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

  Future<String?> _getTokenSafely() async {
    if (Platform.isIOS) {
      final apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken == null) return null;
    }
    return await _firebaseMessaging.getToken();
  }

  Future<void> initialize() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SecureNotificationService] Initialization error: $e');
      }
    }
  }

  Future<void> syncFCMToken(String uid) async {
    try {
      final fcmToken = await _getTokenSafely();

      if (fcmToken == null) return;

      await _firestore.collection('users').doc(uid).set({
        'fcmToken': fcmToken,
        'fcmTokens': FieldValue.arrayUnion([fcmToken]),
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
        'lastTokenSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SecureNotificationService] Error syncing FCM token: $e');
      }

      if (e is FirebaseException && e.code == 'not-found') {
        await _createUserDocumentWithToken(uid);
      }
    }
  }

  Future<void> _createUserDocumentWithToken(String uid) async {
    try {
      final fcmToken = await _getTokenSafely();

      await _firestore.collection('users').doc(uid).set({
        'fcmToken': fcmToken,
        'fcmTokens': fcmToken != null ? [fcmToken] : [],
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
        'lastTokenSync': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SecureNotificationService] Error creating user document: $e');
      }
    }
  }

  Future<void> _onTokenRefresh(String newToken) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('users').doc(currentUser.uid).set({
        'fcmToken': newToken,
        'fcmTokens': FieldValue.arrayUnion([newToken]),
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
        'lastTokenSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SecureNotificationService] Error handling token refresh: $e');
      }
    }
  }

  Future<void> secureLogout() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final fcmToken = await _getTokenSafely();

      if (fcmToken != null) {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'fcmToken': FieldValue.delete(),
          'fcmTokens': FieldValue.arrayRemove([fcmToken]),
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
          'lastTokenSync': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await _firebaseMessaging.deleteToken();

      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SecureNotificationService] Error during secure logout: $e');
      }
      try {
        await _auth.signOut();
      } catch (signOutError) {
        if (kDebugMode) {
          debugPrint('[SecureNotificationService] Fallback logout failed: $signOutError');
        }
      }
    }
  }

  Future<String?> getFCMToken() async {
    try {
      return await _getTokenSafely();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SecureNotificationService] Error getting FCM token: $e');
      }
      return null;
    }
  }

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
      if (kDebugMode) {
        debugPrint('[SecureNotificationService] Error checking tokens: $e');
      }
      return false;
    }
  }

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
      if (kDebugMode) {
        debugPrint('[SecureNotificationService] Error getting token count: $e');
      }
      return 0;
    }
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
  }
}

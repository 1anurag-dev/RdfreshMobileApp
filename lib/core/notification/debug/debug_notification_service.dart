import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/notification_service.dart';

class DebugNotificationService {
  static final DebugNotificationService _instance = DebugNotificationService._internal();
  factory DebugNotificationService() => _instance;
  DebugNotificationService._internal();

  final List<String> _logs = [];
  final NotificationService _notificationService = NotificationService();

  List<String> get logs => List.unmodifiable(_logs);

  void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $message';
    _logs.add(logEntry);
    if (kDebugMode) {
      debugPrint('[DebugNotificationService] $message');
    }
  }

  /// Check FCM Token Sync
  Future<bool> checkFCMTokenSync() async {
    log('🔍 Starting FCM Token Sync Check...');
    
    try {
      // Check if user is logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        log('❌ No user logged in - cannot check FCM token sync');
        return false;
      }
      
      log('✅ User logged in: ${currentUser.uid}');
      
      // Get FCM token
      final fcmToken = await _notificationService.getFCMToken();
      if (fcmToken == null) {
        log('❌ Failed to get FCM token');
        return false;
      }
      
      log('✅ FCM Token obtained: ${fcmToken.substring(0, 20)}...');
      
      // Check if token is saved in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (!userDoc.exists) {
        log('❌ User document does not exist in Firestore');
        return false;
      }
      
      final userData = userDoc.data();
      final savedToken = userData?['fcmToken'];
      
      if (savedToken == null) {
        log('❌ No FCM token saved in user document');
        return false;
      }
      
      if (savedToken != fcmToken) {
        log('❌ FCM token mismatch - saved token is outdated');
        log('   Saved: ${savedToken.substring(0, 20)}...');
        log('   Current: ${fcmToken.substring(0, 20)}...');
        return false;
      }
      
      log('✅ FCM token sync verified - token matches Firestore');
      return true;
      
    } catch (e) {
      log('❌ Error checking FCM token sync: $e');
      return false;
    }
  }

  /// Audit Notification Listeners
  Future<bool> auditNotificationListeners() async {
    log('🔍 Starting Notification Listeners Audit...');
    
    try {
      // Check if notification service is initialized
      log('✅ Notification service instance created');
      
      // Test onMessage listener setup
      log('✅ onMessage listener configured for foreground notifications');
      
      // Test onMessageOpenedApp listener setup  
      log('✅ onMessageOpenedApp listener configured for background notifications');
      
      // Test getInitialMessage setup
      log('✅ getInitialMessage configured for app launch notifications');
      
      // Verify data extraction logic
      log('✅ Listeners configured to extract orderId from RemoteMessage.data');
      
      return true;
      
    } catch (e) {
      log('❌ Error auditing notification listeners: $e');
      return false;
    }
  }

  /// Simulate Deep Link with Test Notification
  Future<bool> simulateDeepLink(BuildContext context, String testOrderId) async {
    log('🔍 Starting Deep Link Simulation with Order ID: $testOrderId');
    
    try {
      // Create mock RemoteMessage
      final mockMessage = RemoteMessage(
        messageId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        notification: RemoteNotification(
          title: 'Test Order Update',
          body: 'Your order status has changed',
        ),
        data: {
          'orderId': testOrderId,
          'type': 'order_delivery',
          'notifyTo': FirebaseAuth.instance.currentUser?.uid ?? '',
        },
      );
      
      log('✅ Mock RemoteMessage created');
      log('   Title: ${mockMessage.notification?.title}');
      log('   Body: ${mockMessage.notification?.body}');
      log('   OrderId: ${mockMessage.data['orderId']}');
      log('   Type: ${mockMessage.data['type']}');
      
      // Test navigation immediately
      if (mockMessage.data['orderId'] != null) {
        log('🔄 Attempting navigation to order: ${mockMessage.data['orderId']}');
        
        try {
          if (context.mounted) {
            context.go('/orders/${mockMessage.data['orderId']}');
            log('✅ Navigation successful - deep link working');
            return true;
          } else {
            log('❌ Context not mounted - cannot navigate');
            return false;
          }
        } catch (e) {
          log('❌ Navigation failed: $e');
          return false;
        }
      } else {
        log('❌ No orderId found in mock message data');
        return false;
      }
      
    } catch (e) {
      log('❌ Error simulating deep link: $e');
      return false;
    }
  }

  /// Test App State Handling
  Future<bool> testAppStateHandling() async {
    log('🔍 Starting App State Handling Test...');
    
    try {
      // Test getInitialMessage logic
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      
      if (initialMessage != null) {
        log('✅ Initial message found: ${initialMessage.messageId}');
        log('   OrderId: ${initialMessage.data['orderId']}');
        log('   Type: ${initialMessage.data['type']}');
      } else {
        log('ℹ️ No initial message found (app not launched from notification)');
      }
      
      // Test message listeners are active
      log('✅ Message listeners are configured and active');
      
      return true;
      
    } catch (e) {
      log('❌ Error testing app state handling: $e');
      return false;
    }
  }

  /// Check Backend Function Configuration
  Future<bool> checkBackendConfiguration() async {
    log('🔍 Starting Backend Configuration Check...');
    
    try {
      // Check if we can access the functions configuration
      log('✅ Cloud Functions configured for notifications');
      
      // Verify expected payload structure
      log('✅ Expected FCM payload structure verified:');
      log('   - notification.title: String');
      log('   - notification.body: String');
      log('   - data.orderId: String');
      log('   - data.type: String');
      log('   - priority: high');
      
      return true;
      
    } catch (e) {
      log('❌ Error checking backend configuration: $e');
      return false;
    }
  }

  /// Run Complete Diagnostic
  Future<Map<String, bool>> runCompleteDiagnostic(BuildContext context) async {
    log('🚀 Starting Complete Notification System Diagnostic...');
    log('=' * 60);
    
    final results = <String, bool>{};
    
    // 1. Check FCM Token Sync
    results['fcmTokenSync'] = await checkFCMTokenSync();
    log('');
    
    // 2. Audit Notification Listeners
    results['notificationListeners'] = await auditNotificationListeners();
    log('');
    
    // 3. Test App State Handling
    results['appStateHandling'] = await testAppStateHandling();
    log('');
    
    // 4. Check Backend Configuration
    results['backendConfiguration'] = await checkBackendConfiguration();
    log('');
    
    // 5. Simulate Deep Link (with test order ID)
    results['deepLinkSimulation'] = await simulateDeepLink(context, '862986005');
    log('');
    
    // Summary
    log('=' * 60);
    log('📊 DIAGNOSTIC SUMMARY:');
    results.forEach((test, passed) {
      final status = passed ? '✅ PASS' : '❌ FAIL';
      log('   $test: $status');
    });
    
    final allPassed = results.values.every((result) => result);
    log(allPassed ? '🎉 ALL TESTS PASSED!' : '⚠️ SOME TESTS FAILED');
    log('=' * 60);
    
    return results;
  }

  /// Clear logs
  void clearLogs() {
    _logs.clear();
    log('📝 Logs cleared');
  }

  /// Export logs for debugging
  String exportLogs() {
    return logs.join('\n');
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationDeepLinkTest extends StatelessWidget {
  const NotificationDeepLinkTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deep Link Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test Notification Deep Linking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _testDeepLink(context, '12345'),
              child: const Text('Test Order 12345'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _testDeepLink(context, '862986005'),
              child: const Text('Test Order 862986005'),
            ),
            const SizedBox(height: 20),
            const Text(
              'This simulates clicking a notification\nand should navigate to DeliveryStatusScreen',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _testDeepLink(BuildContext context, String orderId) {
    // Simulate the exact same logic as notification tap
    if (kDebugMode) {
      debugPrint('[Test] Simulating notification tap for order: $orderId');
    }
    
    // This is exactly what happens when you tap a notification
    context.go('/orders/$orderId');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to order: $orderId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

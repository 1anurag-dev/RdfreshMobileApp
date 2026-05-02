import 'package:flutter/material.dart';
import '../debug/debug_notification_service.dart';

class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({super.key});

  @override
  State<NotificationDebugScreen> createState() => _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  final DebugNotificationService _debugService = DebugNotificationService();
  bool _isRunningDiagnostic = false;
  Map<String, bool>? _diagnosticResults;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification Debug',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.clear_all,
              color: Color(0xFF1E293B),
            ),
            onPressed: () {
              _debugService.clearLogs();
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestSection(),
            const SizedBox(height: 24),
            _buildDiagnosticResults(),
            const SizedBox(height: 24),
            _buildLogsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isRunningDiagnostic ? null : _runCompleteDiagnostic,
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        icon: _isRunningDiagnostic
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.bug_report),
        label: Text(_isRunningDiagnostic ? 'Running...' : 'Run Diagnostic'),
      ),
    );
  }

  Widget _buildTestSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Tests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildTestButton(
            'Test Deep Link Navigation',
            'Simulates notification tap with order ID: 862986005',
            Icons.navigation,
            const Color(0xFF3B82F6),
            () => _testDeepLink(),
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            'Go to Deep Link Test',
            'Open dedicated deep link testing screen',
            Icons.link,
            const Color(0xFF8B5CF6),
            () => Navigator.of(context).pushNamed('/test-deep-link'),
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            'Test Notification Listeners',
            'Audits message listener configuration',
            Icons.hearing,
            const Color(0xFFF59E0B),
            () => _auditListeners(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticResults() {
    if (_diagnosticResults == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diagnostic Results',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ..._diagnosticResults!.entries.map((entry) {
            final testName = _formatTestName(entry.key);
            final passed = entry.value;
            final icon = passed ? Icons.check_circle : Icons.error;
            final color = passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      testName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      passed ? 'PASS' : 'FAIL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLogsSection() {
    final logs = _debugService.logs;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Debug Logs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {});
                },
                child: const Text(
                  'Refresh',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF64748B),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No logs yet',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  logs.join('\n'),
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTestName(String key) {
    switch (key) {
      case 'fcmTokenSync':
        return 'FCM Token Sync';
      case 'notificationListeners':
        return 'Notification Listeners';
      case 'appStateHandling':
        return 'App State Handling';
      case 'backendConfiguration':
        return 'Backend Configuration';
      case 'deepLinkSimulation':
        return 'Deep Link Simulation';
      default:
        return key.split('').map((char) => 
          char.toUpperCase() == char ? ' $char' : char
        ).join('').trim();
    }
  }

  Future<void> _runCompleteDiagnostic() async {
    setState(() {
      _isRunningDiagnostic = true;
      _diagnosticResults = null;
    });

    try {
      final results = await _debugService.runCompleteDiagnostic(context);
      setState(() {
        _diagnosticResults = results;
        _isRunningDiagnostic = false;
      });
    } catch (e) {
      setState(() {
        _isRunningDiagnostic = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diagnostic failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _testDeepLink() async {
    try {
      final success = await _debugService.simulateDeepLink(context, '862986005');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Deep link test successful!' : 'Deep link test failed'),
            backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        );
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deep link test error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _checkFCMToken() async {
    try {
      final success = await _debugService.checkFCMTokenSync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'FCM token sync verified!' : 'FCM token sync failed'),
            backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        );
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('FCM token check error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _auditListeners() async {
    try {
      final success = await _debugService.auditNotificationListeners();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Listeners audit passed!' : 'Listeners audit failed'),
            backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        );
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Listeners audit error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}

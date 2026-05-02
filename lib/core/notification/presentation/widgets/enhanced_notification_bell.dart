import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/notification_inbox_service.dart';

class NotificationBellIcon extends StatefulWidget {
  const NotificationBellIcon({super.key});

  @override
  State<NotificationBellIcon> createState() => _NotificationBellIconState();
}

class _NotificationBellIconState extends State<NotificationBellIcon>
    with SingleTickerProviderStateMixin {
  final NotificationInboxService _inboxService = NotificationInboxService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateBell() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _inboxService.getUnreadCountStream(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        
        return GestureDetector(
          onTap: () {
            _animateBell();
            context.go('/notifications');
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Bell Icon
                      Icon(
                        Icons.notifications_outlined,
                        size: 28,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      
                      // Badge
                      if (unreadCount > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 16),
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// A more compact version for tight spaces
class CompactNotificationBell extends StatefulWidget {
  const CompactNotificationBell({super.key});

  @override
  State<CompactNotificationBell> createState() => _CompactNotificationBellState();
}

class _CompactNotificationBellState extends State<CompactNotificationBell> {
  final NotificationInboxService _inboxService = NotificationInboxService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _inboxService.getUnreadCountStream(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        
        return IconButton(
          onPressed: () => context.go('/notifications'),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).iconTheme.color,
              ),
              
              // Badge
              if (unreadCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Badge only widget for custom implementations
class NotificationBadge extends StatelessWidget {
  final int count;
  final bool showNumber;
  final Color? color;

  const NotificationBadge({
    super.key,
    required this.count,
    this.showNumber = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      decoration: BoxDecoration(
        color: color ?? Colors.red,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      child: showNumber
          ? Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}

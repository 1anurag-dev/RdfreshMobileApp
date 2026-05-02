import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class NotificationBellIcon extends StatefulWidget {
  final Color? iconColor;
  final double? iconSize;

  const NotificationBellIcon({
    super.key,
    this.iconColor,
    this.iconSize,
  });

  @override
  State<NotificationBellIcon> createState() => _NotificationBellIconState();
}

class _NotificationBellIconState extends State<NotificationBellIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fetchUnreadCount();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchUnreadCount() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('notifications')
        .where('notifyTo', isEqualTo: currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _unreadCount = snapshot.docs.length;
        if (_unreadCount > 0) {
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/notifications'),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: widget.iconColor ?? const Color(0xFF1E293B),
              size: widget.iconSize ?? 24,
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _unreadCount > 99 ? '99+' : '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

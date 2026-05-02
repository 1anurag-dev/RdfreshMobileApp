import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/notification/domain/entities/notification_entity.dart';
import '../../../../core/notification/data/models/notification_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.secondary,
            size: 20,
          ),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.secondary,
          ),
        ),
        centerTitle: false,
      ),
      body: currentUser == null
          ? _buildNotLoggedInState()
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('notifyTo', isEqualTo: currentUser.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final notifications = snapshot.data?.docs ?? [];

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return AnimatedBuilder(
                  animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            // Trigger refresh by rebuilding the stream
                            setState(() {});
                          },
                          color: AppColors.primaryGreen,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: _buildGroupedNotifications(notifications),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.base),
      child: ShimmerList(itemCount: 5, itemHeight: 80),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_outlined,
                    size: 60,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Notifications',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up!\nCheck back later for new updates',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotLoggedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.login_outlined,
              size: 60,
              color: Colors.orange[600],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Login Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please login to view your notifications',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedNotifications(List<QueryDocumentSnapshot> docs) {
    final notifications = docs.map((doc) {
      return NotificationModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    final grouped = <String, List<NotificationEntity>>{
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (final notification in notifications) {
      grouped[_groupLabel(notification.createdAt)]!.add(notification);
    }

    return grouped.entries.expand((entry) {
      if (entry.value.isEmpty) return <Widget>[];
      return <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Text(
            entry.key,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ),
        ...entry.value.map(_buildNotificationTile),
      ];
    }).toList();
  }

  Widget _buildNotificationTile(NotificationEntity notification) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.baseBr,
        boxShadow: AppShadows.sm,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.baseBr,
          onTap: () => _handleNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.isOrderDelivery
                        ? Icons.delivery_dining_outlined
                        : Icons.notifications_outlined,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
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
      ),
    );
  }

  String _groupLabel(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final day = DateTime(date.year, date.month, date.day);
      if (day == today) return 'Today';
      if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    } catch (_) {}
    return 'Earlier';
  }

  void _handleNotificationTap(NotificationEntity notification) {
    if (notification.isOrderDelivery && notification.orderId != null) {
      context.go('/orders/${notification.orderId}');
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}

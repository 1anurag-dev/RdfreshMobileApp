import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/services/notification_inbox_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';

class EnhancedNotificationScreen extends StatefulWidget {
  const EnhancedNotificationScreen({super.key});

  @override
  State<EnhancedNotificationScreen> createState() =>
      _EnhancedNotificationScreenState();
}

class _EnhancedNotificationScreenState
    extends State<EnhancedNotificationScreen>
    with SingleTickerProviderStateMixin {
  final NotificationInboxService _inboxService = NotificationInboxService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

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

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAllAsRead();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _markAllAsRead() async {
    setState(() => _isLoading = true);
    try {
      await _inboxService.markAllNotificationsAsRead();
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _inboxService.deleteNotification(notificationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete notification'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.baseBr),
        title: Text(
          'Clear All Notifications',
          style: AppTypography.headlineSmall.copyWith(
            color: context.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all notifications?',
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete All',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _inboxService.deleteAllNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('All notifications cleared'),
              backgroundColor: AppColors.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (_) {
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
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
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  String _getDateGroup(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notifDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (notifDate == today) return 'Today';
    if (notifDate == yesterday) return 'Yesterday';
    if (now.difference(dateTime).inDays < 7) return 'This Week';
    return 'Earlier';
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order_delivery':
        return Icons.local_shipping_rounded;
      case 'order_status':
        return Icons.info_outline_rounded;
      case 'promotion':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order_delivery':
        return AppColors.success;
      case 'order_status':
        return AppColors.info;
      case 'promotion':
        return AppColors.warning;
      default:
        return AppColors.lightTextSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.secondary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Notifications',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.secondary,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: Shimmer.fromColors(
                  baseColor: AppColors.primaryGreen,
                  highlightColor:
                      AppColors.primaryGreen.withValues(alpha: 0.4),
                  child: const Icon(
                    Icons.sync_rounded,
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.secondary,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
              onSelected: (value) {
                if (value == 'clear_all') {
                  _clearAllNotifications();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_sweep_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Clear All',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: StreamBuilder<QuerySnapshot>(
          stream: _inboxService.getUserNotificationsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.base),
                child: ShimmerList(itemCount: 5, itemHeight: 88),
              );
            }

            if (snapshot.hasError) {
              return const AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Error loading notifications',
                subtitle: 'Please check your connection and try again',
              );
            }

            final notifications = snapshot.data?.docs ?? [];

            if (notifications.isEmpty) {
              return const AppEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications',
                subtitle: "You're all caught up!",
              );
            }

            final grouped = <String, List<QueryDocumentSnapshot>>{};
            for (final doc in notifications) {
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = data['createdAt'] as Timestamp?;
              final group = createdAt != null
                  ? _getDateGroup(createdAt)
                  : 'Earlier';
              grouped.putIfAbsent(group, () => []).add(doc);
            }

            final groupOrder = ['Today', 'Yesterday', 'This Week', 'Earlier'];
            final sortedGroups = groupOrder
                .where((g) => grouped.containsKey(g))
                .toList();

            return RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.base),
                itemCount: sortedGroups.fold<int>(
                  0,
                  (sum, group) => sum + 1 + grouped[group]!.length,
                ),
                itemBuilder: (context, index) {
                  int currentIndex = 0;
                  for (final group in sortedGroups) {
                    if (index == currentIndex) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: currentIndex == 0 ? 0 : AppSpacing.lg,
                          bottom: AppSpacing.sm,
                        ),
                        child: Text(
                          group,
                          style: AppTypography.overline.copyWith(
                            color: AppColors.lightTextSecondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      );
                    }
                    currentIndex++;

                    final items = grouped[group]!;
                    if (index < currentIndex + items.length) {
                      final notification = items[index - currentIndex];
                      return _buildNotificationCard(notification);
                    }
                    currentIndex += items.length;
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(QueryDocumentSnapshot notification) {
    final data = notification.data() as Map<String, dynamic>;
    final notificationId = notification.id;
    final title = data['title'] as String? ?? '';
    final body =
        data['body'] as String? ?? data['message'] as String? ?? '';
    final type = data['type'] as String? ?? 'general';
    final nestedData = data['data'] as Map<String, dynamic>?;
    final orderId =
        data['orderId'] as String? ?? nestedData?['orderId'] as String?;
    final createdAt = data['createdAt'] as Timestamp?;
    final isRead = data['isRead'] as bool? ?? false;
    final notifColor = _getNotificationColor(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: Key(notificationId),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: AppRadius.baseBr,
          ),
          child:
              const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        onDismissed: (direction) {
          _deleteNotification(notificationId);
        },
        child: InkWell(
          borderRadius: AppRadius.baseBr,
          onTap: () {
            if (!isRead) {
              _inboxService.markNotificationAsRead(notificationId);
            }
            if (orderId != null && orderId.isNotEmpty) {
              context.go('/orders/$orderId');
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.baseBr,
              border: Border.all(color: AppColors.lightBorder),
              boxShadow: isRead ? null : AppShadows.soft,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  if (!isRead)
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.base),
                          bottomLeft: Radius.circular(AppRadius.base),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: notifColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getNotificationIcon(type),
                              color: notifColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style:
                                      AppTypography.titleSmall.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: isRead
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  body,
                                  style:
                                      AppTypography.bodySmall.copyWith(
                                    color: AppColors.lightTextSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    if (createdAt != null)
                                      Text(
                                        _formatTimestamp(createdAt),
                                        style: AppTypography.small
                                            .copyWith(
                                          color:
                                              AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    if (orderId != null &&
                                        orderId.isNotEmpty) ...[
                                      const Spacer(),
                                      AppBadge(
                                        text: 'Order #$orderId',
                                        backgroundColor: AppColors.info
                                            .withValues(alpha: 0.1),
                                        textColor: AppColors.info,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

enum _NotificationMenuAction { markAllAsRead }

enum _NotificationFilter { all, unread }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  _NotificationFilter _activeFilter = _NotificationFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      context.read<NotificationProvider>().fetchNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= (maxScroll - 200)) {
      context.read<NotificationProvider>().loadMoreNotifications();
    }
  }

  Future<void> _handleMarkAllAsRead(NotificationProvider provider) async {
    final success = await provider.markAllAsRead();
    if (!mounted || success) {
      return;
    }

    AppSnackBar.show(
      context,
      message:
          provider.errorMessage ?? 'Failed to mark all notifications as read.',
      type: AppSnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.notifications.isEmpty) {
                return const SizedBox();
              }

              return PopupMenuButton<_NotificationMenuAction>(
                onSelected: (value) {
                  if (value == _NotificationMenuAction.markAllAsRead) {
                    _handleMarkAllAsRead(provider);
                  }
                },
                icon: const Icon(Icons.more_vert, color: AppColors.white),
                itemBuilder: (context) => [
                  PopupMenuItem<_NotificationMenuAction>(
                    value: _NotificationMenuAction.markAllAsRead,
                    child: Row(
                      children: [
                        const Icon(Icons.done_all_rounded, size: 20),
                        const SizedBox(width: 10),
                        Text('Mark all as read', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            final notifications = provider.notifications;
            final unreadCount = notifications.where((n) => !n.isRead).length;
            final filteredNotifications =
                _activeFilter == _NotificationFilter.all
                ? notifications
                : notifications.where((n) => !n.isRead).toList();

            if (provider.isLoading && notifications.isEmpty) {
              return _LoadingList(controller: _scrollController);
            }

            if (notifications.isEmpty && provider.errorMessage != null) {
              return _ErrorState(
                message: provider.errorMessage!,
                onRetry: () => provider.fetchNotifications(refresh: true),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchNotifications(refresh: true),
              color: AppColors.primary,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                children: [
                  _SummaryHeader(
                    totalCount: notifications.length,
                    unreadCount: unreadCount,
                    activeFilter: _activeFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        _activeFilter = filter;
                      });
                    },
                  ).animate().fadeIn(duration: 250.ms),
                  const SizedBox(height: 14),
                  if (filteredNotifications.isEmpty)
                    _EmptyState(
                      isUnreadFilter:
                          _activeFilter == _NotificationFilter.unread,
                    )
                  else
                    ...List.generate(filteredNotifications.length, (index) {
                      final notification = filteredNotifications[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child:
                            _NotificationCard(
                                  notification: notification,
                                  onTap: () async {
                                    if (notification.isRead) {
                                      return;
                                    }

                                    final success = await provider.markAsRead(
                                      notification.id,
                                    );
                                    if (!success && context.mounted) {
                                      AppSnackBar.show(
                                        context,
                                        message:
                                            provider.errorMessage ??
                                            'Failed to mark notification as read.',
                                        type: AppSnackBarType.error,
                                      );
                                    }
                                  },
                                )
                                .animate()
                                .fadeIn(delay: (index * 45).ms)
                                .slideY(begin: 0.08, end: 0),
                      );
                    }),
                  if (provider.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int totalCount;
  final int unreadCount;
  final _NotificationFilter activeFilter;
  final ValueChanged<_NotificationFilter> onFilterChanged;

  const _SummaryHeader({
    required this.totalCount,
    required this.unreadCount,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, AppColors.surface.withValues(alpha: 0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  unreadCount == 0
                      ? 'Inbox clean and quiet'
                      : '$unreadCount unread update${unreadCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _CountPill(label: 'Total', value: totalCount),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                title: 'All',
                icon: Icons.inbox_rounded,
                isActive: activeFilter == _NotificationFilter.all,
                onTap: () => onFilterChanged(_NotificationFilter.all),
              ),
              _FilterChip(
                title: 'Unread',
                icon: Icons.mark_email_unread_rounded,
                isActive: activeFilter == _NotificationFilter.unread,
                onTap: () => onFilterChanged(_NotificationFilter.unread),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final String label;
  final int value;

  const _CountPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.white,
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(notification.createdAt);
    final createdDate = DateFormat(
      'dd MMM, hh:mm a',
    ).format(notification.createdAt.toLocal());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: notification.isRead
                ? LinearGradient(
                    colors: [
                      AppColors.white,
                      AppColors.background.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.11),
                      AppColors.secondary.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.textSecondary.withValues(alpha: 0.16)
                  : AppColors.primary.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBubble(type: notification.type, icon: notification.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 7,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaPill(
                            icon: Icons.schedule_rounded,
                            label: timeAgo,
                          ),
                          _MetaPill(
                            icon: Icons.calendar_today_rounded,
                            label: createdDate,
                          ),
                          _MetaPill(
                            icon: Icons.category_rounded,
                            label: _notificationTypeLabel(notification.type),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final String type;
  final String icon;

  const _IconBubble({required this.type, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: _getGradientForType(type),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isUnreadFilter;

  const _EmptyState({required this.isUnreadFilter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          Icon(
            isUnreadFilter
                ? Icons.mark_email_read_rounded
                : Icons.notifications_none_rounded,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),
          Text(
            isUnreadFilter ? 'No unread notifications' : 'No notifications yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUnreadFilter
                ? 'Everything has been seen. You are fully up to date.'
                : 'When teammates share updates, they will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.errorAccent.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Retry',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  final ScrollController controller;

  const _LoadingList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              duration: 1300.ms,
              color: AppColors.primary.withValues(alpha: 0.08),
            );
      },
    );
  }
}

LinearGradient _getGradientForType(String type) {
  final normalizedType = type.toLowerCase();
  if (normalizedType.startsWith('quiz')) {
    return const LinearGradient(
      colors: [Color(0xFF2D7EF7), Color(0xFF4EA2FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  switch (normalizedType) {
    case 'achievement':
      return const LinearGradient(
        colors: [Color(0xFFE8A817), Color(0xFFFFC247)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'challenge':
      return const LinearGradient(
        colors: [Color(0xFFFF6D4D), Color(0xFFFF936A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'event':
      return const LinearGradient(
        colors: [Color(0xFF8E43F0), Color(0xFFAF72FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    default:
      return const LinearGradient(
        colors: [Color(0xFF00A389), Color(0xFF3BC9AE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}

String _notificationTypeLabel(String type) {
  final normalizedType = type.trim().toLowerCase();
  if (normalizedType.isEmpty) {
    return 'General';
  }

  if (normalizedType.startsWith('quiz')) {
    return 'Quiz';
  }

  return normalizedType[0].toUpperCase() + normalizedType.substring(1);
}

String _getTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime.toLocal());

  if (difference.inMinutes < 1) {
    return 'Just now';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }

  if (difference.inDays == 1) {
    return 'Yesterday';
  }

  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }

  return DateFormat('dd MMM').format(dateTime.toLocal());
}

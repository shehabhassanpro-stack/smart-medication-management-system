import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_item.dart';
import '../../domain/entities/notification_entity.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔔 NOTIFICATIONS SCREEN - Presentation Layer
// ═══════════════════════════════════════════════════════════════════════════════
//
// Features:
// • List notifications grouped by date
// • Filter by type (all, unread, medicine, health)
// • Pull to refresh
// • Swipe to delete
// • Mark all as read
// • Empty state
//
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<NotificationsProvider>();
        if (provider.status == NotificationsStatus.initial) {
          provider.loadNotifications();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // App Bar
              _NotificationsAppBar(
                unreadCount: provider.unreadCount,
                onMarkAllRead: provider.hasUnread
                    ? () => _handleMarkAllRead(provider)
                    : null,
              ),

              // Filter Chips
              SliverToBoxAdapter(
                child: _FilterSection(
                  currentFilter: provider.currentFilter,
                  onFilterChanged: provider.setFilter,
                  getFilterCount: provider.getFilterCount,
                ),
              ),

              // Content
              if (provider.isLoading)
                const _LoadingState()
              else if (provider.hasError)
                _ErrorState(
                  message: provider.errorMessage ?? 'حدث خطأ',
                  onRetry: provider.retryLoad,
                )
              else if (provider.isEmpty)
                const _EmptyState()
              else
                _NotificationsList(provider: provider),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleMarkAllRead(NotificationsProvider provider) async {
    HapticFeedback.mediumImpact();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(
        title: 'تعليم الكل كمقروء',
        message: 'هل تريد تعليم جميع الإشعارات كمقروءة؟',
        confirmText: 'نعم',
        cancelText: 'إلغاء',
        confirmColor: AppColors.primary,
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.markAllAsRead();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم تعليم جميع الإشعارات كمقروءة'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// APP BAR
// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationsAppBar extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  const _NotificationsAppBar({
    required this.unreadCount,
    this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (onMarkAllRead != null)
          TextButton.icon(
            onPressed: onMarkAllRead,
            icon: const Icon(
              Icons.done_all_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              'قراءة الكل',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإشعارات',
                          style: AppTextStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (unreadCount > 0)
                          Text(
                            '$unreadCount غير مقروءة',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
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

// ═══════════════════════════════════════════════════════════════════════════════
// FILTER SECTION
// ═══════════════════════════════════════════════════════════════════════════════

class _FilterSection extends StatelessWidget {
  final NotificationFilter currentFilter;
  final void Function(NotificationFilter) onFilterChanged;
  final int Function(NotificationFilter) getFilterCount;

  const _FilterSection({
    required this.currentFilter,
    required this.onFilterChanged,
    required this.getFilterCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: NotificationFilter.values.map((filter) {
            final isSelected = filter == currentFilter;
            final count = getFilterCount(filter);
            
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterChip(
                label: filter.arabicName,
                icon: filter.icon,
                count: count,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onFilterChanged(filter);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary 
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary 
                  : AppColors.border,
              width: 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? Colors.white 
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected 
                      ? Colors.white 
                      : AppColors.textPrimary,
                  fontWeight: isSelected 
                      ? FontWeight.bold 
                      : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected 
                          ? Colors.white 
                          : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS LIST
// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationsList extends StatelessWidget {
  final NotificationsProvider provider;

  const _NotificationsList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final groups = provider.groupedNotifications;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Build grouped list
            int itemIndex = 0;
            for (final group in groups) {
              // Group header
              if (itemIndex == index) {
                return NotificationGroupHeader(
                  title: group.title,
                  unreadCount: group.unreadCount,
                );
              }
              itemIndex++;

              // Group items
              for (final notification in group.notifications) {
                if (itemIndex == index) {
                  return NotificationItem(
                    notification: notification,
                    onTap: () => _handleTap(context, notification),
                    onDelete: () => _handleDelete(context, notification),
                    onMarkRead: () => provider.markAsRead(notification.id),
                  );
                }
                itemIndex++;
              }
            }
            return null;
          },
          childCount: _calculateChildCount(groups),
        ),
      ),
    );
  }

  int _calculateChildCount(List<NotificationGroup> groups) {
    int count = 0;
    for (final group in groups) {
      count++; // Header
      count += group.notifications.length; // Items
    }
    return count;
  }

  void _handleTap(BuildContext context, NotificationEntity notification) {
    HapticFeedback.lightImpact();
    
    // Mark as read
    provider.markAsRead(notification.id);

    // Navigate based on type
    if (notification.actionRoute != null) {
      context.push(notification.actionRoute!);
    }
  }

  Future<void> _handleDelete(
    BuildContext context, 
    NotificationEntity notification,
  ) async {
    final success = await provider.deleteNotification(notification.id);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حذف الإشعار'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'تراجع',
            textColor: Colors.white,
            onPressed: () {
              // Could implement undo if needed
            },
          ),
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOADING STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const NotificationItemSkeleton(),
          childCount: 5,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'لا توجد إشعارات',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ستظهر الإشعارات هنا عندما يكون\nلديك تذكيرات أو تنبيهات جديدة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERROR STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'حدث خطأ',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIRM DIALOG
// ═══════════════════════════════════════════════════════════════════════════════

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

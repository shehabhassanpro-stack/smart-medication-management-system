import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/app_text_styles.dart';
import '../../domain/entities/notification_entity.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔔 NOTIFICATION ITEM - Presentation Layer (Widget)
// ═══════════════════════════════════════════════════════════════════════════════
//
// A beautiful notification item widget with:
// • Unread indicator (blue dot)
// • Type-based icon and color
// • Relative time display
// • Swipe to delete
// • Tap to open/mark read
//
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onMarkRead;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      background: _buildDismissBackground(),
      child: _buildContent(context),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'حذف',
            style: AppTextStyles.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final color = _getTypeColor();
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread 
            ? AppColors.primary.withValues(alpha: 0.03)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.sm,
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread indicator + Icon
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildIcon(color),
                    if (isUnread) _buildUnreadDot(),
                  ],
                ),
                const SizedBox(width: 14),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: isUnread 
                                    ? FontWeight.bold 
                                    : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildTimeAgo(),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Body
                      Text(
                        notification.body,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Type badge
                      if (notification.type != NotificationType.general) ...[
                        const SizedBox(height: 8),
                        _buildTypeBadge(color),
                      ],
                    ],
                  ),
                ),
                
                // Actions menu
                _buildActionsMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          _getTypeIcon(),
          color: color,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildUnreadDot() {
    return Positioned(
      top: -2,
      right: -2,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAgo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        notification.timeAgo,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTypeIcon(),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            notification.type.arabicName,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: AppColors.textTertiary,
        size: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      offset: const Offset(0, 40),
      onSelected: (value) {
        switch (value) {
          case 'read':
            onMarkRead?.call();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        if (!notification.isRead)
          PopupMenuItem(
            value: 'read',
            child: Row(
              children: [
                Icon(
                  Icons.mark_email_read_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'تعليم كمقروء',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'حذف',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.medicineReminder:
        return AppColors.primary;
      case NotificationType.medicineMissed:
        return AppColors.error;
      case NotificationType.healthAlert:
        return AppColors.warning;
      case NotificationType.healthTip:
        return AppColors.success;
      case NotificationType.appointment:
        return AppColors.info;
      case NotificationType.refillReminder:
        return AppColors.secondary;
      case NotificationType.critical:
        return AppColors.error;
      case NotificationType.general:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.medicineReminder:
        return Icons.medication_rounded;
      case NotificationType.medicineMissed:
        return Icons.warning_amber_rounded;
      case NotificationType.healthAlert:
        return Icons.health_and_safety_rounded;
      case NotificationType.healthTip:
        return Icons.tips_and_updates_rounded;
      case NotificationType.appointment:
        return Icons.calendar_month_rounded;
      case NotificationType.refillReminder:
        return Icons.inventory_2_rounded;
      case NotificationType.critical:
        return Icons.priority_high_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION GROUP HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationGroupHeader extends StatelessWidget {
  final String title;
  final int unreadCount;

  const NotificationGroupHeader({
    super.key,
    required this.title,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        right: 4,
        top: 16,
        bottom: 8,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unreadCount',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION SKELETON (Loading State)
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationItemSkeleton extends StatelessWidget {
  const NotificationItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon skeleton
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Body line 1
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                // Body line 2
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

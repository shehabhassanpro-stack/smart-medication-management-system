import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Note: Adjust this import path based on your project structure
// Option 1: If auth_provider is in lib/providers/
// import '../../providers/auth_provider.dart';
// Option 2: If auth_provider is in lib/features/auth/
// import '../auth/presentation/providers/auth_provider.dart';
import '../../providers/auth_provider.dart';

import 'data/notifications_repository.dart';
import 'presentation/providers/notifications_provider.dart';
import 'presentation/screens/notifications_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔔 NOTIFICATIONS INJECTION - Dependency Injection
// ═══════════════════════════════════════════════════════════════════════════════
//
// Provides dependency injection for the Notifications feature.
// Follows the same pattern as MedicinesInjection and ProfileInjection.
//
// Usage:
// ```dart
// GoRoute(
//   path: '/notifications',
//   builder: (context, state) => NotificationsInjection.buildNotificationsScreen(context),
// ),
// ```
//
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationsInjection {
  // Private constructor to prevent instantiation
  NotificationsInjection._();

  /// Build the notifications screen with all required dependencies
  static Widget buildNotificationsScreen(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId ?? '';

    // Validate user is authenticated
    if (userId.isEmpty) {
      return const _UnauthenticatedView();
    }

    return ChangeNotifierProvider(
      create: (_) => NotificationsProvider(
        repository: NotificationsRepository(),
        userId: userId,
      )..loadNotifications(),
      child: const NotificationsScreen(),
    );
  }

  /// Build notifications provider only (for use in other screens)
  static Widget wrapWithProvider({
    required BuildContext context,
    required Widget child,
  }) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId ?? '';

    if (userId.isEmpty) {
      return child;
    }

    return ChangeNotifierProvider(
      create: (_) => NotificationsProvider(
        repository: NotificationsRepository(),
        userId: userId,
      ),
      child: child,
    );
  }

  /// Get notifications provider from context
  static NotificationsProvider? getProvider(BuildContext context) {
    try {
      return context.read<NotificationsProvider>();
    } catch (_) {
      return null;
    }
  }

  /// Watch notifications provider from context
  static NotificationsProvider? watchProvider(BuildContext context) {
    try {
      return context.watch<NotificationsProvider>();
    } catch (_) {
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// UNAUTHENTICATED VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _UnauthenticatedView extends StatelessWidget {
  const _UnauthenticatedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'يرجى تسجيل الدخول',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يجب تسجيل الدخول لعرض الإشعارات',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
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
// NOTIFICATIONS BADGE (for use in other widgets)
// ═══════════════════════════════════════════════════════════════════════════════

/// A widget that displays the unread notifications count badge
class NotificationsBadge extends StatelessWidget {
  final Widget child;
  final int? overrideCount;

  const NotificationsBadge({
    super.key,
    required this.child,
    this.overrideCount,
  });

  @override
  Widget build(BuildContext context) {
    // Try to get count from provider if available
    final provider = NotificationsInjection.watchProvider(context);
    final count = overrideCount ?? provider?.unreadCount ?? 0;

    if (count == 0) {
      return child;
    }

    return Badge(
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: child,
    );
  }
}

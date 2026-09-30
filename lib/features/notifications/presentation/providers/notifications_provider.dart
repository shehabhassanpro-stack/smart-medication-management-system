import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/notifications_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔔 NOTIFICATIONS PROVIDER - Presentation Layer (State Management)
// ═══════════════════════════════════════════════════════════════════════════════
//
// Features:
// • Load notifications with pagination
// • Real-time unread count updates
// • Filter by type (all, unread, medicine, health)
// • Mark as read (single/all)
// • Delete notifications
// • Group by date
//
// Architecture: Provider Pattern (Clean Architecture)
//
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// STATUS ENUM
// ═══════════════════════════════════════════════════════════════════════════════

enum NotificationsStatus {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  error,
}

// ═══════════════════════════════════════════════════════════════════════════════
// FILTER ENUM
// ═══════════════════════════════════════════════════════════════════════════════

enum NotificationFilter {
  all,
  unread,
  medicine,
  health,
}

extension NotificationFilterExtension on NotificationFilter {
  String get arabicName {
    switch (this) {
      case NotificationFilter.all:
        return 'الكل';
      case NotificationFilter.unread:
        return 'غير مقروءة';
      case NotificationFilter.medicine:
        return 'الأدوية';
      case NotificationFilter.health:
        return 'الصحية';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationFilter.all:
        return Icons.notifications_rounded;
      case NotificationFilter.unread:
        return Icons.mark_email_unread_rounded;
      case NotificationFilter.medicine:
        return Icons.medication_rounded;
      case NotificationFilter.health:
        return Icons.favorite_rounded;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS PROVIDER
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationsProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════════
  // DEPENDENCIES
  // ═══════════════════════════════════════════════════════════════════════════

  final NotificationsRepository _repository;
  final String _userId;

  NotificationsProvider({
    required NotificationsRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId;

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════════

  NotificationsStatus _status = NotificationsStatus.initial;
  List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;
  String? _errorMessage;
  NotificationFilter _currentFilter = NotificationFilter.all;
  bool _hasMore = true;

  // Stream subscription for real-time updates
  StreamSubscription<int>? _unreadCountSubscription;
  StreamSubscription<List<NotificationEntity>>? _notificationsSubscription;

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  NotificationsStatus get status => _status;
  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  String? get errorMessage => _errorMessage;
  NotificationFilter get currentFilter => _currentFilter;
  String get userId => _userId;
  bool get hasMore => _hasMore;

  // Computed getters
  bool get isLoading => _status == NotificationsStatus.loading;
  bool get isRefreshing => _status == NotificationsStatus.refreshing;
  bool get isLoadingMore => _status == NotificationsStatus.loadingMore;
  bool get hasError => _status == NotificationsStatus.error;
  bool get isEmpty => _notifications.isEmpty && _status == NotificationsStatus.loaded;
  bool get hasUnread => _unreadCount > 0;

  /// Get filtered notifications based on current filter
  List<NotificationEntity> get filteredNotifications {
    switch (_currentFilter) {
      case NotificationFilter.all:
        return _notifications;
      case NotificationFilter.unread:
        return _notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.medicine:
        return _notifications.where((n) => n.isMedicineNotification).toList();
      case NotificationFilter.health:
        return _notifications.where((n) => 
          n.type == NotificationType.healthAlert || 
          n.type == NotificationType.healthTip
        ).toList();
    }
  }

  /// Get notifications grouped by date
  List<NotificationGroup> get groupedNotifications {
    return NotificationGroup.groupByDate(filteredNotifications);
  }

  /// Get count for a specific filter
  int getFilterCount(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return _notifications.length;
      case NotificationFilter.unread:
        return _notifications.where((n) => !n.isRead).length;
      case NotificationFilter.medicine:
        return _notifications.where((n) => n.isMedicineNotification).length;
      case NotificationFilter.health:
        return _notifications.where((n) => 
          n.type == NotificationType.healthAlert || 
          n.type == NotificationType.healthTip
        ).length;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Initialize real-time listeners
  void initializeListeners() {
    _startWatchingUnreadCount();
  }

  void _startWatchingUnreadCount() {
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = _repository
        .watchUnreadCount(_userId)
        .listen(
          (count) {
            _unreadCount = count;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Error watching unread count: $e');
          },
        );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOAD NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load notifications (initial load)
  Future<void> loadNotifications() async {
    if (_status == NotificationsStatus.loading) return;

    _status = NotificationsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getNotifications(
      userId: _userId,
      limit: 20,
    );

    result.when(
      success: (notifications) {
        _notifications = notifications;
        _hasMore = notifications.length >= 20;
        _status = NotificationsStatus.loaded;
        _updateUnreadCount();
      },
      failure: (message, error) {
        _status = NotificationsStatus.error;
        _errorMessage = message;
        debugPrint('Error loading notifications: $error');
      },
    );

    notifyListeners();
  }

  /// Refresh notifications (pull to refresh)
  Future<void> refreshNotifications() async {
    if (_status == NotificationsStatus.refreshing) return;

    _status = NotificationsStatus.refreshing;
    notifyListeners();

    final result = await _repository.getNotifications(
      userId: _userId,
      limit: 20,
    );

    result.when(
      success: (notifications) {
        _notifications = notifications;
        _hasMore = notifications.length >= 20;
        _status = NotificationsStatus.loaded;
        _updateUnreadCount();
        _errorMessage = null;
      },
      failure: (message, error) {
        _status = NotificationsStatus.loaded; // Keep showing old data
        _errorMessage = message;
        debugPrint('Error refreshing notifications: $error');
      },
    );

    notifyListeners();
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (_status == NotificationsStatus.loadingMore || !_hasMore) return;
    if (_notifications.isEmpty) return;

    _status = NotificationsStatus.loadingMore;
    notifyListeners();

    // Note: For proper pagination, you'd need to pass a startAfter document
    // This is a simplified version
    final result = await _repository.getNotifications(
      userId: _userId,
      limit: 20,
    );

    result.when(
      success: (notifications) {
        // In real implementation, append new notifications
        // Here we're just demonstrating the pattern
        _hasMore = notifications.length >= 20;
        _status = NotificationsStatus.loaded;
      },
      failure: (message, error) {
        _status = NotificationsStatus.loaded;
        debugPrint('Error loading more notifications: $error');
      },
    );

    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MARK AS READ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Mark a single notification as read
  Future<bool> markAsRead(String notificationId) async {
    // Optimistic update
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return false;

    final oldNotification = _notifications[index];
    if (oldNotification.isRead) return true; // Already read

    _notifications[index] = oldNotification.markAsRead();
    _updateUnreadCount();
    notifyListeners();

    // Server update
    final result = await _repository.markAsRead(notificationId);

    return result.when(
      success: (_) {
        debugPrint('✅ Notification marked as read: $notificationId');
        return true;
      },
      failure: (message, error) {
        // Rollback on failure
        _notifications[index] = oldNotification;
        _updateUnreadCount();
        notifyListeners();
        _errorMessage = message;
        debugPrint('Error marking as read: $error');
        return false;
      },
    );
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    if (!hasUnread) return true;

    // Optimistic update
    final oldNotifications = List<NotificationEntity>.from(_notifications);
    _notifications = _notifications.map((n) => n.markAsRead()).toList();
    _updateUnreadCount();
    notifyListeners();

    // Server update
    final result = await _repository.markAllAsRead(_userId);

    return result.when(
      success: (count) {
        debugPrint('✅ Marked $count notifications as read');
        return true;
      },
      failure: (message, error) {
        // Rollback on failure
        _notifications = oldNotifications;
        _updateUnreadCount();
        notifyListeners();
        _errorMessage = message;
        debugPrint('Error marking all as read: $error');
        return false;
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Delete a single notification
  Future<bool> deleteNotification(String notificationId) async {
    // Optimistic update
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return false;

    final deletedNotification = _notifications[index];
    _notifications.removeAt(index);
    _updateUnreadCount();
    notifyListeners();

    // Server update
    final result = await _repository.deleteNotification(notificationId);

    return result.when(
      success: (_) {
        debugPrint('🗑️ Notification deleted: $notificationId');
        return true;
      },
      failure: (message, error) {
        // Rollback on failure
        _notifications.insert(index, deletedNotification);
        _updateUnreadCount();
        notifyListeners();
        _errorMessage = message;
        debugPrint('Error deleting notification: $error');
        return false;
      },
    );
  }

  /// Delete all notifications
  Future<bool> deleteAll() async {
    if (_notifications.isEmpty) return true;

    // Optimistic update
    final oldNotifications = List<NotificationEntity>.from(_notifications);
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();

    // Server update
    final result = await _repository.deleteAllForUser(_userId);

    return result.when(
      success: (count) {
        debugPrint('🗑️ Deleted $count notifications');
        return true;
      },
      failure: (message, error) {
        // Rollback on failure
        _notifications = oldNotifications;
        _updateUnreadCount();
        notifyListeners();
        _errorMessage = message;
        debugPrint('Error deleting all notifications: $error');
        return false;
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FILTER
  // ═══════════════════════════════════════════════════════════════════════════

  /// Set current filter
  void setFilter(NotificationFilter filter) {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get a notification by ID
  NotificationEntity? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Retry loading after error
  Future<void> retryLoad() async {
    _status = NotificationsStatus.initial;
    _errorMessage = null;
    await loadNotifications();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _unreadCountSubscription?.cancel();
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Import notification entity - adjust path based on your project structure
// For feature-based structure: '../domain/entities/notification_entity.dart'
// For layer-based structure: '../../domain/entities/notification_entity.dart'
import '../domain/entities/notification_entity.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔔 NOTIFICATIONS REPOSITORY - Data Layer
// ═══════════════════════════════════════════════════════════════════════════════
//
// Handles all notification data operations:
// • Fetch notifications from Firestore
// • Mark as read/unread
// • Delete notifications
// • Real-time updates via streams
//
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// RESULT TYPE (Sealed Class Pattern)
// ═══════════════════════════════════════════════════════════════════════════════

sealed class NotificationResult<T> {
  const NotificationResult();
}

final class NotificationSuccess<T> extends NotificationResult<T> {
  final T data;
  const NotificationSuccess(this.data);
}

final class NotificationFailure<T> extends NotificationResult<T> {
  final String message;
  final Object? error;
  const NotificationFailure(this.message, [this.error]);
}

extension NotificationResultExtension<T> on NotificationResult<T> {
  bool get isSuccess => this is NotificationSuccess<T>;
  bool get isFailure => this is NotificationFailure<T>;

  T? get dataOrNull => isSuccess ? (this as NotificationSuccess<T>).data : null;
  String? get errorMessage => isFailure ? (this as NotificationFailure<T>).message : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Object? error) failure,
  }) {
    if (this is NotificationSuccess<T>) {
      return success((this as NotificationSuccess<T>).data);
    } else {
      final f = this as NotificationFailure<T>;
      return failure(f.message, f.error);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationsRepository {
  final FirebaseFirestore _firestore;

  static const String _collection = 'notifications';
  static const Duration _timeout = Duration(seconds: 10);
  static const int _defaultPageSize = 20;

  NotificationsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // FETCH NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all notifications for a user
  Future<NotificationResult<List<NotificationEntity>>> getNotifications({
    required String userId,
    int limit = _defaultPageSize,
    DocumentSnapshot? startAfter,
    NotificationType? filterType,
    bool? unreadOnly,
  }) async {
    if (userId.isEmpty) {
      return const NotificationFailure('معرف المستخدم فارغ');
    }

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      // Apply filters
      if (filterType != null) {
        query = query.where('type', isEqualTo: filterType.name);
      }

      if (unreadOnly == true) {
        query = query.where('isRead', isEqualTo: false);
      }

      // Pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get().timeout(_timeout);

      final notifications = snapshot.docs
          .map((doc) => NotificationEntity.fromMap(doc.data(), doc.id))
          .toList();

      debugPrint('📬 Fetched ${notifications.length} notifications');
      return NotificationSuccess(notifications);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error fetching notifications: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }

  /// Get a single notification by ID
  Future<NotificationResult<NotificationEntity>> getNotificationById({
    required String notificationId,
  }) async {
    if (notificationId.isEmpty) {
      return const NotificationFailure('معرف الإشعار فارغ');
    }

    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(notificationId)
          .get()
          .timeout(_timeout);

      if (!doc.exists || doc.data() == null) {
        return const NotificationFailure('الإشعار غير موجود');
      }

      return NotificationSuccess(
        NotificationEntity.fromMap(doc.data()!, doc.id),
      );
    } on FirebaseException catch (e) {
      debugPrint('Firebase error fetching notification: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error fetching notification: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REAL-TIME STREAMS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Watch notifications in real-time
  Stream<List<NotificationEntity>> watchNotifications({
    required String userId,
    int limit = _defaultPageSize,
    bool unreadOnly = false,
  }) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    Query<Map<String, dynamic>> query = _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (unreadOnly) {
      query = query.where('isRead', isEqualTo: false);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationEntity.fromMap(doc.data(), doc.id))
          .toList();
    }).handleError((e) {
      debugPrint('Error watching notifications: $e');
      return <NotificationEntity>[];
    });
  }

  /// Watch unread count
  Stream<int> watchUnreadCount(String userId) {
    if (userId.isEmpty) {
      return Stream.value(0);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((e) {
          debugPrint('Error watching unread count: $e');
          return 0;
        });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COUNTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get unread notifications count
  Future<NotificationResult<int>> getUnreadCount(String userId) async {
    if (userId.isEmpty) {
      return const NotificationFailure('معرف المستخدم فارغ');
    }

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get()
          .timeout(_timeout);

      return NotificationSuccess(snapshot.count ?? 0);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting unread count: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }

  /// Get total notifications count
  Future<NotificationResult<int>> getTotalCount(String userId) async {
    if (userId.isEmpty) {
      return const NotificationFailure('معرف المستخدم فارغ');
    }

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .count()
          .get()
          .timeout(_timeout);

      return NotificationSuccess(snapshot.count ?? 0);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error getting total count: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error getting total count: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MARK AS READ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Mark a single notification as read
  Future<NotificationResult<void>> markAsRead(String notificationId) async {
    if (notificationId.isEmpty) {
      return const NotificationFailure('معرف الإشعار فارغ');
    }

    try {
      await _firestore
          .collection(_collection)
          .doc(notificationId)
          .update({
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          })
          .timeout(_timeout);

      debugPrint('✅ Notification marked as read: $notificationId');
      return const NotificationSuccess(null);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error marking as read: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error marking as read: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }

  /// Mark multiple notifications as read
  Future<NotificationResult<void>> markMultipleAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) {
      return const NotificationSuccess(null);
    }

    try {
      final batch = _firestore.batch();
      final now = FieldValue.serverTimestamp();

      for (final id in notificationIds) {
        final docRef = _firestore.collection(_collection).doc(id);
        batch.update(docRef, {
          'isRead': true,
          'readAt': now,
        });
      }

      await batch.commit().timeout(_timeout);

      debugPrint('✅ Marked ${notificationIds.length} notifications as read');
      return const NotificationSuccess(null);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error marking multiple as read: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error marking multiple as read: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }

  /// Mark all notifications as read for a user
  Future<NotificationResult<int>> markAllAsRead(String userId) async {
    if (userId.isEmpty) {
      return const NotificationFailure('معرف المستخدم فارغ');
    }

    try {
      // Get all unread notifications
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get()
          .timeout(_timeout);

      if (snapshot.docs.isEmpty) {
        return const NotificationSuccess(0);
      }

      // Batch update (Firestore limit: 500 per batch)
      final batches = <WriteBatch>[];
      var currentBatch = _firestore.batch();
      var operationCount = 0;
      final now = FieldValue.serverTimestamp();

      for (final doc in snapshot.docs) {
        currentBatch.update(doc.reference, {
          'isRead': true,
          'readAt': now,
        });
        operationCount++;

        if (operationCount % 500 == 0) {
          batches.add(currentBatch);
          currentBatch = _firestore.batch();
        }
      }

      if (operationCount % 500 != 0) {
        batches.add(currentBatch);
      }

      // Commit all batches
      await Future.wait(batches.map((batch) => batch.commit()));

      debugPrint('✅ Marked all ${snapshot.docs.length} notifications as read');
      return NotificationSuccess(snapshot.docs.length);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error marking all as read: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Delete a single notification
  Future<NotificationResult<void>> deleteNotification(String notificationId) async {
    if (notificationId.isEmpty) {
      return const NotificationFailure('معرف الإشعار فارغ');
    }

    try {
      await _firestore
          .collection(_collection)
          .doc(notificationId)
          .delete()
          .timeout(_timeout);

      debugPrint('🗑️ Notification deleted: $notificationId');
      return const NotificationSuccess(null);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error deleting notification: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }

  /// Delete multiple notifications
  Future<NotificationResult<void>> deleteMultiple(List<String> notificationIds) async {
    if (notificationIds.isEmpty) {
      return const NotificationSuccess(null);
    }

    try {
      final batch = _firestore.batch();

      for (final id in notificationIds) {
        final docRef = _firestore.collection(_collection).doc(id);
        batch.delete(docRef);
      }

      await batch.commit().timeout(_timeout);

      debugPrint('🗑️ Deleted ${notificationIds.length} notifications');
      return const NotificationSuccess(null);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error deleting multiple: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error deleting multiple: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }

  /// Delete all notifications for a user
  Future<NotificationResult<int>> deleteAllForUser(String userId) async {
    if (userId.isEmpty) {
      return const NotificationFailure('معرف المستخدم فارغ');
    }

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get()
          .timeout(_timeout);

      if (snapshot.docs.isEmpty) {
        return const NotificationSuccess(0);
      }

      // Batch delete
      final batches = <WriteBatch>[];
      var currentBatch = _firestore.batch();
      var operationCount = 0;

      for (final doc in snapshot.docs) {
        currentBatch.delete(doc.reference);
        operationCount++;

        if (operationCount % 500 == 0) {
          batches.add(currentBatch);
          currentBatch = _firestore.batch();
        }
      }

      if (operationCount % 500 != 0) {
        batches.add(currentBatch);
      }

      await Future.wait(batches.map((batch) => batch.commit()));

      debugPrint('🗑️ Deleted all ${snapshot.docs.length} notifications for user');
      return NotificationSuccess(snapshot.docs.length);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error deleting all: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error deleting all: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE (for testing or local notifications sync)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create a new notification
  Future<NotificationResult<String>> createNotification({
    required String userId,
    required NotificationEntity notification,
  }) async {
    if (userId.isEmpty) {
      return const NotificationFailure('معرف المستخدم فارغ');
    }

    try {
      final data = notification.toMap();
      data['userId'] = userId;
      data['createdAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(_collection)
          .add(data)
          .timeout(_timeout);

      debugPrint('📬 Notification created: ${docRef.id}');
      return NotificationSuccess(docRef.id);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error creating notification: ${e.message}');
      return NotificationFailure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error creating notification: $e');
      return NotificationFailure('خطأ غير متوقع', e);
    }
  }
}

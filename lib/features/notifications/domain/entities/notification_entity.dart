import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔔 NOTIFICATION ENTITY - Domain Layer
// ═══════════════════════════════════════════════════════════════════════════════
//
// Represents a notification in the system.
// Used for both local and push notifications.
//
// Types:
// • Medicine Reminder - تذكير بالدواء
// • Health Alert - تنبيه صحي
// • General - عام
// • Critical - حرج
//
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION TYPE ENUM
// ═══════════════════════════════════════════════════════════════════════════════

enum NotificationType {
  medicineReminder,
  medicineMissed,
  healthAlert,
  healthTip,
  appointment,
  refillReminder,
  general,
  critical,
}

extension NotificationTypeExtension on NotificationType {
  String get arabicName {
    switch (this) {
      case NotificationType.medicineReminder:
        return 'تذكير بالدواء';
      case NotificationType.medicineMissed:
        return 'دواء فائت';
      case NotificationType.healthAlert:
        return 'تنبيه صحي';
      case NotificationType.healthTip:
        return 'نصيحة صحية';
      case NotificationType.appointment:
        return 'موعد';
      case NotificationType.refillReminder:
        return 'تذكير بإعادة التعبئة';
      case NotificationType.general:
        return 'عام';
      case NotificationType.critical:
        return 'حرج';
    }
  }

  String get englishName {
    switch (this) {
      case NotificationType.medicineReminder:
        return 'Medicine Reminder';
      case NotificationType.medicineMissed:
        return 'Missed Medicine';
      case NotificationType.healthAlert:
        return 'Health Alert';
      case NotificationType.healthTip:
        return 'Health Tip';
      case NotificationType.appointment:
        return 'Appointment';
      case NotificationType.refillReminder:
        return 'Refill Reminder';
      case NotificationType.general:
        return 'General';
      case NotificationType.critical:
        return 'Critical';
    }
  }

  String get channelId {
    switch (this) {
      case NotificationType.medicineReminder:
      case NotificationType.medicineMissed:
      case NotificationType.refillReminder:
        return 'medicine_channel';
      case NotificationType.healthAlert:
      case NotificationType.healthTip:
        return 'health_channel';
      case NotificationType.critical:
        return 'critical_channel';
      case NotificationType.appointment:
      case NotificationType.general:
        return 'general_channel';
    }
  }

  bool get isCritical {
    return this == NotificationType.critical ||
           this == NotificationType.medicineMissed ||
           this == NotificationType.healthAlert;
  }

  bool get isMedicineRelated {
    return this == NotificationType.medicineReminder ||
           this == NotificationType.medicineMissed ||
           this == NotificationType.refillReminder;
  }

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'medicinereminder':
      case 'medicine_reminder':
        return NotificationType.medicineReminder;
      case 'medicinemissed':
      case 'medicine_missed':
        return NotificationType.medicineMissed;
      case 'healthalert':
      case 'health_alert':
        return NotificationType.healthAlert;
      case 'healthtip':
      case 'health_tip':
        return NotificationType.healthTip;
      case 'appointment':
        return NotificationType.appointment;
      case 'refillreminder':
      case 'refill_reminder':
        return NotificationType.refillReminder;
      case 'critical':
        return NotificationType.critical;
      default:
        return NotificationType.general;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION PRIORITY ENUM
// ═══════════════════════════════════════════════════════════════════════════════

enum NotificationPriority {
  low,
  normal,
  high,
  critical,
}

extension NotificationPriorityExtension on NotificationPriority {
  String get arabicName {
    switch (this) {
      case NotificationPriority.low:
        return 'منخفضة';
      case NotificationPriority.normal:
        return 'عادية';
      case NotificationPriority.high:
        return 'عالية';
      case NotificationPriority.critical:
        return 'حرجة';
    }
  }

  int get value {
    switch (this) {
      case NotificationPriority.low:
        return 0;
      case NotificationPriority.normal:
        return 1;
      case NotificationPriority.high:
        return 2;
      case NotificationPriority.critical:
        return 3;
    }
  }

  static NotificationPriority fromValue(int value) {
    switch (value) {
      case 0:
        return NotificationPriority.low;
      case 1:
        return NotificationPriority.normal;
      case 2:
        return NotificationPriority.high;
      case 3:
        return NotificationPriority.critical;
      default:
        return NotificationPriority.normal;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION ENTITY
// ═══════════════════════════════════════════════════════════════════════════════

@immutable
class NotificationEntity {
  final String id;
  final String odId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final bool isActioned;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? scheduledFor;
  final Map<String, dynamic>? payload;
  final String? actionRoute;
  final String? imageUrl;

  const NotificationEntity({
    required this.id,
    required this.odId,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    this.isActioned = false,
    required this.createdAt,
    this.readAt,
    this.scheduledFor,
    this.payload,
    this.actionRoute,
    this.imageUrl,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPUTED PROPERTIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Is this a medicine-related notification?
  bool get isMedicineNotification => type.isMedicineRelated;

  /// Is this a critical notification?
  bool get isCritical => type.isCritical || priority == NotificationPriority.critical;

  /// Get medicine ID from payload (if medicine notification)
  String? get medicineId => payload?['medicineId'] as String?;

  /// Get medicine name from payload
  String? get medicineName => payload?['medicineName'] as String?;

  /// Get scheduled time from payload
  String? get scheduledTime => payload?['scheduledTime'] as String?;

  /// Time since notification was created
  Duration get age => DateTime.now().difference(createdAt);

  /// Human-readable time ago string in Arabic
  String get timeAgo {
    final minutes = age.inMinutes;
    final hours = age.inHours;
    final days = age.inDays;

    if (minutes < 1) return 'الآن';
    if (minutes < 60) return 'منذ $minutes دقيقة';
    if (hours < 24) return 'منذ $hours ساعة';
    if (days < 7) return 'منذ $days يوم';
    if (days < 30) return 'منذ ${days ~/ 7} أسبوع';
    return 'منذ ${days ~/ 30} شهر';
  }

  /// Is the notification recent (less than 1 hour)?
  bool get isRecent => age.inHours < 1;

  /// Is the notification from today?
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
           createdAt.month == now.month &&
           createdAt.day == now.day;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COPY WITH
  // ═══════════════════════════════════════════════════════════════════════════

  NotificationEntity copyWith({
    String? id,
    String? odId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    bool? isActioned,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? scheduledFor,
    Map<String, dynamic>? payload,
    String? actionRoute,
    String? imageUrl,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      odId: odId ?? this.odId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      isActioned: isActioned ?? this.isActioned,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      payload: payload ?? this.payload,
      actionRoute: actionRoute ?? this.actionRoute,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Mark as read
  NotificationEntity markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// Mark as actioned
  NotificationEntity markAsActioned() {
    return copyWith(
      isActioned: true,
      isRead: true,
      readAt: readAt ?? DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SERIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'odId': odId,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.value,
      'isRead': isRead,
      'isActioned': isActioned,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'payload': payload,
      'actionRoute': actionRoute,
      'imageUrl': imageUrl,
    };
  }

  factory NotificationEntity.fromMap(Map<String, dynamic> map, [String? docId]) {
    return NotificationEntity(
      id: docId ?? map['id'] as String? ?? '',
      odId: map['odId'] as String? ?? map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? map['message'] as String? ?? '',
      type: NotificationTypeExtension.fromString(map['type'] as String? ?? 'general'),
      priority: NotificationPriorityExtension.fromValue(map['priority'] as int? ?? 1),
      isRead: map['isRead'] as bool? ?? false,
      isActioned: map['isActioned'] as bool? ?? false,
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      readAt: _parseDateTime(map['readAt']),
      scheduledFor: _parseDateTime(map['scheduledFor']),
      payload: map['payload'] as Map<String, dynamic>?,
      actionRoute: map['actionRoute'] as String?,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    // Handle Firestore Timestamp
    if (value is Map && value['_seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as int) * 1000,
      );
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FACTORY CONSTRUCTORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create a medicine reminder notification
  factory NotificationEntity.medicineReminder({
    required String id,
    required String odId,
    required String medicineName,
    required String dosage,
    required String scheduledTime,
    String? medicineId,
  }) {
    return NotificationEntity(
      id: id,
      odId: odId,
      title: 'حان وقت الدواء 💊',
      body: '$medicineName - $dosage\nالموعد: $scheduledTime',
      type: NotificationType.medicineReminder,
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      payload: {
        'medicineId': medicineId,
        'medicineName': medicineName,
        'dosage': dosage,
        'scheduledTime': scheduledTime,
      },
      actionRoute: '/medicines',
    );
  }

  /// Create a missed medicine notification
  factory NotificationEntity.medicineMissed({
    required String id,
    required String odId,
    required String medicineName,
    required String scheduledTime,
    String? medicineId,
  }) {
    return NotificationEntity(
      id: id,
      odId: odId,
      title: 'دواء فائت ⚠️',
      body: 'لم تتناول $medicineName في موعده ($scheduledTime)',
      type: NotificationType.medicineMissed,
      priority: NotificationPriority.critical,
      createdAt: DateTime.now(),
      payload: {
        'medicineId': medicineId,
        'medicineName': medicineName,
        'scheduledTime': scheduledTime,
      },
      actionRoute: '/medicines',
    );
  }

  /// Create a health alert notification
  factory NotificationEntity.healthAlert({
    required String id,
    required String odId,
    required String title,
    required String body,
    String? readingType,
    double? readingValue,
  }) {
    return NotificationEntity(
      id: id,
      odId: odId,
      title: title,
      body: body,
      type: NotificationType.healthAlert,
      priority: NotificationPriority.critical,
      createdAt: DateTime.now(),
      payload: {
        'readingType': readingType,
        'readingValue': readingValue,
      },
      actionRoute: '/health',
    );
  }

  /// Create a refill reminder notification
  factory NotificationEntity.refillReminder({
    required String id,
    required String odId,
    required String medicineName,
    required int remainingCount,
    String? medicineId,
  }) {
    return NotificationEntity(
      id: id,
      odId: odId,
      title: 'تذكير بإعادة التعبئة 📦',
      body: 'المتبقي من $medicineName: $remainingCount فقط',
      type: NotificationType.refillReminder,
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
      payload: {
        'medicineId': medicineId,
        'medicineName': medicineName,
        'remainingCount': remainingCount,
      },
      actionRoute: '/medicines',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EQUALITY & HASH
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationEntity &&
        other.id == id &&
        other.odId == odId &&
        other.isRead == isRead;
  }

  @override
  int get hashCode => Object.hash(id, odId, isRead);

  @override
  String toString() {
    return 'NotificationEntity(id: $id, title: $title, type: ${type.name}, isRead: $isRead)';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION GROUP (for grouping by date)
// ═══════════════════════════════════════════════════════════════════════════════

@immutable
class NotificationGroup {
  final String title;
  final DateTime date;
  final List<NotificationEntity> notifications;

  const NotificationGroup({
    required this.title,
    required this.date,
    required this.notifications,
  });

  int get count => notifications.length;
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  /// Group notifications by date
  static List<NotificationGroup> groupByDate(List<NotificationEntity> notifications) {
    final Map<String, List<NotificationEntity>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final notification in notifications) {
      final date = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String key;
      if (date == today) {
        key = 'اليوم';
      } else if (date == yesterday) {
        key = 'أمس';
      } else if (now.difference(date).inDays < 7) {
        key = 'هذا الأسبوع';
      } else if (now.difference(date).inDays < 30) {
        key = 'هذا الشهر';
      } else {
        key = 'قديم';
      }

      grouped.putIfAbsent(key, () => []).add(notification);
    }

    // Sort and convert to list
    final order = ['اليوم', 'أمس', 'هذا الأسبوع', 'هذا الشهر', 'قديم'];
    return order
        .where((key) => grouped.containsKey(key))
        .map((key) => NotificationGroup(
              title: key,
              date: grouped[key]!.first.createdAt,
              notifications: grouped[key]!,
            ))
        .toList();
  }
}

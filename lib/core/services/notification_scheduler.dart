import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_notification_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 📅 NOTIFICATION SCHEDULER - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Purpose:
// Bridges MedicineEntity data with LocalNotificationService to schedule,
// cancel, and manage medicine reminder notifications.
//
// Features:
// • Schedule notifications for all medicine times
// • Generate unique notification IDs per medicine/time
// • Cancel notifications when medicine is deleted/deactivated
// • Reschedule all notifications on app start
// • Snooze support with configurable durations
// • Respects user notification settings
//
// Architecture: Service Layer (Clean Architecture)
// Pattern: Singleton + Facade
//
// Usage:
// ```dart
// // Schedule for a medicine
// await NotificationScheduler.instance.scheduleForMedicine(medicine);
//
// // Cancel for a medicine
// await NotificationScheduler.instance.cancelForMedicine(medicineId);
//
// // Reschedule all on app start
// await NotificationScheduler.instance.rescheduleAllMedicines(userId);
// ```
//
// ═══════════════════════════════════════════════════════════════════════════════

/// Medicine data required for scheduling (lightweight DTO)
/// This avoids tight coupling with MedicineEntity
@immutable
class SchedulableMedicine {
  final String id;
  final String name;
  final String dosage;
  final List<String> times;
  final bool isActive;
  final bool isCritical;
  final String? instructions;
  final DateTime? startDate;
  final DateTime? endDate;

  const SchedulableMedicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    this.isActive = true,
    this.isCritical = false,
    this.instructions,
    this.startDate,
    this.endDate,
  });

  /// Create from Firestore document
  factory SchedulableMedicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    return SchedulableMedicine(
      id: doc.id,
      name: data['name'] as String? ?? '',
      dosage: data['dosage'] as String? ?? '',
      times: List<String>.from(data['times'] as List? ?? []),
      isActive: data['isActive'] as bool? ?? true,
      isCritical: data['isCritical'] as bool? ?? false,
      instructions: data['instructions'] as String?,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
    );
  }

  /// Check if medicine is scheduled for today
  bool get isScheduledToday {
    if (!isActive) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (startDate != null) {
      final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
      if (today.isBefore(start)) return false;
    }
    
    if (endDate != null) {
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (today.isAfter(end)) return false;
    }
    
    return true;
  }

  @override
  String toString() => 'SchedulableMedicine(id: $id, name: $name, times: $times)';
}

/// Result of scheduling operation
@immutable
class ScheduleResult {
  final bool success;
  final int scheduledCount;
  final int failedCount;
  final List<String> errors;

  const ScheduleResult({
    required this.success,
    this.scheduledCount = 0,
    this.failedCount = 0,
    this.errors = const [],
  });

  factory ScheduleResult.success(int count) => ScheduleResult(
    success: true,
    scheduledCount: count,
  );

  factory ScheduleResult.failure(String error) => ScheduleResult(
    success: false,
    errors: [error],
  );

  factory ScheduleResult.partial({
    required int scheduled,
    required int failed,
    required List<String> errors,
  }) => ScheduleResult(
    success: failed == 0,
    scheduledCount: scheduled,
    failedCount: failed,
    errors: errors,
  );

  @override
  String toString() => 'ScheduleResult(success: $success, scheduled: $scheduledCount, failed: $failedCount)';
}

/// Main Notification Scheduler Service
class NotificationScheduler {
  // ═══════════════════════════════════════════════════════════════════════════
  // SINGLETON
  // ═══════════════════════════════════════════════════════════════════════════

  static final NotificationScheduler _instance = NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;
  NotificationScheduler._internal();

  static NotificationScheduler get instance => _instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Base ID for medicine notifications (to avoid collision with other notifications)
  static const int _medicineNotificationBaseId = 100000;

  /// Maximum notifications per medicine (safety limit)
  static const int _maxNotificationsPerMedicine = 10;

  /// Snooze durations in minutes
  static const List<int> snoozeDurations = [5, 10, 15, 30, 60];

  /// Default snooze duration
  static const int defaultSnoozeDuration = 15;

  /// SharedPreferences key for tracking scheduled medicines
  static const String _scheduledMedicinesKey = 'scheduled_medicine_ids';

  // ═══════════════════════════════════════════════════════════════════════════
  // DEPENDENCIES
  // ═══════════════════════════════════════════════════════════════════════════

  final LocalNotificationService _notificationService = LocalNotificationService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // ID GENERATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generate a unique notification ID for a medicine at a specific time
  /// 
  /// Formula: baseId + (medicineIdHash % 10000) * 10 + timeIndex
  /// This ensures:
  /// - IDs are deterministic (same medicine/time = same ID)
  /// - IDs don't collide with other notification types
  /// - Each time slot has its own ID
  int generateNotificationId(String medicineId, int timeIndex) {
    // Use hashCode to convert string ID to int
    final medicineHash = medicineId.hashCode.abs() % 10000;
    // Multiply by 10 to leave room for up to 10 times per medicine
    return _medicineNotificationBaseId + (medicineHash * 10) + timeIndex;
  }

  /// Get all notification IDs for a medicine
  List<int> getNotificationIds(String medicineId, int timesCount) {
    return List.generate(
      timesCount.clamp(0, _maxNotificationsPerMedicine),
      (index) => generateNotificationId(medicineId, index),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME PARSING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Parse time string (HH:mm) to DateTime for today
  /// Returns null if parsing fails or time has passed
  DateTime? parseTimeForToday(String timeString, {bool allowPast = false}) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      final now = DateTime.now();
      var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

      // If time has passed today and we don't allow past, schedule for tomorrow
      if (!allowPast && scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      return scheduledTime;
    } catch (e) {
      debugPrint('❌ Error parsing time "$timeString": $e');
      return null;
    }
  }

  /// Parse time string to hour and minute
  ({int hour, int minute})? parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return (hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEDULE FOR MEDICINE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Schedule notifications for a single medicine
  /// 
  /// This will:
  /// 1. Cancel any existing notifications for this medicine
  /// 2. Schedule new notifications for each time in the times array
  /// 3. Track the medicine ID for later rescheduling
  Future<ScheduleResult> scheduleForMedicine(SchedulableMedicine medicine) async {
    debugPrint('📅 Scheduling notifications for: ${medicine.name}');

    // Validate medicine
    if (!medicine.isActive) {
      debugPrint('ℹ️ Medicine is inactive, skipping: ${medicine.name}');
      return ScheduleResult.success(0);
    }

    if (medicine.times.isEmpty) {
      debugPrint('ℹ️ Medicine has no times, skipping: ${medicine.name}');
      return ScheduleResult.success(0);
    }

    if (!medicine.isScheduledToday) {
      debugPrint('ℹ️ Medicine not scheduled for today: ${medicine.name}');
      return ScheduleResult.success(0);
    }

    // Check if notification service is initialized
    if (!_notificationService.isInitialized) {
      debugPrint('⚠️ Notification service not initialized');
      return ScheduleResult.failure('خدمة الإشعارات غير مفعلة');
    }

    // Cancel existing notifications first
    await cancelForMedicine(medicine.id, medicine.times.length);

    int scheduledCount = 0;
    int failedCount = 0;
    final errors = <String>[];

    // Schedule for each time
    for (int i = 0; i < medicine.times.length && i < _maxNotificationsPerMedicine; i++) {
      final timeString = medicine.times[i];
      final success = await _scheduleForTime(
        medicine: medicine,
        timeString: timeString,
        timeIndex: i,
      );

      if (success) {
        scheduledCount++;
      } else {
        failedCount++;
        errors.add('فشل جدولة الوقت: $timeString');
      }
    }

    // Track scheduled medicine
    await _trackScheduledMedicine(medicine.id);

    debugPrint('✅ Scheduled $scheduledCount/${medicine.times.length} notifications for ${medicine.name}');

    return ScheduleResult.partial(
      scheduled: scheduledCount,
      failed: failedCount,
      errors: errors,
    );
  }

  /// Schedule a single notification for a specific time
  Future<bool> _scheduleForTime({
    required SchedulableMedicine medicine,
    required String timeString,
    required int timeIndex,
  }) async {
    final scheduledTime = parseTimeForToday(timeString);
    if (scheduledTime == null) {
      debugPrint('⚠️ Invalid time format: $timeString');
      return false;
    }

    final notificationId = generateNotificationId(medicine.id, timeIndex);

    // Build notification content
    final title = _buildNotificationTitle(medicine);
    final body = _buildNotificationBody(medicine, timeString);
    final payload = _buildPayload(medicine, timeString);

    // Determine channel based on criticality
    final channel = medicine.isCritical
        ? NotificationChannel.critical
        : NotificationChannel.medicine;

    // Schedule the notification
    return await _notificationService.scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      channel: channel,
      payload: payload,
    );
  }

  /// Build notification title
  String _buildNotificationTitle(SchedulableMedicine medicine) {
    if (medicine.isCritical) {
      return '⚠️ حان موعد ${medicine.name}';
    }
    return '💊 حان موعد ${medicine.name}';
  }

  /// Build notification body
  String _buildNotificationBody(SchedulableMedicine medicine, String time) {
    final buffer = StringBuffer();
    buffer.write('الجرعة: ${medicine.dosage}');
    
    if (medicine.instructions != null && medicine.instructions!.isNotEmpty) {
      buffer.write('\n${medicine.instructions}');
    }

    return buffer.toString();
  }

  /// Build notification payload
  NotificationPayload _buildPayload(SchedulableMedicine medicine, String time) {
    return NotificationPayload(
      type: 'medicine_reminder',
      medicineId: medicine.id,
      medicineName: medicine.name,
      scheduledTime: time,
      route: '/medicines',
      extra: {
        'dosage': medicine.dosage,
        'isCritical': medicine.isCritical,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEDULE DAILY REPEATING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Schedule daily repeating notifications for a medicine
  /// 
  /// Use this for medicines that should repeat every day at the same times
  Future<ScheduleResult> scheduleDailyRepeating(SchedulableMedicine medicine) async {
    debugPrint('📅 Scheduling daily repeating notifications for: ${medicine.name}');

    if (!medicine.isActive || medicine.times.isEmpty) {
      return ScheduleResult.success(0);
    }

    if (!_notificationService.isInitialized) {
      return ScheduleResult.failure('خدمة الإشعارات غير مفعلة');
    }

    // Cancel existing
    await cancelForMedicine(medicine.id, medicine.times.length);

    int scheduledCount = 0;
    int failedCount = 0;
    final errors = <String>[];

    for (int i = 0; i < medicine.times.length && i < _maxNotificationsPerMedicine; i++) {
      final timeString = medicine.times[i];
      final parsedTime = parseTime(timeString);
      
      if (parsedTime == null) {
        failedCount++;
        errors.add('وقت غير صالح: $timeString');
        continue;
      }

      final notificationId = generateNotificationId(medicine.id, i);
      final title = _buildNotificationTitle(medicine);
      final body = _buildNotificationBody(medicine, timeString);
      final payload = _buildPayload(medicine, timeString);

      final channel = medicine.isCritical
          ? NotificationChannel.critical
          : NotificationChannel.medicine;

      final success = await _notificationService.scheduleDailyNotification(
        id: notificationId,
        title: title,
        body: body,
        hour: parsedTime.hour,
        minute: parsedTime.minute,
        channel: channel,
        payload: payload,
      );

      if (success) {
        scheduledCount++;
      } else {
        failedCount++;
        errors.add('فشل جدولة الوقت: $timeString');
      }
    }

    await _trackScheduledMedicine(medicine.id);

    return ScheduleResult.partial(
      scheduled: scheduledCount,
      failed: failedCount,
      errors: errors,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CANCEL NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cancel all notifications for a medicine
  Future<void> cancelForMedicine(String medicineId, [int timesCount = _maxNotificationsPerMedicine]) async {
    debugPrint('🚫 Cancelling notifications for medicine: $medicineId');

    final notificationIds = getNotificationIds(medicineId, timesCount);
    await _notificationService.cancelNotifications(notificationIds);
    await _untrackScheduledMedicine(medicineId);

    debugPrint('✅ Cancelled ${notificationIds.length} notifications');
  }

  /// Cancel all medicine notifications
  Future<void> cancelAllMedicineNotifications() async {
    debugPrint('🚫 Cancelling all medicine notifications');

    final scheduledIds = await _getScheduledMedicineIds();
    
    for (final medicineId in scheduledIds) {
      await cancelForMedicine(medicineId);
    }

    await _clearScheduledMedicines();
    debugPrint('✅ All medicine notifications cancelled');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SNOOZE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Snooze a medicine notification
  /// 
  /// Reschedules the notification for [minutes] from now
  Future<bool> snoozeMedicine({
    required SchedulableMedicine medicine,
    required String originalTime,
    int minutes = defaultSnoozeDuration,
  }) async {
    debugPrint('😴 Snoozing ${medicine.name} for $minutes minutes');

    // Find the time index
    final timeIndex = medicine.times.indexOf(originalTime);
    if (timeIndex == -1) {
      debugPrint('⚠️ Time not found in medicine times');
      return false;
    }

    // Calculate snooze time
    final snoozeTime = DateTime.now().add(Duration(minutes: minutes));

    final notificationId = generateNotificationId(medicine.id, timeIndex);
    final title = '😴 تذكير مؤجل: ${medicine.name}';
    final body = 'الجرعة: ${medicine.dosage}\n(تم التأجيل $minutes دقيقة)';
    final payload = _buildPayload(medicine, originalTime);

    // Cancel existing and reschedule
    await _notificationService.cancelNotification(notificationId);

    return await _notificationService.scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: snoozeTime,
      channel: medicine.isCritical 
          ? NotificationChannel.critical 
          : NotificationChannel.medicine,
      payload: payload,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESCHEDULE ALL
  // ═══════════════════════════════════════════════════════════════════════════

  /// Reschedule all active medicines for a user
  /// 
  /// Call this on app start to ensure all notifications are scheduled
  Future<ScheduleResult> rescheduleAllMedicines(String userId) async {
    debugPrint('🔄 Rescheduling all medicines for user: $userId');

    if (userId.isEmpty) {
      return ScheduleResult.failure('معرف المستخدم فارغ');
    }

    try {
      // Fetch active medicines from Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('ℹ️ No active medicines found');
        return ScheduleResult.success(0);
      }

      int totalScheduled = 0;
      int totalFailed = 0;
      final allErrors = <String>[];

      for (final doc in snapshot.docs) {
        try {
          final medicine = SchedulableMedicine.fromFirestore(doc);
          final result = await scheduleForMedicine(medicine);
          
          totalScheduled += result.scheduledCount;
          totalFailed += result.failedCount;
          allErrors.addAll(result.errors);
        } catch (e) {
          debugPrint('❌ Error scheduling medicine ${doc.id}: $e');
          totalFailed++;
          allErrors.add('خطأ في جدولة دواء: ${doc.id}');
        }
      }

      debugPrint('✅ Rescheduled: $totalScheduled notifications for ${snapshot.docs.length} medicines');

      return ScheduleResult.partial(
        scheduled: totalScheduled,
        failed: totalFailed,
        errors: allErrors,
      );
    } catch (e) {
      debugPrint('❌ Error rescheduling medicines: $e');
      return ScheduleResult.failure('خطأ في جدولة الإشعارات: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TRACKING (SharedPreferences)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get list of scheduled medicine IDs
  Future<List<String>> _getScheduledMedicineIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_scheduledMedicinesKey) ?? [];
    } catch (e) {
      debugPrint('❌ Error getting scheduled medicines: $e');
      return [];
    }
  }

  /// Track a scheduled medicine
  Future<void> _trackScheduledMedicine(String medicineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_scheduledMedicinesKey) ?? [];
      
      if (!current.contains(medicineId)) {
        current.add(medicineId);
        await prefs.setStringList(_scheduledMedicinesKey, current);
      }
    } catch (e) {
      debugPrint('❌ Error tracking scheduled medicine: $e');
    }
  }

  /// Untrack a scheduled medicine
  Future<void> _untrackScheduledMedicine(String medicineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_scheduledMedicinesKey) ?? [];
      
      current.remove(medicineId);
      await prefs.setStringList(_scheduledMedicinesKey, current);
    } catch (e) {
      debugPrint('❌ Error untracking scheduled medicine: $e');
    }
  }

  /// Clear all tracked medicines
  Future<void> _clearScheduledMedicines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scheduledMedicinesKey);
    } catch (e) {
      debugPrint('❌ Error clearing scheduled medicines: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get count of pending medicine notifications
  Future<int> getPendingNotificationsCount() async {
    try {
      final pending = await _notificationService.getPendingNotifications();
      // Filter to only medicine notifications (ID >= baseId)
      return pending.where((n) => n.id >= _medicineNotificationBaseId).length;
    } catch (e) {
      debugPrint('❌ Error getting pending count: $e');
      return 0;
    }
  }

  /// Check if a medicine has scheduled notifications
  Future<bool> hasScheduledNotifications(String medicineId) async {
    try {
      final pending = await _notificationService.getPendingNotifications();
      final medicineIds = getNotificationIds(medicineId, _maxNotificationsPerMedicine);
      
      return pending.any((n) => medicineIds.contains(n.id));
    } catch (e) {
      debugPrint('❌ Error checking scheduled notifications: $e');
      return false;
    }
  }

  /// Debug: Print all pending notifications
  Future<void> debugPrintPendingNotifications() async {
    if (!kDebugMode) return;

    final pending = await _notificationService.getPendingNotifications();
    debugPrint('═══════════════════════════════════════════');
    debugPrint('📋 Pending Notifications: ${pending.length}');
    for (final n in pending) {
      debugPrint('  ID: ${n.id}, Title: ${n.title}');
    }
    debugPrint('═══════════════════════════════════════════');
  }
}

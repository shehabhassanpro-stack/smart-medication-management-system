import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_notification_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 💊 MEDICINE REMINDER SERVICE - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Features:
// • Schedule medicine reminders based on times array
// • Generate unique notification IDs per medicine/time
// • Handle snooze (reschedule for later)
// • Cancel reminders when medicine is deleted/deactivated
// • Reschedule all reminders on app start
//
// Architecture: Service Layer (Clean Architecture)
// Pattern: Singleton
//
// ═══════════════════════════════════════════════════════════════════════════════

/// Medicine data for scheduling reminders
@immutable
class MedicineReminderData {
  final String id;
  final String name;
  final String dosage;
  final List<String> times;
  final bool isActive;
  final bool isCritical;

  const MedicineReminderData({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    this.isActive = true,
    this.isCritical = false,
  });

  @override
  String toString() => 'MedicineReminderData(id: $id, name: $name, times: $times)';
}

/// Snooze duration options
enum SnoozeDuration {
  fiveMinutes,
  tenMinutes,
  fifteenMinutes,
  thirtyMinutes,
  oneHour,
}

extension SnoozeDurationExtension on SnoozeDuration {
  int get minutes {
    switch (this) {
      case SnoozeDuration.fiveMinutes:
        return 5;
      case SnoozeDuration.tenMinutes:
        return 10;
      case SnoozeDuration.fifteenMinutes:
        return 15;
      case SnoozeDuration.thirtyMinutes:
        return 30;
      case SnoozeDuration.oneHour:
        return 60;
    }
  }

  String get arabicName {
    switch (this) {
      case SnoozeDuration.fiveMinutes:
        return '5 دقائق';
      case SnoozeDuration.tenMinutes:
        return '10 دقائق';
      case SnoozeDuration.fifteenMinutes:
        return '15 دقيقة';
      case SnoozeDuration.thirtyMinutes:
        return '30 دقيقة';
      case SnoozeDuration.oneHour:
        return 'ساعة';
    }
  }
}

/// Main Medicine Reminder Service
class MedicineReminderService {
  // ═══════════════════════════════════════════════════════════════════════════
  // SINGLETON
  // ═══════════════════════════════════════════════════════════════════════════

  static final MedicineReminderService _instance = MedicineReminderService._internal();
  factory MedicineReminderService() => _instance;
  MedicineReminderService._internal();

  static MedicineReminderService get instance => _instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Base multiplier for generating unique notification IDs
  /// Each medicine gets IDs: baseId + (timeIndex * 1000)
  static const int _notificationIdMultiplier = 1000;

  /// Key prefix for storing scheduled reminders
  static const String _scheduledRemindersKey = 'scheduled_medicine_reminders';

  /// Default snooze duration
  static const SnoozeDuration defaultSnoozeDuration = SnoozeDuration.fifteenMinutes;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROPERTIES
  // ═══════════════════════════════════════════════════════════════════════════

  final LocalNotificationService _notificationService = LocalNotificationService.instance;
  bool _isInitialized = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  bool get isInitialized => _isInitialized;

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Initialize the reminder service
  Future<bool> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ MedicineReminderService already initialized');
      return true;
    }

    try {
      debugPrint('💊 Initializing MedicineReminderService...');

      // Ensure notification service is initialized
      if (!_notificationService.isInitialized) {
        debugPrint('⚠️ LocalNotificationService not initialized');
        return false;
      }

      // Setup notification action handlers
      _setupActionHandlers();

      _isInitialized = true;
      debugPrint('✅ MedicineReminderService initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing MedicineReminderService: $e');
      return false;
    }
  }

  /// Setup handlers for notification actions
  void _setupActionHandlers() {
    _notificationService.notificationStream.listen((response) {
      _handleNotificationAction(response);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION ID GENERATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generate a unique notification ID for a medicine time
  /// Formula: hash(medicineId) % 100000 + (timeIndex * 1000)
  int _generateNotificationId(String medicineId, int timeIndex) {
    final baseId = medicineId.hashCode.abs() % 100000;
    return baseId + (timeIndex * _notificationIdMultiplier);
  }

  /// Generate all notification IDs for a medicine
  List<int> _generateAllNotificationIds(String medicineId, int timesCount) {
    return List.generate(
      timesCount,
      (index) => _generateNotificationId(medicineId, index),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME PARSING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Parse time string to hour and minute
  /// Supports formats: "08:00", "8:00", "08:30"
  ({int hour, int minute})? _parseTime(String timeString) {
    try {
      final parts = timeString.trim().split(':');
      if (parts.length != 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return (hour: hour, minute: minute);
    } catch (e) {
      debugPrint('❌ Error parsing time: $timeString - $e');
      return null;
    }
  }

  /// Get next occurrence of a time today or tomorrow
  DateTime _getNextOccurrence(int hour, int minute) {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEDULE REMINDERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Schedule all reminders for a medicine
  Future<bool> scheduleMedicineReminders(MedicineReminderData medicine) async {
    if (!_isInitialized) {
      debugPrint('⚠️ MedicineReminderService not initialized');
      return false;
    }

    if (!medicine.isActive) {
      debugPrint('ℹ️ Medicine ${medicine.name} is not active, skipping');
      return true;
    }

    if (medicine.times.isEmpty) {
      debugPrint('ℹ️ Medicine ${medicine.name} has no scheduled times');
      return true;
    }

    try {
      debugPrint('📅 Scheduling reminders for: ${medicine.name}');

      int successCount = 0;

      for (int i = 0; i < medicine.times.length; i++) {
        final timeString = medicine.times[i];
        final parsedTime = _parseTime(timeString);

        if (parsedTime == null) {
          debugPrint('⚠️ Invalid time format: $timeString');
          continue;
        }

        final notificationId = _generateNotificationId(medicine.id, i);
        final scheduledTime = _getNextOccurrence(parsedTime.hour, parsedTime.minute);

        final payload = NotificationPayload(
          type: 'medicine_reminder',
          medicineId: medicine.id,
          medicineName: medicine.name,
          scheduledTime: timeString,
          route: '/medicines',
          extra: {
            'dosage': medicine.dosage,
            'timeIndex': i,
            'isCritical': medicine.isCritical,
          },
        );

        final scheduled = await _notificationService.scheduleNotification(
          id: notificationId,
          title: _buildNotificationTitle(medicine),
          body: _buildNotificationBody(medicine, timeString),
          scheduledTime: scheduledTime,
          channel: medicine.isCritical
              ? NotificationChannel.critical
              : NotificationChannel.medicine,
          payload: payload,
        );

        if (scheduled) {
          successCount++;
          debugPrint('  ✅ Scheduled for $timeString (ID: $notificationId)');
        } else {
          debugPrint('  ❌ Failed to schedule for $timeString');
        }
      }

      // Store scheduled medicine ID
      await _saveScheduledMedicine(medicine.id);

      debugPrint('📅 Scheduled $successCount/${medicine.times.length} reminders for ${medicine.name}');
      return successCount > 0;
    } catch (e) {
      debugPrint('❌ Error scheduling reminders: $e');
      return false;
    }
  }

  /// Build notification title
  String _buildNotificationTitle(MedicineReminderData medicine) {
    if (medicine.isCritical) {
      return '⚠️ حان موعد دواء مهم!';
    }
    return '💊 حان موعد الدواء';
  }

  /// Build notification body
  String _buildNotificationBody(MedicineReminderData medicine, String time) {
    final formattedTime = _formatTimeArabic(time);
    return '${medicine.name} - ${medicine.dosage}\n⏰ $formattedTime';
  }

  /// Format time to Arabic (e.g., "08:00" → "8:00 ص")
  String _formatTimeArabic(String time) {
    final parsed = _parseTime(time);
    if (parsed == null) return time;

    final hour = parsed.hour;
    final minute = parsed.minute;
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute $period';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CANCEL REMINDERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cancel all reminders for a medicine
  Future<void> cancelMedicineReminders(String medicineId, {int timesCount = 10}) async {
    try {
      debugPrint('🗑️ Cancelling reminders for medicine: $medicineId');

      final notificationIds = _generateAllNotificationIds(medicineId, timesCount);
      await _notificationService.cancelNotifications(notificationIds);

      // Remove from stored list
      await _removeScheduledMedicine(medicineId);

      debugPrint('✅ Cancelled ${notificationIds.length} potential reminders');
    } catch (e) {
      debugPrint('❌ Error cancelling reminders: $e');
    }
  }

  /// Cancel a specific reminder
  Future<void> cancelReminder(String medicineId, int timeIndex) async {
    try {
      final notificationId = _generateNotificationId(medicineId, timeIndex);
      await _notificationService.cancelNotification(notificationId);
      debugPrint('✅ Cancelled reminder ID: $notificationId');
    } catch (e) {
      debugPrint('❌ Error cancelling reminder: $e');
    }
  }

  /// Cancel all medicine reminders
  Future<void> cancelAllReminders() async {
    try {
      debugPrint('🗑️ Cancelling all medicine reminders...');

      final scheduledIds = await _getScheduledMedicineIds();
      for (final medicineId in scheduledIds) {
        await cancelMedicineReminders(medicineId);
      }

      await _clearScheduledMedicines();
      debugPrint('✅ All reminders cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling all reminders: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SNOOZE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Snooze a medicine reminder
  Future<bool> snoozeReminder({
    required String medicineId,
    required String medicineName,
    required String dosage,
    required int timeIndex,
    SnoozeDuration duration = defaultSnoozeDuration,
  }) async {
    try {
      debugPrint('😴 Snoozing reminder for $medicineName (${duration.arabicName})');

      // Cancel current reminder
      await cancelReminder(medicineId, timeIndex);

      // Schedule new reminder
      final snoozeTime = DateTime.now().add(Duration(minutes: duration.minutes));
      final notificationId = _generateNotificationId(medicineId, timeIndex);

      final payload = NotificationPayload(
        type: 'medicine_reminder_snoozed',
        medicineId: medicineId,
        medicineName: medicineName,
        route: '/medicines',
        extra: {
          'dosage': dosage,
          'timeIndex': timeIndex,
          'snoozedAt': DateTime.now().toIso8601String(),
        },
      );

      final scheduled = await _notificationService.scheduleNotification(
        id: notificationId,
        title: '💊 تذكير (مؤجل)',
        body: '$medicineName - $dosage',
        scheduledTime: snoozeTime,
        channel: NotificationChannel.medicine,
        payload: payload,
      );

      if (scheduled) {
        debugPrint('✅ Snoozed until ${snoozeTime.toString()}');
      }

      return scheduled;
    } catch (e) {
      debugPrint('❌ Error snoozing reminder: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESCHEDULE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Reschedule all reminders for a list of medicines
  /// Call this on app start to ensure reminders are up to date
  Future<void> rescheduleAllReminders(List<MedicineReminderData> medicines) async {
    try {
      debugPrint('🔄 Rescheduling all medicine reminders...');

      // Cancel all existing reminders first
      await cancelAllReminders();

      // Schedule new reminders
      int successCount = 0;
      for (final medicine in medicines) {
        if (await scheduleMedicineReminders(medicine)) {
          successCount++;
        }
      }

      debugPrint('✅ Rescheduled reminders for $successCount/${medicines.length} medicines');
    } catch (e) {
      debugPrint('❌ Error rescheduling reminders: $e');
    }
  }

  /// Update reminders for a single medicine (after edit)
  Future<void> updateMedicineReminders(MedicineReminderData medicine) async {
    await cancelMedicineReminders(medicine.id);
    await scheduleMedicineReminders(medicine);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION ACTION HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Handle notification action (mark taken, skip, snooze)
  void _handleNotificationAction(NotificationResponse response) {
    final actionId = response.actionId;
    final payloadString = response.payload;

    if (payloadString == null || payloadString.isEmpty) return;

    try {
      final payload = NotificationPayload.fromJson(payloadString);

      if (payload.type != 'medicine_reminder' &&
          payload.type != 'medicine_reminder_snoozed') {
        return;
      }

      debugPrint('📩 Medicine notification action: $actionId');
      debugPrint('   Medicine: ${payload.medicineName}');

      switch (actionId) {
        case NotificationActions.markTaken:
          _onMarkTaken(payload);
          break;
        case NotificationActions.skip:
          _onSkip(payload);
          break;
        case NotificationActions.snooze:
          _onSnooze(payload);
          break;
        default:
          // Notification tapped (no specific action)
          _onNotificationTapped(payload);
      }
    } catch (e) {
      debugPrint('❌ Error handling notification action: $e');
    }
  }

  // Action callbacks - can be overridden by setting handlers
  Function(NotificationPayload)? onMarkTakenCallback;
  Function(NotificationPayload)? onSkipCallback;
  Function(NotificationPayload)? onSnoozeCallback;
  Function(NotificationPayload)? onNotificationTappedCallback;

  void _onMarkTaken(NotificationPayload payload) {
    debugPrint('✅ Mark taken: ${payload.medicineName}');
    onMarkTakenCallback?.call(payload);
  }

  void _onSkip(NotificationPayload payload) {
    debugPrint('⏭️ Skip: ${payload.medicineName}');
    onSkipCallback?.call(payload);
  }

  void _onSnooze(NotificationPayload payload) {
    debugPrint('😴 Snooze: ${payload.medicineName}');

    // Default snooze behavior
    if (payload.medicineId != null) {
      final timeIndex = payload.extra?['timeIndex'] as int? ?? 0;
      snoozeReminder(
        medicineId: payload.medicineId!,
        medicineName: payload.medicineName ?? '',
        dosage: payload.extra?['dosage'] as String? ?? '',
        timeIndex: timeIndex,
      );
    }

    onSnoozeCallback?.call(payload);
  }

  void _onNotificationTapped(NotificationPayload payload) {
    debugPrint('👆 Notification tapped: ${payload.medicineName}');
    onNotificationTappedCallback?.call(payload);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PERSISTENCE (Store scheduled medicine IDs)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveScheduledMedicine(String medicineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = await _getScheduledMedicineIds();
      if (!ids.contains(medicineId)) {
        ids.add(medicineId);
        await prefs.setStringList(_scheduledRemindersKey, ids);
      }
    } catch (e) {
      debugPrint('❌ Error saving scheduled medicine: $e');
    }
  }

  Future<void> _removeScheduledMedicine(String medicineId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = await _getScheduledMedicineIds();
      ids.remove(medicineId);
      await prefs.setStringList(_scheduledRemindersKey, ids);
    } catch (e) {
      debugPrint('❌ Error removing scheduled medicine: $e');
    }
  }

  Future<List<String>> _getScheduledMedicineIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_scheduledRemindersKey) ?? [];
    } catch (e) {
      debugPrint('❌ Error getting scheduled medicines: $e');
      return [];
    }
  }

  Future<void> _clearScheduledMedicines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scheduledRemindersKey);
    } catch (e) {
      debugPrint('❌ Error clearing scheduled medicines: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if a medicine has scheduled reminders
  Future<bool> hasScheduledReminders(String medicineId) async {
    final ids = await _getScheduledMedicineIds();
    return ids.contains(medicineId);
  }

  /// Get pending reminders count
  Future<int> getPendingRemindersCount() async {
    final pending = await _notificationService.getPendingNotifications();
    return pending.where((n) {
      // Filter only medicine reminders
      if (n.payload == null) return false;
      try {
        final payload = NotificationPayload.fromJson(n.payload!);
        return payload.type == 'medicine_reminder' ||
            payload.type == 'medicine_reminder_snoozed';
      } catch (e) {
        return false;
      }
    }).length;
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_notification_service.dart';
import 'notification_scheduler.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🎯 NOTIFICATION ACTION HANDLER - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Version: 2.0.0
// Architecture: Service Layer (Clean Architecture)
// Pattern: Singleton + Observer + Replay Stream
//
// Features:
// • Navigation callback system for app integration
// • Firestore integration for dose logging
// • Snooze with configurable durations
// • Error handling with user feedback
// • Action analytics/logging
// • 🆕 ReplaySubject for late subscribers (fixes cold start issue)
// • 🆕 Pending actions queue (for actions before app ready)
// • 🆕 Idempotent action handling (prevents duplicates)
//
// Cold Start Flow Fix:
// ┌─────────────────────────────────────────────────────────────────────────┐
// │  1. User taps notification action while app is closed                  │
// │  2. App starts, NotificationActionHandler processes action             │
// │  3. Action is stored in _pendingActions queue                          │
// │  4. HomeProvider subscribes and calls processPendingActions()          │
// │  5. Pending actions are replayed to HomeProvider                       │
// │  6. UI updates correctly                                               │
// └─────────────────────────────────────────────────────────────────────────┘
//
// ═══════════════════════════════════════════════════════════════════════════════

typedef NavigationCallback = void Function(String route, Map<String, dynamic>? arguments);
typedef MessageCallback = void Function(String message, {bool isError});

@immutable
class ActionResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const ActionResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory ActionResult.success(String message, [Map<String, dynamic>? data]) =>
      ActionResult(success: true, message: message, data: data);

  factory ActionResult.failure(String message) =>
      ActionResult(success: false, message: message);
}

enum SnoozeOption {
  fiveMinutes(5, '5 دقائق'),
  tenMinutes(10, '10 دقائق'),
  fifteenMinutes(15, '15 دقيقة'),
  thirtyMinutes(30, '30 دقيقة'),
  oneHour(60, 'ساعة');

  final int minutes;
  final String label;
  
  const SnoozeOption(this.minutes, this.label);
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN HANDLER CLASS
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationActionHandler {
  // ═══════════════════════════════════════════════════════════════════════════
  // SINGLETON
  // ═══════════════════════════════════════════════════════════════════════════

  static final NotificationActionHandler _instance = NotificationActionHandler._internal();
  factory NotificationActionHandler() => _instance;
  NotificationActionHandler._internal();

  static NotificationActionHandler get instance => _instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // DEPENDENCIES
  // ═══════════════════════════════════════════════════════════════════════════

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationScheduler _scheduler = NotificationScheduler.instance;
  final LocalNotificationService _notificationService = LocalNotificationService.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // CALLBACKS
  // ═══════════════════════════════════════════════════════════════════════════

  NavigationCallback? _onNavigate;
  MessageCallback? _onMessage;
  VoidCallback? _onMedicineActionCompleted;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 REPLAY STREAM & PENDING ACTIONS - Fixes cold start issue
  // ═══════════════════════════════════════════════════════════════════════════

  final StreamController<NotificationActionEvent> _actionStreamController =
      StreamController<NotificationActionEvent>.broadcast();

  final List<NotificationActionEvent> _recentEvents = [];
  static const int _maxRecentEvents = 10;

  final List<NotificationActionEvent> _pendingActions = [];

  // 🆕 Idempotency tracking - prevents duplicate actions
  final Set<String> _processedActionIds = {};
  static const Duration _actionIdExpiry = Duration(minutes: 5);
  final Map<String, DateTime> _actionIdTimestamps = {};

  Stream<NotificationActionEvent> get actionStream => _actionStreamController.stream;

  List<NotificationActionEvent> get recentEvents => List.unmodifiable(_recentEvents);

  bool get hasPendingActions => _pendingActions.isNotEmpty;

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  void initialize({
    NavigationCallback? onNavigate,
    MessageCallback? onMessage,
    VoidCallback? onMedicineActionCompleted,
  }) {
    _onNavigate = onNavigate;
    _onMessage = onMessage;
    _onMedicineActionCompleted = onMedicineActionCompleted;
    
    debugPrint('✅ NotificationActionHandler initialized');
    
    // Process any pending actions that occurred before initialization
    _processPendingActionsInternal();
  }

  void setNavigationCallback(NavigationCallback callback) {
    _onNavigate = callback;
  }

  void setMessageCallback(MessageCallback callback) {
    _onMessage = callback;
  }
  
  void setMedicineActionCallback(VoidCallback callback) {
    _onMedicineActionCompleted = callback;
    debugPrint('✅ Medicine action callback set');
    
    // Process pending actions when callback is set
    _processPendingActionsInternal();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 PENDING ACTIONS PROCESSING
  // ═══════════════════════════════════════════════════════════════════════════

  void _processPendingActionsInternal() {
    if (_pendingActions.isEmpty) return;
    if (_onMedicineActionCompleted == null) {
      debugPrint('⏳ Pending actions waiting for callback: ${_pendingActions.length}');
      return;
    }
    
    debugPrint('🔄 Processing ${_pendingActions.length} pending actions');
    
    for (final event in _pendingActions) {
      _onMedicineActionCompleted?.call();
      debugPrint('✅ Processed pending action: ${event.type}');
    }
    
    _pendingActions.clear();
  }

  void processPendingActions() {
    _processPendingActionsInternal();
  }

  List<NotificationActionEvent> getPendingActions() {
    return List.unmodifiable(_pendingActions);
  }

  void clearPendingActions() {
    _pendingActions.clear();
    debugPrint('🧹 Cleared pending actions');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 IDEMPOTENCY CHECK - Prevents duplicate action processing
  // ═══════════════════════════════════════════════════════════════════════════

  String _generateActionId(String medicineId, String actionType, String? scheduledTime) {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}';
    return '$medicineId-$actionType-${scheduledTime ?? 'notime'}-$dateKey';
  }

  bool _isActionAlreadyProcessed(String actionId) {
    _cleanupExpiredActionIds();
    return _processedActionIds.contains(actionId);
  }

  void _markActionAsProcessed(String actionId) {
    _processedActionIds.add(actionId);
    _actionIdTimestamps[actionId] = DateTime.now();
  }

  void _cleanupExpiredActionIds() {
    final now = DateTime.now();
    final expiredIds = <String>[];
    
    _actionIdTimestamps.forEach((id, timestamp) {
      if (now.difference(timestamp) > _actionIdExpiry) {
        expiredIds.add(id);
      }
    });
    
    for (final id in expiredIds) {
      _processedActionIds.remove(id);
      _actionIdTimestamps.remove(id);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HANDLE NOTIFICATION TAP
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> handleNotificationTap(NotificationResponse response) async {
    debugPrint('📩 Handling notification tap: ${response.payload}');

    if (response.payload == null || response.payload!.isEmpty) {
      _navigateTo('/home');
      return;
    }

    try {
      final payload = NotificationPayload.fromJson(response.payload!);
      
      switch (payload.type) {
        case 'medicine_reminder':
          _handleMedicineReminderTap(payload);
          break;
        case 'health_reminder':
          _navigateTo('/health-readings');
          break;
        case 'appointment':
          _navigateTo('/appointments', {'id': payload.extra?['appointmentId']});
          break;
        default:
          _navigateTo(payload.route ?? '/home');
      }

      _emitEvent(NotificationActionEvent(
        type: NotificationActionType.tap,
        payload: payload,
        timestamp: DateTime.now(),
      ));

    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
      _navigateTo('/home');
    }
  }

  void _handleMedicineReminderTap(NotificationPayload payload) {
    if (payload.medicineId != null) {
      _navigateTo('/medicines', {
        'medicineId': payload.medicineId,
        'highlightTime': payload.scheduledTime,
      });
    } else {
      _navigateTo('/medicines');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HANDLE ACTION BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> handleNotificationAction(NotificationResponse response) async {
    debugPrint('📩 Handling notification action: ${response.actionId}');
    debugPrint('   Payload: ${response.payload}');

    if (response.payload == null || response.payload!.isEmpty) {
      debugPrint('⚠️ No payload for action');
      return;
    }

    try {
      final payload = NotificationPayload.fromJson(response.payload!);

      switch (response.actionId) {
        case NotificationActions.markTaken:
          await _handleMarkTaken(payload, response.id);
          break;
        case NotificationActions.skip:
          await _handleSkip(payload, response.id);
          break;
        case NotificationActions.snooze:
          await _handleSnooze(payload, response.id);
          break;
        case NotificationActions.view:
          _handleMedicineReminderTap(payload);
          break;
        case NotificationActions.dismiss:
          await _handleDismiss(payload, response.id);
          break;
        default:
          debugPrint('⚠️ Unknown action: ${response.actionId}');
      }

    } catch (e) {
      debugPrint('❌ Error handling notification action: $e');
      _showMessage('حدث خطأ أثناء تنفيذ الإجراء', isError: true);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MARK TAKEN - With idempotency check
  // ═══════════════════════════════════════════════════════════════════════════

  Future<ActionResult> _handleMarkTaken(NotificationPayload payload, int? notificationId) async {
    debugPrint('✅ Marking as taken: ${payload.medicineName}');

    if (payload.medicineId == null) {
      return ActionResult.failure('معرف الدواء غير موجود');
    }

    // 🆕 Idempotency check
    final actionId = _generateActionId(payload.medicineId!, 'taken', payload.scheduledTime);
    if (_isActionAlreadyProcessed(actionId)) {
      debugPrint('⚠️ Action already processed: $actionId');
      return ActionResult.success('تم التسجيل مسبقاً');
    }

    try {
      final result = await _logDose(
        medicineId: payload.medicineId!,
        scheduledTime: payload.scheduledTime,
        status: 'taken',
        takenTime: DateTime.now(),
      );

      if (!result.success) {
        _showMessage(result.message, isError: true);
        return result;
      }

      // Mark as processed
      _markActionAsProcessed(actionId);

      if (notificationId != null) {
        await _notificationService.cancelNotification(notificationId);
      }

      _showMessage('تم تسجيل تناول ${payload.medicineName ?? 'الدواء'} ✓');

      final event = NotificationActionEvent(
        type: NotificationActionType.markTaken,
        payload: payload,
        timestamp: DateTime.now(),
        success: true,
      );
      
      _emitEvent(event);
      
      // 🆕 Call callback AND add to pending if callback not ready
      _notifyMedicineActionCompleted(event);

      return ActionResult.success('تم التسجيل بنجاح');

    } catch (e) {
      debugPrint('❌ Error marking as taken: $e');
      _showMessage('فشل تسجيل الجرعة', isError: true);
      return ActionResult.failure('فشل تسجيل الجرعة: $e');
    }
  }

  Future<ActionResult> markMedicineAsTaken({
    required String medicineId,
    required String medicineName,
    String? scheduledTime,
  }) async {
    final payload = NotificationPayload(
      type: 'medicine_reminder',
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: scheduledTime,
    );

    return await _handleMarkTaken(payload, null);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SKIP - With idempotency check
  // ═══════════════════════════════════════════════════════════════════════════

  Future<ActionResult> _handleSkip(NotificationPayload payload, int? notificationId) async {
    debugPrint('⏭️ Skipping: ${payload.medicineName}');

    if (payload.medicineId == null) {
      return ActionResult.failure('معرف الدواء غير موجود');
    }

    // 🆕 Idempotency check
    final actionId = _generateActionId(payload.medicineId!, 'skipped', payload.scheduledTime);
    if (_isActionAlreadyProcessed(actionId)) {
      debugPrint('⚠️ Action already processed: $actionId');
      return ActionResult.success('تم التخطي مسبقاً');
    }

    try {
      final result = await _logDose(
        medicineId: payload.medicineId!,
        scheduledTime: payload.scheduledTime,
        status: 'skipped',
      );

      if (!result.success) {
        _showMessage(result.message, isError: true);
        return result;
      }

      // Mark as processed
      _markActionAsProcessed(actionId);

      if (notificationId != null) {
        await _notificationService.cancelNotification(notificationId);
      }

      _showMessage('تم تخطي جرعة ${payload.medicineName ?? 'الدواء'}');

      final event = NotificationActionEvent(
        type: NotificationActionType.skip,
        payload: payload,
        timestamp: DateTime.now(),
        success: true,
      );
      
      _emitEvent(event);
      
      // 🆕 Call callback AND add to pending if callback not ready
      _notifyMedicineActionCompleted(event);

      return ActionResult.success('تم التخطي');

    } catch (e) {
      debugPrint('❌ Error skipping: $e');
      _showMessage('فشل تخطي الجرعة', isError: true);
      return ActionResult.failure('فشل تخطي الجرعة: $e');
    }
  }

  Future<ActionResult> skipMedicineDose({
    required String medicineId,
    required String medicineName,
    String? scheduledTime,
    String? reason,
  }) async {
    final payload = NotificationPayload(
      type: 'medicine_reminder',
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: scheduledTime,
      extra: reason != null ? {'skipReason': reason} : null,
    );

    return await _handleSkip(payload, null);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SNOOZE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<ActionResult> _handleSnooze(NotificationPayload payload, int? notificationId, [int minutes = 15]) async {
    debugPrint('😴 Snoozing: ${payload.medicineName} for $minutes minutes');

    if (payload.medicineId == null) {
      return ActionResult.failure('معرف الدواء غير موجود');
    }

    try {
      final medicineDoc = await _getMedicineDocument(payload.medicineId!);
      if (medicineDoc == null) {
        return ActionResult.failure('الدواء غير موجود');
      }

      final medicine = SchedulableMedicine.fromFirestore(medicineDoc);

      final success = await _scheduler.snoozeMedicine(
        medicine: medicine,
        originalTime: payload.scheduledTime ?? '',
        minutes: minutes,
      );

      if (!success) {
        _showMessage('فشل تأجيل التذكير', isError: true);
        return ActionResult.failure('فشل تأجيل التذكير');
      }

      final snoozeLabel = SnoozeOption.values
          .where((o) => o.minutes == minutes)
          .firstOrNull?.label ?? '$minutes دقيقة';
      _showMessage('سيتم تذكيرك بـ ${payload.medicineName ?? 'الدواء'} بعد $snoozeLabel');

      final event = NotificationActionEvent(
        type: NotificationActionType.snooze,
        payload: payload,
        timestamp: DateTime.now(),
        success: true,
        extra: {'snoozeMinutes': minutes},
      );
      
      _emitEvent(event);
      
      // 🆕 Call callback AND add to pending if callback not ready
      _notifyMedicineActionCompleted(event);

      return ActionResult.success('تم التأجيل', {'minutes': minutes});

    } catch (e) {
      debugPrint('❌ Error snoozing: $e');
      _showMessage('فشل تأجيل التذكير', isError: true);
      return ActionResult.failure('فشل تأجيل التذكير: $e');
    }
  }

  Future<ActionResult> snoozeMedicine({
    required String medicineId,
    required String medicineName,
    String? scheduledTime,
    int minutes = 15,
  }) async {
    final payload = NotificationPayload(
      type: 'medicine_reminder',
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: scheduledTime,
    );

    return await _handleSnooze(payload, null, minutes);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DISMISS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<ActionResult> _handleDismiss(NotificationPayload payload, int? notificationId) async {
    debugPrint('🚫 Dismissing: ${payload.medicineName}');

    if (notificationId != null) {
      await _notificationService.cancelNotification(notificationId);
    }

    _emitEvent(NotificationActionEvent(
      type: NotificationActionType.dismiss,
      payload: payload,
      timestamp: DateTime.now(),
      success: true,
    ));

    return ActionResult.success('تم إغلاق الإشعار');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 UNIFIED NOTIFICATION - Handles both immediate callback and pending queue
  // ═══════════════════════════════════════════════════════════════════════════

  void _notifyMedicineActionCompleted(NotificationActionEvent event) {
    if (_onMedicineActionCompleted != null) {
      debugPrint('🔔 Calling medicine action callback immediately');
      _onMedicineActionCompleted!.call();
    } else {
      debugPrint('⏳ No callback set, adding to pending actions');
      _pendingActions.add(event);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FIRESTORE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<ActionResult> _logDose({
    required String medicineId,
    String? scheduledTime,
    required String status,
    DateTime? takenTime,
    String? notes,
  }) async {
    try {
      final medicineDoc = await _getMedicineDocument(medicineId);
      if (medicineDoc == null) {
        return ActionResult.failure('الدواء غير موجود');
      }

      final medicineData = medicineDoc.data() as Map<String, dynamic>;
      final userId = medicineData['userId'] as String?;
      final medicineName = medicineData['name'] as String? ?? 'دواء';
      
      if (userId == null) {
        return ActionResult.failure('معرف المستخدم غير موجود');
      }

      final now = DateTime.now();
      final todayString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // ═══════════════════════════════════════════════════════════════════════
      // 🔧 FIX: Save to 'medicine_logs' (same as home_repository.dart)
      // ═══════════════════════════════════════════════════════════════════════

      final existingLogInfo = await _findExistingLogWithStatus(
        userId: userId,
        medicineId: medicineId,
        date: todayString,
        scheduledTime: scheduledTime,
      );

      bool isNewAction = false;

      if (existingLogInfo != null) {
        // Check if status changed
        if (existingLogInfo.currentStatus == status) {
          debugPrint('⏭️ Action unchanged: $status for $medicineId');
          return ActionResult.success('تم التسجيل مسبقاً');
        }

        // Update existing log
        await _firestore
            .collection('medicine_logs')
            .doc(existingLogInfo.id)
            .update({
          'status': status,
          'actionTime': FieldValue.serverTimestamp(),
          if (notes != null) 'notes': notes,
        });
        
        debugPrint('🔄 Updated existing medicine log: ${existingLogInfo.id}');
      } else {
        // Create new log in medicine_logs collection
        isNewAction = true;
        
        final logData = {
          'userId': userId,
          'medicineId': medicineId,
          'status': status,
          'date': todayString,
          'scheduledTime': scheduledTime ?? '',
          'actionTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          if (notes != null) 'notes': notes,
        };

        await _firestore
            .collection('medicine_logs')
            .add(logData);
        
        debugPrint('✅ Created new medicine log: $status for $medicineId');
      }

      // Save notification only for new actions
      if (isNewAction) {
        DateTime scheduledDateTime = now;
        if (scheduledTime != null) {
          final parts = scheduledTime.split(':');
          if (parts.length >= 2) {
            scheduledDateTime = DateTime(
              now.year, now.month, now.day,
              int.tryParse(parts[0]) ?? now.hour,
              int.tryParse(parts[1]) ?? 0,
            );
          }
        }

        await _saveNotificationToFirestore(
          userId: userId,
          medicineId: medicineId,
          medicineName: medicineName,
          status: status,
          scheduledTime: scheduledDateTime,
          actionTime: takenTime ?? now,
        );
      }

      debugPrint('✅ Dose logged: $status for $medicineId');
      return ActionResult.success('تم تسجيل الجرعة');

    } catch (e) {
      debugPrint('❌ Error logging dose: $e');
      return ActionResult.failure('فشل تسجيل الجرعة: $e');
    }
  }

  // 🆕 Find existing log with status info
  Future<_ExistingLogInfo?> _findExistingLogWithStatus({
    required String userId,
    required String medicineId,
    required String date,
    String? scheduledTime,
  }) async {
    try {
      var query = _firestore
          .collection('medicine_logs')
          .where('userId', isEqualTo: userId)
          .where('medicineId', isEqualTo: medicineId)
          .where('date', isEqualTo: date);

      if (scheduledTime != null && scheduledTime.isNotEmpty) {
        query = query.where('scheduledTime', isEqualTo: scheduledTime);
      }

      final snapshot = await query.limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        return _ExistingLogInfo(
          id: doc.id,
          currentStatus: data['status'] as String?,
        );
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error finding existing log: $e');
      return null;
    }
  }

  Future<void> _saveNotificationToFirestore({
    required String userId,
    required String medicineId,
    required String medicineName,
    required String status,
    required DateTime scheduledTime,
    required DateTime actionTime,
  }) async {
    try {
      String title;
      String body;
      String type;

      switch (status) {
        case 'taken':
          title = 'تم تناول الدواء ✓';
          body = 'لقد تناولت $medicineName';
          type = 'medicine_taken';
          break;
        case 'skipped':
          title = 'تم تخطي الدواء';
          body = 'لقد تخطيت $medicineName';
          type = 'medicine_skipped';
          break;
        case 'snoozed':
          title = 'تم تأجيل الدواء';
          body = 'سيتم تذكيرك بـ $medicineName لاحقاً';
          type = 'medicine_snoozed';
          break;
        default:
          title = 'تذكير دواء';
          body = medicineName;
          type = 'medicine_reminder';
      }

      final notificationRef = _firestore.collection('notifications').doc();

      final notification = {
        'id': notificationRef.id,
        'userId': userId,
        'medicineId': medicineId,
        'medicineName': medicineName,
        'title': title,
        'body': body,
        'type': type,
        'status': status,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'actionTime': Timestamp.fromDate(actionTime),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await notificationRef.set(notification);
      debugPrint('✅ Notification saved to Firestore: $type');
    } catch (e) {
      debugPrint('⚠️ Failed to save notification to Firestore: $e');
    }
  }

  Future<DocumentSnapshot?> _getMedicineDocument(String medicineId) async {
    try {
      final docSnapshot = await _firestore
          .collection('medicines')
          .doc(medicineId)
          .get();

      if (!docSnapshot.exists) {
        debugPrint('⚠️ Medicine not found: $medicineId');
        return null;
      }

      debugPrint('✅ Medicine found: ${docSnapshot.data()?['name']}');
      return docSnapshot;
    } catch (e) {
      debugPrint('❌ Error getting medicine: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _navigateTo(String route, [Map<String, dynamic>? arguments]) {
    debugPrint('🧭 Navigating to: $route');
    _onNavigate?.call(route, arguments);
  }

  void _showMessage(String message, {bool isError = false}) {
    debugPrint(isError ? '❌ $message' : 'ℹ️ $message');
    _onMessage?.call(message, isError: isError);
  }

  void _emitEvent(NotificationActionEvent event) {
    // Add to recent events (for replay)
    _recentEvents.add(event);
    if (_recentEvents.length > _maxRecentEvents) {
      _recentEvents.removeAt(0);
    }
    
    // Emit to stream
    if (!_actionStreamController.isClosed) {
      _actionStreamController.add(event);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  void dispose() {
    _actionStreamController.close();
    _onNavigate = null;
    _onMessage = null;
    _onMedicineActionCompleted = null;
    _pendingActions.clear();
    _recentEvents.clear();
    _processedActionIds.clear();
    _actionIdTimestamps.clear();
    debugPrint('🧹 NotificationActionHandler disposed');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTION EVENT
// ═══════════════════════════════════════════════════════════════════════════════

enum NotificationActionType {
  tap,
  markTaken,
  skip,
  snooze,
  dismiss,
}

@immutable
class NotificationActionEvent {
  final NotificationActionType type;
  final NotificationPayload payload;
  final DateTime timestamp;
  final bool success;
  final Map<String, dynamic>? extra;

  const NotificationActionEvent({
    required this.type,
    required this.payload,
    required this.timestamp,
    this.success = true,
    this.extra,
  });

  @override
  String toString() => 'NotificationActionEvent(type: $type, success: $success)';
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION PAYLOAD
// ═══════════════════════════════════════════════════════════════════════════════

@immutable
class NotificationPayload {
  final String type;
  final String? medicineId;
  final String? medicineName;
  final String? scheduledTime;
  final String? route;
  final Map<String, dynamic>? extra;

  const NotificationPayload({
    required this.type,
    this.medicineId,
    this.medicineName,
    this.scheduledTime,
    this.route,
    this.extra,
  });

  factory NotificationPayload.fromJson(String json) {
    try {
      // Check if it's actual JSON (starts with {)
      if (json.trim().startsWith('{')) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          jsonDecode(json) as Map,
        );
        
        return NotificationPayload(
          type: data['type'] as String? ?? 'unknown',
          medicineId: data['medicineId'] as String?,
          medicineName: data['medicineName'] as String?,
          scheduledTime: data['scheduledTime'] as String?,
          route: data['route'] as String?,
          extra: data['extra'] as Map<String, dynamic>?,
        );
      }
      
      // Fallback: pipe-separated format (legacy)
      final parts = json.split('|');
      final Map<String, String> data = {};
      
      for (final part in parts) {
        final keyValue = part.split(':');
        if (keyValue.length >= 2) {
          data[keyValue[0]] = keyValue.sublist(1).join(':');
        }
      }

      return NotificationPayload(
        type: data['type'] ?? 'unknown',
        medicineId: data['medicineId'],
        medicineName: data['medicineName'],
        scheduledTime: data['scheduledTime'],
        route: data['route'],
      );
    } catch (e) {
      debugPrint('⚠️ Error parsing payload: $e');
      debugPrint('⚠️ Raw payload: $json');
      return const NotificationPayload(type: 'unknown');
    }
  }

  String toJson() {
    final parts = <String>['type:$type'];
    if (medicineId != null) parts.add('medicineId:$medicineId');
    if (medicineName != null) parts.add('medicineName:$medicineName');
    if (scheduledTime != null) parts.add('scheduledTime:$scheduledTime');
    if (route != null) parts.add('route:$route');
    return parts.join('|');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION ACTIONS CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationActions {
  static const String markTaken = 'MARK_TAKEN';
  static const String skip = 'SKIP';
  static const String snooze = 'SNOOZE';
  static const String view = 'VIEW';
  static const String dismiss = 'DISMISS';
}

// ═══════════════════════════════════════════════════════════════════════════════
// EXISTING LOG INFO - Helper class for checking duplicates
// ═══════════════════════════════════════════════════════════════════════════════

class _ExistingLogInfo {
  final String id;
  final String? currentStatus;

  const _ExistingLogInfo({
    required this.id,
    this.currentStatus,
  });
}

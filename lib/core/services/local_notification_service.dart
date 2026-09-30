import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔔 LOCAL NOTIFICATION SERVICE - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Features:
// • Android Notification Channels (critical, medicine, general)
// • iOS Notification Categories with actions
// • Scheduled notifications with timezone support
// • Notification tap handling with navigation
// • Settings-aware (respects user preferences)
// • Singleton pattern for global access
//
// Architecture: Service Layer (Clean Architecture)
// Pattern: Singleton + Observer
//
// ═══════════════════════════════════════════════════════════════════════════════

/// Callback type for handling notification taps
typedef NotificationTapCallback = void Function(NotificationResponse response);

/// Notification channel types for Android
enum NotificationChannel {
  medicine,
  health,
  general,
  critical,
}

/// Extension for NotificationChannel properties
extension NotificationChannelExtension on NotificationChannel {
  String get id {
    switch (this) {
      case NotificationChannel.medicine:
        return 'medicine_reminders';
      case NotificationChannel.health:
        return 'health_readings';
      case NotificationChannel.general:
        return 'general_notifications';
      case NotificationChannel.critical:
        return 'critical_alerts';
    }
  }

  String get name {
    switch (this) {
      case NotificationChannel.medicine:
        return 'تذكيرات الأدوية';
      case NotificationChannel.health:
        return 'القراءات الصحية';
      case NotificationChannel.general:
        return 'إشعارات عامة';
      case NotificationChannel.critical:
        return 'تنبيهات مهمة';
    }
  }

  String get description {
    switch (this) {
      case NotificationChannel.medicine:
        return 'تذكيرات مواعيد تناول الأدوية';
      case NotificationChannel.health:
        return 'تذكيرات لتسجيل القراءات الصحية';
      case NotificationChannel.general:
        return 'إشعارات ونصائح صحية';
      case NotificationChannel.critical:
        return 'تنبيهات مهمة تتطلب انتباهك الفوري';
    }
  }

  Importance get importance {
    switch (this) {
      case NotificationChannel.critical:
        return Importance.max;
      case NotificationChannel.medicine:
        return Importance.high;
      case NotificationChannel.health:
        return Importance.defaultImportance;
      case NotificationChannel.general:
        return Importance.low;
    }
  }

  Priority get priority {
    switch (this) {
      case NotificationChannel.critical:
        return Priority.max;
      case NotificationChannel.medicine:
        return Priority.high;
      case NotificationChannel.health:
        return Priority.defaultPriority;
      case NotificationChannel.general:
        return Priority.low;
    }
  }

  String get settingsKey {
    switch (this) {
      case NotificationChannel.medicine:
        return 'notif_medicine';
      case NotificationChannel.health:
        return 'notif_readings';
      case NotificationChannel.general:
        return 'notif_health_tips';
      case NotificationChannel.critical:
        return 'notif_medicine'; // Critical always follows medicine settings
    }
  }
}

/// Notification action identifiers
class NotificationActions {
  static const String markTaken = 'MARK_TAKEN';
  static const String skip = 'SKIP';
  static const String snooze = 'SNOOZE';
  static const String view = 'VIEW';
  static const String dismiss = 'DISMISS';
}

/// Notification payload data structure
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

  factory NotificationPayload.fromJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return NotificationPayload(
        type: map['type'] as String? ?? 'unknown',
        medicineId: map['medicineId'] as String?,
        medicineName: map['medicineName'] as String?,
        scheduledTime: map['scheduledTime'] as String?,
        route: map['route'] as String?,
        extra: map['extra'] as Map<String, dynamic>?,
      );
    } catch (e) {
      debugPrint('❌ Error parsing notification payload: $e');
      return const NotificationPayload(type: 'unknown');
    }
  }

  String toJson() {
    return jsonEncode({
      'type': type,
      if (medicineId != null) 'medicineId': medicineId,
      if (medicineName != null) 'medicineName': medicineName,
      if (scheduledTime != null) 'scheduledTime': scheduledTime,
      if (route != null) 'route': route,
      if (extra != null) 'extra': extra,
    });
  }
}

/// Main Local Notification Service
class LocalNotificationService {
  // ═══════════════════════════════════════════════════════════════════════════
  // SINGLETON
  // ═══════════════════════════════════════════════════════════════════════════

  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  static LocalNotificationService get instance => _instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROPERTIES
  // ═══════════════════════════════════════════════════════════════════════════

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  NotificationTapCallback? _onNotificationTap;
  NotificationTapCallback? _onNotificationAction;

  /// Stream controller for notification events
  final StreamController<NotificationResponse> _notificationStreamController =
      StreamController<NotificationResponse>.broadcast();

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  bool get isInitialized => _isInitialized;
  FlutterLocalNotificationsPlugin get plugin => _plugin;
  Stream<NotificationResponse> get notificationStream => _notificationStreamController.stream;

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Initialize the notification service
  /// Must be called before any other methods
  Future<bool> initialize({
    NotificationTapCallback? onNotificationTap,
    NotificationTapCallback? onNotificationAction,
  }) async {
    if (_isInitialized) {
      debugPrint('⚠️ LocalNotificationService already initialized');
      return true;
    }

    try {
      debugPrint('🔔 Initializing LocalNotificationService...');

      _onNotificationTap = onNotificationTap;
      _onNotificationAction = onNotificationAction;

      // Note: Timezone must be initialized in main.dart before this service
      // Call tz_data.initializeTimeZones() in main() before LocalNotificationService.initialize()

      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      final darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: _buildIOSCategories(),
      );

      // Combined settings
      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      // Initialize plugin
      final initialized = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _backgroundNotificationHandler,
      );

      if (initialized != true) {
        debugPrint('⚠️ Plugin initialization returned false');
      }

      // Create Android notification channels
      await _createAndroidChannels();

      // Check for notification that launched the app
      await _checkLaunchNotification();

      _isInitialized = true;
      debugPrint('✅ LocalNotificationService initialized successfully');
      return true;
    } catch (e, stack) {
      debugPrint('❌ Error initializing LocalNotificationService: $e');
      debugPrint('📍 Stack: $stack');
      return false;
    }
  }

  /// Build iOS notification categories with actions
  List<DarwinNotificationCategory> _buildIOSCategories() {
    return [
      DarwinNotificationCategory(
        'medicine_reminder',
        actions: [
          DarwinNotificationAction.plain(
            NotificationActions.markTaken,
            'تم تناوله ✓',
            options: {DarwinNotificationActionOption.foreground},
          ),
          DarwinNotificationAction.plain(
            NotificationActions.skip,
            'تخطي',
          ),
          DarwinNotificationAction.plain(
            NotificationActions.snooze,
            'تذكيري لاحقاً',
          ),
        ],
        options: {
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
      DarwinNotificationCategory(
        'health_reminder',
        actions: [
          DarwinNotificationAction.plain(
            NotificationActions.view,
            'عرض',
            options: {DarwinNotificationActionOption.foreground},
          ),
          DarwinNotificationAction.plain(
            NotificationActions.dismiss,
            'إغلاق',
          ),
        ],
      ),
    ];
  }

  /// Create Android notification channels
  Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    for (final channel in NotificationChannel.values) {
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          channel.id,
          channel.name,
          description: channel.description,
          importance: channel.importance,
          enableLights: true,
          ledColor: const Color(0xFF2196F3),
          enableVibration: true,
          playSound: true,
        ),
      );
      debugPrint('📢 Created Android channel: ${channel.id}');
    }
  }

  /// Check if app was launched from notification
  Future<void> _checkLaunchNotification() async {
    try {
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();

      if (launchDetails?.didNotificationLaunchApp == true &&
          launchDetails?.notificationResponse != null) {
        debugPrint('🚀 App launched from notification');
        _handleNotificationResponse(launchDetails!.notificationResponse!);
      }
    } catch (e) {
      debugPrint('❌ Error checking launch notification: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Handle notification tap or action
  void _handleNotificationResponse(NotificationResponse response) {
    debugPrint('📩 Notification response received');
    debugPrint('   ID: ${response.id}');
    debugPrint('   Action: ${response.actionId}');
    debugPrint('   Payload: ${response.payload}');

    // Add to stream
    _notificationStreamController.add(response);

    // Handle based on notification type
    if (response.actionId != null && response.actionId!.isNotEmpty) {
      // Action button was pressed
      _onNotificationAction?.call(response);
    } else {
      // Notification was tapped
      _onNotificationTap?.call(response);
    }
  }

  /// Background notification handler (must be top-level)
  @pragma('vm:entry-point')
  static void _backgroundNotificationHandler(NotificationResponse response) {
    debugPrint('📩 Background notification: ${response.payload}');
    // Background handling is limited - usually just logging
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PERMISSIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Request notification permissions (including exact alarms for Android 12+)
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        
        // 1. Request standard notification permission
        final notificationGranted = await androidPlugin?.requestNotificationsPermission();
        debugPrint('📢 Notification permission: ${notificationGranted ?? false}');
        
        // 2. Request exact alarms permission (Android 12+)
        // This is CRITICAL for scheduled notifications to work!
        final exactAlarmGranted = await requestExactAlarmsPermission();
        debugPrint('⏰ Exact alarm permission: $exactAlarmGranted');
        
        return (notificationGranted ?? false) && exactAlarmGranted;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Request exact alarms permission for Android 12+ (API 31+)
  /// 
  /// Starting from Android 12, apps need SCHEDULE_EXACT_ALARM permission
  /// to schedule notifications at exact times. On Android 13+, this
  /// permission is denied by default and must be granted by the user.
  /// 
  /// Returns true if:
  /// - Platform is not Android
  /// - Android version < 12 (doesn't need permission)
  /// - Permission is already granted
  /// - User grants permission
  Future<bool> requestExactAlarmsPermission() async {
    try {
      if (!Platform.isAndroid) return true;
      
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin == null) {
        debugPrint('⚠️ Android plugin not available');
        return false;
      }
      
      // Check if exact alarms are already permitted
      final canSchedule = await androidPlugin.canScheduleExactNotifications();
      debugPrint('🔍 Can schedule exact alarms: ${canSchedule ?? false}');
      
      if (canSchedule == true) {
        debugPrint('✅ Exact alarm permission already granted');
        return true;
      }
      
      // Request the permission - this opens system settings on Android 12+
      debugPrint('📝 Requesting exact alarm permission...');
      final granted = await androidPlugin.requestExactAlarmsPermission();
      
      if (granted == true) {
        debugPrint('✅ Exact alarm permission granted by user');
        return true;
      } else {
        debugPrint('⚠️ Exact alarm permission denied - scheduled notifications may not work');
        debugPrint('💡 User can enable this in: Settings > Apps > [App Name] > Alarms & reminders');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error requesting exact alarm permission: $e');
      // Don't fail completely - inexact alarms might still work
      return false;
    }
  }

  /// Check if exact alarms are permitted
  Future<bool> canScheduleExactAlarms() async {
    try {
      if (!Platform.isAndroid) return true;
      
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      return await androidPlugin?.canScheduleExactNotifications() ?? false;
    } catch (e) {
      debugPrint('❌ Error checking exact alarm permission: $e');
      return false;
    }
  }

  /// Check if notifications are permitted
  Future<bool> hasPermissions() async {
    try {
      if (Platform.isIOS) {
        // iOS doesn't have a direct check - assume granted if initialized
        return true;
      }

      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.areNotificationsEnabled() ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error checking permissions: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SETTINGS INTEGRATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if notifications are enabled for a channel
  Future<bool> isChannelEnabled(NotificationChannel channel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(channel.settingsKey) ?? true;
    } catch (e) {
      debugPrint('❌ Error checking channel settings: $e');
      return true;
    }
  }

  /// Check if sound is enabled
  Future<bool> isSoundEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notif_sound') ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Check if vibration is enabled
  Future<bool> isVibrationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notif_vibration') ?? true;
    } catch (e) {
      return true;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SHOW NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Show an immediate notification
  Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    NotificationChannel channel = NotificationChannel.general,
    NotificationPayload? payload,
    bool checkSettings = true,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ LocalNotificationService not initialized');
      return false;
    }

    // Check if channel is enabled
    if (checkSettings && !await isChannelEnabled(channel)) {
      debugPrint('ℹ️ Notifications disabled for channel: ${channel.id}');
      return false;
    }

    try {
      final soundEnabled = await isSoundEnabled();
      final vibrationEnabled = await isVibrationEnabled();

      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: channel.priority,
        playSound: soundEnabled,
        enableVibration: vibrationEnabled,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(body),
        category: channel == NotificationChannel.medicine
            ? AndroidNotificationCategory.reminder
            : AndroidNotificationCategory.message,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled,
        categoryIdentifier: channel == NotificationChannel.medicine
            ? 'medicine_reminder'
            : 'health_reminder',
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        id,
        title,
        body,
        details,
        payload: payload?.toJson(),
      );

      debugPrint('✅ Notification shown: $title');
      return true;
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEDULE NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Schedule a notification for a specific time
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    NotificationChannel channel = NotificationChannel.medicine,
    NotificationPayload? payload,
    bool checkSettings = true,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ LocalNotificationService not initialized');
      return false;
    }

    // Don't schedule for past times
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ Cannot schedule notification in the past');
      return false;
    }

    // Check if channel is enabled
    if (checkSettings && !await isChannelEnabled(channel)) {
      debugPrint('ℹ️ Notifications disabled for channel: ${channel.id}');
      return false;
    }

    try {
      final soundEnabled = await isSoundEnabled();
      final vibrationEnabled = await isVibrationEnabled();

      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: channel.priority,
        playSound: soundEnabled,
        enableVibration: vibrationEnabled,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(body),
        actions: channel == NotificationChannel.medicine
            ? [
                const AndroidNotificationAction(
                  NotificationActions.markTaken,
                  'تم تناوله ✓',
                  showsUserInterface: true,
                ),
                const AndroidNotificationAction(
                  NotificationActions.skip,
                  'تخطي',
                ),
                const AndroidNotificationAction(
                  NotificationActions.snooze,
                  'لاحقاً',
                ),
              ]
            : null,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled,
        categoryIdentifier: channel == NotificationChannel.medicine
            ? 'medicine_reminder'
            : 'health_reminder',
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // Determine the best schedule mode based on permissions
      AndroidScheduleMode scheduleMode;
      
      if (Platform.isAndroid) {
        final canUseExact = await canScheduleExactAlarms();
        if (canUseExact) {
          scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
          debugPrint('📅 Using exact alarm mode');
        } else {
          // Fallback to inexact if permission not granted
          scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
          debugPrint('⚠️ Using inexact alarm mode (exact permission not granted)');
          debugPrint('💡 Enable in: Settings > Apps > [App] > Alarms & reminders');
        }
      } else {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload?.toJson(),
      );

      debugPrint('✅ Notification scheduled: $title at $scheduledTime');
      return true;
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
      
      // Log helpful message for exact alarm errors
      if (e.toString().contains('exact_alarms_not_permitted')) {
        debugPrint('⚠️ Exact alarms not permitted');
        debugPrint('💡 User can enable in: Settings > Apps > [App Name] > Alarms & reminders');
      }
      
      return false;
    }
  }

  /// Schedule a daily repeating notification
  Future<bool> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    NotificationChannel channel = NotificationChannel.medicine,
    NotificationPayload? payload,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ LocalNotificationService not initialized');
      return false;
    }

    try {
      final soundEnabled = await isSoundEnabled();
      final vibrationEnabled = await isVibrationEnabled();

      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: channel.priority,
        playSound: soundEnabled,
        enableVibration: vibrationEnabled,
        icon: '@mipmap/ic_launcher',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Determine the best schedule mode based on permissions
      AndroidScheduleMode scheduleMode;
      
      if (Platform.isAndroid) {
        final canUseExact = await canScheduleExactAlarms();
        scheduleMode = canUseExact 
            ? AndroidScheduleMode.exactAllowWhileIdle 
            : AndroidScheduleMode.inexactAllowWhileIdle;
      } else {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload?.toJson(),
      );

      debugPrint('✅ Daily notification scheduled: $title at $hour:$minute');
      return true;
    } catch (e) {
      debugPrint('❌ Error scheduling daily notification: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CANCEL NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      debugPrint('✅ Notification cancelled: $id');
    } catch (e) {
      debugPrint('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel multiple notifications
  Future<void> cancelNotifications(List<int> ids) async {
    for (final id in ids) {
      await cancelNotification(id);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PENDING NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Check if a notification is scheduled
  Future<bool> isNotificationScheduled(int id) async {
    final pending = await getPendingNotifications();
    return pending.any((n) => n.id == id);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BADGE (iOS)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Set app badge number (iOS only)
  Future<void> setBadgeCount(int count) async {
    if (!Platform.isIOS) return;

    try {
      // Badge is managed through notifications on iOS
      // This is typically done through backend push notifications
      debugPrint('ℹ️ Badge count: $count');
    } catch (e) {
      debugPrint('❌ Error setting badge: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Dispose resources
  void dispose() {
    _notificationStreamController.close();
    _isInitialized = false;
    debugPrint('🧹 LocalNotificationService disposed');
  }
}

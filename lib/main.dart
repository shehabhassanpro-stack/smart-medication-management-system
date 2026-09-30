import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'app.dart';
import 'services/notification_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/medicine_reminder_service.dart';
import 'core/services/notification_action_handler.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/device_security_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🏥 MEDICAL CARE APP - Main Entry Point
// ═══════════════════════════════════════════════════════════════════════════════
//
// Initialization Order (Critical - Do Not Change):
// 1. Flutter Bindings
// 2. Firebase (Core, Messaging, Crashlytics)
// 3. Timezone (for scheduled notifications)
// 4. Local Notifications (medicine reminders)
// 5. Notification Action Handler (processes notification interactions)
// 6. Medicine Reminder Service
// 7. FCM Notifications (push notifications)
// 8. System UI Configuration
//
// Notification Flow:
// ┌─────────────────────────────────────────────────────────────────────────┐
// │  User taps notification/action                                          │
// │         │                                                               │
// │         ▼                                                               │
// │  LocalNotificationService (receives response)                           │
// │         │                                                               │
// │         ▼                                                               │
// │  NotificationActionHandler (processes action, logs dose, etc.)          │
// │         │                                                               │
// │         ▼                                                               │
// │  app.dart (receives navigation/message callbacks)                       │
// │         │                                                               │
// │         ▼                                                               │
// │  AppRouter.go() (navigates to screen)                                   │
// └─────────────────────────────────────────────────────────────────────────┘
//
// ═══════════════════════════════════════════════════════════════════════════════

/// FCM Background Message Handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📬 Background FCM message: ${message.notification?.title}');
}

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      // Ensure Flutter is ready
      WidgetsFlutterBinding.ensureInitialized();
      
      // Initialize all services
      await _initializeApp();
      
      // Setup error handling
      _setupErrorHandling();
      
      // Run the app
      runApp(const MedicalCareApp());
    },
    (error, stackTrace) {
      debugPrint('❌ Uncaught error: $error');
      debugPrint('📍 Stack trace: $stackTrace');
      
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      }
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERROR HANDLING
// ═══════════════════════════════════════════════════════════════════════════════

void _setupErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('❌ Flutter error: ${details.exception}');
    debugPrint('📍 Stack: ${details.stack}');
    
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('❌ Platform error: $error');
    
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    
    return true;
  };
}

// ═══════════════════════════════════════════════════════════════════════════════
// APP INITIALIZATION
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _initializeApp() async {
  // 1. Firebase (must be first)
  await _initializeFirebase();
  
  // 2. Connectivity monitoring
  await _initializeConnectivity();
  
  // 3. Device security check
  await _initializeDeviceSecurity();
  
  // 4. Timezone (required for scheduled notifications)
  await _initializeTimezone();
  
  // 5. Local Notifications (medicine reminders)
  await _initializeLocalNotifications();
  
  // 6. Medicine Reminder Service
  await _initializeMedicineReminders();
  
  // 7. FCM Notifications (push notifications)
  await _initializeFCMNotifications();
  
  // 8. System UI
  await _configureSystemUI();
  
  debugPrint('═══════════════════════════════════════════');
  debugPrint('✅ All services initialized successfully');
  debugPrint('═══════════════════════════════════════════');
}

// ═══════════════════════════════════════════════════════════════════════════════
// FIREBASE
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    
    // Configure Firestore offline persistence (100MB cache)
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 104857600, // 100MB
    );
    
    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Setup Crashlytics (only in release mode)
    if (!kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    }
    
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    debugPrint('❌ Firebase init failed: $e');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONNECTIVITY MONITORING
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _initializeConnectivity() async {
  try {
    await ConnectivityService.instance.initialize();
    debugPrint('✅ Connectivity monitoring initialized');
  } catch (e) {
    debugPrint('⚠️ Connectivity init failed: $e');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEVICE SECURITY
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _initializeDeviceSecurity() async {
  try {
    await DeviceSecurityService.instance.checkDeviceSecurity();
    if (DeviceSecurityService.instance.isCompromised) {
      debugPrint('⚠️ WARNING: Device integrity compromised — offline cache disabled');
    }
  } catch (e) {
    debugPrint('⚠️ Device security check failed: $e');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TIMEZONE
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _initializeTimezone() async {
  try {
    tz_data.initializeTimeZones();
    debugPrint('✅ Timezone initialized');
  } catch (e) {
    debugPrint('⚠️ Timezone init failed: $e');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOCAL NOTIFICATIONS - With Action Handler Integration
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _initializeLocalNotifications() async {
  try {
    // Initialize local notification service with callbacks
    final success = await LocalNotificationService.instance.initialize(
      onNotificationTap: _handleNotificationTap,
      onNotificationAction: _handleNotificationAction,
    );
    
    if (success) {
      // Request permissions
      final hasPermission = await LocalNotificationService.instance.requestPermissions();
      debugPrint('✅ Local notifications initialized (permission: $hasPermission)');
    } else {
      debugPrint('⚠️ Local notifications init returned false');
    }
  } catch (e) {
    debugPrint('⚠️ Local notifications failed: $e');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MEDICINE REMINDERS
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _initializeMedicineReminders() async {
  try {
    final success = await MedicineReminderService.instance.initialize();
    
    if (success) {
      debugPrint('✅ Medicine reminder service initialized');
    } else {
      debugPrint('⚠️ Medicine reminder service init returned false');
    }
  } catch (e) {
    debugPrint('⚠️ Medicine reminder service failed: $e');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FCM NOTIFICATIONS
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _initializeFCMNotifications() async {
  try {
    await NotificationService().initialize();
    debugPrint('✅ FCM notifications initialized');
  } catch (e) {
    debugPrint('⚠️ FCM notifications failed: $e');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SYSTEM UI
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _configureSystemUI() async {
  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  
  debugPrint('✅ System UI configured');
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATION HANDLERS - Bridging to NotificationActionHandler
// ═══════════════════════════════════════════════════════════════════════════════

/// Handle notification tap (when user taps the notification body)
/// 
/// This is called by LocalNotificationService when user taps a notification.
/// We forward it to NotificationActionHandler which handles:
/// - Parsing the payload
/// - Determining the route
/// - Calling the navigation callback (set by app.dart)
void _handleNotificationTap(NotificationResponse response) {
  debugPrint('📩 [main.dart] Notification tapped');
  debugPrint('   ID: ${response.id}');
  debugPrint('   Payload: ${response.payload}');
  
  // Forward to the action handler
  NotificationActionHandler.instance.handleNotificationTap(response);
}

/// Handle notification action (when user taps an action button)
/// 
/// This is called by LocalNotificationService when user taps an action button.
/// We forward it to NotificationActionHandler which handles:
/// - Parsing the action (MARK_TAKEN, SKIP, SNOOZE)
/// - Logging dose to Firestore
/// - Showing feedback message
/// - Cancelling/rescheduling notifications
void _handleNotificationAction(NotificationResponse response) {
  debugPrint('📩 [main.dart] Notification action');
  debugPrint('   ID: ${response.id}');
  debugPrint('   Action: ${response.actionId}');
  debugPrint('   Payload: ${response.payload}');
  
  // Forward to the action handler
  NotificationActionHandler.instance.handleNotificationAction(response);
}

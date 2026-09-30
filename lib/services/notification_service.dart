import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

/// ═══════════════════════════════════════════════════════════════
/// NOTIFICATION SERVICE - Firebase Cloud Messaging 🔥
/// ═══════════════════════════════════════════════════════════════
/// Modern, Clean, Firebase-based Notification System
/// Zero local dependencies, 100% Cloud-powered!
/// ═══════════════════════════════════════════════════════════════

class NotificationService {
  // ══════════════════════════════════════════════════════════════
  // Singleton Pattern
  // ══════════════════════════════════════════════════════════════
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ══════════════════════════════════════════════════════════════
  // Firebase Messaging Instance
  // ══════════════════════════════════════════════════════════════
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _isInitialized = false;
  String? _fcmToken;

  // ══════════════════════════════════════════════════════════════
  // Getters
  // ══════════════════════════════════════════════════════════════
  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  // ══════════════════════════════════════════════════════════════
  // ✅ Initialize Firebase Cloud Messaging
  // ══════════════════════════════════════════════════════════════
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ NotificationService already initialized');
      return;
    }

    try {
      debugPrint('🔔 Initializing Firebase Cloud Messaging...');

      // ✅ Request permissions (iOS & Android 13+)
      final permitted = await requestPermissions();

      if (!permitted) {
        debugPrint('⚠️ Notification permissions denied');
        // نستمر رغم الرفض (المستخدم يقدر يفعلها لاحقاً)
      }

      // ✅ Get FCM Token
      await _getFCMToken();

      // ✅ Setup message handlers
      _setupMessageHandlers();

      // ✅ Setup token refresh listener
      _setupTokenRefreshListener();

      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');
      debugPrint('📱 FCM Token: $_fcmToken');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
      // لا نرمي Exception عشان ما نوقفش التطبيق
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Request Notification Permissions
  // ══════════════════════════════════════════════════════════════
  Future<bool> requestPermissions() async {
    try {
      debugPrint('🔔 Requesting notification permissions...');

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      final granted = settings.authorizationStatus == AuthorizationStatus.authorized;

      debugPrint(granted
          ? '✅ Notification permissions granted'
          : '⚠️ Notification permissions denied'
      );

      return granted;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Get FCM Token
  // ══════════════════════════════════════════════════════════════
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();

      if (_fcmToken != null) {
        debugPrint('✅ FCM Token retrieved successfully');
        // TODO: أرسل الـ Token للـ Backend لحفظه
        // await _sendTokenToBackend(_fcmToken!);
      } else {
        debugPrint('⚠️ FCM Token is null');
      }

      return _fcmToken;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Setup Message Handlers
  // ══════════════════════════════════════════════════════════════
  void _setupMessageHandlers() {
    // ✅ Handler للإشعارات عندما التطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground message received!');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      // TODO: اعرض Notification داخل التطبيق (Custom UI)
      _showInAppNotification(message);
    });

    // ✅ Handler عند الضغط على الإشعار (التطبيق مغلق أو في Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📩 Notification tapped!');
      debugPrint('Data: ${message.data}');

      // TODO: Navigate للصفحة المناسبة
      _handleNotificationTap(message);
    });

    // ✅ Handler للإشعار اللي فتح التطبيق (من حالة Terminated)
    _checkInitialMessage();
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Check Initial Message (التطبيق كان مغلق)
  // ══════════════════════════════════════════════════════════════
  Future<void> _checkInitialMessage() async {
    try {
      final message = await _messaging.getInitialMessage();

      if (message != null) {
        debugPrint('📩 App opened from notification!');
        debugPrint('Data: ${message.data}');

        // TODO: Navigate للصفحة المناسبة
        _handleNotificationTap(message);
      }
    } catch (e) {
      debugPrint('❌ Error checking initial message: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Setup Token Refresh Listener
  // ══════════════════════════════════════════════════════════════
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed');
      debugPrint('📱 New Token: $newToken');

      _fcmToken = newToken;

      // TODO: أرسل الـ Token الجديد للـ Backend
      // await _sendTokenToBackend(newToken);
    });
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Show In-App Notification (Custom UI)
  // ══════════════════════════════════════════════════════════════
  void _showInAppNotification(RemoteMessage message) {
    // TODO: اعرض Custom Notification داخل التطبيق
    // يمكن استخدام SnackBar أو Custom Widget

    debugPrint('🔔 Showing in-app notification...');
    // Example:
    // showTopSnackBar(
    //   title: message.notification?.title ?? '',
    //   body: message.notification?.body ?? '',
    // );
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Handle Notification Tap
  // ══════════════════════════════════════════════════════════════
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('👆 Handling notification tap...');

    // TODO: Navigate حسب نوع الإشعار
    // مثلاً:
    // if (message.data['type'] == 'medicine_reminder') {
    //   navigateToMedicineScreen(message.data['medicine_id']);
    // }
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Subscribe to Topic (للإشعارات الجماعية)
  // ══════════════════════════════════════════════════════════════
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Unsubscribe from Topic
  // ══════════════════════════════════════════════════════════════
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Check if Permissions are Granted
  // ══════════════════════════════════════════════════════════════
  Future<bool> hasPermissions() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('❌ Error checking permissions: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Open App Settings (للأذونات)
  // ══════════════════════════════════════════════════════════════
  Future<void> openAppSettings() async {
    try {
      if (Platform.isIOS) {
        debugPrint('📱 Open iOS app settings');
        // على iOS، المستخدم لازم يفتح Settings يدوياً
      } else if (Platform.isAndroid) {
        debugPrint('📱 Open Android app settings');
        // على Android، نقدر نفتح Settings
        // TODO: استخدم package مثل app_settings
      }
    } catch (e) {
      debugPrint('❌ Error opening settings: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Delete FCM Token (عند Logout)
  // ══════════════════════════════════════════════════════════════
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('✅ FCM Token deleted');

      // TODO: امسح الـ Token من الـ Backend
      // await _deleteTokenFromBackend();
    } catch (e) {
      debugPrint('❌ Error deleting token: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // 🔮 TODO: Backend Integration Functions
  // ══════════════════════════════════════════════════════════════

  /// Send token to backend when received/refreshed
  Future<void> _sendTokenToBackend(String token) async {
    // TODO: API call لحفظ الـ Token في الـ Backend
    debugPrint('📤 TODO: Send token to backend: $token');
  }

  /// Delete token from backend on logout
  Future<void> _deleteTokenFromBackend() async {
    // TODO: API call لمسح الـ Token من الـ Backend
    debugPrint('🗑️ TODO: Delete token from backend');
  }

  // ══════════════════════════════════════════════════════════════
  // ✅ Test Notification (For Development)
  // ══════════════════════════════════════════════════════════════
  Future<void> sendTestNotification() async {
    debugPrint('🧪 Test notification feature not available in FCM');
    debugPrint('💡 Use Firebase Console to send test notifications');
    debugPrint('📱 Your FCM Token: $_fcmToken');
  }
}

// ══════════════════════════════════════════════════════════════
// 🔥 Background Message Handler (Top-level function)
// ══════════════════════════════════════════════════════════════
/// يجب أن تكون Top-level function (خارج الـ Class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Background message received!');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');

  // TODO: Handle background notification
  // مثلاً: Update local database, show notification, etc.
}
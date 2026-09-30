import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/app_theme.dart';
import 'core/app_colors.dart';
import 'core/config/app_router.dart';
import 'core/services/notification_action_handler.dart';
import 'core/widgets/offline_auth_gate.dart';
import 'core/widgets/offline_banner.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🏥 MEDICAL CARE APP - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Version: 2.0.0
//
// Features:
// • Local notification tap handling (medicine reminders)
// • Local notification action buttons (Mark Taken, Skip, Snooze)
// • FCM push notifications (server-side)
// • Unified navigation from all notification sources
// • App lifecycle management for notification rescheduling
// • 🆕 Pending actions processing on app resume
// • 🆕 Home screen refresh trigger from notifications
// • 🆕 Global refresh callback for external notification actions
//
// Cold Start Fix:
// ┌─────────────────────────────────────────────────────────────────────────┐
// │  1. User taps notification action while app is closed                  │
// │  2. NotificationActionHandler processes action, stores in pending      │
// │  3. App starts, _setupLocalNotificationHandler() called                │
// │  4. Pending actions are processed                                      │
// │  5. _onAppResumed() triggers refresh if needed                        │
// └─────────────────────────────────────────────────────────────────────────┘
//
// ═══════════════════════════════════════════════════════════════════════════════

class MedicalCareApp extends StatefulWidget {
  const MedicalCareApp({super.key});

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = 
      GlobalKey<ScaffoldMessengerState>();
  
  static final GlobalKey<NavigatorState> navigatorKey = 
      GlobalKey<NavigatorState>();

  // 🆕 Global callback for triggering home refresh
  static VoidCallback? onHomeRefreshNeeded;

  /// Show a snackbar message globally
  static void showSnackBar(String message, {bool isError = false}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 🆕 Trigger home screen refresh from anywhere
  static void triggerHomeRefresh() {
    debugPrint('🔄 MedicalCareApp: Triggering home refresh');
    onHomeRefreshNeeded?.call();
  }

  @override
  State<MedicalCareApp> createState() => _MedicalCareAppState();
}

class _MedicalCareAppState extends State<MedicalCareApp> with WidgetsBindingObserver {
  late final AuthProvider _authProvider;
  late final AppRouter _appRouter;

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION SERVICES
  // ═══════════════════════════════════════════════════════════════════════════
  
  final NotificationActionHandler _notificationActionHandler = 
      NotificationActionHandler.instance;

  // 🆕 Track if we need to refresh on resume
  bool _needsRefreshOnResume = false;
  
  // 🆕 Stream subscription for action events
  StreamSubscription<NotificationActionEvent>? _actionStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authProvider = AuthProvider();
    _appRouter = AppRouter(authProvider: _authProvider);
    
    // Setup notification handlers
    _setupFCMForegroundHandler();
    _setupLocalNotificationHandler();
    
    // 🆕 Check for pending actions after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPendingNotificationActions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _actionStreamSubscription?.cancel();
    _authProvider.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APP LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 App resumed');
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        debugPrint('📱 App inactive');
        break;
      case AppLifecycleState.paused:
        debugPrint('📱 App paused');
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        debugPrint('📱 App detached');
        break;
      case AppLifecycleState.hidden:
        debugPrint('📱 App hidden');
        break;
    }
  }

  /// 🔧 UPDATED: Handle app resume with refresh trigger
  void _onAppResumed() {
    debugPrint('🔄 App resumed - checking for pending actions');
    
    // Process any pending notification actions
    _processPendingNotificationActions();
    
    // Trigger refresh if needed
    if (_needsRefreshOnResume) {
      _needsRefreshOnResume = false;
      debugPrint('🔄 Triggering deferred home refresh');
      
      // Delay slightly to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 300), () {
        MedicalCareApp.triggerHomeRefresh();
      });
    }
  }

  /// 🆕 Handle app paused
  void _onAppPaused() {
    debugPrint('📱 App paused - will check for updates on resume');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 PENDING ACTIONS PROCESSING
  // ═══════════════════════════════════════════════════════════════════════════

  void _processPendingNotificationActions() {
    if (_notificationActionHandler.hasPendingActions) {
      debugPrint('🔔 Processing ${_notificationActionHandler.getPendingActions().length} pending actions');
      _notificationActionHandler.processPendingActions();
      
      // Trigger refresh after processing
      Future.delayed(const Duration(milliseconds: 500), () {
        MedicalCareApp.triggerHomeRefresh();
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCAL NOTIFICATION HANDLER - UPDATED
  // ═══════════════════════════════════════════════════════════════════════════

  void _setupLocalNotificationHandler() {
    debugPrint('🔔 Setting up local notification handler');
    
    _notificationActionHandler.initialize(
      onNavigate: _handleLocalNotificationNavigation,
      onMessage: _handleNotificationMessage,
      onMedicineActionCompleted: _handleMedicineActionCompleted,
    );

    // 🆕 Listen to action events for UI updates
    _actionStreamSubscription = _notificationActionHandler.actionStream.listen(
      (event) {
        debugPrint('📩 App received notification action event: ${event.type}');
        
        // If action was successful, trigger refresh
        if (event.success && 
            (event.type == NotificationActionType.markTaken ||
             event.type == NotificationActionType.skip ||
             event.type == NotificationActionType.snooze)) {
          _handleMedicineActionCompleted();
        }
      },
      onError: (error) {
        debugPrint('❌ Error in action stream: $error');
      },
    );
  }

  /// 🆕 Handle medicine action completed (from notification)
  void _handleMedicineActionCompleted() {
    debugPrint('🔔 Medicine action completed - triggering refresh');
    
    // Trigger home refresh
    MedicalCareApp.triggerHomeRefresh();
  }

  /// Handle navigation from local notification tap
  void _handleLocalNotificationNavigation(String route, Map<String, dynamic>? arguments) {
    debugPrint('🧭 Local notification navigation: $route');
    debugPrint('   Arguments: $arguments');

    // Wait for app to be ready before navigating
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToRoute(route, arguments);
    });
  }

  /// Handle messages from notification actions
  void _handleNotificationMessage(String message, {bool isError = false}) {
    MedicalCareApp.showSnackBar(message, isError: isError);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FCM HANDLER (Firebase Cloud Messaging)
  // ═══════════════════════════════════════════════════════════════════════════

  void _setupFCMForegroundHandler() {
    // Handle FCM messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 FCM Foreground: ${message.notification?.title}');
      
      if (message.notification != null) {
        MedicalCareApp.showSnackBar(
          message.notification!.body ?? 'لديك إشعار جديد',
        );
      }
    });

    // Handle FCM when user taps notification and app opens
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📩 FCM Opened: ${message.data}');
      _handleFCMNotificationNavigation(message);
    });
  }

  /// Handle navigation from FCM notification
  void _handleFCMNotificationNavigation(RemoteMessage message) {
    final type = message.data['type'];
    final arguments = Map<String, dynamic>.from(message.data);
    
    switch (type) {
      case 'medicine_reminder':
        _navigateToRoute(AppRouter.medicines, arguments);
        break;
      case 'health_reading':
        _navigateToRoute(AppRouter.healthReadings, arguments);
        break;
      case 'appointment':
        _navigateToRoute(AppRouter.appointments, arguments);
        break;
      default:
        _navigateToRoute(AppRouter.home, null);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UNIFIED NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════

  void _navigateToRoute(String route, Map<String, dynamic>? arguments) {
    debugPrint('🧭 Navigating to: $route');

    final targetRoute = _mapRoute(route);

    try {
      if (arguments != null && arguments.isNotEmpty) {
        _appRouter.router.go(targetRoute, extra: arguments);
      } else {
        _appRouter.router.go(targetRoute);
      }
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
      _appRouter.router.go(AppRouter.home);
    }
  }

  String _mapRoute(String route) {
    final normalizedRoute = route.startsWith('/') ? route.substring(1) : route;
    
    switch (normalizedRoute) {
      case 'medicines':
        return AppRouter.medicines;
      case 'health-readings':
      case 'healthReadings':
        return AppRouter.healthReadings;
      case 'appointments':
        return AppRouter.appointments;
      case 'notifications':
        return AppRouter.notifications;
      case 'home':
      default:
        return AppRouter.home;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'Medical Care',
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: MedicalCareApp.scaffoldMessengerKey,
            locale: settings.locale,
            supportedLocales: S.supportedLocales,
            localizationsDelegates: S.localizationsDelegates,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            routerConfig: _appRouter.router,
            builder: (context, child) {
              return OfflineAuthGate(
                child: Directionality(
                  textDirection: settings.textDirection,
                  child: Stack(
                    children: [
                      if (child != null) child,
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          bottom: false,
                          child: OfflineBanner.connected(
                            onReconnect: () {
                              MedicalCareApp.triggerHomeRefresh();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

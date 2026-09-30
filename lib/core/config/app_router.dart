import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';
import '../app_shadows.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/health/health_exports.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/navigation/screens/main_navigation.dart';
import '../../features/medicines/medicines_injection.dart';
import '../../features/medicines/presentation/screens/add_medicine_screen.dart';
import '../../features/medicines/presentation/providers/medicine_form_provider.dart';
import '../../features/health_readings/health_readings_exports.dart';
import '../../features/profile/profile_injection.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/app_settings_screen.dart';
import '../../features/profile/presentation/screens/qr_code_screen.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/notifications/notifications_injection.dart';
import '../../features/doctor_dashboard/presentation/screens/qr_scanner_screen.dart';
import '../../features/doctor_dashboard/presentation/screens/doctor_patient_detail_screen.dart';
import '../../features/doctor_dashboard/presentation/providers/doctor_patient_detail_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🧭 APP ROUTER - Enterprise-Grade Navigation System
// ═══════════════════════════════════════════════════════════════════════════════
//
// Architecture: GoRouter with Clean Architecture Principles
//
// Features:
// • Type-safe routing with constants
// • Authentication guards
// • Custom page transitions (fade, slide, slideUp)
// • Nested routes for feature modules
// • Dependency injection integration
// • Error handling with custom error screens
// • Extension methods for clean navigation API
//
// Route Structure:
// ├── / (splash/auth wrapper)
// ├── /login
// ├── /register
// ├── /email-verification
// ├── /home (main navigation)
// ├── /medicines
// │   └── /add
// ├── /health-readings
// │   ├── /add
// │   └── /detail
// ├── /appointments (coming soon)
// ├── /history (coming soon)
// ├── /profile
// │   ├── /edit
// │   ├── /change-password
// │   └── /qr-code
// ├── /settings
// │   └── /notifications (settings)
// └── /notifications (notifications center) 🆕
//
// ═══════════════════════════════════════════════════════════════════════════════

class AppRouter {
  // ═══════════════════════════════════════════════════════════════════════════
  // DEPENDENCIES
  // ═══════════════════════════════════════════════════════════════════════════

  final AuthProvider authProvider;

  AppRouter({required this.authProvider});

  // ═══════════════════════════════════════════════════════════════════════════
  // ROUTE CONSTANTS - Type-safe route paths
  // ═══════════════════════════════════════════════════════════════════════════

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String emailVerification = '/email-verification';
  static const String home = '/home';
  static const String medicines = '/medicines';
  static const String addMedicine = '/medicines/add';
  static const String medicineDetail = '/medicines/:id';
  static const String healthReadings = '/health-readings';
  static const String addReading = '/health-readings/add';
  static const String readingDetail = '/health-readings/detail';
  static const String appointments = '/appointments';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String qrCode = '/profile/qr-code';
  static const String qrScanner = '/qr-scanner';
  static const String doctorPatientDetail = '/doctor-patient/:id';
  static const String doctorAddMedicine = 'add-medicine';
  static const String settings = '/settings';
  static const String notificationSettings = '/settings/notifications';
  static const String notifications = '/notifications';

  // ═══════════════════════════════════════════════════════════════════════════
  // ROUTER CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════════

  late final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    refreshListenable: authProvider,
    redirect: _guardRoute,
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    routes: _routes,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTHENTICATION GUARD
  // ═══════════════════════════════════════════════════════════════════════════

  String? _guardRoute(BuildContext context, GoRouterState state) {
    final isAuthenticated = authProvider.isAuthenticated;
    final isLoading = authProvider.isLoading;
    final shouldBlockRedirect = authProvider.shouldBlockAuthRedirect;
    final currentPath = state.matchedLocation;

    // Don't redirect while loading
    if (isLoading) return null;
    
    // Respect explicit redirect blocks
    if (shouldBlockRedirect) {
      return null;
    }

    // Define public routes that don't require authentication
    final publicRoutes = [welcome, login, register, emailVerification, splash];
    final isPublicRoute = publicRoutes.contains(currentPath);

    // Always allow email verification
    if (currentPath == emailVerification) {
      return null;
    }

    // Redirect authenticated users away from public routes
    if (isAuthenticated && isPublicRoute) {
      return home;
    }

    // Redirect unauthenticated users to login
    if (!isAuthenticated && !isPublicRoute) {
      return login;
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ROUTES DEFINITION
  // ═══════════════════════════════════════════════════════════════════════════

  List<RouteBase> get _routes => [
    // ─────────────────────────────────────────────────────────────────────────
    // SPLASH / AUTH WRAPPER
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: splash,
      name: 'splash',
      builder: (context, state) => const AuthWrapper(),
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // WELCOME / LANDING
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: welcome,
      name: 'welcome',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const WelcomeScreen(),
        transitionsBuilder: _fadeTransition,
      ),
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // AUTHENTICATION ROUTES
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: login,
      name: 'login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: _fadeTransition,
      ),
    ),

    GoRoute(
      path: register,
      name: 'register',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RegisterScreen(),
        transitionsBuilder: _slideTransition,
      ),
    ),

    GoRoute(
      path: emailVerification,
      name: 'emailVerification',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final email = extra?['email'] as String? ?? '';
        final password = extra?['password'] as String?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: EmailVerificationScreen(
            email: email,
            password: password,
          ),
          transitionsBuilder: _slideUpTransition,
        );
      },
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // HOME / MAIN NAVIGATION
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: home,
      name: 'home',
      builder: (context, state) {
        final userRole = authProvider.userModel?.role ?? UserRole.patient;
        return MainNavigation(userRole: userRole);
      },
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // DOCTOR QR SCANNER & PATIENT DETAIL
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: qrScanner,
      name: 'qrScanner',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const QrScannerScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    GoRoute(
      path: doctorPatientDetail,
      name: 'doctorPatientDetail',
      pageBuilder: (context, state) {
        final patientId = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ChangeNotifierProvider(
            create: (_) => DoctorPatientDetailProvider(patientId),
            child: const DoctorPatientDetailScreen(),
          ),
          transitionsBuilder: _slideTransition,
        );
      },
      routes: [
        GoRoute(
          path: doctorAddMedicine,
          name: 'doctorAddMedicine',
          pageBuilder: (context, state) {
            final patientId = state.pathParameters['id']!;
            return CustomTransitionPage(
              key: state.pageKey,
              child: ChangeNotifierProvider<MedicineFormProvider>(
                create: (_) => MedicineFormProvider(
                  repository: MedicinesInjection.repository,
                  userId: patientId, // Injecting the patient's ID instead of the doctor's
                ),
                child: const AddMedicineScreen(),
              ),
              transitionsBuilder: _slideUpTransition,
            );
          },
        ),
      ],
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // MEDICINES MODULE
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: medicines,
      name: 'medicines',
      builder: (context, state) => MedicinesInjection.buildMedicinesScreen(context),
      routes: [
        GoRoute(
          path: 'add',
          name: 'addMedicine',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: _buildAddMedicineScreen(context, state),
            transitionsBuilder: _slideUpTransition,
          ),
        ),
      ],
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // HEALTH READINGS MODULE
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: healthReadings,
      name: 'healthReadings',
      builder: (context, state) => const HealthReadingsScreen(),
      routes: [
        GoRoute(
          path: 'add',
          name: 'addReading',
          pageBuilder: (context, state) {
            final type = state.extra as ReadingType?;
            return CustomTransitionPage(
              key: state.pageKey,
              child: HealthAddReadingScreen(initialType: type),
              transitionsBuilder: _slideUpTransition,
            );
          },
        ),
        GoRoute(
          path: 'detail',
          name: 'readingDetail',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const HealthReadingsScreen(),
              transitionsBuilder: _slideTransition,
            );
          },
        ),
      ],
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // COMING SOON MODULES
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: appointments,
      name: 'appointments',
      builder: (context, state) => const ComingSoonScreen(
        icon: Icons.calendar_month_rounded,
        title: 'المواعيد',
        subtitle: 'إدارة مواعيدك الطبية',
        featureList: ['حجز المواعيد', 'التذكيرات', 'سجل المواعيد'],
        accentColor: AppColors.info,
      ),
    ),

    GoRoute(
      path: history,
      name: 'history',
      builder: (context, state) => const ComingSoonScreen(
        icon: Icons.history_rounded,
        title: 'السجل الطبي',
        subtitle: 'تاريخك الصحي الكامل',
        featureList: ['التشخيصات السابقة', 'نتائج التحاليل', 'الوصفات الطبية'],
        accentColor: AppColors.secondary,
      ),
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // PROFILE MODULE
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: profile,
      name: 'profile',
      builder: (context, state) => ProfileInjection.buildProfileScreen(context),
      routes: [
        GoRoute(
          path: 'edit',
          name: 'editProfile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: _buildProfileSubScreen(const EditProfileScreen()),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: 'change-password',
          name: 'changePassword',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: _buildProfileSubScreen(const ChangePasswordScreen()),
            transitionsBuilder: _slideTransition,
          ),
        ),
        GoRoute(
          path: 'qr-code',
          name: 'qrCode',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: _buildProfileSubScreen(const QRCodeScreen()),
            transitionsBuilder: _slideUpTransition,
          ),
        ),
      ],
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // SETTINGS MODULE
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: settings,
      name: 'settings',
      builder: (context, state) => const AppSettingsScreen(),
      routes: [
        GoRoute(
          path: 'notifications',
          name: 'notificationSettings',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const NotificationSettingsScreen(),
            transitionsBuilder: _slideTransition,
          ),
        ),
      ],
    ),

    // ─────────────────────────────────────────────────────────────────────────
    // 🔔 NOTIFICATIONS CENTER - Enterprise Notifications Module
    // ─────────────────────────────────────────────────────────────────────────
    GoRoute(
      path: notifications,
      name: 'notifications',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: NotificationsInjection.buildNotificationsScreen(context),
        transitionsBuilder: _slideTransition,
      ),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Build profile sub-screen with ProfileProvider
  Widget _buildProfileSubScreen(Widget screen) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider()..init(),
      child: screen,
    );
  }

  /// Build add medicine screen with MedicineFormProvider
  Widget _buildAddMedicineScreen(BuildContext context, GoRouterState state) {
    final userId = authProvider.userId;
    if (userId == null || userId.isEmpty) {
      return const _AuthErrorWidget();
    }

    return ChangeNotifierProvider<MedicineFormProvider>(
      create: (_) => MedicineFormProvider(
        repository: MedicinesInjection.repository,
        userId: userId,
      ),
      child: const AddMedicineScreen(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGE TRANSITIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fade transition - for splash/login
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  /// Slide from right transition - for general navigation
  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }

  /// Slide from bottom transition - for modals/forms
  static Widget _slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NAVIGATION EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════════

extension GoRouterExtensions on BuildContext {
  void goHome() => GoRouter.of(this).go(AppRouter.home);
  void goLogin() => GoRouter.of(this).go(AppRouter.login);
  void goRegister() => GoRouter.of(this).go(AppRouter.register);
  void goProfile() => GoRouter.of(this).go(AppRouter.profile);
  void goEditProfile() => GoRouter.of(this).go(AppRouter.editProfile);
  void goChangePassword() => GoRouter.of(this).go(AppRouter.changePassword);
  void goQRCode() => GoRouter.of(this).go(AppRouter.qrCode);
  void goSettings() => GoRouter.of(this).go(AppRouter.settings);
  void goNotificationSettings() => GoRouter.of(this).go(AppRouter.notificationSettings);
  void goNotifications() => GoRouter.of(this).go(AppRouter.notifications);
  
  void goBack() {
    if (GoRouter.of(this).canPop()) {
      GoRouter.of(this).pop();
    } else {
      goHome();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AUTH WRAPPER
// ═══════════════════════════════════════════════════════════════════════════════

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (auth.isAuthenticated) {
          final userRole = auth.userModel?.role ?? UserRole.patient;
          return MainNavigation(userRole: userRole);
        }

        // Redirect to welcome landing screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/welcome');
        });

        // Show loading while redirect is scheduled
        return const Scaffold(
          backgroundColor: Color(0xFF1565C0),
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      },
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════════
// AUTH ERROR WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

class _AuthErrorWidget extends StatelessWidget {
  const _AuthErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'خطأ في المصادقة',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'يرجى تسجيل الدخول مرة أخرى',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.goLogin(),
                icon: const Icon(Icons.login_rounded),
                label: const Text('تسجيل الدخول'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERROR SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'عذراً!',
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'الصفحة غير موجودة',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.goHome(),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('العودة للرئيسية'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMING SOON SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class ComingSoonScreen extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String>? featureList;
  final Color? accentColor;

  const ComingSoonScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.featureList,
    this.accentColor,
  });

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  Color get _color => widget.accentColor ?? AppColors.primary;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildIcon(),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    widget.title,
                    style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.subtitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildBadge(),
                  if (widget.featureList != null) ...[
                    const SizedBox(height: 32),
                    _buildFeatureList(),
                  ],
                  const SizedBox(height: 40),
                  _buildBackButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _color.withAlpha(38),
            _color.withAlpha(13),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: _color.withAlpha(77), width: 2),
      ),
      child: Icon(widget.icon, size: 64, color: _color),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(26),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.warning.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_rounded, color: AppColors.warning, size: 22),
          const SizedBox(width: 10),
          Text(
            'قريباً',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: _color, size: 20),
              const SizedBox(width: 8),
              Text(
                'الميزات القادمة',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.featureList!.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _color.withAlpha(26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.check_rounded, color: _color, size: 16),
                ),
                const SizedBox(width: 12),
                Text(feature, style: AppTextStyles.bodyMedium),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.goBack(),
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text('رجوع'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

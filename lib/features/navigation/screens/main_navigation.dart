import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/app_colors.dart';
import '../../../core/design_tokens.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../home/presentation/screens/patient_home_screen.dart';
import '../../home/presentation/providers/home_provider.dart';
import '../../doctor_dashboard/presentation/screens/doctor_home_screen.dart';
import '../../doctor_dashboard/presentation/providers/doctor_home_provider.dart';
import '../../doctor_dashboard/presentation/screens/doctor_patients_screen.dart';
import '../../doctor_dashboard/presentation/providers/doctor_patients_provider.dart';
import '../../doctor_dashboard/presentation/screens/doctor_reports_screen.dart';
import '../../doctor_dashboard/presentation/providers/doctor_reports_provider.dart';
import '../../medicines/medicines_injection.dart';
import '../../health_readings/health_readings_injection.dart';
import '../../profile/profile_injection.dart';
import '../models/navigation_item.dart';
import '../widgets/bottom_nav_bar.dart';

class MainNavigation extends StatefulWidget {
  final UserRole userRole;

  const MainNavigation({
    super.key,
    required this.userRole,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final HomeProvider _homeProvider;
  late final DoctorHomeProvider _doctorHomeProvider;
  late final DoctorPatientsProvider _doctorPatientsProvider;
  late final DoctorReportsProvider _doctorReportsProvider;

  List<NavigationItem> get _navigationItems => _buildNavigationItems();

  @override
  void initState() {
    super.initState();
    _homeProvider = HomeProvider();
    _doctorPatientsProvider = DoctorPatientsProvider(context.read<AuthProvider>());
    _doctorHomeProvider = DoctorHomeProvider(context.read<AuthProvider>(), _doctorPatientsProvider);
    _doctorReportsProvider = DoctorReportsProvider(context.read<AuthProvider>());
    _validateUserRole();
  }

  @override
  void dispose() {
    _homeProvider.dispose();
    _doctorHomeProvider.dispose();
    _doctorPatientsProvider.dispose();
    _doctorReportsProvider.dispose();
    super.dispose();
  }

  List<NavigationItem> _buildNavigationItems() {
    return widget.userRole == UserRole.patient
        ? _buildPatientItems()
        : _buildDoctorItems();
  }

  List<NavigationItem> _buildPatientItems() {
    final t = S.of(context);
    return [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: t.nav_home,
        semanticLabel: t.nav_homeSemantics,
        screen: ChangeNotifierProvider.value(
          value: _homeProvider,
          child: PatientHomeScreen(
            onTabChange: _changeTab,
          ),
        ),
      ),
      NavigationItem(
        icon: Icons.medication_outlined,
        activeIcon: Icons.medication_rounded,
        label: t.nav_medicines,
        semanticLabel: t.nav_medicinesSemantics,
        screen: Builder(
          builder: (context) => MedicinesInjection.buildMedicinesScreen(context),
        ),
      ),
      NavigationItem(
        icon: Icons.monitor_heart_outlined,
        activeIcon: Icons.monitor_heart_rounded,
        label: t.nav_readings,
        semanticLabel: t.nav_readingsSemantics,
        screen: Builder(
          builder: (context) => HealthReadingsInjection.buildHealthReadingsScreen(context),
        ),
      ),
      NavigationItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: t.nav_profile,
        semanticLabel: t.nav_profileSemantics,
        screen: Builder(
          builder: (context) => ProfileInjection.buildProfileScreen(context),
        ),
      ),
    ];
  }

  List<NavigationItem> _buildDoctorItems() {
    final t = S.of(context);
    return [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: t.nav_home,
        semanticLabel: t.nav_doctorHomeSemantics,
        screen: ChangeNotifierProvider.value(
          value: _doctorHomeProvider,
          child: DoctorHomeScreen(
            onTabChange: _changeTab,
          ),
        ),
      ),
      NavigationItem(
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        label: t.nav_patients,
        semanticLabel: t.nav_patientsSemantics,
        screen: ChangeNotifierProvider.value(
          value: _doctorPatientsProvider,
          child: const DoctorPatientsScreen(),
        ),
      ),
      NavigationItem(
        icon: Icons.assessment_outlined,
        activeIcon: Icons.assessment_rounded,
        label: t.nav_reports,
        semanticLabel: t.nav_reportsSemantics,
        screen: ChangeNotifierProvider.value(
          value: _doctorReportsProvider,
          child: const DoctorReportsScreen(),
        ),
      ),
      NavigationItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: t.nav_profile,
        semanticLabel: t.nav_profileSemantics,
        screen: Builder(
          builder: (context) => ProfileInjection.buildProfileScreen(context),
        ),
      ),
    ];
  }

  void _validateUserRole() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      
      if (authProvider.isLoading) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
      }
      
      final currentUser = authProvider.userModel;

      if (currentUser == null) {
        if (authProvider.firebaseUser != null) {
          return;
        }
        _redirectToLogin(reason: 'المستخدم غير مسجل');
        return;
      }

      if (currentUser.role != widget.userRole) {
        _redirectToLogin(reason: 'خطأ في صلاحيات المستخدم');
      }
    });
  }

  void _redirectToLogin({String? reason}) {
    if (!mounted) return;

    if (reason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reason),
          backgroundColor: AppColors.error,
        ),
      );
    }

    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  void _onTabChanged(int index) {
    if (index != _currentIndex && index >= 0 && index < _navigationItems.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _changeTab(int index) {
    if (index >= 0 && index < _navigationItems.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<bool> _handleBackPress() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }

    final shouldExit = await _showExitDialog();
    return shouldExit ?? false;
  }

  Future<bool?> _showExitDialog() {
    final tokens = context.tokens;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: tokens.borderRadiusLarge,
        ),
        title: Row(
          children: [
            Container(
              padding: tokens.paddingAllSmall,
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(26),
                borderRadius: tokens.borderRadiusSmall,
              ),
              child: Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.warning,
                size: tokens.iconMedium,
              ),
            ),
            SizedBox(width: tokens.spacingSmall),
            Flexible(
              child: Text(
                S.of(context).common_logoutTitle,
                style: TextStyle(
                  fontSize: tokens.fontSubtitle,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          S.of(context).common_logoutConfirm,
          style: TextStyle(
            fontSize: tokens.fontBody,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              S.of(context).common_cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: tokens.fontBody,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: tokens.borderRadiusMedium,
              ),
            ),
            child: Text(
              S.of(context).common_logout,
              style: TextStyle(fontSize: tokens.fontBody),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_navigationItems.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final shouldExit = await _handleBackPress();
        if (shouldExit && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentIndex.clamp(0, _navigationItems.length - 1),
                children: _navigationItems.map((item) => item.screen).toList(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          items: _navigationItems,
          currentIndex: _currentIndex,
          onTap: _onTabChanged,
        ),
      ),
    );
  }
}

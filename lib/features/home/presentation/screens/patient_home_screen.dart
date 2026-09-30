import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../app.dart';
import '../providers/home_provider.dart';
import '../widgets/health_status_card.dart';
import '../widgets/greeting_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/today_medicines_card.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/weekly_progress_card.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🏠 PATIENT HOME SCREEN - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Version: 2.0.0
// Architecture: Clean Architecture with Provider Pattern
//
// Features:
// • Greeting header with user info
// • Health status card with latest readings
// • Quick actions grid
// • Today's medicines with reminders
// • Weekly progress tracking
// • Daily health tips
// • Real-time notifications badge
// • 🆕 Auto-refresh from external notification actions
// • 🆕 Global refresh callback registration
//
// Updates v2.0:
// • Registers MedicalCareApp.onHomeRefreshNeeded callback
// • Proper cleanup in dispose()
// • Supports refresh from cold start notification actions
//
// ═══════════════════════════════════════════════════════════════════════════════

class PatientHomeScreen extends StatefulWidget {
  final void Function(int)? onTabChange;
  
  const PatientHomeScreen({
    super.key,
    this.onTabChange,
  });

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  bool _showDailyTip = true;

  @override
  void initState() {
    super.initState();
    
    // 🆕 Register global refresh callback for notification actions
    _registerRefreshCallback();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeProvider>().loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    // 🆕 Clear the callback when screen is disposed
    _unregisterRefreshCallback();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 REFRESH CALLBACK REGISTRATION
  // ═══════════════════════════════════════════════════════════════════════════

  void _registerRefreshCallback() {
    MedicalCareApp.onHomeRefreshNeeded = _handleExternalRefresh;
    debugPrint('✅ PatientHomeScreen: Refresh callback registered');
  }

  void _unregisterRefreshCallback() {
    MedicalCareApp.onHomeRefreshNeeded = null;
    debugPrint('🧹 PatientHomeScreen: Refresh callback cleared');
  }

  void _handleExternalRefresh() {
    debugPrint('🔄 PatientHomeScreen: External refresh triggered');
    
    if (!mounted) {
      debugPrint('⚠️ PatientHomeScreen: Not mounted, skipping refresh');
      return;
    }

    // Refresh medicines data
    try {
      final provider = context.read<HomeProvider>();
      provider.refreshMedicines();
      debugPrint('✅ PatientHomeScreen: Medicines refreshed');
    } catch (e) {
      debugPrint('❌ PatientHomeScreen: Error refreshing: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const _LoadingView();
          }

          if (provider.hasError) {
            return _ErrorView(
              message: provider.errorMessage ?? S.of(context).common_error,
              onRetry: provider.retryLoad,
            );
          }

          return Stack(
            children: [
              const _BackgroundGradient(),
              
              RefreshIndicator(
                onRefresh: provider.refresh,
                color: AppColors.white,
                backgroundColor: AppColors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    _HomeAppBar(
                      userName: provider.userName,
                      unreadNotificationsCount: provider.unreadNotificationsCount,
                      onNotifications: () => _navigateTo('/notifications'),
                      onProfile: () {
                        if (widget.onTabChange != null) {
                          widget.onTabChange!(3);
                        } else {
                          _navigateTo('/profile');
                        }
                      },
                    ),
                    SliverToBoxAdapter(
                      child: _HomeContent(
                        provider: provider,
                        showDailyTip: _showDailyTip,
                        onDismissTip: () => setState(() => _showDailyTip = false),
                        onShareTip: _shareTip,
                        onNavigate: _navigateTo,
                        onTabChange: widget.onTabChange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateTo(String route) {
    if (mounted) {
      HapticFeedback.lightImpact();
      context.push(route);
    }
  }

  void _shareTip() {
    Share.share(
      'نصيحة صحية من تطبيق Medical Care:\n\nاشرب الماء بانتظام للحفاظ على صحتك! 💧',
      subject: 'نصيحة صحية',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BACKGROUND GRADIENT
// ═══════════════════════════════════════════════════════════════════════════════

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.background,
            AppColors.background,
          ],
          stops: const [0.0, 0.15, 0.3, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME CONTENT
// ═══════════════════════════════════════════════════════════════════════════════

class _HomeContent extends StatelessWidget {
  final HomeProvider provider;
  final bool showDailyTip;
  final VoidCallback onDismissTip;
  final VoidCallback onShareTip;
  final void Function(String) onNavigate;
  final void Function(int)? onTabChange;

  const _HomeContent({
    required this.provider,
    required this.showDailyTip,
    required this.onDismissTip,
    required this.onShareTip,
    required this.onNavigate,
    this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(tokens.radiusXL),
          topRight: Radius.circular(tokens.radiusXL),
        ),
      ),
      child: Padding(
        padding: tokens.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tokens.spacerMedium,
            
            GreetingHeader(
              userName: provider.userName,
              avatarUrl: provider.userAvatarUrl,
              onAvatarTap: () {
                if (onTabChange != null) {
                  onTabChange!(3);
                } else {
                  onNavigate('/profile');
                }
              },
            ),
            tokens.spacerLarge,
            
            HealthStatusCard(
              healthSummary: provider.healthSummary,
              bloodPressure: provider.latestReadings.bloodPressure,
              bloodSugar: provider.latestReadings.bloodSugar,
              weight: provider.latestReadings.weight,
              onTap: () {
                if (onTabChange != null) {
                  onTabChange!(2);
                } else {
                  onNavigate('/health-readings');
                }
              },
            ),
            tokens.spacerXLarge,
            
            QuickActionsGrid(
              onAddReading: () => onNavigate('/health-readings/add'),
              onMedicines: () {
                if (onTabChange != null) {
                  onTabChange!(1);
                } else {
                  onNavigate('/medicines');
                }
              },
              onStatistics: () {
                if (onTabChange != null) {
                  onTabChange!(2);
                } else {
                  onNavigate('/health-readings');
                }
              },
              onHistory: () {
                if (onTabChange != null) {
                  onTabChange!(2);
                } else {
                  onNavigate('/health-readings');
                }
              },
              medicinesCount: provider.medicinesCount,
              readingsCount: provider.readingsCount,
            ),
            tokens.spacerXLarge,
            
            TodayMedicinesCard(
              medicines: provider.todayMedicines,
              onViewAll: () {
                if (onTabChange != null) {
                  onTabChange!(1);
                } else {
                  onNavigate('/medicines');
                }
              },
              onAddMedicine: () => onNavigate('/medicines/add'),
            ),
            tokens.spacerXLarge,
            
            WeeklyProgressCard(
              stats: _buildWeeklyStats(provider),
              userCreatedAt: provider.userCreatedAt,
              onViewDetails: () => onNavigate('/health-readings'),
            ),
            tokens.spacerXLarge,
            
            if (showDailyTip)
              DailyTipCard(
                onShare: onShareTip,
                onDismiss: onDismissTip,
              ),
            
            SizedBox(height: tokens.responsive.scale(100)),
          ],
        ),
      ),
    );
  }

  WeeklyStats _buildWeeklyStats(HomeProvider provider) {
    final now = DateTime.now();
    final today = (now.weekday % 7);
    final userCreatedAt = provider.userCreatedAt;
    
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: today));

    final activeDays = List.generate(7, (index) {
      final dayDate = startOfWeek.add(Duration(days: index));
      
      if (userCreatedAt != null) {
        final createdDate = DateTime(
          userCreatedAt.year,
          userCreatedAt.month,
          userCreatedAt.day,
        );
        
        if (dayDate.isBefore(createdDate)) {
          return false;
        }
      }

      if (index > today) return false;
      
      return provider.readingsCount > index;
    });

    int availableDays = today + 1;
    if (userCreatedAt != null) {
      final createdDate = DateTime(
        userCreatedAt.year,
        userCreatedAt.month,
        userCreatedAt.day,
      );
      
      if (createdDate.isAfter(startOfWeek)) {
        final daysSinceCreated = now.difference(createdDate).inDays + 1;
        availableDays = daysSinceCreated.clamp(0, today + 1);
      }
    }

    return WeeklyStats(
      activeDays: activeDays,
      medicinesTaken: provider.takenMedicinesCount,
      medicinesTotal: provider.medicinesCount > 0 ? provider.medicinesCount * availableDays : 0,
      readingsTaken: provider.readingsCount,
      readingsGoal: availableDays,
      streakDays: activeDays.where((d) => d).length,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME APP BAR
// ═══════════════════════════════════════════════════════════════════════════════

class _HomeAppBar extends StatelessWidget {
  final String userName;
  final int unreadNotificationsCount;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const _HomeAppBar({
    required this.userName,
    required this.unreadNotificationsCount,
    required this.onNotifications,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SliverAppBar(
      expandedHeight: tokens.responsive.scale(100),
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.paddingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: tokens.paddingAllSmall,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: tokens.borderRadiusMedium,
                    ),
                    child: Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.white,
                      size: tokens.iconMedium,
                    ),
                  ),
                  SizedBox(width: tokens.spacingSmall),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Care',
                        style: TextStyle(
                          fontSize: tokens.fontSubtitle,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        'صحتك أولويتنا',
                        style: TextStyle(
                          fontSize: tokens.fontCaption,
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              Row(
                children: [
                  _AppBarButton(
                    icon: Icons.notifications_outlined,
                    onTap: onNotifications,
                    badge: unreadNotificationsCount > 0 ? unreadNotificationsCount : null,
                  ),
                  SizedBox(width: tokens.spacingXS),
                  _AppBarButton(
                    icon: Icons.person_outline_rounded,
                    onTap: onProfile,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// APP BAR BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;

  const _AppBarButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      button: true,
      label: badge != null ? 'لديك $badge إشعارات جديدة' : null,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Stack(
          children: [
            Container(
              padding: tokens.paddingAllSmall,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: tokens.borderRadiusMedium,
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: tokens.iconMedium,
              ),
            ),
            if (badge != null && badge! > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(tokens.spacing2XS),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    minWidth: tokens.responsive.scale(16),
                    minHeight: tokens.responsive.scale(16),
                  ),
                  child: Center(
                    child: Text(
                      badge! > 99 ? '99+' : (badge! > 9 ? '9+' : badge.toString()),
                      style: TextStyle(
                        fontSize: tokens.fontXS - 2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOADING VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: tokens.paddingAllLarge,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: tokens.spacingLarge),
            Text(
              'جاري التحميل...',
              style: TextStyle(
                fontSize: tokens.fontBody,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ERROR VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: tokens.paddingAllLarge,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: tokens.paddingAllLarge,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.error,
                  size: tokens.icon2XL,
                ),
              ),
              tokens.spacerLarge,
              Text(
                'عذراً!',
                style: TextStyle(
                  fontSize: tokens.fontHeadline,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              tokens.spacerSmall,
              Text(
                message,
                style: TextStyle(
                  fontSize: tokens.fontBody,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              tokens.spacerXLarge,
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.paddingLarge,
                    vertical: tokens.paddingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: tokens.borderRadiusMedium,
                  ),
                  elevation: 0,
                ),
              ),
              tokens.spacerMedium,
              TextButton(
                onPressed: () {},
                child: Text(
                  'هل تحتاج مساعدة؟',
                  style: TextStyle(
                    fontSize: tokens.fontSmall,
                    color: AppColors.primary,
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

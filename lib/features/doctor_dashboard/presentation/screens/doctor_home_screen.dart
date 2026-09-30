import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../../../home/presentation/widgets/greeting_header.dart';
import '../providers/doctor_home_provider.dart';
import '../widgets/scan_qr_glass_card.dart';
import '../widgets/recent_patients_list.dart';

class DoctorHomeScreen extends StatefulWidget {
  final void Function(int)? onTabChange;

  const DoctorHomeScreen({
    super.key,
    this.onTabChange,
  });

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DoctorHomeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(child: Text(provider.errorMessage!));
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
                      unreadCount: provider.unreadNotificationsCount,
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
}

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

class _HomeContent extends StatelessWidget {
  final DoctorHomeProvider provider;
  final void Function(String) onNavigate;
  final void Function(int)? onTabChange;

  const _HomeContent({
    required this.provider,
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
              userName: provider.doctorName,
              avatarUrl: provider.doctorAvatarUrl,
              onAvatarTap: () {
                if (onTabChange != null) {
                  onTabChange!(3);
                } else {
                  onNavigate('/profile');
                }
              },
            ),
            tokens.spacerXLarge,
            
            ScanQrGlassCard(
              onTap: () {
                onNavigate('/qr-scanner');
              },
            ),
            tokens.spacerXLarge,
            
            RecentPatientsList(
              patients: provider.recentPatients,
              onViewAll: () {
                if (onTabChange != null) {
                  onTabChange!(1); // Go to Patients Tab
                }
              },
            ),
            
            SizedBox(height: tokens.responsive.scale(100)),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const _HomeAppBar({
    required this.unreadCount,
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
                      Icons.local_hospital_rounded,
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
                        'لوحة الطبيب',
                        style: TextStyle(
                          fontSize: tokens.fontSubtitle,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        'إدارة المرضى بسهولة',
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
                    badge: unreadCount > 0 ? unreadCount : null,
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
                  ),
                  constraints: BoxConstraints(
                    minWidth: tokens.responsive.scale(16),
                    minHeight: tokens.responsive.scale(16),
                  ),
                  child: Center(
                    child: Text(
                      badge! > 9 ? '9+' : badge.toString(),
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

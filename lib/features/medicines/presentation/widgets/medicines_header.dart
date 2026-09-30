import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/design_tokens.dart';

class MedicinesHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int totalMedicines;
  final int activeMedicines;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const MedicinesHeader({
    super.key,
    this.title = 'الأدوية',
    this.subtitle,
    this.totalMedicines = 0,
    this.activeMedicines = 0,
    this.onSearchTap,
    this.onFilterTap,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopBar(context, tokens),
            _buildHeaderContent(context, tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingLG,
        vertical: tokens.paddingSM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildIconContainer(
                context: context,
                tokens: tokens,
                child: Icon(
                  Icons.medication_rounded,
                  color: AppColors.white,
                  size: tokens.iconMD,
                ),
              ),
              SizedBox(width: tokens.spacingSM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: tokens.fontXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: tokens.fontSM,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (onSearchTap != null)
                _HeaderActionButton(
                  icon: Icons.search_rounded,
                  onTap: onSearchTap!,
                  tokens: tokens,
                ),
              if (onFilterTap != null) ...[
                SizedBox(width: tokens.spacingSM),
                _HeaderActionButton(
                  icon: Icons.tune_rounded,
                  onTap: onFilterTap!,
                  tokens: tokens,
                ),
              ],
              if (onNotificationTap != null) ...[
                SizedBox(width: tokens.spacingSM),
                _HeaderActionButton(
                  icon: Icons.notifications_outlined,
                  onTap: onNotificationTap!,
                  tokens: tokens,
                  badge: notificationCount,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context, DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.only(
        left: tokens.paddingLG,
        right: tokens.paddingLG,
        bottom: tokens.paddingXL,
        top: tokens.paddingSM,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context: context,
              tokens: tokens,
              icon: Icons.medication_liquid_rounded,
              label: 'إجمالي الأدوية',
              value: totalMedicines.toString(),
              color: AppColors.white,
            ),
          ),
          SizedBox(width: tokens.spacingMD),
          Expanded(
            child: _buildStatCard(
              context: context,
              tokens: tokens,
              icon: Icons.check_circle_outline_rounded,
              label: 'الأدوية النشطة',
              value: activeMedicines.toString(),
              color: AppColors.successLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer({
    required BuildContext context,
    required DesignTokens tokens,
    required Widget child,
  }) {
    return Container(
      padding: tokens.paddingAllSM,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required DesignTokens tokens,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingMD,
        vertical: tokens.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: tokens.paddingAllXS,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: tokens.borderRadiusSM,
            ),
            child: Icon(
              icon,
              color: color,
              size: tokens.iconSM,
            ),
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: tokens.font2XL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: tokens.fontXS,
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final DesignTokens tokens;
  final int? badge;

  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
    required this.tokens,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'زر إجراء',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: tokens.paddingAllSM,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: tokens.borderRadiusMD,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: tokens.iconMD,
              ),
            ),
            if (badge != null && badge! > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: EdgeInsets.all(tokens.spacing2XS),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryDark,
                      width: 1.5,
                    ),
                    boxShadow: AppShadows.sm,
                  ),
                  constraints: BoxConstraints(
                    minWidth: tokens.responsive.scale(18),
                    minHeight: tokens.responsive.scale(18),
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

class MedicinesHeaderSliver extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int totalMedicines;
  final int activeMedicines;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final bool floating;
  final bool pinned;

  const MedicinesHeaderSliver({
    super.key,
    this.title = 'الأدوية',
    this.subtitle,
    this.totalMedicines = 0,
    this.activeMedicines = 0,
    this.onSearchTap,
    this.onFilterTap,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.floating = false,
    this.pinned = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final topPadding = MediaQuery.of(context).padding.top;
    final expandedHeight = tokens.responsive.scale(180) + topPadding;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      elevation: 0,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: MedicinesHeader(
          title: title,
          subtitle: subtitle,
          totalMedicines: totalMedicines,
          activeMedicines: activeMedicines,
          onSearchTap: onSearchTap,
          onFilterTap: onFilterTap,
          onNotificationTap: onNotificationTap,
          notificationCount: notificationCount,
        ),
      ),
    );
  }
}
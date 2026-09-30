import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../models/health/health_exports.dart';

class HealthTypeTabs extends StatelessWidget {
  final TabController tabController;

  const HealthTypeTabs({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.sm,
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppColors.primaryGradient,
          boxShadow: AppShadows.sm,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        tabs: ReadingType.values.map((type) {
          return Tab(
            height: isSmallScreen ? 50 : 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type.emoji,
                  style: TextStyle(fontSize: isSmallScreen ? 18 : 22),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    type.nameAr,
                    style: TextStyle(fontSize: isSmallScreen ? 9 : 10),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
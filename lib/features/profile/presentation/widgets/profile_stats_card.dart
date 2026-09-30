import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class ProfileStatsCard extends StatelessWidget {
  final int readingsCount;
  final int medicinesCount;
  final int consecutiveDays;

  const ProfileStatsCard({
    super.key,
    required this.readingsCount,
    required this.medicinesCount,
    required this.consecutiveDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                S.of(context).quickActions_statistics,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.monitor_heart_rounded,
                  value: readingsCount.toString(),
                  label: S.of(context).nav_readings,
                  color: AppColors.error,
                ),
              ),
              _buildDivider(context),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.medication_rounded,
                  value: medicinesCount.toString(),
                  label: S.of(context).nav_medicines,
                  color: AppColors.info,
                ),
              ),
              _buildDivider(context),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.local_fire_department_rounded,
                  value: consecutiveDays.toString(),
                  label: S.of(context).common_today,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).dividerColor,
    );
  }
}

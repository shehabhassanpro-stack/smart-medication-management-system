import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../models/health/health_exports.dart';
import '../../utils/health_readings_utils.dart';

class HealthStatisticsCard extends StatelessWidget {
  final List<HealthReading> readings;
  final ReadingType type;
  final TimePeriod selectedPeriod;

  const HealthStatisticsCard({
    super.key,
    required this.readings,
    required this.type,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final isBloodPressure = type == ReadingType.bloodPressure;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(color),
          const SizedBox(height: 20),
          if (isBloodPressure)
            _buildBloodPressureStats(color)
          else
            _buildGeneralStats(color),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(type.emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إحصائيات ${type.nameAr}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${selectedPeriod.labelAr} الأخير',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${readings.length} قراءة',
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralStats(Color color) {
    final stats = HealthStatisticsCalculator.calculate(readings);

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'المتوسط',
            value: stats.averageText,
            color: color,
            icon: Icons.analytics_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            label: 'الأعلى',
            value: stats.maxText,
            color: AppColors.error,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            label: 'الأقل',
            value: stats.minText,
            color: AppColors.success,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildBloodPressureStats(Color color) {
    final stats = HealthStatisticsCalculator.calculateBloodPressure(readings);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                label: 'المتوسط',
                value: stats.averageText,
                color: color,
                icon: Icons.analytics_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                label: 'الأعلى',
                value: stats.maxText,
                color: AppColors.error,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                label: 'الأقل',
                value: stats.minText,
                color: AppColors.success,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBPLegend('انقباضي', color),
              const SizedBox(width: 24),
              _buildBPLegend('انبساطي', color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBPLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

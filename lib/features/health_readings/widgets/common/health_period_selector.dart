import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/app_text_styles.dart';
import '../../utils/health_readings_utils.dart';

class HealthPeriodSelector extends StatelessWidget {
  final TimePeriod selectedPeriod;
  final ValueChanged<TimePeriod> onPeriodChanged;

  const HealthPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: TimePeriod.values
            .where((p) => p != TimePeriod.threeMonths)
            .map((period) => _buildPeriodChip(period))
            .toList(),
      ),
    );
  }

  Widget _buildPeriodChip(TimePeriod period) {
    final isSelected = selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onPeriodChanged(period);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            period.labelAr,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
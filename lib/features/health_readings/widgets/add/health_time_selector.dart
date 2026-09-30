import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../../../models/health/health_exports.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../core/app_constants.dart';

class MeasurementTimeSelector extends StatelessWidget {
  final MeasurementTime? selectedTime;
  final ValueChanged<MeasurementTime?> onTimeSelected;
  final bool showOnlyRelevantForSugar;
  final Color? accentColor;

  const MeasurementTimeSelector({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
    this.showOnlyRelevantForSugar = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final times = showOnlyRelevantForSugar
        ? MeasurementTime.sugarRelevant
        : MeasurementTime.sortedByOrder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: UIConstants.paddingMd),
        Wrap(
          spacing: UIConstants.paddingSm,
          runSpacing: UIConstants.paddingSm,
          children: times.map((time) {
            return _MeasurementTimeChip(
              time: time,
              isSelected: selectedTime == time,
              accentColor: accentColor,
              onTap: () {
                if (selectedTime == time) {
                  onTimeSelected(null);
                } else {
                  onTimeSelected(time);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          color: accentColor ?? AppColors.primary,
          size: 20,
        ),
        SizedBox(width: UIConstants.paddingSm),
        Text(
          'وقت القياس',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (selectedTime != null)
          GestureDetector(
            onTap: () => onTimeSelected(null),
            child: Text(
              'إلغاء',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _MeasurementTimeChip extends StatelessWidget {
  final MeasurementTime time;
  final bool isSelected;
  final Color? accentColor;
  final VoidCallback onTap;

  const _MeasurementTimeChip({
    required this.time,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? time.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                time.icon,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                time.nameAr,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MeasurementTimeSelectorCompact extends StatelessWidget {
  final MeasurementTime? selectedTime;
  final ValueChanged<MeasurementTime?> onTimeSelected;
  final Color? accentColor;

  const MeasurementTimeSelectorCompact({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.all(UIConstants.paddingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            color: color,
            size: 20,
          ),
          SizedBox(width: UIConstants.paddingSm),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MeasurementTime?>(
                value: selectedTime,
                hint: Text(
                  'اختر وقت القياس',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down_rounded, color: color),
                items: [
                  DropdownMenuItem<MeasurementTime?>(
                    value: null,
                    child: Text(
                      'بدون تحديد',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ...MeasurementTime.sortedByOrder.map((time) {
                    return DropdownMenuItem<MeasurementTime>(
                      value: time,
                      child: Row(
                        children: [
                          Icon(time.icon, size: 18, color: time.color),
                          const SizedBox(width: 8),
                          Text(
                            time.nameAr,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: onTimeSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
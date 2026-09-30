import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../../../models/health/health_exports.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/app_constants.dart';

class HealthQuickActions extends StatelessWidget {
  final ReadingType type;
  final ValueChanged<HealthQuickValue> onQuickValueSelected;
  final Animation<double>? animation;
  final Animation<Offset>? slideAnimation;

  const HealthQuickActions({
    super.key,
    required this.type,
    required this.onQuickValueSelected,
    this.animation,
    this.slideAnimation,
  });

  Color get _color => type.color;

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    if (animation != null && slideAnimation != null) {
      return SlideTransition(
        position: slideAnimation!,
        child: FadeTransition(
          opacity: animation!,
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.all(UIConstants.paddingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: UIConstants.paddingMd),
          Wrap(
            spacing: UIConstants.paddingSm,
            runSpacing: UIConstants.paddingSm,
            children: _getQuickValues().map((quickValue) {
              return _QuickActionChip(
                quickValue: quickValue,
                color: _color,
                onTap: () => onQuickValueSelected(quickValue),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.flash_on_rounded, color: AppColors.warning),
        SizedBox(width: UIConstants.paddingSm),
        Text(
          'إجراءات سريعة',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<HealthQuickValue> _getQuickValues() {
    switch (type) {
      case ReadingType.bloodPressure:
        return [
          HealthQuickValue(label: 'طبيعي 120/80', value: '120/80', systolic: 120, diastolic: 80),
          HealthQuickValue(label: 'مرتفع قليلاً 130/85', value: '130/85', systolic: 130, diastolic: 85),
          HealthQuickValue(label: 'مرتفع 140/90', value: '140/90', systolic: 140, diastolic: 90),
        ];
      case ReadingType.bloodSugar:
        return [
          HealthQuickValue(label: 'طبيعي صائم 90', value: '90', numericValue: 90),
          HealthQuickValue(label: 'طبيعي 110', value: '110', numericValue: 110),
          HealthQuickValue(label: 'بعد الأكل 140', value: '140', numericValue: 140),
        ];
      case ReadingType.weight:
        return [
          HealthQuickValue(label: '60 كجم', value: '60', numericValue: 60),
          HealthQuickValue(label: '70 كجم', value: '70', numericValue: 70),
          HealthQuickValue(label: '80 كجم', value: '80', numericValue: 80),
        ];
      case ReadingType.temperature:
        return [
          HealthQuickValue(label: 'طبيعي 36.6', value: '36.6', numericValue: 36.6),
          HealthQuickValue(label: 'طبيعي 37', value: '37', numericValue: 37),
          HealthQuickValue(label: 'حمى خفيفة 37.5', value: '37.5', numericValue: 37.5),
        ];
    }
  }
}

class _QuickActionChip extends StatelessWidget {
  final HealthQuickValue quickValue;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.quickValue,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.speed_rounded,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                quickValue.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthQuickValue {
  final String label;
  final String value;
  final int? systolic;
  final int? diastolic;
  final double? numericValue;

  const HealthQuickValue({
    required this.label,
    required this.value,
    this.systolic,
    this.diastolic,
    this.numericValue,
  });

  bool get isBloodPressure => systolic != null && diastolic != null;
}

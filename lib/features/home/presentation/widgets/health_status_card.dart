import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../../../../models/health/health_reading.dart';
import '../../domain/models/health_evaluation.dart';

class HealthStatusCard extends StatelessWidget {
  final HealthSummary healthSummary;
  final HealthReading? bloodPressure;
  final HealthReading? bloodSugar;
  final HealthReading? weight;
  final VoidCallback? onTap;

  const HealthStatusCard({
    super.key,
    required this.healthSummary,
    this.bloodPressure,
    this.bloodSugar,
    this.weight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      label: 'بطاقة الحالة الصحية: ${healthSummary.statusText}',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap != null
            ? () {
          HapticFeedback.lightImpact();
          onTap!();
        }
            : null,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.medicalGradient,
            borderRadius: tokens.borderRadiusLarge,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: tokens.responsive.scale(20),
                offset: Offset(0, tokens.responsive.scale(10)),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: tokens.borderRadiusLarge,
            child: Stack(
              children: [
                const Positioned.fill(child: _BackgroundDecoration()),
                Padding(
                  padding: tokens.paddingAllLarge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardHeader(healthSummary: healthSummary),
                      tokens.spacerLarge,
                      _ReadingsRow(
                        healthSummary: healthSummary,
                        bloodPressure: bloodPressure,
                        bloodSugar: bloodSugar,
                        weight: weight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: tokens.responsive.scale(-30),
          top: tokens.responsive.scale(-30),
          child: Container(
            width: tokens.responsive.scale(160),
            height: tokens.responsive.scale(160),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: tokens.responsive.scale(-50),
          bottom: tokens.responsive.scale(-40),
          child: Container(
            width: tokens.responsive.scale(140),
            height: tokens.responsive.scale(140),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardHeader extends StatelessWidget {
  final HealthSummary healthSummary;

  const _CardHeader({required this.healthSummary});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Container(
          padding: tokens.paddingAllSmall,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.2),
            borderRadius: tokens.borderRadiusSmall,
          ),
          child: Icon(
            Icons.health_and_safety_rounded,
            color: AppColors.white,
            size: tokens.iconLarge,
          ),
        ),
        tokens.hSpacerSmall,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الحالة الصحية',
                style: TextStyle(
                  fontSize: tokens.fontBodyLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              Text(
                'ملخص يومي محدث',
                style: TextStyle(
                  fontSize: tokens.fontCaption,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        _StatusBadge(healthSummary: healthSummary),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final HealthSummary healthSummary;

  const _StatusBadge({required this.healthSummary});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      label: 'الحالة: ${healthSummary.statusText}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.paddingSmall,
          vertical: tokens.paddingTiny,
        ),
        decoration: BoxDecoration(
          color: healthSummary.color.withValues(alpha: 0.2),
          borderRadius: tokens.borderRadiusFull,
          border: Border.all(
            color: healthSummary.color.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: tokens.responsive.scale(8),
              height: tokens.responsive.scale(8),
              decoration: BoxDecoration(
                color: healthSummary.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: healthSummary.color.withValues(alpha: 0.5),
                    blurRadius: tokens.responsive.scale(8),
                    spreadRadius: tokens.responsive.scale(2),
                  ),
                ],
              ),
            ),
            tokens.hSpacerTiny,
            Text(
              healthSummary.statusText,
              style: TextStyle(
                fontSize: tokens.fontSmall,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingsRow extends StatelessWidget {
  final HealthSummary healthSummary;
  final HealthReading? bloodPressure;
  final HealthReading? bloodSugar;
  final HealthReading? weight;

  const _ReadingsRow({
    required this.healthSummary,
    this.bloodPressure,
    this.bloodSugar,
    this.weight,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Expanded(
          child: _ReadingItem(
            icon: Icons.favorite_rounded,
            label: 'ضغط الدم',
            value: _getBloodPressureValue(),
            unit: 'mmHg',
            evaluation: healthSummary.bloodPressureEvaluation,
          ),
        ),
        tokens.hSpacerSmall,
        Expanded(
          child: _ReadingItem(
            icon: Icons.water_drop_rounded,
            label: 'السكر',
            value: bloodSugar?.displayValue ?? '--',
            unit: 'mg/dL',
            evaluation: healthSummary.bloodSugarEvaluation,
          ),
        ),
        tokens.hSpacerSmall,
        Expanded(
          child: _ReadingItem(
            icon: Icons.monitor_weight_rounded,
            label: 'الوزن',
            value: weight?.displayValue ?? '--',
            unit: 'kg',
            evaluation: healthSummary.weightEvaluation,
          ),
        ),
      ],
    );
  }

  String _getBloodPressureValue() {
    if (bloodPressure == null) return '--/--';
    if (bloodPressure!.systolic == null || bloodPressure!.diastolic == null) {
      return '--/--';
    }
    return '${bloodPressure!.systolic}/${bloodPressure!.diastolic}';
  }
}

class _ReadingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final ReadingEvaluation evaluation;

  const _ReadingItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.evaluation,
  });

  bool get _hasData => value != '--' && value != '--/--';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      label: '$label: $value $unit، الحالة: ${evaluation.status}',
      child: Container(
        padding: tokens.paddingAllMedium,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          borderRadius: tokens.borderRadiusMedium,
          border: Border.all(
            color: _hasData
                ? evaluation.color.withValues(alpha: 0.5)
                : AppColors.white.withValues(alpha: 0.2),
            width: _hasData ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconRow(tokens),
            tokens.spacerSmall,
            _buildValueText(tokens),
            SizedBox(height: tokens.spacingTiny),
            _buildLabelText(tokens),
            if (_hasData) _buildStatusBadge(tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildIconRow(DesignTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(tokens.paddingTiny),
          decoration: BoxDecoration(
            color: evaluation.color.withValues(alpha: 0.3),
            borderRadius: tokens.borderRadiusSmall,
          ),
          child: Icon(
            icon,
            color: AppColors.white,
            size: tokens.iconSmall,
          ),
        ),
        if (_hasData)
          Container(
            width: tokens.responsive.scale(8),
            height: tokens.responsive.scale(8),
            decoration: BoxDecoration(
              color: evaluation.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: evaluation.color.withValues(alpha: 0.5),
                  blurRadius: tokens.responsive.scale(4),
                  spreadRadius: tokens.responsive.scale(1),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildValueText(DesignTokens tokens) {
    return Text(
      value,
      style: TextStyle(
        fontSize: tokens.fontSubtitle,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildLabelText(DesignTokens tokens) {
    return Text(
      '$label ($unit)',
      style: TextStyle(
        fontSize: tokens.fontCaption,
        color: AppColors.white.withValues(alpha: 0.7),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusBadge(DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.only(top: tokens.spacingTiny),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.paddingTiny,
          vertical: tokens.spacing2XS,
        ),
        decoration: BoxDecoration(
          color: evaluation.color.withValues(alpha: 0.2),
          borderRadius: tokens.borderRadiusXS,
        ),
        child: Text(
          evaluation.status,
          style: TextStyle(
            fontSize: tokens.fontCaption * 0.85,
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../models/health/health_exports.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../core/app_constants.dart';
import '../../../home/domain/models/health_evaluation.dart';
import '../../../home/domain/services/health_evaluator.dart';

class HealthSuccessDialog extends StatelessWidget {
  final HealthReading reading;
  final VoidCallback onAddAnother;
  final VoidCallback onDone;
  final double? userHeight;

  const HealthSuccessDialog({
    super.key,
    required this.reading,
    required this.onAddAnother,
    required this.onDone,
    this.userHeight,
  });

  static Future<void> show(
    BuildContext context, {
    required HealthReading reading,
    required VoidCallback onAddAnother,
    required VoidCallback onDone,
    double? userHeight,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HealthSuccessDialog(
        reading: reading,
        onAddAnother: onAddAnother,
        onDone: onDone,
        userHeight: userHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: EdgeInsets.all(UIConstants.paddingXl),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSuccessIcon(),
            SizedBox(height: UIConstants.paddingLg),
            _buildTitle(),
            SizedBox(height: UIConstants.paddingSm),
            _buildSubtitle(),
            SizedBox(height: UIConstants.paddingLg),
            _buildReadingSummary(),
            SizedBox(height: UIConstants.paddingMd),
            _buildAdvice(),
          ],
        ),
      ),
      actions: [
        _buildActions(context),
      ],
    );
  }

  /// الحصول على معلومات الحالة - يستخدم BMI للوزن
  _StatusInfo _getStatusInfo() {
    if (reading.type == ReadingType.weight && userHeight != null && userHeight! > 0) {
      final evaluation = HealthEvaluator.evaluateWeight(reading, userHeight!);
      return _StatusInfo(
        status: evaluation.status,
        color: evaluation.color,
        icon: _getIconForLevel(evaluation.level),
        bmi: evaluation.bmi,
        advice: _getWeightAdvice(evaluation.level),
      );
    }

    final status = reading.status;
    return _StatusInfo(
      status: status.nameAr,
      color: status.color,
      icon: status.icon,
      bmi: null,
      advice: reading.advice,
    );
  }

  IconData _getIconForLevel(HealthLevel level) {
    switch (level) {
      case HealthLevel.normal:
        return Icons.check_circle_rounded;
      case HealthLevel.warning:
        return Icons.warning_rounded;
      case HealthLevel.critical:
        return Icons.error_rounded;
    }
  }

  String _getWeightAdvice(HealthLevel level) {
    switch (level) {
      case HealthLevel.critical:
        return 'يُنصح بمراجعة طبيب التغذية لوضع خطة صحية مناسبة.';
      case HealthLevel.warning:
        return 'حاول الحفاظ على نظام غذائي متوازن ومارس الرياضة بانتظام.';
      case HealthLevel.normal:
        return 'وزنك في المعدل الطبيعي. استمر في نمط حياتك الصحي! 💪';
    }
  }

  Widget _buildSuccessIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        color: AppColors.success,
        size: 60,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'تم حفظ القراءة بنجاح! 🎉',
      style: AppTextStyles.h3.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'تم إضافة قراءتك الجديدة',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildReadingSummary() {
    final color = reading.type.color;
    final statusInfo = _getStatusInfo();

    return Container(
      padding: EdgeInsets.all(UIConstants.paddingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                reading.type.emoji,
                style: const TextStyle(fontSize: 30),
              ),
              SizedBox(width: UIConstants.paddingMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reading.displayValueWithUnit,
                    style: AppTextStyles.h3.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusInfo.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusInfo.icon, size: 12, color: statusInfo.color),
                        const SizedBox(width: 4),
                        Text(
                          statusInfo.status,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusInfo.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // عرض BMI للوزن
          if (reading.type == ReadingType.weight && statusInfo.bmi != null) ...[
            SizedBox(height: UIConstants.paddingSm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusInfo.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusInfo.color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calculate_rounded,
                    size: 16,
                    color: statusInfo.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'مؤشر كتلة الجسم (BMI): ${statusInfo.bmi!.toStringAsFixed(1)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusInfo.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvice() {
    final statusInfo = _getStatusInfo();
    final advice = statusInfo.advice;
    
    if (advice.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(UIConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: AppColors.info, size: 24),
          SizedBox(width: UIConstants.paddingSm),
          Expanded(
            child: Text(
              advice,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: UIConstants.paddingMd),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                onAddAnother();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('إضافة أخرى'),
            ),
          ),
          SizedBox(width: UIConstants.paddingSm),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onDone();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('تم'),
            ),
          ),
        ],
      ),
    );
  }
}

/// معلومات الحالة للعرض
class _StatusInfo {
  final String status;
  final Color color;
  final IconData icon;
  final double? bmi;
  final String advice;

  const _StatusInfo({
    required this.status,
    required this.color,
    required this.icon,
    this.bmi,
    required this.advice,
  });
}

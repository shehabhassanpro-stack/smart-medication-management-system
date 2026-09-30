import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../models/health/health_exports.dart';
import '../../../home/domain/models/health_evaluation.dart';
import '../../../home/domain/services/health_evaluator.dart';
import '../../utils/health_readings_utils.dart';

class HealthReadingDetailsSheet extends StatelessWidget {
  final HealthReading reading;
  final VoidCallback onDelete;
  final double? userHeight;

  const HealthReadingDetailsSheet({
    super.key,
    required this.reading,
    required this.onDelete,
    this.userHeight,
  });

  static void show(
    BuildContext context, {
    required HealthReading reading,
    required VoidCallback onDelete,
    double? userHeight,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => HealthReadingDetailsSheet(
        reading: reading,
        onDelete: onDelete,
        userHeight: userHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = reading.type.color;
    final statusInfo = _getStatusInfo();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: 24),
          _buildEmojiIcon(color),
          const SizedBox(height: 20),
          _buildValue(color, statusInfo),
          const SizedBox(height: 8),
          _buildStatusBadge(statusInfo),
          const SizedBox(height: 20),
          _buildDetailsCard(context),
          if (reading.notes != null && reading.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotesCard(),
          ],
          const SizedBox(height: 24),
          _buildAdviceCard(color),
          const SizedBox(height: 24),
          _buildActionButtons(context, color),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
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
      );
    }

    final status = reading.status;
    return _StatusInfo(
      status: status.nameAr,
      color: status.color,
      icon: status.icon,
      bmi: null,
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

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildEmojiIcon(Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          reading.type.emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }

  Widget _buildValue(Color color, _StatusInfo statusInfo) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              reading.displayValue,
              style: AppTextStyles.headlineLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 48,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                reading.type.unit,
                style: AppTextStyles.titleMedium.copyWith(
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        // عرض BMI للوزن
        if (reading.type == ReadingType.weight && statusInfo.bmi != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  size: 18,
                  color: statusInfo.color,
                ),
                const SizedBox(width: 8),
                Text(
                  'مؤشر كتلة الجسم (BMI): ${statusInfo.bmi!.toStringAsFixed(1)}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: statusInfo.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(_StatusInfo statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Icon(statusInfo.icon, size: 18, color: statusInfo.color),
          const SizedBox(width: 8),
          Text(
            statusInfo.status,
            style: AppTextStyles.labelMedium.copyWith(
              color: statusInfo.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'التاريخ',
            value: ArabicDateFormatter.formatDate(reading.timestamp),
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'الوقت',
            value: ArabicDateFormatter.formatTime(reading.timestamp),
          ),
          if (reading.measurementTime != null) ...[
            const Divider(height: 24),
            _buildDetailRow(
              icon: reading.measurementTime!.icon,
              label: 'وقت القياس',
              value: reading.measurementTime!.nameAr,
            ),
          ],
          if (reading.type == ReadingType.bloodPressure) ...[
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.arrow_upward_rounded,
              label: 'الانقباضي',
              value: '${reading.systolic ?? reading.value.toInt()} mmHg',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.arrow_downward_rounded,
              label: 'الانبساطي',
              value: '${reading.diastolic ?? 80} mmHg',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_rounded,
                size: 18,
                color: AppColors.info,
              ),
              const SizedBox(width: 8),
              Text(
                'ملاحظات',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reading.notes!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نصيحة',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getAdvice(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAdvice() {
    // للوزن: نعطي نصيحة بناءً على BMI
    if (reading.type == ReadingType.weight && userHeight != null && userHeight! > 0) {
      final evaluation = HealthEvaluator.evaluateWeight(reading, userHeight!);
      switch (evaluation.level) {
        case HealthLevel.critical:
          return 'يُنصح بمراجعة طبيب التغذية لوضع خطة صحية مناسبة.';
        case HealthLevel.warning:
          return 'حاول الحفاظ على نظام غذائي متوازن ومارس الرياضة بانتظام.';
        case HealthLevel.normal:
          return 'وزنك في المعدل الطبيعي. استمر في نمط حياتك الصحي!';
      }
    }
    return reading.advice;
  }

  Widget _buildActionButtons(BuildContext context, Color color) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('حذف'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('إغلاق'),
          ),
        ),
      ],
    );
  }
}

/// معلومات الحالة للعرض
class _StatusInfo {
  final String status;
  final Color color;
  final IconData icon;
  final double? bmi;

  const _StatusInfo({
    required this.status,
    required this.color,
    required this.icon,
    this.bmi,
  });
}

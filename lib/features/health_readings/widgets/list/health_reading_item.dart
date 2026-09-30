import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../models/health/health_exports.dart';
import '../../../home/domain/models/health_evaluation.dart';
import '../../../home/domain/services/health_evaluator.dart';
import '../../utils/health_readings_utils.dart';

class HealthReadingItem extends StatelessWidget {
  final HealthReading reading;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  
  /// طول المستخدم بالسنتيمتر - مطلوب لحساب BMI للوزن
  final double? userHeight;

  const HealthReadingItem({
    super.key,
    required this.reading,
    required this.onTap,
    required this.onDelete,
    this.userHeight,
  });

  @override
  Widget build(BuildContext context) {
    final color = reading.type.color;
    final statusInfo = _getStatusInfo();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.sm,
        border: Border.all(
          color: statusInfo.needsAttention
              ? statusInfo.color.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildIcon(color),
                const SizedBox(width: 14),
                Expanded(child: _buildInfo(color, statusInfo)),
                const SizedBox(width: 8),
                _buildStatusBadge(statusInfo),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// الحصول على معلومات الحالة - يستخدم BMI للوزن
  _StatusInfo _getStatusInfo() {
    // للوزن: نستخدم HealthEvaluator لحساب BMI
    if (reading.type == ReadingType.weight && userHeight != null && userHeight! > 0) {
      final evaluation = HealthEvaluator.evaluateWeight(reading, userHeight!);
      return _StatusInfo(
        status: evaluation.status,
        color: evaluation.color,
        icon: _getIconForLevel(evaluation.level),
        needsAttention: evaluation.level != HealthLevel.normal,
        bmi: evaluation.bmi,
      );
    }
    
    // لباقي القراءات: نستخدم status من الـ Model
    final status = reading.status;
    return _StatusInfo(
      status: status.nameAr,
      color: status.color,
      icon: status.icon,
      needsAttention: reading.needsAttention,
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

  Widget _buildIcon(Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          reading.type.emoji,
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }

  Widget _buildInfo(Color color, _StatusInfo statusInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              reading.displayValue,
              style: AppTextStyles.titleLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              reading.type.unit,
              style: AppTextStyles.bodySmall.copyWith(
                color: color.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // عرض BMI للوزن
        if (reading.type == ReadingType.weight && statusInfo.bmi != null) ...[
          const SizedBox(height: 2),
          Text(
            'BMI: ${statusInfo.bmi!.toStringAsFixed(1)}',
            style: AppTextStyles.caption.copyWith(
              color: statusInfo.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 14,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                ArabicDateFormatter.relativeTime(reading.timestamp),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (reading.measurementTime != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                reading.measurementTime!.icon,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                reading.measurementTime!.nameAr,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
        if (reading.notes != null && reading.notes!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.note_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  reading.notes!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(_StatusInfo statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: 12, color: statusInfo.color),
          const SizedBox(width: 3),
          Text(
            statusInfo.status,
            style: AppTextStyles.labelSmall.copyWith(
              color: statusInfo.color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'حذف',
                style: TextStyle(color: AppColors.error),
              ),
            ],
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
  final bool needsAttention;
  final double? bmi;

  const _StatusInfo({
    required this.status,
    required this.color,
    required this.icon,
    required this.needsAttention,
    this.bmi,
  });
}

import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/design_tokens.dart';

class TodayScheduleWidget extends StatelessWidget {
  final List<ScheduledDose> doses;
  final ValueChanged<ScheduledDose>? onDoseTap;
  final ValueChanged<ScheduledDose>? onDoseTaken;
  final ValueChanged<ScheduledDose>? onDoseSkipped;
  final VoidCallback? onViewAll;
  final bool showHeader;
  final bool isCompact;
  final int maxVisibleDoses;

  const TodayScheduleWidget({
    super.key,
    required this.doses,
    this.onDoseTap,
    this.onDoseTaken,
    this.onDoseSkipped,
    this.onViewAll,
    this.showHeader = true,
    this.isCompact = false,
    this.maxVisibleDoses = 5,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (doses.isEmpty) {
      return _buildEmptyState(tokens);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: tokens.borderRadiusLG,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHeader) _buildHeader(tokens),
          _buildDosesList(tokens),
          if (doses.length > maxVisibleDoses && onViewAll != null)
            _buildViewAllButton(tokens),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DesignTokens tokens) {
    return Container(
      padding: tokens.paddingAllLG,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: tokens.borderRadiusLG,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: AppColors.success,
            size: tokens.iconXL,
          ),
          SizedBox(height: tokens.spacingSM),
          Text(
            'لا توجد جرعات متبقية اليوم',
            style: TextStyle(
              fontSize: tokens.fontMD,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacingXS),
          Text(
            'أحسنت! لقد أكملت جميع جرعاتك 🎉',
            style: TextStyle(
              fontSize: tokens.fontSM,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(DesignTokens tokens) {
    final pendingCount = doses.where((d) => d.status == DoseStatus.pending).length;
    final completedCount = doses.where((d) => d.status == DoseStatus.taken).length;

    return Container(
      padding: EdgeInsets.all(tokens.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radiusLG),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: tokens.paddingAllSM,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: tokens.borderRadiusSM,
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: AppColors.primary,
              size: tokens.iconMD,
            ),
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جدول اليوم',
                  style: TextStyle(
                    fontSize: tokens.fontMD,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$completedCount مكتملة • $pendingCount متبقية',
                  style: TextStyle(
                    fontSize: tokens.fontSM,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildProgressIndicator(tokens, completedCount, doses.length),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(DesignTokens tokens, int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;
    final color = progress >= 1.0
        ? AppColors.success
        : progress >= 0.5
        ? AppColors.warning
        : AppColors.primary;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: tokens.responsive.scale(44),
          height: tokens.responsive.scale(44),
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: tokens.fontXS,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDosesList(DesignTokens tokens) {
    final visibleDoses = doses.take(maxVisibleDoses).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(tokens.paddingSM),
      itemCount: visibleDoses.length,
      separatorBuilder: (_, __) => SizedBox(height: tokens.spacingXS),
      itemBuilder: (context, index) {
        return _DoseItem(
          dose: visibleDoses[index],
          isCompact: isCompact,
          onTap: () => onDoseTap?.call(visibleDoses[index]),
          onTaken: () => onDoseTaken?.call(visibleDoses[index]),
          onSkipped: () => onDoseSkipped?.call(visibleDoses[index]),
        );
      },
    );
  }

  Widget _buildViewAllButton(DesignTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.paddingSM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: TextButton(
        onPressed: onViewAll,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: tokens.paddingXS),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'عرض الكل (${doses.length})',
              style: TextStyle(
                fontSize: tokens.fontSM,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: tokens.spacingXS),
            Icon(Icons.arrow_forward_rounded, size: tokens.iconSM),
          ],
        ),
      ),
    );
  }
}

class _DoseItem extends StatelessWidget {
  final ScheduledDose dose;
  final bool isCompact;
  final VoidCallback? onTap;
  final VoidCallback? onTaken;
  final VoidCallback? onSkipped;

  const _DoseItem({
    required this.dose,
    this.isCompact = false,
    this.onTap,
    this.onTaken,
    this.onSkipped,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isPending = dose.status == DoseStatus.pending;
    final isTaken = dose.status == DoseStatus.taken;
    final isOverdue = dose.isOverdue;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.all(tokens.paddingSM),
        decoration: BoxDecoration(
          color: _getBackgroundColor(isPending, isTaken, isOverdue),
          borderRadius: tokens.borderRadiusMD,
          border: Border.all(
            color: _getBorderColor(isPending, isTaken, isOverdue),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildTimeColumn(tokens, isOverdue),
            SizedBox(width: tokens.spacingSM),
            Expanded(
              child: _buildMedicineInfo(tokens, isTaken),
            ),
            if (isPending) _buildActions(tokens),
            if (!isPending) _buildStatusIcon(tokens, isTaken),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isPending, bool isTaken, bool isOverdue) {
    if (isTaken) return AppColors.success.withValues(alpha: 0.05);
    if (isOverdue) return AppColors.error.withValues(alpha: 0.05);
    return AppColors.surface;
  }

  Color _getBorderColor(bool isPending, bool isTaken, bool isOverdue) {
    if (isTaken) return AppColors.success.withValues(alpha: 0.2);
    if (isOverdue) return AppColors.error.withValues(alpha: 0.3);
    return AppColors.border;
  }

  Widget _buildTimeColumn(DesignTokens tokens, bool isOverdue) {
    final timeColor = isOverdue ? AppColors.error : AppColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingSM,
        vertical: tokens.paddingXS,
      ),
      decoration: BoxDecoration(
        color: timeColor.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusSM,
      ),
      child: Column(
        children: [
          Icon(
            _getTimeIcon(dose.time),
            color: timeColor,
            size: tokens.iconSM,
          ),
          SizedBox(height: tokens.spacing2XS),
          Text(
            dose.time,
            style: TextStyle(
              fontSize: tokens.fontSM,
              fontWeight: FontWeight.bold,
              color: timeColor,
            ),
          ),
          if (isOverdue)
            Text(
              'فات الموعد',
              style: TextStyle(
                fontSize: tokens.fontXS - 2,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getTimeIcon(String time) {
    final hour = int.tryParse(time.split(':').first) ?? 12;
    if (hour >= 5 && hour < 12) return Icons.wb_sunny_outlined;
    if (hour >= 12 && hour < 17) return Icons.wb_sunny_rounded;
    if (hour >= 17 && hour < 21) return Icons.wb_twilight_rounded;
    return Icons.nights_stay_outlined;
  }

  Widget _buildMedicineInfo(DesignTokens tokens, bool isTaken) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dose.medicineName,
          style: TextStyle(
            fontSize: tokens.fontMD,
            fontWeight: FontWeight.w600,
            color: isTaken ? AppColors.textSecondary : AppColors.textPrimary,
            decoration: isTaken ? TextDecoration.lineThrough : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: tokens.spacing2XS),
        Row(
          children: [
            Icon(
              Icons.medication_rounded,
              color: AppColors.textTertiary,
              size: tokens.iconXS,
            ),
            SizedBox(width: tokens.spacing2XS),
            Text(
              dose.dosage,
              style: TextStyle(
                fontSize: tokens.fontSM,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(DesignTokens tokens) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.close_rounded,
          color: AppColors.textSecondary,
          onTap: () {
            HapticFeedback.lightImpact();
            onSkipped?.call();
          },
          tooltip: 'تخطي',
        ),
        SizedBox(width: tokens.spacingXS),
        _ActionButton(
          icon: Icons.check_rounded,
          color: AppColors.success,
          isPrimary: true,
          onTap: () {
            HapticFeedback.mediumImpact();
            onTaken?.call();
          },
          tooltip: 'تم',
        ),
      ],
    );
  }

  Widget _buildStatusIcon(DesignTokens tokens, bool isTaken) {
    return Container(
      padding: tokens.paddingAllXS,
      decoration: BoxDecoration(
        color: isTaken
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isTaken ? Icons.check_rounded : Icons.remove_rounded,
        color: isTaken ? AppColors.success : AppColors.warning,
        size: tokens.iconSM,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback? onTap;
  final String? tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.isPrimary = false,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: tokens.paddingAllSM,
          decoration: BoxDecoration(
            color: isPrimary ? color : color.withValues(alpha: 0.1),
            borderRadius: tokens.borderRadiusSM,
            border: isPrimary
                ? null
                : Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isPrimary ? AppColors.white : color,
            size: tokens.iconSM,
          ),
        ),
      ),
    );
  }
}

class ScheduledDose {
  final String id;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final String time;
  final DoseStatus status;
  final DateTime scheduledAt;
  final DateTime? takenAt;

  const ScheduledDose({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.time,
    this.status = DoseStatus.pending,
    required this.scheduledAt,
    this.takenAt,
  });

  bool get isOverdue {
    if (status != DoseStatus.pending) return false;
    return DateTime.now().isAfter(scheduledAt);
  }

  ScheduledDose copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    String? dosage,
    String? time,
    DoseStatus? status,
    DateTime? scheduledAt,
    DateTime? takenAt,
  }) {
    return ScheduledDose(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      takenAt: takenAt ?? this.takenAt,
    );
  }
}

enum DoseStatus {
  pending,
  taken,
  skipped,
  missed,
}

extension DoseStatusExtension on DoseStatus {
  String get label {
    switch (this) {
      case DoseStatus.pending:
        return 'قيد الانتظار';
      case DoseStatus.taken:
        return 'تم التناول';
      case DoseStatus.skipped:
        return 'تم التخطي';
      case DoseStatus.missed:
        return 'فائتة';
    }
  }

  Color get color {
    switch (this) {
      case DoseStatus.pending:
        return AppColors.primary;
      case DoseStatus.taken:
        return AppColors.success;
      case DoseStatus.skipped:
        return AppColors.warning;
      case DoseStatus.missed:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case DoseStatus.pending:
        return Icons.schedule_rounded;
      case DoseStatus.taken:
        return Icons.check_circle_rounded;
      case DoseStatus.skipped:
        return Icons.skip_next_rounded;
      case DoseStatus.missed:
        return Icons.cancel_rounded;
    }
  }
}
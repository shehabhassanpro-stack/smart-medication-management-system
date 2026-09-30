import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

class WeeklyProgressCard extends StatelessWidget {
  final WeeklyStats stats;
  final DateTime? userCreatedAt;
  final VoidCallback? onViewDetails;

  const WeeklyProgressCard({
    super.key,
    required this.stats,
    this.userCreatedAt,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      label: 'ملخص الأسبوع: ${stats.completionPercentage}% من الأهداف مكتملة',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: tokens.borderRadiusLarge,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _CardHeader(
              completionPercentage: stats.completionPercentage,
              onViewDetails: onViewDetails,
            ),
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: tokens.paddingAllMedium,
              child: Column(
                children: [
                  _WeekDaysProgress(
                    activeDays: stats.activeDays,
                    userCreatedAt: userCreatedAt,
                  ),
                  SizedBox(height: tokens.spacingMedium),
                  _StatsGrid(stats: stats),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final int completionPercentage;
  final VoidCallback? onViewDetails;

  const _CardHeader({
    required this.completionPercentage,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: tokens.paddingAllMedium,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: tokens.paddingAllSmall,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: tokens.borderRadiusMedium,
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: AppColors.white,
                  size: tokens.iconSmall,
                ),
              ),
              SizedBox(width: tokens.spacingSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملخص الأسبوع',
                    style: TextStyle(
                      fontSize: tokens.fontBody,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _getWeekRange(),
                    style: TextStyle(
                      fontSize: tokens.fontCaption,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _CompletionBadge(percentage: completionPercentage),
              if (onViewDetails != null) ...[
                SizedBox(width: tokens.spacingXS),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onViewDetails!();
                  },
                  child: Container(
                    padding: tokens.paddingAllSmall,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: tokens.borderRadiusFull,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: tokens.fontSmall,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getWeekRange() {
    final now = DateTime.now();
    final today = (now.weekday % 7);
    final startOfWeek = now.subtract(Duration(days: today));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    
    if (startOfWeek.month == endOfWeek.month) {
      return '${startOfWeek.day} - ${endOfWeek.day} ${months[startOfWeek.month - 1]}';
    }
    return '${startOfWeek.day} ${months[startOfWeek.month - 1]} - ${endOfWeek.day} ${months[endOfWeek.month - 1]}';
  }
}

class _CompletionBadge extends StatelessWidget {
  final int percentage;

  const _CompletionBadge({required this.percentage});

  Color get _color {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingSmall,
        vertical: tokens.spacing2XS,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusFull,
        border: Border.all(
          color: _color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            percentage >= 80
                ? Icons.emoji_events_rounded
                : Icons.trending_up_rounded,
            size: tokens.fontSmall,
            color: _color,
          ),
          SizedBox(width: tokens.spacing2XS),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: tokens.fontSmall,
              fontWeight: FontWeight.bold,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

enum DayStatus {
  active,
  today,
  missed,
  future,
  unavailable,
}

class _WeekDaysProgress extends StatelessWidget {
  final List<bool> activeDays;
  final DateTime? userCreatedAt;

  const _WeekDaysProgress({
    required this.activeDays,
    this.userCreatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final days = ['سبت', 'أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع'];
    final now = DateTime.now();
    final today = (now.weekday % 7);
    
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: today));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final dayDate = startOfWeek.add(Duration(days: index));
        final dayStatus = _getDayStatus(
          index: index,
          today: today,
          dayDate: dayDate,
          isActive: index < activeDays.length && activeDays[index],
        );

        return _DayIndicator(
          label: days[index],
          status: dayStatus,
        );
      }),
    );
  }

  DayStatus _getDayStatus({
    required int index,
    required int today,
    required DateTime dayDate,
    required bool isActive,
  }) {
    if (userCreatedAt != null) {
      final createdDate = DateTime(
        userCreatedAt!.year,
        userCreatedAt!.month,
        userCreatedAt!.day,
      );
      
      if (dayDate.isBefore(createdDate)) {
        return DayStatus.unavailable;
      }
    }

    if (isActive) {
      return DayStatus.active;
    }

    if (index == today) {
      return DayStatus.today;
    }

    if (index < today) {
      return DayStatus.missed;
    }

    return DayStatus.future;
  }
}

class _DayIndicator extends StatelessWidget {
  final String label;
  final DayStatus status;

  const _DayIndicator({
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    Color backgroundColor;
    Color textColor;
    Color borderColor;
    IconData? icon;

    switch (status) {
      case DayStatus.active:
        backgroundColor = AppColors.success;
        textColor = AppColors.white;
        borderColor = AppColors.success;
        icon = Icons.check_rounded;
        break;
      case DayStatus.today:
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        borderColor = AppColors.primary;
        break;
      case DayStatus.missed:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        borderColor = AppColors.error.withValues(alpha: 0.3);
        break;
      case DayStatus.future:
        backgroundColor = AppColors.surface;
        textColor = AppColors.textTertiary;
        borderColor = AppColors.border;
        break;
      case DayStatus.unavailable:
        backgroundColor = AppColors.surface;
        textColor = AppColors.textTertiary.withValues(alpha: 0.5);
        borderColor = AppColors.border.withValues(alpha: 0.5);
        break;
    }

    return Column(
      children: [
        Container(
          width: tokens.responsive.scale(36),
          height: tokens.responsive.scale(36),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: status == DayStatus.today ? 2 : 1,
            ),
            boxShadow: status == DayStatus.active
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: textColor,
                    size: tokens.fontBody,
                  )
                : Text(
                    status == DayStatus.unavailable ? '—' : label,
                    style: TextStyle(
                      fontSize: tokens.fontSmall,
                      fontWeight: status == DayStatus.today
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
          ),
        ),
        SizedBox(height: tokens.spacing2XS),
        if (status == DayStatus.today)
          Container(
            width: tokens.responsive.scale(4),
            height: tokens.responsive.scale(4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          )
        else if (status == DayStatus.unavailable)
          Container(
            width: tokens.responsive.scale(4),
            height: tokens.responsive.scale(4),
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final WeeklyStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.medication_rounded,
            label: 'الأدوية',
            value: '${stats.medicinesTaken}/${stats.medicinesTotal}',
            progress: stats.medicinesTotal > 0
                ? stats.medicinesTaken / stats.medicinesTotal
                : 0,
            color: AppColors.success,
          ),
        ),
        SizedBox(width: tokens.spacingSmall),
        Expanded(
          child: _StatItem(
            icon: Icons.monitor_heart_rounded,
            label: 'القراءات',
            value: '${stats.readingsTaken}',
            progress: stats.readingsGoal > 0
                ? stats.readingsTaken / stats.readingsGoal
                : 0,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: tokens.spacingSmall),
        Expanded(
          child: _StatItem(
            icon: Icons.local_fire_department_rounded,
            label: 'الالتزام',
            value: '${stats.streakDays} يوم',
            progress: stats.streakDays / 7,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      padding: tokens.paddingAllSmall,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: tokens.borderRadiusMedium,
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: tokens.iconSmall,
          ),
          SizedBox(height: tokens.spacing2XS),
          Text(
            value,
            style: TextStyle(
              fontSize: tokens.fontBody,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacing2XS),
          Text(
            label,
            style: TextStyle(
              fontSize: tokens.fontXS,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: tokens.spacingXS),
          ClipRRect(
            borderRadius: tokens.borderRadiusFull,
            child: LinearProgressIndicator(
              value: clampedProgress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: tokens.responsive.scale(4),
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyStats {
  final List<bool> activeDays;
  final int medicinesTaken;
  final int medicinesTotal;
  final int readingsTaken;
  final int readingsGoal;
  final int streakDays;

  const WeeklyStats({
    required this.activeDays,
    required this.medicinesTaken,
    required this.medicinesTotal,
    required this.readingsTaken,
    this.readingsGoal = 7,
    required this.streakDays,
  });

  int get completionPercentage {
    if (medicinesTotal == 0 && readingsGoal == 0) return 0;
    
    final medicineProgress = medicinesTotal > 0
        ? (medicinesTaken / medicinesTotal)
        : 0.0;
    final readingsProgress = readingsGoal > 0
        ? (readingsTaken / readingsGoal)
        : 0.0;
    
    return ((medicineProgress + readingsProgress) / 2 * 100).round();
  }

  factory WeeklyStats.empty() => const WeeklyStats(
        activeDays: [false, false, false, false, false, false, false],
        medicinesTaken: 0,
        medicinesTotal: 0,
        readingsTaken: 0,
        streakDays: 0,
      );

  factory WeeklyStats.sample() => const WeeklyStats(
        activeDays: [true, true, true, false, true, false, false],
        medicinesTaken: 12,
        medicinesTotal: 14,
        readingsTaken: 5,
        readingsGoal: 7,
        streakDays: 4,
      );
}

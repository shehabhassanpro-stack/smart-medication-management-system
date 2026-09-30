import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/design_tokens.dart';

class MedicinesStatsBar extends StatelessWidget {
  final int totalMedicines;
  final int activeMedicines;
  final int todayDoses;
  final double adherenceRate;
  final VoidCallback? onStatTap;

  const MedicinesStatsBar({
    super.key,
    this.totalMedicines = 0,
    this.activeMedicines = 0,
    this.todayDoses = 0,
    this.adherenceRate = 0.0,
    this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingMD,
        vertical: tokens.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: tokens.borderRadiusLG,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.medication_rounded,
              label: 'الإجمالي',
              value: totalMedicines.toString(),
              color: AppColors.primary,
              onTap: onStatTap,
            ),
          ),
          _buildDivider(tokens),
          Expanded(
            child: _StatItem(
              icon: Icons.check_circle_rounded,
              label: 'نشط',
              value: activeMedicines.toString(),
              color: AppColors.success,
              onTap: onStatTap,
            ),
          ),
          _buildDivider(tokens),
          Expanded(
            child: _StatItem(
              icon: Icons.today_rounded,
              label: 'اليوم',
              value: todayDoses.toString(),
              color: AppColors.info,
              onTap: onStatTap,
            ),
          ),
          _buildDivider(tokens),
          Expanded(
            child: _StatItem(
              icon: Icons.trending_up_rounded,
              label: 'الالتزام',
              value: '${adherenceRate.toStringAsFixed(0)}%',
              color: _getAdherenceColor(adherenceRate),
              onTap: onStatTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(DesignTokens tokens) {
    return Container(
      width: 1,
      height: tokens.responsive.scale(40),
      margin: EdgeInsets.symmetric(horizontal: tokens.spacingXS),
      color: AppColors.border,
    );
  }

  Color _getAdherenceColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 60) return AppColors.warning;
    return AppColors.error;
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: tokens.paddingAllXS,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: tokens.iconSM,
            ),
          ),
          SizedBox(height: tokens.spacing2XS),
          Text(
            value,
            style: TextStyle(
              fontSize: tokens.fontLG,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: tokens.fontXS,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MedicinesStatsBarExpanded extends StatelessWidget {
  final int totalMedicines;
  final int activeMedicines;
  final int inactiveMedicines;
  final int todayDoses;
  final int takenDoses;
  final int missedDoses;
  final double adherenceRate;
  final int currentStreak;
  final VoidCallback? onViewDetails;

  const MedicinesStatsBarExpanded({
    super.key,
    this.totalMedicines = 0,
    this.activeMedicines = 0,
    this.inactiveMedicines = 0,
    this.todayDoses = 0,
    this.takenDoses = 0,
    this.missedDoses = 0,
    this.adherenceRate = 0.0,
    this.currentStreak = 0,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: tokens.paddingAllMD,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: tokens.borderRadiusLG,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إحصائيات الأدوية',
                style: TextStyle(
                  fontSize: tokens.fontLG,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (onViewDetails != null)
                GestureDetector(
                  onTap: onViewDetails,
                  child: Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontSize: tokens.fontSM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: tokens.spacingMD),
          Row(
            children: [
              Expanded(
                child: _StatCardExpanded(
                  title: 'الأدوية',
                  mainValue: totalMedicines.toString(),
                  subItems: [
                    _SubStatItem('نشط', activeMedicines, AppColors.success),
                    _SubStatItem('متوقف', inactiveMedicines, AppColors.textSecondary),
                  ],
                  icon: Icons.medication_rounded,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: tokens.spacingSM),
              Expanded(
                child: _StatCardExpanded(
                  title: 'جرعات اليوم',
                  mainValue: '$takenDoses/$todayDoses',
                  subItems: [
                    _SubStatItem('تم', takenDoses, AppColors.success),
                    _SubStatItem('فات', missedDoses, AppColors.error),
                  ],
                  icon: Icons.today_rounded,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingSM),
          _AdherenceCard(
            adherenceRate: adherenceRate,
            currentStreak: currentStreak,
          ),
        ],
      ),
    );
  }
}

class _SubStatItem {
  final String label;
  final int value;
  final Color color;

  _SubStatItem(this.label, this.value, this.color);
}

class _StatCardExpanded extends StatelessWidget {
  final String title;
  final String mainValue;
  final List<_SubStatItem> subItems;
  final IconData icon;
  final Color color;

  const _StatCardExpanded({
    required this.title,
    required this.mainValue,
    required this.subItems,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: tokens.paddingAllSM,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: tokens.paddingAllXS,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: tokens.borderRadiusSM,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: tokens.iconSM,
                ),
              ),
              SizedBox(width: tokens.spacingXS),
              Text(
                title,
                style: TextStyle(
                  fontSize: tokens.fontSM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingSM),
          Text(
            mainValue,
            style: TextStyle(
              fontSize: tokens.font2XL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacingXS),
          Row(
            children: subItems.map((item) {
              return Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: tokens.spacing2XS),
                    Text(
                      '${item.value} ${item.label}',
                      style: TextStyle(
                        fontSize: tokens.fontXS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  final double adherenceRate;
  final int currentStreak;

  const _AdherenceCard({
    required this.adherenceRate,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = _getAdherenceColor(adherenceRate);

    return Container(
      padding: tokens.paddingAllSM,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: color,
                      size: tokens.iconSM,
                    ),
                    SizedBox(width: tokens.spacingXS),
                    Text(
                      'معدل الالتزام',
                      style: TextStyle(
                        fontSize: tokens.fontSM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacingXS),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${adherenceRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: tokens.font3XL,
                        fontWeight: FontWeight.bold,
                        color: color,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: tokens.spacingSM),
                    Expanded(
                      child: _buildProgressBar(tokens, color),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: tokens.spacingMD),
          Container(
            width: 1,
            height: tokens.responsive.scale(50),
            color: color.withValues(alpha: 0.2),
          ),
          SizedBox(width: tokens.spacingMD),
          Expanded(
            child: Column(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: currentStreak > 0 ? AppColors.warning : AppColors.textTertiary,
                  size: tokens.iconMD,
                ),
                SizedBox(height: tokens.spacing2XS),
                Text(
                  '$currentStreak',
                  style: TextStyle(
                    fontSize: tokens.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'يوم متتالي',
                  style: TextStyle(
                    fontSize: tokens.fontXS,
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

  Widget _buildProgressBar(DesignTokens tokens, Color color) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerRight,
        widthFactor: (adherenceRate / 100).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Color _getAdherenceColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
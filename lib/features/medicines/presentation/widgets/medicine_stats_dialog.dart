import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/design_tokens.dart';

class MedicineStatsDialog extends StatelessWidget {
  final String medicineName;
  final double adherenceRate;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final int skippedDoses;
  final int currentStreak;
  final int bestStreak;
  final double avgDelayMinutes;
  final Map<String, double>? weeklyAdherence;
  final VoidCallback? onViewHistory;

  const MedicineStatsDialog({
    super.key,
    required this.medicineName,
    required this.adherenceRate,
    required this.totalDoses,
    required this.takenDoses,
    this.missedDoses = 0,
    this.skippedDoses = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.avgDelayMinutes = 0,
    this.weeklyAdherence,
    this.onViewHistory,
  });

  static Future<void> show(
      BuildContext context, {
        required String medicineName,
        required double adherenceRate,
        required int totalDoses,
        required int takenDoses,
        int missedDoses = 0,
        int skippedDoses = 0,
        int currentStreak = 0,
        int bestStreak = 0,
        double avgDelayMinutes = 0,
        Map<String, double>? weeklyAdherence,
        VoidCallback? onViewHistory,
      }) {
    return showDialog(
      context: context,
      builder: (context) => MedicineStatsDialog(
        medicineName: medicineName,
        adherenceRate: adherenceRate,
        totalDoses: totalDoses,
        takenDoses: takenDoses,
        missedDoses: missedDoses,
        skippedDoses: skippedDoses,
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        avgDelayMinutes: avgDelayMinutes,
        weeklyAdherence: weeklyAdherence,
        onViewHistory: onViewHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(tokens.paddingLG),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: tokens.responsive.scale(400),
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: tokens.borderRadiusXL,
          boxShadow: AppShadows.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, tokens),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(tokens.paddingLG),
                child: Column(
                  children: [
                    _buildAdherenceCircle(tokens),
                    SizedBox(height: tokens.spacingLG),
                    _buildDosesGrid(tokens),
                    SizedBox(height: tokens.spacingLG),
                    _buildStreakSection(tokens),
                    if (weeklyAdherence != null) ...[
                      SizedBox(height: tokens.spacingLG),
                      _buildWeeklyChart(tokens),
                    ],
                    SizedBox(height: tokens.spacingLG),
                    _buildAvgDelay(tokens),
                  ],
                ),
              ),
            ),
            _buildFooter(context, tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DesignTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radiusXL),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: tokens.paddingAllSM,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: tokens.borderRadiusMD,
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: AppColors.white,
              size: tokens.iconMD,
            ),
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات الدواء',
                  style: TextStyle(
                    fontSize: tokens.fontLG,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  medicineName,
                  style: TextStyle(
                    fontSize: tokens.fontSM,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.white,
              size: tokens.iconMD,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceCircle(DesignTokens tokens) {
    final color = _getAdherenceColor(adherenceRate);

    return Container(
      padding: tokens.paddingAllLG,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: tokens.borderRadiusLG,
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: tokens.responsive.scale(100),
            height: tokens.responsive.scale(100),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: tokens.responsive.scale(100),
                  height: tokens.responsive.scale(100),
                  child: CircularProgressIndicator(
                    value: adherenceRate / 100,
                    strokeWidth: 10,
                    backgroundColor: color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${adherenceRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: tokens.font2XL,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'التزام',
                      style: TextStyle(
                        fontSize: tokens.fontXS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: tokens.spacingLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAdherenceMessage(adherenceRate),
                  style: TextStyle(
                    fontSize: tokens.fontMD,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                SizedBox(height: tokens.spacingXS),
                Text(
                  _getAdherenceDescription(adherenceRate),
                  style: TextStyle(
                    fontSize: tokens.fontSM,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAdherenceMessage(double rate) {
    if (rate >= 90) return 'ممتاز! 🌟';
    if (rate >= 80) return 'جيد جداً 👍';
    if (rate >= 60) return 'يحتاج تحسين ⚠️';
    return 'يحتاج اهتمام 🔴';
  }

  String _getAdherenceDescription(double rate) {
    if (rate >= 90) return 'أنت ملتزم بشكل رائع بتناول الدواء. استمر!';
    if (rate >= 80) return 'التزامك جيد. حاول الحفاظ على هذا المستوى.';
    if (rate >= 60) return 'هناك مجال للتحسين. حاول ضبط تنبيهات أكثر.';
    return 'الالتزام بالدواء مهم لصحتك. تواصل مع طبيبك.';
  }

  Widget _buildDosesGrid(DesignTokens tokens) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            label: 'تم تناولها',
            value: takenDoses.toString(),
            color: AppColors.success,
          ),
        ),
        SizedBox(width: tokens.spacingSM),
        Expanded(
          child: _StatCard(
            icon: Icons.cancel_rounded,
            label: 'فائتة',
            value: missedDoses.toString(),
            color: AppColors.error,
          ),
        ),
        SizedBox(width: tokens.spacingSM),
        Expanded(
          child: _StatCard(
            icon: Icons.skip_next_rounded,
            label: 'تم تخطيها',
            value: skippedDoses.toString(),
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakSection(DesignTokens tokens) {
    return Container(
      padding: tokens.paddingAllMD,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: tokens.borderRadiusMD,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StreakItem(
              icon: Icons.local_fire_department_rounded,
              label: 'السلسلة الحالية',
              value: '$currentStreak يوم',
              color: currentStreak > 0 ? AppColors.warning : AppColors.textTertiary,
            ),
          ),
          Container(
            width: 1,
            height: tokens.responsive.scale(50),
            color: AppColors.border,
          ),
          Expanded(
            child: _StreakItem(
              icon: Icons.emoji_events_rounded,
              label: 'أفضل سلسلة',
              value: '$bestStreak يوم',
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(DesignTokens tokens) {
    final days = ['سبت', 'أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_view_week_rounded,
              color: AppColors.textSecondary,
              size: tokens.iconSM,
            ),
            SizedBox(width: tokens.spacingXS),
            Text(
              'الأسبوع الحالي',
              style: TextStyle(
                fontSize: tokens.fontMD,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingSM),
        Container(
          padding: tokens.paddingAllMD,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: tokens.borderRadiusMD,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.asMap().entries.map((entry) {
              final rate = weeklyAdherence?[entry.value] ?? 0;
              return _DayBar(
                day: entry.value,
                rate: rate,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAvgDelay(DesignTokens tokens) {
    final isGood = avgDelayMinutes <= 15;

    return Container(
      padding: tokens.paddingAllMD,
      decoration: BoxDecoration(
        color: (isGood ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: (isGood ? AppColors.success : AppColors.warning).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: isGood ? AppColors.success : AppColors.warning,
            size: tokens.iconMD,
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متوسط التأخير',
                  style: TextStyle(
                    fontSize: tokens.fontSM,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  avgDelayMinutes < 1
                      ? 'في الوقت المحدد'
                      : '${avgDelayMinutes.toStringAsFixed(0)} دقيقة',
                  style: TextStyle(
                    fontSize: tokens.fontLG,
                    fontWeight: FontWeight.bold,
                    color: isGood ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isGood ? Icons.thumb_up_rounded : Icons.schedule_rounded,
            color: isGood ? AppColors.success : AppColors.warning,
            size: tokens.iconMD,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, DesignTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.paddingLG),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.border),
                padding: EdgeInsets.symmetric(vertical: tokens.paddingSM),
                shape: RoundedRectangleBorder(
                  borderRadius: tokens.borderRadiusMD,
                ),
              ),
              child: Text(
                'إغلاق',
                style: TextStyle(fontSize: tokens.fontMD),
              ),
            ),
          ),
          if (onViewHistory != null) ...[
            SizedBox(width: tokens.spacingSM),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onViewHistory?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: tokens.paddingSM),
                  shape: RoundedRectangleBorder(
                    borderRadius: tokens.borderRadiusMD,
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.history_rounded, size: tokens.iconSM),
                label: Text(
                  'السجل',
                  style: TextStyle(fontSize: tokens.fontMD),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getAdherenceColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 60) return AppColors.warning;
    return AppColors.error;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: tokens.paddingAllSM,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusMD,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: tokens.iconSM),
          SizedBox(height: tokens.spacing2XS),
          Text(
            value,
            style: TextStyle(
              fontSize: tokens.fontLG,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: tokens.fontXS,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StreakItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StreakItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        Icon(icon, color: color, size: tokens.iconMD),
        SizedBox(height: tokens.spacing2XS),
        Text(
          value,
          style: TextStyle(
            fontSize: tokens.fontLG,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: tokens.fontXS,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DayBar extends StatelessWidget {
  final String day;
  final double rate;

  const _DayBar({
    required this.day,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = rate >= 80
        ? AppColors.success
        : rate >= 50
        ? AppColors.warning
        : rate > 0
        ? AppColors.error
        : AppColors.border;

    return Column(
      children: [
        Container(
          width: tokens.responsive.scale(28),
          height: tokens.responsive.scale(60),
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.3),
            borderRadius: tokens.borderRadiusSM,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: (rate / 100).clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: tokens.borderRadiusSM,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.spacing2XS),
        Text(
          day,
          style: TextStyle(
            fontSize: tokens.fontXS - 2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
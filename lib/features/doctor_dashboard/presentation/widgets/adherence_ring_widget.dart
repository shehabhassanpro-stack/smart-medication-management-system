import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

class AdherenceRingWidget extends StatelessWidget {
  final double adherenceRate; // 0.0 to 100.0

  const AdherenceRingWidget({
    super.key,
    required this.adherenceRate,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    // H3 Fix: When adherence data is unavailable, show a friendly message
    if (adherenceRate < 0) {
      return Container(
        height: 220,
        padding: EdgeInsets.all(tokens.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: tokens.borderRadiusLarge,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.analytics_outlined, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
              SizedBox(height: tokens.spacingSmall),
              Text(
                '\u063a\u064a\u0631 \u0645\u062a\u0648\u0641\u0631 \u062d\u0627\u0644\u064a\u0627\u064b',
                style: TextStyle(
                  fontSize: tokens.fontBody,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: tokens.spacingTiny),
              Text(
                '\u0633\u064a\u062a\u0645 \u062d\u0633\u0627\u0628\u0647 \u0639\u0646\u062f \u062a\u0633\u062c\u064a\u0644 \u062a\u0646\u0627\u0648\u0644 \u0627\u0644\u0623\u062f\u0648\u064a\u0629',
                style: TextStyle(
                  fontSize: tokens.fontSmall,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final isGood = adherenceRate >= 80;
    final isWarning = adherenceRate >= 50 && adherenceRate < 80;
    final color = isGood
        ? AppColors.success
        : (isWarning ? AppColors.warning : AppColors.error);

    return Container(
      height: 220,
      padding: EdgeInsets.all(tokens.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: tokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle circle
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 65,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  color: color.withValues(alpha: 0.15),
                  value: 100,
                  radius: 15,
                  showTitle: false,
                )
              ],
            ),
          ),
          // Foreground active ring
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 65,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  color: color,
                  value: adherenceRate.clamp(0.0, 100.0),
                  radius: 15,
                  showTitle: false,
                ),
                PieChartSectionData(
                  color: Colors.transparent,
                  value: (100.0 - adherenceRate).clamp(0.0, 100.0),
                  radius: 15,
                  showTitle: false,
                ),
              ],
            ),
          ),
          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${adherenceRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: tokens.fontHeadline,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'نسبة الالتزام',
                style: TextStyle(
                  fontSize: tokens.fontSmall,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

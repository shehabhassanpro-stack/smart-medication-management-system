import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../models/health/health_exports.dart';
import '../../utils/health_readings_utils.dart';

class HealthChart extends StatelessWidget {
  final List<HealthReading> readings;
  final ReadingType type;
  final TimePeriod selectedPeriod;

  const HealthChart({
    super.key,
    required this.readings,
    required this.type,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final isBloodPressure = type == ReadingType.bloodPressure;

    final sortedReadings = List<HealthReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final chartReadings = sortedReadings.length > 7
        ? sortedReadings.sublist(sortedReadings.length - 7)
        : sortedReadings;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(color, chartReadings.length),
          const SizedBox(height: 20),
          if (chartReadings.isEmpty)
            _buildEmptyChart(color)
          else if (chartReadings.length == 1)
            _buildSingleReadingView(chartReadings.first, color)
          else
            _buildLineChart(chartReadings, color, isBloodPressure),
          if (chartReadings.length > 1) ...[
            const SizedBox(height: 16),
            _buildLegend(color, isBloodPressure),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Color color, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.show_chart_rounded, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الرسم البياني',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                count > 0 ? 'آخر $count قراءات' : 'لا توجد بيانات',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            selectedPeriod.labelAr,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart(Color color) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insert_chart_outlined_rounded,
                size: 36,
                color: color.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد قراءات',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'أضف قراءات لعرض الرسم البياني',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleReadingView(HealthReading reading, Color color) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                reading.type.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              reading.displayValueWithUnit,
              style: AppTextStyles.h2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: reading.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reading.status.nameAr,
                style: AppTextStyles.labelSmall.copyWith(
                  color: reading.status.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف المزيد من القراءات لعرض الرسم البياني',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(
    List<HealthReading> chartReadings,
    Color color,
    bool isBloodPressure,
  ) {
    final ranges = ChartRanges.forType(type);

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: _buildGridData(color, ranges),
          titlesData: _buildTitlesData(chartReadings, ranges),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (chartReadings.length - 1).toDouble(),
          minY: ranges.min,
          maxY: ranges.max,
          lineTouchData: _buildTouchData(chartReadings, color),
          lineBarsData: _buildLineBarsData(chartReadings, color, isBloodPressure),
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: [
              HorizontalRangeAnnotation(
                y1: ranges.normalMin,
                y2: ranges.normalMax,
                color: AppColors.success.withValues(alpha: 0.1),
              ),
            ],
          ),
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  FlGridData _buildGridData(Color color, ChartRanges ranges) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: ranges.interval,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppColors.border.withValues(alpha: 0.5),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  FlTitlesData _buildTitlesData(List<HealthReading> chartReadings, ChartRanges ranges) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= chartReadings.length) {
              return const SizedBox.shrink();
            }

            final reading = chartReadings[index];
            final day = ArabicDateFormatter.dayShort(reading.timestamp.weekday);

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                day,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: ranges.interval,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineTouchData _buildTouchData(List<HealthReading> chartReadings, Color color) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipRoundedRadius: 12,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tooltipMargin: 8,
        getTooltipColor: (spot) => color.withValues(alpha: 0.95),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final index = spot.x.toInt();
            if (index < 0 || index >= chartReadings.length) return null;

            final reading = chartReadings[index];
            return LineTooltipItem(
              '${reading.displayValueWithUnit}\n',
              AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: ArabicDateFormatter.relativeTime(reading.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
      touchSpotThreshold: 20,
    );
  }

  List<LineChartBarData> _buildLineBarsData(
    List<HealthReading> chartReadings,
    Color color,
    bool isBloodPressure,
  ) {
    final List<LineChartBarData> bars = [];

    final mainSpots = chartReadings.asMap().entries.map((entry) {
      final reading = entry.value;
      final yValue = isBloodPressure
          ? (reading.systolic ?? reading.value).toDouble()
          : reading.value;
      return FlSpot(entry.key.toDouble(), yValue);
    }).toList();

    bars.add(
      LineChartBarData(
        spots: mainSpots,
        isCurved: true,
        curveSmoothness: 0.35,
        preventCurveOverShooting: true,
        color: color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final reading = chartReadings[index];
            return FlDotCirclePainter(
              radius: 5,
              color: Colors.white,
              strokeWidth: 3,
              strokeColor: reading.status.color,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );

    if (isBloodPressure) {
      final diastolicSpots = chartReadings.asMap().entries.map((entry) {
        final reading = entry.value;
        final yValue = (reading.diastolic ?? 80).toDouble();
        return FlSpot(entry.key.toDouble(), yValue);
      }).toList();

      bars.add(
        LineChartBarData(
          spots: diastolicSpots,
          isCurved: true,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          color: color.withValues(alpha: 0.5),
          barWidth: 2,
          isStrokeCapRound: true,
          dashArray: [5, 5],
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: color.withValues(alpha: 0.5),
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return bars;
  }

  Widget _buildLegend(Color color, bool isBloodPressure) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            color: color,
            label: isBloodPressure ? 'انقباضي' : 'القراءة',
            isDashed: false,
          ),
          if (isBloodPressure) ...[
            const SizedBox(width: 24),
            _buildLegendItem(
              color: color.withValues(alpha: 0.5),
              label: 'انبساطي',
              isDashed: true,
            ),
          ],
          const SizedBox(width: 24),
          _buildLegendItem(
            color: AppColors.success,
            label: 'النطاق الطبيعي',
            isArea: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isDashed = false,
    bool isArea = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isArea)
          Container(
            width: 16,
            height: 12,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
          )
        else
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: isDashed ? Colors.transparent : color,
              borderRadius: BorderRadius.circular(2),
            ),
            child: isDashed
                ? Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 3 ? 1 : 0),
                          color: index.isEven ? color : Colors.transparent,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

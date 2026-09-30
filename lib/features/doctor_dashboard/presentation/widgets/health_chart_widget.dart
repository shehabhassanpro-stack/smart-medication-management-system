import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

/// Enterprise health chart widget supporting all 4 reading types:
/// - bloodSugar: single line (mg/dL)
/// - bloodPressure: dual lines — systolic + diastolic (mmHg)
/// - weight: single line (kg)
/// - temperature: single line (°C)
class HealthChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> readings;
  final String selectedType;

  const HealthChartWidget({
    super.key,
    required this.readings,
    this.selectedType = 'bloodSugar',
  });

  // Color palette per reading type
  Color get _primaryColor {
    switch (selectedType) {
      case 'bloodPressure':
        return const Color(0xFF5B8DEF); // Blue
      case 'bloodSugar':
        return const Color(0xFFEF5B5B); // Red
      case 'weight':
        return const Color(0xFF4CAF50); // Green
      case 'temperature':
        return const Color(0xFFFF9800); // Orange
      default:
        return AppColors.primary;
    }
  }

  Color get _secondaryColor {
    // Only used for blood pressure diastolic
    return const Color(0xFF90CAF9); // Light blue
  }

  String get _typeLabel {
    switch (selectedType) {
      case 'bloodPressure':
        return 'ضغط الدم';
      case 'bloodSugar':
        return 'سكر الدم';
      case 'weight':
        return 'الوزن';
      case 'temperature':
        return 'الحرارة';
      default:
        return 'القراءات';
    }
  }

  String get _unit {
    switch (selectedType) {
      case 'bloodPressure':
        return 'mmHg';
      case 'bloodSugar':
        return 'mg/dL';
      case 'weight':
        return 'kg';
      case 'temperature':
        return '°C';
      default:
        return '';
    }
  }

  IconData get _icon {
    switch (selectedType) {
      case 'bloodPressure':
        return Icons.favorite_rounded;
      case 'bloodSugar':
        return Icons.water_drop_rounded;
      case 'weight':
        return Icons.monitor_weight_rounded;
      case 'temperature':
        return Icons.thermostat_rounded;
      default:
        return Icons.show_chart_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    // Filter readings for the selected type
    final filtered = readings
        .where((r) => r['type'] == selectedType && _hasValue(r))
        .toList()
      ..sort((a, b) {
        final ta = a['timestamp'] as Timestamp?;
        final tb = b['timestamp'] as Timestamp?;
        if (ta == null || tb == null) return 0;
        return ta.compareTo(tb);
      });

    if (filtered.isEmpty) {
      return _buildEmptyState(tokens);
    }

    if (filtered.length == 1) {
      return _buildSingleReadingCard(tokens, filtered.first);
    }

    return _buildChartCard(context, tokens, filtered);
  }

  bool _hasValue(Map<String, dynamic> r) {
    if (selectedType == 'bloodPressure') {
      return r['systolic'] is num || r['value'] is num;
    }
    return r['value'] is num;
  }

  Widget _buildEmptyState(DesignTokens tokens) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: _cardDecoration(tokens),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icon, size: 40, color: _primaryColor.withValues(alpha: 0.3)),
          SizedBox(height: tokens.spacingSmall),
          Text(
            'لا توجد قراءات $_typeLabel كافية',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: tokens.fontBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleReadingCard(DesignTokens tokens, Map<String, dynamic> reading) {
    final ts = reading['timestamp'] as Timestamp?;
    final dateStr = ts != null
        ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}'
        : '';

    String valueStr;
    if (selectedType == 'bloodPressure') {
      final sys = reading['systolic'] ?? reading['value'];
      final dia = reading['diastolic'] ?? '--';
      valueStr = '$sys / $dia';
    } else {
      final val = (reading['value'] as num).toDouble();
      valueStr = val.toStringAsFixed(selectedType == 'weight' || selectedType == 'temperature' ? 1 : 0);
    }

    return Container(
      height: 200,
      width: double.infinity,
      padding: EdgeInsets.all(tokens.paddingLarge),
      decoration: _cardDecoration(tokens),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(_typeLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: tokens.fontHeadline, color: AppColors.textPrimary)),
            ],
          ),
          SizedBox(height: tokens.spacingMedium),
          Text(
            '$valueStr $_unit',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _primaryColor),
          ),
          SizedBox(height: tokens.spacingSmall),
          Text(
            'قراءة واحدة بتاريخ $dateStr',
            style: TextStyle(fontSize: tokens.fontSmall, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, DesignTokens tokens, List<Map<String, dynamic>> data) {
    // Build spots
    final List<FlSpot> primarySpots = [];
    final List<FlSpot> secondarySpots = []; // For blood pressure diastolic
    double minX = double.maxFinite, maxX = -double.maxFinite;
    double minY = double.maxFinite, maxY = -double.maxFinite;

    for (final r in data) {
      final ts = (r['timestamp'] as Timestamp).millisecondsSinceEpoch.toDouble();

      if (selectedType == 'bloodPressure') {
        final sys = (r['systolic'] ?? r['value'] as num?)?.toDouble();
        final dia = (r['diastolic'] as num?)?.toDouble();
        if (sys != null) {
          primarySpots.add(FlSpot(ts, sys));
          if (sys < minY) minY = sys;
          if (sys > maxY) maxY = sys;
        }
        if (dia != null) {
          secondarySpots.add(FlSpot(ts, dia));
          if (dia < minY) minY = dia;
        }
      } else {
        final val = (r['value'] as num).toDouble();
        primarySpots.add(FlSpot(ts, val));
        if (val < minY) minY = val;
        if (val > maxY) maxY = val;
      }

      if (ts < minX) minX = ts;
      if (ts > maxX) maxX = ts;
    }

    // Add Y-axis padding
    final yPad = (maxY - minY) * 0.15;
    minY = (minY - yPad).clamp(0, double.maxFinite);
    maxY = maxY + yPad;

    // Build line bars
    final List<LineChartBarData> bars = [
      LineChartBarData(
        spots: primarySpots,
        isCurved: true,
        preventCurveOverShooting: true,
        color: _primaryColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: data.length <= 15,
          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2.5,
            strokeColor: _primaryColor,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              _primaryColor.withValues(alpha: 0.2),
              _primaryColor.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];

    // Add diastolic line for blood pressure
    if (selectedType == 'bloodPressure' && secondarySpots.isNotEmpty) {
      bars.add(LineChartBarData(
        spots: secondarySpots,
        isCurved: true,
        preventCurveOverShooting: true,
        color: _secondaryColor,
        barWidth: 2,
        isStrokeCapRound: true,
        dashArray: [6, 4],
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ));
    }

    return Container(
      height: 280,
      padding: EdgeInsets.all(tokens.paddingLarge),
      decoration: _cardDecoration(tokens),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                _typeLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: tokens.fontHeadline,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _unit,
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: tokens.fontCaption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (selectedType == 'bloodPressure') ...[
            const SizedBox(height: 4),
            Row(
              children: [
                _legendDot(_primaryColor),
                Text(' انقباضي', style: TextStyle(fontSize: tokens.fontCaption, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                _legendDot(_secondaryColor),
                Text(' انبساطي', style: TextStyle(fontSize: tokens.fontCaption, color: AppColors.textSecondary)),
              ],
            ),
          ],
          SizedBox(height: tokens.spacingMedium),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border.withValues(alpha: 0.3),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                          ),
                        );
                      },
                      interval: (maxX - minX) > 0 ? (maxX - minX) / 4 : 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                        final label = selectedType == 'bloodPressure'
                            ? (spot.barIndex == 0 ? 'انقباضي' : 'انبساطي')
                            : _typeLabel;
                        return LineTooltipItem(
                          '$label: ${spot.y.toStringAsFixed(0)} $_unit\n${date.day}/${date.month}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: bars,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  BoxDecoration _cardDecoration(DesignTokens tokens) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: tokens.borderRadiusLarge,
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

/// Numeric table view for health readings.
/// Shows date, value, and color-coded status badge per row.
class ReadingsTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> readings;
  final String selectedType;

  const ReadingsTableWidget({
    super.key,
    required this.readings,
    this.selectedType = 'bloodSugar',
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    // Filter and sort by most recent first
    final filtered = readings
        .where((r) => r['type'] == selectedType)
        .toList()
      ..sort((a, b) {
        final ta = a['timestamp'] as Timestamp?;
        final tb = b['timestamp'] as Timestamp?;
        if (ta == null || tb == null) return 0;
        return tb.compareTo(ta); // Newest first
      });

    if (filtered.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: _cardDecoration(tokens),
        child: Center(
          child: Text(
            'لا توجد قراءات ${_typeLabel(selectedType)}',
            style: TextStyle(color: AppColors.textSecondary, fontSize: tokens.fontBody),
          ),
        ),
      );
    }

    return Container(
      decoration: _cardDecoration(tokens),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row
          Container(
            padding: EdgeInsets.symmetric(horizontal: tokens.paddingMedium, vertical: tokens.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('التاريخ', style: _headerStyle(tokens))),
                Expanded(flex: 3, child: Text('القيمة', style: _headerStyle(tokens), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('الحالة', style: _headerStyle(tokens), textAlign: TextAlign.center)),
              ],
            ),
          ),
          // Data rows
          ...filtered.take(20).map((r) => _buildRow(context, tokens, r)),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, DesignTokens tokens, Map<String, dynamic> reading) {
    final ts = reading['timestamp'] as Timestamp?;
    final date = ts?.toDate();
    final dateStr = date != null
        ? '${date.day}/${date.month}/${date.year}'
        : '--';
    final timeStr = date != null
        ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : '';

    // Value string
    String valueStr;
    if (selectedType == 'bloodPressure') {
      final sys = reading['systolic'] ?? reading['value'] ?? '--';
      final dia = reading['diastolic'] ?? '--';
      valueStr = '$sys / $dia';
    } else {
      final val = reading['value'];
      if (val is num) {
        valueStr = selectedType == 'weight' || selectedType == 'temperature'
            ? val.toDouble().toStringAsFixed(1)
            : val.toDouble().toStringAsFixed(0);
      } else {
        valueStr = '--';
      }
    }
    valueStr += ' ${_unit(selectedType)}';

    // Status evaluation
    final status = _evaluateReading(reading);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: tokens.paddingMedium, vertical: tokens.paddingSmall + 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.15), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr, style: TextStyle(fontSize: tokens.fontSmall, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                Text(timeStr, style: TextStyle(fontSize: tokens.fontCaption, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valueStr,
              style: TextStyle(
                fontSize: tokens.fontBody,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _statusBadge(tokens, status)),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(DesignTokens tokens, _ReadingStatus status) {
    Color bg, fg;
    String label;

    switch (status) {
      case _ReadingStatus.normal:
        bg = AppColors.success.withValues(alpha: 0.1);
        fg = AppColors.success;
        label = 'طبيعي';
      case _ReadingStatus.high:
        bg = AppColors.error.withValues(alpha: 0.1);
        fg = AppColors.error;
        label = 'مرتفع';
      case _ReadingStatus.low:
        bg = AppColors.warning.withValues(alpha: 0.1);
        fg = AppColors.warning;
        label = 'منخفض';
      case _ReadingStatus.unknown:
        bg = AppColors.textSecondary.withValues(alpha: 0.1);
        fg = AppColors.textSecondary;
        label = '--';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: tokens.fontCaption,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _ReadingStatus _evaluateReading(Map<String, dynamic> reading) {
    switch (selectedType) {
      case 'bloodSugar':
        final val = (reading['value'] as num?)?.toDouble();
        if (val == null) return _ReadingStatus.unknown;
        if (val < 70) return _ReadingStatus.low;
        if (val > 180) return _ReadingStatus.high;
        return _ReadingStatus.normal;

      case 'bloodPressure':
        final sys = (reading['systolic'] ?? reading['value'] as num?)?.toDouble();
        if (sys == null) return _ReadingStatus.unknown;
        if (sys < 90) return _ReadingStatus.low;
        if (sys > 140) return _ReadingStatus.high;
        return _ReadingStatus.normal;

      case 'weight':
        // Weight is relative — can't evaluate without height/BMI
        return _ReadingStatus.normal;

      case 'temperature':
        final val = (reading['value'] as num?)?.toDouble();
        if (val == null) return _ReadingStatus.unknown;
        if (val < 36.0) return _ReadingStatus.low;
        if (val > 37.5) return _ReadingStatus.high;
        return _ReadingStatus.normal;

      default:
        return _ReadingStatus.unknown;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'bloodPressure': return 'ضغط الدم';
      case 'bloodSugar': return 'سكر الدم';
      case 'weight': return 'الوزن';
      case 'temperature': return 'الحرارة';
      default: return 'القراءات';
    }
  }

  String _unit(String type) {
    switch (type) {
      case 'bloodPressure': return 'mmHg';
      case 'bloodSugar': return 'mg/dL';
      case 'weight': return 'kg';
      case 'temperature': return '°C';
      default: return '';
    }
  }

  TextStyle _headerStyle(DesignTokens tokens) => TextStyle(
    fontSize: tokens.fontSmall,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  BoxDecoration _cardDecoration(DesignTokens tokens) => BoxDecoration(
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

enum _ReadingStatus { normal, high, low, unknown }

import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../models/health/health_exports.dart';

class HealthStatisticsCalculator {
  HealthStatisticsCalculator._();

  static HealthStatistics calculate(List<HealthReading> readings) {
    if (readings.isEmpty) {
      return const HealthStatistics.empty();
    }

    final values = readings.map((r) => r.value).toList();
    final average = values.reduce((a, b) => a + b) / values.length;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);

    double? trend;
    if (readings.length >= 2) {
      final recent = readings.take((readings.length / 2).ceil()).toList();
      final older = readings.skip((readings.length / 2).ceil()).toList();
      if (recent.isNotEmpty && older.isNotEmpty) {
        final recentAvg = recent.map((r) => r.value).reduce((a, b) => a + b) / recent.length;
        final olderAvg = older.map((r) => r.value).reduce((a, b) => a + b) / older.length;
        trend = ((recentAvg - olderAvg) / olderAvg) * 100;
      }
    }

    return HealthStatistics(
      average: average,
      max: max,
      min: min,
      count: readings.length,
      trend: trend,
    );
  }

  static BloodPressureStatistics calculateBloodPressure(List<HealthReading> readings) {
    final bpReadings = readings.where((r) => r.type == ReadingType.bloodPressure).toList();

    if (bpReadings.isEmpty) {
      return const BloodPressureStatistics.empty();
    }

    final systolicValues = bpReadings.map((r) => r.systolic ?? 0).where((v) => v > 0).toList();
    final diastolicValues = bpReadings.map((r) => r.diastolic ?? 0).where((v) => v > 0).toList();

    if (systolicValues.isEmpty || diastolicValues.isEmpty) {
      return const BloodPressureStatistics.empty();
    }

    return BloodPressureStatistics(
      avgSystolic: systolicValues.reduce((a, b) => a + b) / systolicValues.length,
      avgDiastolic: diastolicValues.reduce((a, b) => a + b) / diastolicValues.length,
      maxSystolic: systolicValues.reduce((a, b) => a > b ? a : b).toDouble(),
      minSystolic: systolicValues.reduce((a, b) => a < b ? a : b).toDouble(),
      maxDiastolic: diastolicValues.reduce((a, b) => a > b ? a : b).toDouble(),
      minDiastolic: diastolicValues.reduce((a, b) => a < b ? a : b).toDouble(),
      count: bpReadings.length,
    );
  }
}

class HealthStatistics {
  final double average;
  final double max;
  final double min;
  final int count;
  final double? trend;

  const HealthStatistics({
    required this.average,
    required this.max,
    required this.min,
    required this.count,
    this.trend,
  });

  const HealthStatistics.empty()
      : average = 0,
        max = 0,
        min = 0,
        count = 0,
        trend = null;

  bool get isEmpty => count == 0;
  bool get isNotEmpty => count > 0;

  String get averageText => isEmpty ? '-' : average.toStringAsFixed(1);
  String get maxText => isEmpty ? '-' : max.toStringAsFixed(1);
  String get minText => isEmpty ? '-' : min.toStringAsFixed(1);

  String get trendText {
    if (trend == null) return '-';
    final sign = trend! > 0 ? '+' : '';
    return '$sign${trend!.toStringAsFixed(1)}%';
  }

  bool get isTrendUp => trend != null && trend! > 0;
  bool get isTrendDown => trend != null && trend! < 0;
  bool get isTrendStable => trend != null && trend!.abs() < 2;
}

class BloodPressureStatistics {
  final double avgSystolic;
  final double avgDiastolic;
  final double maxSystolic;
  final double minSystolic;
  final double maxDiastolic;
  final double minDiastolic;
  final int count;

  const BloodPressureStatistics({
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.maxSystolic,
    required this.minSystolic,
    required this.maxDiastolic,
    required this.minDiastolic,
    required this.count,
  });

  const BloodPressureStatistics.empty()
      : avgSystolic = 0,
        avgDiastolic = 0,
        maxSystolic = 0,
        minSystolic = 0,
        maxDiastolic = 0,
        minDiastolic = 0,
        count = 0;

  bool get isEmpty => count == 0;

  String get averageText => isEmpty ? '-' : '${avgSystolic.toInt()}/${avgDiastolic.toInt()}';
  String get maxText => isEmpty ? '-' : '${maxSystolic.toInt()}/${maxDiastolic.toInt()}';
  String get minText => isEmpty ? '-' : '${minSystolic.toInt()}/${minDiastolic.toInt()}';
}

enum TimePeriod {
  week(days: 7, labelAr: 'أسبوع', labelEn: 'Week'),
  month(days: 30, labelAr: 'شهر', labelEn: 'Month'),
  threeMonths(days: 90, labelAr: '3 أشهر', labelEn: '3 Months'),
  year(days: 365, labelAr: 'سنة', labelEn: 'Year'),
  all(days: 0, labelAr: 'الكل', labelEn: 'All');

  final int days;
  final String labelAr;
  final String labelEn;

  const TimePeriod({
    required this.days,
    required this.labelAr,
    required this.labelEn,
  });

  DateTime? get startDate {
    if (this == TimePeriod.all) return null;
    return DateTime.now().subtract(Duration(days: days));
  }

  static TimePeriod fromString(String value) {
    return TimePeriod.values.firstWhere(
          (p) => p.name == value,
      orElse: () => TimePeriod.week,
    );
  }
}

class ChartRanges {
  final double min;
  final double max;
  final double normalMin;
  final double normalMax;
  final double interval;

  const ChartRanges({
    required this.min,
    required this.max,
    required this.normalMin,
    required this.normalMax,
    required this.interval,
  });

  static ChartRanges forType(ReadingType type) {
    switch (type) {
      case ReadingType.bloodPressure:
        return const ChartRanges(
          min: 40,
          max: 200,
          normalMin: 90,
          normalMax: 120,
          interval: 20,
        );
      case ReadingType.bloodSugar:
        return const ChartRanges(
          min: 40,
          max: 300,
          normalMin: 70,
          normalMax: 140,
          interval: 40,
        );
      case ReadingType.weight:
        return const ChartRanges(
          min: 30,
          max: 150,
          normalMin: 50,
          normalMax: 90,
          interval: 20,
        );
      case ReadingType.temperature:
        return const ChartRanges(
          min: 35,
          max: 42,
          normalMin: 36.1,
          normalMax: 37.2,
          interval: 1,
        );
    }
  }
}

class ArabicDateFormatter {
  ArabicDateFormatter._();

  static const List<String> _weekDaysShort = ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];
  static const List<String> _weekDaysFull = [
    'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
  ];
  static const List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  static String dayShort(int weekday) => _weekDaysShort[(weekday - 1) % 7];
  static String dayFull(int weekday) => _weekDaysFull[(weekday - 1) % 7];
  static String month(int month) => _months[(month - 1) % 12];

  static String formatDate(DateTime date) {
    return '${date.day} ${month(date.month)} ${date.year}';
  }

  static String formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'م' : 'ص';
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} - ${formatTime(date)}';
  }

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks أسبوع';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months شهر';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years سنة';
    }
  }
}

class HealthStateWidgets {
  HealthStateWidgets._();

  static Widget buildLoadingState({Color? color}) {
    final effectiveColor = color ?? AppColors.primary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل القراءات...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  static Widget buildErrorState(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState({
    required ReadingType type,
    required VoidCallback onAdd,
  }) {
    final color = type.color;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
                ),
                shape: BoxShape.circle,
              ),
              child: Text(type.emoji, style: const TextStyle(fontSize: 50)),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد قراءات',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بتسجيل قراءات ${type.nameAr} الخاصة بك',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة قراءة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, size: 48, color: AppColors.warning),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمات مختلفة',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildAuthRequiredState({VoidCallback? onLogin}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              'يرجى تسجيل الدخول',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'تحتاج لتسجيل الدخول لعرض القراءات',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            if (onLogin != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onLogin,
                icon: const Icon(Icons.login_rounded),
                label: const Text('تسجيل الدخول'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SnackBarHelper {
  SnackBarHelper._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppColors.success, Icons.check_circle_rounded);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, AppColors.error, Icons.error_outline_rounded);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, AppColors.warning, Icons.warning_amber_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.info, Icons.info_outline_rounded);
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
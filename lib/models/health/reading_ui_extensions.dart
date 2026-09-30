import 'package:flutter/material.dart';

import 'reading_type.dart';
import 'reading_status.dart';
import 'measurement_time.dart';
import 'health_reading.dart';

extension ReadingTypeUI on ReadingType {
  IconData get icon {
    switch (this) {
      case ReadingType.bloodPressure:
        return Icons.favorite_rounded;
      case ReadingType.bloodSugar:
        return Icons.water_drop_rounded;
      case ReadingType.weight:
        return Icons.monitor_weight_rounded;
      case ReadingType.temperature:
        return Icons.thermostat_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ReadingType.bloodPressure:
        return const Color(0xFFEF4444);
      case ReadingType.bloodSugar:
        return const Color(0xFFF59E0B);
      case ReadingType.weight:
        return const Color(0xFF10B981);
      case ReadingType.temperature:
        return const Color(0xFF8B5CF6);
    }
  }

  Color get lightColor {
    switch (this) {
      case ReadingType.bloodPressure:
        return const Color(0xFFFEE2E2);
      case ReadingType.bloodSugar:
        return const Color(0xFFFEF3C7);
      case ReadingType.weight:
        return const Color(0xFFD1FAE5);
      case ReadingType.temperature:
        return const Color(0xFFEDE9FE);
    }
  }

  Color get darkColor {
    switch (this) {
      case ReadingType.bloodPressure:
        return const Color(0xFFDC2626);
      case ReadingType.bloodSugar:
        return const Color(0xFFD97706);
      case ReadingType.weight:
        return const Color(0xFF059669);
      case ReadingType.temperature:
        return const Color(0xFF7C3AED);
    }
  }

  LinearGradient get gradient {
    return LinearGradient(
      colors: [color, darkColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  BoxDecoration get cardDecoration {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  BoxDecoration get lightCardDecoration {
    return BoxDecoration(
      color: lightColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    );
  }
}

extension ReadingStatusUI on ReadingStatus {
  IconData get icon {
    switch (this) {
      case ReadingStatus.normal:
        return Icons.check_circle_rounded;
      case ReadingStatus.borderline:
        return Icons.warning_rounded;
      case ReadingStatus.high:
        return Icons.arrow_upward_rounded;
      case ReadingStatus.low:
        return Icons.arrow_downward_rounded;
      case ReadingStatus.critical:
        return Icons.error_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ReadingStatus.normal:
        return const Color(0xFF10B981);
      case ReadingStatus.borderline:
        return const Color(0xFFF59E0B);
      case ReadingStatus.high:
        return const Color(0xFFEF4444);
      case ReadingStatus.low:
        return const Color(0xFF3B82F6);
      case ReadingStatus.critical:
        return const Color(0xFF991B1B);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ReadingStatus.normal:
        return const Color(0xFFD1FAE5);
      case ReadingStatus.borderline:
        return const Color(0xFFFEF3C7);
      case ReadingStatus.high:
        return const Color(0xFFFEE2E2);
      case ReadingStatus.low:
        return const Color(0xFFDBEAFE);
      case ReadingStatus.critical:
        return const Color(0xFFFEE2E2);
    }
  }

  BoxDecoration get badgeDecoration {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    );
  }

  Widget badge({double fontSize = 12}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: badgeDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: color),
          const SizedBox(width: 4),
          Text(
            nameAr,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

extension MeasurementTimeUI on MeasurementTime {
  IconData get icon {
    switch (this) {
      case MeasurementTime.fasting:
        return Icons.no_food_rounded;
      case MeasurementTime.beforeMeal:
        return Icons.restaurant_rounded;
      case MeasurementTime.afterMeal:
        return Icons.lunch_dining_rounded;
      case MeasurementTime.beforeSleep:
        return Icons.bedtime_rounded;
      case MeasurementTime.wakeUp:
        return Icons.wb_sunny_rounded;
      case MeasurementTime.random:
        return Icons.schedule_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MeasurementTime.fasting:
        return const Color(0xFF6366F1);
      case MeasurementTime.beforeMeal:
        return const Color(0xFF8B5CF6);
      case MeasurementTime.afterMeal:
        return const Color(0xFFF59E0B);
      case MeasurementTime.beforeSleep:
        return const Color(0xFF3B82F6);
      case MeasurementTime.wakeUp:
        return const Color(0xFFF97316);
      case MeasurementTime.random:
        return const Color(0xFF6B7280);
    }
  }

  Widget chip({bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? color : color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(
            nameAr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}

extension HealthReadingUI on HealthReading {
  Color get typeColor => type.color;

  Color get typeLightColor => type.lightColor;

  LinearGradient get typeGradient => type.gradient;

  IconData get typeIcon => type.icon;

  Color get statusColor => status.color;

  Color get statusBackgroundColor => status.backgroundColor;

  IconData get statusIcon => status.icon;

  Widget get statusBadge => status.badge();

  BoxDecoration get cardDecoration => type.lightCardDecoration;

  BoxDecoration get gradientCardDecoration => type.cardDecoration;
}

class ReadingTrendUI {
  static IconData getIcon(double percentageChange) {
    if (percentageChange > 5) return Icons.trending_up_rounded;
    if (percentageChange < -5) return Icons.trending_down_rounded;
    return Icons.trending_flat_rounded;
  }

  static Color getColor(double percentageChange) {
    if (percentageChange > 5) return const Color(0xFFEF4444);
    if (percentageChange < -5) return const Color(0xFF3B82F6);
    return const Color(0xFF10B981);
  }

  static String getText(double percentageChange) {
    if (percentageChange > 5) return 'مرتفع';
    if (percentageChange < -5) return 'منخفض';
    return 'مستقر';
  }

  static Widget badge(double percentageChange) {
    final color = getColor(percentageChange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getIcon(percentageChange), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${percentageChange.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class HealthReadingTypeConfig {
  final ReadingType type;
  final String name;
  final String emoji;
  final Color color;
  final IconData icon;

  const HealthReadingTypeConfig({
    required this.type,
    required this.name,
    required this.emoji,
    required this.color,
    required this.icon,
  });

  static List<HealthReadingTypeConfig> get all => ReadingType.values
      .map((type) => HealthReadingTypeConfig(
            type: type,
            name: type.nameAr,
            emoji: type.emoji,
            color: type.color,
            icon: type.icon,
          ))
      .toList();

  static HealthReadingTypeConfig fromType(ReadingType type) {
    return HealthReadingTypeConfig(
      type: type,
      name: type.nameAr,
      emoji: type.emoji,
      color: type.color,
      icon: type.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'emoji': emoji,
      'color': color,
      'icon': icon,
    };
  }
}

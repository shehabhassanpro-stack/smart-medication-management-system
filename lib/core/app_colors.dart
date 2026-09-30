import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryContainer = Color(0xFFE3F2FD);

  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryContainer = Color(0xFFE8F5E9);

  static const Color accent = Color(0xFFFF9800);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);

  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  static const Color bloodPressure = Color(0xFFE91E63);
  static const Color bloodSugar = Color(0xFF9C27B0);
  static const Color weight = Color(0xFF4CAF50);
  static const Color temperature = Color(0xFFFF9800);
  static const Color heartRate = Color(0xFFF44336);
  static const Color oxygen = Color(0xFF2196F3);

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFCBD5E1);
  static const Color textDisabled = Color(0xFFE2E8F0);

  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFFF1F5F9);
  static const Color backgroundLight = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color surfaceTint = Color(0xFFE3F2FD);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFFCBD5E1);
  static const Color divider = Color(0xFFE2E8F0);

  static const Color overlayLight = Color(0x0A000000);
  static const Color overlayMedium = Color(0x14000000);
  static const Color overlayDark = Color(0x52000000);
  static const Color overlayScrim = Color(0x99000000);

  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x29000000);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );

  static const LinearGradient medicalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    stops: [0.0, 1.0],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorLight, error],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningLight, warning],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundLight],
  );

  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  static Color byStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
        return success;
      case 'error':
      case 'failed':
      case 'critical':
        return error;
      case 'warning':
      case 'pending':
        return warning;
      case 'info':
      case 'default':
        return info;
      default:
        return textSecondary;
    }
  }

  static Color byReadingType(String type) {
    switch (type.toLowerCase()) {
      case 'blood_pressure':
      case 'bloodpressure':
        return bloodPressure;
      case 'blood_sugar':
      case 'bloodsugar':
      case 'glucose':
        return bloodSugar;
      case 'weight':
        return weight;
      case 'temperature':
        return temperature;
      case 'heart_rate':
      case 'heartrate':
        return heartRate;
      case 'oxygen':
      case 'spo2':
        return oxygen;
      default:
        return primary;
    }
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

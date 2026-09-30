import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    height: 1.12,
    letterSpacing: -0.25,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    height: 1.16,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    height: 1.22,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    height: 1.25,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    height: 1.29,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    height: 1.33,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    height: 1.25,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    height: 1.29,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    height: 1.33,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    height: 1.4,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    height: 1.44,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    height: 1.27,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    height: 1.45,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  static const TextStyle linkSmall = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    height: 1.6,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    textBaseline: TextBaseline.alphabetic,
  );

  static const TextStyle success = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
  );

  static const TextStyle error = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
  );

  static const TextStyle warning = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w600,
    color: AppColors.warning,
  );

  static const TextStyle info = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w600,
    color: AppColors.info,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.15,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  static const TextStyle inputError = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
  );

  static const TextStyle inputHelper = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle readingValueLarge = TextStyle(
    fontSize: 32,
    height: 1.25,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle readingValueMedium = TextStyle(
    fontSize: 24,
    height: 1.33,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle readingValueSmall = TextStyle(
    fontSize: 18,
    height: 1.44,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle readingUnit = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle readingLabel = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle readingStatus = TextStyle(
    fontSize: 13,
    height: 1.38,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle statLarge = TextStyle(
    fontSize: 40,
    height: 1.2,
    letterSpacing: -0.5,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle statMedium = TextStyle(
    fontSize: 28,
    height: 1.29,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle statSmall = TextStyle(
    fontSize: 20,
    height: 1.4,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle doctorName = TextStyle(
    fontSize: 18,
    height: 1.44,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle doctorSpecialty = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle doctorCode = TextStyle(
    fontSize: 13,
    height: 1.38,
    letterSpacing: 1.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    fontFamily: 'monospace',
  );

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    height: 1.4,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle tabLabel = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle tabLabelActive = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle chipLabel = TextStyle(
    fontSize: 13,
    height: 1.38,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontSize: 20,
    height: 1.4,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle dialogContent = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle snackbar = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle emptyStateTitle = TextStyle(
    fontSize: 18,
    height: 1.44,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle emptyStateMessage = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10,
    height: 1.2,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle tooltip = TextStyle(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.25,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withAlpha(TextStyle style, double alpha) {
    return style.copyWith(
      color: style.color?.withValues(alpha: alpha),
    );
  }

  static TextStyle withUnderline(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: style.color,
    );
  }

  static TextStyle withLineThrough(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.lineThrough,
      decorationColor: style.color,
    );
  }

  static TextStyle withShadow(
    TextStyle style, {
    Color? shadowColor,
    Offset? offset,
    double? blur,
  }) {
    return style.copyWith(
      shadows: [
        Shadow(
          color: shadowColor ?? Colors.black26,
          offset: offset ?? const Offset(0, 2),
          blurRadius: blur ?? 4,
        ),
      ],
    );
  }

  static TextStyle responsive(
    TextStyle style,
    BuildContext context, {
    double? minSize,
    double? maxSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseSize = style.fontSize ?? 14;
    final scaleFactor = (screenWidth / 375).clamp(0.85, 1.2);
    var newSize = baseSize * scaleFactor;
    
    if (minSize != null) newSize = newSize.clamp(minSize, double.infinity);
    if (maxSize != null) newSize = newSize.clamp(0, maxSize);
    
    return style.copyWith(fontSize: newSize);
  }

  static TextStyle readingValueColored(Color color) {
    return readingValueLarge.copyWith(color: color);
  }

  static TextStyle statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'taken':
        return success;
      case 'error':
      case 'failed':
      case 'critical':
        return error;
      case 'warning':
      case 'pending':
      case 'missed':
        return warning;
      case 'info':
      case 'active':
      case 'scheduled':
        return info;
      default:
        return bodyMedium;
    }
  }

  static TextStyle readingStyle(String type) {
    switch (type.toLowerCase()) {
      case 'blood_pressure':
      case 'bloodpressure':
        return readingValueColored(AppColors.bloodPressure);
      case 'blood_sugar':
      case 'bloodsugar':
      case 'glucose':
        return readingValueColored(AppColors.bloodSugar);
      case 'weight':
        return readingValueColored(AppColors.weight);
      case 'temperature':
        return readingValueColored(AppColors.temperature);
      case 'heart_rate':
      case 'heartrate':
        return readingValueColored(AppColors.heartRate);
      case 'oxygen':
      case 'spo2':
        return readingValueColored(AppColors.oxygen);
      default:
        return readingValueMedium;
    }
  }

  static TextStyle greetingStyle(String timeOfDay) {
    Color color;
    switch (timeOfDay.toLowerCase()) {
      case 'morning':
        color = const Color(0xFFF59E0B);
        break;
      case 'afternoon':
        color = const Color(0xFF3B82F6);
        break;
      case 'evening':
        color = const Color(0xFF8B5CF6);
        break;
      case 'night':
        color = const Color(0xFF1E293B);
        break;
      default:
        color = AppColors.primary;
    }
    return h2.copyWith(color: color);
  }
}

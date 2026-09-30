import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../../models/health/health_reading.dart';
import '../../../../models/health/reading_status.dart';
import '../models/health_evaluation.dart';

class HealthEvaluator {
  // ═══════════════════════════════════════════════════════════════
  // 🏥 COMPREHENSIVE HEALTH EVALUATION
  // ═══════════════════════════════════════════════════════════════
  static HealthSummary evaluateHealth({
    HealthReading? bloodPressure,
    HealthReading? bloodSugar,
    HealthReading? weight,
    double userHeight = 170.0,
  }) {
    int totalScore = 100;
    int criticalCount = 0;
    int warningCount = 0;
    List<String> issues = [];

    final bpEval = _evaluateReading(bloodPressure);
    totalScore -= bpEval.penalty;
    if (bpEval.isCritical) {
      criticalCount++;
      issues.add('ضغط الدم ${bpEval.status}');
    } else if (bpEval.isWarning) {
      warningCount++;
      issues.add('ضغط الدم ${bpEval.status}');
    }

    final sugarEval = _evaluateReading(bloodSugar);
    totalScore -= sugarEval.penalty;
    if (sugarEval.isCritical) {
      criticalCount++;
      issues.add('سكر الدم ${sugarEval.status}');
    } else if (sugarEval.isWarning) {
      warningCount++;
      issues.add('سكر الدم ${sugarEval.status}');
    }

    final weightEval = _evaluateWeightInternal(weight, userHeight);
    totalScore -= weightEval.penalty;
    if (weightEval.isCritical) {
      criticalCount++;
      issues.add('الوزن ${weightEval.status}');
    } else if (weightEval.isWarning) {
      warningCount++;
      issues.add('الوزن ${weightEval.status}');
    }

    totalScore = totalScore.clamp(0, 100);

    final overallData = _calculateOverallStatus(totalScore, criticalCount, warningCount);

    return HealthSummary(
      status: overallData.$1,
      statusText: overallData.$2,
      description: overallData.$3,
      color: overallData.$4,
      score: totalScore,
      warningCount: warningCount,
      criticalCount: criticalCount,
      issues: issues,
      bloodPressureEvaluation: bpEval,
      bloodSugarEvaluation: sugarEval,
      weightEvaluation: weightEval,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ⚖️ PUBLIC: WEIGHT EVALUATION (للاستخدام في HealthReadingItem)
  // ═══════════════════════════════════════════════════════════════
  /// تقييم الوزن باستخدام BMI
  /// 
  /// يُستخدم هذا الـ method في:
  /// - HealthReadingItem لعرض حالة الوزن الصحيحة
  /// - HealthReadingPreview لعرض معاينة القراءة
  /// 
  /// [reading] - قراءة الوزن
  /// [heightCm] - طول المستخدم بالسنتيمتر
  static ReadingEvaluation evaluateWeight(HealthReading reading, double heightCm) {
    if (reading.value <= 0 || heightCm <= 0) {
      // إرجاع تقييم طبيعي إذا لم تتوفر البيانات
      return ReadingEvaluation(
        status: 'غير محدد',
        color: AppColors.textSecondary,
        penalty: 0,
        level: HealthLevel.normal,
        bmi: null,
      );
    }

    final heightM = heightCm / 100;
    final bmi = reading.value / (heightM * heightM);

    return _getBMIEvaluation(bmi);
  }

  /// تقييم الوزن باستخدام القيمة مباشرة
  /// 
  /// [weightKg] - الوزن بالكيلوجرام
  /// [heightCm] - الطول بالسنتيمتر
  static ReadingEvaluation evaluateWeightFromValues(double weightKg, double heightCm) {
    if (weightKg <= 0 || heightCm <= 0) {
      return ReadingEvaluation(
        status: 'غير محدد',
        color: AppColors.textSecondary,
        penalty: 0,
        level: HealthLevel.normal,
        bmi: null,
      );
    }

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    return _getBMIEvaluation(bmi);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔒 PRIVATE: INTERNAL EVALUATION METHODS
  // ═══════════════════════════════════════════════════════════════
  static ReadingEvaluation _evaluateReading(HealthReading? reading) {
    if (reading == null) {
      return ReadingEvaluation(
        status: 'غير متوفر',
        color: AppColors.textSecondary,
        penalty: 0,
        level: HealthLevel.normal,
      );
    }

    final readingStatus = reading.status;

    switch (readingStatus) {
      case ReadingStatus.critical:
        return ReadingEvaluation(
          status: 'خطر',
          color: AppColors.error,
          penalty: 35,
          level: HealthLevel.critical,
        );
      case ReadingStatus.high:
        return ReadingEvaluation(
          status: 'مرتفع',
          color: AppColors.error,
          penalty: 25,
          level: HealthLevel.critical,
        );
      case ReadingStatus.borderline:
        return ReadingEvaluation(
          status: 'حدّي',
          color: AppColors.warning,
          penalty: 12,
          level: HealthLevel.warning,
        );
      case ReadingStatus.low:
        return ReadingEvaluation(
          status: 'منخفض',
          color: AppColors.warning,
          penalty: 15,
          level: HealthLevel.warning,
        );
      case ReadingStatus.normal:
        return ReadingEvaluation(
          status: 'طبيعي',
          color: AppColors.success,
          penalty: 0,
          level: HealthLevel.normal,
        );
    }
  }

  /// Internal: تقييم الوزن (يقبل null)
  static ReadingEvaluation _evaluateWeightInternal(HealthReading? reading, double heightCm) {
    if (reading == null || reading.value <= 0 || heightCm <= 0) {
      return ReadingEvaluation(
        status: 'غير متوفر',
        color: AppColors.textSecondary,
        penalty: 0,
        level: HealthLevel.normal,
        bmi: null,
      );
    }

    final heightM = heightCm / 100;
    final bmi = reading.value / (heightM * heightM);

    return _getBMIEvaluation(bmi);
  }

  /// الحصول على تقييم BMI
  /// 
  /// معايير منظمة الصحة العالمية (WHO):
  /// - نقص شديد: < 16
  /// - نقص الوزن: 16 - 18.5
  /// - طبيعي: 18.5 - 25
  /// - وزن زائد: 25 - 30
  /// - سمنة: 30 - 35
  /// - سمنة شديدة: 35 - 40
  /// - سمنة مفرطة: >= 40
  static ReadingEvaluation _getBMIEvaluation(double bmi) {
    // سمنة مفرطة - Morbid Obesity (Class III)
    if (bmi >= 40) {
      return ReadingEvaluation(
        status: 'سمنة مفرطة',
        color: AppColors.error,
        penalty: 30,
        level: HealthLevel.critical,
        bmi: bmi,
      );
    }

    // سمنة شديدة - Severe Obesity (Class II)
    if (bmi >= 35) {
      return ReadingEvaluation(
        status: 'سمنة شديدة',
        color: AppColors.error,
        penalty: 25,
        level: HealthLevel.critical,
        bmi: bmi,
      );
    }

    // سمنة - Obesity (Class I)
    if (bmi >= 30) {
      return ReadingEvaluation(
        status: 'سمنة',
        color: AppColors.warning,
        penalty: 15,
        level: HealthLevel.warning,
        bmi: bmi,
      );
    }

    // وزن زائد - Overweight
    if (bmi >= 25) {
      return ReadingEvaluation(
        status: 'وزن زائد',
        color: AppColors.warning,
        penalty: 8,
        level: HealthLevel.warning,
        bmi: bmi,
      );
    }

    // نقص شديد - Severe Underweight
    if (bmi < 16) {
      return ReadingEvaluation(
        status: 'نقص شديد',
        color: AppColors.error,
        penalty: 25,
        level: HealthLevel.critical,
        bmi: bmi,
      );
    }

    // نقص الوزن - Underweight
    if (bmi < 18.5) {
      return ReadingEvaluation(
        status: 'نقص الوزن',
        color: AppColors.warning,
        penalty: 10,
        level: HealthLevel.warning,
        bmi: bmi,
      );
    }

    // طبيعي - Normal
    return ReadingEvaluation(
      status: 'طبيعي',
      color: AppColors.success,
      penalty: 0,
      level: HealthLevel.normal,
      bmi: bmi,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 OVERALL STATUS CALCULATION
  // ═══════════════════════════════════════════════════════════════
  static (OverallHealthStatus, String, String, Color) _calculateOverallStatus(
    int score,
    int criticalCount,
    int warningCount,
  ) {
    if (criticalCount >= 2 || score < 40) {
      return (
        OverallHealthStatus.needsCare,
        'تحتاج رعاية',
        'يُنصح بمراجعة الطبيب فوراً',
        AppColors.error,
      );
    }

    if (criticalCount == 1 || score < 60) {
      return (
        OverallHealthStatus.needsAttention,
        'تحتاج متابعة',
        'راجع طبيبك قريباً',
        AppColors.error,
      );
    }

    if (warningCount >= 2 || score < 75) {
      return (
        OverallHealthStatus.acceptable,
        'مقبولة',
        'حافظ على نمط حياة صحي',
        AppColors.warning,
      );
    }

    if (warningCount == 1 || score < 90) {
      return (
        OverallHealthStatus.good,
        'جيدة',
        'استمر على هذا النهج',
        AppColors.success,
      );
    }

    return (
      OverallHealthStatus.excellent,
      'ممتازة',
      'صحتك في أفضل حال!',
      AppColors.success,
    );
  }
}

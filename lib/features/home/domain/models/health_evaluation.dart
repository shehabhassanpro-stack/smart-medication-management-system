import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

enum HealthLevel {
  normal,
  warning,
  critical,
}

enum OverallHealthStatus {
  excellent,
  good,
  acceptable,
  needsAttention,
  needsCare,
}

class ReadingEvaluation {
  final String status;
  final Color color;
  final int penalty;
  final HealthLevel level;
  final double? bmi;

  const ReadingEvaluation({
    required this.status,
    required this.color,
    required this.penalty,
    required this.level,
    this.bmi,
  });

  bool get isNormal => level == HealthLevel.normal;
  bool get isWarning => level == HealthLevel.warning;
  bool get isCritical => level == HealthLevel.critical;

  factory ReadingEvaluation.noData() {
    return ReadingEvaluation(
      status: 'لا توجد بيانات',
      color: AppColors.textSecondary,
      penalty: 0,
      level: HealthLevel.normal,
    );
  }
}

class HealthSummary {
  final OverallHealthStatus status;
  final String statusText;
  final String description;
  final Color color;
  final int score;
  final int warningCount;
  final int criticalCount;
  final List<String> issues;
  final ReadingEvaluation bloodPressureEvaluation;
  final ReadingEvaluation bloodSugarEvaluation;
  final ReadingEvaluation weightEvaluation;

  const HealthSummary({
    required this.status,
    required this.statusText,
    required this.description,
    required this.color,
    required this.score,
    required this.warningCount,
    required this.criticalCount,
    required this.issues,
    required this.bloodPressureEvaluation,
    required this.bloodSugarEvaluation,
    required this.weightEvaluation,
  });

  bool get isExcellent => status == OverallHealthStatus.excellent;
  bool get isGood => status == OverallHealthStatus.good;
  bool get isAcceptable => status == OverallHealthStatus.acceptable;
  bool get needsAttention => status == OverallHealthStatus.needsAttention;
  bool get needsCare => status == OverallHealthStatus.needsCare;
  bool get hasIssues => issues.isNotEmpty;
  bool get hasCritical => criticalCount > 0;
  bool get hasWarning => warningCount > 0;

  factory HealthSummary.empty() {
    return HealthSummary(
      status: OverallHealthStatus.good,
      statusText: 'جيدة',
      description: 'أضف قراءاتك الصحية',
      color: AppColors.success,
      score: 100,
      warningCount: 0,
      criticalCount: 0,
      issues: const [],
      bloodPressureEvaluation: ReadingEvaluation.noData(),
      bloodSugarEvaluation: ReadingEvaluation.noData(),
      weightEvaluation: ReadingEvaluation.noData(),
    );
  }
}
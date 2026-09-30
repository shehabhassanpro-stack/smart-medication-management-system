import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../models/health/health_exports.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../core/app_constants.dart';

class HealthReadingPreview extends StatelessWidget {
  final HealthReading reading;
  final Animation<double>? animation;
  final double? userHeight;

  const HealthReadingPreview({
    super.key,
    required this.reading,
    this.animation,
    this.userHeight,
  });

  Color get _color {
    if (_bmiResult != null) {
      return _bmiResult!.color;
    }
    return reading.type.color;
  }

  BmiResult? get _bmiResult {
    if (reading.type != ReadingType.weight) return null;
    if (userHeight == null || userHeight! <= 0) return null;
    if (reading.value <= 0) return null;
    
    return BmiCalculator.calculate(
      weightKg: reading.value,
      heightCm: userHeight!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    if (animation != null) {
      return AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.9 + (0.1 * animation!.value),
            child: Opacity(
              opacity: animation!.value,
              child: child,
            ),
          );
        },
        child: content,
      );
    }

    return content;
  }

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.all(UIConstants.paddingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _color.withValues(alpha: 0.1),
            _color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: UIConstants.paddingLg),
          _buildMainContent(),
          if (_bmiResult != null) ...[
            SizedBox(height: UIConstants.paddingMd),
            _BmiBadge(bmiResult: _bmiResult!),
          ],
          if (reading.advice.isNotEmpty) ...[
            SizedBox(height: UIConstants.paddingMd),
            _buildAdvice(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.preview_rounded, color: _color),
        SizedBox(width: UIConstants.paddingSm),
        Text(
          'معاينة القراءة',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: _color,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          reading.type.emoji,
          style: const TextStyle(fontSize: 40),
        ),
        SizedBox(width: UIConstants.paddingMd),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reading.displayValueWithUnit,
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
                color: _color,
              ),
            ),
            _buildStatusBadge(),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final bmi = _bmiResult;
    
    if (bmi != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bmi.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              bmi.icon,
              size: 14,
              color: bmi.color,
            ),
            const SizedBox(width: 4),
            Text(
              bmi.categoryAr,
              style: AppTextStyles.labelSmall.copyWith(
                color: bmi.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final status = reading.status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 14,
            color: status.color,
          ),
          const SizedBox(width: 4),
          Text(
            status.nameAr,
            style: AppTextStyles.labelSmall.copyWith(
              color: status.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvice() {
    return Container(
      padding: EdgeInsets.all(UIConstants.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: _color, size: 20),
          SizedBox(width: UIConstants.paddingSm),
          Expanded(
            child: Text(
              reading.advice,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiBadge extends StatelessWidget {
  final BmiResult bmiResult;

  const _BmiBadge({required this.bmiResult});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UIConstants.paddingMd),
      decoration: BoxDecoration(
        color: bmiResult.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bmiResult.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bmiResult.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              bmiResult.icon,
              color: bmiResult.color,
              size: 24,
            ),
          ),
          SizedBox(width: UIConstants.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'مؤشر كتلة الجسم (BMI)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: bmiResult.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bmiResult.value.toStringAsFixed(1),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: bmiResult.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  bmiResult.categoryAr,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: bmiResult.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bmiResult.advice,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HealthReadingPreviewCompact extends StatelessWidget {
  final HealthReading reading;
  final double? userHeight;

  const HealthReadingPreviewCompact({
    super.key,
    required this.reading,
    this.userHeight,
  });

  BmiResult? get _bmiResult {
    if (reading.type != ReadingType.weight) return null;
    if (userHeight == null || userHeight! <= 0) return null;
    if (reading.value <= 0) return null;
    
    return BmiCalculator.calculate(
      weightKg: reading.value,
      heightCm: userHeight!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = reading.type.color;
    final status = reading.status;

    return Container(
      padding: EdgeInsets.all(UIConstants.paddingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  reading.type.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(width: UIConstants.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reading.displayValueWithUnit,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      reading.type.nameAr,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(status.icon, size: 12, color: status.color),
                    const SizedBox(width: 4),
                    Text(
                      status.nameAr,
                      style: AppTextStyles.caption.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_bmiResult != null) ...[
            const SizedBox(height: 12),
            _BmiCompactBadge(bmiResult: _bmiResult!),
          ],
        ],
      ),
    );
  }
}

class _BmiCompactBadge extends StatelessWidget {
  final BmiResult bmiResult;

  const _BmiCompactBadge({required this.bmiResult});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bmiResult.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: bmiResult.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            bmiResult.icon,
            color: bmiResult.color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'BMI: ${bmiResult.value.toStringAsFixed(1)}',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: bmiResult.color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: bmiResult.color.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bmiResult.categoryAr,
              style: AppTextStyles.caption.copyWith(
                color: bmiResult.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum BmiCategory {
  severeThinness,
  moderateThinness,
  mildThinness,
  normal,
  overweight,
  obeseClass1,
  obeseClass2,
  obeseClass3,
}

class BmiResult {
  final double value;
  final BmiCategory category;

  const BmiResult({
    required this.value,
    required this.category,
  });

  String get categoryAr {
    switch (category) {
      case BmiCategory.severeThinness:
        return 'نحافة شديدة';
      case BmiCategory.moderateThinness:
        return 'نحافة متوسطة';
      case BmiCategory.mildThinness:
        return 'نحافة خفيفة';
      case BmiCategory.normal:
        return 'وزن طبيعي';
      case BmiCategory.overweight:
        return 'وزن زائد';
      case BmiCategory.obeseClass1:
        return 'سمنة درجة أولى';
      case BmiCategory.obeseClass2:
        return 'سمنة درجة ثانية';
      case BmiCategory.obeseClass3:
        return 'سمنة مفرطة';
    }
  }

  String get advice {
    switch (category) {
      case BmiCategory.severeThinness:
        return 'يُنصح بمراجعة الطبيب فوراً';
      case BmiCategory.moderateThinness:
        return 'زيادة السعرات الحرارية مطلوبة';
      case BmiCategory.mildThinness:
        return 'حاول زيادة وزنك تدريجياً';
      case BmiCategory.normal:
        return 'حافظ على نمط حياتك الصحي';
      case BmiCategory.overweight:
        return 'حاول إنقاص وزنك تدريجياً';
      case BmiCategory.obeseClass1:
        return 'يُنصح باستشارة أخصائي تغذية';
      case BmiCategory.obeseClass2:
        return 'يُنصح بمراجعة الطبيب';
      case BmiCategory.obeseClass3:
        return 'يُنصح بمراجعة الطبيب فوراً';
    }
  }

  Color get color {
    switch (category) {
      case BmiCategory.severeThinness:
        return AppColors.error;
      case BmiCategory.moderateThinness:
        return AppColors.error;
      case BmiCategory.mildThinness:
        return AppColors.warning;
      case BmiCategory.normal:
        return AppColors.success;
      case BmiCategory.overweight:
        return AppColors.warning;
      case BmiCategory.obeseClass1:
        return AppColors.warning;
      case BmiCategory.obeseClass2:
        return AppColors.error;
      case BmiCategory.obeseClass3:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (category) {
      case BmiCategory.severeThinness:
        return Icons.warning_amber_rounded;
      case BmiCategory.moderateThinness:
        return Icons.trending_down_rounded;
      case BmiCategory.mildThinness:
        return Icons.trending_down_rounded;
      case BmiCategory.normal:
        return Icons.check_circle_rounded;
      case BmiCategory.overweight:
        return Icons.trending_up_rounded;
      case BmiCategory.obeseClass1:
        return Icons.trending_up_rounded;
      case BmiCategory.obeseClass2:
        return Icons.warning_amber_rounded;
      case BmiCategory.obeseClass3:
        return Icons.warning_amber_rounded;
    }
  }
}

class BmiCalculator {
  static BmiResult calculate({
    required double weightKg,
    required double heightCm,
  }) {
    if (weightKg <= 0 || heightCm <= 0) {
      return const BmiResult(value: 0, category: BmiCategory.normal);
    }

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    final category = _getCategory(bmi);

    return BmiResult(
      value: bmi,
      category: category,
    );
  }

  static BmiCategory _getCategory(double bmi) {
    if (bmi < 16) return BmiCategory.severeThinness;
    if (bmi < 17) return BmiCategory.moderateThinness;
    if (bmi < 18.5) return BmiCategory.mildThinness;
    if (bmi < 25) return BmiCategory.normal;
    if (bmi < 30) return BmiCategory.overweight;
    if (bmi < 35) return BmiCategory.obeseClass1;
    if (bmi < 40) return BmiCategory.obeseClass2;
    return BmiCategory.obeseClass3;
  }

  static String getRangeText(BmiCategory category) {
    switch (category) {
      case BmiCategory.severeThinness:
        return '< 16';
      case BmiCategory.moderateThinness:
        return '16 - 17';
      case BmiCategory.mildThinness:
        return '17 - 18.5';
      case BmiCategory.normal:
        return '18.5 - 25';
      case BmiCategory.overweight:
        return '25 - 30';
      case BmiCategory.obeseClass1:
        return '30 - 35';
      case BmiCategory.obeseClass2:
        return '35 - 40';
      case BmiCategory.obeseClass3:
        return '> 40';
    }
  }
}

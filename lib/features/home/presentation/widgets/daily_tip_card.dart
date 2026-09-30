import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

enum TipCategory {
  nutrition,
  exercise,
  sleep,
  mental,
  hydration,
  medication,
}

class DailyTipCard extends StatelessWidget {
  final HealthTip? customTip;
  final VoidCallback? onShare;
  final VoidCallback? onDismiss;

  const DailyTipCard({
    super.key,
    this.customTip,
    this.onShare,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tip = customTip ?? _getTodayTip();

    return Semantics(
      label: 'نصيحة اليوم: ${tip.title}. ${tip.description}',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              tip.color.withValues(alpha: 0.15),
              tip.color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: tokens.borderRadiusLarge,
          border: Border.all(
            color: tip.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              left: -20,
              bottom: -20,
              child: Icon(
                tip.icon,
                size: tokens.responsive.scale(80),
                color: tip.color.withValues(alpha: 0.08),
              ),
            ),
            // Content
            Padding(
              padding: tokens.paddingAllMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TipHeader(
                    category: tip.category,
                    color: tip.color,
                    onDismiss: onDismiss,
                  ),
                  SizedBox(height: tokens.spacingSmall),
                  _TipContent(tip: tip),
                  SizedBox(height: tokens.spacingMedium),
                  _TipActions(
                    color: tip.color,
                    onShare: onShare,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  HealthTip _getTodayTip() {
    final tips = _getAllTips();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return tips[dayOfYear % tips.length];
  }

  List<HealthTip> _getAllTips() {
    return [
      // Hydration tips
      HealthTip(
        category: TipCategory.hydration,
        title: 'اشرب الماء بانتظام',
        description: 'حاول شرب 8 أكواب من الماء يومياً للحفاظ على ترطيب جسمك وتحسين وظائف الأعضاء.',
        icon: Icons.water_drop_rounded,
        color: AppColors.info,
      ),
      HealthTip(
        category: TipCategory.hydration,
        title: 'ابدأ يومك بالماء',
        description: 'اشرب كوباً من الماء فور استيقاظك لتنشيط جسمك وتحفيز عملية الأيض.',
        icon: Icons.water_drop_rounded,
        color: AppColors.info,
      ),
      
      // Nutrition tips
      HealthTip(
        category: TipCategory.nutrition,
        title: 'تناول الخضروات الملونة',
        description: 'كلما كان طبقك ملوناً أكثر، كان أكثر فائدة. جرب إضافة خضروات بألوان مختلفة.',
        icon: Icons.restaurant_rounded,
        color: AppColors.success,
      ),
      HealthTip(
        category: TipCategory.nutrition,
        title: 'قلل السكريات المضافة',
        description: 'استبدل الحلويات بالفواكه الطازجة للحصول على الطاقة بطريقة صحية.',
        icon: Icons.no_food_rounded,
        color: AppColors.success,
      ),
      HealthTip(
        category: TipCategory.nutrition,
        title: 'لا تفوت وجبة الإفطار',
        description: 'الإفطار الصحي يمنحك الطاقة ويساعد على التركيز طوال اليوم.',
        icon: Icons.free_breakfast_rounded,
        color: AppColors.success,
      ),

      // Exercise tips
      HealthTip(
        category: TipCategory.exercise,
        title: 'تحرك كل ساعة',
        description: 'قم بالمشي لمدة 5 دقائق كل ساعة لتنشيط الدورة الدموية وتقليل آثار الجلوس الطويل.',
        icon: Icons.directions_walk_rounded,
        color: AppColors.warning,
      ),
      HealthTip(
        category: TipCategory.exercise,
        title: 'مارس التمارين الخفيفة',
        description: '30 دقيقة من المشي السريع يومياً تقلل خطر أمراض القلب بنسبة 30%.',
        icon: Icons.fitness_center_rounded,
        color: AppColors.warning,
      ),
      HealthTip(
        category: TipCategory.exercise,
        title: 'استخدم الدرج',
        description: 'اختر الدرج بدلاً من المصعد لتمرين بسيط وفعال خلال يومك.',
        icon: Icons.stairs_rounded,
        color: AppColors.warning,
      ),

      // Sleep tips
      HealthTip(
        category: TipCategory.sleep,
        title: 'نم 7-8 ساعات',
        description: 'النوم الكافي يعزز المناعة ويحسن التركيز والمزاج.',
        icon: Icons.bedtime_rounded,
        color: AppColors.secondary,
      ),
      HealthTip(
        category: TipCategory.sleep,
        title: 'أغلق الشاشات قبل النوم',
        description: 'تجنب الشاشات قبل النوم بساعة للحصول على نوم أعمق وأفضل.',
        icon: Icons.phonelink_off_rounded,
        color: AppColors.secondary,
      ),
      HealthTip(
        category: TipCategory.sleep,
        title: 'حافظ على روتين النوم',
        description: 'النوم والاستيقاظ في نفس الوقت يومياً يحسن جودة نومك.',
        icon: Icons.schedule_rounded,
        color: AppColors.secondary,
      ),

      // Mental health tips
      HealthTip(
        category: TipCategory.mental,
        title: 'خذ استراحات قصيرة',
        description: 'استراحة 10 دقائق كل ساعتين تحسن إنتاجيتك وتقلل التوتر.',
        icon: Icons.self_improvement_rounded,
        color: AppColors.primary,
      ),
      HealthTip(
        category: TipCategory.mental,
        title: 'مارس التنفس العميق',
        description: '5 دقائق من التنفس العميق يومياً تقلل التوتر وتحسن التركيز.',
        icon: Icons.air_rounded,
        color: AppColors.primary,
      ),
      HealthTip(
        category: TipCategory.mental,
        title: 'تواصل مع أحبائك',
        description: 'العلاقات الاجتماعية القوية تحسن الصحة النفسية والجسدية.',
        icon: Icons.people_rounded,
        color: AppColors.primary,
      ),

      // Medication tips
      HealthTip(
        category: TipCategory.medication,
        title: 'التزم بمواعيد أدويتك',
        description: 'تناول الأدوية في نفس الوقت يومياً يزيد فعاليتها.',
        icon: Icons.medication_rounded,
        color: AppColors.error,
      ),
      HealthTip(
        category: TipCategory.medication,
        title: 'لا تتوقف فجأة',
        description: 'استشر طبيبك قبل إيقاف أي دواء حتى لو شعرت بالتحسن.',
        icon: Icons.medical_services_rounded,
        color: AppColors.error,
      ),
    ];
  }
}

class _TipHeader extends StatelessWidget {
  final TipCategory category;
  final Color color;
  final VoidCallback? onDismiss;

  const _TipHeader({
    required this.category,
    required this.color,
    this.onDismiss,
  });

  String get _categoryName {
    switch (category) {
      case TipCategory.nutrition:
        return 'تغذية';
      case TipCategory.exercise:
        return 'رياضة';
      case TipCategory.sleep:
        return 'نوم';
      case TipCategory.mental:
        return 'صحة نفسية';
      case TipCategory.hydration:
        return 'ترطيب';
      case TipCategory.medication:
        return 'أدوية';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.paddingSmall,
                vertical: tokens.spacing2XS,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: tokens.borderRadiusFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    size: tokens.fontSmall,
                    color: color,
                  ),
                  SizedBox(width: tokens.spacing2XS),
                  Text(
                    'نصيحة اليوم',
                    style: TextStyle(
                      fontSize: tokens.fontXS,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: tokens.spacingXS),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.paddingSmall,
                vertical: tokens.spacing2XS,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: tokens.borderRadiusFull,
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Text(
                _categoryName,
                style: TextStyle(
                  fontSize: tokens.fontXS,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        if (onDismiss != null)
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close_rounded,
              size: tokens.iconSmall,
              color: AppColors.textTertiary,
            ),
          ),
      ],
    );
  }
}

class _TipContent extends StatelessWidget {
  final HealthTip tip;

  const _TipContent({required this.tip});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: tokens.paddingAllSmall,
              decoration: BoxDecoration(
                color: tip.color.withValues(alpha: 0.15),
                borderRadius: tokens.borderRadiusMedium,
              ),
              child: Icon(
                tip.icon,
                color: tip.color,
                size: tokens.iconMedium,
              ),
            ),
            SizedBox(width: tokens.spacingSmall),
            Expanded(
              child: Text(
                tip.title,
                style: TextStyle(
                  fontSize: tokens.fontBody,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingSmall),
        Text(
          tip.description,
          style: TextStyle(
            fontSize: tokens.fontSmall,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _TipActions extends StatelessWidget {
  final Color color;
  final VoidCallback? onShare;

  const _TipActions({
    required this.color,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onShare != null
                ? () {
                    HapticFeedback.lightImpact();
                    onShare!();
                  }
                : null,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: tokens.spacingXS,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: tokens.borderRadiusMedium,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share_rounded,
                    size: tokens.fontSmall,
                    color: color,
                  ),
                  SizedBox(width: tokens.spacing2XS),
                  Text(
                    'مشاركة',
                    style: TextStyle(
                      fontSize: tokens.fontSmall,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HealthTip {
  final TipCategory category;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const HealthTip({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

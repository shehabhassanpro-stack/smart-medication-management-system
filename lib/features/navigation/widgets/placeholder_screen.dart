import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/app_colors.dart';
import '../../../core/design_tokens.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<String>? features;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.features,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: _buildAppBar(tokens),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: tokens.screenPadding,
          child: Column(
            children: [
              tokens.spacerXLarge,
              _IconContainer(icon: icon),
              tokens.spacerLarge,
              _TitleSection(title: title, description: description),
              tokens.spacerLarge,
              const _DevelopmentBadge(),
              tokens.spacerLarge,
              _FeaturesList(
                features: features ?? _getDefaultFeatures(),
              ),
              tokens.spacerXLarge,
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(DesignTokens tokens) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: tokens.fontTitle,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      ),
    );
  }

  List<String> _getDefaultFeatures() {
    switch (title) {
      case 'الأدوية':
        return [
          'عرض قائمة الأدوية الكاملة مع التفاصيل',
          'إضافة وتعديل وحذف الأدوية',
          'تذكير ذكي بمواعيد الأدوية',
          'تتبع الالتزام بالجدول الدوائي',
          'سجل كامل للأدوية المتناولة',
        ];
      case 'القراءات الصحية':
        return [
          'تسجيل قراءات الضغط والسكر والوزن',
          'رسوم بيانية احترافية للمتابعة',
          'تحليل الاتجاهات والتغيرات',
          'تنبيهات للقراءات غير الطبيعية',
          'مشاركة القراءات مع الطبيب',
        ];
      case 'قائمة المرضى':
        return [
          'عرض قائمة المرضى الشاملة',
          'البحث والفلترة المتقدمة',
          'إضافة مرضى جدد بسهولة',
          'عرض السجلات الطبية الكاملة',
          'تحديثات فورية للحالات',
        ];
      case 'التقارير':
        return [
          'تقارير إحصائية شاملة',
          'تحليل بيانات المرضى',
          'رسوم بيانية احترافية',
          'تصدير التقارير بصيغ مختلفة',
          'مقارنة الفترات الزمنية',
        ];
      case 'الملف الشخصي':
        return [
          'إدارة المعلومات الشخصية',
          'تغيير كلمة المرور',
          'إعدادات الإشعارات',
          'تفضيلات التطبيق',
          'تسجيل الخروج',
        ];
      default:
        return [
          'ميزات احترافية قادمة',
          'تجربة مستخدم محسّنة',
          'أداء عالي وسرعة فائقة',
        ];
    }
  }
}

class _IconContainer extends StatelessWidget {
  final IconData icon;

  const _IconContainer({required this.icon});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      label: 'أيقونة الصفحة',
      child: Container(
        padding: tokens.paddingAllXLarge,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.primary.withValues(alpha: 0.05),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: tokens.responsive.scale(20),
              offset: Offset(0, tokens.responsive.scale(10)),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: tokens.icon3XL,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  final String title;
  final String description;

  const _TitleSection({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: tokens.fontHeadline,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.spacingSmall),
        Text(
          description,
          style: TextStyle(
            fontSize: tokens.fontBody,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DevelopmentBadge extends StatelessWidget {
  const _DevelopmentBadge();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      label: 'هذه الميزة قيد التطوير',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.paddingLarge,
          vertical: tokens.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: tokens.borderRadiusFull,
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              color: AppColors.warning,
              size: tokens.iconSmall,
            ),
            SizedBox(width: tokens.spacingSmall),
            Text(
              'هذه الميزة قيد التطوير',
              style: TextStyle(
                fontSize: tokens.fontSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  final List<String> features;

  const _FeaturesList({required this.features});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: tokens.paddingAllLarge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: tokens.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: tokens.responsive.scale(20),
            offset: Offset(0, tokens.responsive.scale(8)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(tokens),
          SizedBox(height: tokens.spacingMedium),
          ...features.map((feature) => _FeatureItem(feature: feature)),
        ],
      ),
    );
  }

  Widget _buildHeader(DesignTokens tokens) {
    return Row(
      children: [
        Container(
          padding: tokens.paddingAllSmall,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: tokens.borderRadiusSmall,
          ),
          child: Icon(
            Icons.star_rounded,
            color: AppColors.primary,
            size: tokens.iconSmall,
          ),
        ),
        SizedBox(width: tokens.spacingSmall),
        Text(
          'المميزات القادمة',
          style: TextStyle(
            fontSize: tokens.fontSubtitle,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String feature;

  const _FeatureItem({required this.feature});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: tokens.spacingXS),
            width: tokens.responsive.scale(8),
            height: tokens.responsive.scale(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.6),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: tokens.spacingSmall),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: tokens.fontSmall,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
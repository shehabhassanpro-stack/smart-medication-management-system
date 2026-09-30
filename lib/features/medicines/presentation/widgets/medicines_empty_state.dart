import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

class MedicinesEmptyState extends StatefulWidget {
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonTap;
  final EmptyStateType type;

  const MedicinesEmptyState({
    super.key,
    this.title = 'لا توجد أدوية',
    this.description = 'لم تقم بإضافة أي أدوية بعد.\nابدأ بإضافة أدويتك لتتمكن من متابعتها.',
    this.buttonText,
    this.onButtonTap,
    this.type = EmptyStateType.noMedicines,
  });

  @override
  State<MedicinesEmptyState> createState() => _MedicinesEmptyStateState();
}

class _MedicinesEmptyStateState extends State<MedicinesEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildContent(tokens),
          ),
        );
      },
    );
  }

  Widget _buildContent(DesignTokens tokens) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(tokens),
            SizedBox(height: tokens.spacingLG),
            _buildTitle(tokens),
            SizedBox(height: tokens.spacingSM),
            _buildDescription(tokens),
            if (widget.buttonText != null && widget.onButtonTap != null) ...[
              SizedBox(height: tokens.spacingXL),
              _buildButton(tokens),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(DesignTokens tokens) {
    final iconData = widget.type.icon;
    final color = widget.type.color;

    return Container(
      padding: EdgeInsets.all(tokens.paddingXL),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(tokens.paddingLG),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: color,
          size: tokens.responsive.scale(48),
        ),
      ),
    );
  }

  Widget _buildTitle(DesignTokens tokens) {
    return Text(
      widget.title,
      style: TextStyle(
        fontSize: tokens.fontXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(DesignTokens tokens) {
    return Text(
      widget.description,
      style: TextStyle(
        fontSize: tokens.fontMD,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildButton(DesignTokens tokens) {
    return ElevatedButton.icon(
      onPressed: widget.onButtonTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.paddingXL,
          vertical: tokens.paddingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: tokens.borderRadiusFull,
        ),
        elevation: 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
      ),
      icon: const Icon(Icons.add_rounded),
      label: Text(
        widget.buttonText!,
        style: TextStyle(
          fontSize: tokens.fontMD,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum EmptyStateType {
  noMedicines,
  noResults,
  noActive,
  noSchedule,
  error,
}

extension EmptyStateTypeExtension on EmptyStateType {
  IconData get icon {
    switch (this) {
      case EmptyStateType.noMedicines:
        return Icons.medication_outlined;
      case EmptyStateType.noResults:
        return Icons.search_off_rounded;
      case EmptyStateType.noActive:
        return Icons.pause_circle_outline_rounded;
      case EmptyStateType.noSchedule:
        return Icons.event_busy_rounded;
      case EmptyStateType.error:
        return Icons.error_outline_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EmptyStateType.noMedicines:
        return AppColors.primary;
      case EmptyStateType.noResults:
        return AppColors.warning;
      case EmptyStateType.noActive:
        return AppColors.textSecondary;
      case EmptyStateType.noSchedule:
        return AppColors.info;
      case EmptyStateType.error:
        return AppColors.error;
    }
  }

  String get defaultTitle {
    switch (this) {
      case EmptyStateType.noMedicines:
        return 'لا توجد أدوية';
      case EmptyStateType.noResults:
        return 'لا توجد نتائج';
      case EmptyStateType.noActive:
        return 'لا توجد أدوية نشطة';
      case EmptyStateType.noSchedule:
        return 'لا توجد جرعات مجدولة';
      case EmptyStateType.error:
        return 'حدث خطأ';
    }
  }

  String get defaultDescription {
    switch (this) {
      case EmptyStateType.noMedicines:
        return 'لم تقم بإضافة أي أدوية بعد.\nابدأ بإضافة أدويتك لتتمكن من متابعتها.';
      case EmptyStateType.noResults:
        return 'لم نتمكن من العثور على نتائج مطابقة.\nجرب البحث بكلمات مختلفة.';
      case EmptyStateType.noActive:
        return 'جميع الأدوية متوقفة حالياً.\nيمكنك تفعيل أي دواء من القائمة.';
      case EmptyStateType.noSchedule:
        return 'لا توجد جرعات مجدولة لهذا اليوم.\nاستمتع بيومك!';
      case EmptyStateType.error:
        return 'حدث خطأ أثناء تحميل البيانات.\nيرجى المحاولة مرة أخرى.';
    }
  }
}

class MedicinesNoResultsState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const MedicinesNoResultsState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return MedicinesEmptyState(
      type: EmptyStateType.noResults,
      title: 'لا توجد نتائج',
      description: 'لم نتمكن من العثور على "$searchQuery".\nجرب البحث بكلمات مختلفة.',
      buttonText: onClearSearch != null ? 'مسح البحث' : null,
      onButtonTap: onClearSearch,
    );
  }
}

class MedicinesTodayEmptyState extends StatelessWidget {
  const MedicinesTodayEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const MedicinesEmptyState(
      type: EmptyStateType.noSchedule,
      title: 'لا توجد جرعات اليوم',
      description: 'لا توجد جرعات مجدولة لهذا اليوم.\nاستمتع بيومك! 🎉',
    );
  }
}
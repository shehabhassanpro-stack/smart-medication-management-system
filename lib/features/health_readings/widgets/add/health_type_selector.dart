import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../../../models/health/health_exports.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/app_constants.dart';

class HealthTypeSelector extends StatelessWidget {
  final ReadingType? selectedType;
  final ValueChanged<ReadingType> onTypeSelected;
  final Animation<double>? animation;

  const HealthTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (animation != null) {
      return AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          final animValue = animation!.value.clamp(0.0, 1.0);
          return Transform.scale(
            scale: 0.8 + (0.2 * animValue),
            child: Opacity(
              opacity: animValue,
              child: child,
            ),
          );
        },
        child: content,
      );
    }

    return content;
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - UIConstants.paddingMd * 2 - UIConstants.paddingSm * 3) / 2;

    return Container(
      padding: EdgeInsets.all(UIConstants.paddingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: UIConstants.paddingLg),
          Wrap(
            spacing: UIConstants.paddingSm,
            runSpacing: UIConstants.paddingSm,
            children: ReadingType.values.map((type) {
              return SizedBox(
                width: cardWidth.clamp(140.0, 180.0),
                child: _TypeCard(
                  type: type,
                  isSelected: selectedType == type,
                  onTap: () => onTypeSelected(type),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.category_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        SizedBox(width: UIConstants.paddingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر نوع القراءة',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'حدد نوع القياس الصحي',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final ReadingType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [color, color.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isSelected ? null : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) _buildSelectedBadge(isSmallScreen),
                SizedBox(height: isSelected ? 4 : 0),
                _buildIcon(color, isSmallScreen),
                SizedBox(height: isSmallScreen ? 6 : 8),
                _buildName(color, isSmallScreen),
                SizedBox(height: isSmallScreen ? 2 : 4),
                _buildUnit(color, isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedBadge(bool isSmallScreen) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'محدد',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 8 : 9,
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.25)
            : color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Text(
        type.emoji,
        style: TextStyle(fontSize: isSmallScreen ? 22 : 26),
      ),
    );
  }

  Widget _buildName(Color color, bool isSmallScreen) {
    return Text(
      type.nameAr,
      style: (isSmallScreen ? AppTextStyles.labelSmall : AppTextStyles.labelMedium).copyWith(
        color: isSelected ? Colors.white : color,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUnit(Color color, bool isSmallScreen) {
    return Text(
      type.unit,
      style: AppTextStyles.caption.copyWith(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.85)
            : color.withValues(alpha: 0.7),
        fontSize: isSmallScreen ? 9 : 10,
      ),
      maxLines: 1,
    );
  }
}
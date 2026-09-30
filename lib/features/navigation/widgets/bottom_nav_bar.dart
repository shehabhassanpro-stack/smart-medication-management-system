import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../core/app_colors.dart';
import '../../../core/design_tokens.dart';
import '../models/navigation_item.dart';

class BottomNavBar extends StatelessWidget {
  final List<NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  bool get _isValidIndex => currentIndex >= 0 && currentIndex < items.length;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final tokens = context.tokens;
    final safeIndex = _isValidIndex ? currentIndex : 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: tokens.responsive.scale(10),
            offset: Offset(0, tokens.responsive.scale(-2)),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: tokens.responsive.scale(56),
            maxHeight: tokens.responsive.scale(72),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.paddingSmall,
              vertical: tokens.paddingTiny,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildNavItems(tokens, safeIndex),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(DesignTokens tokens, int safeIndex) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = safeIndex == index;

      return _NavItem(
        item: item,
        isSelected: isSelected,
        onTap: () => _handleTap(index),
      );
    }).toList();
  }

  void _handleTap(int index) {
    if (index != currentIndex && index >= 0 && index < items.length) {
      HapticFeedback.lightImpact();
      onTap(index);
    }
  }
}

class _NavItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      label: item.accessibilityLabel,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? tokens.paddingMedium : tokens.paddingSmall,
            vertical: tokens.paddingTiny,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.transparent,
            borderRadius: tokens.borderRadiusMedium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(context, tokens),
              SizedBox(height: tokens.spacingXS),
              _buildLabel(context, tokens),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, DesignTokens tokens) {
    return AnimatedScale(
      scale: isSelected ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Icon(
        isSelected ? item.displayIcon : item.icon,
        size: tokens.iconSmall,
        color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildLabel(BuildContext context, DesignTokens tokens) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: tokens.fontXS,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Text(item.label),
    );
  }
}
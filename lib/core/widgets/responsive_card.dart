import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../app_colors.dart';
import '../app_shadows.dart';

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool useTokenPadding;
  final bool useTokenMargin;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Gradient? gradient;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.useTokenPadding = true,
    this.useTokenMargin = false,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    final effectivePadding = padding ??
        (useTokenPadding ? tokens.paddingAllMedium : EdgeInsets.zero);

    final effectiveMargin = margin ??
        (useTokenMargin ? tokens.paddingAllSmall : EdgeInsets.zero);

    final effectiveBorderRadius = borderRadius ?? tokens.borderRadiusMedium;

    final effectiveShadow = boxShadow ?? AppShadows.card;

    final cardContent = Container(
      width: width,
      height: height,
      padding: effectivePadding,
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? AppColors.surface)
            : null,
        gradient: gradient,
        borderRadius: effectiveBorderRadius,
        boxShadow: effectiveShadow,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Alignment? alignment;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Gradient? gradient;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: width,
      height: height,
      padding: padding ?? tokens.paddingAllMedium,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: borderRadius ?? tokens.borderRadiusMedium,
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double mobileAspectRatio;
  final double? tabletAspectRatio;
  final double? desktopAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns,
    this.desktopColumns,
    this.mobileAspectRatio = 1.0,
    this.tabletAspectRatio,
    this.desktopAspectRatio,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    final columns = tokens.gridColumns(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    final aspectRatio = tokens.gridAspectRatio(
      mobile: mobileAspectRatio,
      tablet: tabletAspectRatio,
      desktop: desktopAspectRatio,
    );

    return GridView.count(
      crossAxisCount: columns,
      childAspectRatio: aspectRatio,
      mainAxisSpacing: mainAxisSpacing ?? tokens.spacingMedium,
      crossAxisSpacing: crossAxisSpacing ?? tokens.spacingMedium,
      padding: padding ?? tokens.paddingAllMedium,
      shrinkWrap: shrinkWrap,
      physics: physics,
      children: children,
    );
  }
}

class ResponsiveSpacer extends StatelessWidget {
  final double mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final bool isHorizontal;

  const ResponsiveSpacer({
    super.key,
    this.mobileHeight = 16.0,
    this.tabletHeight,
    this.desktopHeight,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final height = tokens.responsiveValue(
      mobile: mobileHeight,
      tablet: tabletHeight,
      desktop: desktopHeight,
    );

    return SizedBox(
      width: isHorizontal ? height : null,
      height: !isHorizontal ? height : null,
    );
  }
}
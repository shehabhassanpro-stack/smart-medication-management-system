import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_shadows.dart';
import '../utils/responsive_utils.dart';
import '../design_tokens.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? minFontSize;
  final double? maxFontSize;
  final double? letterSpacing;
  final double? height;

  const ResponsiveText(
      this.text, {
        super.key,
        this.style,
        this.fontSize,
        this.fontWeight,
        this.color,
        this.textAlign,
        this.maxLines,
        this.overflow,
        this.minFontSize,
        this.maxFontSize,
        this.letterSpacing,
        this.height,
      });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);

    final scaledFontSize = fontSize != null
        ? responsive.scaleText(fontSize!, minSize: minFontSize, maxSize: maxFontSize)
        : null;

    final effectiveStyle = (style ?? const TextStyle()).copyWith(
      fontSize: scaledFontSize ?? style?.fontSize,
      fontWeight: fontWeight ?? style?.fontWeight,
      color: color ?? style?.color,
      letterSpacing: letterSpacing ?? style?.letterSpacing,
      height: height ?? style?.height,
    );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final double? minSize;
  final double? maxSize;

  const ResponsiveIcon(
      this.icon, {
        super.key,
        this.size,
        this.color,
        this.minSize,
        this.maxSize,
      });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);

    final scaledSize = size != null
        ? responsive.scaleIcon(size!, minSize: minSize, maxSize: maxSize)
        : responsive.scaleIcon(24);

    return Icon(
      icon,
      size: scaledSize,
      color: color,
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableSplash;
  final Clip clipBehavior;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.onTap,
    this.onLongPress,
    this.enableSplash = true,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    final effectivePadding = padding ?? tokens.paddingAllLG;
    final effectiveRadius = borderRadius ?? tokens.radiusLG;
    final effectiveShadow = boxShadow ?? AppShadows.card;
    final effectiveBackground = backgroundColor ?? AppColors.surface;

    Widget cardContent = Container(
      width: width,
      height: height,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: gradient == null ? effectiveBackground : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow: effectiveShadow,
        border: border,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(effectiveRadius),
          splashColor: enableSplash ? null : Colors.transparent,
          highlightColor: enableSplash ? null : Colors.transparent,
          child: cardContent,
        ),
      );
    }

    if (margin != null) {
      cardContent = Padding(
        padding: margin!,
        child: cardContent,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(effectiveRadius),
      clipBehavior: clipBehavior,
      child: cardContent,
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Gradient? gradient;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final bool responsive;

  const ResponsiveContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.constraints,
    this.alignment,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    final effectiveRadius = borderRadius != null
        ? (responsive ? tokens.scale(borderRadius!) : borderRadius!)
        : null;

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: effectiveRadius != null
            ? BorderRadius.circular(effectiveRadius)
            : null,
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );
  }
}

enum ResponsiveButtonSize { small, medium, large }
enum ResponsiveButtonVariant { primary, secondary, outline, ghost }

class ResponsiveButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ResponsiveButtonSize size;
  final ResponsiveButtonVariant variant;
  final IconData? icon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Gradient? gradient;

  const ResponsiveButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.size = ResponsiveButtonSize.medium,
    this.variant = ResponsiveButtonVariant.primary,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    final double height;
    final double fontSize;
    final double iconSize;
    final EdgeInsets padding;

    switch (size) {
      case ResponsiveButtonSize.small:
        height = tokens.buttonHeightSM;
        fontSize = tokens.fontSM;
        iconSize = tokens.iconSM;
        padding = EdgeInsets.symmetric(horizontal: tokens.paddingMD);
        break;
      case ResponsiveButtonSize.medium:
        height = tokens.buttonHeightMD;
        fontSize = tokens.fontMD;
        iconSize = tokens.iconMD;
        padding = EdgeInsets.symmetric(horizontal: tokens.paddingLG);
        break;
      case ResponsiveButtonSize.large:
        height = tokens.buttonHeightLG;
        fontSize = tokens.fontLG;
        iconSize = tokens.iconLG;
        padding = EdgeInsets.symmetric(horizontal: tokens.paddingXL);
        break;
    }

    Color bgColor;
    Color fgColor;
    Border? border;

    switch (variant) {
      case ResponsiveButtonVariant.primary:
        bgColor = backgroundColor ?? AppColors.primary;
        fgColor = textColor ?? Colors.white;
        break;
      case ResponsiveButtonVariant.secondary:
        bgColor = backgroundColor ?? AppColors.primaryContainer;
        fgColor = textColor ?? AppColors.primary;
        break;
      case ResponsiveButtonVariant.outline:
        bgColor = backgroundColor ?? Colors.transparent;
        fgColor = textColor ?? AppColors.primary;
        border = Border.all(color: AppColors.primary, width: 1.5);
        break;
      case ResponsiveButtonVariant.ghost:
        bgColor = backgroundColor ?? Colors.transparent;
        fgColor = textColor ?? AppColors.primary;
        break;
    }

    final effectiveRadius = borderRadius ?? tokens.radiusMD;

    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          SizedBox(width: tokens.spacingSM),
        ] else if (icon != null) ...[
          Icon(icon, size: iconSize, color: fgColor),
          if (text != null) SizedBox(width: tokens.spacingSM),
        ],
        if (child != null)
          child!
        else if (text != null)
          Text(
            text!,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        if (suffixIcon != null && !isLoading) ...[
          SizedBox(width: tokens.spacingSM),
          Icon(suffixIcon, size: iconSize, color: fgColor),
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: gradient == null ? bgColor : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(effectiveRadius),
              border: border,
              boxShadow: variant == ResponsiveButtonVariant.primary
                  ? AppShadows.button
                  : null,
            ),
            child: Center(child: buttonContent),
          ),
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileCrossAxisCount;
  final int? tabletCrossAxisCount;
  final int? desktopCrossAxisCount;
  final double mobileAspectRatio;
  final double? tabletAspectRatio;
  final double? desktopAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileCrossAxisCount = 2,
    this.tabletCrossAxisCount,
    this.desktopCrossAxisCount,
    this.mobileAspectRatio = 1.0,
    this.tabletAspectRatio,
    this.desktopAspectRatio,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    final crossAxisCount = tokens.gridColumns(
      mobile: mobileCrossAxisCount,
      tablet: tabletCrossAxisCount,
      desktop: desktopCrossAxisCount,
    );

    final aspectRatio = tokens.gridAspectRatio(
      mobile: mobileAspectRatio,
      tablet: tabletAspectRatio,
      desktop: desktopAspectRatio,
    );

    final spacing = mainAxisSpacing ?? tokens.spacingMD;
    final crossSpacing = crossAxisSpacing ?? tokens.spacingMD;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: aspectRatio,
      mainAxisSpacing: spacing,
      crossAxisSpacing: crossSpacing,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int mobileCrossAxisCount;
  final int? tabletCrossAxisCount;
  final int? desktopCrossAxisCount;
  final double mobileAspectRatio;
  final double? tabletAspectRatio;
  final double? desktopAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const ResponsiveGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.mobileCrossAxisCount = 2,
    this.tabletCrossAxisCount,
    this.desktopCrossAxisCount,
    this.mobileAspectRatio = 1.0,
    this.tabletAspectRatio,
    this.desktopAspectRatio,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    final crossAxisCount = tokens.gridColumns(
      mobile: mobileCrossAxisCount,
      tablet: tabletCrossAxisCount,
      desktop: desktopCrossAxisCount,
    );

    final aspectRatio = tokens.gridAspectRatio(
      mobile: mobileAspectRatio,
      tablet: tabletAspectRatio,
      desktop: desktopAspectRatio,
    );

    final spacing = mainAxisSpacing ?? tokens.spacingMD;
    final crossSpacing = crossAxisSpacing ?? tokens.spacingMD;

    return GridView.builder(
      controller: controller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        mainAxisSpacing: spacing,
        crossAxisSpacing: crossSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
    );
  }
}

class ResponsiveSpacer extends StatelessWidget {
  final double? height;
  final double? width;
  final double multiplier;

  const ResponsiveSpacer({
    super.key,
    this.height,
    this.width,
    this.multiplier = 1.0,
  });

  const ResponsiveSpacer.xs({super.key})
      : height = 4,
        width = null,
        multiplier = 1.0;

  const ResponsiveSpacer.sm({super.key})
      : height = 8,
        width = null,
        multiplier = 1.0;

  const ResponsiveSpacer.md({super.key})
      : height = 16,
        width = null,
        multiplier = 1.0;

  const ResponsiveSpacer.lg({super.key})
      : height = 24,
        width = null,
        multiplier = 1.0;

  const ResponsiveSpacer.xl({super.key})
      : height = 32,
        width = null,
        multiplier = 1.0;

  const ResponsiveSpacer.hXs({super.key})
      : height = null,
        width = 4,
        multiplier = 1.0;

  const ResponsiveSpacer.hSm({super.key})
      : height = null,
        width = 8,
        multiplier = 1.0;

  const ResponsiveSpacer.hMd({super.key})
      : height = null,
        width = 16,
        multiplier = 1.0;

  const ResponsiveSpacer.hLg({super.key})
      : height = null,
        width = 24,
        multiplier = 1.0;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);

    final scaledHeight = height != null
        ? responsive.scaleSpacing(height! * multiplier)
        : null;
    final scaledWidth = width != null
        ? responsive.scaleSpacing(width! * multiplier)
        : null;

    return SizedBox(
      height: scaledHeight,
      width: scaledWidth,
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? all;
  final double? horizontal;
  final double? vertical;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
    this.all,
    this.horizontal,
    this.vertical,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);

    EdgeInsets effectivePadding;

    if (padding != null) {
      effectivePadding = responsive.scaledPadding(padding!);
    } else if (all != null) {
      final scaled = responsive.scaleSpacing(all!);
      effectivePadding = EdgeInsets.all(scaled);
    } else {
      effectivePadding = EdgeInsets.only(
        left: left != null ? responsive.scaleSpacing(left!) : (horizontal != null ? responsive.scaleSpacing(horizontal!) : 0),
        top: top != null ? responsive.scaleSpacing(top!) : (vertical != null ? responsive.scaleSpacing(vertical!) : 0),
        right: right != null ? responsive.scaleSpacing(right!) : (horizontal != null ? responsive.scaleSpacing(horizontal!) : 0),
        bottom: bottom != null ? responsive.scaleSpacing(bottom!) : (vertical != null ? responsive.scaleSpacing(vertical!) : 0),
      );
    }

    return Padding(
      padding: effectivePadding,
      child: child,
    );
  }
}

class ResponsiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets? minimumPadding;

  const ResponsiveSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimumPadding,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimumPadding ?? EdgeInsets.symmetric(
        horizontal: tokens.paddingLG,
      ),
      child: child,
    );
  }
}

class ResponsiveImage extends StatelessWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;

  const ResponsiveImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.boxShadow,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    final effectiveRadius = borderRadius ?? tokens.radiusMD;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: Image(
          image: image,
          fit: fit,
          width: width,
          height: height,
        ),
      ),
    );
  }
}

class ResponsiveDivider extends StatelessWidget {
  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;
  final bool isVertical;

  const ResponsiveDivider({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    if (isVertical) {
      return VerticalDivider(
        width: height ?? tokens.spacingLG,
        thickness: thickness ?? 1,
        indent: indent,
        endIndent: endIndent,
        color: color ?? AppColors.divider,
      );
    }

    return Divider(
      height: height ?? tokens.spacingLG,
      thickness: thickness ?? 1,
      indent: indent,
      endIndent: endIndent,
      color: color ?? AppColors.divider,
    );
  }
}
import 'package:flutter/material.dart';
import 'dart:math' as math;

enum ScreenSize { xsmall, small, medium, large, xlarge, xxlarge }

enum DeviceType { mobile, tablet, desktop }

enum ScreenOrientation { portrait, landscape }

class Breakpoints {
  Breakpoints._();

  static const double minSupported = 320.0;
  static const double xsmall = 360.0;
  static const double small = 390.0;
  static const double medium = 600.0;
  static const double large = 900.0;
  static const double xlarge = 1200.0;
  static const double xxlarge = 1536.0;

  static const double mobileMax = 599.0;
  static const double tabletMax = 1199.0;
  static const double desktopMin = 1200.0;

  static const double baseWidth = 390.0;
  static const double baseHeight = 844.0;

  static const double minScaleFactor = 0.75;
  static const double maxScaleFactor = 1.3;
  static const double minTextScale = 0.8;
  static const double maxTextScale = 1.25;
  static const double minIconScale = 0.85;
  static const double maxIconScale = 1.2;
}

class ResponsiveUtils {
  final BuildContext context;

  late final Size _screenSize;
  late final double _width;
  late final double _height;
  late final Orientation _orientation;
  late final EdgeInsets _padding;
  late final EdgeInsets _viewPadding;
  late final EdgeInsets _viewInsets;
  late final double _textScaleFactor;
  late final double _devicePixelRatio;

  late final double _widthScale;
  late final double _heightScale;

  ResponsiveUtils(this.context) {
    final mediaQuery = MediaQuery.of(context);

    _screenSize = mediaQuery.size;
    _width = _screenSize.width;
    _height = _screenSize.height;
    _orientation = mediaQuery.orientation;
    _padding = mediaQuery.padding;
    _viewPadding = mediaQuery.viewPadding;
    _viewInsets = mediaQuery.viewInsets;
    _textScaleFactor = mediaQuery.textScaler.scale(1.0);
    _devicePixelRatio = mediaQuery.devicePixelRatio;

    _widthScale = _width / Breakpoints.baseWidth;
    _heightScale = _height / Breakpoints.baseHeight;
  }

  Size get screenSize => _screenSize;
  double get width => _width;
  double get height => _height;
  Orientation get orientation => _orientation;
  double get textScaleFactor => _textScaleFactor;
  double get devicePixelRatio => _devicePixelRatio;

  ScreenSize get screenSizeType {
    if (_width < Breakpoints.xsmall) return ScreenSize.xsmall;
    if (_width < Breakpoints.small) return ScreenSize.small;
    if (_width < Breakpoints.medium) return ScreenSize.medium;
    if (_width < Breakpoints.large) return ScreenSize.large;
    if (_width < Breakpoints.xlarge) return ScreenSize.xlarge;
    return ScreenSize.xxlarge;
  }

  DeviceType get deviceType {
    if (_width <= Breakpoints.mobileMax) return DeviceType.mobile;
    if (_width <= Breakpoints.tabletMax) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  ScreenOrientation get screenOrientation {
    return _orientation == Orientation.portrait
        ? ScreenOrientation.portrait
        : ScreenOrientation.landscape;
  }

  bool get isXSmall => screenSizeType == ScreenSize.xsmall;
  bool get isSmall => screenSizeType == ScreenSize.small;
  bool get isMedium => screenSizeType == ScreenSize.medium;
  bool get isLarge => screenSizeType == ScreenSize.large;
  bool get isXLarge => screenSizeType == ScreenSize.xlarge;
  bool get isXXLarge => screenSizeType == ScreenSize.xxlarge;

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;

  bool get isPortrait => _orientation == Orientation.portrait;
  bool get isLandscape => _orientation == Orientation.landscape;

  bool get isSmallPhone => _width < Breakpoints.small;
  bool get isLargePhone => _width >= Breakpoints.small && _width < Breakpoints.medium;
  bool get isSmallTablet => _width >= Breakpoints.medium && _width < Breakpoints.large;
  bool get isLargeTablet => _width >= Breakpoints.large && _width < Breakpoints.xlarge;

  double get statusBarHeight => _padding.top;
  double get bottomBarHeight => _padding.bottom;
  double get safeAreaTop => _viewPadding.top;
  double get safeAreaBottom => _viewPadding.bottom;
  double get safeAreaLeft => _viewPadding.left;
  double get safeAreaRight => _viewPadding.right;
  double get keyboardHeight => _viewInsets.bottom;

  bool get hasNotch => safeAreaTop > 24;
  bool get isKeyboardVisible => keyboardHeight > 0;

  double get availableHeight => _height - safeAreaTop - safeAreaBottom;
  double get availableWidth => _width - safeAreaLeft - safeAreaRight;

  double scale(double value) {
    final scaleFactor = _widthScale.clamp(
      Breakpoints.minScaleFactor,
      Breakpoints.maxScaleFactor,
    );

    double adjustment = 1.0;
    if (isXSmall) {
      adjustment = 0.9;
    } else if (isXXLarge) {
      adjustment = 1.05;
    }

    final result = value * scaleFactor * adjustment;
    return _roundToHalf(result);
  }

  double scaleHeight(double value) {
    final scaleFactor = _heightScale.clamp(
      Breakpoints.minScaleFactor,
      Breakpoints.maxScaleFactor,
    );

    final result = value * scaleFactor;
    return _roundToHalf(result);
  }

  double scaleText(double fontSize, {double? minSize, double? maxSize}) {
    final scaleFactor = _widthScale.clamp(
      Breakpoints.minTextScale,
      Breakpoints.maxTextScale,
    );

    double result = fontSize * scaleFactor;

    final effectiveMin = minSize ?? (fontSize * 0.75);
    final effectiveMax = maxSize ?? (fontSize * 1.35);
    result = result.clamp(effectiveMin, effectiveMax);

    return _roundToHalf(result);
  }

  double scaleIcon(double iconSize, {double? minSize, double? maxSize}) {
    final scaleFactor = _widthScale.clamp(
      Breakpoints.minIconScale,
      Breakpoints.maxIconScale,
    );

    double result = iconSize * scaleFactor;

    final effectiveMin = minSize ?? (iconSize * 0.8);
    final effectiveMax = maxSize ?? (iconSize * 1.25);
    result = result.clamp(effectiveMin, effectiveMax);

    return result.roundToDouble();
  }

  double scaleRadius(double radius, {double? minRadius, double? maxRadius}) {
    final scaleFactor = _widthScale.clamp(0.9, 1.15);

    double result = radius * scaleFactor;

    final effectiveMin = minRadius ?? (radius * 0.8);
    final effectiveMax = maxRadius ?? (radius * 1.3);
    result = result.clamp(effectiveMin, effectiveMax);

    return result.roundToDouble();
  }

  double scaleSpacing(double spacing, {double? minSpacing, double? maxSpacing}) {
    final scaleFactor = _widthScale.clamp(
      Breakpoints.minScaleFactor,
      Breakpoints.maxScaleFactor,
    );

    double result = spacing * scaleFactor;

    if (minSpacing != null) result = math.max(result, minSpacing);
    if (maxSpacing != null) result = math.min(result, maxSpacing);

    return _roundToEven(result);
  }

  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? (mobile * 1.15);
      case DeviceType.desktop:
        return desktop ?? tablet ?? (mobile * 1.25);
    }
  }

  T valueByScreen<T>({
    required T xsmall,
    T? small,
    T? medium,
    T? large,
    T? xlarge,
    T? xxlarge,
  }) {
    switch (screenSizeType) {
      case ScreenSize.xsmall:
        return xsmall;
      case ScreenSize.small:
        return small ?? xsmall;
      case ScreenSize.medium:
        return medium ?? small ?? xsmall;
      case ScreenSize.large:
        return large ?? medium ?? small ?? xsmall;
      case ScreenSize.xlarge:
        return xlarge ?? large ?? medium ?? small ?? xsmall;
      case ScreenSize.xxlarge:
        return xxlarge ?? xlarge ?? large ?? medium ?? small ?? xsmall;
    }
  }

  T byDevice<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  int gridColumns({
    int mobile = 2,
    int? tablet,
    int? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        if (isXSmall) return math.max(1, mobile - 1);
        return mobile;
      case DeviceType.tablet:
        return tablet ?? (mobile + 1);
      case DeviceType.desktop:
        return desktop ?? tablet ?? (mobile + 2);
    }
  }

  double gridAspectRatio({
    double mobile = 1.0,
    double? tablet,
    double? desktop,
  }) {
    double result;

    switch (deviceType) {
      case DeviceType.mobile:
        if (isLandscape) {
          result = mobile * 1.3;
        } else {
          result = mobile;
        }
        if (isXSmall || isSmall) {
          result *= 0.9;
        }
        break;
      case DeviceType.tablet:
        result = tablet ?? (mobile * 1.1);
        break;
      case DeviceType.desktop:
        result = desktop ?? tablet ?? (mobile * 1.2);
        break;
    }

    return (result * 100).roundToDouble() / 100;
  }

  double gridSpacing({
    double mobile = 12,
    double? tablet,
    double? desktop,
  }) {
    return scale(responsiveValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    ));
  }

  double wp(double percentage) {
    final result = _width * percentage / 100;
    return _roundToHalf(result);
  }

  double hp(double percentage) {
    final result = _height * percentage / 100;
    return _roundToHalf(result);
  }

  double awp(double percentage) {
    final result = availableWidth * percentage / 100;
    return _roundToHalf(result);
  }

  double ahp(double percentage) {
    final result = availableHeight * percentage / 100;
    return _roundToHalf(result);
  }

  EdgeInsets scaledPadding(EdgeInsets base) {
    return EdgeInsets.only(
      left: scale(base.left),
      top: scale(base.top),
      right: scale(base.right),
      bottom: scale(base.bottom),
    );
  }

  EdgeInsets responsivePadding({
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    EdgeInsets base;

    switch (deviceType) {
      case DeviceType.mobile:
        base = mobile;
        break;
      case DeviceType.tablet:
        base = tablet ?? _multiplyEdgeInsets(mobile, 1.15);
        break;
      case DeviceType.desktop:
        base = desktop ?? tablet ?? _multiplyEdgeInsets(mobile, 1.25);
        break;
    }

    return _roundEdgeInsets(base);
  }

  double get horizontalPadding => scale(16);
  double get verticalPadding => scale(12);
  double get cardPadding => scale(16);
  double get listItemPadding => scale(12);
  double get sectionSpacing => scale(24);
  double get itemSpacing => scale(12);
  double get smallSpacing => scale(8);
  double get tinySpacing => scale(4);

  double get appBarHeight => responsiveValue(mobile: 56, tablet: 64, desktop: 72);
  double get bottomNavHeight => responsiveValue(mobile: 60, tablet: 72, desktop: 80);
  double get buttonHeight => responsiveValue(mobile: 48, tablet: 52, desktop: 56);
  double get inputHeight => responsiveValue(mobile: 52, tablet: 56, desktop: 60);
  double get fabSize => responsiveValue(mobile: 56, tablet: 64, desktop: 72);

  Map<String, dynamic> get debugInfo => {
    'screenSize': '${_width.toStringAsFixed(1)} x ${_height.toStringAsFixed(1)}',
    'screenSizeType': screenSizeType.name,
    'deviceType': deviceType.name,
    'orientation': screenOrientation.name,
    'widthScale': _widthScale.toStringAsFixed(3),
    'heightScale': _heightScale.toStringAsFixed(3),
    'hasNotch': hasNotch,
    'safeAreaTop': safeAreaTop.toStringAsFixed(1),
    'safeAreaBottom': safeAreaBottom.toStringAsFixed(1),
    'devicePixelRatio': _devicePixelRatio.toStringAsFixed(2),
  };

  double _roundToHalf(double value) {
    return (value * 2).roundToDouble() / 2;
  }

  double _roundToEven(double value) {
    return (value / 2).roundToDouble() * 2;
  }

  EdgeInsets _multiplyEdgeInsets(EdgeInsets insets, double multiplier) {
    return EdgeInsets.only(
      left: insets.left * multiplier,
      top: insets.top * multiplier,
      right: insets.right * multiplier,
      bottom: insets.bottom * multiplier,
    );
  }

  EdgeInsets _roundEdgeInsets(EdgeInsets insets) {
    return EdgeInsets.only(
      left: _roundToHalf(insets.left),
      top: _roundToHalf(insets.top),
      right: _roundToHalf(insets.right),
      bottom: _roundToHalf(insets.bottom),
    );
  }

  @override
  String toString() {
    return 'ResponsiveUtils(${_width.toInt()}x${_height.toInt()}, ${deviceType.name}, ${screenSizeType.name})';
  }
}

extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);

  ScreenSize get screenSize => responsive.screenSizeType;
  DeviceType get deviceType => responsive.deviceType;

  bool get isXSmallScreen => responsive.isXSmall;
  bool get isSmallScreen => responsive.isSmall;
  bool get isMediumScreen => responsive.isMedium;
  bool get isLargeScreen => responsive.isLarge;
  bool get isXLargeScreen => responsive.isXLarge;
  bool get isXXLargeScreen => responsive.isXXLarge;

  bool get isMobile => responsive.isMobile;
  bool get isTablet => responsive.isTablet;
  bool get isDesktop => responsive.isDesktop;

  bool get isPortrait => responsive.isPortrait;
  bool get isLandscape => responsive.isLandscape;

  double scale(double value) => responsive.scale(value);
  double scaleHeight(double value) => responsive.scaleHeight(value);
  double scaleText(double value) => responsive.scaleText(value);
  double scaleIcon(double value) => responsive.scaleIcon(value);
  double scaleRadius(double value) => responsive.scaleRadius(value);

  double wp(double percentage) => responsive.wp(percentage);
  double hp(double percentage) => responsive.hp(percentage);
}

extension EdgeInsetsResponsive on EdgeInsets {
  EdgeInsets scaledBy(BuildContext context) {
    return context.responsive.scaledPadding(this);
  }
}

extension ResponsiveNum on num {
  double scaledBy(BuildContext context) => context.scale(toDouble());
  double textScaledBy(BuildContext context) => context.scaleText(toDouble());
  double iconScaledBy(BuildContext context) => context.scaleIcon(toDouble());
  double radiusScaledBy(BuildContext context) => context.scaleRadius(toDouble());
  double wpBy(BuildContext context) => context.wp(toDouble());
  double hpBy(BuildContext context) => context.hp(toDouble());
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveUtils responsive) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveUtils(context));
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);

    if (responsive.isDesktop && desktop != null) {
      return desktop!;
    }

    if (responsive.isTablet && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}
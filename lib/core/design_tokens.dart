import 'package:flutter/material.dart';
import 'utils/responsive_utils.dart';

class DesignTokens {
  final BuildContext context;
  final ResponsiveUtils responsive;

  DesignTokens(this.context) : responsive = ResponsiveUtils(context);

  double get spacing2XS => responsive.scaleSpacing(2, minSpacing: 1, maxSpacing: 3);
  double get spacingXS => responsive.scaleSpacing(4, minSpacing: 2, maxSpacing: 6);
  double get spacingSM => responsive.scaleSpacing(8, minSpacing: 6, maxSpacing: 12);
  double get spacingMD => responsive.scaleSpacing(12, minSpacing: 8, maxSpacing: 16);
  double get spacingLG => responsive.scaleSpacing(16, minSpacing: 12, maxSpacing: 24);
  double get spacingXL => responsive.scaleSpacing(24, minSpacing: 18, maxSpacing: 32);
  double get spacing2XL => responsive.scaleSpacing(32, minSpacing: 24, maxSpacing: 48);
  double get spacing3XL => responsive.scaleSpacing(48, minSpacing: 36, maxSpacing: 64);
  double get spacing4XL => responsive.scaleSpacing(64, minSpacing: 48, maxSpacing: 96);

  double get spacingTiny => spacingXS;
  double get spacingSmall => spacingSM;
  double get spacingMedium => spacingLG;
  double get spacingLarge => spacingXL;
  double get spacingXLarge => spacing2XL;
  double get spacing2XLarge => spacing3XL;

  double get padding2XS => spacing2XS;
  double get paddingXS => spacingXS;
  double get paddingSM => spacingSM;
  double get paddingMD => spacingMD;
  double get paddingLG => spacingLG;
  double get paddingXL => spacingXL;
  double get padding2XL => spacing2XL;

  double get paddingTiny => paddingXS;
  double get paddingSmall => paddingSM;
  double get paddingMedium => paddingLG;
  double get paddingLarge => paddingXL;
  double get paddingXLarge => padding2XL;

  double get radius2XS => responsive.scaleRadius(2, minRadius: 1, maxRadius: 3);
  double get radiusXS => responsive.scaleRadius(4, minRadius: 3, maxRadius: 6);
  double get radiusSM => responsive.scaleRadius(8, minRadius: 6, maxRadius: 12);
  double get radiusMD => responsive.scaleRadius(12, minRadius: 10, maxRadius: 16);
  double get radiusLG => responsive.scaleRadius(16, minRadius: 12, maxRadius: 20);
  double get radiusXL => responsive.scaleRadius(20, minRadius: 16, maxRadius: 28);
  double get radius2XL => responsive.scaleRadius(24, minRadius: 20, maxRadius: 32);
  double get radius3XL => responsive.scaleRadius(32, minRadius: 24, maxRadius: 40);
  double get radiusFull => 999.0;

  double get radiusTiny => radiusXS;
  double get radiusSmall => radiusSM;
  double get radiusMedium => radiusMD;
  double get radiusLarge => radiusLG;
  double get radiusXLarge => radiusXL;

  double get fontXS => responsive.scaleText(10, minSize: 9, maxSize: 12);
  double get fontSM => responsive.scaleText(12, minSize: 10, maxSize: 14);
  double get fontMD => responsive.scaleText(14, minSize: 12, maxSize: 16);
  double get fontLG => responsive.scaleText(16, minSize: 14, maxSize: 18);
  double get fontXL => responsive.scaleText(18, minSize: 16, maxSize: 22);
  double get font2XL => responsive.scaleText(20, minSize: 18, maxSize: 24);
  double get font3XL => responsive.scaleText(24, minSize: 20, maxSize: 28);
  double get font4XL => responsive.scaleText(28, minSize: 24, maxSize: 34);
  double get font5XL => responsive.scaleText(32, minSize: 26, maxSize: 40);
  double get font6XL => responsive.scaleText(40, minSize: 32, maxSize: 48);

  double get fontCaption => fontXS;
  double get fontSmall => fontSM;
  double get fontBody => fontMD;
  double get fontBodyLarge => fontLG;
  double get fontSubtitle => fontXL;
  double get fontTitle => font2XL;
  double get fontHeadline => font3XL;
  double get fontDisplay => font5XL;

  double get icon2XS => responsive.scaleIcon(12, minSize: 10, maxSize: 14);
  double get iconXS => responsive.scaleIcon(16, minSize: 14, maxSize: 18);
  double get iconSM => responsive.scaleIcon(20, minSize: 18, maxSize: 24);
  double get iconMD => responsive.scaleIcon(24, minSize: 20, maxSize: 28);
  double get iconLG => responsive.scaleIcon(28, minSize: 24, maxSize: 34);
  double get iconXL => responsive.scaleIcon(32, minSize: 28, maxSize: 40);
  double get icon2XL => responsive.scaleIcon(48, minSize: 40, maxSize: 56);
  double get icon3XL => responsive.scaleIcon(64, minSize: 52, maxSize: 80);
  double get icon4XL => responsive.scaleIcon(96, minSize: 72, maxSize: 120);

  double get iconTiny => iconXS;
  double get iconSmall => iconSM;
  double get iconMedium => iconMD;
  double get iconLarge => iconXL;
  double get iconXLarge => icon2XL;
  double get icon2XLarge => icon3XL;

  double get buttonHeightSM => responsive.scale(32).clamp(28.0, 38.0);
  double get buttonHeightMD => responsive.scale(40).clamp(36.0, 48.0);
  double get buttonHeightLG => responsive.scale(48).clamp(44.0, 56.0);
  double get buttonHeightXL => responsive.scale(56).clamp(52.0, 64.0);

  double get buttonHeightSmall => buttonHeightSM;
  double get buttonHeightMedium => buttonHeightLG;
  double get buttonHeightLarge => buttonHeightXL;

  double get inputHeightSM => responsive.scale(44).clamp(40.0, 52.0);
  double get inputHeightMD => responsive.scale(52).clamp(48.0, 60.0);
  double get inputHeightLG => responsive.scale(60).clamp(56.0, 68.0);

  double get avatarXS => responsive.scaleIcon(24, minSize: 20, maxSize: 28);
  double get avatarSM => responsive.scaleIcon(32, minSize: 28, maxSize: 40);
  double get avatarMD => responsive.scaleIcon(48, minSize: 40, maxSize: 56);
  double get avatarLG => responsive.scaleIcon(64, minSize: 52, maxSize: 80);
  double get avatarXL => responsive.scaleIcon(96, minSize: 80, maxSize: 120);
  double get avatar2XL => responsive.scaleIcon(128, minSize: 100, maxSize: 160);

  double get avatarSmall => avatarSM;
  double get avatarMedium => avatarMD;
  double get avatarLarge => avatarLG;
  double get avatarXLarge => avatarXL;

  double get appBarHeight => responsive.appBarHeight;
  double get bottomNavHeight => responsive.bottomNavHeight;
  double get tabBarHeight => responsive.scale(48).clamp(44.0, 56.0);
  double get cardElevation => 2.0;
  double get cardPadding => paddingLG;
  double get listItemHeight => responsive.scale(72).clamp(64.0, 88.0);
  double get listItemMinHeight => responsive.scale(48).clamp(44.0, 56.0);

  double get chartHeightSM => responsive.scaleHeight(180).clamp(150.0, 220.0);
  double get chartHeightMD => responsive.scaleHeight(240).clamp(200.0, 300.0);
  double get chartHeightLG => responsive.scaleHeight(320).clamp(260.0, 400.0);

  double get chartHeightSmall => chartHeightSM;
  double get chartHeightMedium => chartHeightMD;
  double get chartHeightLarge => chartHeightLG;

  EdgeInsets get paddingAll2XS => EdgeInsets.all(padding2XS);
  EdgeInsets get paddingAllXS => EdgeInsets.all(paddingXS);
  EdgeInsets get paddingAllSM => EdgeInsets.all(paddingSM);
  EdgeInsets get paddingAllMD => EdgeInsets.all(paddingMD);
  EdgeInsets get paddingAllLG => EdgeInsets.all(paddingLG);
  EdgeInsets get paddingAllXL => EdgeInsets.all(paddingXL);
  EdgeInsets get paddingAll2XL => EdgeInsets.all(padding2XL);

  EdgeInsets get paddingAllTiny => paddingAllXS;
  EdgeInsets get paddingAllSmall => paddingAllSM;
  EdgeInsets get paddingAllMedium => paddingAllLG;
  EdgeInsets get paddingAllLarge => paddingAllXL;
  EdgeInsets get paddingAllXLarge => paddingAll2XL;

  EdgeInsets get paddingHorizontalXS => EdgeInsets.symmetric(horizontal: paddingXS);
  EdgeInsets get paddingHorizontalSM => EdgeInsets.symmetric(horizontal: paddingSM);
  EdgeInsets get paddingHorizontalMD => EdgeInsets.symmetric(horizontal: paddingMD);
  EdgeInsets get paddingHorizontalLG => EdgeInsets.symmetric(horizontal: paddingLG);
  EdgeInsets get paddingHorizontalXL => EdgeInsets.symmetric(horizontal: paddingXL);

  EdgeInsets get paddingHorizontalTiny => paddingHorizontalXS;
  EdgeInsets get paddingHorizontalSmall => paddingHorizontalSM;
  EdgeInsets get paddingHorizontalMedium => paddingHorizontalLG;
  EdgeInsets get paddingHorizontalLarge => paddingHorizontalXL;

  EdgeInsets get paddingVerticalXS => EdgeInsets.symmetric(vertical: paddingXS);
  EdgeInsets get paddingVerticalSM => EdgeInsets.symmetric(vertical: paddingSM);
  EdgeInsets get paddingVerticalMD => EdgeInsets.symmetric(vertical: paddingMD);
  EdgeInsets get paddingVerticalLG => EdgeInsets.symmetric(vertical: paddingLG);
  EdgeInsets get paddingVerticalXL => EdgeInsets.symmetric(vertical: paddingXL);

  EdgeInsets get paddingVerticalTiny => paddingVerticalXS;
  EdgeInsets get paddingVerticalSmall => paddingVerticalSM;
  EdgeInsets get paddingVerticalMedium => paddingVerticalLG;
  EdgeInsets get paddingVerticalLarge => paddingVerticalXL;

  EdgeInsets get screenPadding => EdgeInsets.only(
    left: paddingLG,
    right: paddingLG,
    top: paddingMD,
    bottom: paddingMD + responsive.safeAreaBottom,
  );

  EdgeInsets get cardContentPadding => EdgeInsets.symmetric(
    horizontal: paddingLG,
    vertical: paddingMD,
  );

  SizedBox get spacer2XS => SizedBox(height: spacing2XS);
  SizedBox get spacerXS => SizedBox(height: spacingXS);
  SizedBox get spacerSM => SizedBox(height: spacingSM);
  SizedBox get spacerMD => SizedBox(height: spacingMD);
  SizedBox get spacerLG => SizedBox(height: spacingLG);
  SizedBox get spacerXL => SizedBox(height: spacingXL);
  SizedBox get spacer2XL => SizedBox(height: spacing2XL);
  SizedBox get spacer3XL => SizedBox(height: spacing3XL);

  SizedBox get spacerTiny => spacerXS;
  SizedBox get spacerSmall => spacerSM;
  SizedBox get spacerMedium => spacerLG;
  SizedBox get spacerLarge => spacerXL;
  SizedBox get spacerXLarge => spacer2XL;

  SizedBox get hSpacer2XS => SizedBox(width: spacing2XS);
  SizedBox get hSpacerXS => SizedBox(width: spacingXS);
  SizedBox get hSpacerSM => SizedBox(width: spacingSM);
  SizedBox get hSpacerMD => SizedBox(width: spacingMD);
  SizedBox get hSpacerLG => SizedBox(width: spacingLG);
  SizedBox get hSpacerXL => SizedBox(width: spacingXL);
  SizedBox get hSpacer2XL => SizedBox(width: spacing2XL);

  SizedBox get hSpacerTiny => hSpacerXS;
  SizedBox get hSpacerSmall => hSpacerSM;
  SizedBox get hSpacerMedium => hSpacerLG;
  SizedBox get hSpacerLarge => hSpacerXL;
  SizedBox get hSpacerXLarge => hSpacer2XL;

  BorderRadius get borderRadius2XS => BorderRadius.circular(radius2XS);
  BorderRadius get borderRadiusXS => BorderRadius.circular(radiusXS);
  BorderRadius get borderRadiusSM => BorderRadius.circular(radiusSM);
  BorderRadius get borderRadiusMD => BorderRadius.circular(radiusMD);
  BorderRadius get borderRadiusLG => BorderRadius.circular(radiusLG);
  BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  BorderRadius get borderRadius2XL => BorderRadius.circular(radius2XL);
  BorderRadius get borderRadius3XL => BorderRadius.circular(radius3XL);
  BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  BorderRadius get borderRadiusTiny => borderRadiusXS;
  BorderRadius get borderRadiusSmall => borderRadiusSM;
  BorderRadius get borderRadiusMedium => borderRadiusMD;
  BorderRadius get borderRadiusLarge => borderRadiusLG;
  BorderRadius get borderRadiusXLarge => borderRadiusXL;

  BorderRadius get borderRadiusTopLG => BorderRadius.only(
    topLeft: Radius.circular(radiusLG),
    topRight: Radius.circular(radiusLG),
  );

  BorderRadius get borderRadiusTopXL => BorderRadius.only(
    topLeft: Radius.circular(radiusXL),
    topRight: Radius.circular(radiusXL),
  );

  BorderRadius get borderRadiusTop2XL => BorderRadius.only(
    topLeft: Radius.circular(radius2XL),
    topRight: Radius.circular(radius2XL),
  );

  int gridColumns({int mobile = 2, int? tablet, int? desktop}) {
    return responsive.gridColumns(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  double gridAspectRatio({double mobile = 1.0, double? tablet, double? desktop}) {
    return responsive.gridAspectRatio(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  double gridSpacing({double mobile = 12, double? tablet, double? desktop}) {
    return responsive.gridSpacing(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsive.responsiveValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  T byScreen<T>({
    required T xsmall,
    T? small,
    T? medium,
    T? large,
    T? xlarge,
    T? xxlarge,
  }) {
    return responsive.valueByScreen(
      xsmall: xsmall,
      small: small,
      medium: medium,
      large: large,
      xlarge: xlarge,
      xxlarge: xxlarge,
    );
  }

  T byDevice<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return responsive.byDevice(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  double wp(double percentage) => responsive.wp(percentage);
  double hp(double percentage) => responsive.hp(percentage);
  double awp(double percentage) => responsive.awp(percentage);
  double ahp(double percentage) => responsive.ahp(percentage);

  DeviceType get deviceType => responsive.deviceType;
  ScreenSize get screenSize => responsive.screenSizeType;

  bool get isMobile => responsive.isMobile;
  bool get isTablet => responsive.isTablet;
  bool get isDesktop => responsive.isDesktop;
  bool get isSmallScreen => responsive.isXSmall || responsive.isSmall;
  bool get isLargeScreen => responsive.isXLarge || responsive.isXXLarge;
  bool get isPortrait => responsive.isPortrait;
  bool get isLandscape => responsive.isLandscape;

  double scale(double value) => responsive.scale(value);
  double scaleText(double value) => responsive.scaleText(value);
  double scaleIcon(double value) => responsive.scaleIcon(value);

  Map<String, dynamic> get debugInfo => responsive.debugInfo;
}

extension DesignTokensExtension on BuildContext {
  DesignTokens get tokens => DesignTokens(this);
}
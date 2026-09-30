import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_shadows.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryBlue = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color secondaryBlue = AppColors.info;
  static const Color accentCyan = Color(0xFF00BCD4);

  static const Color successGreen = AppColors.success;
  static const Color errorRed = AppColors.error;
  static const Color warningOrange = AppColors.warning;
  static const Color infoBlue = AppColors.info;

  static const Color backgroundLight = AppColors.background;
  static const Color backgroundWhite = AppColors.backgroundLight;
  static const Color cardWhite = AppColors.surface;
  static const Color dividerColor = AppColors.divider;

  static const Color textDark = AppColors.textPrimary;
  static const Color textMedium = AppColors.textSecondary;
  static const Color textLight = AppColors.textTertiary;
  static const Color textHint = AppColors.textHint;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF03A9F4), Color(0xFF00BCD4)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.background, AppColors.backgroundLight],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF5350), Color(0xFFF44336)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );

  static const double space2XS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double spaceLG = 16.0;
  static const double spaceXL = 24.0;
  static const double space2XL = 32.0;
  static const double space3XL = 48.0;
  static const double space4XL = 64.0;

  static const double radius2XS = 2.0;
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radius2XL = 24.0;
  static const double radius3XL = 32.0;
  static const double radiusFull = 999.0;
  static const double radiusCircle = 999.0;

  static const double fontXS = 10.0;
  static const double fontSM = 12.0;
  static const double fontMD = 14.0;
  static const double fontLG = 16.0;
  static const double fontXL = 18.0;
  static const double font2XL = 20.0;
  static const double font3XL = 24.0;
  static const double font4XL = 28.0;
  static const double font5XL = 32.0;
  static const double font6XL = 40.0;

  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSize2XL = 20.0;
  static const double fontSize3XL = 24.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeNormal = 16.0;
  static const double fontSizeTitle = 20.0;

  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;

  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  static List<BoxShadow> get shadowSM => AppShadows.sm;
  static List<BoxShadow> get shadowMD => AppShadows.md;
  static List<BoxShadow> get shadowLG => AppShadows.lg;
  static List<BoxShadow> get shadowXL => AppShadows.xl;
  static List<BoxShadow> get cardShadow => AppShadows.card;
  static List<BoxShadow> get buttonShadow => AppShadows.button;
  static List<BoxShadow> get floatingShadow => AppShadows.fab;
  static List<BoxShadow> get modalShadow => AppShadows.modal;
  static List<BoxShadow> get subtleShadow => AppShadows.xs;

  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 3;
  static const double elevation3 = 6;
  static const double elevation4 = 8;
  static const double elevation5 = 12;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: primaryDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.secondaryDark,
        tertiary: accentCyan,
        onTertiary: Colors.white,
        error: errorRed,
        onError: Colors.white,
        errorContainer: AppColors.errorLight,
        surface: backgroundWhite,
        onSurface: textDark,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: textMedium,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
        shadow: AppColors.shadowMedium,
        scrim: AppColors.overlayScrim,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: textLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 6,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        labelStyle: TextStyle(
          color: textMedium,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: textHint,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          color: errorRed,
          fontSize: 12,
        ),
        prefixIconColor: textMedium,
        suffixIconColor: textMedium,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textMedium,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryBlue, size: 24);
          }
          return IconThemeData(color: textMedium, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryBlue,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textMedium,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundWhite,
        elevation: 24,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: textMedium,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: backgroundWhite,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        dragHandleColor: AppColors.border,
        dragHandleSize: const Size(40, 4),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundLight,
        deleteIconColor: textMedium,
        labelStyle: TextStyle(
          color: textDark,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: textMedium,
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        iconColor: textMedium,
        textColor: textDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.border;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue;
          return AppColors.borderLight;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          return Colors.transparent;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: AppColors.border, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue;
          return textMedium;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryBlue,
        linearTrackColor: AppColors.borderLight,
        circularTrackColor: AppColors.borderLight,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryBlue,
        inactiveTrackColor: AppColors.borderLight,
        thumbColor: primaryBlue,
        overlayColor: primaryBlue.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryBlue,
        unselectedLabelColor: textMedium,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicatorColor: primaryBlue,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textDark,
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: font5XL,
          fontWeight: weightBold,
          color: textDark,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: font4XL,
          fontWeight: weightBold,
          color: textDark,
          height: 1.25,
        ),
        displaySmall: TextStyle(
          fontSize: font3XL,
          fontWeight: weightBold,
          color: textDark,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: font3XL,
          fontWeight: weightSemiBold,
          color: textDark,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: font2XL,
          fontWeight: weightSemiBold,
          color: textDark,
          height: 1.35,
        ),
        headlineSmall: TextStyle(
          fontSize: fontXL,
          fontWeight: weightSemiBold,
          color: textDark,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: fontLG,
          fontWeight: weightSemiBold,
          color: textDark,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: fontMD,
          fontWeight: weightMedium,
          color: textDark,
          height: 1.45,
        ),
        titleSmall: TextStyle(
          fontSize: fontSM,
          fontWeight: weightMedium,
          color: textDark,
          height: 1.45,
        ),
        bodyLarge: TextStyle(
          fontSize: fontLG,
          fontWeight: weightRegular,
          color: textMedium,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: fontMD,
          fontWeight: weightRegular,
          color: textMedium,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: fontSM,
          fontWeight: weightRegular,
          color: textLight,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: fontMD,
          fontWeight: weightMedium,
          color: textMedium,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: fontSM,
          fontWeight: weightMedium,
          color: textMedium,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: fontXS,
          fontWeight: weightMedium,
          color: textLight,
          height: 1.4,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color _darkSurface = Color(0xFF121212);
  static const Color _darkCard = Color(0xFF1E1E1E);
  static const Color _darkElevated = Color(0xFF2C2C2C);
  static const Color _darkBorder = Color(0xFF3A3A3A);
  static const Color _darkTextPrimary = Color(0xFFE8EAED);
  static const Color _darkTextSecondary = Color(0xFF9AA0A6);
  static const Color _darkTextTertiary = Color(0xFF6B7280);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFF1A3A5C),
        onPrimaryContainer: primaryLight,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFF1B3A1B),
        onSecondaryContainer: AppColors.secondaryLight,
        tertiary: accentCyan,
        onTertiary: Colors.white,
        error: AppColors.errorLight,
        onError: Colors.white,
        errorContainer: const Color(0xFF3B1010),
        surface: _darkCard,
        onSurface: _darkTextPrimary,
        surfaceContainerHighest: _darkElevated,
        onSurfaceVariant: _darkTextSecondary,
        outline: _darkBorder,
        outlineVariant: const Color(0xFF2A2A2A),
        shadow: Colors.black54,
        scrim: Colors.black87,
      ),
      scaffoldBackgroundColor: _darkSurface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: _darkCard,
        foregroundColor: _darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: _darkTextPrimary,
          size: 24,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _darkBorder,
          disabledForegroundColor: _darkTextTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: const BorderSide(color: primaryBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 6,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: AppColors.errorLight, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        labelStyle: const TextStyle(
          color: _darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: _darkTextTertiary,
          fontSize: 14,
        ),
        errorStyle: TextStyle(
          color: AppColors.errorLight,
          fontSize: 12,
        ),
        prefixIconColor: _darkTextSecondary,
        suffixIconColor: _darkTextSecondary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkCard,
        selectedItemColor: primaryBlue,
        unselectedItemColor: _darkTextSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkCard,
        indicatorColor: const Color(0xFF1A3A5C),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBlue, size: 24);
          }
          return const IconThemeData(color: _darkTextSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryBlue,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _darkTextSecondary,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkElevated,
        elevation: 24,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
        titleTextStyle: const TextStyle(
          color: _darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: _darkTextSecondary,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _darkElevated,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        dragHandleColor: _darkBorder,
        dragHandleSize: Size(40, 4),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkElevated,
        contentTextStyle: const TextStyle(
          color: _darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkElevated,
        deleteIconColor: _darkTextSecondary,
        labelStyle: const TextStyle(
          color: _darkTextPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: _darkBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: _darkTextSecondary,
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        iconColor: _darkTextSecondary,
        textColor: _darkTextPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return _darkBorder;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue;
          return const Color(0xFF2A2A2A);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          return Colors.transparent;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: _darkBorder, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue;
          return _darkTextSecondary;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryBlue,
        linearTrackColor: _darkBorder,
        circularTrackColor: _darkBorder,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryBlue,
        inactiveTrackColor: _darkBorder,
        thumbColor: primaryBlue,
        overlayColor: primaryBlue.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryBlue,
        unselectedLabelColor: _darkTextSecondary,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicatorColor: primaryBlue,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _darkElevated,
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        textStyle: const TextStyle(
          color: _darkTextPrimary,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: font5XL, fontWeight: weightBold,
          color: _darkTextPrimary, height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: font4XL, fontWeight: weightBold,
          color: _darkTextPrimary, height: 1.25,
        ),
        displaySmall: TextStyle(
          fontSize: font3XL, fontWeight: weightBold,
          color: _darkTextPrimary, height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: font3XL, fontWeight: weightSemiBold,
          color: _darkTextPrimary, height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: font2XL, fontWeight: weightSemiBold,
          color: _darkTextPrimary, height: 1.35,
        ),
        headlineSmall: TextStyle(
          fontSize: fontXL, fontWeight: weightSemiBold,
          color: _darkTextPrimary, height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: fontLG, fontWeight: weightSemiBold,
          color: _darkTextPrimary, height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: fontMD, fontWeight: weightMedium,
          color: _darkTextPrimary, height: 1.45,
        ),
        titleSmall: TextStyle(
          fontSize: fontSM, fontWeight: weightMedium,
          color: _darkTextPrimary, height: 1.45,
        ),
        bodyLarge: TextStyle(
          fontSize: fontLG, fontWeight: weightRegular,
          color: _darkTextSecondary, height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: fontMD, fontWeight: weightRegular,
          color: _darkTextSecondary, height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: fontSM, fontWeight: weightRegular,
          color: _darkTextTertiary, height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: fontMD, fontWeight: weightMedium,
          color: _darkTextSecondary, height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: fontSM, fontWeight: weightMedium,
          color: _darkTextSecondary, height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: fontXS, fontWeight: weightMedium,
          color: _darkTextTertiary, height: 1.4, letterSpacing: 0.5,
        ),
      ),
    );
  }

  static BoxDecoration gradientDecoration({
    Gradient? gradient,
    double? radius,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(radius ?? radiusLG),
      boxShadow: shadows ?? shadowMD,
    );
  }

  static BoxDecoration cardDecoration({
    Color? color,
    double? radius,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? backgroundWhite,
      borderRadius: BorderRadius.circular(radius ?? radiusLG),
      boxShadow: shadows ?? cardShadow,
      border: border,
    );
  }

  static BoxDecoration iconCircleDecoration({
    Color? color,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color ?? primaryBlue.withValues(alpha: 0.1),
      shape: BoxShape.circle,
      boxShadow: shadows ?? subtleShadow,
    );
  }

  static BoxDecoration glassDecoration({
    double? radius,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(radius ?? radiusLG),
      boxShadow: shadows ?? shadowMD,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.5),
        width: 1.5,
      ),
    );
  }

  static BoxDecoration backgroundDecoration({
    Gradient? gradient,
  }) {
    return BoxDecoration(
      gradient: gradient ?? backgroundGradient,
    );
  }

  static BoxDecoration buttonDecoration({
    Gradient? gradient,
    double? radius,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(radius ?? radiusMD),
      boxShadow: buttonShadow,
    );
  }

  static BoxDecoration modalDecoration({
    double? radius,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? backgroundWhite,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radius ?? radiusXL),
        topRight: Radius.circular(radius ?? radiusXL),
      ),
      boxShadow: modalShadow,
    );
  }

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? helperText,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
    );
  }
}

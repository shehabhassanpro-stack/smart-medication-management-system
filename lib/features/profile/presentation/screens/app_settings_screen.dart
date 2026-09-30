import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/settings_provider.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              _buildHeader(context, t),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        context: context,
                        title: t.settings_appearance,
                        icon: Icons.palette_outlined,
                        children: [
                          _buildOptionTile(
                            context: context,
                            title: t.settings_language,
                            subtitle: _getLanguageName(settings.languageCode, t),
                            icon: Icons.language_rounded,
                            onTap: () => _showLanguageDialog(context, settings, t),
                          ),
                          _buildDivider(context),
                          _buildOptionTile(
                            context: context,
                            title: t.settings_theme,
                            subtitle: _getThemeName(settings.themeString, t),
                            icon: Icons.dark_mode_outlined,
                            onTap: () => _showThemeDialog(context, settings, t),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        context: context,
                        title: t.settings_measurementUnits,
                        icon: Icons.straighten_rounded,
                        children: [
                          _buildOptionTile(
                            context: context,
                            title: t.settings_weightUnit,
                            subtitle: settings.weightUnit == 'kg'
                                ? t.settings_kgUnit
                                : t.settings_lbUnit,
                            icon: Icons.monitor_weight_outlined,
                            onTap: () =>
                                _showWeightUnitDialog(context, settings, t),
                          ),
                          _buildDivider(context),
                          _buildOptionTile(
                            context: context,
                            title: t.settings_heightUnit,
                            subtitle: settings.heightUnit == 'cm'
                                ? t.settings_cmUnit
                                : t.settings_ftUnit,
                            icon: Icons.height_rounded,
                            onTap: () =>
                                _showHeightUnitDialog(context, settings, t),
                          ),
                          _buildDivider(context),
                          _buildOptionTile(
                            context: context,
                            title: t.settings_temperatureUnit,
                            subtitle: settings.temperatureUnit == 'celsius'
                                ? t.settings_celsiusUnit
                                : t.settings_fahrenheitUnit,
                            icon: Icons.thermostat_outlined,
                            onTap: () =>
                                _showTemperatureUnitDialog(context, settings, t),
                          ),
                          _buildDivider(context),
                          _buildOptionTile(
                            context: context,
                            title: t.settings_glucoseUnit,
                            subtitle: settings.glucoseUnit,
                            icon: Icons.bloodtype_outlined,
                            onTap: () =>
                                _showGlucoseUnitDialog(context, settings, t),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        context: context,
                        title: t.settings_data,
                        icon: Icons.storage_rounded,
                        children: [
                          _buildOptionTile(
                            context: context,
                            title: t.settings_clearCache,
                            subtitle: t.settings_clearCacheSubtitle,
                            icon: Icons.cleaning_services_rounded,
                            onTap: () => _showClearCacheDialog(context, t),
                            showArrow: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, S t) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Row(
        children: [
          _buildBackButton(context),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.settings_title,
                    style: AppTextStyles.h3.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(t.settings_subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.labelMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.02 : 0.06),
                blurRadius: 16, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
                  ],
                ),
              ),
              if (showArrow)
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded, size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 74),
      child: Divider(height: 1, thickness: 1,
        color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
    );
  }

  String _getLanguageName(String code, S t) {
    switch (code) {
      case 'en': return t.settings_langEnglish;
      default: return t.settings_langArabic;
    }
  }

  String _getThemeName(String theme, S t) {
    switch (theme) {
      case 'dark': return t.settings_themeDark;
      case 'system': return t.settings_themeSystem;
      default: return t.settings_themeLight;
    }
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings, S t) {
    _showSelectionDialog(
      context: context,
      title: t.settings_language,
      icon: Icons.language_rounded,
      options: [
        _DialogOption(value: 'ar', label: t.settings_langArabic, icon: '🇸🇦'),
        _DialogOption(value: 'en', label: t.settings_langEnglish, icon: '🇺🇸'),
      ],
      selectedValue: settings.languageCode,
      onSelect: (value) => settings.setLanguage(value),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings, S t) {
    _showSelectionDialog(
      context: context,
      title: t.settings_theme,
      icon: Icons.dark_mode_outlined,
      options: [
        _DialogOption(value: 'light', label: t.settings_themeLight, icon: '☀️'),
        _DialogOption(value: 'dark', label: t.settings_themeDark, icon: '🌙'),
        _DialogOption(value: 'system', label: t.settings_themeSystem, icon: '📱'),
      ],
      selectedValue: settings.themeString,
      onSelect: (value) => settings.setTheme(value),
    );
  }

  void _showWeightUnitDialog(BuildContext context, SettingsProvider settings, S t) {
    _showSelectionDialog(
      context: context,
      title: t.settings_weightUnit,
      icon: Icons.monitor_weight_outlined,
      options: [
        _DialogOption(value: 'kg', label: t.settings_kgUnit, icon: '⚖️'),
        _DialogOption(value: 'lb', label: t.settings_lbUnit, icon: '⚖️'),
      ],
      selectedValue: settings.weightUnit,
      onSelect: (value) => settings.setWeightUnit(value),
    );
  }

  void _showHeightUnitDialog(BuildContext context, SettingsProvider settings, S t) {
    _showSelectionDialog(
      context: context,
      title: t.settings_heightUnit,
      icon: Icons.height_rounded,
      options: [
        _DialogOption(value: 'cm', label: t.settings_cmUnit, icon: '📏'),
        _DialogOption(value: 'ft', label: t.settings_ftUnit, icon: '📏'),
      ],
      selectedValue: settings.heightUnit,
      onSelect: (value) => settings.setHeightUnit(value),
    );
  }

  void _showTemperatureUnitDialog(BuildContext context, SettingsProvider settings, S t) {
    _showSelectionDialog(
      context: context,
      title: t.settings_temperatureUnit,
      icon: Icons.thermostat_outlined,
      options: [
        _DialogOption(value: 'celsius', label: t.settings_celsiusUnit, icon: '🌡️'),
        _DialogOption(value: 'fahrenheit', label: t.settings_fahrenheitUnit, icon: '🌡️'),
      ],
      selectedValue: settings.temperatureUnit,
      onSelect: (value) => settings.setTemperatureUnit(value),
    );
  }

  void _showGlucoseUnitDialog(BuildContext context, SettingsProvider settings, S t) {
    _showSelectionDialog(
      context: context,
      title: t.settings_glucoseUnit,
      icon: Icons.bloodtype_outlined,
      options: [
        _DialogOption(value: 'mg/dL', label: 'mg/dL', icon: '🩸'),
        _DialogOption(value: 'mmol/L', label: 'mmol/L', icon: '🩸'),
      ],
      selectedValue: settings.glucoseUnit,
      onSelect: (value) => settings.setGlucoseUnit(value),
    );
  }

  void _showSelectionDialog({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<_DialogOption> options,
    required String selectedValue,
    required Function(String) onSelect,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(title),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            final isSelected = option.value == selectedValue;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () { Navigator.pop(ctx); onSelect(option.value); },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary
                          : isDark ? const Color(0xFF3A3A3A) : AppColors.border,
                    ),
                  ),
                  child: Row(children: [
                    Text(option.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(option.label, style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
                      )),
                    ),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, S t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.cleaning_services_rounded, color: AppColors.warning),
          ),
          const SizedBox(width: 12),
          Text(t.settings_clearCache),
        ]),
        content: Text(t.settings_clearCacheConfirm,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.common_cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(t.settings_cacheCleared)),
                ]),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(t.settings_clearCache),
          ),
        ],
      ),
    );
  }
}

class _DialogOption {
  final String value;
  final String label;
  final String icon;
  _DialogOption({required this.value, required this.label, required this.icon});
}

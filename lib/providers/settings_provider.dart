import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central settings provider managing locale, theme mode, and measurement units.
/// Consumed by MaterialApp to instantly apply language and theme changes.
class SettingsProvider extends ChangeNotifier {
  static const String _keyLanguage = 'app_language';
  static const String _keyTheme = 'app_theme';
  static const String _keyWeightUnit = 'unit_weight';
  static const String _keyHeightUnit = 'unit_height';
  static const String _keyTemperatureUnit = 'unit_temperature';
  static const String _keyGlucoseUnit = 'unit_glucose';

  // --- Current Values ---
  Locale _locale = const Locale('ar', 'EG');
  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'ar';
  String _themeString = 'light';
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  String _temperatureUnit = 'celsius';
  String _glucoseUnit = 'mg/dL';

  bool _isLoaded = false;

  SettingsProvider() {
    _loadSettings();
  }

  // --- Getters ---
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  String get themeString => _themeString;
  String get weightUnit => _weightUnit;
  String get heightUnit => _heightUnit;
  String get temperatureUnit => _temperatureUnit;
  String get glucoseUnit => _glucoseUnit;
  bool get isLoaded => _isLoaded;

  /// Text direction based on current language
  TextDirection get textDirection =>
      _languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  // --- Load from SharedPreferences ---
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _languageCode = prefs.getString(_keyLanguage) ?? 'ar';
      _themeString = prefs.getString(_keyTheme) ?? 'light';
      _weightUnit = prefs.getString(_keyWeightUnit) ?? 'kg';
      _heightUnit = prefs.getString(_keyHeightUnit) ?? 'cm';
      _temperatureUnit = prefs.getString(_keyTemperatureUnit) ?? 'celsius';
      _glucoseUnit = prefs.getString(_keyGlucoseUnit) ?? 'mg/dL';

      _locale = _languageCode == 'en'
          ? const Locale('en', 'US')
          : const Locale('ar', 'EG');

      _themeMode = _parseThemeMode(_themeString);
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ SettingsProvider load error: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  // --- Setters (persist + notify) ---

  Future<void> setLanguage(String code) async {
    if (_languageCode == code) return;
    _languageCode = code;
    _locale = code == 'en'
        ? const Locale('en', 'US')
        : const Locale('ar', 'EG');
    notifyListeners();
    await _save(_keyLanguage, code);
  }

  Future<void> setTheme(String theme) async {
    if (_themeString == theme) return;
    _themeString = theme;
    _themeMode = _parseThemeMode(theme);
    notifyListeners();
    await _save(_keyTheme, theme);
  }

  Future<void> setWeightUnit(String unit) async {
    if (_weightUnit == unit) return;
    _weightUnit = unit;
    notifyListeners();
    await _save(_keyWeightUnit, unit);
  }

  Future<void> setHeightUnit(String unit) async {
    if (_heightUnit == unit) return;
    _heightUnit = unit;
    notifyListeners();
    await _save(_keyHeightUnit, unit);
  }

  Future<void> setTemperatureUnit(String unit) async {
    if (_temperatureUnit == unit) return;
    _temperatureUnit = unit;
    notifyListeners();
    await _save(_keyTemperatureUnit, unit);
  }

  Future<void> setGlucoseUnit(String unit) async {
    if (_glucoseUnit == unit) return;
    _glucoseUnit = unit;
    notifyListeners();
    await _save(_keyGlucoseUnit, unit);
  }

  // --- Helpers ---

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> _save(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('❌ SettingsProvider save error ($key): $e');
    }
  }
}

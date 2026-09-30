import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🔐 CREDENTIALS MANAGER - Enterprise Grade
// ═══════════════════════════════════════════════════════════════════════════
// 
// A centralized, secure credentials management service following 
// enterprise security standards used by Google, Meta, and Netflix.
//
// 🏛️ Design Principles:
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ • Single Responsibility: Only handles credential storage/retrieval     │
// │ • Singleton Pattern: One instance across the app                       │
// │ • Secure by Default: Uses encrypted storage for sensitive data         │
// │ • Fail-Safe: Graceful error handling with fallbacks                    │
// │ • Observable: Notifies listeners on credential changes                 │
// └─────────────────────────────────────────────────────────────────────────┘
//
// 🔒 Security Features:
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ • AES-256 encryption for passwords (via FlutterSecureStorage)          │
// │ • Automatic credential clearing on logout                              │
// │ • Session timeout support                                              │
// │ • Biometric authentication integration ready                           │
// └─────────────────────────────────────────────────────────────────────────┘
//
// 📊 Usage:
// ```dart
// // Save credentials after successful login
// await CredentialsManager.instance.saveCredentials(
//   email: 'user@example.com',
//   password: 'securePassword123',
//   rememberMe: true,
// );
//
// // Clear credentials on logout
// await CredentialsManager.instance.clearAll();
// ```
// ═══════════════════════════════════════════════════════════════════════════

/// Represents stored user credentials
@immutable
class StoredCredentials {
  final String? email;
  final String? password;
  final bool rememberMe;
  final DateTime? savedAt;

  const StoredCredentials({
    this.email,
    this.password,
    this.rememberMe = false,
    this.savedAt,
  });

  /// Check if credentials are valid and complete
  bool get isValid =>
      email != null &&
      email!.isNotEmpty &&
      password != null &&
      password!.isNotEmpty &&
      rememberMe;

  /// Check if credentials have expired (default: 30 days)
  bool get isExpired {
    if (savedAt == null) return true;
    final expiryDuration = const Duration(days: 30);
    return DateTime.now().difference(savedAt!) > expiryDuration;
  }

  /// Check if credentials are valid and not expired
  bool get isUsable => isValid && !isExpired;

  @override
  String toString() => 'StoredCredentials(email: $email, rememberMe: $rememberMe)';
}

/// Result of a credentials operation
@immutable
class CredentialsResult {
  final bool success;
  final String? errorMessage;
  final StoredCredentials? credentials;

  const CredentialsResult._({
    required this.success,
    this.errorMessage,
    this.credentials,
  });

  factory CredentialsResult.success([StoredCredentials? credentials]) =>
      CredentialsResult._(success: true, credentials: credentials);

  factory CredentialsResult.failure(String message) =>
      CredentialsResult._(success: false, errorMessage: message);
}

/// Centralized credentials management service
/// 
/// This service handles all credential-related operations including:
/// - Secure storage of email and password
/// - Remember me functionality
/// - Biometric authentication preparation
/// - Session management
class CredentialsManager extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════
  // 🔒 SINGLETON INSTANCE
  // ═══════════════════════════════════════════════════════════════
  
  static CredentialsManager? _instance;
  
  /// Get the singleton instance of CredentialsManager
  static CredentialsManager get instance {
    _instance ??= CredentialsManager._internal();
    return _instance!;
  }

  /// Private constructor for singleton
  CredentialsManager._internal();

  /// Reset instance (for testing purposes only)
  @visibleForTesting
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔑 STORAGE KEYS (Constants)
  // ═══════════════════════════════════════════════════════════════
  
  static const String _keyEmail = 'saved_email';
  static const String _keyRememberMe = 'remember_me';
  static const String _keySavedAt = 'credentials_saved_at';
  static const String _keyPassword = 'saved_password';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyLastLoginEmail = 'last_login_email';

  // ═══════════════════════════════════════════════════════════════
  // 🛠️ STORAGE INSTANCES
  // ═══════════════════════════════════════════════════════════════
  
  /// Secure storage for sensitive data (passwords)
  /// Uses AES-256 encryption on Android and Keychain on iOS
  /// Uses Android Keystore (default) instead of EncryptedSharedPreferences
  /// to avoid data loss on real devices after OS updates or process kills.
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: false,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'MedicalCareCredentials',
    ),
  );

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool _isDisposed = false;

  // ═══════════════════════════════════════════════════════════════
  // 📊 STATE
  // ═══════════════════════════════════════════════════════════════
  
  StoredCredentials? _cachedCredentials;
  bool _isLoading = false;

  /// Whether the manager is currently loading
  bool get isLoading => _isLoading;

  /// Whether the manager has been initialized
  bool get isInitialized => _isInitialized;

  /// Get cached credentials (call loadCredentials first)
  StoredCredentials? get cachedCredentials => _cachedCredentials;

  // ═══════════════════════════════════════════════════════════════
  // 🚀 INITIALIZATION
  // ═══════════════════════════════════════════════════════════════

  /// Initialize the credentials manager
  /// Must be called before using any other methods
  Future<void> initialize() async {
    if (_isInitialized || _isDisposed) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      _log('CredentialsManager initialized successfully');
    } catch (e) {
      _logError('Failed to initialize CredentialsManager', e);
      rethrow;
    }
  }

  /// Ensure the manager is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 💾 SAVE CREDENTIALS
  // ═══════════════════════════════════════════════════════════════

  /// Save user credentials securely
  /// 
  /// [email] - User's email address
  /// [password] - User's password (stored encrypted)
  /// [rememberMe] - Whether to remember credentials
  /// 
  /// Returns [CredentialsResult] indicating success or failure
  Future<CredentialsResult> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (_isDisposed) return CredentialsResult.failure('Manager disposed');

    try {
      await _ensureInitialized();
      _setLoading(true);

      if (rememberMe) {
        // Save email and remember me flag to SharedPreferences
        await _prefs?.setString(_keyEmail, email);
        await _prefs?.setBool(_keyRememberMe, true);
        await _prefs?.setString(_keySavedAt, DateTime.now().toIso8601String());

        // Save password securely (encrypted)
        await _secureStorage.write(key: _keyPassword, value: password);

        _log('Credentials saved successfully for: $email');
      } else {
        // If not remembering, clear any existing credentials
        await clearAll();
        _log('Remember me disabled - credentials cleared');
      }

      // Always save last login email for convenience
      await _prefs?.setString(_keyLastLoginEmail, email);

      // Update cache
      _cachedCredentials = StoredCredentials(
        email: rememberMe ? email : null,
        password: rememberMe ? password : null,
        rememberMe: rememberMe,
        savedAt: rememberMe ? DateTime.now() : null,
      );

      _setLoading(false);
      _notifyListeners();

      return CredentialsResult.success(_cachedCredentials);
    } catch (e) {
      _logError('Failed to save credentials', e);
      _setLoading(false);
      return CredentialsResult.failure('فشل حفظ بيانات الدخول');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📖 LOAD CREDENTIALS
  // ═══════════════════════════════════════════════════════════════

  /// Load stored credentials
  /// 
  /// Returns [StoredCredentials] with the saved data
  /// Returns empty credentials if none exist or remember me is disabled
  Future<StoredCredentials> loadCredentials() async {
    if (_isDisposed) return const StoredCredentials();

    try {
      await _ensureInitialized();
      _setLoading(true);

      final rememberMe = _prefs?.getBool(_keyRememberMe) ?? false;

      if (!rememberMe) {
        _cachedCredentials = const StoredCredentials();
        _setLoading(false);
        return _cachedCredentials!;
      }

      final email = _prefs?.getString(_keyEmail);
      final savedAtString = _prefs?.getString(_keySavedAt);
      final savedAt = savedAtString != null 
          ? DateTime.tryParse(savedAtString) 
          : null;

      // Load password from secure storage
      final password = await _secureStorage.read(key: _keyPassword);

      _cachedCredentials = StoredCredentials(
        email: email,
        password: password,
        rememberMe: rememberMe,
        savedAt: savedAt,
      );

      _setLoading(false);
      _log('Credentials loaded: ${_cachedCredentials?.isValid == true ? "valid" : "invalid"}');

      return _cachedCredentials!;
    } catch (e) {
      _logError('Failed to load credentials', e);
      _setLoading(false);
      _cachedCredentials = const StoredCredentials();
      return _cachedCredentials!;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🗑️ CLEAR CREDENTIALS
  // ═══════════════════════════════════════════════════════════════

  /// Clear all stored credentials
  /// 
  /// This should be called on logout to ensure no auto-login occurs
  /// 
  /// Returns [CredentialsResult] indicating success or failure
  Future<CredentialsResult> clearAll() async {
    if (_isDisposed) return CredentialsResult.failure('Manager disposed');

    try {
      await _ensureInitialized();
      _setLoading(true);

      _log('🧹 Clearing all credentials...');

      // Clear SharedPreferences
      await _prefs?.remove(_keyEmail);
      await _prefs?.remove(_keyRememberMe);
      await _prefs?.remove(_keySavedAt);
      await _prefs?.remove(_keyBiometricEnabled);
      // Note: We keep _keyLastLoginEmail for convenience

      // Clear secure storage
      await _secureStorage.delete(key: _keyPassword);

      // Clear cache
      _cachedCredentials = const StoredCredentials();

      _setLoading(false);
      _notifyListeners();

      _log('✅ All credentials cleared successfully');
      return CredentialsResult.success();
    } catch (e) {
      _logError('Failed to clear credentials', e);
      _setLoading(false);
      return CredentialsResult.failure('فشل مسح بيانات الدخول');
    }
  }

  /// Clear only the password (keep email for convenience)
  Future<CredentialsResult> clearPassword() async {
    if (_isDisposed) return CredentialsResult.failure('Manager disposed');

    try {
      await _ensureInitialized();

      await _secureStorage.delete(key: _keyPassword);
      await _prefs?.setBool(_keyRememberMe, false);

      _cachedCredentials = StoredCredentials(
        email: _cachedCredentials?.email,
        rememberMe: false,
      );

      _notifyListeners();
      _log('Password cleared, email kept');

      return CredentialsResult.success();
    } catch (e) {
      _logError('Failed to clear password', e);
      return CredentialsResult.failure('فشل مسح كلمة المرور');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔍 CHECK METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Check if valid credentials exist
  Future<bool> hasValidCredentials() async {
    final credentials = await loadCredentials();
    return credentials.isUsable;
  }

  /// Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    await _ensureInitialized();
    return _prefs?.getBool(_keyRememberMe) ?? false;
  }

  /// Check if password exists in secure storage
  Future<bool> hasStoredPassword() async {
    try {
      final password = await _secureStorage.read(key: _keyPassword);
      return password != null && password.isNotEmpty;
    } catch (e) {
      _logError('Failed to check stored password', e);
      return false;
    }
  }

  /// Get the last login email (for pre-filling login form)
  Future<String?> getLastLoginEmail() async {
    await _ensureInitialized();
    return _prefs?.getString(_keyLastLoginEmail);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔐 BIOMETRIC SETTINGS
  // ═══════════════════════════════════════════════════════════════

  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyBiometricEnabled, true);
    _log('Biometric enabled');
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyBiometricEnabled, false);
    _log('Biometric disabled');
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    await _ensureInitialized();
    return _prefs?.getBool(_keyBiometricEnabled) ?? false;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 UPDATE METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Update remember me setting
  Future<void> setRememberMe(bool value) async {
    await _ensureInitialized();

    if (!value) {
      await clearAll();
    } else {
      await _prefs?.setBool(_keyRememberMe, value);
    }

    _notifyListeners();
  }

  /// Update stored password (e.g., after password change)
  Future<CredentialsResult> updatePassword(String newPassword) async {
    if (_isDisposed) return CredentialsResult.failure('Manager disposed');

    try {
      final rememberMe = await isRememberMeEnabled();
      if (!rememberMe) {
        return CredentialsResult.failure('Remember me is disabled');
      }

      await _secureStorage.write(key: _keyPassword, value: newPassword);
      
      _cachedCredentials = StoredCredentials(
        email: _cachedCredentials?.email,
        password: newPassword,
        rememberMe: true,
        savedAt: DateTime.now(),
      );

      _log('Password updated in secure storage');
      return CredentialsResult.success(_cachedCredentials);
    } catch (e) {
      _logError('Failed to update password', e);
      return CredentialsResult.failure('فشل تحديث كلمة المرور');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🛠️ UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
    }
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('🔐 CredentialsManager: $message');
    }
  }

  void _logError(String message, Object? error) {
    if (kDebugMode) {
      debugPrint('❌ CredentialsManager: $message');
      if (error != null) {
        debugPrint('   Error: $error');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🧹 CLEANUP
  // ═══════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _isDisposed = true;
    _cachedCredentials = null;
    _log('CredentialsManager disposed');
    super.dispose();
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🛡️ DEVICE SECURITY SERVICE — Root/Jailbreak Detection
// ═══════════════════════════════════════════════════════════════════════════════
//
// Checks for compromised (rooted/jailbroken) devices.
// On compromised devices: shows warning + disables offline cache.
//
// Detection Methods (Android):
// • Check for su binary in common paths
// • Check for Superuser/Magisk apps
// • Check for test-keys build
//
// Enterprise Approach: WARN, don't block.
//
// ═══════════════════════════════════════════════════════════════════════════════

class DeviceSecurityService {
  static final DeviceSecurityService _instance =
      DeviceSecurityService._internal();
  static DeviceSecurityService get instance => _instance;

  DeviceSecurityService._internal();

  bool _isChecked = false;
  bool _isCompromised = false;

  static const String _prefKeyDeviceCompromised = 'device_compromised';

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────────────────────────────────

  /// Whether the device is potentially compromised
  bool get isCompromised => _isCompromised;

  /// Whether the check has been performed
  bool get isChecked => _isChecked;

  /// Run the security check — call once at app startup
  Future<void> checkDeviceSecurity() async {
    if (_isChecked) return;
    _isChecked = true;

    debugPrint('🛡️ DeviceSecurityService: Checking device integrity...');

    try {
      if (Platform.isAndroid) {
        _isCompromised = await _checkAndroidRoot();
      } else if (Platform.isIOS) {
        _isCompromised = _checkiOSJailbreak();
      }

      // Cache result
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyDeviceCompromised, _isCompromised);

      if (_isCompromised) {
        debugPrint('⚠️ DeviceSecurityService: COMPROMISED DEVICE DETECTED');
      } else {
        debugPrint('✅ DeviceSecurityService: Device integrity OK');
      }
    } catch (e) {
      debugPrint('⚠️ DeviceSecurityService: Check failed: $e');
      // Fail open — don't block users on check failure
      _isCompromised = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ANDROID ROOT DETECTION
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _checkAndroidRoot() async {
    // Check 1: Common su binary locations
    final suPaths = [
      '/system/bin/su',
      '/system/xbin/su',
      '/sbin/su',
      '/system/su',
      '/system/bin/.ext/.su',
      '/system/usr/we-need-root/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/data/local/su',
    ];

    for (final path in suPaths) {
      if (await File(path).exists()) {
        debugPrint('🛡️ Root indicator: su binary found at $path');
        return true;
      }
    }

    // Check 2: Magisk / Superuser apps
    final rootApps = [
      '/system/app/Superuser.apk',
      '/system/app/SuperSU.apk',
      '/data/data/com.topjohnwu.magisk',
      '/data/adb/magisk',
    ];

    for (final path in rootApps) {
      if (await File(path).exists()) {
        debugPrint('🛡️ Root indicator: root app found at $path');
        return true;
      }
    }

    // Check 3: Build tags
    try {
      final result = await Process.run('getprop', ['ro.build.tags']);
      if (result.stdout.toString().contains('test-keys')) {
        debugPrint('🛡️ Root indicator: test-keys build detected');
        return true;
      }
    } catch (_) {
      // Ignore — can't run getprop
    }

    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // iOS JAILBREAK DETECTION
  // ─────────────────────────────────────────────────────────────────────────

  bool _checkiOSJailbreak() {
    final jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
      '/usr/bin/ssh',
    ];

    for (final path in jailbreakPaths) {
      if (File(path).existsSync()) {
        debugPrint('🛡️ Jailbreak indicator: found $path');
        return true;
      }
    }

    return false;
  }
}

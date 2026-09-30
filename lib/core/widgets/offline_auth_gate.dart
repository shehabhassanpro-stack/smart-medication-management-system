import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/connectivity_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔐 OFFLINE AUTH GATE — Biometric lock for offline access
// ═══════════════════════════════════════════════════════════════════════════════
//
// When the app resumes from background WHILE OFFLINE:
// - Prompts biometric (fingerprint/face) or device PIN
// - Only triggers if backgrounded > 60 seconds
// - Prevents unauthorized access to medical data on stolen devices
//
// Enterprise Pattern: Google Health, Apple Health, MyChart
//
// ═══════════════════════════════════════════════════════════════════════════════

class OfflineAuthGate extends StatefulWidget {
  final Widget child;

  const OfflineAuthGate({
    super.key,
    required this.child,
  });

  @override
  State<OfflineAuthGate> createState() => _OfflineAuthGateState();
}

class _OfflineAuthGateState extends State<OfflineAuthGate>
    with WidgetsBindingObserver {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isLocked = false;
  bool _isAuthenticating = false;
  DateTime? _lastBackgrounded;
  DateTime? _lastAuthAttempt; // Cooldown timer to prevent infinite loops

  // Grace period: don't prompt if resumed within 60 seconds
  static const Duration _backgroundGracePeriod = Duration(seconds: 60);
  
  // Cooldown: minimum time between auth attempts to let OS settle
  static const Duration _authCooldown = Duration(milliseconds: 1000);

  // Pref key
  static const String _prefKeyBiometricOffline = 'biometric_offline_enabled';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cold start check: schedule lock check immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfLockNeeded(isColdStart: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (!_isLocked && !_isAuthenticating) {
        _lastBackgrounded = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Small delay allows OS to settle before checking lock
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !_isLocked && !_isAuthenticating) {
          _checkIfLockNeeded();
        }
      });
    }
  }

  Future<void> _checkIfLockNeeded({bool isColdStart = false}) async {
    if (_isLocked || _isAuthenticating) return;
    
    // Only lock when offline
    if (ConnectivityService.instance.isOnline) return;

    // Check if biometric offline lock is enabled
    final prefs = await SharedPreferences.getInstance();
    final biometricEnabled = prefs.getBool(_prefKeyBiometricOffline) ?? true;
    if (!biometricEnabled) return;

    // Check grace period ONLY if it's not a cold start
    if (!isColdStart && _lastBackgrounded != null) {
      final backgroundDuration = DateTime.now().difference(_lastBackgrounded!);
      if (backgroundDuration < _backgroundGracePeriod) return;
    }

    // Check auth cooldown to prevent loops
    if (_lastAuthAttempt != null) {
      if (DateTime.now().difference(_lastAuthAttempt!) < _authCooldown) {
         return; 
      }
    }

    // Check if biometric is available on device
    final canAuth = await _localAuth.canCheckBiometrics ||
        await _localAuth.isDeviceSupported();
    if (!canAuth) return;

    // Lock the screen and trigger auth
    if (mounted) {
      setState(() => _isLocked = true);
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    if (mounted) {
      setState(() => _isAuthenticating = true);
    }

    _lastAuthAttempt = DateTime.now();

    try {
      final success = await _localAuth.authenticate(
        localizedReason: 'يرجى التحقق من هويتك للوصول لبياناتك الصحية',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern
          useErrorDialogs: true,
        ),
      );

      if (success && mounted) {
        setState(() {
           _isLocked = false;
           _lastBackgrounded = null; // Reset background timer on success
        });
      }
    } catch (e) {
      debugPrint('🔐 Biometric auth error: $e');
    } finally {
      // Delay unflagging to let the OS lifecycle events (pause/resume) settle
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isAuthenticating = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) return widget.child;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'رعايتك محمية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'يرجى التحقق من هويتك للوصول لبياناتك',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Unlock button
                  ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : _authenticate,
                    icon: const Icon(Icons.fingerprint_rounded, size: 24),
                    label: const Text(
                      'إلغاء القفل',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D47A1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

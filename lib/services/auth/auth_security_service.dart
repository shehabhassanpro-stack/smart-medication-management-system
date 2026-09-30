import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/services/connectivity_service.dart';

class AuthSecurityService {
  static final AuthSecurityService _instance = AuthSecurityService._internal();
  factory AuthSecurityService() => _instance;
  AuthSecurityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔒 SECURITY CONSTANTS - Enterprise Grade
  // ═══════════════════════════════════════════════════════════════════════════

  // Progressive Lockout Thresholds (Google/Microsoft Standard)
  static const List<int> lockoutThresholds = [3, 5, 8, 12];
  static const List<Duration> lockoutDurations = [
    Duration(minutes: 1),   // بعد 3 محاولات
    Duration(minutes: 5),   // بعد 5 محاولات
    Duration(minutes: 15),  // بعد 8 محاولات
    Duration(minutes: 30),  // بعد 12 محاولات
  ];
  
  // Max attempts before permanent lock (requires manual unlock)
  static const int maxLoginAttempts = 15;
  static const int maxRegistrationAttempts = 5;
  static const int maxPasswordResetAttempts = 5;

  // Session Management
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration rememberMeDuration = Duration(days: 30);
  static const Duration offlineGracePeriod = Duration(days: 7);
  static const Duration firestoreTimeout = Duration(seconds: 15);
  
  // SharedPreferences key for offline tracking
  static const String prefKeyLastOnlineValidation = 'last_online_validation';
  
  // Auto-cleanup: محاولات أقدم من هذا الوقت تُحذف تلقائياً
  static const Duration attemptExpirationTime = Duration(hours: 24);

  // Collections
  static const String loginAttemptsCollection = 'login_attempts';
  static const String registrationAttemptsCollection = 'registration_attempts';
  static const String securityLogsCollection = 'security_logs';
  static const String sessionsCollection = 'user_sessions';

  // SharedPreferences Keys
  static const String prefKeyRememberMe = 'remember_me';
  static const String prefKeyLastLoginTime = 'last_login_time';
  static const String prefKeySessionToken = 'session_token';
  static const String prefKeyBiometricEnabled = 'biometric_enabled';
  static const String prefKeyDeviceId = 'device_id';

  // ═══════════════════════════════════════════════════════════════════════════
  // 🛡️ REDUNDANT SECURE STORAGE (OEM Kill Protection)
  // ═══════════════════════════════════════════════════════════════════════════
  // On aggressive OEMs (Oppo/ColorOS, Xiaomi/MIUI), SharedPreferences may not
  // flush to disk before the OS kills the process. FlutterSecureStorage uses
  // Android Keystore (hardware-backed) which persists across process kills.
  static const String _secureKeyRememberMe = 'secure_remember_me';
  static const String _secureKeyLastLoginTime = 'secure_last_login_time';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: false), // Use Keystore
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Cache for device ID
  String? _cachedDeviceId;

  // ═══════════════════════════════════════════════════════════════════════════
  // 📱 DEVICE IDENTIFICATION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(prefKeyDeviceId);

      if (deviceId == null || deviceId.isEmpty) {
        deviceId = await _generateDeviceId();
        await prefs.setString(prefKeyDeviceId, deviceId);
      }

      _cachedDeviceId = deviceId;
      return deviceId;
    } catch (e) {
      debugPrint('⚠️ Error getting device ID: $e');
      return 'unknown_device';
    }
  }

  Future<String> _generateDeviceId() async {
    try {
      String deviceData = '';

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData = '${androidInfo.id}_${androidInfo.model}_${androidInfo.brand}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData = '${iosInfo.identifierForVendor}_${iosInfo.model}';
      } else {
        deviceData = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // Generate hash for privacy
      final bytes = utf8.encode(deviceData);
      final hash = sha256.convert(bytes);
      return hash.toString().substring(0, 32);
    } catch (e) {
      debugPrint('⚠️ Error generating device ID: $e');
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 SESSION VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> validateSessionOnStartup() async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔐 SecurityService: Validating session on startup...');
      debugPrint('═══════════════════════════════════════════════════════');

      // تنظيف المحاولات المنتهية عند بدء التطبيق
      // ⚠️ DO NOT AWAIT CLEANUP HERE TO AVOID STARTUP DELAY!
      _cleanupExpiredAttemptsOnStartup();

      // ─── 🚀 FAST-FAIL OPTIMIZATION ──────────────────────────────
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = await _readRememberMe(prefs);
      final lastLoginTime = await _readLastLoginTime(prefs);

      if (!rememberMe) {
        debugPrint('⏩ Fast-fail: Remember Me is disabled - signing out immediately');
        await _auth.signOut();
        await _clearSessionData();
        return false;
      }
      // ────────────────────────────────────────────────────────────

      // Wait for Firebase Auth to emit its first state (stream-based)
      User? user = _auth.currentUser;
      if (user == null) {
        debugPrint('⏳ Waiting for Firebase Auth session restoration...');
        try {
          // Reduced timeout from 8s to 3s because we already validated local credentials
          user = await _auth
              .authStateChanges()
              .where((u) => u != null)
              .first
              .timeout(const Duration(seconds: 3));
        } on TimeoutException {
          debugPrint('ℹ️ No user session found after 3s timeout');
          return false;
        } catch (_) {
          debugPrint('ℹ️ Auth state check failed');
          return false;
        }
      }

      if (user == null) {
        debugPrint('ℹ️ No user session found after wait');
        return false;
      }

      debugPrint('👤 User found: ${user.uid}');

      if (lastLoginTime == null) {
        // First-time session validation — save current time as login time
        debugPrint('ℹ️ No login time found — setting current time');
        await prefs.setInt(prefKeyLastLoginTime, DateTime.now().millisecondsSinceEpoch);
      } else {
        final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginTime);
        final sessionAge = DateTime.now().difference(lastLogin);

        if (sessionAge > rememberMeDuration) {
          debugPrint('⏰ Session expired - signing out user');
          await _auth.signOut();
          await _clearSessionData();
          return false;
        }

        debugPrint('✅ Session valid - age: ${sessionAge.inHours} hours');
      }

      final isSessionValid = await _validateFirestoreSession(user.uid);

      if (!isSessionValid) {
        // ─── OFFLINE GRACE PERIOD ──────────────────────────────────
        // If offline + rememberMe + session < 7 days → allow access
        if (ConnectivityService.instance.isOffline) {
          final lastOnline = prefs.getInt(prefKeyLastOnlineValidation);
          final gracePeriodValid = lastOnline != null &&
              DateTime.now().difference(
                DateTime.fromMillisecondsSinceEpoch(lastOnline),
              ) < offlineGracePeriod;

          if (gracePeriodValid) {
            debugPrint('🔌 OFFLINE: Grace period valid — allowing access');
            _logSecurityEvent(
              userId: user.uid,
              eventType: 'offline_session_validated',
              severity: 'info',
              details: {
                'offlineDuration':
                    ConnectivityService.instance.offlineDuration?.inHours ?? 0,
              },
            );
            return true;
          } else {
            debugPrint('🔌 OFFLINE: Grace period EXPIRED — re-auth required');
            _logSecurityEvent(
              userId: user.uid,
              eventType: 'offline_grace_expired',
              severity: 'warning',
            );
          }
        }

        debugPrint('❌ Firestore session validation failed');
        await _auth.signOut();
        await _clearSessionData();
        return false;
      }

      // Online validation succeeded — save timestamp for offline grace period
      await prefs.setInt(
        prefKeyLastOnlineValidation,
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('✅ Valid session found with Remember Me enabled');
      debugPrint('═══════════════════════════════════════════════════════');

      return true;
    } catch (e) {
      debugPrint('❌ Error validating session: $e');
      return false;
    }
  }

  Future<bool> _validateFirestoreSession(String userId) async {
    try {
      final sessionDoc = await _firestore
          .collection(sessionsCollection)
          .doc(userId)
          .get()
          .timeout(firestoreTimeout);

      if (!sessionDoc.exists) {
        return true;
      }

      final data = sessionDoc.data();
      if (data == null) {
        return true;
      }

      final lastActive = (data['last_active'] as Timestamp?)?.toDate();
      if (lastActive == null) {
        return true;
      }

      final inactivityDuration = DateTime.now().difference(lastActive);

      if (inactivityDuration > sessionTimeout) {
        debugPrint('⏰ Session timeout - inactive for ${inactivityDuration.inHours} hours');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('⚠️ Error validating Firestore session: $e');
      return true;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚫 PROGRESSIVE LOCKOUT SYSTEM (Enterprise Grade)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> isAccountLocked(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final lockoutInfo = await _getLockoutInfo(normalizedEmail);

      if (lockoutInfo == null) {
        return false;
      }

      final failedCount = lockoutInfo['failed_attempts'] as int? ?? 0;
      final lastAttempt = (lockoutInfo['last_attempt'] as Timestamp?)?.toDate();
      final isPermLocked = lockoutInfo['permanently_locked'] as bool? ?? false;

      // Check permanent lock
      if (isPermLocked) {
        debugPrint('🔒 Account permanently locked - requires manual unlock');
        return true;
      }

      // Check progressive lockout
      if (lastAttempt != null) {
        final lockoutDuration = _getLockoutDuration(failedCount);
        
        if (lockoutDuration != null) {
          final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
          
          if (timeSinceLastAttempt < lockoutDuration) {
            final remainingMinutes = (lockoutDuration - timeSinceLastAttempt).inMinutes;
            debugPrint('🔒 Account locked - remaining: $remainingMinutes minutes');
            return true;
          } else {
            // Lockout expired - DON'T reset here, just return false
            // Reset will happen on successful login
            debugPrint('🔓 Lockout expired - allowing new attempt');
            return false;
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error checking account lockout: $e');
      // في حالة الخطأ، نسمح بالمحاولة لتجنب حجب المستخدم
      return false;
    }
  }

  Duration? _getLockoutDuration(int failedAttempts) {
    for (int i = lockoutThresholds.length - 1; i >= 0; i--) {
      if (failedAttempts >= lockoutThresholds[i]) {
        return lockoutDurations[i];
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getLockoutInfo(String normalizedEmail) async {
    try {
      final doc = await _firestore
          .collection(loginAttemptsCollection)
          .doc(normalizedEmail)
          .get()
          .timeout(firestoreTimeout);

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      debugPrint('⚠️ Error getting lockout info: $e');
      return null;
    }
  }

  Future<int> getRemainingLockoutTime(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final lockoutInfo = await _getLockoutInfo(normalizedEmail);

      if (lockoutInfo == null) {
        return 0;
      }

      final failedCount = lockoutInfo['failed_attempts'] as int? ?? 0;
      final lastAttempt = (lockoutInfo['last_attempt'] as Timestamp?)?.toDate();
      final isPermLocked = lockoutInfo['permanently_locked'] as bool? ?? false;

      if (isPermLocked) {
        return -1; // -1 indicates permanent lock
      }

      if (lastAttempt != null) {
        final lockoutDuration = _getLockoutDuration(failedCount);
        
        if (lockoutDuration != null) {
          final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
          final remainingTime = lockoutDuration - timeSinceLastAttempt;
          
          if (!remainingTime.isNegative) {
            return remainingTime.inMinutes + 1; // +1 للتقريب لأعلى
          }
        }
      }

      return 0;
    } catch (e) {
      debugPrint('❌ Error getting remaining lockout time: $e');
      return 0;
    }
  }

  Future<LockoutStatus> getLockoutStatus(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final lockoutInfo = await _getLockoutInfo(normalizedEmail);

      if (lockoutInfo == null) {
        return LockoutStatus(
          isLocked: false,
          failedAttempts: 0,
          remainingMinutes: 0,
          nextLockoutThreshold: lockoutThresholds.first,
          message: null,
        );
      }

      final failedCount = lockoutInfo['failed_attempts'] as int? ?? 0;
      final lastAttempt = (lockoutInfo['last_attempt'] as Timestamp?)?.toDate();
      final isPermLocked = lockoutInfo['permanently_locked'] as bool? ?? false;

      if (isPermLocked) {
        return LockoutStatus(
          isLocked: true,
          isPermanent: true,
          failedAttempts: failedCount,
          remainingMinutes: -1,
          message: 'الحساب مقفل بشكل دائم. يرجى التواصل مع الدعم الفني.',
        );
      }

      final lockoutDuration = _getLockoutDuration(failedCount);
      
      if (lockoutDuration != null && lastAttempt != null) {
        final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);
        
        if (timeSinceLastAttempt < lockoutDuration) {
          final remainingMinutes = (lockoutDuration - timeSinceLastAttempt).inMinutes + 1;
          return LockoutStatus(
            isLocked: true,
            failedAttempts: failedCount,
            remainingMinutes: remainingMinutes,
            message: 'الحساب مقفل مؤقتاً. تم تجاوز عدد المحاولات المسموحة.\nالرجاء الانتظار $remainingMinutes دقيقة.',
          );
        }
      }

      // Find next threshold
      int? nextThreshold;
      for (final threshold in lockoutThresholds) {
        if (failedCount < threshold) {
          nextThreshold = threshold;
          break;
        }
      }

      return LockoutStatus(
        isLocked: false,
        failedAttempts: failedCount,
        remainingMinutes: 0,
        nextLockoutThreshold: nextThreshold,
        attemptsUntilLock: nextThreshold != null ? nextThreshold - failedCount : null,
        message: failedCount > 0 
            ? 'تبقى ${nextThreshold != null ? nextThreshold - failedCount : 0} محاولات قبل القفل المؤقت'
            : null,
      );
    } catch (e) {
      debugPrint('❌ Error getting lockout status: $e');
      return LockoutStatus(
        isLocked: false,
        failedAttempts: 0,
        remainingMinutes: 0,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 FAILED ATTEMPTS MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> incrementFailedAttempts(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final deviceId = await getDeviceId();

      final docRef = _firestore
          .collection(loginAttemptsCollection)
          .doc(normalizedEmail);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        
        int currentCount = 0;
        List<dynamic> attemptHistory = [];
        
        if (doc.exists) {
          final data = doc.data()!;
          currentCount = data['failed_attempts'] as int? ?? 0;
          attemptHistory = data['attempt_history'] as List<dynamic>? ?? [];
        }

        // Add to history (keep last 10)
        attemptHistory.add({
          'timestamp': DateTime.now().toIso8601String(),
          'device_id': deviceId,
        });
        if (attemptHistory.length > 10) {
          attemptHistory = attemptHistory.sublist(attemptHistory.length - 10);
        }

        final newCount = currentCount + 1;
        final isPermanentLock = newCount >= maxLoginAttempts;

        transaction.set(docRef, {
          'email': normalizedEmail,
          'failed_attempts': newCount,
          'last_attempt': FieldValue.serverTimestamp(),
          'last_device_id': deviceId,
          'attempt_history': attemptHistory,
          'permanently_locked': isPermanentLock,
          'updated_at': FieldValue.serverTimestamp(),
          if (!doc.exists) 'created_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      // Log security event
      await _logSecurityEvent(
        email: normalizedEmail,
        eventType: 'failed_login_attempt',
        severity: 'warning',
        details: {
          'device_id': deviceId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('⚠️ Failed attempt recorded for: $normalizedEmail');
    } catch (e) {
      debugPrint('❌ Error incrementing failed attempts: $e');
      // Don't rethrow - we don't want to break the login flow
    }
  }

  Future<void> resetFailedAttempts(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);

      await _firestore
          .collection(loginAttemptsCollection)
          .doc(normalizedEmail)
          .delete()
          .timeout(firestoreTimeout);

      debugPrint('✅ Failed attempts reset for: $normalizedEmail');
    } catch (e) {
      debugPrint('⚠️ Error resetting failed attempts: $e');
    }
  }

  Future<int> getFailedAttemptsCount(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final lockoutInfo = await _getLockoutInfo(normalizedEmail);
      return lockoutInfo?['failed_attempts'] as int? ?? 0;
    } catch (e) {
      debugPrint('❌ Error getting failed attempts count: $e');
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🧹 AUTO CLEANUP SYSTEM
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _cleanupExpiredAttemptsOnStartup() async {
    try {
      debugPrint('🧹 Cleaning up expired login attempts...');
      
      final cutoffTime = DateTime.now().subtract(attemptExpirationTime);
      final cutoffTimestamp = Timestamp.fromDate(cutoffTime);

      // Query for expired attempts (not permanently locked)
      final expiredAttempts = await _firestore
          .collection(loginAttemptsCollection)
          .where('last_attempt', isLessThan: cutoffTimestamp)
          .where('permanently_locked', isEqualTo: false)
          .limit(50)
          .get()
          .timeout(firestoreTimeout);

      if (expiredAttempts.docs.isEmpty) {
        debugPrint('✅ No expired attempts to clean');
        return;
      }

      final batch = _firestore.batch();
      for (final doc in expiredAttempts.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint('🧹 Cleaned ${expiredAttempts.docs.length} expired login attempts');
    } catch (e) {
      debugPrint('⚠️ Error cleaning up expired attempts: $e');
      // Don't throw - this is a background cleanup
    }
  }

  Future<void> cleanupExpiredSessions() async {
    try {
      final cutoffTime = DateTime.now().subtract(sessionTimeout);
      final cutoffTimestamp = Timestamp.fromDate(cutoffTime);

      final expiredSessions = await _firestore
          .collection(sessionsCollection)
          .where('last_active', isLessThan: cutoffTimestamp)
          .limit(100)
          .get();

      final batch = _firestore.batch();

      for (final doc in expiredSessions.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (expiredSessions.docs.isNotEmpty) {
        debugPrint('🧹 Cleaned up ${expiredSessions.docs.length} expired sessions');
      }
    } catch (e) {
      debugPrint('⚠️ Error cleaning up sessions: $e');
    }
  }

  Future<void> cleanupExpiredAttempts() async {
    try {
      final cutoffTime = DateTime.now().subtract(attemptExpirationTime);
      final cutoffTimestamp = Timestamp.fromDate(cutoffTime);

      final expiredAttempts = await _firestore
          .collection(loginAttemptsCollection)
          .where('last_attempt', isLessThan: cutoffTimestamp)
          .where('permanently_locked', isEqualTo: false)
          .limit(100)
          .get();

      final batch = _firestore.batch();

      for (final doc in expiredAttempts.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (expiredAttempts.docs.isNotEmpty) {
        debugPrint('🧹 Cleaned up ${expiredAttempts.docs.length} expired attempts');
      }
    } catch (e) {
      debugPrint('⚠️ Error cleaning up attempts: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateSessionActivity(String userId) async {
    try {
      final deviceId = await getDeviceId();
      
      await _firestore
          .collection(sessionsCollection)
          .doc(userId)
          .set({
        'user_id': userId,
        'device_id': deviceId,
        'last_active': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true))
          .timeout(firestoreTimeout);

      debugPrint('✅ Session activity updated');
    } catch (e) {
      debugPrint('⚠️ Failed to update session activity: $e');
    }
  }

  Future<void> saveLoginSession({
    required bool rememberMe,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Primary write: SharedPreferences
      await prefs.setBool(prefKeyRememberMe, rememberMe);
      await prefs.setInt(prefKeyLastLoginTime, now);

      // Redundant write: FlutterSecureStorage (survives OEM process kills)
      await _secureStorage.write(
        key: _secureKeyRememberMe,
        value: rememberMe.toString(),
      );
      await _secureStorage.write(
        key: _secureKeyLastLoginTime,
        value: now.toString(),
      );

      debugPrint('✅ Login session saved (dual-write) - Remember Me: $rememberMe');
    } catch (e) {
      debugPrint('⚠️ Failed to save login session: $e');
    }
  }

  Future<void> clearLoginSession() async {
    try {
      await _clearSessionData();
      debugPrint('✅ Login session cleared');
    } catch (e) {
      debugPrint('⚠️ Failed to clear login session: $e');
    }
  }

  Future<void> _clearSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prefKeyRememberMe);
      await prefs.remove(prefKeyLastLoginTime);
      await prefs.remove(prefKeySessionToken);

      // Clear secure backup too
      await _secureStorage.delete(key: _secureKeyRememberMe);
      await _secureStorage.delete(key: _secureKeyLastLoginTime);
    } catch (e) {
      debugPrint('⚠️ Error clearing session data: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 RESILIENT SESSION READERS (OEM Kill Protection)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Reads rememberMe with redundant fallback to FlutterSecureStorage.
  /// On aggressive OEMs (Oppo/ColorOS), SharedPreferences may not flush
  /// before process kill. SecureStorage uses Android Keystore which persists.
  Future<bool> _readRememberMe(SharedPreferences prefs) async {
    // Primary: SharedPreferences (fast)
    final primary = prefs.getBool(prefKeyRememberMe);
    if (primary != null) return primary;

    // Fallback: FlutterSecureStorage (durable, survives OEM kills)
    try {
      final backup = await _secureStorage.read(key: _secureKeyRememberMe);
      if (backup != null) {
        final value = backup == 'true';
        // Self-heal: restore primary from backup
        await prefs.setBool(prefKeyRememberMe, value);
        debugPrint('🔄 Restored rememberMe from secure backup: $value');
        return value;
      }
    } catch (e) {
      debugPrint('⚠️ SecureStorage fallback failed: $e');
    }

    return false; // Truly no data
  }

  /// Reads lastLoginTime with redundant fallback to FlutterSecureStorage.
  Future<int?> _readLastLoginTime(SharedPreferences prefs) async {
    // Primary: SharedPreferences (fast)
    final primary = prefs.getInt(prefKeyLastLoginTime);
    if (primary != null) return primary;

    // Fallback: FlutterSecureStorage
    try {
      final backup = await _secureStorage.read(key: _secureKeyLastLoginTime);
      if (backup != null) {
        final value = int.tryParse(backup);
        if (value != null) {
          // Self-heal: restore primary from backup
          await prefs.setInt(prefKeyLastLoginTime, value);
          debugPrint('🔄 Restored lastLoginTime from secure backup');
          return value;
        }
      }
    } catch (e) {
      debugPrint('⚠️ SecureStorage lastLoginTime fallback failed: $e');
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 REGISTRATION ATTEMPTS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> canAttemptRegistration(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);

      final doc = await _firestore
          .collection(registrationAttemptsCollection)
          .doc(normalizedEmail)
          .get()
          .timeout(firestoreTimeout);

      if (!doc.exists) {
        return true;
      }

      final data = doc.data();
      if (data == null) {
        return true;
      }

      final attempts = data['attempts'] as int? ?? 0;
      final lastAttempt = (data['last_attempt'] as Timestamp?)?.toDate();

      if (attempts >= maxRegistrationAttempts && lastAttempt != null) {
        final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);

        // Registration lockout is 1 hour
        if (timeSinceLastAttempt < const Duration(hours: 1)) {
          return false;
        } else {
          // Auto-reset after lockout period
          await resetRegistrationAttempts(email);
          return true;
        }
      }

      return true;
    } catch (e) {
      debugPrint('⚠️ Error checking registration attempts: $e');
      return true;
    }
  }

  Future<void> incrementRegistrationAttempts(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final deviceId = await getDeviceId();

      final docRef = _firestore
          .collection(registrationAttemptsCollection)
          .doc(normalizedEmail);

      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data()!;
        final currentCount = data['attempts'] as int? ?? 0;

        await docRef.update({
          'attempts': currentCount + 1,
          'last_attempt': FieldValue.serverTimestamp(),
          'last_device_id': deviceId,
        });
      } else {
        await docRef.set({
          'email': normalizedEmail,
          'attempts': 1,
          'last_attempt': FieldValue.serverTimestamp(),
          'last_device_id': deviceId,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error incrementing registration attempts: $e');
    }
  }

  Future<void> resetRegistrationAttempts(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);

      await _firestore
          .collection(registrationAttemptsCollection)
          .doc(normalizedEmail)
          .delete();

      debugPrint('✅ Registration attempts reset');
    } catch (e) {
      debugPrint('⚠️ Error resetting registration attempts: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 SECURITY FIELDS INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> initializeSecurityFields(String userId) async {
    try {
      final deviceId = await getDeviceId();
      
      await _firestore.collection('users').doc(userId).set({
        'security': {
          'account_created_at': FieldValue.serverTimestamp(),
          'last_login': null,
          'login_count': 0,
          'password_changed_at': null,
          'registered_device_id': deviceId,
        },
      }, SetOptions(merge: true)).timeout(firestoreTimeout);

      await _logSecurityEvent(
        userId: userId,
        eventType: 'account_created',
        severity: 'info',
        details: {
          'timestamp': DateTime.now().toIso8601String(),
          'device_id': deviceId,
        },
      );

      debugPrint('✅ Security fields initialized');
    } catch (e) {
      debugPrint('⚠️ Error initializing security fields: $e');
      // Don't throw - allow registration to continue
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 SECURITY LOGGING
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _logSecurityEvent({
    String? userId,
    String? email,
    required String eventType,
    required String severity,
    Map<String, dynamic>? details,
  }) async {
    try {
      final deviceId = await getDeviceId();
      
      final logData = {
        if (userId != null) 'user_id': userId,
        if (email != null) 'email': email,
        'event_type': eventType,
        'severity': severity,
        'device_id': deviceId,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
        if (details != null) 'details': details,
      };

      await _firestore
          .collection(securityLogsCollection)
          .add(logData)
          .timeout(firestoreTimeout);

      debugPrint('📝 Security event logged: $eventType');
    } catch (e) {
      debugPrint('⚠️ Failed to log security event: $e');
    }
  }

  Future<void> logLoginAttempt({
    required String email,
    required bool success,
    String? failureReason,
  }) async {
    await _logSecurityEvent(
      email: email,
      eventType: success ? 'login_success' : 'login_failure',
      severity: success ? 'info' : 'warning',
      details: {
        'timestamp': DateTime.now().toIso8601String(),
        if (!success && failureReason != null) 'reason': failureReason,
      },
    );
  }

  Future<void> logLogoutAttempt({
    required String userId,
  }) async {
    await _logSecurityEvent(
      userId: userId,
      eventType: 'logout',
      severity: 'info',
      details: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logPasswordChange({
    required String userId,
  }) async {
    await _logSecurityEvent(
      userId: userId,
      eventType: 'password_changed',
      severity: 'medium',
      details: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logAccountDeletion({
    required String userId,
    required String email,
  }) async {
    await _logSecurityEvent(
      userId: userId,
      email: email,
      eventType: 'account_deleted',
      severity: 'high',
      details: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 BIOMETRIC SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> getBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(prefKeyBiometricEnabled) ?? false;
    } catch (e) {
      debugPrint('⚠️ Error getting biometric preference: $e');
      return false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyBiometricEnabled, enabled);
      debugPrint('✅ Biometric preference saved: $enabled');
    } catch (e) {
      debugPrint('⚠️ Error saving biometric preference: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Admin method to unlock account (for support purposes)
  Future<void> adminUnlockAccount(String email) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      
      await _firestore
          .collection(loginAttemptsCollection)
          .doc(normalizedEmail)
          .delete();

      await _logSecurityEvent(
        email: normalizedEmail,
        eventType: 'admin_account_unlock',
        severity: 'high',
        details: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('✅ Account unlocked by admin: $normalizedEmail');
    } catch (e) {
      debugPrint('❌ Error unlocking account: $e');
      rethrow;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 LOCKOUT STATUS MODEL
// ═══════════════════════════════════════════════════════════════════════════

class LockoutStatus {
  final bool isLocked;
  final bool isPermanent;
  final int failedAttempts;
  final int remainingMinutes;
  final int? nextLockoutThreshold;
  final int? attemptsUntilLock;
  final String? message;

  LockoutStatus({
    required this.isLocked,
    this.isPermanent = false,
    required this.failedAttempts,
    required this.remainingMinutes,
    this.nextLockoutThreshold,
    this.attemptsUntilLock,
    this.message,
  });

  bool get hasWarning => failedAttempts > 0 && !isLocked;
  
  String get userFriendlyMessage {
    if (isPermanent) {
      return 'الحساب مقفل بشكل دائم.\nيرجى التواصل مع الدعم الفني لفتح الحساب.';
    }
    
    if (isLocked) {
      if (remainingMinutes <= 1) {
        return 'الحساب مقفل مؤقتاً.\nيرجى الانتظار دقيقة واحدة.';
      }
      return 'الحساب مقفل مؤقتاً.\nيرجى الانتظار $remainingMinutes دقيقة.';
    }
    
    if (hasWarning && attemptsUntilLock != null) {
      if (attemptsUntilLock == 1) {
        return '⚠️ تحذير: محاولة واحدة متبقية قبل القفل المؤقت';
      }
      return '⚠️ تحذير: $attemptsUntilLock محاولات متبقية قبل القفل المؤقت';
    }
    
    return '';
  }
}

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/errors/failures.dart';
import '../core/validators/auth_validators.dart';
import '../core/services/credentials_manager.dart';
import '../models/user_model.dart';
import 'auth/auth_security_service.dart';
import 'auth/auth_profile_service.dart';

sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  final UserModel user;
  const LoginSuccess(this.user);
}

class LoginEmailNotVerified extends LoginResult {
  final String email;
  final bool verificationEmailSent;
  final String? errorMessage;
  
  const LoginEmailNotVerified({
    required this.email,
    required this.verificationEmailSent,
    this.errorMessage,
  });
}

class LoginFailed extends LoginResult {
  final AuthFailure failure;
  const LoginFailed(this.failure);
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthValidators _validators = AuthValidators();
  final AuthSecurityService _security = AuthSecurityService();
  final AuthProfileService _profile = AuthProfileService();

  static const Duration authTimeout = Duration(seconds: 10);
  static const Duration firestoreTimeout = Duration(seconds: 15);
  static const Duration cacheValidity = Duration(minutes: 5);
  static const String usersCollection = 'users';

  UserModel? _cachedUser;
  DateTime? _cacheTime;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;
  bool get isUserLoggedIn => _auth.currentUser != null;

  void clearCache() {
    _cachedUser = null;
    _cacheTime = null;
  }

  bool _isCacheValid() {
    if (_cacheTime == null || _cachedUser == null) return false;
    final age = DateTime.now().difference(_cacheTime!);
    return age < cacheValidity;
  }

  String _generateDoctorCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final timestampPart = timestamp.toString().substring(5, 13);
    final random = Random();
    final randomPart = String.fromCharCodes(
      List.generate(4, (index) {
        final isLetter = random.nextBool();
        if (isLetter) {
          return random.nextInt(26) + 65;
        } else {
          return random.nextInt(10) + 48;
        }
      }),
    );
    return 'DR$timestampPart$randomPart';
  }

  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    DateTime? dateOfBirth,
    String? specialty,
    String? licenseNumber,
    String? gender,
  }) async {
    UserCredential? userCredential;
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📝 AuthService: Starting user registration...');
      debugPrint('═══════════════════════════════════════════════════════');

      await _security.incrementRegistrationAttempts(email);
      if (!await _security.canAttemptRegistration(email)) {
        throw UnexpectedFailure('تم تجاوز عدد محاولات التسجيل المسموح بها');
      }

      _validators.validateRegistrationInput(
        name: name,
        email: email,
        password: password,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );

      if (role == UserRole.doctor) {
        _validators.validateDoctorFields(
          specialty: specialty,
          licenseNumber: licenseNumber,
        );
      }

      debugPrint('🔐 Creating Firebase Auth account...');
      userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: _validators.sanitizeEmail(email),
        password: password,
      )
          .timeout(authTimeout);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw UnexpectedFailure('فشل إنشاء حساب المصادقة');
      }

      debugPrint('✅ Firebase Auth account created: ${firebaseUser.uid}');

      String? doctorCode;
      if (role == UserRole.doctor) {
        doctorCode = _generateDoctorCode();
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        name: _validators.sanitizeName(name),
        email: _validators.sanitizeEmail(email),
        role: role,
        createdAt: DateTime.now(),
        phone: _validators.sanitizePhone(phone),
        dateOfBirth: dateOfBirth,
        specialty: specialty?.trim(),
        licenseNumber: licenseNumber?.trim(),
        doctorCode: doctorCode,
        gender: gender,
      );

      debugPrint('💾 Saving user data to Firestore...');
      await _firestore
          .collection(usersCollection)
          .doc(firebaseUser.uid)
          .set(userModel.toMap())
          .timeout(firestoreTimeout);

      await _security.initializeSecurityFields(firebaseUser.uid);

      try {
        await firebaseUser.updateDisplayName(userModel.name).timeout(authTimeout);
        debugPrint('✅ Firebase Auth display name updated');
      } catch (e) {
        debugPrint('⚠️ Failed to update display name: $e');
      }

      try {
        await firebaseUser.sendEmailVerification().timeout(authTimeout);
        debugPrint('📧 Verification email sent to: ${userModel.email}');
      } catch (e) {
        debugPrint('⚠️ Failed to send verification email: $e');
      }

      await _auth.signOut();
      debugPrint('🔐 User signed out - must verify email before login');

      await _security.resetRegistrationAttempts(email);
      clearCache();

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🎉 Registration successful!');
      debugPrint('   UID: ${userModel.uid}');
      debugPrint('   Name: ${userModel.name}');
      debugPrint('   Role: ${userModel.role.toEnglish()}');
      debugPrint('   📧 Please verify email before login');
      debugPrint('═══════════════════════════════════════════════════════');

      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error: ${e.code}');
      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
          debugPrint('🔄 Rolled back Firebase Auth user');
        } catch (rollbackError) {
          debugPrint('⚠️ Rollback failed: $rollbackError');
        }
      }
      throw authFailureFromFirebaseAuth(e);
    } on FirebaseException catch (e) {
      debugPrint('❌ Firestore error: ${e.code}');
      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
          debugPrint('🔄 Rolled back Firebase Auth user');
        } catch (rollbackError) {
          debugPrint('⚠️ Rollback failed: $rollbackError');
        }
      }
      throw authFailureFromFirestore(e);
    } on TimeoutException {
      debugPrint('⏰ Timeout during registration');
      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
          debugPrint('🔄 Rolled back Firebase Auth user');
        } catch (rollbackError) {
          debugPrint('⚠️ Rollback failed: $rollbackError');
        }
      }
      throw TimeoutFailure();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      if (userCredential != null) {
        try {
          await userCredential.user?.delete();
          debugPrint('🔄 Rolled back Firebase Auth user');
        } catch (rollbackError) {
          debugPrint('⚠️ Rollback failed: $rollbackError');
        }
      }
      throw authFailureFromException(e);
    }
  }

  Future<LoginResult> loginUserWithResult({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔑 AuthService: Starting user login...');
      debugPrint('═══════════════════════════════════════════════════════');

      _validators.validateLoginInput(email: email, password: password);
      final normalizedEmail = _validators.sanitizeEmail(email);

      if (await _security.isAccountLocked(normalizedEmail)) {
        final remaining = await _security.getRemainingLockoutTime(normalizedEmail);
        return LoginFailed(UnexpectedFailure('الحساب مقفل. حاول بعد $remaining دقيقة'));
      }

      debugPrint('🔐 Attempting Firebase Auth sign in...');
      final userCredential = await _auth
          .signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      )
          .timeout(authTimeout);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return LoginFailed(UnexpectedFailure('فشل تسجيل الدخول'));
      }

      if (!firebaseUser.emailVerified) {
        debugPrint('⚠️ Email not verified - sending verification email BEFORE sign out...');
        
        bool emailSent = false;
        String? errorMessage;
        
        try {
          await firebaseUser.sendEmailVerification().timeout(authTimeout);
          emailSent = true;
          debugPrint('✅ Verification email sent to: $normalizedEmail');
        } on FirebaseAuthException catch (e) {
          debugPrint('❌ Failed to send verification email: ${e.code}');
          if (e.code == 'too-many-requests') {
            errorMessage = 'تم إرسال عدة رسائل. يرجى التحقق من بريدك أو الانتظار قليلاً.';
          } else {
            errorMessage = 'تعذر إرسال رسالة التفعيل.';
          }
        } catch (e) {
          debugPrint('❌ Failed to send verification email: $e');
          errorMessage = 'تعذر إرسال رسالة التفعيل.';
        }
        
        await _auth.signOut();
        debugPrint('🔐 User signed out after handling unverified email');
        
        return LoginEmailNotVerified(
          email: normalizedEmail,
          verificationEmailSent: emailSent,
          errorMessage: errorMessage,
        );
      }

      await _security.resetFailedAttempts(normalizedEmail);

      debugPrint('💾 Loading user data from Firestore...');
      final userModel = await getUserData(firebaseUser.uid);
      if (userModel == null) {
        return LoginFailed(DataNotFoundFailure());
      }

      await _security.updateSessionActivity(firebaseUser.uid);
      await _security.logLoginAttempt(
        email: normalizedEmail,
        success: true,
      );

      _cachedUser = userModel;
      _cacheTime = DateTime.now();

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🎉 Login successful!');
      debugPrint('   UID: ${userModel.uid}');
      debugPrint('   Name: ${userModel.name}');
      debugPrint('   Role: ${userModel.role.toEnglish()}');
      debugPrint('   Email Verified: ${firebaseUser.emailVerified}');
      debugPrint('═══════════════════════════════════════════════════════');

      return LoginSuccess(userModel);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error: ${e.code}');
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        await _security.incrementFailedAttempts(email);
      }
      await _security.logLoginAttempt(
        email: email,
        success: false,
        failureReason: e.code,
      );
      return LoginFailed(authFailureFromFirebaseAuth(e));
    } on TimeoutException {
      debugPrint('⏰ Timeout during login');
      return LoginFailed(TimeoutFailure());
    } on AuthFailure catch (e) {
      return LoginFailed(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return LoginFailed(authFailureFromException(e));
    }
  }

  @Deprecated('Use loginUserWithResult instead for better email verification handling')
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final result = await loginUserWithResult(email: email, password: password);
    
    switch (result) {
      case LoginSuccess(:final user):
        return user;
      case LoginEmailNotVerified():
        throw EmailNotVerifiedFailure();
      case LoginFailed(:final failure):
        throw failure;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚪 LOGOUT - Enterprise Grade Implementation
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // Complete logout flow that ensures:
  // 1. Security logging
  // 2. Session cleanup
  // 3. Credentials clearing (optional)
  // 4. Firebase sign out
  // 5. Cache clearing
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// Logout user with optional credentials clearing
  /// 
  /// [clearCredentials] - If true (default), clears saved email/password
  ///                      This prevents auto-login on next app launch
  /// 
  /// Throws [AuthFailure] on error
  Future<void> logoutUser({bool clearCredentials = true}) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🚪 AuthService: Starting logout process...');
      debugPrint('═══════════════════════════════════════════════════════════');

      // ═══════════════════════════════════════════════════════════════
      // Step 1: Log logout attempt (for audit trail)
      // ═══════════════════════════════════════════════════════════════
      final userId = _auth.currentUser?.uid;
      final userEmail = _auth.currentUser?.email;
      
      if (userId != null) {
        debugPrint('📝 Logging logout attempt for user: $userId');
        await _security.logLogoutAttempt(userId: userId);
      }

      // ═══════════════════════════════════════════════════════════════
      // Step 2: Clear saved credentials (CRITICAL - prevents auto-login)
      // ═══════════════════════════════════════════════════════════════
      if (clearCredentials) {
        debugPrint('🧹 Clearing saved credentials...');
        try {
          final credentialsResult = await CredentialsManager.instance.clearAll();
          if (credentialsResult.success) {
            debugPrint('✅ Credentials cleared successfully');
          } else {
            debugPrint('⚠️ Warning: Failed to clear credentials: ${credentialsResult.errorMessage}');
            // Continue with logout even if credentials clearing fails
          }
        } catch (e) {
          debugPrint('⚠️ Warning: Error clearing credentials: $e');
          // Continue with logout - don't fail the entire logout
        }
      } else {
        debugPrint('ℹ️ Skipping credentials clearing (clearCredentials=false)');
      }

      // ═══════════════════════════════════════════════════════════════
      // Step 3: Clear login session
      // ═══════════════════════════════════════════════════════════════
      debugPrint('🔒 Clearing login session...');
      await _security.clearLoginSession();

      // ═══════════════════════════════════════════════════════════════
      // Step 4: Firebase sign out
      // ═══════════════════════════════════════════════════════════════
      debugPrint('🔐 Signing out from Firebase...');
      await _auth.signOut().timeout(authTimeout);

      // ═══════════════════════════════════════════════════════════════
      // Step 5: Clear cache
      // ═══════════════════════════════════════════════════════════════
      debugPrint('🗑️ Clearing cache...');
      clearCache();

      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('✅ LOGOUT COMPLETE');
      debugPrint('   • User: ${userEmail ?? 'unknown'}');
      debugPrint('   • Credentials cleared: $clearCredentials');
      debugPrint('   • Session cleared: true');
      debugPrint('   • Firebase signed out: true');
      debugPrint('   • Cache cleared: true');
      debugPrint('═══════════════════════════════════════════════════════════');

    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error during logout: ${e.code}');
      // Still try to clear credentials even on Firebase error
      if (clearCredentials) {
        try {
          await CredentialsManager.instance.clearAll();
        } catch (_) {}
      }
      throw authFailureFromFirebaseAuth(e);
    } on TimeoutException {
      debugPrint('⏰ Timeout during logout');
      // Still try to clear credentials even on timeout
      if (clearCredentials) {
        try {
          await CredentialsManager.instance.clearAll();
        } catch (_) {}
      }
      throw TimeoutFailure();
    } catch (e) {
      debugPrint('❌ Unexpected error during logout: $e');
      // Still try to clear credentials even on error
      if (clearCredentials) {
        try {
          await CredentialsManager.instance.clearAll();
        } catch (_) {}
      }
      throw authFailureFromException(e);
    }
  }

  /// Logout user and clear all credentials (convenience method)
  /// 
  /// This is a shortcut for `logoutUser(clearCredentials: true)`
  Future<void> logoutAndClearCredentials() async {
    return logoutUser(clearCredentials: true);
  }

  /// Logout user but keep credentials (for session-only logout)
  /// 
  /// Use this when user wants to stay "remembered" but just end current session
  Future<void> logoutKeepCredentials() async {
    return logoutUser(clearCredentials: false);
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      if (_isCacheValid() && _cachedUser?.uid == uid) {
        debugPrint('📦 Using cached user data');
        return _cachedUser;
      }
      return await _profile.getUserData(uid);
    } catch (e) {
      debugPrint('❌ Error getting user data: $e');
      rethrow;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _profile.updateUserData(uid: uid, data: data);
      clearCache();
    } catch (e) {
      debugPrint('❌ Error updating user data: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      await _profile.updateUserProfile(
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );
      clearCache();
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _profile.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _security.logPasswordChange(userId: userId);
      }
    } catch (e) {
      debugPrint('❌ Error changing password: $e');
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _profile.sendEmailVerification();
    } catch (e) {
      debugPrint('❌ Error sending email verification: $e');
      rethrow;
    }
  }

  Future<void> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📧 AuthService: Resending verification email...');
      final normalizedEmail = _validators.sanitizeEmail(email);
      
      final userCredential = await _auth
          .signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      )
          .timeout(authTimeout);
      
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw UnexpectedFailure('فشل تسجيل الدخول');
      }

      if (firebaseUser.emailVerified) {
        await _auth.signOut();
        throw UnexpectedFailure('البريد الإلكتروني مفعّل بالفعل');
      }

      await firebaseUser.sendEmailVerification().timeout(authTimeout);
      await _auth.signOut();
      
      debugPrint('✅ Verification email resent to: $normalizedEmail');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error: ${e.code}');
      if (e.code == 'too-many-requests') {
        throw TooManyRequestsFailure();
      }
      throw authFailureFromFirebaseAuth(e);
    } on TimeoutException {
      debugPrint('⏰ Timeout resending verification email');
      throw TimeoutFailure();
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      if (e is AuthFailure) rethrow;
      throw authFailureFromException(e);
    }
  }

  Future<bool> reloadUser() async {
    try {
      return await _profile.reloadUser();
    } catch (e) {
      debugPrint('❌ Error reloading user: $e');
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('📧 AuthService: Sending password reset email...');
      final normalizedEmail = _validators.sanitizeEmail(email);
      if (!_validators.isValidEmail(normalizedEmail)) {
        throw InvalidEmailFailure();
      }
      await _auth.sendPasswordResetEmail(email: normalizedEmail).timeout(authTimeout);
      debugPrint('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error: ${e.code}');
      if (e.code == 'too-many-requests') {
        throw TooManyRequestsFailure();
      }
      throw authFailureFromFirebaseAuth(e);
    } on TimeoutException {
      debugPrint('⏰ Timeout sending password reset email');
      throw TimeoutFailure();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw authFailureFromException(e);
    }
  }

  Future<void> resetPassword(String email) async {
    return sendPasswordResetEmail(email);
  }

  Future<void> deleteAccount() async {
    try {
      debugPrint('🗑️ AuthService: Deleting user account...');
      final user = _auth.currentUser;
      if (user == null) {
        throw UnexpectedFailure('لا يوجد مستخدم مسجل دخول');
      }
      await _security.logAccountDeletion(
        userId: user.uid,
        email: user.email ?? '',
      );
      await _firestore
          .collection(usersCollection)
          .doc(user.uid)
          .delete()
          .timeout(firestoreTimeout);
      await user.delete().timeout(authTimeout);
      clearCache();
      debugPrint('✅ Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error: ${e.code}');
      if (e.code == 'requires-recent-login') {
        throw UnexpectedFailure('يرجى تسجيل الدخول مرة أخرى قبل حذف الحساب');
      }
      throw authFailureFromFirebaseAuth(e);
    } on TimeoutException {
      debugPrint('⏰ Timeout deleting account');
      throw TimeoutFailure();
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw authFailureFromException(e);
    }
  }

  Future<void> deleteUserAccount() async {
    return deleteAccount();
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      return await _validators.checkEmailExists(email);
    } catch (e) {
      debugPrint('❌ Error checking email: $e');
      return false;
    }
  }

  Future<void> refreshUserToken() async {
    try {
      await _profile.refreshUserToken();
    } catch (e) {
      debugPrint('⚠️ Error refreshing token: $e');
    }
  }

  bool isEmailVerified() {
    return _profile.isEmailVerified();
  }

  static String getErrorMessage(Object error) {
    if (error is AuthFailure) {
      return error.userMessage;
    }
    if (error is FirebaseAuthException) {
      return authFailureFromFirebaseAuth(error).userMessage;
    }
    if (error is FirebaseException) {
      return authFailureFromFirestore(error).userMessage;
    }
    if (error is TimeoutException) {
      return 'انتهت مهلة الاتصال';
    }
    return 'حدث خطأ غير متوقع';
  }

  Future<bool> validateSessionOnStartup() async {
    try {
      return await _security.validateSessionOnStartup();
    } catch (e) {
      debugPrint('❌ Error validating session: $e');
      return false;
    }
  }

  Future<bool> isAccountLocked(String email) async {
    try {
      return await _security.isAccountLocked(email);
    } catch (e) {
      debugPrint('❌ Error checking account lock: $e');
      return false;
    }
  }

  Future<int> getRemainingLockoutTime(String email) async {
    try {
      return await _security.getRemainingLockoutTime(email);
    } catch (e) {
      debugPrint('❌ Error getting lockout time: $e');
      return 0;
    }
  }

  Future<void> resetFailedAttempts(String email) async {
    try {
      await _security.resetFailedAttempts(email);
    } catch (e) {
      debugPrint('⚠️ Error resetting failed attempts: $e');
    }
  }

  Future<void> logLoginActivity({
    required String email,
    required bool success,
    String? reason,
  }) async {
    try {
      await _security.logLoginAttempt(
        email: email,
        success: success,
        failureReason: reason,
      );
    } catch (e) {
      debugPrint('⚠️ Error logging login activity: $e');
    }
  }

  Future<void> incrementFailedAttempts(String email) async {
    try {
      await _security.incrementFailedAttempts(email);
    } catch (e) {
      debugPrint('❌ Error incrementing failed attempts: $e');
      rethrow;
    }
  }

  Future<int> getFailedAttemptsCount(String email) async {
    try {
      return await _security.getFailedAttemptsCount(email);
    } catch (e) {
      debugPrint('❌ Error getting failed attempts count: $e');
      return 0;
    }
  }
}

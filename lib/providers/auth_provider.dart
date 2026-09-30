import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../core/errors/failures.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

export '../services/auth_service.dart' show LoginResult, LoginSuccess, LoginEmailNotVerified, LoginFailed;

enum AuthErrorType {
  network,
  timeout,
  validation,
  permission,
  authentication,
  notFound,
  emailNotVerified,
  unknown
}

enum AuthOperationType {
  login,
  logout,
  register,
  updateProfile,
  changePassword,
  resetPassword,
  deleteAccount,
  emailVerification,
  loadUserData
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  firebase_auth.User? _firebaseUser;
  bool _isLoading = false;
  bool _isInitializing = true; // true until first authStateChanges() emission resolves
  String? _errorMessage;
  AuthErrorType? _errorType;
  bool _isPendingEmailVerification = false;

  StreamSubscription<firebase_auth.User?>? _authStateSubscription;
  Timer? _loadingTimeoutTimer;
  UserModel? _previousUserState;

  DateTime? _lastEmailVerificationSent;
  DateTime? _lastPasswordResetSent;
  final Map<AuthOperationType, DateTime> _lastOperationTime = {};

  static const Duration _operationTimeout = Duration(seconds: 30);
  static const Duration _loadingTimeout = Duration(seconds: 45);
  static const Duration _emailVerificationCooldown = Duration(minutes: 2);
  static const Duration _passwordResetCooldown = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  UserModel? get user => _user;
  UserModel? get userModel => _user;
  firebase_auth.User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading || _isInitializing;
  String? get errorMessage => _errorMessage;
  AuthErrorType? get errorType => _errorType;
  bool get isAuthenticated => _firebaseUser != null || _isPendingEmailVerification;
  bool get isPendingEmailVerification => _isPendingEmailVerification;
  bool get shouldBlockAuthRedirect => _isPendingEmailVerification;
  bool get isUserDataLoaded => _user != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;
  UserRole? get userRole => _user?.role;
  String? get userName => _user?.name;
  String? get userEmail => _user?.email;
  String? get userId => _user?.uid;
  String? get userPhone => _user?.phone;
  DateTime? get userDateOfBirth => _user?.dateOfBirth;
  String? get userSpecialty => _user?.specialty;
  String? get userLicenseNumber => _user?.licenseNumber;
  String? get userDoctorCode => _user?.doctorCode;

  AuthProvider() {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _authStateSubscription?.cancel();

    _authStateSubscription = _authService.authStateChanges.listen(
          (firebase_auth.User? firebaseUser) {
        _handleAuthStateChange(firebaseUser);
      },
      onError: (error) {
        _logError('Auth state error', error);
        _updateState(errorMessage: 'حدث خطأ في المصادقة', errorType: AuthErrorType.authentication);
      },
    );
  }

  void _handleAuthStateChange(firebase_auth.User? firebaseUser) {
    _log('Auth state changed: ${firebaseUser?.email ?? "null"}');

    // Mark initialization complete on first emission — safe to route now
    _isInitializing = false;
    _firebaseUser = firebaseUser;

    if (firebaseUser != null) {
      _loadUserDataWithRetry(firebaseUser.uid);
    } else {
      _user = null;
      _authService.clearCache();
      notifyListeners();
    }
  }

  Future<void> _loadUserDataWithRetry(String uid, {int retryCount = 0}) async {
    try {
      final userData = await _authService.getUserData(uid);

      if (userData != null) {
        _user = userData;
        _log('User data loaded: ${userData.name}');
      } else {
        _logWarning('User data not found for uid: $uid');
        _user = null;
      }

      notifyListeners();
    } catch (e) {
      if (retryCount < _maxRetries) {
        _logWarning('Retry ${retryCount + 1}/$_maxRetries loading user data...');
        await Future.delayed(_retryDelay);
        return _loadUserDataWithRetry(uid, retryCount: retryCount + 1);
      }

      _logError('Failed loading user data after $_maxRetries attempts', e);
      _user = null;
      notifyListeners();
    }
  }

  String? _pendingVerificationEmail;
  String? _pendingVerificationPassword;

  String? get pendingVerificationEmail => _pendingVerificationEmail;
  String? get pendingVerificationPassword => _pendingVerificationPassword;

  Future<bool> register({
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
    return _executeOperation(
      operation: () async {
        final user = await _authService.registerUser(
          name: name,
          email: email,
          password: password,
          role: role,
          phone: phone,
          dateOfBirth: dateOfBirth,
          specialty: specialty,
          licenseNumber: licenseNumber,
          gender: gender,
        );

        if (user != null) {
          _pendingVerificationEmail = email;
          _pendingVerificationPassword = password;
          _log('Registration successful - pending email verification');
          return true;
        }

        _updateState(errorMessage: 'فشل إنشاء الحساب', errorType: AuthErrorType.unknown);
        return false;
      },
      operationType: AuthOperationType.register,
      operationName: 'Registration',
    );
  }

  void clearPendingVerification() {
    _pendingVerificationEmail = null;
    _pendingVerificationPassword = null;
    _isPendingEmailVerification = false;
    _log('Pending verification cleared');
    notifyListeners();
  }

  void setPendingEmailVerification(bool value) {
    _isPendingEmailVerification = value;
    _log('isPendingEmailVerification set to: $value');
    notifyListeners();
  }

  LoginResult? _lastLoginResult;
  LoginResult? get lastLoginResult => _lastLoginResult;

  Future<LoginResult> loginWithResult({
    required String email,
    required String password,
  }) async {
    _startLoadingWithTimeout();
    _clearError();

    try {
      _log('Starting Login with Result...');

      final result = await _authService.loginUserWithResult(
        email: email,
        password: password,
      ).timeout(_operationTimeout);

      _lastLoginResult = result;

      switch (result) {
        case LoginSuccess(:final user):
          _user = user;
          _firebaseUser = _authService.currentFirebaseUser;
          _log('Login successful');
          _recordOperation(AuthOperationType.login);
          break;

        case LoginEmailNotVerified(:final email, :final verificationEmailSent, :final errorMessage):
          _log('Login failed - email not verified: $email');
          _log('Verification email sent: $verificationEmailSent');
          if (errorMessage != null) {
            _log('Error message: $errorMessage');
          }
          _pendingVerificationEmail = email;
          _pendingVerificationPassword = password;
          _isPendingEmailVerification = true;
          _log('isPendingEmailVerification set to TRUE');
          break;

        case LoginFailed(:final failure):
          _logError('Login failed', failure);
          _updateState(
            errorMessage: failure.userMessage,
            errorType: AuthErrorType.authentication,
          );
          break;
      }

      _stopLoading();
      return result;
    } on TimeoutException {
      _logError('Login timeout', null);
      _updateState(
        errorMessage: 'انتهت مهلة العملية',
        errorType: AuthErrorType.timeout,
      );
      _stopLoading();
      return LoginFailed(TimeoutFailure());
    } catch (e) {
      _logError('Login error', e);
      final errorMessage = AuthService.getErrorMessage(e);
      _updateState(
        errorMessage: errorMessage,
        errorType: _classifyError(e),
      );
      _stopLoading();
      return LoginFailed(authFailureFromException(e));
    }
  }

  @Deprecated('Use loginWithResult instead for better email verification handling')
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final result = await loginWithResult(email: email, password: password);

    switch (result) {
      case LoginSuccess():
        return true;
      case LoginEmailNotVerified():
        _updateState(
          errorMessage: 'يرجى تفعيل بريدك الإلكتروني أولاً',
          errorType: AuthErrorType.emailNotVerified,
        );
        return false;
      case LoginFailed():
        return false;
    }
  }

  Future<bool> logout() async {
    return _executeOperation(
      operation: () async {
        await _authService.logoutUser();
        _user = null;
        _firebaseUser = null;
        _lastLoginResult = null;
        _clearOperationHistory();
        return true;
      },
      operationType: AuthOperationType.logout,
      operationName: 'Logout',
    );
  }

  Future<bool> sendEmailVerification() async {
    if (!_canPerformOperation(_lastEmailVerificationSent, _emailVerificationCooldown)) {
      final remaining = _getRemainingCooldown(_lastEmailVerificationSent, _emailVerificationCooldown);
      _updateState(
        errorMessage: 'يرجى الانتظار $remaining ثانية قبل إرسال رسالة جديدة',
        errorType: AuthErrorType.validation,
      );
      return false;
    }

    final result = await _executeOperation(
      operation: () async {
        await _authService.sendEmailVerification();
        _lastEmailVerificationSent = DateTime.now();
        return true;
      },
      operationType: AuthOperationType.emailVerification,
      operationName: 'Email Verification',
    );

    return result;
  }

  Future<bool> reloadUser() async {
    try {
      _log('Reloading user...');

      final isVerified = await _authService.reloadUser();
      _firebaseUser = _authService.currentFirebaseUser;

      _log('User reloaded - Email verified: $isVerified');
      notifyListeners();

      return isVerified;
    } catch (e) {
      _logError('Reload user error', e);
      return false;
    }
  }

  Future<bool> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    if (!_canPerformOperation(_lastEmailVerificationSent, _emailVerificationCooldown)) {
      final remaining = _getRemainingCooldown(_lastEmailVerificationSent, _emailVerificationCooldown);
      _updateState(
        errorMessage: 'يرجى الانتظار $remaining ثانية قبل إرسال رسالة جديدة',
        errorType: AuthErrorType.validation,
      );
      return false;
    }

    final result = await _executeOperation(
      operation: () async {
        await _authService.resendVerificationEmail(
          email: email,
          password: password,
        );
        _lastEmailVerificationSent = DateTime.now();
        return true;
      },
      operationType: AuthOperationType.emailVerification,
      operationName: 'Resend Email Verification',
    );

    return result;
  }

  Future<bool> resetPassword(String email) async {
    if (!_canPerformOperation(_lastPasswordResetSent, _passwordResetCooldown)) {
      final remaining = _getRemainingCooldown(_lastPasswordResetSent, _passwordResetCooldown);
      _updateState(
        errorMessage: 'يرجى الانتظار $remaining ثانية قبل المحاولة مرة أخرى',
        errorType: AuthErrorType.validation,
      );
      return false;
    }

    final result = await _executeOperation(
      operation: () async {
        await _authService.resetPassword(email);
        _lastPasswordResetSent = DateTime.now();
        return true;
      },
      operationType: AuthOperationType.resetPassword,
      operationName: 'Password Reset',
    );

    return result;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    return resetPassword(email);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _executeOperation(
      operation: () async {
        await _authService.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        return true;
      },
      operationType: AuthOperationType.changePassword,
      operationName: 'Change Password',
    );
  }

  Future<bool> updateUserData(Map<String, dynamic> data) async {
    if (!_validateUpdateOperation(data)) {
      return false;
    }

    _saveUserState();

    return _executeOperation(
      operation: () async {
        await _authService.updateUserData(_user!.uid, data);
        await _loadUserDataWithRetry(_user!.uid);
        return true;
      },
      operationType: AuthOperationType.updateProfile,
      operationName: 'Update User Data',
      rollbackOnError: true,
    );
  }

  Future<void> refreshUserData() async {
    if (_user == null) {
      _logWarning('No user to refresh');
      return;
    }

    try {
      _log('Refreshing user data...');
      await _loadUserDataWithRetry(_user!.uid);
    } catch (e) {
      _logError('Refresh user data error', e);
    }
  }

  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    if (_user == null) {
      _updateState(
        errorMessage: 'لا يوجد مستخدم مسجل',
        errorType: AuthErrorType.authentication,
      );
      return false;
    }

    _saveUserState();

    return _executeOperation(
      operation: () async {
        await _authService.updateUserProfile(
          name: name,
          phone: phone,
          photoUrl: photoUrl,
        );
        await _loadUserDataWithRetry(_user!.uid);
        return true;
      },
      operationType: AuthOperationType.updateProfile,
      operationName: 'Update Profile',
      rollbackOnError: true,
    );
  }

  Future<bool> deleteAccount() async {
    if (_user == null) {
      _updateState(
        errorMessage: 'لا يوجد مستخدم مسجل',
        errorType: AuthErrorType.authentication,
      );
      return false;
    }

    return _executeOperation(
      operation: () async {
        await _authService.deleteAccount();
        _user = null;
        _firebaseUser = null;
        _lastLoginResult = null;
        _clearOperationHistory();
        return true;
      },
      operationType: AuthOperationType.deleteAccount,
      operationName: 'Delete Account',
    );
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      _log('Checking email existence: $email');
      return await _authService.checkEmailExists(email);
    } catch (e) {
      _logError('Check email error', e);
      return false;
    }
  }

  Future<void> refreshToken() async {
    try {
      _log('Refreshing token...');
      await _authService.refreshUserToken();
      _log('Token refreshed');
    } catch (e) {
      _logError('Refresh token error', e);
    }
  }

  Future<bool> _executeOperation({
    required Future<bool> Function() operation,
    required AuthOperationType operationType,
    required String operationName,
    bool rollbackOnError = false,
  }) async {
    _startLoadingWithTimeout();
    _clearError();

    try {
      _log('Starting $operationName...');

      final result = await operation().timeout(_operationTimeout);

      if (result) {
        _log('$operationName successful');
        _recordOperation(operationType);
      } else {
        _logWarning('$operationName returned false');
      }

      _stopLoading();
      return result;
    } on TimeoutException {
      _logError('$operationName timeout', null);
      _handleError('انتهت مهلة العملية', AuthErrorType.timeout, rollbackOnError);
      return false;
    } catch (e) {
      _logError('$operationName error', e);
      final errorType = _classifyError(e);
      final errorMessage = AuthService.getErrorMessage(e);
      _handleError(errorMessage, errorType, rollbackOnError);
      return false;
    }
  }

  bool _validateUpdateOperation(Map<String, dynamic> data) {
    if (_user == null) {
      _updateState(
        errorMessage: 'لا يوجد مستخدم مسجل',
        errorType: AuthErrorType.authentication,
      );
      return false;
    }

    if (_firebaseUser == null) {
      _updateState(
        errorMessage: 'جلسة المستخدم منتهية',
        errorType: AuthErrorType.authentication,
      );
      return false;
    }

    if (data.isEmpty) {
      _updateState(
        errorMessage: 'لا توجد بيانات للتحديث',
        errorType: AuthErrorType.validation,
      );
      return false;
    }

    return true;
  }

  void _saveUserState() {
    _previousUserState = _user;
  }

  void _restoreUserState() {
    if (_previousUserState != null) {
      _user = _previousUserState;
      _previousUserState = null;
      notifyListeners();
    }
  }

  void _handleError(String message, AuthErrorType type, bool rollback) {
    _updateState(errorMessage: message, errorType: type);
    _stopLoading();

    if (rollback) {
      _restoreUserState();
    }
  }

  AuthErrorType _classifyError(Object error) {
    if (error is TimeoutException) {
      return AuthErrorType.timeout;
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('internet')) {
      return AuthErrorType.network;
    }

    if (errorString.contains('permission') ||
        errorString.contains('unauthorized') ||
        errorString.contains('denied')) {
      return AuthErrorType.permission;
    }

    if (errorString.contains('not-found') ||
        errorString.contains('notfound') ||
        errorString.contains('no user')) {
      return AuthErrorType.notFound;
    }

    if (errorString.contains('email') && errorString.contains('verif')) {
      return AuthErrorType.emailNotVerified;
    }

    if (errorString.contains('invalid') ||
        errorString.contains('validation') ||
        errorString.contains('weak-password') ||
        errorString.contains('email-already')) {
      return AuthErrorType.validation;
    }

    if (errorString.contains('auth') ||
        errorString.contains('credential') ||
        errorString.contains('password') ||
        errorString.contains('sign')) {
      return AuthErrorType.authentication;
    }

    return AuthErrorType.unknown;
  }

  bool _canPerformOperation(DateTime? lastTime, Duration cooldown) {
    if (lastTime == null) return true;
    return DateTime.now().difference(lastTime) >= cooldown;
  }

  int _getRemainingCooldown(DateTime? lastTime, Duration cooldown) {
    if (lastTime == null) return 0;
    final elapsed = DateTime.now().difference(lastTime);
    final remaining = cooldown - elapsed;
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }

  void _recordOperation(AuthOperationType operationType) {
    _lastOperationTime[operationType] = DateTime.now();
  }

  void _clearOperationHistory() {
    _lastOperationTime.clear();
    _lastEmailVerificationSent = null;
    _lastPasswordResetSent = null;
    _pendingVerificationEmail = null;
    _pendingVerificationPassword = null;
  }

  void _startLoadingWithTimeout() {
    _updateState(isLoading: true);

    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(_loadingTimeout, () {
      if (_isLoading) {
        _logWarning('Loading timeout - forcing stop');
        _updateState(
          isLoading: false,
          errorMessage: 'انتهت مهلة العملية',
          errorType: AuthErrorType.timeout,
        );
      }
    });
  }

  void _stopLoading() {
    _loadingTimeoutTimer?.cancel();
    _updateState(isLoading: false);
  }

  void _updateState({
    bool? isLoading,
    String? errorMessage,
    AuthErrorType? errorType,
    bool clearError = false,
  }) {
    bool stateChanged = false;

    if (isLoading != null && _isLoading != isLoading) {
      _isLoading = isLoading;
      stateChanged = true;
    }

    if (clearError) {
      if (_errorMessage != null || _errorType != null) {
        _errorMessage = null;
        _errorType = null;
        stateChanged = true;
      }
    } else {
      if (errorMessage != null && _errorMessage != errorMessage) {
        _errorMessage = errorMessage;
        stateChanged = true;
      }

      if (errorType != null && _errorType != errorType) {
        _errorType = errorType;
        stateChanged = true;
      }
    }

    if (stateChanged) {
      notifyListeners();
    }
  }

  void _clearError() {
    _updateState(clearError: true);
  }

  void clearError() {
    _clearError();
  }

  void setUser(UserModel user) {
    _user = user;
    _log('User set manually');
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _firebaseUser = null;
    _lastLoginResult = null;
    _authService.clearCache();
    _log('User cleared manually');
    notifyListeners();
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ AuthProvider: $message');
    }
  }

  void _logWarning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ AuthProvider: $message');
    }
  }

  void _logError(String message, Object? error) {
    if (kDebugMode) {
      debugPrint('❌ AuthProvider: $message');
      if (error != null) {
        debugPrint('   Error: $error');
      }
    }
  }

  void _cleanupResources() {
    _authStateSubscription?.cancel();
    _loadingTimeoutTimer?.cancel();
    _user = null;
    _firebaseUser = null;
    _previousUserState = null;
    _lastLoginResult = null;
    _clearOperationHistory();
  }

  @override
  void dispose() {
    _log('Disposing AuthProvider...');
    _cleanupResources();
    super.dispose();
  }
}

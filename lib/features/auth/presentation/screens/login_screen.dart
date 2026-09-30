import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/services/credentials_manager.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/auth/auth_security_service.dart';
import '../widgets/dialogs/auth_dialogs.dart';
import '../widgets/login/login_form.dart';
import '../widgets/login/login_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ═══════════════════════════════════════════════════════════════════════════
  // 🔐 LOGIN SCREEN - Enterprise Grade Implementation
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // Uses CredentialsManager for centralized credential management.
  // This ensures consistent behavior across login/logout flows.
  //
  // ═══════════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════
  // 📊 STATE
  // ═══════════════════════════════════════════════════════════════
  
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _biometricAvailable = false;
  bool _hasSavedCredentials = false;
  bool _isInitialized = false;
  String? _savedEmail;
  String? _savedPassword;

  // ═══════════════════════════════════════════════════════════════
  // 🛠️ SERVICES
  // ═══════════════════════════════════════════════════════════════
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  /// Centralized credentials manager (replaces direct SharedPreferences/SecureStorage)
  CredentialsManager get _credentialsManager => CredentialsManager.instance;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeAuth();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  Future<void> _initializeAuth() async {
    final authService = AuthService();
    
    // Execute initialization tasks concurrently for faster startup (O(max(t1,t2,t3)) instead of O(t1+t2+t3))
    await Future.wait([
      authService.validateSessionOnStartup(),
      _checkBiometricAvailability(),
      _loadSavedCredentials(),
    ]);

    if (mounted) {
      setState(() => _isInitialized = true);
    }
    if (_hasSavedCredentials && _biometricAvailable && _rememberMe) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _showBiometricLoginDialog();
      }
    } else if (_hasSavedCredentials && _rememberMe && !_biometricAvailable) {
      await _attemptAutoLogin();
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (mounted) {
        setState(() {
          _biometricAvailable = canAuthenticate && isDeviceSupported;
        });
      }
    } catch (e) {
      debugPrint('Error checking biometric: $e');
      if (mounted) {
        setState(() => _biometricAvailable = false);
      }
    }
  }

  Future<void> _loadSavedCredentials() async {
    try {
      // Initialize credentials manager
      await _credentialsManager.initialize();
      
      // Load credentials using centralized manager
      final credentials = await _credentialsManager.loadCredentials();
      
      if (!mounted) return;
      
      if (credentials.isValid) {
        setState(() {
          _savedEmail = credentials.email;
          _savedPassword = credentials.password;
          _rememberMe = credentials.rememberMe;
          _hasSavedCredentials = true;
        });
        debugPrint('🔐 Credentials loaded: ${credentials.email}');
      } else {
        // Try to get last login email for convenience (even if no saved password)
        final lastEmail = await _credentialsManager.getLastLoginEmail();
        if (lastEmail != null && mounted) {
          setState(() {
            _savedEmail = lastEmail;
            _rememberMe = false;
            _hasSavedCredentials = false;
          });
        }
        debugPrint('🔐 No valid saved credentials found');
      }
    } catch (e) {
      debugPrint('❌ Error loading saved credentials: $e');
    }
  }

  Future<void> _attemptAutoLogin() async {
    if (!_rememberMe || !_hasSavedCredentials) return;
    try {
      if (_savedPassword != null && _savedPassword!.isNotEmpty && _savedEmail != null) {
        await _handleLogin(_savedEmail!, _savedPassword!);
      }
    } catch (e) {
      debugPrint('Auto-login error: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authService = AuthService();
      
      final isLocked = await authService.isAccountLocked(email);
      if (isLocked) {
        final lockoutMinutes = await authService.getRemainingLockoutTime(email);
        if (mounted) {
          await AuthDialogs.showLockoutDialog(
            context: context,
            isPermanent: false,
            remainingMinutes: lockoutMinutes,
            message: 'تم تجاوز عدد المحاولات المسموحة.',
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final result = await authProvider.loginWithResult(
        email: email,
        password: password,
      );

      debugPrint('🔔 Login result type: ${result.runtimeType}');
      debugPrint('🔔 Mounted status: $mounted');
      
      if (result is LoginEmailNotVerified) {
        debugPrint('📧 LoginEmailNotVerified - navigating to verification screen');
        if (mounted) {
          setState(() => _isLoading = false);
          context.go(
            '/email-verification',
            extra: {
              'email': result.email,
              'password': password,
              'verificationEmailSent': result.verificationEmailSent,
            },
          );
        }
        return;
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      
      if (result is LoginSuccess) {
        debugPrint('✅ LoginSuccess branch');
        await authService.resetFailedAttempts(email);
        await _saveCredentials(email, password);
        // Save session for startup validation (fixes logout on real devices)
        await AuthSecurityService().saveLoginSession(rememberMe: _rememberMe);
        await authService.logLoginActivity(email: email, success: true);
        
        _showSuccessSnackBar('مرحباً ${result.user.name}! 🎉');
        
        if (mounted) {
          context.go('/home');
        }
      } else if (result is LoginFailed) {
        debugPrint('❌ LoginFailed branch');
        final failure = result.failure;
        await authService.incrementFailedAttempts(email);
        await authService.logLoginActivity(
          email: email,
          success: false,
          reason: failure.userMessage,
        );
        
        final failedCount = await authService.getFailedAttemptsCount(email);
        
        if (failedCount >= 5) {
          if (mounted) {
            await AuthDialogs.showLockoutDialog(
              context: context,
              isPermanent: false,
              remainingMinutes: 30,
              message: 'تم إيقاف تسجيل الدخول مؤقتاً لحماية حسابك.',
            );
          }
        } else {
          final remainingAttempts = 5 - failedCount;
          if (mounted) {
            await AuthDialogs.showFailedLoginDialog(
              context: context,
              errorMessage: failure.userMessage,
              remainingAttempts: remainingAttempts,
              showWarning: remainingAttempts <= 3,
              onForgotPassword: _handleForgotPassword,
            );
          }
        }
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await AuthDialogs.showErrorDialog(
        context: context,
        title: 'انتهى وقت الاتصال',
        message: 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى.',
      );
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      await AuthDialogs.showErrorDialog(
        context: context,
        title: 'خطأ غير متوقع',
        message: 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى لاحقاً.',
      );
    }
  }

  Future<void> _showBiometricLoginDialog() async {
    final result = await AuthDialogs.showBiometricPromptDialog(context: context);
    if (result == true && mounted) {
      await _handleBiometricLogin();
    }
  }

  Future<void> _handleBiometricLogin() async {
    try {
      setState(() => _isLoading = true);
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'الرجاء المصادقة لتسجيل الدخول',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (!authenticated) {
        setState(() => _isLoading = false);
        return;
      }
      if (_savedPassword != null && _savedPassword!.isNotEmpty && _savedEmail != null) {
        await _handleLogin(_savedEmail!, _savedPassword!);
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar('لم يتم العثور على كلمة المرور المحفوظة');
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('فشلت المصادقة البيومترية');
      }
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    try {
      final result = await _credentialsManager.saveCredentials(
        email: email,
        password: password,
        rememberMe: _rememberMe,
      );
      
      if (result.success) {
        debugPrint('🔐 Credentials saved successfully');
      } else {
        debugPrint('⚠️ Failed to save credentials: ${result.errorMessage}');
      }
    } catch (e) {
      debugPrint('❌ Error saving credentials: $e');
    }
  }

  Future<void> _clearCredentials() async {
    try {
      final result = await _credentialsManager.clearAll();
      
      if (result.success) {
        debugPrint('🧹 Credentials cleared successfully');
      } else {
        debugPrint('⚠️ Failed to clear credentials: ${result.errorMessage}');
      }
    } catch (e) {
      debugPrint('❌ Error clearing credentials: $e');
    }
  }

  void _handleRememberMeChanged(bool value) {
    setState(() => _rememberMe = value);
    
    // If user disables remember me, clear saved credentials immediately
    if (!value) {
      _clearCredentials();
      
      // Also clear local state
      setState(() {
        _savedPassword = null;
        _hasSavedCredentials = false;
      });
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = await AuthDialogs.showForgotPasswordDialog(
      context: context,
      initialEmail: _savedEmail,
    );

    if (email == null || email.isEmpty || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.sendPasswordResetEmail(email).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('انتهى وقت الاتصال');
        },
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      await AuthDialogs.showPasswordResetSuccessDialog(
        context: context,
        email: email,
      );
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await AuthDialogs.showErrorDialog(
        context: context,
        title: 'انتهت مهلة الاتصال',
        message: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
      );
    } catch (e) {
      debugPrint('Password reset error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      await AuthDialogs.showErrorDialog(
        context: context,
        title: 'حدث خطأ',
        message: _getPasswordResetErrorMessage(e),
      );
    }
  }

  String _getPasswordResetErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
    }
    if (errorString.contains('user-not-found') || errorString.contains('invalid-email')) {
      return 'لم يتم العثور على حساب بهذا البريد الإلكتروني';
    }
    if (errorString.contains('too-many-requests')) {
      return 'تم إرسال عدد كبير من الطلبات. يرجى المحاولة لاحقاً';
    }
    return 'فشل إرسال رابط استعادة كلمة المرور. حاول مرة أخرى.';
  }

  void _navigateToRegister() {
    context.push('/register');
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: !_isInitialized
                ? InitializingScreen(
                    key: const ValueKey('initializing'),
                    biometricAvailable: _biometricAvailable,
                    hasSavedCredentials: _hasSavedCredentials,
                  )
                : _buildMainContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      key: const ValueKey('main_content'),
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/images/medical_pattern.png',
              repeat: ImageRepeat.repeat,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
        ),
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const LoginHeader(),
                    const SizedBox(height: 40),
                    LoginForm(
                      onLogin: _handleLogin,
                      onForgotPassword: _handleForgotPassword,
                      onCreateAccount: _navigateToRegister,
                      onBiometricLogin: _handleBiometricLogin,
                      onRememberMeChanged: _handleRememberMeChanged,
                      initialEmail: _savedEmail,
                      initialRememberMe: _rememberMe,
                      biometricAvailable: _biometricAvailable,
                      hasSavedCredentials: _hasSavedCredentials,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'جاري تسجيل الدخول...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

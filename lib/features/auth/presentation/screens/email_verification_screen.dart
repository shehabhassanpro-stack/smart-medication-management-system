import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/auth_service.dart';
import '../widgets/verification/animated_envelope.dart';
import '../widgets/verification/verification_instructions.dart';
import '../widgets/verification/verification_actions.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String? password;
  final bool verificationEmailSent;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.password,
    this.verificationEmailSent = false,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {

  final AuthService _authService = AuthService();

  late AnimationController _envelopeController;
  late AnimationController _pulseController;
  late AnimationController _checkController;
  late AnimationController _particleController;
  late AnimationController _successController;

  late Animation<double> _envelopeFloat;
  late Animation<double> _envelopeRotate;
  late Animation<double> _pulseAnimation;
  late Animation<double> _checkScale;
  late Animation<double> _successScale;

  Timer? _countdownTimer;

  int _resendCountdown = 0;
  bool _isResending = false;
  bool _isVerified = false;
  bool _isCheckingVerification = false;
  String? _errorMessage;

  static const int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    if (widget.verificationEmailSent) {
      _startResendCountdown();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('تم إرسال رسالة التفعيل بنجاح')),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _envelopeController.dispose();
    _pulseController.dispose();
    _checkController.dispose();
    _particleController.dispose();
    _successController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _setupAnimations() {
    _envelopeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _envelopeFloat = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _envelopeController, curve: Curves.easeInOut),
    );

    _envelopeRotate = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _envelopeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = _resendCooldown);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    if (_isVerified || _isCheckingVerification) return;
    if (widget.password == null) return;

    setState(() => _isCheckingVerification = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: widget.password!,
      );

      final user = userCredential.user;
      if (user != null) {
        await user.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;

        if (refreshedUser?.emailVerified == true) {
          setState(() => _isVerified = true);

          _checkController.forward();
          await Future.delayed(const Duration(milliseconds: 400));
          _successController.forward();

          HapticFeedback.heavyImpact();

          await FirebaseAuth.instance.signOut();

          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            authProvider.clearPendingVerification();
            context.go('/login');
          }
        } else {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            _showInfoSnackBar('البريد لم يتم تفعيله بعد');
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking verification: $e');
      if (mounted) {
        setState(() => _errorMessage = 'تعذر التحقق. حاول مرة أخرى.');
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingVerification = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    try {
      if (widget.password != null) {
        await _authService.resendVerificationEmail(
          email: widget.email,
          password: widget.password!,
        );
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.sendEmailVerification();
        }
      }

      if (mounted) {
        _startResendCountdown();
        _showSuccessSnackBar('تم إرسال رسالة التفعيل بنجاح');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'فشل إرسال الرسالة. حاول مرة أخرى.');
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openEmailApp() {
    HapticFeedback.lightImpact();
    _showEmailAppsBottomSheet();
  }

  void _showEmailAppsBottomSheet() {
    final tokens = context.tokens;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: tokens.paddingAllLarge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: tokens.borderRadiusTopXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: tokens.spacingLG),
            Text(
              'افتح تطبيق البريد',
              style: TextStyle(
                fontSize: tokens.fontTitle,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: tokens.spacingMD),
            Text(
              'اختر تطبيق البريد للتحقق من رسالة التفعيل',
              style: TextStyle(
                fontSize: tokens.fontBody,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spacingXL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEmailAppButton(
                  tokens: tokens,
                  icon: Icons.mail_rounded,
                  label: 'Gmail',
                  color: const Color(0xFFEA4335),
                  onTap: () => Navigator.pop(context),
                ),
                _buildEmailAppButton(
                  tokens: tokens,
                  icon: Icons.mail_outline_rounded,
                  label: 'Outlook',
                  color: const Color(0xFF0078D4),
                  onTap: () => Navigator.pop(context),
                ),
                _buildEmailAppButton(
                  tokens: tokens,
                  icon: Icons.email_rounded,
                  label: 'البريد',
                  color: AppColors.primary,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: tokens.spacingXL + tokens.responsive.safeAreaBottom),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailAppButton({
    required DesignTokens tokens,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: tokens.responsive.scale(64),
            height: tokens.responsive.scale(64),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: tokens.borderRadiusLG,
            ),
            child: Icon(icon, color: color, size: tokens.iconLarge),
          ),
          SizedBox(height: tokens.spacingSM),
          Text(
            label,
            style: TextStyle(
              fontSize: tokens.fontSmall,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _goToLogin() {
    HapticFeedback.lightImpact();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearPendingVerification();

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.background,
              AppColors.background,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: tokens.paddingAllLarge,
              child: Column(
                children: [
                  SizedBox(height: tokens.spacingXL),
                  AnimatedEnvelope(
                    envelopeController: _envelopeController,
                    pulseController: _pulseController,
                    particleController: _particleController,
                    successController: _successController,
                    checkController: _checkController,
                    envelopeFloat: _envelopeFloat,
                    envelopeRotate: _envelopeRotate,
                    pulseAnimation: _pulseAnimation,
                    checkScale: _checkScale,
                    successScale: _successScale,
                    isVerified: _isVerified,
                  ),
                  SizedBox(height: tokens.spacing2XL),
                  _buildHeaderText(tokens),
                  SizedBox(height: tokens.spacingLG),
                  _buildEmailCard(tokens),
                  SizedBox(height: tokens.spacing2XL),
                  VerificationInstructions(tokens: tokens),
                  SizedBox(height: tokens.spacingXL),
                  VerificationActions(
                    tokens: tokens,
                    isVerified: _isVerified,
                    isCheckingVerification: _isCheckingVerification,
                    isResending: _isResending,
                    resendCountdown: _resendCountdown,
                    errorMessage: _errorMessage,
                    onOpenEmailApp: _openEmailApp,
                    onCheckVerification: _checkEmailVerification,
                    onResendEmail: _resendVerificationEmail,
                    onGoToLogin: _goToLogin,
                  ),
                  SizedBox(height: tokens.spacing2XL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(DesignTokens tokens) {
    return Column(
      children: [
        Text(
          _isVerified ? 'تم التفعيل بنجاح! 🎉' : 'تفعيل البريد الإلكتروني',
          style: TextStyle(
            fontSize: tokens.fontHeadline,
            fontWeight: FontWeight.bold,
            color: _isVerified ? AppColors.success : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.spacingSM),
        Text(
          _isVerified
              ? 'جاري تحويلك لتسجيل الدخول...'
              : 'أرسلنا رسالة تفعيل إلى بريدك الإلكتروني',
          style: TextStyle(
            fontSize: tokens.fontBody,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailCard(DesignTokens tokens) {
    return Container(
      padding: tokens.paddingAllMedium,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(tokens.paddingXS),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: tokens.borderRadiusSM,
            ),
            child: Icon(
              Icons.alternate_email_rounded,
              color: AppColors.primary,
              size: tokens.iconSmall,
            ),
          ),
          SizedBox(width: tokens.spacingSM),
          Flexible(
            child: Text(
              widget.email,
              style: TextStyle(
                fontSize: tokens.fontBody,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
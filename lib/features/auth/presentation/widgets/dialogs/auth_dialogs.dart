import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/design_tokens.dart';

class AuthDialogs {
  AuthDialogs._();

  static Future<void> showLockoutDialog({
    required BuildContext context,
    required bool isPermanent,
    required int remainingMinutes,
    required String message,
    VoidCallback? onContactSupport,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _LockoutDialog(
        isPermanent: isPermanent,
        remainingMinutes: remainingMinutes,
        message: message,
        onContactSupport: onContactSupport,
      ),
    );
  }

  static Future<void> showFailedLoginDialog({
    required BuildContext context,
    required String errorMessage,
    int? remainingAttempts,
    bool showWarning = false,
    VoidCallback? onForgotPassword,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _FailedLoginDialog(
        errorMessage: errorMessage,
        remainingAttempts: remainingAttempts,
        showWarning: showWarning,
        onForgotPassword: onForgotPassword,
      ),
    );
  }

  static Future<void> showEmailVerificationDialog({
    required BuildContext context,
    required String email,
    bool emailSent = true,
    VoidCallback? onResendEmail,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EmailVerificationDialog(
        email: email,
        emailSent: emailSent,
        onResendEmail: onResendEmail,
        onDismiss: onDismiss,
      ),
    );
  }

  static Future<bool?> showBiometricPromptDialog({
    required BuildContext context,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _BiometricPromptDialog(),
    );
  }

  static Future<String?> showForgotPasswordDialog({
    required BuildContext context,
    String? initialEmail,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ForgotPasswordDialog(
        initialEmail: initialEmail,
      ),
    );
  }

  static Future<void> showPasswordResetSuccessDialog({
    required BuildContext context,
    required String email,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _PasswordResetSuccessDialog(email: email),
    );
  }

  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'حسناً',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ErrorDialog(
        title: title,
        message: message,
        buttonText: buttonText,
      ),
    );
  }
}

class _LockoutDialog extends StatelessWidget {
  final bool isPermanent;
  final int remainingMinutes;
  final String message;
  final VoidCallback? onContactSupport;

  const _LockoutDialog({
    required this.isPermanent,
    required this.remainingMinutes,
    required this.message,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);
    final color = isPermanent ? AppColors.error : AppColors.warning;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: tokens.borderRadiusXL,
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        constraints: BoxConstraints(
          maxWidth: tokens.byDevice(mobile: 320.0, tablet: 400.0, desktop: 450.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: tokens.paddingAllLG,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(tokens.radiusXL),
                  topRight: Radius.circular(tokens.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(tokens.paddingMD),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPermanent ? Icons.lock_rounded : Icons.timer_rounded,
                      color: color,
                      size: tokens.iconXL,
                    ),
                  ),
                  SizedBox(height: tokens.spacingMD),
                  Text(
                    isPermanent ? 'الحساب مقفل' : 'الحساب مقفل مؤقتاً',
                    style: TextStyle(
                      fontSize: tokens.fontTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: tokens.paddingAllLG,
              child: Column(
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: tokens.fontBody,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isPermanent) ...[
                    SizedBox(height: tokens.spacingLG),
                    _buildCountdownIndicator(context, tokens),
                  ],
                  SizedBox(height: tokens.spacingLG),
                  _buildInfoCard(context, tokens),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.paddingLG,
                0,
                tokens.paddingLG,
                tokens.paddingLG,
              ),
              child: Row(
                children: [
                  if (isPermanent && onContactSupport != null) ...[
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onContactSupport?.call();
                        },
                        icon: Icon(Icons.support_agent_rounded, size: tokens.iconSM),
                        label: Text(
                          'تواصل مع الدعم',
                          style: TextStyle(fontSize: tokens.fontBody),
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spacingMD),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: tokens.paddingMD),
                        shape: RoundedRectangleBorder(
                          borderRadius: tokens.borderRadiusMD,
                        ),
                      ),
                      child: Text(
                        'حسناً',
                        style: TextStyle(
                          fontSize: tokens.fontBody,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownIndicator(BuildContext context, DesignTokens tokens) {
    final progress = remainingMinutes > 0 ? (30 - remainingMinutes) / 30 : 1.0;
    final progressColor = _getProgressColor(remainingMinutes);

    return Container(
      padding: tokens.paddingAllMD,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: tokens.borderRadiusMD,
      ),
      child: Row(
        children: [
          SizedBox(
            width: tokens.avatarSM,
            height: tokens.avatarSM,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 4,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
                Text(
                  '$remainingMinutes',
                  style: TextStyle(
                    fontSize: tokens.fontBody,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: tokens.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الوقت المتبقي',
                  style: TextStyle(
                    fontSize: tokens.fontSmall,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  _formatTime(remainingMinutes),
                  style: TextStyle(
                    fontSize: tokens.fontLG,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, DesignTokens tokens) {
    return Container(
      padding: tokens.paddingAllMD,
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.info,
            size: tokens.iconSM,
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: Text(
              isPermanent
                  ? 'تم قفل الحساب لأسباب أمنية بعد عدة محاولات فاشلة.'
                  : 'هذا الإجراء لحماية حسابك من المحاولات غير المصرح بها.',
              style: TextStyle(
                fontSize: tokens.fontSmall,
                color: AppColors.info,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int minutes) {
    if (minutes > 20) return AppColors.error;
    if (minutes > 10) return AppColors.warning;
    if (minutes > 5) return Colors.amber;
    return AppColors.success;
  }

  String _formatTime(int minutes) {
    if (minutes <= 1) return 'أقل من دقيقة';
    if (minutes < 60) return '$minutes دقيقة';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours ساعة';
    return '$hours ساعة و $mins دقيقة';
  }
}

class _FailedLoginDialog extends StatelessWidget {
  final String errorMessage;
  final int? remainingAttempts;
  final bool showWarning;
  final VoidCallback? onForgotPassword;

  const _FailedLoginDialog({
    required this.errorMessage,
    this.remainingAttempts,
    this.showWarning = false,
    this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: tokens.borderRadiusXL,
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(tokens.paddingSM),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: tokens.borderRadiusMD,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: tokens.iconLG,
            ),
          ),
          SizedBox(width: tokens.spacingMD),
          Expanded(
            child: Text(
              'فشل تسجيل الدخول',
              style: TextStyle(
                fontSize: tokens.fontTitle,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: tokens.fontBody,
              color: AppColors.textSecondary,
            ),
          ),
          if (showWarning && remainingAttempts != null) ...[
            SizedBox(height: tokens.spacingLG),
            _buildWarningCard(context, tokens),
          ],
        ],
      ),
      actions: [
        if (onForgotPassword != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onForgotPassword?.call();
            },
            child: Text(
              'نسيت كلمة المرور؟',
              style: TextStyle(
                fontSize: tokens.fontBody,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: tokens.borderRadiusMD,
            ),
          ),
          child: Text(
            'حاول مرة أخرى',
            style: TextStyle(
              fontSize: tokens.fontBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningCard(BuildContext context, DesignTokens tokens) {
    final isUrgent = remainingAttempts != null && remainingAttempts! <= 2;
    final color = isUrgent ? AppColors.error : AppColors.warning;

    return Container(
      padding: tokens.paddingAllMD,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: color,
            size: tokens.iconMD,
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUrgent ? 'تحذير هام!' : 'تنبيه',
                  style: TextStyle(
                    fontSize: tokens.fontSmall,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: tokens.spacing2XS),
                Text(
                  remainingAttempts == 1
                      ? 'محاولة واحدة متبقية قبل قفل الحساب مؤقتاً!'
                      : '$remainingAttempts محاولات متبقية قبل قفل الحساب مؤقتاً',
                  style: TextStyle(
                    fontSize: tokens.fontSmall,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailVerificationDialog extends StatelessWidget {
  final String email;
  final bool emailSent;
  final VoidCallback? onResendEmail;
  final VoidCallback? onDismiss;

  const _EmailVerificationDialog({
    required this.email,
    this.emailSent = true,
    this.onResendEmail,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: tokens.borderRadiusXL,
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(tokens.paddingSM),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: tokens.borderRadiusMD,
            ),
            child: Icon(
              Icons.mark_email_unread_rounded,
              color: AppColors.warning,
              size: tokens.iconLG,
            ),
          ),
          SizedBox(width: tokens.spacingMD),
          Expanded(
            child: Text(
              'الحساب غير مفعّل',
              style: TextStyle(
                fontSize: tokens.fontTitle,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حسابك غير مفعّل بعد.',
            style: TextStyle(
              fontSize: tokens.fontBody,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spacingSM),
          Text(
            emailSent
                ? 'تم إرسال رسالة تفعيل جديدة إلى:\n$email'
                : 'يرجى التحقق من بريدك الإلكتروني:\n$email',
            style: TextStyle(
              fontSize: tokens.fontBody,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacingLG),
          Container(
            padding: tokens.paddingAllMD,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: tokens.borderRadiusMD,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                  size: tokens.iconSM,
                ),
                SizedBox(width: tokens.spacingSM),
                Expanded(
                  child: Text(
                    'تحقق من صندوق الوارد أو مجلد الرسائل غير المرغوبة (Spam)',
                    style: TextStyle(
                      fontSize: tokens.fontSmall,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (onResendEmail != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onResendEmail?.call();
            },
            child: Text(
              'إعادة الإرسال',
              style: TextStyle(fontSize: tokens.fontBody),
            ),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: tokens.borderRadiusMD,
            ),
          ),
          child: Text(
            'حسناً',
            style: TextStyle(
              fontSize: tokens.fontBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BiometricPromptDialog extends StatelessWidget {
  const _BiometricPromptDialog();

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: tokens.borderRadiusXL,
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(tokens.paddingSM),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: tokens.borderRadiusMD,
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              color: AppColors.primary,
              size: tokens.iconLG,
            ),
          ),
          SizedBox(width: tokens.spacingMD),
          Text(
            'تسجيل دخول سريع',
            style: TextStyle(
              fontSize: tokens.fontTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        'هل تريد تسجيل الدخول باستخدام البصمة أو التعرف على الوجه؟',
        style: TextStyle(
          fontSize: tokens.fontBody,
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'لاحقاً',
            style: TextStyle(
              fontSize: tokens.fontBody,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: tokens.borderRadiusMD,
            ),
          ),
          child: Text(
            'نعم',
            style: TextStyle(
              fontSize: tokens.fontBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final String? initialEmail;

  const _ForgotPasswordDialog({this.initialEmail});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: tokens.borderRadiusXL,
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        constraints: BoxConstraints(
          maxWidth: tokens.byDevice(mobile: 320.0, tablet: 400.0, desktop: 450.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: tokens.paddingAllLG,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(tokens.radiusXL),
                  topRight: Radius.circular(tokens.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(tokens.paddingLG),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.primary,
                      size: tokens.icon2XL,
                    ),
                  ),
                  SizedBox(height: tokens.spacingMD),
                  Text(
                    'استعادة كلمة المرور',
                    style: TextStyle(
                      fontSize: tokens.fontTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: tokens.spacingXS),
                  Text(
                    'أدخل بريدك الإلكتروني لإرسال رابط الاستعادة',
                    style: TextStyle(
                      fontSize: tokens.fontBody,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: tokens.paddingAllLG,
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontSize: tokens.fontBody),
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    hintText: 'example@email.com',
                    hintTextDirection: TextDirection.ltr,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.primary,
                      size: tokens.iconSM,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: tokens.borderRadiusMD,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: tokens.borderRadiusMD,
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'البريد الإلكتروني غير صحيح';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.paddingLG,
                0,
                tokens.paddingLG,
                tokens.paddingLG,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: tokens.paddingMD),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: tokens.fontBody,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.spacingMD),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context, _emailController.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: tokens.paddingMD),
                        shape: RoundedRectangleBorder(
                          borderRadius: tokens.borderRadiusMD,
                        ),
                      ),
                      child: Text(
                        'إرسال رابط الاستعادة',
                        style: TextStyle(
                          fontSize: tokens.fontBody,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordResetSuccessDialog extends StatelessWidget {
  final String email;

  const _PasswordResetSuccessDialog({required this.email});

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: tokens.borderRadiusXL,
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        constraints: BoxConstraints(
          maxWidth: tokens.byDevice(mobile: 320.0, tablet: 400.0, desktop: 450.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: tokens.paddingAllXL,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(tokens.radiusXL),
                  topRight: Radius.circular(tokens.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(tokens.paddingLG),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: tokens.icon2XL,
                    ),
                  ),
                  SizedBox(height: tokens.spacingMD),
                  Text(
                    'تم الإرسال بنجاح!',
                    style: TextStyle(
                      fontSize: tokens.fontTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: tokens.paddingAllLG,
              child: Column(
                children: [
                  Text(
                    'تم إرسال رابط استعادة كلمة المرور إلى:',
                    style: TextStyle(
                      fontSize: tokens.fontBody,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.spacingSM),
                  Container(
                    padding: tokens.paddingAllMD,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: tokens.borderRadiusMD,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                          size: tokens.iconSM,
                        ),
                        SizedBox(width: tokens.spacingSM),
                        Flexible(
                          child: Text(
                            email,
                            style: TextStyle(
                              fontSize: tokens.fontBody,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.spacingLG),
                  Text(
                    'تحقق من صندوق الوارد واتبع التعليمات لإعادة تعيين كلمة المرور.',
                    style: TextStyle(
                      fontSize: tokens.fontSmall,
                      color: AppColors.textTertiary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.paddingLG,
                0,
                tokens.paddingLG,
                tokens.paddingLG,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: tokens.paddingMD),
                    shape: RoundedRectangleBorder(
                      borderRadius: tokens.borderRadiusMD,
                    ),
                  ),
                  child: Text(
                    'حسناً',
                    style: TextStyle(
                      fontSize: tokens.fontBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;

  const _ErrorDialog({
    required this.title,
    required this.message,
    this.buttonText = 'حسناً',
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: tokens.borderRadiusXL,
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(tokens.paddingSM),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: tokens.borderRadiusMD,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: tokens.iconLG,
            ),
          ),
          SizedBox(width: tokens.spacingMD),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: tokens.fontTitle,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: tokens.fontBody,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: tokens.borderRadiusMD,
            ),
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: tokens.fontBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

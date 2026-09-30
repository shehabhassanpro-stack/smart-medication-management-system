import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/design_tokens.dart';

class VerificationActions extends StatelessWidget {
  final DesignTokens tokens;
  final bool isVerified;
  final bool isCheckingVerification;
  final bool isResending;
  final int resendCountdown;
  final String? errorMessage;
  final VoidCallback onOpenEmailApp;
  final VoidCallback onCheckVerification;
  final VoidCallback onResendEmail;
  final VoidCallback onGoToLogin;

  const VerificationActions({
    super.key,
    required this.tokens,
    required this.isVerified,
    required this.isCheckingVerification,
    required this.isResending,
    required this.resendCountdown,
    required this.errorMessage,
    required this.onOpenEmailApp,
    required this.onCheckVerification,
    required this.onResendEmail,
    required this.onGoToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildActionButtons(),
        SizedBox(height: tokens.spacingLG),
        _buildResendSection(),
        if (errorMessage != null) ...[
          SizedBox(height: tokens.spacingMD),
          _buildErrorMessage(),
        ],
        SizedBox(height: tokens.spacingXL),
        _buildBackToLogin(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: tokens.buttonHeightLG,
          child: ElevatedButton.icon(
            onPressed: isVerified ? null : onOpenEmailApp,
            icon: Icon(Icons.open_in_new_rounded, size: tokens.iconSmall),
            label: const Text('فتح تطبيق البريد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: tokens.borderRadiusMD,
              ),
              textStyle: TextStyle(
                fontSize: tokens.fontBody,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.spacingMD),
        SizedBox(
          width: double.infinity,
          height: tokens.buttonHeightLG,
          child: OutlinedButton.icon(
            onPressed: isCheckingVerification || isVerified
                ? null
                : onCheckVerification,
            icon: isCheckingVerification
                ? SizedBox(
                    width: tokens.iconSmall,
                    height: tokens.iconSmall,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  )
                : Icon(Icons.refresh_rounded, size: tokens.iconSmall),
            label: Text(isCheckingVerification ? 'جاري التحقق...' : 'تحقق من التفعيل'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: tokens.borderRadiusMD,
              ),
              textStyle: TextStyle(
                fontSize: tokens.fontBody,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    return Container(
      padding: tokens.paddingAllMedium,
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.info,
            size: tokens.iconSmall,
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: Text(
              'لم تصلك الرسالة؟',
              style: TextStyle(
                fontSize: tokens.fontSmall,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          isResending
              ? SizedBox(
                  width: tokens.iconSmall,
                  height: tokens.iconSmall,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                )
              : TextButton(
                  onPressed: resendCountdown > 0 ? null : onResendEmail,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: tokens.paddingSM),
                  ),
                  child: Text(
                    resendCountdown > 0
                        ? 'إعادة الإرسال ($resendCountdown)'
                        : 'إعادة الإرسال',
                    style: TextStyle(
                      fontSize: tokens.fontSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: tokens.paddingAllMedium,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: tokens.iconSmall,
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(
                fontSize: tokens.fontSmall,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToLogin() {
    return TextButton.icon(
      onPressed: onGoToLogin,
      icon: Icon(Icons.arrow_back_rounded, size: tokens.iconSmall),
      label: const Text('العودة لتسجيل الدخول'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        textStyle: TextStyle(
          fontSize: tokens.fontBody,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

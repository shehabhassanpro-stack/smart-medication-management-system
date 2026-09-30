import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/design_tokens.dart';

class VerificationInstructions extends StatelessWidget {
  final DesignTokens tokens;

  const VerificationInstructions({
    super.key,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: tokens.paddingAllLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: tokens.borderRadiusLG,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInstructionStep(
            number: '1',
            title: 'افتح بريدك الإلكتروني',
            subtitle: 'تحقق من صندوق الوارد',
            icon: Icons.inbox_rounded,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.spacingSM),
            child: _buildDottedLine(),
          ),
          _buildInstructionStep(
            number: '2',
            title: 'ابحث عن رسالتنا',
            subtitle: 'قد تكون في البريد غير المرغوب',
            icon: Icons.search_rounded,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.spacingSM),
            child: _buildDottedLine(),
          ),
          _buildInstructionStep(
            number: '3',
            title: 'اضغط على رابط التفعيل',
            subtitle: 'سيتم تفعيل حسابك تلقائياً',
            icon: Icons.touch_app_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: tokens.responsive.scale(44),
          height: tokens.responsive.scale(44),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: tokens.borderRadiusMD,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: tokens.fontTitle,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: tokens.spacingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: tokens.fontBody,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: tokens.spacing2XS),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: tokens.fontSmall,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Icon(
          icon,
          color: AppColors.primary.withValues(alpha: 0.5),
          size: tokens.iconMedium,
        ),
      ],
    );
  }

  Widget _buildDottedLine() {
    return Row(
      children: [
        SizedBox(width: tokens.responsive.scale(22)),
        Container(
          width: 2,
          height: tokens.responsive.scale(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

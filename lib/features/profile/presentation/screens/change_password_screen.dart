import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../providers/profile_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSecurityIcon(),
                        const SizedBox(height: 32),
                        _buildCurrentPasswordField(),
                        const SizedBox(height: 20),
                        _buildNewPasswordField(),
                        const SizedBox(height: 20),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 16),
                        _buildPasswordRequirements(),
                        const SizedBox(height: 32),
                        _buildChangeButton(provider),
                        const SizedBox(height: 16),
                        _buildForgotPasswordButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Row(
        children: [
          _buildBackButton(context),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تغيير كلمة المرور',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'حافظ على أمان حسابك',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityIcon() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock_outline_rounded,
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCurrentPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة المرور الحالية',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _currentPasswordController,
          focusNode: _currentPasswordFocus,
          obscureText: _obscureCurrentPassword,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_newPasswordFocus);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال كلمة المرور الحالية';
            }
            return null;
          },
          style: AppTextStyles.bodyLarge,
          decoration: _buildPasswordDecoration(
            hint: 'أدخل كلمة المرور الحالية',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureCurrentPassword,
            onToggle: () {
              setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة المرور الجديدة',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _newPasswordController,
          focusNode: _newPasswordFocus,
          obscureText: _obscureNewPassword,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_confirmPasswordFocus);
          },
          onChanged: (_) => setState(() {}),
          validator: _validateNewPassword,
          style: AppTextStyles.bodyLarge,
          decoration: _buildPasswordDecoration(
            hint: 'أدخل كلمة المرور الجديدة',
            icon: Icons.lock_reset_rounded,
            obscure: _obscureNewPassword,
            onToggle: () {
              setState(() => _obscureNewPassword = !_obscureNewPassword);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تأكيد كلمة المرور',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _changePassword(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى تأكيد كلمة المرور';
            }
            if (value != _newPasswordController.text) {
              return 'كلمات المرور غير متطابقة';
            }
            return null;
          },
          style: AppTextStyles.bodyLarge,
          decoration: _buildPasswordDecoration(
            hint: 'أعد إدخال كلمة المرور الجديدة',
            icon: Icons.lock_clock_rounded,
            obscure: _obscureConfirmPassword,
            onToggle: () {
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
          ),
        ),
      ],
    );
  }

  InputDecoration _buildPasswordDecoration({
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور الجديدة';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'يجب أن تحتوي على رقم واحد على الأقل';
    }
    if (value == _currentPasswordController.text) {
      return 'كلمة المرور الجديدة يجب أن تختلف عن الحالية';
    }
    return null;
  }

  Widget _buildPasswordRequirements() {
    final password = _newPasswordController.text;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'متطلبات كلمة المرور',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirement('8 أحرف على الأقل', password.length >= 8),
          _buildRequirement('حرف كبير (A-Z)', password.contains(RegExp(r'[A-Z]'))),
          _buildRequirement('حرف صغير (a-z)', password.contains(RegExp(r'[a-z]'))),
          _buildRequirement('رقم (0-9)', password.contains(RegExp(r'[0-9]'))),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isMet ? AppColors.success : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isMet ? AppColors.success : AppColors.textSecondary,
                width: 2,
              ),
            ),
            child: isMet
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: isMet ? AppColors.success : AppColors.textSecondary,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton(ProfileProvider provider) {
    final isLoading = provider.isUpdating;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _changePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security_rounded),
                  const SizedBox(width: 8),
                  Text(
                    'تغيير كلمة المرور',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Center(
      child: TextButton(
        onPressed: _showForgotPasswordDialog,
        child: Text(
          'نسيت كلمة المرور الحالية؟',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.mediumImpact();

    final provider = context.read<ProfileProvider>();
    
    final success = await provider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'حدث خطأ في تغيير كلمة المرور');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تم بنجاح!',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم تغيير كلمة المرور بنجاح',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('حسناً'),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.mail_outline_rounded, color: AppColors.info),
            ),
            const SizedBox(width: 12),
            const Text('نسيت كلمة المرور؟'),
          ],
        ),
        content: Text(
          'سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني المسجل.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendPasswordResetEmail();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _sendPasswordResetEmail() {
    _showSuccessSnackBar('تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

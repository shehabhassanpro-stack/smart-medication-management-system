import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

import '../../../../../core/app_theme.dart';

class LoginForm extends StatefulWidget {
  final Future<void> Function(String email, String password) onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;
  final VoidCallback? onBiometricLogin;
  final ValueChanged<bool> onRememberMeChanged;
  final String? initialEmail;
  final bool initialRememberMe;
  final bool biometricAvailable;
  final bool hasSavedCredentials;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onCreateAccount,
    required this.onRememberMeChanged,
    this.onBiometricLogin,
    this.initialEmail,
    this.initialRememberMe = false,
    this.biometricAvailable = false,
    this.hasSavedCredentials = false,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
    _rememberMe = widget.initialRememberMe;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    await widget.onLogin(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'مرحباً بعودتك!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildRememberMeRow(),
              const SizedBox(height: 24),
              _buildLoginButton(),
              if (widget.biometricAvailable && widget.hasSavedCredentials) ...[
                const SizedBox(height: 16),
                _buildBiometricButton(),
              ],
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildCreateAccountButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      enabled: !widget.isLoading,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني',
        hintText: 'example@email.com',
        hintTextDirection: TextDirection.ltr,
        prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال البريد الإلكتروني';
        }
        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
          return 'البريد الإلكتروني غير صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      enabled: !widget.isLoading,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryBlue),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppTheme.primaryBlue,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال كلمة المرور';
        }
        if (value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: widget.isLoading ? null : (value) {
                  setState(() => _rememberMe = value ?? false);
                  widget.onRememberMeChanged(_rememberMe);
                },
                activeColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.isLoading ? null : () {
                setState(() => _rememberMe = !_rememberMe);
                widget.onRememberMeChanged(_rememberMe);
              },
              child: const Text(
                'تذكرني',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: widget.isLoading ? null : widget.onForgotPassword,
          child: const Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text(
        'تسجيل الدخول',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return OutlinedButton.icon(
      onPressed: widget.isLoading ? null : widget.onBiometricLogin,
      icon: const Icon(Icons.fingerprint, color: AppTheme.primaryBlue),
      label: const Text(
        'تسجيل دخول بالبصمة',
        style: TextStyle(color: AppTheme.primaryBlue),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'أو',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return OutlinedButton(
      onPressed: widget.isLoading ? null : widget.onCreateAccount,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: const Text(
        'إنشاء حساب جديد',
        style: TextStyle(
          fontSize: 16,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }
}

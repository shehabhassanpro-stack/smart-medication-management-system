import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../core/app_theme.dart';
import '../../../../../models/user_model.dart';

class RegisterForm extends StatefulWidget {
  final Future<void> Function({
  required String name,
  required String email,
  required String password,
  required UserRole role,
  String? phone,
  DateTime? dateOfBirth,
  String? specialty,
  String? licenseNumber,
  String? gender,
  }) onRegister;

  final VoidCallback onLoginPressed;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.onRegister,
    required this.onLoginPressed,
    this.isLoading = false,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.patient;
  String? _selectedGender; // Selected gender for doctors ('male' / 'female')
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specialtyController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) {
      strength++;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    setState(() => _passwordStrength = strength);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('كلمات المرور غير متطابقة');
      return;
    }

    if (_passwordStrength < 2) {
      _showError('كلمة المرور ضعيفة. استخدم 8 أحرف على الأقل مع أرقام وحروف كبيرة وصغيرة');
      return;
    }

    if (_selectedRole == UserRole.doctor) {
      if (_selectedGender == null) {
        _showError('الرجاء تحديد الجنس (دكتور أو دكتورة)');
        return;
      }
      if (_specialtyController.text.trim().isEmpty) {
        _showError('الرجاء إدخال التخصص');
        return;
      }
      if (_licenseNumberController.text.trim().isEmpty) {
        _showError('الرجاء إدخال رقم الرخصة');
        return;
      }
    }

    await widget.onRegister(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      dateOfBirth: _selectedDateOfBirth,
      specialty: _selectedRole == UserRole.doctor ? _specialtyController.text.trim() : null,
      licenseNumber: _selectedRole == UserRole.doctor ? _licenseNumberController.text.trim() : null,
      gender: _selectedRole == UserRole.doctor ? _selectedGender : null,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRoleSelector(),
          if (_selectedRole == UserRole.doctor) ...[
            const SizedBox(height: AppTheme.spaceLG),
            _buildGenderSelector(),
          ],
          const SizedBox(height: AppTheme.spaceLG),
          _buildFormFields(),
          const SizedBox(height: AppTheme.spaceLG),
          _buildRegisterButton(),
          const SizedBox(height: AppTheme.spaceMD),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نوع الحساب',
            style: TextStyle(
              fontSize: AppTheme.fontSizeMD,
              fontWeight: AppTheme.fontWeightSemiBold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          Row(
            children: [
              Expanded(
                child: _buildRoleButton(
                  label: 'مريض',
                  icon: Icons.person_outline,
                  role: UserRole.patient,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: _buildRoleButton(
                  label: 'دكتور',
                  icon: Icons.medical_services_outlined,
                  role: UserRole.doctor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required IconData icon,
    required UserRole role,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: widget.isLoading ? null : () {
        setState(() => _selectedRole = role);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMD),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textMedium,
              size: 32,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTheme.fontSizeMD,
                fontWeight: AppTheme.fontWeightSemiBold,
                color: isSelected ? Colors.white : AppTheme.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الجنس',
            style: TextStyle(
              fontSize: AppTheme.fontSizeMD,
              fontWeight: AppTheme.fontWeightSemiBold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          Row(
            children: [
              Expanded(
                child: _buildGenderButton(
                  label: 'دكتور (ذكر)',
                  icon: Icons.male_rounded,
                  genderValue: 'male',
                ),
              ),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: _buildGenderButton(
                  label: 'دكتورة (أنثى)',
                  icon: Icons.female_rounded,
                  genderValue: 'female',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required IconData icon,
    required String genderValue,
  }) {
    final isSelected = _selectedGender == genderValue;

    return GestureDetector(
      onTap: widget.isLoading ? null : () {
        setState(() => _selectedGender = genderValue);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMD),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textMedium,
              size: 32,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTheme.fontSizeSM,
                fontWeight: AppTheme.fontWeightSemiBold,
                color: isSelected ? Colors.white : AppTheme.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(AppTheme.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameField(),
          const SizedBox(height: AppTheme.spaceMD),
          _buildEmailField(),
          const SizedBox(height: AppTheme.spaceMD),
          _buildPhoneField(),
          const SizedBox(height: AppTheme.spaceMD),
          _buildDateOfBirthField(),
          if (_selectedRole == UserRole.doctor) ...[
            const SizedBox(height: AppTheme.spaceMD),
            _buildSpecialtyField(),
            const SizedBox(height: AppTheme.spaceMD),
            _buildLicenseNumberField(),
          ],
          const SizedBox(height: AppTheme.spaceMD),
          _buildPasswordField(),
          const SizedBox(height: AppTheme.spaceSM),
          _buildPasswordStrengthIndicator(),
          const SizedBox(height: AppTheme.spaceMD),
          _buildConfirmPasswordField(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      enabled: !widget.isLoading,
      decoration: const InputDecoration(
        labelText: 'الاسم الكامل',
        hintText: 'أدخل اسمك الكامل',
        prefixIcon: Icon(Icons.person_outline),
      ),
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال الاسم';
        }
        if (value.trim().length < 2) {
          return 'الاسم يجب أن يكون حرفين على الأقل';
        }
        if (value.length > 50) {
          return 'الاسم طويل جداً';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      enabled: !widget.isLoading,
      decoration: const InputDecoration(
        labelText: 'البريد الإلكتروني',
        hintText: 'example@email.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال البريد الإلكتروني';
        }
        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'البريد الإلكتروني غير صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      enabled: !widget.isLoading,
      decoration: const InputDecoration(
        labelText: 'رقم الهاتف (اختياري)',
        hintText: '01012345678',
        prefixIcon: Icon(Icons.phone_outlined),
        helperText: 'يمكنك تخطي هذا الحقل',
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (value.length != 11) {
            return 'رقم الهاتف يجب أن يكون 11 رقم';
          }
          if (!value.startsWith('01')) {
            return 'رقم الهاتف يجب أن يبدأ بـ 01';
          }
        }
        return null;
      },
    );
  }

  Widget _buildDateOfBirthField() {
    return InkWell(
      onTap: widget.isLoading ? null : _selectDateOfBirth,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'تاريخ الميلاد (اختياري)',
          hintText: 'اختر تاريخ الميلاد',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: _selectedDateOfBirth != null
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() => _selectedDateOfBirth = null);
            },
          )
              : null,
        ),
        child: Text(
          _selectedDateOfBirth != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!)
              : 'لم يتم التحديد',
          style: TextStyle(
            color: _selectedDateOfBirth != null
                ? AppTheme.textDark
                : AppTheme.textMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyField() {
    return TextFormField(
      controller: _specialtyController,
      enabled: !widget.isLoading,
      decoration: const InputDecoration(
        labelText: 'التخصص',
        hintText: 'مثال: طب الأطفال، جراحة، باطنة',
        prefixIcon: Icon(Icons.local_hospital_outlined),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (_selectedRole == UserRole.doctor) {
          if (value == null || value.trim().isEmpty) {
            return 'الرجاء إدخال التخصص';
          }
          if (value.trim().length < 3) {
            return 'التخصص يجب أن يكون 3 أحرف على الأقل';
          }
        }
        return null;
      },
    );
  }

  Widget _buildLicenseNumberField() {
    return TextFormField(
      controller: _licenseNumberController,
      enabled: !widget.isLoading,
      decoration: const InputDecoration(
        labelText: 'رقم الرخصة',
        hintText: 'رقم رخصة مزاولة المهنة',
        prefixIcon: Icon(Icons.badge_outlined),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (_selectedRole == UserRole.doctor) {
          if (value == null || value.trim().isEmpty) {
            return 'الرجاء إدخال رقم الرخصة';
          }
          if (value.trim().length < 3) {
            return 'رقم الرخصة يجب أن يكون 3 أحرف على الأقل';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      enabled: !widget.isLoading,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        hintText: 'أدخل كلمة مرور قوية',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال كلمة المرور';
        }
        if (value.length < 8) {
          return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
        }
        if (!RegExp(r'[A-Z]').hasMatch(value)) {
          return 'يجب أن تحتوي على حرف كبير';
        }
        if (!RegExp(r'[a-z]').hasMatch(value)) {
          return 'يجب أن تحتوي على حرف صغير';
        }
        if (!RegExp(r'[0-9]').hasMatch(value)) {
          return 'يجب أن تحتوي على رقم';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = [
      AppTheme.errorRed,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.lightGreen,
      Colors.green,
    ];

    final labels = [
      'ضعيفة جداً',
      'ضعيفة',
      'متوسطة',
      'قوية',
      'قوية جداً',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  color: index < _passwordStrength
                      ? colors[_passwordStrength.clamp(0, 4)]
                      : AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppTheme.spaceSM),
        Text(
          'قوة كلمة المرور: ${labels[_passwordStrength.clamp(0, 4)]}',
          style: TextStyle(
            fontSize: AppTheme.fontSizeSM,
            color: colors[_passwordStrength.clamp(0, 4)],
            fontWeight: AppTheme.fontWeightMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      enabled: !widget.isLoading,
      decoration: InputDecoration(
        labelText: 'تأكيد كلمة المرور',
        hintText: 'أعد إدخال كلمة المرور',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
        ),
      ),
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSubmit(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء تأكيد كلمة المرور';
        }
        if (value != _passwordController.text) {
          return 'كلمات المرور غير متطابقة';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          ),
        ),
        child: widget.isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
            : const Text(
          'إنشاء الحساب',
          style: TextStyle(
            fontSize: AppTheme.fontSizeNormal,
            fontWeight: AppTheme.fontWeightBold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            fontSize: AppTheme.fontSizeMD,
            color: AppTheme.textMedium,
          ),
        ),
        TextButton(
          onPressed: widget.isLoading ? null : widget.onLoginPressed,
          child: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontSize: AppTheme.fontSizeMD,
              fontWeight: AppTheme.fontWeightBold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}
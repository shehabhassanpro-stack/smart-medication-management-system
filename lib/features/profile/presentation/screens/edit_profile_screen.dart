import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _nationalIdController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _newDiseaseController;
  late TextEditingController _newAllergyController;

  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _selectedDateOfBirth;
  List<String> _chronicDiseases = [];
  List<String> _allergies = [];

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _nationalIdController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
    _newDiseaseController = TextEditingController();
    _newAllergyController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeFromProvider();
      _isInitialized = true;
    }
  }

  void _initializeFromProvider() {
    final provider = context.read<ProfileProvider>();

    _nameController.text = provider.userName;
    _phoneController.text = provider.userPhone;
    _addressController.text = provider.address ?? '';
    _nationalIdController.text = provider.nationalId ?? '';
    _heightController.text = provider.height?.toStringAsFixed(0) ?? '';
    _weightController.text = provider.weight?.toStringAsFixed(0) ?? '';
    _emergencyContactController.text = provider.emergencyContact ?? '';
    _emergencyPhoneController.text = provider.emergencyPhone ?? '';

    _selectedGender = provider.gender;
    _selectedBloodType = provider.bloodType;
    _selectedDateOfBirth = provider.dateOfBirth;
    _chronicDiseases = List<String>.from(provider.chronicDiseases);
    _allergies = List<String>.from(provider.allergies);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nationalIdController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _newDiseaseController.dispose();
    _newAllergyController.dispose();
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
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('المعلومات الأساسية'),
                        const SizedBox(height: 16),
                        _buildNameField(),
                        const SizedBox(height: 16),
                        _buildPhoneField(),
                        const SizedBox(height: 16),
                        _buildGenderSelector(),
                        const SizedBox(height: 16),
                        _buildDateOfBirthPicker(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('المعلومات الصحية'),
                        const SizedBox(height: 16),
                        _buildBloodTypeSelector(),
                        const SizedBox(height: 16),
                        _buildHeightWeightRow(),
                        const SizedBox(height: 16),
                        _buildChronicDiseasesList(),
                        const SizedBox(height: 16),
                        _buildAllergiesList(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('معلومات إضافية'),
                        const SizedBox(height: 16),
                        _buildAddressField(),
                        const SizedBox(height: 16),
                        _buildNationalIdField(),
                        const SizedBox(height: 32),
                        _buildSectionTitle('جهة اتصال الطوارئ'),
                        const SizedBox(height: 16),
                        _buildEmergencyContactField(),
                        const SizedBox(height: 16),
                        _buildEmergencyPhoneField(),
                        const SizedBox(height: 32),
                        _buildSaveButton(provider),
                        const SizedBox(height: 32),
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
                  'تعديل المعلومات',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'قم بتحديث بياناتك الشخصية',
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return _buildTextField(
      controller: _nameController,
      label: 'الاسم الكامل',
      icon: Icons.person_outline_rounded,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال الاسم';
        }
        if (value.length < 3) {
          return 'الاسم يجب أن يكون 3 أحرف على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'رقم الهاتف',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 10) {
          return 'رقم الهاتف غير صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return _buildTextField(
      controller: _addressController,
      label: 'العنوان',
      icon: Icons.location_on_outlined,
      maxLines: 2,
    );
  }

  Widget _buildNationalIdField() {
    return _buildTextField(
      controller: _nationalIdController,
      label: 'رقم الهوية',
      icon: Icons.badge_outlined,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildEmergencyContactField() {
    return _buildTextField(
      controller: _emergencyContactController,
      label: 'اسم جهة الاتصال',
      icon: Icons.contact_emergency_outlined,
    );
  }

  Widget _buildEmergencyPhoneField() {
    return _buildTextField(
      controller: _emergencyPhoneController,
      label: 'رقم هاتف الطوارئ',
      icon: Icons.phone_callback_outlined,
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildHeightWeightRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _heightController,
            label: 'الطول (سم)',
            icon: Icons.height_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final height = double.tryParse(value);
                if (height == null || height < 50 || height > 250) {
                  return 'قيمة غير صحيحة';
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            controller: _weightController,
            label: 'الوزن (كجم)',
            icon: Icons.monitor_weight_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final weight = double.tryParse(value);
                if (weight == null || weight < 20 || weight > 300) {
                  return 'قيمة غير صحيحة';
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
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
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الجنس',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                label: 'ذكر',
                value: 'male',
                icon: Icons.male_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption(
                label: 'أنثى',
                value: 'female',
                icon: Icons.female_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedGender == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedGender = value);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthPicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickDateOfBirth,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.cake_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ الميلاد',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDateOfBirth != null
                          ? _formatDate(_selectedDateOfBirth!)
                          : 'اختر التاريخ',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _selectedDateOfBirth != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickDateOfBirth() async {
    HapticFeedback.lightImpact();
    
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  Widget _buildBloodTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'فصيلة الدم',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _bloodTypes.map((type) {
            final isSelected = _selectedBloodType == type;
            return _buildBloodTypeChip(type, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBloodTypeChip(String type, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedBloodType = type);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.error.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.error : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              type,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.error : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChronicDiseasesList() {
    return _buildTagsList(
      title: 'الأمراض المزمنة',
      icon: Icons.medical_services_outlined,
      tags: _chronicDiseases,
      controller: _newDiseaseController,
      hintText: 'أضف مرض مزمن...',
      onAdd: _addChronicDisease,
      onRemove: _removeChronicDisease,
      color: AppColors.warning,
    );
  }

  void _addChronicDisease(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_chronicDiseases.contains(trimmed)) {
      setState(() => _chronicDiseases.add(trimmed));
      _newDiseaseController.clear();
    }
  }

  void _removeChronicDisease(String value) {
    setState(() => _chronicDiseases.remove(value));
  }

  Widget _buildAllergiesList() {
    return _buildTagsList(
      title: 'الحساسية',
      icon: Icons.coronavirus_outlined,
      tags: _allergies,
      controller: _newAllergyController,
      hintText: 'أضف حساسية...',
      onAdd: _addAllergy,
      onRemove: _removeAllergy,
      color: AppColors.error,
    );
  }

  void _addAllergy(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_allergies.contains(trimmed)) {
      setState(() => _allergies.add(trimmed));
      _newAllergyController.clear();
    }
  }

  void _removeAllergy(String value) {
    setState(() => _allergies.remove(value));
  }

  Widget _buildTagsList({
    required String title,
    required IconData icon,
    required List<String> tags,
    required TextEditingController controller,
    required String hintText,
    required void Function(String) onAdd,
    required void Function(String) onRemove,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                return _buildTag(tag, color, onRemove);
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          _buildTagInput(controller, hintText, onAdd, color),
        ],
      ),
    );
  }

  Widget _buildTag(String tag, Color color, void Function(String) onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRemove(tag);
            },
            child: Icon(Icons.close, size: 16, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTagInput(
    TextEditingController controller,
    String hintText,
    void Function(String) onAdd,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: color),
              ),
            ),
            onSubmitted: onAdd,
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onAdd(controller.text);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ProfileProvider provider) {
    final isLoading = provider.isUpdating;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _saveProfile(provider),
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
                  const Icon(Icons.save_rounded),
                  const SizedBox(width: 8),
                  Text(
                    'حفظ التغييرات',
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

  Future<void> _saveProfile(ProfileProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('يرجى تصحيح الأخطاء في النموذج');
      return;
    }

    HapticFeedback.mediumImpact();

    final success = await provider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _selectedDateOfBirth,
      gender: _selectedGender,
      bloodType: _selectedBloodType,
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      address: _addressController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      chronicDiseases: _chronicDiseases,
      allergies: _allergies,
      emergencyContact: _emergencyContactController.text.trim(),
      emergencyPhone: _emergencyPhoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _showSuccessSnackBar('تم حفظ التغييرات بنجاح');
      Navigator.pop(context);
    } else {
      _showErrorSnackBar(provider.errorMessage ?? 'حدث خطأ في حفظ البيانات');
    }
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

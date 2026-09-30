import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../domain/entities/medicine_entity.dart';
import '../providers/medicine_form_provider.dart';

class AddMedicineScreen extends StatefulWidget {
  final MedicineEntity? medicine;

  const AddMedicineScreen({
    super.key,
    this.medicine,
  });

  static const String routeName = '/add-medicine';

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();
  final _stockController = TextEditingController();
  final _refillReminderController = TextEditingController();

  bool get isEditing => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MedicineFormProvider>();
      if (isEditing) {
        provider.initWithMedicine(widget.medicine!);
      } else {
        provider.reset();
      }
    });
  }

  void _populateFields() {
    final medicine = widget.medicine!;
    _nameController.text = medicine.name;
    _dosageController.text = medicine.dosage;
    _instructionsController.text = medicine.instructions ?? '';
    _notesController.text = medicine.notes ?? '';
    _stockController.text = medicine.stockCount?.toString() ?? '';
    _refillReminderController.text = medicine.refillReminder?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    _stockController.dispose();
    _refillReminderController.dispose();
    super.dispose();
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<MedicineFormProvider>();

    provider.setName(_nameController.text.trim());
    provider.setDosage(_dosageController.text.trim());
    provider.setInstructions(_instructionsController.text.trim());
    provider.setNotes(_notesController.text.trim());

    final stock = int.tryParse(_stockController.text);
    final refill = int.tryParse(_refillReminderController.text);
    provider.setStock(stock, refill);

    final success = await provider.saveMedicine(
      existingId: widget.medicine?.id,
    );

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'تم تحديث الدواء بنجاح' : 'تم إضافة الدواء بنجاح',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'تعديل الدواء' : 'إضافة دواء جديد',
          style: AppTextStyles.titleMedium,
        ),
        centerTitle: true,
        actions: [
          Consumer<MedicineFormProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: provider.isSaving ? null : _saveMedicine,
                child: provider.isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
                    : Text(
                  'حفظ',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MedicineFormProvider>(
        builder: (context, provider, child) {
          return Form(
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
                  _buildDosageField(),
                  const SizedBox(height: 16),
                  _buildDosageFormSelector(provider),
                  const SizedBox(height: 24),

                  _buildSectionTitle('مواعيد الجرعات'),
                  const SizedBox(height: 16),
                  _buildFrequencySelector(provider),
                  const SizedBox(height: 16),
                  _buildTimesSelector(provider),
                  const SizedBox(height: 24),

                  _buildSectionTitle('مدة العلاج'),
                  const SizedBox(height: 16),
                  _buildDateRangeSelector(provider),
                  const SizedBox(height: 24),

                  _buildSectionTitle('إعدادات إضافية'),
                  const SizedBox(height: 16),
                  _buildCriticalSwitch(provider),
                  const SizedBox(height: 16),
                  _buildStockFields(),
                  const SizedBox(height: 16),
                  _buildInstructionsField(),
                  const SizedBox(height: 16),
                  _buildNotesField(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: 'اسم الدواء *',
        hintText: 'مثال: باراسيتامول',
        prefixIcon: const Icon(Icons.medication_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال اسم الدواء';
        }
        if (value.trim().length < 2) {
          return 'اسم الدواء يجب أن يكون حرفين على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildDosageField() {
    return TextFormField(
      controller: _dosageController,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: 'الجرعة *',
        hintText: 'مثال: 500 ملجم',
        prefixIcon: const Icon(Icons.science_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال الجرعة';
        }
        return null;
      },
    );
  }

  Widget _buildDosageFormSelector(MedicineFormProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'شكل الدواء',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DosageForm.values.map((form) {
            final isSelected = provider.dosageForm == form;
            return ChoiceChip(
              label: Text(form.arabicName),
              selected: isSelected,
              onSelected: (_) => provider.setDosageForm(form),
              selectedColor: AppColors.primary.withAlpha(51),
              backgroundColor: AppColors.surface,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              avatar: isSelected
                  ? Icon(Icons.check, size: 16, color: AppColors.primary)
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector(MedicineFormProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تكرار الجرعة',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Frequency>(
              value: provider.frequency,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(12),
              items: Frequency.values.map((freq) {
                return DropdownMenuItem(
                  value: freq,
                  child: Text(
                    freq.arabicName,
                    style: AppTextStyles.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setFrequency(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimesSelector(MedicineFormProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'أوقات الجرعات',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddTimeDialog(provider),
              icon: Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
              label: Text(
                'إضافة وقت',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.times.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 40,
                    color: AppColors.textSecondary.withAlpha(128),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لم تتم إضافة أوقات بعد',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.times.map((time) {
              return Chip(
                label: Text(
                  time,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                backgroundColor: AppColors.primary.withAlpha(26),
                deleteIcon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                onDeleted: () => provider.removeTime(time),
                side: BorderSide(color: AppColors.primary.withAlpha(77)),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> _showAddTimeDialog(MedicineFormProvider provider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      provider.addTime(timeString);
    }
  }

  Widget _buildDateRangeSelector(MedicineFormProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            label: 'تاريخ البداية',
            value: provider.startDate,
            onTap: () => _selectDate(provider, isStart: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateField(
            label: 'تاريخ الانتهاء',
            value: provider.endDate,
            onTap: () => _selectDate(provider, isStart: false),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  value != null
                      ? '${value.day}/${value.month}/${value.year}'
                      : 'غير محدد',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: value != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(MedicineFormProvider provider, {required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (provider.startDate ?? DateTime.now())
          : (provider.endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        provider.setStartDate(picked);
      } else {
        provider.setEndDate(picked);
      }
    }
  }

  Widget _buildCriticalSwitch(MedicineFormProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.isCritical
            ? AppColors.error.withAlpha(26)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: provider.isCritical ? AppColors.error : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: provider.isCritical ? AppColors.error : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دواء حرج',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: provider.isCritical
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'سيتم تمييز هذا الدواء كدواء مهم',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: provider.isCritical,
            onChanged: provider.setIsCritical,
            activeTrackColor: AppColors.error.withAlpha(128),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.error;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStockFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _stockController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'الكمية المتبقية',
              hintText: '0',
              prefixIcon: const Icon(Icons.inventory_2_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _refillReminderController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'تنبيه التعبئة',
              hintText: '5',
              prefixIcon: const Icon(Icons.notifications_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsField() {
    return TextFormField(
      controller: _instructionsController,
      textDirection: TextDirection.rtl,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'تعليمات الاستخدام',
        hintText: 'مثال: تناول بعد الأكل',
        prefixIcon: const Icon(Icons.info_outline_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      textDirection: TextDirection.rtl,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'ملاحظات',
        hintText: 'أي ملاحظات إضافية...',
        prefixIcon: const Icon(Icons.note_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}
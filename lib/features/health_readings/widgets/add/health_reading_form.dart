import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../../../models/health/health_exports.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/app_constants.dart';
import 'health_time_selector.dart';

class HealthReadingForm extends StatelessWidget {
  final ReadingType type;
  final TextEditingController? systolicController;
  final TextEditingController? diastolicController;
  final TextEditingController? valueController;
  final TextEditingController? notesController;
  final FocusNode? systolicFocus;
  final FocusNode? diastolicFocus;
  final FocusNode? valueFocus;
  final FocusNode? notesFocus;
  final MeasurementTime? selectedMeasurementTime;
  final ValueChanged<MeasurementTime?>? onMeasurementTimeChanged;
  final Animation<double>? animation;
  final Animation<Offset>? slideAnimation;

  const HealthReadingForm({
    super.key,
    required this.type,
    this.systolicController,
    this.diastolicController,
    this.valueController,
    this.notesController,
    this.systolicFocus,
    this.diastolicFocus,
    this.valueFocus,
    this.notesFocus,
    this.selectedMeasurementTime,
    this.onMeasurementTimeChanged,
    this.animation,
    this.slideAnimation,
  });

  Color get _color => type.color;

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (animation != null && slideAnimation != null) {
      return SlideTransition(
        position: slideAnimation!,
        child: FadeTransition(
          opacity: animation!,
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(UIConstants.paddingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: UIConstants.paddingLg),
          _buildInputFields(context),
          SizedBox(height: UIConstants.paddingMd),
          _buildRangeInfo(),
          if (_showMeasurementTime) ...[
            SizedBox(height: UIConstants.paddingLg),
            MeasurementTimeSelectorCompact(
              selectedTime: selectedMeasurementTime,
              onTimeSelected: onMeasurementTimeChanged ?? (_) {},
              accentColor: _color,
            ),
          ],
          SizedBox(height: UIConstants.paddingLg),
          _buildNotesField(),
        ],
      ),
    );
  }

  bool get _showMeasurementTime =>
      type == ReadingType.bloodSugar || type == ReadingType.bloodPressure;

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_color, _color.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            type.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        SizedBox(width: UIConstants.paddingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إدخال ${type.nameAr}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                type.descriptionAr,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields(BuildContext context) {
    switch (type) {
      case ReadingType.bloodPressure:
        return _buildBloodPressureFields(context);
      case ReadingType.bloodSugar:
        return _buildSingleField(
          controller: valueController,
          focusNode: valueFocus,
          label: 'مستوى السكر',
          hint: '100',
          suffix: type.unit,
          icon: Icons.water_drop_rounded,
          decimal: false,
        );
      case ReadingType.weight:
        return _buildSingleField(
          controller: valueController,
          focusNode: valueFocus,
          label: 'الوزن',
          hint: '70.5',
          suffix: type.unit,
          icon: Icons.monitor_weight_rounded,
          decimal: true,
        );
      case ReadingType.temperature:
        return _buildSingleField(
          controller: valueController,
          focusNode: valueFocus,
          label: 'درجة الحرارة',
          hint: '37.0',
          suffix: type.unit,
          icon: Icons.thermostat_rounded,
          decimal: true,
        );
    }
  }

  Widget _buildBloodPressureFields(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSingleField(
            controller: systolicController,
            focusNode: systolicFocus,
            label: 'الانقباضي',
            hint: '120',
            suffix: 'mmHg',
            icon: Icons.arrow_upward_rounded,
            decimal: false,
            onSubmit: (_) => diastolicFocus?.requestFocus(),
          ),
        ),
        SizedBox(width: UIConstants.paddingMd),
        Expanded(
          child: _buildSingleField(
            controller: diastolicController,
            focusNode: diastolicFocus,
            label: 'الانبساطي',
            hint: '80',
            suffix: 'mmHg',
            icon: Icons.arrow_downward_rounded,
            decimal: false,
            color: _color.withValues(alpha: 0.7),
            onSubmit: (_) => notesFocus?.requestFocus(),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
    required bool decimal,
    Color? color,
    Function(String)? onSubmit,
  }) {
    final fieldColor = color ?? _color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: fieldColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            decimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
          ),
          LengthLimitingTextInputFormatter(6),
        ],
        style: AppTextStyles.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: fieldColor,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          suffixStyle: AppTextStyles.titleMedium.copyWith(
            color: fieldColor.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(icon, color: fieldColor, size: 28),
          filled: true,
          fillColor: fieldColor.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: fieldColor.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: fieldColor,
              width: 3,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 3,
            ),
          ),
        ),
        validator: _validateInput,
        onFieldSubmitted: onSubmit ?? (_) => notesFocus?.requestFocus(),
      ),
    );
  }

  String? _validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final sanitized = value.replaceAll(RegExp(r'[^\d.]'), '');
    final number = double.tryParse(sanitized);
    if (number == null) {
      return 'يرجى إدخال رقم صحيح';
    }
    if (number <= 0) {
      return 'يرجى إدخال رقم موجب';
    }
    return null;
  }

  Widget _buildRangeInfo() {
    return Container(
      padding: EdgeInsets.all(UIConstants.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.info,
            size: 20,
          ),
          SizedBox(width: UIConstants.paddingSm),
          Expanded(
            child: Text(
              'النطاق المسموح: ${type.rangeText}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.sm,
      ),
      child: TextFormField(
        controller: notesController,
        focusNode: notesFocus,
        maxLines: 3,
        maxLength: 500,
        style: AppTextStyles.bodyMedium,
        inputFormatters: [
          LengthLimitingTextInputFormatter(500),
        ],
        decoration: InputDecoration(
          labelText: 'ملاحظات (اختياري)',
          hintText: 'أي ملاحظات أو أعراض إضافية...',
          alignLabelWithHint: true,
          counterText: '',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Icon(
              Icons.sticky_note_2_rounded,
              color: AppColors.info,
            ),
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.divider,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.info,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}
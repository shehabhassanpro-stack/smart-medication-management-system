import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../../models/health/health_exports.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../core/app_shadows.dart';
import '../../../core/app_constants.dart';
import '../controllers/health_add_reading_controller.dart';
import '../widgets/add/health_type_selector.dart';
import '../widgets/add/health_reading_form.dart';
import '../widgets/add/health_time_selector.dart';
import '../widgets/add/health_quick_actions.dart';
import '../widgets/add/health_reading_preview.dart';
import '../widgets/add/health_success_dialog.dart';

class HealthAddReadingScreen extends StatefulWidget {
  final ReadingType? initialType;

  const HealthAddReadingScreen({
    super.key,
    this.initialType,
  });

  @override
  State<HealthAddReadingScreen> createState() => _HealthAddReadingScreenState();
}

class _HealthAddReadingScreenState extends State<HealthAddReadingScreen>
    with TickerProviderStateMixin {
  late final HealthAddReadingController _controller;

  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();

  final _systolicFocus = FocusNode();
  final _diastolicFocus = FocusNode();
  final _valueFocus = FocusNode();
  final _notesFocus = FocusNode();

  late AnimationController _typeSelectionController;
  late AnimationController _formController;
  late AnimationController _previewController;
  late Animation<double> _typeSelectionAnimation;
  late Animation<double> _formAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = HealthAddReadingController();
    _setupAnimations();
    _setupListeners();

    if (widget.initialType != null) {
      _controller.setSelectedType(widget.initialType);
      _showForm();
    }
  }

  void _setupAnimations() {
    _typeSelectionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _previewController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _typeSelectionAnimation = CurvedAnimation(
      parent: _typeSelectionController,
      curve: Curves.easeOutBack,
    );

    _formAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_formAnimation);

    _typeSelectionController.forward();
  }

  void _setupListeners() {
    _systolicController.addListener(_onInputChanged);
    _diastolicController.addListener(_onInputChanged);
    _valueController.addListener(_onInputChanged);
    _notesController.addListener(_onNotesChanged);
  }

  void _onInputChanged() {
    if (_controller.selectedType == ReadingType.bloodPressure) {
      final systolic = int.tryParse(_systolicController.text);
      final diastolic = int.tryParse(_diastolicController.text);
      _controller.setBloodPressure(systolic, diastolic);
    } else {
      final value = double.tryParse(_valueController.text);
      _controller.setValue(value);
    }
    _updatePreviewAnimation();
  }

  void _onNotesChanged() {
    _controller.setNotes(_notesController.text);
  }

  void _updatePreviewAnimation() {
    if (_controller.previewReading != null) {
      _previewController.forward();
    } else {
      _previewController.reverse();
    }
  }

  void _showForm() {
    _formController.forward();
  }

  void _onTypeSelected(ReadingType type) {
    _controller.setSelectedType(type);
    _clearControllers();
    _showForm();
  }

  void _clearControllers() {
    _systolicController.clear();
    _diastolicController.clear();
    _valueController.clear();
    _notesController.clear();
  }

  void _applyQuickValue(HealthQuickValue quickValue) {
    if (quickValue.isBloodPressure) {
      _systolicController.text = quickValue.systolic.toString();
      _diastolicController.text = quickValue.diastolic.toString();
    } else {
      _valueController.text = quickValue.value;
    }
  }

  Future<void> _saveReading() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('يرجى ملء جميع الحقول المطلوبة بشكل صحيح');
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();

    final success = await _controller.saveReading();

    if (success && mounted) {
      HapticFeedback.heavyImpact();
      await HealthSuccessDialog.show(
        context,
        reading: _controller.savedReading!,
        userHeight: _controller.userHeight,  // ✅ إضافة userHeight لحساب BMI
        onAddAnother: () {
          _controller.prepareForNewReading();
          _clearControllers();
        },
        onDone: () {
          Navigator.pop(context);
        },
      );
    } else if (_controller.hasError && mounted) {
      _showErrorSnackBar(_controller.errorMessage ?? 'حدث خطأ');
      HapticFeedback.heavyImpact();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            SizedBox(width: UIConstants.paddingSm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(UIConstants.paddingMd),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_rounded, color: AppColors.info),
            const SizedBox(width: 12),
            const Text('معلومات'),
          ],
        ),
        content: const Text(
          'هذه الشاشة تمكنك من إضافة قراءات صحية جديدة.\n\n'
              '• اختر نوع القراءة\n'
              '• أدخل القيمة ضمن النطاق المسموح\n'
              '• يمكنك إضافة ملاحظات اختيارية\n'
              '• راجع المعاينة قبل الحفظ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _typeSelectionController.dispose();
    _formController.dispose();
    _previewController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    _systolicFocus.dispose();
    _diastolicFocus.dispose();
    _valueFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(UIConstants.paddingMd),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            HealthTypeSelector(
                              selectedType: _controller.selectedType,
                              onTypeSelected: _onTypeSelected,
                              animation: _typeSelectionAnimation,
                            ),
                            if (_controller.selectedType != null) ...[
                              SizedBox(height: UIConstants.paddingLg),
                              HealthReadingForm(
                                type: _controller.selectedType!,
                                systolicController: _systolicController,
                                diastolicController: _diastolicController,
                                valueController: _valueController,
                                notesController: _notesController,
                                systolicFocus: _systolicFocus,
                                diastolicFocus: _diastolicFocus,
                                valueFocus: _valueFocus,
                                notesFocus: _notesFocus,
                                selectedMeasurementTime: _controller.selectedMeasurementTime,
                                onMeasurementTimeChanged: _controller.setMeasurementTime,
                                animation: _formAnimation,
                                slideAnimation: _slideAnimation,
                              ),
                              SizedBox(height: UIConstants.paddingLg),
                              HealthQuickActions(
                                type: _controller.selectedType!,
                                onQuickValueSelected: _applyQuickValue,
                                animation: _formAnimation,
                                slideAnimation: _slideAnimation,
                              ),
                              if (_controller.previewReading != null) ...[
                                SizedBox(height: UIConstants.paddingLg),
                                HealthReadingPreview(
                                  reading: _controller.previewReading!,
                                  animation: _previewController,
                                  userHeight: _controller.userHeight,
                                ),
                              ],
                              SizedBox(height: UIConstants.paddingXl),
                              _buildSaveButton(),
                              SizedBox(height: UIConstants.paddingLg),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_controller.isLoading) _buildLoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        UIConstants.paddingLg,
        topPadding + UIConstants.paddingLg,
        UIConstants.paddingLg,
        UIConstants.paddingLg,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        children: [
          _buildHeaderButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          SizedBox(width: UIConstants.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إضافة قراءة جديدة',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سجّل قراءاتك الصحية',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderButton(
            icon: Icons.info_outline_rounded,
            onTap: _showInfoDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final color = _controller.selectedType?.color ?? AppColors.primary;

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _controller.isLoading ? null : _saveReading,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_controller.isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else ...[
              const Icon(Icons.save_rounded, size: 26),
              SizedBox(width: UIConstants.paddingSm),
              Text(
                'حفظ القراءة',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(UIConstants.paddingXl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: UIConstants.paddingMd),
              Text(
                'جاري حفظ القراءة...',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

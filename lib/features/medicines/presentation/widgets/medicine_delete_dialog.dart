import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/design_tokens.dart';

class MedicineDeleteDialog extends StatefulWidget {
  final String medicineName;
  final String? medicineId;
  final bool showWarning;
  final String? warningMessage;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const MedicineDeleteDialog({
    super.key,
    required this.medicineName,
    this.medicineId,
    this.showWarning = true,
    this.warningMessage,
    this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show(
      BuildContext context, {
        required String medicineName,
        String? medicineId,
        bool showWarning = true,
        String? warningMessage,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MedicineDeleteDialog(
        medicineName: medicineName,
        medicineId: medicineId,
        showWarning: showWarning,
        warningMessage: warningMessage,
      ),
    );
  }

  @override
  State<MedicineDeleteDialog> createState() => _MedicineDeleteDialogState();
}

class _MedicineDeleteDialogState extends State<MedicineDeleteDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    HapticFeedback.mediumImpact();

    setState(() {
      _isDeleting = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    widget.onConfirm?.call();

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    widget.onCancel?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(tokens.paddingLG),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: tokens.responsive.scale(340),
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: tokens.borderRadiusXL,
            boxShadow: AppShadows.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(tokens),
              _buildContent(tokens),
              _buildActions(tokens),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DesignTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radiusXL),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: tokens.paddingAllMD,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_forever_rounded,
              color: AppColors.error,
              size: tokens.iconXL,
            ),
          ),
          SizedBox(height: tokens.spacingSM),
          Text(
            'حذف الدواء',
            style: TextStyle(
              fontSize: tokens.fontLG,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.paddingLG),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: tokens.fontMD,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'هل أنت متأكد من حذف '),
                TextSpan(
                  text: '"${widget.medicineName}"',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const TextSpan(text: '؟'),
              ],
            ),
          ),
          if (widget.showWarning) ...[
            SizedBox(height: tokens.spacingMD),
            _buildWarningBox(tokens),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningBox(DesignTokens tokens) {
    final message = widget.warningMessage ??
        'سيتم حذف جميع سجلات الجرعات والتنبيهات المرتبطة بهذا الدواء نهائياً.';

    return Container(
      padding: tokens.paddingAllMD,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: tokens.iconSM,
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: tokens.fontSM,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(DesignTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.paddingLG),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isDeleting ? null : _handleCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.border),
                padding: EdgeInsets.symmetric(vertical: tokens.paddingSM),
                shape: RoundedRectangleBorder(
                  borderRadius: tokens.borderRadiusMD,
                ),
              ),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: tokens.fontMD,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: ElevatedButton(
              onPressed: _isDeleting ? null : _handleDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: tokens.paddingSM),
                shape: RoundedRectangleBorder(
                  borderRadius: tokens.borderRadiusMD,
                ),
                elevation: 0,
                disabledBackgroundColor: AppColors.error.withValues(alpha: 0.5),
              ),
              child: _isDeleting
                  ? SizedBox(
                width: tokens.iconSM,
                height: tokens.iconSM,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.white,
                  ),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_rounded, size: tokens.iconSM),
                  SizedBox(width: tokens.spacingXS),
                  Text(
                    'حذف',
                    style: TextStyle(
                      fontSize: tokens.fontMD,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedicineBulkDeleteDialog extends StatefulWidget {
  final List<String> medicineNames;
  final int count;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const MedicineBulkDeleteDialog({
    super.key,
    required this.medicineNames,
    required this.count,
    this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show(
      BuildContext context, {
        required List<String> medicineNames,
        required int count,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MedicineBulkDeleteDialog(
        medicineNames: medicineNames,
        count: count,
      ),
    );
  }

  @override
  State<MedicineBulkDeleteDialog> createState() =>
      _MedicineBulkDeleteDialogState();
}

class _MedicineBulkDeleteDialogState extends State<MedicineBulkDeleteDialog> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    HapticFeedback.mediumImpact();

    setState(() {
      _isDeleting = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    widget.onConfirm?.call();

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    widget.onCancel?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(tokens.paddingLG),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: tokens.responsive.scale(340),
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: tokens.borderRadiusXL,
          boxShadow: AppShadows.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(tokens),
            _buildContent(tokens),
            _buildActions(tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DesignTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radiusXL),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: tokens.paddingAllMD,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_sweep_rounded,
              color: AppColors.error,
              size: tokens.iconXL,
            ),
          ),
          SizedBox(height: tokens.spacingSM),
          Text(
            'حذف ${widget.count} أدوية',
            style: TextStyle(
              fontSize: tokens.fontLG,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.paddingLG),
      child: Column(
        children: [
          Text(
            'هل أنت متأكد من حذف الأدوية التالية؟',
            style: TextStyle(
              fontSize: tokens.fontMD,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.spacingSM),
          Container(
            constraints: BoxConstraints(
              maxHeight: tokens.responsive.scale(120),
            ),
            padding: tokens.paddingAllSM,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: tokens.borderRadiusSM,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.medicineNames.length,
              separatorBuilder: (_, __) => SizedBox(height: tokens.spacingXS),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Icon(
                      Icons.medication_rounded,
                      color: AppColors.error,
                      size: tokens.iconXS,
                    ),
                    SizedBox(width: tokens.spacingXS),
                    Expanded(
                      child: Text(
                        widget.medicineNames[index],
                        style: TextStyle(
                          fontSize: tokens.fontSM,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: tokens.spacingMD),
          Container(
            padding: tokens.paddingAllSM,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: tokens.borderRadiusSM,
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: tokens.iconSM,
                ),
                SizedBox(width: tokens.spacingSM),
                Expanded(
                  child: Text(
                    'لا يمكن التراجع عن هذا الإجراء',
                    style: TextStyle(
                      fontSize: tokens.fontSM,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(DesignTokens tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.paddingLG),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isDeleting ? null : _handleCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.border),
                padding: EdgeInsets.symmetric(vertical: tokens.paddingSM),
                shape: RoundedRectangleBorder(
                  borderRadius: tokens.borderRadiusMD,
                ),
              ),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: tokens.fontMD,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: tokens.spacingSM),
          Expanded(
            child: ElevatedButton(
              onPressed: _isDeleting ? null : _handleDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: tokens.paddingSM),
                shape: RoundedRectangleBorder(
                  borderRadius: tokens.borderRadiusMD,
                ),
                elevation: 0,
                disabledBackgroundColor: AppColors.error.withValues(alpha: 0.5),
              ),
              child: _isDeleting
                  ? SizedBox(
                width: tokens.iconSM,
                height: tokens.iconSM,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.white,
                  ),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_rounded, size: tokens.iconSM),
                  SizedBox(width: tokens.spacingXS),
                  Text(
                    'حذف الكل',
                    style: TextStyle(
                      fontSize: tokens.fontMD,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
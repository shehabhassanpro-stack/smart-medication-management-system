import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/design_tokens.dart';

class MedicineCard extends StatelessWidget {
  final String id;
  final String name;
  final String dosage;
  final String dosageForm;
  final List<String> times;
  final String frequency;
  final bool isActive;
  final bool isCritical;
  final double? adherenceRate;
  final int? todayTaken;
  final int? todayTotal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleActive;

  const MedicineCard({
    super.key,
    required this.id,
    required this.name,
    required this.dosage,
    this.dosageForm = 'حبوب',
    required this.times,
    required this.frequency,
    this.isActive = true,
    this.isCritical = false,
    this.adherenceRate,
    this.todayTaken,
    this.todayTotal,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Dismissible(
      key: Key('medicine_$id'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false;
        } else {
          return await _showDeleteConfirmation(context);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      background: _buildSwipeBackground(
        context,
        tokens,
        isEdit: true,
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        tokens,
        isEdit: false,
      ),
      child: _buildCard(context, tokens),
    );
  }

  Widget _buildCard(BuildContext context, DesignTokens tokens) {
    return Semantics(
      button: true,
      label: 'دواء $name',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: tokens.paddingAllMD,
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : AppColors.surfaceVariant,
            borderRadius: tokens.borderRadiusLG,
            border: Border.all(
              color: isCritical
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.border,
              width: isCritical ? 1.5 : 1,
            ),
            boxShadow: isActive ? AppShadows.card : AppShadows.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(tokens),
              SizedBox(height: tokens.spacingSM),
              _buildDosageInfo(tokens),
              SizedBox(height: tokens.spacingSM),
              _buildTimesRow(tokens),
              if (adherenceRate != null || todayTaken != null) ...[
                SizedBox(height: tokens.spacingSM),
                _buildProgressSection(tokens),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DesignTokens tokens) {
    return Row(
      children: [
        _buildMedicineIcon(tokens),
        SizedBox(width: tokens.spacingSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: tokens.fontLG,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCritical) ...[
                    SizedBox(width: tokens.spacingXS),
                    _buildCriticalBadge(tokens),
                  ],
                ],
              ),
              SizedBox(height: tokens.spacing2XS),
              Text(
                frequency,
                style: TextStyle(
                  fontSize: tokens.fontSM,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(tokens),
      ],
    );
  }

  Widget _buildMedicineIcon(DesignTokens tokens) {
    final iconData = _getDosageFormIcon();
    final color = isActive ? _getDosageFormColor() : AppColors.textTertiary;

    return Container(
      padding: tokens.paddingAllSM,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusMD,
      ),
      child: Icon(
        iconData,
        color: color,
        size: tokens.iconMD,
      ),
    );
  }

  IconData _getDosageFormIcon() {
    switch (dosageForm.toLowerCase()) {
      case 'حبوب':
      case 'أقراص':
      case 'كبسولات':
        return Icons.medication_rounded;
      case 'شراب':
      case 'محلول':
        return Icons.medication_liquid_rounded;
      case 'حقن':
      case 'إبر':
        return Icons.vaccines_rounded;
      case 'قطرة':
      case 'قطرات':
        return Icons.opacity_rounded;
      case 'بخاخ':
        return Icons.air_rounded;
      case 'كريم':
      case 'مرهم':
        return Icons.sanitizer_rounded;
      default:
        return Icons.medication_rounded;
    }
  }

  Color _getDosageFormColor() {
    switch (dosageForm.toLowerCase()) {
      case 'حبوب':
      case 'أقراص':
      case 'كبسولات':
        return AppColors.primary;
      case 'شراب':
      case 'محلول':
        return AppColors.info;
      case 'حقن':
      case 'إبر':
        return AppColors.error;
      case 'قطرة':
      case 'قطرات':
        return AppColors.success;
      case 'بخاخ':
        return AppColors.warning;
      case 'كريم':
      case 'مرهم':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildCriticalBadge(DesignTokens tokens) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingXS,
        vertical: tokens.padding2XS,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusSM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.priority_high_rounded,
            color: AppColors.error,
            size: tokens.iconXS,
          ),
          SizedBox(width: tokens.spacing2XS),
          Text(
            'مهم',
            style: TextStyle(
              fontSize: tokens.fontXS,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DesignTokens tokens) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggleActive?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.paddingSM,
          vertical: tokens.paddingXS,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.textSecondary.withValues(alpha: 0.1),
          borderRadius: tokens.borderRadiusSM,
        ),
        child: Text(
          isActive ? 'نشط' : 'متوقف',
          style: TextStyle(
            fontSize: tokens.fontXS,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDosageInfo(DesignTokens tokens) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingSM,
        vertical: tokens.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: tokens.borderRadiusSM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_pharmacy_outlined,
            color: AppColors.primary,
            size: tokens.iconSM,
          ),
          SizedBox(width: tokens.spacingXS),
          Text(
            '$dosage - $dosageForm',
            style: TextStyle(
              fontSize: tokens.fontSM,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimesRow(DesignTokens tokens) {
    return Wrap(
      spacing: tokens.spacingXS,
      runSpacing: tokens.spacingXS,
      children: times.take(4).map((time) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.paddingSM,
            vertical: tokens.paddingXS,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: tokens.borderRadiusSM,
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                color: AppColors.textSecondary,
                size: tokens.iconXS,
              ),
              SizedBox(width: tokens.spacing2XS),
              Text(
                time,
                style: TextStyle(
                  fontSize: tokens.fontSM,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressSection(DesignTokens tokens) {
    return Container(
      padding: tokens.paddingAllSM,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: tokens.borderRadiusSM,
      ),
      child: Row(
        children: [
          if (todayTaken != null && todayTotal != null) ...[
            Expanded(
              child: _buildTodayProgress(tokens),
            ),
            if (adherenceRate != null)
              Container(
                width: 1,
                height: tokens.responsive.scale(30),
                margin: EdgeInsets.symmetric(horizontal: tokens.spacingSM),
                color: AppColors.border,
              ),
          ],
          if (adherenceRate != null)
            Expanded(
              child: _buildAdherenceInfo(tokens),
            ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress(DesignTokens tokens) {
    final progress = todayTotal! > 0 ? todayTaken! / todayTotal! : 0.0;
    final isComplete = todayTaken == todayTotal;

    return Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle_rounded : Icons.pending_rounded,
          color: isComplete ? AppColors.success : AppColors.warning,
          size: tokens.iconSM,
        ),
        SizedBox(width: tokens.spacingXS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اليوم: $todayTaken/$todayTotal',
                style: TextStyle(
                  fontSize: tokens.fontXS,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: tokens.spacing2XS),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? AppColors.success : AppColors.warning,
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdherenceInfo(DesignTokens tokens) {
    final color = _getAdherenceColor(adherenceRate!);

    return Row(
      children: [
        Icon(
          Icons.trending_up_rounded,
          color: color,
          size: tokens.iconSM,
        ),
        SizedBox(width: tokens.spacingXS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الالتزام',
              style: TextStyle(
                fontSize: tokens.fontXS,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${adherenceRate!.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: tokens.fontMD,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getAdherenceColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildSwipeBackground(
      BuildContext context,
      DesignTokens tokens, {
        required bool isEdit,
      }) {
    return Container(
      alignment: isEdit ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: tokens.paddingXL),
      decoration: BoxDecoration(
        color: isEdit ? AppColors.info : AppColors.error,
        borderRadius: tokens.borderRadiusLG,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isEdit) ...[
            Icon(
              Icons.delete_rounded,
              color: AppColors.white,
              size: tokens.iconMD,
            ),
            SizedBox(width: tokens.spacingXS),
            Text(
              'حذف',
              style: TextStyle(
                fontSize: tokens.fontMD,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
          if (isEdit) ...[
            Text(
              'تعديل',
              style: TextStyle(
                fontSize: tokens.fontMD,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: tokens.spacingXS),
            Icon(
              Icons.edit_rounded,
              color: AppColors.white,
              size: tokens.iconMD,
            ),
          ],
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    final tokens = context.tokens;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: tokens.borderRadiusLG,
        ),
        title: Row(
          children: [
            Container(
              padding: tokens.paddingAllSM,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: tokens.borderRadiusSM,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: tokens.iconMD,
              ),
            ),
            SizedBox(width: tokens.spacingSM),
            const Text('حذف الدواء'),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف "$name"؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(
            fontSize: tokens.fontMD,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: tokens.fontMD,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: tokens.borderRadiusMD,
              ),
            ),
            child: Text(
              'حذف',
              style: TextStyle(fontSize: tokens.fontMD),
            ),
          ),
        ],
      ),
    );
  }
}
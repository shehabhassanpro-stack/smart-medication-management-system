import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/design_tokens.dart';

class MedicineDetailsSheet extends StatelessWidget {
  final String id;
  final String name;
  final String dosage;
  final String dosageForm;
  final List<String> times;
  final String frequency;
  final bool isActive;
  final bool isCritical;
  final double? adherenceRate;
  final String? instructions;
  final String? notes;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? remainingDays;
  final int? stockCount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleActive;
  final VoidCallback? onViewHistory;

  const MedicineDetailsSheet({
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
    this.instructions,
    this.notes,
    this.startDate,
    this.endDate,
    this.remainingDays,
    this.stockCount,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
    this.onViewHistory,
  });

  static Future<void> show(
      BuildContext context, {
        required String id,
        required String name,
        required String dosage,
        String dosageForm = 'حبوب',
        required List<String> times,
        required String frequency,
        bool isActive = true,
        bool isCritical = false,
        double? adherenceRate,
        String? instructions,
        String? notes,
        DateTime? startDate,
        DateTime? endDate,
        int? remainingDays,
        int? stockCount,
        VoidCallback? onEdit,
        VoidCallback? onDelete,
        VoidCallback? onToggleActive,
        VoidCallback? onViewHistory,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicineDetailsSheet(
        id: id,
        name: name,
        dosage: dosage,
        dosageForm: dosageForm,
        times: times,
        frequency: frequency,
        isActive: isActive,
        isCritical: isCritical,
        adherenceRate: adherenceRate,
        instructions: instructions,
        notes: notes,
        startDate: startDate,
        endDate: endDate,
        remainingDays: remainingDays,
        stockCount: stockCount,
        onEdit: onEdit,
        onDelete: onDelete,
        onToggleActive: onToggleActive,
        onViewHistory: onViewHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radiusXL),
        ),
        boxShadow: AppShadows.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(tokens),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPadding + tokens.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, tokens),
                  _buildDivider(tokens),
                  _buildDosageSection(tokens),
                  _buildDivider(tokens),
                  _buildScheduleSection(tokens),
                  if (adherenceRate != null) ...[
                    _buildDivider(tokens),
                    _buildAdherenceSection(tokens),
                  ],
                  if (instructions != null || notes != null) ...[
                    _buildDivider(tokens),
                    _buildNotesSection(tokens),
                  ],
                  if (startDate != null || endDate != null || stockCount != null) ...[
                    _buildDivider(tokens),
                    _buildAdditionalInfo(tokens),
                  ],
                  _buildDivider(tokens),
                  _buildActions(context, tokens),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(DesignTokens tokens) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: tokens.paddingSM),
      width: tokens.responsive.scale(40),
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.paddingLG),
      child: Row(
        children: [
          _buildMedicineIcon(tokens),
          SizedBox(width: tokens.spacingMD),
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
                          fontSize: tokens.fontXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isCritical)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.paddingSM,
                          vertical: tokens.paddingXS,
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
                      ),
                  ],
                ),
                SizedBox(height: tokens.spacingXS),
                Row(
                  children: [
                    Container(
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
                    SizedBox(width: tokens.spacingSM),
                    Text(
                      frequency,
                      style: TextStyle(
                        fontSize: tokens.fontSM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: tokens.iconMD,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineIcon(DesignTokens tokens) {
    final color = isActive ? _getDosageFormColor() : AppColors.textTertiary;

    return Container(
      padding: tokens.paddingAllMD,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusLG,
      ),
      child: Icon(
        _getDosageFormIcon(),
        color: color,
        size: tokens.iconLG,
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

  Widget _buildDivider(DesignTokens tokens) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: tokens.paddingLG,
      endIndent: tokens.paddingLG,
    );
  }

  Widget _buildDosageSection(DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(tokens, 'الجرعة', Icons.local_pharmacy_outlined),
          SizedBox(height: tokens.spacingSM),
          Container(
            width: double.infinity,
            padding: tokens.paddingAllMD,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: tokens.borderRadiusMD,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getDosageFormIcon(),
                  color: AppColors.primary,
                  size: tokens.iconMD,
                ),
                SizedBox(width: tokens.spacingSM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dosage,
                      style: TextStyle(
                        fontSize: tokens.fontLG,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      dosageForm,
                      style: TextStyle(
                        fontSize: tokens.fontSM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(tokens, 'مواعيد الجرعات', Icons.schedule_rounded),
          SizedBox(height: tokens.spacingSM),
          Wrap(
            spacing: tokens.spacingSM,
            runSpacing: tokens.spacingSM,
            children: times.map((time) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.paddingMD,
                  vertical: tokens.paddingSM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: tokens.borderRadiusMD,
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: AppShadows.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTimeIcon(time),
                      color: _getTimeColor(time),
                      size: tokens.iconSM,
                    ),
                    SizedBox(width: tokens.spacingXS),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: tokens.fontMD,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getTimeIcon(String time) {
    final hour = int.tryParse(time.split(':').first) ?? 12;
    if (hour >= 5 && hour < 12) return Icons.wb_sunny_outlined;
    if (hour >= 12 && hour < 17) return Icons.wb_sunny_rounded;
    if (hour >= 17 && hour < 21) return Icons.wb_twilight_rounded;
    return Icons.nights_stay_outlined;
  }

  Color _getTimeColor(String time) {
    final hour = int.tryParse(time.split(':').first) ?? 12;
    if (hour >= 5 && hour < 12) return AppColors.warning;
    if (hour >= 12 && hour < 17) return AppColors.accent;
    if (hour >= 17 && hour < 21) return AppColors.info;
    return AppColors.primaryDark;
  }

  Widget _buildAdherenceSection(DesignTokens tokens) {
    final color = _getAdherenceColor(adherenceRate!);

    return Padding(
      padding: EdgeInsets.all(tokens.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(tokens, 'معدل الالتزام', Icons.trending_up_rounded),
          SizedBox(height: tokens.spacingSM),
          Container(
            width: double.infinity,
            padding: tokens.paddingAllMD,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: tokens.borderRadiusMD,
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: tokens.paddingAllSM,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: color,
                    size: tokens.iconMD,
                  ),
                ),
                SizedBox(width: tokens.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${adherenceRate!.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: tokens.font2XL,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      SizedBox(height: tokens.spacing2XS),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: adherenceRate! / 100,
                          backgroundColor: color.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAdherenceColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildNotesSection(DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(tokens, 'ملاحظات', Icons.notes_rounded),
          SizedBox(height: tokens.spacingSM),
          if (instructions != null) ...[
            _buildInfoCard(
              tokens,
              title: 'تعليمات الاستخدام',
              content: instructions!,
              icon: Icons.info_outline_rounded,
              color: AppColors.info,
            ),
            SizedBox(height: tokens.spacingSM),
          ],
          if (notes != null)
            _buildInfoCard(
              tokens,
              title: 'ملاحظات إضافية',
              content: notes!,
              icon: Icons.sticky_note_2_outlined,
              color: AppColors.warning,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      DesignTokens tokens, {
        required String title,
        required String content,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      width: double.infinity,
      padding: tokens.paddingAllMD,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: tokens.borderRadiusMD,
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: tokens.iconSM),
              SizedBox(width: tokens.spacingXS),
              Text(
                title,
                style: TextStyle(
                  fontSize: tokens.fontSM,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingXS),
          Text(
            content,
            style: TextStyle(
              fontSize: tokens.fontMD,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(tokens, 'معلومات إضافية', Icons.info_outline_rounded),
          SizedBox(height: tokens.spacingSM),
          Wrap(
            spacing: tokens.spacingSM,
            runSpacing: tokens.spacingSM,
            children: [
              if (startDate != null)
                _buildInfoChip(
                  tokens,
                  icon: Icons.play_arrow_rounded,
                  label: 'تاريخ البدء',
                  value: _formatDate(startDate!),
                  color: AppColors.success,
                ),
              if (endDate != null)
                _buildInfoChip(
                  tokens,
                  icon: Icons.stop_rounded,
                  label: 'تاريخ الانتهاء',
                  value: _formatDate(endDate!),
                  color: AppColors.warning,
                ),
              if (remainingDays != null)
                _buildInfoChip(
                  tokens,
                  icon: Icons.hourglass_bottom_rounded,
                  label: 'الأيام المتبقية',
                  value: '$remainingDays يوم',
                  color: AppColors.info,
                ),
              if (stockCount != null)
                _buildInfoChip(
                  tokens,
                  icon: Icons.inventory_2_outlined,
                  label: 'المخزون',
                  value: '$stockCount',
                  color: stockCount! < 10 ? AppColors.error : AppColors.success,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
      DesignTokens tokens, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingSM,
        vertical: tokens.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusSM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: tokens.iconXS),
          SizedBox(width: tokens.spacing2XS),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: tokens.fontXS,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: tokens.fontXS,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSectionTitle(DesignTokens tokens, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: tokens.iconSM,
        ),
        SizedBox(width: tokens.spacingXS),
        Text(
          title,
          style: TextStyle(
            fontSize: tokens.fontMD,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.paddingLG),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'تعديل',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.of(context).pop();
                    onEdit?.call();
                  },
                ),
              ),
              SizedBox(width: tokens.spacingSM),
              Expanded(
                child: _ActionButton(
                  icon: isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  label: isActive ? 'إيقاف' : 'تفعيل',
                  color: isActive ? AppColors.warning : AppColors.success,
                  onTap: () {
                    Navigator.of(context).pop();
                    onToggleActive?.call();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingSM),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.history_rounded,
                  label: 'السجل',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.of(context).pop();
                    onViewHistory?.call();
                  },
                ),
              ),
              SizedBox(width: tokens.spacingSM),
              Expanded(
                child: _ActionButton(
                  icon: Icons.delete_rounded,
                  label: 'حذف',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.of(context).pop();
                    onDelete?.call();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.paddingMD,
          vertical: tokens.paddingSM,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: tokens.borderRadiusMD,
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: tokens.iconSM),
            SizedBox(width: tokens.spacingXS),
            Text(
              label,
              style: TextStyle(
                fontSize: tokens.fontSM,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
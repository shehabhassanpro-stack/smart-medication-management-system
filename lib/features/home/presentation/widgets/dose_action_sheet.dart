import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 💊 DOSE ACTION SHEET - UI Component
// ═══════════════════════════════════════════════════════════════════════════════
//
// A beautiful bottom sheet for medicine dose actions:
// • Mark as Taken ✅
// • Skip Dose ⏭️
// • Snooze (5, 10, 15, 30, 60 min) 😴
//
// Usage:
// ```dart
// DoseActionSheet.show(
//   context: context,
//   medicineName: 'أسبرين',
//   dosage: '100 ملج',
//   scheduledTime: '08:00 ص',
//   onTaken: () => provider.markMedicineTaken(id),
//   onSkip: () => provider.skipMedicine(id),
//   onSnooze: (minutes) => provider.snoozeMedicine(id, minutes),
// );
// ```
//
// ═══════════════════════════════════════════════════════════════════════════════

/// Snooze duration options for dose action sheet
/// Note: This is specific to UI, different from MedicineReminderService's SnoozeDuration
enum DoseSnoozeOption {
  fiveMinutes(5, '5 دقائق'),
  tenMinutes(10, '10 دقائق'),
  fifteenMinutes(15, '15 دقيقة'),
  thirtyMinutes(30, '30 دقيقة'),
  oneHour(60, 'ساعة');

  final int minutes;
  final String label;

  const DoseSnoozeOption(this.minutes, this.label);
}

/// Result of the dose action sheet
enum DoseActionResult {
  taken,
  skipped,
  snoozed,
  dismissed,
}

/// Data returned when action is taken
class DoseActionData {
  final DoseActionResult result;
  final int? snoozeMinutes;
  final String? skipReason;

  const DoseActionData({
    required this.result,
    this.snoozeMinutes,
    this.skipReason,
  });

  bool get isTaken => result == DoseActionResult.taken;
  bool get isSkipped => result == DoseActionResult.skipped;
  bool get isSnoozed => result == DoseActionResult.snoozed;
  bool get isDismissed => result == DoseActionResult.dismissed;
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOSE ACTION SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class DoseActionSheet extends StatefulWidget {
  final String medicineName;
  final String dosage;
  final String scheduledTime;
  final String? instructions;
  final bool isOverdue;
  final int? minutesOverdue;
  final VoidCallback? onTaken;
  final VoidCallback? onSkip;
  final void Function(int minutes)? onSnooze;

  const DoseActionSheet({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    this.instructions,
    this.isOverdue = false,
    this.minutesOverdue,
    this.onTaken,
    this.onSkip,
    this.onSnooze,
  });

  /// Show the action sheet and return the result
  static Future<DoseActionData?> show({
    required BuildContext context,
    required String medicineName,
    required String dosage,
    required String scheduledTime,
    String? instructions,
    bool isOverdue = false,
    int? minutesOverdue,
    VoidCallback? onTaken,
    VoidCallback? onSkip,
    void Function(int minutes)? onSnooze,
  }) {
    HapticFeedback.mediumImpact();
    
    return showModalBottomSheet<DoseActionData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DoseActionSheet(
        medicineName: medicineName,
        dosage: dosage,
        scheduledTime: scheduledTime,
        instructions: instructions,
        isOverdue: isOverdue,
        minutesOverdue: minutesOverdue,
        onTaken: onTaken,
        onSkip: onSkip,
        onSnooze: onSnooze,
      ),
    );
  }

  @override
  State<DoseActionSheet> createState() => _DoseActionSheetState();
}

class _DoseActionSheetState extends State<DoseActionSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showSnoozeOptions = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTaken() {
    HapticFeedback.heavyImpact();
    widget.onTaken?.call();
    Navigator.of(context).pop(
      const DoseActionData(result: DoseActionResult.taken),
    );
  }

  void _handleSkip() {
    HapticFeedback.mediumImpact();
    widget.onSkip?.call();
    Navigator.of(context).pop(
      const DoseActionData(result: DoseActionResult.skipped),
    );
  }

  void _handleSnooze(DoseSnoozeOption duration) {
    HapticFeedback.mediumImpact();
    widget.onSnooze?.call(duration.minutes);
    Navigator.of(context).pop(
      DoseActionData(
        result: DoseActionResult.snoozed,
        snoozeMinutes: duration.minutes,
      ),
    );
  }

  void _toggleSnoozeOptions() {
    HapticFeedback.selectionClick();
    setState(() {
      _showSnoozeOptions = !_showSnoozeOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: 0.9 + (0.1 * _scaleAnimation.value),
        child: Opacity(
          opacity: _scaleAnimation.value,
          child: child,
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(tokens.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: tokens.borderRadiusXL,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            _buildHandle(tokens),
            
            // Medicine Info Header
            _buildMedicineHeader(tokens),
            
            // Divider
            Divider(
              height: 1,
              color: AppColors.border.withValues(alpha: 0.5),
            ),
            
            // Action Buttons
            Padding(
              padding: tokens.paddingAllMedium,
              child: Column(
                children: [
                  // Primary Action: Mark as Taken
                  _ActionButton(
                    icon: Icons.check_circle_rounded,
                    label: 'تم تناوله',
                    sublabel: 'سجّل أنك تناولت الدواء',
                    color: AppColors.success,
                    isPrimary: true,
                    onTap: _handleTaken,
                  ),
                  
                  SizedBox(height: tokens.spacingSmall),
                  
                  // Secondary Actions Row
                  Row(
                    children: [
                      // Skip Button
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.skip_next_rounded,
                          label: 'تخطي',
                          color: AppColors.textTertiary,
                          isPrimary: false,
                          onTap: _handleSkip,
                        ),
                      ),
                      
                      SizedBox(width: tokens.spacingSmall),
                      
                      // Snooze Button
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.snooze_rounded,
                          label: 'لاحقاً',
                          color: AppColors.warning,
                          isPrimary: false,
                          isExpanded: _showSnoozeOptions,
                          onTap: _toggleSnoozeOptions,
                        ),
                      ),
                    ],
                  ),
                  
                  // Snooze Options (Expandable)
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: _buildSnoozeOptions(tokens),
                    crossFadeState: _showSnoozeOptions
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
            
            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(DesignTokens tokens) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: tokens.spacingSmall),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildMedicineHeader(DesignTokens tokens) {
    return Padding(
      padding: tokens.paddingAllMedium,
      child: Row(
        children: [
          // Medicine Icon
          Container(
            padding: tokens.paddingAllMedium,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: tokens.borderRadiusMedium,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.medication_rounded,
              color: AppColors.white,
              size: tokens.iconMedium,
            ),
          ),
          
          SizedBox(width: tokens.spacingMedium),
          
          // Medicine Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.medicineName,
                  style: TextStyle(
                    fontSize: tokens.fontSubtitle,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: tokens.spacing2XS),
                Row(
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: tokens.fontSmall,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: tokens.spacing2XS),
                    Text(
                      widget.dosage,
                      style: TextStyle(
                        fontSize: tokens.fontSmall,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: tokens.spacingSmall),
                    Icon(
                      Icons.access_time_rounded,
                      size: tokens.fontSmall,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: tokens.spacing2XS),
                    Text(
                      widget.scheduledTime,
                      style: TextStyle(
                        fontSize: tokens.fontSmall,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (widget.instructions != null) ...[
                  SizedBox(height: tokens.spacing2XS),
                  Text(
                    widget.instructions!,
                    style: TextStyle(
                      fontSize: tokens.fontXS,
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Overdue Badge
          if (widget.isOverdue)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.paddingSmall,
                vertical: tokens.spacing2XS,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: tokens.borderRadiusFull,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: tokens.fontSmall,
                    color: AppColors.error,
                  ),
                  SizedBox(width: tokens.spacing2XS),
                  Text(
                    widget.minutesOverdue != null
                        ? 'متأخر ${widget.minutesOverdue} د'
                        : 'متأخر',
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
    );
  }

  Widget _buildSnoozeOptions(DesignTokens tokens) {
    return Padding(
      padding: EdgeInsets.only(top: tokens.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ذكرني بعد:',
            style: TextStyle(
              fontSize: tokens.fontSmall,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacingXS),
          Wrap(
            spacing: tokens.spacingXS,
            runSpacing: tokens.spacingXS,
            children: DoseSnoozeOption.values.map((duration) {
              return _SnoozeChip(
                duration: duration,
                onTap: () => _handleSnooze(duration),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTION BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Color color;
  final bool isPrimary;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.sublabel,
    required this.color,
    required this.isPrimary,
    this.isExpanded = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: tokens.borderRadiusMedium,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.paddingMedium,
            vertical: isPrimary ? tokens.paddingMedium : tokens.paddingSmall,
          ),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isPrimary ? null : color.withValues(alpha: 0.1),
            borderRadius: tokens.borderRadiusMedium,
            border: isExpanded
                ? Border.all(color: color.withValues(alpha: 0.5), width: 2)
                : null,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? AppColors.white : color,
                size: isPrimary ? tokens.iconMedium : tokens.iconSmall,
              ),
              SizedBox(width: tokens.spacingXS),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isPrimary ? tokens.fontBody : tokens.fontSmall,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? AppColors.white : color,
                    ),
                  ),
                  if (sublabel != null && isPrimary) ...[
                    SizedBox(height: tokens.spacing2XS),
                    Text(
                      sublabel!,
                      style: TextStyle(
                        fontSize: tokens.fontXS,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
              if (isExpanded) ...[
                SizedBox(width: tokens.spacingXS),
                Icon(
                  Icons.expand_less_rounded,
                  color: color,
                  size: tokens.iconSmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SNOOZE CHIP
// ═══════════════════════════════════════════════════════════════════════════════

class _SnoozeChip extends StatelessWidget {
  final DoseSnoozeOption duration;
  final VoidCallback onTap;

  const _SnoozeChip({
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: tokens.borderRadiusFull,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.paddingSmall,
            vertical: tokens.spacingXS,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: tokens.borderRadiusFull,
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: tokens.fontSmall,
                color: AppColors.warning,
              ),
              SizedBox(width: tokens.spacing2XS),
              Text(
                duration.label,
                style: TextStyle(
                  fontSize: tokens.fontSmall,
                  fontWeight: FontWeight.w500,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

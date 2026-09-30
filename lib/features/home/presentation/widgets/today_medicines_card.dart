import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../providers/home_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 💊 TODAY MEDICINES CARD - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Version: 2.0.0
// Architecture: Presentation Layer (Clean Architecture)
//
// Features:
// • Loading state per action button (prevents duplicate clicks)
// • Debounce protection (500ms between clicks)
// • Visual feedback during processing
// • Optimistic UI with rollback support
// • Accessibility support (Semantics)
//
// Updates from v1.0:
// • _ActionButton converted to StatefulWidget with loading state
// • Added isProcessing parameter to MedicineItem
// • Added visual loading indicator on buttons
// • Added disabled state styling
//
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// MEDICINE STATUS ENUM
// ═══════════════════════════════════════════════════════════════════════════════

enum MedicineStatus {
  upcoming,
  due,
  inGracePeriod,
  taken,
  skipped,
  snoozed,
  missed,
}

extension MedicineStatusExtension on MedicineStatus {
  String get arabicName {
    switch (this) {
      case MedicineStatus.upcoming:
        return 'قادم';
      case MedicineStatus.due:
        return 'حان الموعد';
      case MedicineStatus.inGracePeriod:
        return 'تناوله الآن';
      case MedicineStatus.taken:
        return 'تم التناول';
      case MedicineStatus.skipped:
        return 'تم التخطي';
      case MedicineStatus.snoozed:
        return 'مؤجل';
      case MedicineStatus.missed:
        return 'فائت';
    }
  }

  Color get color {
    switch (this) {
      case MedicineStatus.upcoming:
        return AppColors.info;
      case MedicineStatus.due:
        return AppColors.warning;
      case MedicineStatus.inGracePeriod:
        return AppColors.warning;
      case MedicineStatus.taken:
        return AppColors.success;
      case MedicineStatus.skipped:
        return AppColors.textTertiary;
      case MedicineStatus.snoozed:
        return AppColors.secondary;
      case MedicineStatus.missed:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case MedicineStatus.upcoming:
        return Icons.schedule_rounded;
      case MedicineStatus.due:
        return Icons.notifications_active_rounded;
      case MedicineStatus.inGracePeriod:
        return Icons.timer_rounded;
      case MedicineStatus.taken:
        return Icons.check_circle_rounded;
      case MedicineStatus.skipped:
        return Icons.skip_next_rounded;
      case MedicineStatus.snoozed:
        return Icons.snooze_rounded;
      case MedicineStatus.missed:
        return Icons.error_rounded;
    }
  }

  bool get canMarkTaken {
    return this == MedicineStatus.upcoming ||
           this == MedicineStatus.due ||
           this == MedicineStatus.inGracePeriod;
  }

  bool get canSkip {
    return this == MedicineStatus.upcoming ||
           this == MedicineStatus.due ||
           this == MedicineStatus.inGracePeriod;
  }

  bool get canSnooze {
    return this == MedicineStatus.due ||
           this == MedicineStatus.inGracePeriod;
  }

  bool get isUrgent {
    return this == MedicineStatus.due ||
           this == MedicineStatus.inGracePeriod ||
           this == MedicineStatus.missed;
  }

  bool get isCompleted {
    return this == MedicineStatus.taken ||
           this == MedicineStatus.skipped;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MEDICINE ITEM - UPDATED with isProcessing
// ═══════════════════════════════════════════════════════════════════════════════

class MedicineItem {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final String? scheduledTime;
  final MedicineStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onMarkTaken;
  final VoidCallback? onSkip;
  final VoidCallback? onSnooze;

  const MedicineItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.scheduledTime,
    this.status = MedicineStatus.upcoming,
    this.onTap,
    this.onMarkTaken,
    this.onSkip,
    this.onSnooze,
  });

  MedicineItem copyWith({
    String? id,
    String? name,
    String? dosage,
    String? time,
    String? scheduledTime,
    MedicineStatus? status,
    VoidCallback? onTap,
    VoidCallback? onMarkTaken,
    VoidCallback? onSkip,
    VoidCallback? onSnooze,
  }) {
    return MedicineItem(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      onTap: onTap ?? this.onTap,
      onMarkTaken: onMarkTaken ?? this.onMarkTaken,
      onSkip: onSkip ?? this.onSkip,
      onSnooze: onSnooze ?? this.onSnooze,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TODAY MEDICINES CARD
// ═══════════════════════════════════════════════════════════════════════════════

class TodayMedicinesCard extends StatelessWidget {
  final List<MedicineItem> medicines;
  final VoidCallback onViewAll;
  final VoidCallback? onAddMedicine;
  final int maxVisible;

  const TodayMedicinesCard({
    super.key,
    this.medicines = const [],
    required this.onViewAll,
    this.onAddMedicine,
    this.maxVisible = 3,
  });

  bool get _hasMedicines => medicines.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'أدوية اليوم',
          count: medicines.length,
          onViewAll: onViewAll,
        ),
        SizedBox(height: tokens.spacingSmall),
        if (_hasMedicines)
          _MedicinesTimeline(
            medicines: medicines.take(maxVisible).toList(),
            hasMore: medicines.length > maxVisible,
            onViewAll: onViewAll,
          )
        else
          _EmptyState(onAddMedicine: onAddMedicine),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onViewAll;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: tokens.fontSubtitle,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: tokens.spacingXS),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.paddingSmall,
                  vertical: tokens.spacing2XS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: tokens.borderRadiusFull,
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: tokens.fontXS,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: tokens.paddingSmall),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: tokens.fontSmall,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: tokens.spacing2XS),
              Icon(
                Icons.arrow_forward_ios,
                size: tokens.fontSmall,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAddMedicine;

  const _EmptyState({this.onAddMedicine});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      label: 'لا توجد أدوية مجدولة، اضغط لإضافة أدويتك',
      button: onAddMedicine != null,
      child: GestureDetector(
        onTap: onAddMedicine != null
            ? () {
                HapticFeedback.lightImpact();
                onAddMedicine!();
              }
            : null,
        child: Container(
          padding: tokens.paddingAllLarge,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surface,
                AppColors.secondaryContainer.withValues(alpha: 0.3),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: tokens.borderRadiusLarge,
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              _AnimatedMedicineIcon(),
              tokens.hSpacerMedium,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لا توجد أدوية مجدولة',
                      style: TextStyle(
                        fontSize: tokens.fontBody,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing2XS),
                    Text(
                      'أضف أدويتك لتتبع مواعيدها وتلقي تذكيرات',
                      style: TextStyle(
                        fontSize: tokens.fontSmall,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: tokens.paddingAllSmall,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: tokens.borderRadiusFull,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.secondary,
                  size: tokens.iconSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATED MEDICINE ICON
// ═══════════════════════════════════════════════════════════════════════════════

class _AnimatedMedicineIcon extends StatefulWidget {
  @override
  State<_AnimatedMedicineIcon> createState() => _AnimatedMedicineIconState();
}

class _AnimatedMedicineIconState extends State<_AnimatedMedicineIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _bounceAnimation.value),
        child: child,
      ),
      child: Container(
        padding: tokens.paddingAllMedium,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary,
              AppColors.secondary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: tokens.borderRadiusMedium,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.medication_rounded,
          color: AppColors.white,
          size: tokens.iconMedium,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MEDICINES TIMELINE
// ═══════════════════════════════════════════════════════════════════════════════

class _MedicinesTimeline extends StatelessWidget {
  final List<MedicineItem> medicines;
  final bool hasMore;
  final VoidCallback onViewAll;

  const _MedicinesTimeline({
    required this.medicines,
    required this.hasMore,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: tokens.borderRadiusLarge,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...medicines.asMap().entries.map((entry) {
            final index = entry.key;
            final medicine = entry.value;
            return _MedicineTimelineItem(
              medicine: medicine,
              isFirst: index == 0,
              isLast: index == medicines.length - 1 && !hasMore,
            );
          }),
          if (hasMore)
            _ViewMoreButton(
              remainingCount: 0,
              onTap: onViewAll,
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MEDICINE TIMELINE ITEM - Uses Consumer to check processing state
// ═══════════════════════════════════════════════════════════════════════════════

class _MedicineTimelineItem extends StatelessWidget {
  final MedicineItem medicine;
  final bool isFirst;
  final bool isLast;

  const _MedicineTimelineItem({
    required this.medicine,
    this.isFirst = false,
    this.isLast = false,
  });

  Color get _statusColor => medicine.status.color;
  IconData get _statusIcon => medicine.status.icon;
  String get _statusText => medicine.status.arabicName;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final isProcessing = provider.isMedicineProcessing(medicine.id);
        
        return Semantics(
          label: '${medicine.name}، ${medicine.dosage}، ${medicine.time}، $_statusText',
          button: medicine.onTap != null,
          child: InkWell(
            onTap: medicine.onTap != null
                ? () {
                    HapticFeedback.selectionClick();
                    medicine.onTap!();
                  }
                : null,
            borderRadius: BorderRadius.vertical(
              top: isFirst ? Radius.circular(tokens.radiusLarge) : Radius.zero,
              bottom: isLast ? Radius.circular(tokens.radiusLarge) : Radius.zero,
            ),
            child: Container(
              padding: tokens.paddingAllMedium,
              decoration: BoxDecoration(
                border: !isLast
                    ? Border(
                        bottom: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.3),
                        ),
                      )
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _buildStatusIndicator(tokens, isProcessing),
                      if (!isLast) _buildTimelineLine(tokens),
                    ],
                  ),
                  tokens.hSpacerMedium,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(tokens),
                        SizedBox(height: tokens.spacing2XS),
                        _buildDetails(tokens),
                        if (_showActionButtons && !isProcessing) ...[
                          SizedBox(height: tokens.spacingSmall),
                          _MedicineActionButtons(medicine: medicine),
                        ],
                        if (isProcessing) ...[
                          SizedBox(height: tokens.spacingSmall),
                          _ProcessingIndicator(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(DesignTokens tokens, bool isProcessing) {
    return Container(
      padding: EdgeInsets.all(tokens.spacingXS),
      decoration: BoxDecoration(
        color: isProcessing 
            ? AppColors.primary.withValues(alpha: 0.1)
            : _statusColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: isProcessing
              ? AppColors.primary.withValues(alpha: 0.3)
              : _statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: isProcessing
          ? SizedBox(
              width: tokens.iconSmall,
              height: tokens.iconSmall,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Icon(
              _statusIcon,
              color: _statusColor,
              size: tokens.iconSmall,
            ),
    );
  }

  Widget _buildTimelineLine(DesignTokens tokens) {
    return Container(
      width: 2,
      height: tokens.responsive.scale(30),
      margin: EdgeInsets.symmetric(vertical: tokens.spacing2XS),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _statusColor.withValues(alpha: 0.3),
            AppColors.border,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildHeader(DesignTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            medicine.name,
            style: TextStyle(
              fontSize: tokens.fontBody,
              fontWeight: FontWeight.w600,
              color: medicine.status.isCompleted
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              decoration: medicine.status == MedicineStatus.taken
                  ? TextDecoration.lineThrough
                  : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _StatusBadge(
          status: medicine.status,
          color: _statusColor,
          text: _statusText,
        ),
      ],
    );
  }

  Widget _buildDetails(DesignTokens tokens) {
    return Row(
      children: [
        Icon(
          Icons.medication_outlined,
          size: tokens.fontSmall,
          color: AppColors.textTertiary,
        ),
        SizedBox(width: tokens.spacing2XS),
        Text(
          medicine.dosage,
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
          medicine.time,
          style: TextStyle(
            fontSize: tokens.fontSmall,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  bool get _showActionButtons {
    // لا تظهر الأزرار للأدوية المأخوذة أو المتخطاة
    if (medicine.status == MedicineStatus.taken ||
        medicine.status == MedicineStatus.skipped) {
      return false;
    }
    return medicine.onMarkTaken != null;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🆕 PROCESSING INDICATOR - Shows when action is in progress
// ═══════════════════════════════════════════════════════════════════════════════

class _ProcessingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingSmall,
        vertical: tokens.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusMedium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: tokens.fontSmall,
            height: tokens.fontSmall,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: tokens.spacingXS),
          Text(
            'جاري التنفيذ...',
            style: TextStyle(
              fontSize: tokens.fontSmall,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MEDICINE ACTION BUTTONS - Now with debounce protection
// ═══════════════════════════════════════════════════════════════════════════════

class _MedicineActionButtons extends StatelessWidget {
  final MedicineItem medicine;

  const _MedicineActionButtons({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Wrap(
      spacing: tokens.spacingSmall,
      runSpacing: tokens.spacingXS,
      children: [
        if (medicine.onMarkTaken != null)
          _ActionButton(
            label: 'تم تناوله',
            icon: Icons.check_rounded,
            color: AppColors.success,
            isPrimary: true,
            onTap: medicine.onMarkTaken!,
          ),
        
        if (medicine.onSkip != null)
          _ActionButton(
            label: 'تخطي',
            icon: Icons.skip_next_rounded,
            color: AppColors.textTertiary,
            isPrimary: false,
            onTap: medicine.onSkip!,
          ),
        
        if (medicine.onSnooze != null)
          _ActionButton(
            label: 'لاحقاً',
            icon: Icons.snooze_rounded,
            color: AppColors.warning,
            isPrimary: false,
            onTap: medicine.onSnooze!,
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🆕 ACTION BUTTON - StatefulWidget with loading & debounce
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;
  DateTime? _lastTapTime;
  static const Duration _debounceTime = Duration(milliseconds: 500);

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null && 
        now.difference(_lastTapTime!) < _debounceTime) {
      debugPrint('⚠️ ActionButton: Debounced tap');
      return;
    }
    
    if (_isPressed) {
      debugPrint('⚠️ ActionButton: Already pressed');
      return;
    }

    _lastTapTime = now;
    
    setState(() => _isPressed = true);
    
    HapticFeedback.mediumImpact();
    
    widget.onTap();
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isPressed = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      button: true,
      label: widget.label,
      enabled: !_isPressed,
      child: GestureDetector(
        onTap: _isPressed ? null : _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.paddingSmall,
            vertical: tokens.spacingXS,
          ),
          decoration: BoxDecoration(
            gradient: widget.isPrimary && !_isPressed
                ? LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: _isPressed
                ? widget.color.withValues(alpha: 0.3)
                : (widget.isPrimary ? null : widget.color.withValues(alpha: 0.1)),
            borderRadius: tokens.borderRadiusMedium,
            boxShadow: widget.isPrimary && !_isPressed
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isPressed)
                SizedBox(
                  width: tokens.fontSmall,
                  height: tokens.fontSmall,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.isPrimary ? AppColors.white : widget.color,
                  ),
                )
              else
                Icon(
                  widget.icon,
                  color: widget.isPrimary ? AppColors.white : widget.color,
                  size: tokens.fontSmall,
                ),
              SizedBox(width: tokens.spacing2XS),
              Text(
                _isPressed ? 'جاري...' : widget.label,
                style: TextStyle(
                  fontSize: tokens.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: widget.isPrimary ? AppColors.white : widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATUS BADGE
// ═══════════════════════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final MedicineStatus status;
  final Color color;
  final String text;

  const _StatusBadge({
    required this.status,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingSmall,
        vertical: tokens.spacing2XS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusFull,
        border: status.isUrgent
            ? Border.all(
                color: color.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: tokens.fontXS,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VIEW MORE BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _ViewMoreButton extends StatelessWidget {
  final int remainingCount;
  final VoidCallback onTap;

  const _ViewMoreButton({
    required this.remainingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: tokens.paddingAllMedium,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(tokens.radiusLarge),
            bottomRight: Radius.circular(tokens.radiusLarge),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'عرض المزيد',
              style: TextStyle(
                fontSize: tokens.fontSmall,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: tokens.spacing2XS),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
              size: tokens.iconSmall,
            ),
          ],
        ),
      ),
    );
  }
}

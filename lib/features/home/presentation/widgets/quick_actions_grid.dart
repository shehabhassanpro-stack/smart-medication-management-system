import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onAddReading;
  final VoidCallback onMedicines;
  final VoidCallback onStatistics;
  final VoidCallback onHistory;
  final int? medicinesCount;
  final int? readingsCount;

  const QuickActionsGrid({
    super.key,
    required this.onAddReading,
    required this.onMedicines,
    required this.onStatistics,
    required this.onHistory,
    this.medicinesCount,
    this.readingsCount,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'الإجراءات السريعة'),
        tokens.spacerMedium,
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_rounded,
                label: 'إضافة قراءة',
                subtitle: 'سجّل قراءة جديدة',
                color: AppColors.primary,
                onTap: onAddReading,
              ),
            ),
            SizedBox(width: tokens.spacingSmall),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.medication_rounded,
                label: 'الأدوية',
                subtitle: medicinesCount != null ? '$medicinesCount دواء' : 'إدارة أدويتك',
                color: AppColors.success,
                badge: medicinesCount,
                onTap: onMedicines,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingSmall),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.insights_rounded,
                label: 'الإحصائيات',
                subtitle: 'تحليل بياناتك',
                color: AppColors.info,
                onTap: onStatistics,
              ),
            ),
            SizedBox(width: tokens.spacingSmall),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.history_rounded,
                label: 'السجل',
                subtitle: readingsCount != null ? '$readingsCount قراءة' : 'سجلك الصحي',
                color: AppColors.warning,
                badge: readingsCount,
                onTap: onHistory,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: tokens.fontSubtitle,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: tokens.paddingSmall),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText!,
              style: TextStyle(
                fontSize: tokens.fontSmall,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final int? badge;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      label: '${widget.label}، ${widget.subtitle}',
      button: true,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: tokens.paddingAllMedium,
            decoration: BoxDecoration(
              color: _isPressed
                  ? widget.color.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: tokens.borderRadiusLarge,
              border: Border.all(
                color: _isPressed
                    ? widget.color.withValues(alpha: 0.3)
                    : AppColors.border,
                width: _isPressed ? 1.5 : 1,
              ),
              boxShadow: _isPressed
                  ? []
                  : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _IconContainer(
                      icon: widget.icon,
                      color: widget.color,
                    ),
                    if (widget.badge != null && widget.badge! > 0)
                      _Badge(count: widget.badge!, color: widget.color),
                  ],
                ),
                SizedBox(height: tokens.spacingSmall),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: tokens.fontBody,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: tokens.spacing2XS),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: tokens.fontCaption,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconContainer({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: tokens.paddingAllSmall,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.borderRadiusMedium,
      ),
      child: Icon(
        icon,
        color: color,
        size: tokens.iconMedium,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  final Color color;

  const _Badge({
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingSmall,
        vertical: tokens.spacing2XS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: tokens.borderRadiusFull,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        displayCount,
        style: TextStyle(
          fontSize: tokens.fontXS,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
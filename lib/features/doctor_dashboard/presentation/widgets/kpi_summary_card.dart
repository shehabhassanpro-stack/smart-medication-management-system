import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

/// Glassmorphic KPI summary card for the reports dashboard.
/// Shows icon, value, label, and optional delta/change indicator.
class KpiSummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Widget? trailing; // Optional widget (e.g. mini chart or ring)

  const KpiSummaryCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: tokens.borderRadiusLarge,
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          SizedBox(height: tokens.spacingSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: tokens.fontSmall,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

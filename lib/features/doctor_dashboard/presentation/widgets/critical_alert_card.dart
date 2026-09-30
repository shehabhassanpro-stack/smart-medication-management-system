import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../providers/doctor_reports_provider.dart';

/// Red/orange-tinted card showing a critical patient alert.
/// Tappable to navigate to the patient's detail screen.
class CriticalAlertCard extends StatelessWidget {
  final CriticalAlert alert;
  final VoidCallback? onTap;

  const CriticalAlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isCritical = alert.severity == AlertSeverity.critical;
    final color = isCritical ? AppColors.error : AppColors.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(tokens.paddingMedium),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: tokens.borderRadiusMedium,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            // Severity icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCritical
                    ? Icons.warning_rounded
                    : Icons.info_outline_rounded,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(width: tokens.spacingSmall),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.patientName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: tokens.fontBody,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        alert.type,
                        style: TextStyle(
                          fontSize: tokens.fontSmall,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        alert.value,
                        style: TextStyle(
                          fontSize: tokens.fontSmall,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Time
            if (alert.timestamp != null)
              Text(
                _formatTime(alert.timestamp!),
                style: TextStyle(
                  fontSize: tokens.fontCaption,
                  color: AppColors.textSecondary,
                ),
              ),
            SizedBox(width: tokens.spacingTiny),
            Icon(Icons.chevron_left_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dt.day}/${dt.month}';
  }
}

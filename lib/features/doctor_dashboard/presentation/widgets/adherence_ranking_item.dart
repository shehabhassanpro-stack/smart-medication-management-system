import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../providers/doctor_reports_provider.dart';

/// Compact row showing a patient's adherence rank with progress bar.
class AdherenceRankingItem extends StatelessWidget {
  final PatientAdherence patient;
  final int rank;
  final VoidCallback? onTap;

  const AdherenceRankingItem({
    super.key,
    required this.patient,
    required this.rank,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasData = patient.adherenceRate >= 0;
    final rate = hasData ? patient.adherenceRate : 0.0;
    final color = _getColor(rate, hasData);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.paddingMedium,
          vertical: tokens.paddingSmall + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: tokens.borderRadiusMedium,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            // Rank number
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? AppColors.error : AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(width: tokens.spacingSmall),
            // Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                patient.patientName.isNotEmpty
                    ? patient.patientName[0]
                    : '؟',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(width: tokens.spacingSmall),
            // Name + medicines count
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.patientName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: tokens.fontSmall,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${patient.totalMedicines} دواء',
                    style: TextStyle(
                      fontSize: tokens.fontCaption,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar + percentage
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: hasData ? rate / 100 : 0,
                        backgroundColor: AppColors.border.withValues(alpha: 0.15),
                        color: color,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      hasData ? '${rate.toStringAsFixed(0)}%' : 'غير متوفر',
                      style: TextStyle(
                        fontSize: hasData ? 13 : 9,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(double rate, bool hasData) {
    if (!hasData) return AppColors.textSecondary;
    if (rate >= 80) return AppColors.success;
    if (rate >= 50) return AppColors.warning;
    return AppColors.error;
  }
}

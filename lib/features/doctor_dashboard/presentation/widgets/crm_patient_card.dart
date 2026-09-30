import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

class CrmPatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onTap;
  final VoidCallback onUnlink;

  const CrmPatientCard({
    super.key,
    required this.patient,
    required this.onTap,
    required this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final name = patient['name'] ?? 'مريض بدون اسم';
    final initial = name.isNotEmpty ? name.substring(0, 1) : '?';
    final adherence = patient['adherence'] as int? ?? 100;
    
    // Status colors
    final isWarning = adherence < 70;
    final statusColor = isWarning ? AppColors.error : AppColors.success;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingMedium,
        vertical: tokens.paddingSmall,
      ),
      child: Slidable(
        key: ValueKey(patient['patientId']),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.lightImpact();
                onUnlink();
              },
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              icon: Icons.person_remove_rounded,
              label: 'إلغاء ربط',
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(tokens.radiusMedium), // Arabic Layout
              ),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: tokens.borderRadiusMedium,
          child: Container(
            padding: EdgeInsets.all(tokens.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: tokens.borderRadiusMedium,
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with online/status indicator
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: tokens.responsive.scale(26),
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: tokens.fontHeadline,
                        ),
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: tokens.spacingMedium),
                
                // Patient Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: tokens.fontBody,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: tokens.spacingTiny),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: tokens.spacingTiny),
                          Text(
                            'اخر زيارة: ${patient['lastVisit'] ?? 'مؤخراً'}',
                            style: TextStyle(
                              fontSize: tokens.fontCaption,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.spacingTiny),
                      Row(
                        children: [
                          Icon(
                            Icons.local_phone_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: tokens.spacingTiny),
                          Text(
                            patient['phone']?.isNotEmpty == true 
                                ? patient['phone']! 
                                : 'لا يوجد رقم',
                            style: TextStyle(
                              fontSize: tokens.fontCaption,
                              color: AppColors.textSecondary,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Chevron
                Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

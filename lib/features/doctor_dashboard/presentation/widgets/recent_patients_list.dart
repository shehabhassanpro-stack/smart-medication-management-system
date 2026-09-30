import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

class RecentPatientsList extends StatelessWidget {
  final VoidCallback onViewAll;
  final List<Map<String, dynamic>> patients;

  const RecentPatientsList({
    super.key,
    required this.onViewAll,
    required this.patients,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'أحدث المرضى',
              style: TextStyle(
                fontSize: tokens.fontHeadline,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onViewAll();
              },
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: tokens.fontBody,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        tokens.spacerMedium,
        tokens.spacerMedium,
        if (patients.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(tokens.paddingLarge),
              child: Text(
                'لا يوجد مرضى حالياً. استخدم الماسح الضوئي لربط مريض جديد.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: tokens.fontBody),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patients.length > 3 ? 3 : patients.length,
            separatorBuilder: (context, index) => tokens.spacerMedium,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return _PatientCard(
                name: patient['name'],
                lastVisit: patient['lastVisit'],
                status: patient['status'],
                adherence: patient['adherence'],
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/doctor-patient/${patient['patientId']}');
                },
              );
            },
          ),
      ],
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String name;
  final String lastVisit;
  final String status;
  final int adherence;
  final VoidCallback onTap;

  const _PatientCard({
    required this.name,
    required this.lastVisit,
    required this.status,
    required this.adherence,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isWarning = adherence < 70;

    return InkWell(
      onTap: onTap,
      borderRadius: tokens.borderRadiusMedium,
      child: Container(
        padding: EdgeInsets.all(tokens.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: tokens.borderRadiusMedium,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: tokens.responsive.scale(24),
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
              child: Text(
                name.isNotEmpty ? name.substring(0, 1) : '?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: tokens.fontHeadline,
                ),
              ),
            ),
            SizedBox(width: tokens.spacingMedium),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: tokens.fontBody,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing2XS),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: tokens.iconSmall,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: tokens.spacing2XS),
                      Text(
                        'آخر زيارة: $lastVisit',
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
            
            // Status & Adherence
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.paddingSmall,
                    vertical: tokens.padding2XS,
                  ),
                  decoration: BoxDecoration(
                    color: isWarning 
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    isWarning ? 'عناية' : 'مستقر',
                    style: TextStyle(
                      fontSize: tokens.fontXS,
                      fontWeight: FontWeight.bold,
                      color: isWarning ? AppColors.error : AppColors.success,
                    ),
                  ),
                ),
                SizedBox(height: tokens.spacing2XS),
                Text(
                  'التزام $adherence%',
                  style: TextStyle(
                    fontSize: tokens.fontSmall,
                    color: isWarning ? AppColors.error : AppColors.textSecondary,
                    fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

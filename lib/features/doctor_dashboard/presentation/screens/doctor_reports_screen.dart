import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/config/app_router.dart';
import '../providers/doctor_reports_provider.dart';
import '../widgets/kpi_summary_card.dart';
import '../widgets/critical_alert_card.dart';
import '../widgets/adherence_ranking_item.dart';

class DoctorReportsScreen extends StatelessWidget {
  const DoctorReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DoctorReportsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const _LoadingState();
          }

          if (provider.errorMessage != null) {
            return _ErrorState(
              message: provider.errorMessage!,
              onRetry: provider.refresh,
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, provider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(context.tokens.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period filter
                      _buildPeriodFilter(context, provider),
                      SizedBox(height: context.tokens.spacingLarge),

                      // KPI Grid
                      _buildKpiGrid(context, provider),
                      SizedBox(height: context.tokens.spacingXLarge),

                      // Critical Alerts
                      if (provider.criticalAlerts.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          'تنبيهات حرجة',
                          Icons.warning_amber_rounded,
                          AppColors.error,
                          badge: '${provider.criticalAlerts.length}',
                        ),
                        SizedBox(height: context.tokens.spacingMedium),
                        _buildCriticalAlerts(context, provider),
                        SizedBox(height: context.tokens.spacingXLarge),
                      ],

                      // Adherence Ranking
                      _buildSectionHeader(
                        context,
                        'ترتيب الالتزام الدوائي',
                        Icons.leaderboard_rounded,
                        AppColors.primary,
                      ),
                      SizedBox(height: context.tokens.spacingMedium),
                      _buildAdherenceRanking(context, provider),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── App Bar ───────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, DoctorReportsProvider provider) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'التقارير الطبية',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 20),
              child: Opacity(
                opacity: 0.06,
                child: Icon(Icons.assessment_rounded, size: 100, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            provider.refresh();
          },
          tooltip: 'تحديث',
        ),
      ],
    );
  }

  // ─── Period Filter ────────────────────────────────────────────────
  Widget _buildPeriodFilter(BuildContext context, DoctorReportsProvider provider) {
    final periods = [
      ('7d', '٧ أيام'),
      ('30d', '٣٠ يوم'),
      ('90d', '٩٠ يوم'),
    ];

    return Row(
      children: periods.map((p) {
        final (id, label) = p;
        final isSelected = provider.selectedPeriod == id;

        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              provider.setSelectedPeriod(id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border.withValues(alpha: 0.3),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── KPI Grid ─────────────────────────────────────────────────────
  Widget _buildKpiGrid(BuildContext context, DoctorReportsProvider provider) {
    final adherenceStr = provider.averageAdherence >= 0
        ? '${provider.averageAdherence.toStringAsFixed(0)}%'
        : '--';

    final adherenceColor = provider.averageAdherence >= 80
        ? AppColors.success
        : provider.averageAdherence >= 50
            ? AppColors.warning
            : provider.averageAdherence >= 0
                ? AppColors.error
                : AppColors.textSecondary;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiSummaryCard(
                icon: Icons.people_rounded,
                value: '${provider.totalPatients}',
                label: 'عدد المرضى',
                color: AppColors.info,
              ),
            ),
            SizedBox(width: context.tokens.spacingSmall),
            Expanded(
              child: KpiSummaryCard(
                icon: Icons.medication_rounded,
                value: '${provider.totalActiveMedicines}',
                label: 'وصفة فعّالة',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: context.tokens.spacingSmall),
        Row(
          children: [
            Expanded(
              child: KpiSummaryCard(
                icon: Icons.track_changes_rounded,
                value: adherenceStr,
                label: 'متوسط الالتزام',
                color: adherenceColor,
              ),
            ),
            SizedBox(width: context.tokens.spacingSmall),
            Expanded(
              child: KpiSummaryCard(
                icon: Icons.warning_amber_rounded,
                value: '${provider.criticalAlerts.length}',
                label: 'تنبيه حرج',
                color: provider.criticalAlerts.isNotEmpty
                    ? AppColors.error
                    : AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Section Header ───────────────────────────────────────────────
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    String? badge,
  }) {
    final tokens = context.tokens;
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: tokens.fontHeadline,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Critical Alerts ──────────────────────────────────────────────
  Widget _buildCriticalAlerts(BuildContext context, DoctorReportsProvider provider) {
    return Column(
      children: provider.criticalAlerts.take(5).map((alert) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CriticalAlertCard(
            alert: alert,
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(
                AppRouter.doctorPatientDetail.replaceFirst(':id', alert.patientId),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  // ─── Adherence Ranking ────────────────────────────────────────────
  Widget _buildAdherenceRanking(BuildContext context, DoctorReportsProvider provider) {
    if (provider.adherenceRanking.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: context.tokens.borderRadiusLarge,
        ),
        child: Column(
          children: [
            Icon(Icons.leaderboard_rounded, size: 40,
                color: AppColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text(
              'لا يوجد مرضى مرتبطون',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: provider.adherenceRanking.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final patient = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: AdherenceRankingItem(
            patient: patient,
            rank: rank,
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(
                AppRouter.doctorPatientDetail.replaceFirst(':id', patient.patientId),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

// ─── Loading State ────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جارٍ تحميل التقارير...'),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

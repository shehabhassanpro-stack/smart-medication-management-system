import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../providers/doctor_patient_detail_provider.dart';
import '../widgets/adherence_ring_widget.dart';
import '../widgets/health_chart_widget.dart';
import '../widgets/readings_table_widget.dart';
import '../../../medicines/presentation/widgets/medicine_card.dart';

class DoctorPatientDetailScreen extends StatelessWidget {
  const DoctorPatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DoctorPatientDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(context, provider);
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
                      // 1. Demographics
                      _buildDemographics(context, provider),
                      context.tokens.spacerXLarge,

                      // 2. Adherence Ring
                      _buildSectionHeader(context, 'معدل الالتزام', Icons.track_changes_rounded),
                      context.tokens.spacerMedium,
                      AdherenceRingWidget(adherenceRate: provider.adherenceRate),
                      context.tokens.spacerXLarge,

                      // 3. Health Readings — Type Selector + View Toggle
                      _buildReadingsSection(context, provider),
                      context.tokens.spacerXLarge,

                      // 4. Active Medicines
                      _buildSectionHeader(context, 'الأدوية الحالية', Icons.medication_rounded),
                      context.tokens.spacerMedium,
                      _buildMedicinesList(context, provider),
                      SizedBox(height: context.tokens.responsive.scale(100)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton.extended(
            onPressed: () async {
              HapticFeedback.heavyImpact();
              final provider = context.read<DoctorPatientDetailProvider>();
              final result = await context.pushNamed(
                'doctorAddMedicine',
                pathParameters: {'id': provider.patientId},
              );
              if (result == true && context.mounted) {
                provider.refresh();
              }
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_task_rounded, color: Colors.white),
            label: const Text(
              'وصف دواء',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  // ─── App Bar ───────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, DoctorPatientDetailProvider provider) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          provider.patientName,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
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
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, top: 30),
              child: Opacity(
                opacity: 0.08,
                child: Icon(Icons.person_rounded, size: 120, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────────
  Widget _buildErrorState(BuildContext context, DoctorPatientDetailProvider provider) {
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
              provider.errorMessage!,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: provider.refresh,
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

  // ─── Demographics ─────────────────────────────────────────────────
  Widget _buildDemographics(BuildContext context, DoctorPatientDetailProvider provider) {
    final tokens = context.tokens;
    return Row(
      children: [
        Expanded(child: _buildInfoCard(context, 'العمر', '${provider.age} سنة', Icons.cake_rounded, AppColors.info)),
        SizedBox(width: tokens.spacingSmall),
        Expanded(child: _buildInfoCard(context, 'الدم', provider.bloodType, Icons.bloodtype_rounded, AppColors.error)),
        SizedBox(width: tokens.spacingSmall),
        Expanded(child: _buildInfoCard(context, 'الجنس', provider.genderArabic, Icons.person_rounded, AppColors.primary)),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(vertical: tokens.paddingMedium, horizontal: tokens.paddingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: tokens.borderRadiusMedium,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: tokens.iconMedium),
          SizedBox(height: tokens.spacingTiny),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: tokens.fontCaption),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: tokens.fontBody,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Health Readings Section ──────────────────────────────────────
  Widget _buildReadingsSection(BuildContext context, DoctorPatientDetailProvider provider) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with view toggle
        Row(
          children: [
            Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'القراءات الصحية',
              style: TextStyle(
                fontSize: tokens.fontHeadline,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            // Chart/Table toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton(
                    context,
                    icon: Icons.show_chart_rounded,
                    isActive: !provider.isTableView,
                    onTap: () {
                      if (provider.isTableView) provider.toggleViewMode();
                    },
                  ),
                  _buildToggleButton(
                    context,
                    icon: Icons.table_rows_rounded,
                    isActive: provider.isTableView,
                    onTap: () {
                      if (!provider.isTableView) provider.toggleViewMode();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacingMedium),

        // Type Selector Chips
        _buildTypeSelector(context, provider),
        SizedBox(height: tokens.spacingMedium),

        // Chart or Table
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: provider.isTableView
              ? ReadingsTableWidget(
                  key: ValueKey('table_${provider.selectedReadingType}'),
                  readings: provider.healthReadings,
                  selectedType: provider.selectedReadingType,
                )
              : HealthChartWidget(
                  key: ValueKey('chart_${provider.selectedReadingType}'),
                  readings: provider.healthReadings,
                  selectedType: provider.selectedReadingType,
                ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(BuildContext context, {required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, DoctorPatientDetailProvider provider) {
    final types = [
      ('bloodSugar', 'سكر الدم', Icons.water_drop_rounded, const Color(0xFFEF5B5B)),
      ('bloodPressure', 'ضغط الدم', Icons.favorite_rounded, const Color(0xFF5B8DEF)),
      ('weight', 'الوزن', Icons.monitor_weight_rounded, const Color(0xFF4CAF50)),
      ('temperature', 'الحرارة', Icons.thermostat_rounded, const Color(0xFFFF9800)),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (id, label, icon, color) = types[index];
          final isSelected = provider.selectedReadingType == id;
          final count = provider.healthReadings.where((r) => r['type'] == id).length;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              provider.setSelectedReadingType(id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.15) : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : AppColors.border.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: isSelected ? color : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.2) : AppColors.border.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final tokens = context.tokens;
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: tokens.fontHeadline,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Medicines List ───────────────────────────────────────────────
  Widget _buildMedicinesList(BuildContext context, DoctorPatientDetailProvider provider) {
    if (provider.activeMedicines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: context.tokens.borderRadiusLarge,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.medication_rounded, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text(
              'لا توجد أدوية حالية',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.activeMedicines.length,
      separatorBuilder: (context, index) => context.tokens.spacerMedium,
      itemBuilder: (context, index) {
        final medData = provider.activeMedicines[index];
        return MedicineCard(
          id: medData['id'] ?? '',
          name: medData['name'] ?? '',
          dosage: medData['dosage'] ?? '',
          dosageForm: medData['dosageForm'] ?? 'حبوب',
          times: (medData['times'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          frequency: medData['frequency'] ?? '',
          isActive: medData['isActive'] ?? true,
          isCritical: medData['isCritical'] ?? false,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('وضع العرض فقط للطبيب')),
            );
          },
        );
      },
    );
  }
}

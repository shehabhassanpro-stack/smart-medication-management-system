import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicines_repository.dart';
import '../../medicines_injection.dart';
import '../providers/medicines_provider.dart';
import '../providers/medicine_form_provider.dart';
import '../widgets/medicines_header.dart';
import '../widgets/medicines_search_bar.dart';
import '../widgets/medicines_stats_bar.dart';
import '../widgets/medicines_filter_chips.dart';
import '../widgets/medicine_card.dart';
import '../widgets/medicine_card_shimmer.dart';
import '../widgets/medicines_empty_state.dart';
import '../widgets/medicines_error_state.dart';
import '../widgets/medicine_details_sheet.dart';
import 'add_medicine_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 💊 MEDICINES LIST SCREEN - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Critical Fixes Applied:
// ✓ Fixed Navigation Stack Corruption (Navigator.pop on wrong context)
// ✓ Separated sheet callbacks from direct callbacks
// ✓ Added mounted checks before async operations
// ✓ Connected adherence rate from provider
// ✓ Proper error handling for navigation
//
// ═══════════════════════════════════════════════════════════════════════════════

class MedicinesListScreen extends StatefulWidget {
  const MedicinesListScreen({super.key});

  static const String routeName = '/medicines';

  @override
  State<MedicinesListScreen> createState() => _MedicinesListScreenState();
}

class _MedicinesListScreenState extends State<MedicinesListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabScaleAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;
  MedicineFilterType _selectedFilter = MedicineFilterType.all;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadMedicines();
      }
    });
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!mounted) return;
      final shouldShow = _scrollController.offset < 100;
      if (shouldShow != _showFab) {
        setState(() => _showFab = shouldShow);
        if (_showFab) {
          _fabAnimationController.reverse();
        } else {
          _fabAnimationController.forward();
        }
      }
    });
  }

  Future<void> _loadMedicines() async {
    if (!mounted) return;
    final provider = context.read<MedicinesProvider>();
    await provider.loadMedicines();
  }

  Future<void> _refreshMedicines() async {
    if (!mounted) return;
    final provider = context.read<MedicinesProvider>();
    await provider.refreshMedicines();
  }

  void _onSearchChanged(String query) {
    if (!mounted) return;
    final provider = context.read<MedicinesProvider>();
    provider.setSearchQuery(query);
  }

  void _onFilterChanged(MedicineFilterType filterType) {
    if (!mounted) return;
    setState(() {
      _selectedFilter = filterType;
    });

    final provider = context.read<MedicinesProvider>();
    MedicineFilter filter;
    switch (filterType) {
      case MedicineFilterType.all:
        filter = const MedicineFilter();
        break;
      case MedicineFilterType.active:
        filter = const MedicineFilter(isActive: true);
        break;
      case MedicineFilterType.inactive:
        filter = const MedicineFilter(isActive: false);
        break;
      case MedicineFilterType.critical:
        filter = const MedicineFilter(isCritical: true);
        break;
      case MedicineFilterType.morning:
      case MedicineFilterType.afternoon:
      case MedicineFilterType.evening:
      case MedicineFilterType.night:
        filter = const MedicineFilter();
        break;
    }
    provider.setFilter(filter);
  }

  void _onSortChanged(MedicineSort sort) {
    if (!mounted) return;
    final provider = context.read<MedicinesProvider>();
    provider.setSort(sort);
  }

  void _onMedicineCardTap(MedicineEntity medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: false,
      builder: (sheetContext) => MedicineDetailsSheet(
        id: medicine.id,
        name: medicine.name,
        dosage: medicine.dosage,
        dosageForm: medicine.dosageForm.arabicName,
        times: medicine.times,
        frequency: medicine.frequency.arabicName,
        isActive: medicine.isActive,
        isCritical: medicine.isCritical,
        instructions: medicine.instructions,
        notes: medicine.notes,
        startDate: medicine.startDate,
        endDate: medicine.endDate,
        remainingDays: medicine.remainingDays,
        stockCount: medicine.stockCount,
        onEdit: () {
          // الـ Sheet يغلق نفسه - لا حاجة لـ pop هنا
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) _navigateToEditMedicine(medicine);
          });
        },
        onDelete: () {
          // الـ Sheet يغلق نفسه - لا حاجة لـ pop هنا
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) _showDeleteConfirmation(medicine);
          });
        },
        onToggleActive: () {
          // الـ Sheet يغلق نفسه - لا حاجة لـ pop هنا
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) _toggleMedicineStatus(medicine);
          });
        },
      ),
    );
  }

  void _navigateToAddMedicine() {
    if (!mounted) return;
    final medicinesProvider = context.read<MedicinesProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MedicineFormProvider(
            repository: MedicinesInjection.repository,
            userId: medicinesProvider.userId,
          ),
          child: const AddMedicineScreen(),
        ),
      ),
    ).then((_) {
      if (mounted) _loadMedicines();
    });
  }

  void _navigateToEditMedicine(MedicineEntity medicine) {
    if (!mounted) return;
    final medicinesProvider = context.read<MedicinesProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MedicineFormProvider(
            repository: MedicinesInjection.repository,
            userId: medicinesProvider.userId,
          ),
          child: AddMedicineScreen(medicine: medicine),
        ),
      ),
    ).then((_) {
      if (mounted) _loadMedicines();
    });
  }

  Future<void> _toggleMedicineStatus(MedicineEntity medicine) async {
    if (!mounted) return;
    final provider = context.read<MedicinesProvider>();
    await provider.toggleMedicineStatus(medicine.id, !medicine.isActive);
  }

  Future<void> _showDeleteConfirmation(MedicineEntity medicine) async {
    if (!mounted) return;

    final provider = context.read<MedicinesProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'حذف الدواء',
          style: AppTextStyles.titleMedium,
          textAlign: TextAlign.center,
        ),
        content: Text(
          'هل أنت متأكد من حذف "${medicine.name}"?\nسيتم حذف جميع سجلات الجرعات المرتبطة به.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'الغاء',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'حذف',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      debugPrint('🗑️ Delete confirmed for: ${medicine.name} (${medicine.id})');
      final success = await provider.deleteMedicine(medicine.id);
      debugPrint('🗑️ Delete result: ${success ? "SUCCESS" : "FAILED"}');
    } else {
      debugPrint('🗑️ Delete cancelled or widget unmounted');
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<MedicinesProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: _refreshMedicines,
            color: AppColors.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      MedicinesHeader(
                        totalMedicines: provider.medicinesCount.total,
                        activeMedicines: provider.medicinesCount.active,
                        onSearchTap: () {},
                        onFilterTap: () => _showSortSheet(provider),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MedicinesSearchBar(
                          onChanged: _onSearchChanged,
                          onFilterTap: () => _showSortSheet(provider),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!provider.isLoading && provider.medicines.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: MedicinesStatsBar(
                            totalMedicines: provider.medicinesCount.total,
                            activeMedicines: provider.medicinesCount.active,
                            todayDoses: provider.todaySchedule.length,
                            adherenceRate: provider.adherenceRate,
                          ),
                        ),
                      const SizedBox(height: 8),
                      MedicinesFilterChips(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: _onFilterChanged,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                _buildMedicinesList(provider),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: StreamBuilder<ConnectivityStatus>(
        stream: ConnectivityService.instance.statusStream,
        initialData: ConnectivityService.instance.status,
        builder: (context, snapshot) {
          final isOffline = snapshot.data == ConnectivityStatus.offline;
          
          return ScaleTransition(
            scale: _fabScaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: isOffline
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isOffline ? Colors.grey : AppColors.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: (isOffline ? Colors.grey : AppColors.primary)
                        .withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isOffline 
                      ? () => OfflineBanner.showWriteBlocked() 
                      : _navigateToAddMedicine,
                  borderRadius: BorderRadius.circular(28),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isOffline ? Icons.wifi_off_rounded : Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isOffline ? 'غير متصل' : 'اضافة دواء',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMedicinesList(MedicinesProvider provider) {
    if (provider.isLoading && provider.medicines.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: MedicineCardShimmer(),
            ),
            childCount: 5,
          ),
        ),
      );
    }

    if (provider.hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: MedicinesErrorState(
          description: provider.errorMessage ?? 'حدث خطأ غير متوقع',
          onRetry: _loadMedicines,
        ),
      );
    }

    final filteredMedicines = provider.filteredMedicines;

    if (filteredMedicines.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: MedicinesEmptyState(
          buttonText: 'اضافة دواء',
          onButtonTap: _navigateToAddMedicine,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final medicine = filteredMedicines[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MedicineCard(
                id: medicine.id,
                name: medicine.name,
                dosage: medicine.dosage,
                dosageForm: medicine.dosageForm.arabicName,
                times: medicine.times,
                frequency: medicine.frequency.arabicName,
                isActive: medicine.isActive,
                isCritical: medicine.isCritical,
                onTap: () => _onMedicineCardTap(medicine),
                onEdit: () => _navigateToEditMedicine(medicine),
                onDelete: () => _showDeleteConfirmation(medicine),
                onToggleActive: () => _toggleMedicineStatus(medicine),
              ),
            );
          },
          childCount: filteredMedicines.length,
        ),
      ),
    );
  }

  void _showSortSheet(MedicinesProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ترتيب حسب',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildSortOption(
              sheetContext,
              provider,
              MedicineSort.createdAtDesc,
              'الاحدث اولا',
              Icons.access_time_rounded,
            ),
            _buildSortOption(
              sheetContext,
              provider,
              MedicineSort.createdAtAsc,
              'الاقدم اولا',
              Icons.history_rounded,
            ),
            _buildSortOption(
              sheetContext,
              provider,
              MedicineSort.nameAsc,
              'الاسم (أ - ي)',
              Icons.sort_by_alpha_rounded,
            ),
            _buildSortOption(
              sheetContext,
              provider,
              MedicineSort.nameDesc,
              'الاسم (ي - أ)',
              Icons.sort_by_alpha_rounded,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext sheetContext,
    MedicinesProvider provider,
    MedicineSort sort,
    String label,
    IconData icon,
  ) {
    final isSelected = provider.currentSort == sort;
    return ListTile(
      onTap: () {
        Navigator.of(sheetContext).pop();
        _onSortChanged(sort);
      },
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
    );
  }
}

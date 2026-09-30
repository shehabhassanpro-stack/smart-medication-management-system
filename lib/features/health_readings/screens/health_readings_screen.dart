import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../../models/health/health_exports.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/widgets/offline_banner.dart';
import '../controllers/health_readings_controller.dart';
import '../utils/health_readings_utils.dart';
import '../widgets/list/health_header.dart';
import '../widgets/list/health_statistics_card.dart';
import '../widgets/list/health_chart.dart';
import '../widgets/list/health_reading_item.dart';
import '../widgets/list/health_reading_details_sheet.dart';
import '../widgets/common/health_period_selector.dart';
import '../widgets/common/health_type_tabs.dart';
import 'health_add_reading_screen.dart';

class HealthReadingsScreen extends StatefulWidget {
  const HealthReadingsScreen({super.key});

  @override
  State<HealthReadingsScreen> createState() => _HealthReadingsScreenState();
}

class _HealthReadingsScreenState extends State<HealthReadingsScreen>
    with TickerProviderStateMixin {
  late final HealthReadingsController _controller;
  late final TabController _tabController;
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = HealthReadingsController();
    _tabController = TabController(length: ReadingType.values.length, vsync: this);
    _searchController = TextEditingController();
    _scrollController = ScrollController();

    _setupAnimations();
    _setupListeners();
    _controller.init();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  void _setupListeners() {
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final type = ReadingType.values[_tabController.index];
      _controller.setSelectedType(type);
      _scaleController.forward(from: 0);
      _slideController.forward(from: 0);
    }
  }

  void _onSearchChanged() {
    _controller.setSearchQuery(_searchController.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              HealthHeader(
                isSearching: _controller.isSearching,
                searchController: _searchController,
                onSearchToggle: _controller.toggleSearch,
                onExport: _exportData,
              ),
              HealthPeriodSelector(
                selectedPeriod: _controller.selectedPeriod,
                onPeriodChanged: _controller.setSelectedPeriod,
              ),
              HealthTypeTabs(
                tabController: _tabController,
              ),
              Expanded(child: _buildTabView()),
              _buildBottomActionBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabView() {
    if (!_controller.isAuthenticated) {
      return HealthStateWidgets.buildAuthRequiredState();
    }

    return TabBarView(
      controller: _tabController,
      children: ReadingType.values.map((type) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildReadingsContent(type),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReadingsContent(ReadingType type) {
    if (_controller.isLoading) {
      return HealthStateWidgets.buildLoadingState(color: type.color);
    }

    if (_controller.hasError) {
      return HealthStateWidgets.buildErrorState(
        _controller.errorMessage ?? 'حدث خطأ',
        onRetry: _controller.refresh,
      );
    }

    if (_controller.isEmpty) {
      return HealthStateWidgets.buildEmptyState(
        type: type,
        onAdd: () => _addReading(type),
      );
    }

    final readings = _controller.readings;

    if (readings.isEmpty && _controller.searchQuery.isNotEmpty) {
      return HealthStateWidgets.buildNoResultsState();
    }

    return RefreshIndicator(
      onRefresh: () async => _controller.refresh(),
      color: type.color,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          HealthStatisticsCard(
            readings: readings,
            type: type,
            selectedPeriod: _controller.selectedPeriod,
          ),
          const SizedBox(height: 16),
          HealthChart(
            readings: readings,
            type: type,
            selectedPeriod: _controller.selectedPeriod,
          ),
          const SizedBox(height: 16),
          _buildReadingsHeader(readings.length),
          const SizedBox(height: 12),
          // ✅ تمرير userHeight للـ HealthReadingItem
          ...readings.map((reading) => HealthReadingItem(
            reading: reading,
            userHeight: _controller.userHeight,  // ← هنا التغيير
            onTap: () => _showReadingDetails(reading),
            onDelete: () => _confirmDeleteReading(reading),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildReadingsHeader(int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'السجل',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    final type = _controller.selectedType;
    final color = type.color;

    return StreamBuilder<ConnectivityStatus>(
      stream: ConnectivityService.instance.statusStream,
      initialData: ConnectivityService.instance.status,
      builder: (context, snapshot) {
        final isOffline = snapshot.data == ConnectivityStatus.offline;
        final activeColor = isOffline ? Colors.grey.shade500 : color;

        return Container(
          padding: EdgeInsets.fromLTRB(
            16, 12, 16,
            MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom
                : 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isOffline 
                  ? () => OfflineBanner.showWriteBlocked() 
                  : () => _addReading(type),
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activeColor,
                      activeColor.withValues(alpha: 0.85),
                      _adjustColor(activeColor, 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(type.emoji, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOffline ? 'غير متصل' : 'إضافة قراءة جديدة',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isOffline ? 'وضع القراءة فقط' : type.nameAr,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isOffline ? Icons.wifi_off_rounded : Icons.add_rounded, 
                          color: activeColor, 
                          size: 28,
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
    );
  }

  Color _adjustColor(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0)).toColor();
  }

  void _showReadingDetails(HealthReading reading) {
    HealthReadingDetailsSheet.show(
      context,
      reading: reading,
      userHeight: _controller.userHeight,  // ← تمرير الطول لعرض BMI في التفاصيل
      onDelete: () => _confirmDeleteReading(reading),
    );
  }

  void _addReading(ReadingType type) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthAddReadingScreen(initialType: type),
      ),
    );
  }

  void _confirmDeleteReading(HealthReading reading) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('حذف القراءة'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذه القراءة؟\nلا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReading(reading);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReading(HealthReading reading) async {
    if (!_controller.canDeleteReading()) {
      final remaining = _controller.getRemainingDeleteActions();
      SnackBarHelper.showWarning(
        context,
        'لقد تجاوزت الحد الأقصى للحذف. المتبقي: $remaining',
      );
      return;
    }

    final success = await _controller.deleteReading(reading);

    if (mounted) {
      if (success) {
        SnackBarHelper.showSuccess(context, 'تم حذف القراءة بنجاح');
      } else {
        SnackBarHelper.showError(
          context,
          _controller.errorMessage ?? 'حدث خطأ أثناء الحذف',
        );
      }
    }
  }

  void _exportData() {
    HapticFeedback.lightImpact();
    SnackBarHelper.showInfo(context, 'ميزة التصدير قريباً');
  }
}

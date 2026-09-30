import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../providers/doctor_patients_provider.dart';
import '../widgets/crm_patient_card.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (mounted) {
      context.read<DoctorPatientsProvider>().setSearchQuery(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DoctorPatientsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.hasError) {
            return Center(
              child: Text(
                provider.errorMessage ?? 'حدث خطأ غير متوقع',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final patients = provider.filteredPatients;

          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: AppColors.white,
            backgroundColor: AppColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(context),
                if (patients.isEmpty)
                  _buildEmptyState(context, provider.searchQuery.isNotEmpty)
                else
                  _buildPatientsList(context, patients, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final tokens = context.tokens;
    // We combine the App bar and the search bar into one beautiful curved header
    return SliverPersistentHeader(
      pinned: true,
      delegate: _CurvedHeaderWithSearchDelegate(
        minHeight: 110 + MediaQuery.of(context).padding.top,
        maxHeight: 160 + MediaQuery.of(context).padding.top,
        controller: _searchController,
        onClearChanged: () {
          _searchController.clear();
          context.read<DoctorPatientsProvider>().setSearchQuery('');
        },
        tokens: tokens,
      ),
    );
  }

  // We no longer need a separate _buildSearchBar method as it is integrated into the header.

  Widget _buildEmptyState(BuildContext context, bool isSearching) {
    final tokens = context.tokens;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSearching ? Icons.search_off_rounded : Icons.person_add_disabled_rounded,
                size: 80,
                color: AppColors.primaryLight.withValues(alpha: 0.5),
              ),
              tokens.spacerLarge,
              Text(
                isSearching ? 'لم نجد مرضى بهذا الاسم' : 'لا يوجد مرضى حالياً',
                style: TextStyle(
                  fontSize: tokens.fontHeadline,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              tokens.spacerSmall,
              Text(
                isSearching
                    ? 'جرب البحث بكلمات أخرى'
                    : 'استخدم أيقونة المسح الضوئي أعلى القائمة الرئيسية لربط مريض جديد.',
                style: TextStyle(
                  fontSize: tokens.fontBody,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientsList(
    BuildContext context,
    List<Map<String, dynamic>> patients,
    DoctorPatientsProvider provider,
  ) {
    final tokens = context.tokens;
    return SliverPadding(
      padding: EdgeInsets.only(
        top: tokens.paddingLarge, // Added space because search bar floats down 
        bottom: tokens.paddingXLarge * 2,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final patient = patients[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: CrmPatientCard(
                    patient: patient,
                    onTap: () => context.push('/doctor-patient/${patient['patientId']}'),
                    onUnlink: () async {
                      // M2 Fix: Show confirmation dialog before destructive action
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: tokens.borderRadiusLarge,
                          ),
                          icon: Icon(Icons.person_remove_rounded, color: AppColors.error, size: 40),
                          title: const Text(
                            '\u0625\u0644\u063a\u0627\u0621 \u0627\u0631\u062a\u0628\u0627\u0637 \u0627\u0644\u0645\u0631\u064a\u0636',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            '\u0647\u0644 \u0623\u0646\u062a \u0645\u062a\u0623\u0643\u062f \u0645\u0646 \u0625\u0644\u063a\u0627\u0621 \u0627\u0631\u062a\u0628\u0627\u0637 "${patient['name'] ?? '\u0627\u0644\u0645\u0631\u064a\u0636'}"?\n\u064a\u0645\u0643\u0646\u0643 \u0625\u0639\u0627\u062f\u0629 \u0631\u0628\u0637\u0647 \u0644\u0627\u062d\u0642\u0627\u064b \u0639\u0628\u0631 \u0645\u0633\u062d \u0643\u0648\u062f QR.',
                            textAlign: TextAlign.center,
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('\u062a\u0631\u0627\u062c\u0639', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              child: const Text('\u0625\u0644\u063a\u0627\u0621 \u0627\u0644\u0627\u0631\u062a\u0628\u0627\u0637', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true || !context.mounted) return;

                      final (success, message) = await provider.unlinkPatient(patient['patientId']);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: success ? AppColors.success : AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(tokens.paddingMedium),
                            shape: RoundedRectangleBorder(
                              borderRadius: tokens.borderRadiusMedium,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          },
          childCount: patients.length,
        ),
      ),
    );
  }
}

class _CurvedHeaderWithSearchDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final TextEditingController controller;
  final VoidCallback onClearChanged;
  final DesignTokens tokens;

  _CurvedHeaderWithSearchDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.controller,
    required this.onClearChanged,
    required this.tokens,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate the normalized scroll progress (0.0 to 1.0)
    final double progress = shrinkOffset / (maxExtent - minExtent);
    final double clampedProgress = progress.clamp(0.0, 1.0);
    
    // We want the search bar to move up slightly and the bottom curve to flatten
    final double curveRadius = (1 - clampedProgress) * 40;
    
    // The search bar margin pushes it to float halfway between the gradient and the background
    final double searchBarTopMargin = maxHeight - shrinkOffset - 30;

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        // 1. The curved gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(curveRadius),
              bottomRight: Radius.circular(curveRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3 * (1 - clampedProgress)),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        
        // 1.5 Parallax Medical Watermark
        Positioned(
          top: -20 - (shrinkOffset * 0.6),
          left: -30,
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              Icons.monitor_heart_rounded,
              size: 180,
              color: AppColors.white.withValues(alpha: 0.1 * (1 - clampedProgress)),
            ),
          ),
        ),
        
        // 2. The title and icon
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: tokens.paddingLarge,
          right: tokens.paddingLarge,
          child: AnimatedOpacity(
            opacity: 1 - clampedProgress,
            duration: const Duration(milliseconds: 100),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(tokens.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.diversity_1_rounded,
                      color: AppColors.white,
                      size: tokens.iconMedium,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spacingMedium),
                Text(
                  'مرضاك',
                  style: TextStyle(
                    fontSize: tokens.fontTitle,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 3. The floating search bar
        Positioned(
          top: searchBarTopMargin.clamp(
            MediaQuery.of(context).padding.top + 10, // Stop going up here
            maxHeight - 30, // Start from here
          ),
          left: tokens.paddingLarge,
          right: tokens.paddingLarge,
          child: Container(
            height: 55, // Sleeker search bar
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                const Icon(Icons.search_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(
                      fontSize: tokens.fontBody,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم، أو الرقم...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontSize: tokens.fontBody,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                    onPressed: onClearChanged,
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_CurvedHeaderWithSearchDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        controller.text != oldDelegate.controller.text;
  }
}

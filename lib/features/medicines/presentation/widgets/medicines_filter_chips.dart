import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/design_tokens.dart';

enum MedicineFilterType {
  all,
  active,
  inactive,
  critical,
  morning,
  afternoon,
  evening,
  night,
}

extension MedicineFilterTypeExtension on MedicineFilterType {
  String get label {
    switch (this) {
      case MedicineFilterType.all:
        return 'الكل';
      case MedicineFilterType.active:
        return 'نشط';
      case MedicineFilterType.inactive:
        return 'متوقف';
      case MedicineFilterType.critical:
        return 'مهم';
      case MedicineFilterType.morning:
        return 'صباحاً';
      case MedicineFilterType.afternoon:
        return 'ظهراً';
      case MedicineFilterType.evening:
        return 'مساءً';
      case MedicineFilterType.night:
        return 'ليلاً';
    }
  }

  IconData get icon {
    switch (this) {
      case MedicineFilterType.all:
        return Icons.grid_view_rounded;
      case MedicineFilterType.active:
        return Icons.check_circle_outline_rounded;
      case MedicineFilterType.inactive:
        return Icons.pause_circle_outline_rounded;
      case MedicineFilterType.critical:
        return Icons.priority_high_rounded;
      case MedicineFilterType.morning:
        return Icons.wb_sunny_outlined;
      case MedicineFilterType.afternoon:
        return Icons.wb_sunny_rounded;
      case MedicineFilterType.evening:
        return Icons.wb_twilight_rounded;
      case MedicineFilterType.night:
        return Icons.nights_stay_outlined;
    }
  }

  Color get color {
    switch (this) {
      case MedicineFilterType.all:
        return AppColors.primary;
      case MedicineFilterType.active:
        return AppColors.success;
      case MedicineFilterType.inactive:
        return AppColors.textSecondary;
      case MedicineFilterType.critical:
        return AppColors.error;
      case MedicineFilterType.morning:
        return AppColors.warning;
      case MedicineFilterType.afternoon:
        return AppColors.accent;
      case MedicineFilterType.evening:
        return AppColors.info;
      case MedicineFilterType.night:
        return AppColors.primaryDark;
    }
  }
}

class MedicinesFilterChips extends StatelessWidget {
  final MedicineFilterType selectedFilter;
  final ValueChanged<MedicineFilterType> onFilterChanged;
  final List<MedicineFilterType> availableFilters;
  final Map<MedicineFilterType, int>? filterCounts;
  final bool showIcons;
  final bool showCounts;

  const MedicinesFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.availableFilters = const [
      MedicineFilterType.all,
      MedicineFilterType.active,
      MedicineFilterType.inactive,
      MedicineFilterType.critical,
    ],
    this.filterCounts,
    this.showIcons = true,
    this.showCounts = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SizedBox(
      height: tokens.responsive.scale(44),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: tokens.paddingLG),
        itemCount: availableFilters.length,
        separatorBuilder: (_, __) => SizedBox(width: tokens.spacingSM),
        itemBuilder: (context, index) {
          final filter = availableFilters[index];
          final isSelected = filter == selectedFilter;
          final count = filterCounts?[filter];

          return _FilterChip(
            filter: filter,
            isSelected: isSelected,
            count: showCounts ? count : null,
            showIcon: showIcons,
            onTap: () {
              HapticFeedback.lightImpact();
              onFilterChanged(filter);
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final MedicineFilterType filter;
  final bool isSelected;
  final int? count;
  final bool showIcon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.isSelected,
    this.count,
    this.showIcon = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = filter.color;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'فلتر ${filter.label}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: tokens.paddingMD,
            vertical: tokens.paddingSM,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surface,
            borderRadius: tokens.borderRadiusFull,
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected ? AppShadows.sm : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(
                  filter.icon,
                  color: isSelected ? AppColors.white : color,
                  size: tokens.iconSM,
                ),
                SizedBox(width: tokens.spacingXS),
              ],
              Text(
                filter.label,
                style: TextStyle(
                  fontSize: tokens.fontSM,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              if (count != null) ...[
                SizedBox(width: tokens.spacingXS),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.paddingXS,
                    vertical: tokens.padding2XS,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.white.withValues(alpha: 0.2)
                        : color.withValues(alpha: 0.1),
                    borderRadius: tokens.borderRadiusSM,
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: tokens.fontXS,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MedicinesTimeFilterChips extends StatelessWidget {
  final MedicineFilterType selectedFilter;
  final ValueChanged<MedicineFilterType> onFilterChanged;
  final Map<MedicineFilterType, int>? filterCounts;

  const MedicinesTimeFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.filterCounts,
  });

  @override
  Widget build(BuildContext context) {
    return MedicinesFilterChips(
      selectedFilter: selectedFilter,
      onFilterChanged: onFilterChanged,
      availableFilters: const [
        MedicineFilterType.all,
        MedicineFilterType.morning,
        MedicineFilterType.afternoon,
        MedicineFilterType.evening,
        MedicineFilterType.night,
      ],
      filterCounts: filterCounts,
      showIcons: true,
      showCounts: true,
    );
  }
}

class MedicinesSortChips extends StatelessWidget {
  final MedicineSortType selectedSort;
  final ValueChanged<MedicineSortType> onSortChanged;

  const MedicinesSortChips({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SizedBox(
      height: tokens.responsive.scale(40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: tokens.paddingLG),
        itemCount: MedicineSortType.values.length,
        separatorBuilder: (_, __) => SizedBox(width: tokens.spacingSM),
        itemBuilder: (context, index) {
          final sort = MedicineSortType.values[index];
          final isSelected = sort == selectedSort;

          return _SortChip(
            sort: sort,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              onSortChanged(sort);
            },
          );
        },
      ),
    );
  }
}

enum MedicineSortType {
  nameAsc,
  nameDesc,
  dateAsc,
  dateDesc,
  timeAsc,
}

extension MedicineSortTypeExtension on MedicineSortType {
  String get label {
    switch (this) {
      case MedicineSortType.nameAsc:
        return 'الاسم أ-ي';
      case MedicineSortType.nameDesc:
        return 'الاسم ي-أ';
      case MedicineSortType.dateAsc:
        return 'الأقدم';
      case MedicineSortType.dateDesc:
        return 'الأحدث';
      case MedicineSortType.timeAsc:
        return 'الوقت';
    }
  }

  IconData get icon {
    switch (this) {
      case MedicineSortType.nameAsc:
        return Icons.sort_by_alpha_rounded;
      case MedicineSortType.nameDesc:
        return Icons.sort_by_alpha_rounded;
      case MedicineSortType.dateAsc:
        return Icons.arrow_upward_rounded;
      case MedicineSortType.dateDesc:
        return Icons.arrow_downward_rounded;
      case MedicineSortType.timeAsc:
        return Icons.schedule_rounded;
    }
  }
}

class _SortChip extends StatelessWidget {
  final MedicineSortType sort;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.sort,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'ترتيب ${sort.label}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: tokens.paddingSM,
            vertical: tokens.paddingXS,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: tokens.borderRadiusSM,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                sort.icon,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                size: tokens.iconXS,
              ),
              SizedBox(width: tokens.spacing2XS),
              Text(
                sort.label,
                style: TextStyle(
                  fontSize: tokens.fontXS,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
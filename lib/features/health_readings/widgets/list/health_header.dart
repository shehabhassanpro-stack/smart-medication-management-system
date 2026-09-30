import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/app_text_styles.dart';

class HealthHeader extends StatelessWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final VoidCallback onExport;

  const HealthHeader({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onSearchToggle,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 12 : 16,
        topPadding + (isSmallScreen ? 12 : 16),
        isSmallScreen ? 12 : 16,
        isSmallScreen ? 16 : 20,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: AppShadows.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildTitle(isSmallScreen)),
              _buildActions(isSmallScreen),
            ],
          ),
          if (isSearching) ...[
            const SizedBox(height: 16),
            _buildSearchField(),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.monitor_heart_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'القراءات الصحية',
                style: (isSmallScreen ? AppTextStyles.titleLarge : AppTextStyles.h3).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'تتبع صحتك يومياً',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          icon: isSearching ? Icons.close_rounded : Icons.search_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            onSearchToggle();
          },
        ),
        SizedBox(width: isSmallScreen ? 4 : 8),
        _buildIconButton(
          icon: Icons.file_download_rounded,
          onTap: onExport,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'ابحث عن القراءات...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: Colors.white),
                onPressed: () => searchController.clear(),
              )
            : null,
      ),
    );
  }
}

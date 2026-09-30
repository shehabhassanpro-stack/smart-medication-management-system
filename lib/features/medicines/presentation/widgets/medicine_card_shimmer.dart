import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

class MedicineCardShimmer extends StatefulWidget {
  const MedicineCardShimmer({super.key});

  @override
  State<MedicineCardShimmer> createState() => _MedicineCardShimmerState();
}

class _MedicineCardShimmerState extends State<MedicineCardShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: tokens.paddingAllMD,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: tokens.borderRadiusLG,
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(tokens),
              SizedBox(height: tokens.spacingSM),
              _buildDosageInfo(tokens),
              SizedBox(height: tokens.spacingSM),
              _buildTimesRow(tokens),
              SizedBox(height: tokens.spacingSM),
              _buildProgressSection(tokens),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(DesignTokens tokens) {
    return Row(
      children: [
        _ShimmerBox(
          width: tokens.responsive.scale(48),
          height: tokens.responsive.scale(48),
          borderRadius: tokens.borderRadiusMD,
          animation: _animation,
        ),
        SizedBox(width: tokens.spacingSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(
                width: tokens.responsive.scale(140),
                height: tokens.responsive.scale(18),
                borderRadius: tokens.borderRadiusSM,
                animation: _animation,
              ),
              SizedBox(height: tokens.spacingXS),
              _ShimmerBox(
                width: tokens.responsive.scale(100),
                height: tokens.responsive.scale(14),
                borderRadius: tokens.borderRadiusSM,
                animation: _animation,
              ),
            ],
          ),
        ),
        _ShimmerBox(
          width: tokens.responsive.scale(50),
          height: tokens.responsive.scale(28),
          borderRadius: tokens.borderRadiusSM,
          animation: _animation,
        ),
      ],
    );
  }

  Widget _buildDosageInfo(DesignTokens tokens) {
    return _ShimmerBox(
      width: tokens.responsive.scale(120),
      height: tokens.responsive.scale(32),
      borderRadius: tokens.borderRadiusSM,
      animation: _animation,
    );
  }

  Widget _buildTimesRow(DesignTokens tokens) {
    return Row(
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(
            left: index < 2 ? tokens.spacingXS : 0,
          ),
          child: _ShimmerBox(
            width: tokens.responsive.scale(70),
            height: tokens.responsive.scale(32),
            borderRadius: tokens.borderRadiusSM,
            animation: _animation,
          ),
        );
      }),
    );
  }

  Widget _buildProgressSection(DesignTokens tokens) {
    return Container(
      padding: tokens.paddingAllSM,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: tokens.borderRadiusSM,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  width: tokens.responsive.scale(80),
                  height: tokens.responsive.scale(12),
                  borderRadius: tokens.borderRadiusXS,
                  animation: _animation,
                ),
                SizedBox(height: tokens.spacingXS),
                _ShimmerBox(
                  width: double.infinity,
                  height: tokens.responsive.scale(4),
                  borderRadius: tokens.borderRadiusXS,
                  animation: _animation,
                ),
              ],
            ),
          ),
          SizedBox(width: tokens.spacingMD),
          _ShimmerBox(
            width: tokens.responsive.scale(60),
            height: tokens.responsive.scale(36),
            borderRadius: tokens.borderRadiusSM,
            animation: _animation,
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Animation<double> animation;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment(animation.value - 1, 0),
          end: Alignment(animation.value + 1, 0),
          colors: [
            AppColors.border.withValues(alpha: 0.3),
            AppColors.border.withValues(alpha: 0.6),
            AppColors.border.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class MedicineCardShimmerList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const MedicineCardShimmerList({
    super.key,
    this.itemCount = 5,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ListView.separated(
      padding: padding ?? EdgeInsets.all(tokens.paddingLG),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: tokens.spacingMD),
      itemBuilder: (_, __) => const MedicineCardShimmer(),
    );
  }
}

class MedicineCardShimmerSliver extends StatelessWidget {
  final int itemCount;

  const MedicineCardShimmerSliver({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SliverPadding(
      padding: EdgeInsets.all(tokens.paddingLG),
      sliver: SliverList.separated(
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: tokens.spacingMD),
        itemBuilder: (_, __) => const MedicineCardShimmer(),
      ),
    );
  }
}
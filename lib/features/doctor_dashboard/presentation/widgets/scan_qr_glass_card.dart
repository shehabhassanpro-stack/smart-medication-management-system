import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

class ScanQrGlassCard extends StatefulWidget {
  final VoidCallback onTap;

  const ScanQrGlassCard({super.key, required this.onTap});

  @override
  State<ScanQrGlassCard> createState() => _ScanQrGlassCardState();
}

class _ScanQrGlassCardState extends State<ScanQrGlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(tokens.paddingLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: tokens.borderRadiusLarge,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative background icon
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: tokens.responsive.scale(120),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: tokens.paddingAllMedium,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: tokens.borderRadiusMedium,
                    ),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: tokens.iconLarge,
                    ),
                  ),
                  tokens.spacerMedium,
                  Text(
                    'مسح كود المريض',
                    style: TextStyle(
                      fontSize: tokens.fontHeadline,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  tokens.spacer2XS,
                  Text(
                    'للوصول لسجل المريض وربطه بعيادتك',
                    style: TextStyle(
                      fontSize: tokens.fontBody,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

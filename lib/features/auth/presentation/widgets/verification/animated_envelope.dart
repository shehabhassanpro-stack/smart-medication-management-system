import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/design_tokens.dart';

class AnimatedEnvelope extends StatelessWidget {
  final AnimationController envelopeController;
  final AnimationController pulseController;
  final AnimationController particleController;
  final AnimationController successController;
  final AnimationController checkController;
  final Animation<double> envelopeFloat;
  final Animation<double> envelopeRotate;
  final Animation<double> pulseAnimation;
  final Animation<double> checkScale;
  final Animation<double> successScale;
  final bool isVerified;

  const AnimatedEnvelope({
    super.key,
    required this.envelopeController,
    required this.pulseController,
    required this.particleController,
    required this.successController,
    required this.checkController,
    required this.envelopeFloat,
    required this.envelopeRotate,
    required this.pulseAnimation,
    required this.checkScale,
    required this.successScale,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AnimatedBuilder(
      animation: Listenable.merge([envelopeController, pulseController, particleController]),
      builder: (context, child) {
        return SizedBox(
          height: tokens.responsive.scale(200),
          width: tokens.responsive.scale(200),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ..._buildParticles(tokens),
              _buildPulseCircles(tokens),
              Transform.translate(
                offset: Offset(0, envelopeFloat.value),
                child: Transform.rotate(
                  angle: envelopeRotate.value,
                  child: isVerified
                      ? _buildVerifiedIcon(tokens)
                      : _buildEnvelopeIcon(tokens),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildParticles(DesignTokens tokens) {
    const particleCount = 8;
    return List.generate(particleCount, (index) {
      final angle = (index / particleCount) * 2 * math.pi;
      final progress = (particleController.value + index / particleCount) % 1.0;
      final radius = tokens.responsive.scale(70) + (progress * tokens.responsive.scale(30));
      final opacity = (1.0 - progress).clamp(0.0, 0.6);
      final size = tokens.responsive.scale(8) * (1.0 - progress * 0.5);

      return Positioned(
        left: tokens.responsive.scale(100) + math.cos(angle + progress * 2) * radius - size / 2,
        top: tokens.responsive.scale(100) + math.sin(angle + progress * 2) * radius - size / 2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  Widget _buildPulseCircles(DesignTokens tokens) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.scale(
          scale: pulseAnimation.value * 1.3,
          child: Container(
            width: tokens.responsive.scale(140),
            height: tokens.responsive.scale(140),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ),
        ),
        Transform.scale(
          scale: pulseAnimation.value * 1.15,
          child: Container(
            width: tokens.responsive.scale(120),
            height: tokens.responsive.scale(120),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        Transform.scale(
          scale: pulseAnimation.value,
          child: Container(
            width: tokens.responsive.scale(100),
            height: tokens.responsive.scale(100),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primaryDark.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnvelopeIcon(DesignTokens tokens) {
    return Container(
      width: tokens.responsive.scale(80),
      height: tokens.responsive.scale(80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: tokens.borderRadiusXL,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.mark_email_unread_rounded,
        color: Colors.white,
        size: tokens.responsive.scale(40),
      ),
    );
  }

  Widget _buildVerifiedIcon(DesignTokens tokens) {
    return AnimatedBuilder(
      animation: successController,
      builder: (context, child) {
        return Transform.scale(
          scale: successScale.value,
          child: Container(
            width: tokens.responsive.scale(80),
            height: tokens.responsive.scale(80),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
              ),
              borderRadius: tokens.borderRadiusXL,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: checkController,
              builder: (context, child) {
                return Transform.scale(
                  scale: checkScale.value,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: tokens.responsive.scale(44),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

import '../../../../../core/app_theme.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Medical Care',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'نظام إدارة السجلات الصحية',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class InitializingScreen extends StatelessWidget {
  final bool biometricAvailable;
  final bool hasSavedCredentials;

  const InitializingScreen({
    super.key,
    this.biometricAvailable = false,
    this.hasSavedCredentials = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('initializing_screen'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 60,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Medical Care',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جاري التحضير...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value < 0.9 ? null : value,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildInitStatusIndicators(),
        ],
      ),
    );
  }

  Widget _buildInitStatusIndicators() {
    return Column(
      children: [
        _buildStatusRow(
          icon: Icons.security_rounded,
          label: 'فحص الأمان',
          isComplete: true,
        ),
        const SizedBox(height: 8),
        _buildStatusRow(
          icon: Icons.person_rounded,
          label: 'تحميل البيانات',
          isComplete: true,
        ),
      ],
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required bool isComplete,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isComplete ? Icons.check_circle_rounded : icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

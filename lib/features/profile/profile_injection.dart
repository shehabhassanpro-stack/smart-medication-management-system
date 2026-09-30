import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/screens/profile_screen.dart';

class ProfileInjection {
  ProfileInjection._();

  static Widget buildProfileScreen(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const _ProfileLoadingWidget();
        }

        final userId = authProvider.userId;

        if (userId == null || userId.isEmpty) {
          if (authProvider.firebaseUser != null) {
            return const _ProfileLoadingWidget();
          }
          return const _ProfileAuthErrorWidget();
        }

        return ChangeNotifierProvider(
          create: (_) => ProfileProvider()..init(),
          child: const ProfileScreen(),
        );
      },
    );
  }
}

class _ProfileLoadingWidget extends StatelessWidget {
  const _ProfileLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'جاري تحميل الملف الشخصي...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAuthErrorWidget extends StatelessWidget {
  const _ProfileAuthErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'خطأ في المصادقة',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'يرجى تسجيل الدخول للوصول إلى الملف الشخصي',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  final authProvider = context.read<AuthProvider>();
                  authProvider.logout();
                },
                icon: const Icon(Icons.login_rounded),
                label: const Text('تسجيل الدخول'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

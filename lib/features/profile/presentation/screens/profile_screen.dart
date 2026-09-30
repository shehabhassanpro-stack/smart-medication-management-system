import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../models/user_model.dart';
import '../../../../providers/auth_provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_section.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'notification_settings_screen.dart';
import 'app_settings_screen.dart';
import 'qr_code_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              _buildHeader(context, provider),
              Expanded(
                child: _buildContent(context, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProfileProvider provider) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                S.of(context).profile_title,
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // QR code button — only for patients
              if (context.read<AuthProvider>().userModel?.role != UserRole.doctor)
                _buildHeaderButton(
                  icon: Icons.qr_code_rounded,
                  onTap: () => _navigateTo(context, const QRCodeScreen()),
                ),
            ],
          ),
          const SizedBox(height: 24),
          ProfileHeader(
            name: provider.userName,
            email: provider.userEmail,
            initial: provider.userInitial,
            memberSince: provider.memberSinceFormatted,
            completeness: provider.profileCompleteness,
            onEditTap: () => _navigateTo(context, const EditProfileScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.hasError) {
      return _buildErrorState(context, provider);
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProfileStatsCard(
              readingsCount: provider.readingsCount,
              medicinesCount: provider.medicinesCount,
              consecutiveDays: provider.consecutiveDays,
            ),
            const SizedBox(height: 24),
            ProfileSection(
              title: S.of(context).profile_title,
              children: [
                ProfileMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: S.of(context).profile_editProfile,
                  subtitle: S.of(context).profile_name,
                  onTap: () => _navigateTo(context, const EditProfileScreen()),
                ),
                ProfileMenuItem(
                  icon: Icons.lock_outline_rounded,
                  title: S.of(context).profile_changePassword,
                  subtitle: S.of(context).profile_newPassword,
                  onTap: () => _navigateTo(context, const ChangePasswordScreen()),
                ),
                // QR Code menu item — only for patients (doctors have a scanner, not a QR)
                if (context.read<AuthProvider>().userModel?.role != UserRole.doctor)
                  ProfileMenuItem(
                    icon: Icons.qr_code_rounded,
                    title: S.of(context).profile_qrCode,
                    subtitle: S.of(context).profile_qrCode,
                    onTap: () => _navigateTo(context, const QRCodeScreen()),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ProfileSection(
              title: S.of(context).notifications_settings,
              children: [
                ProfileMenuItem(
                  icon: Icons.notifications_outlined,
                  title: S.of(context).notifications_settings,
                  subtitle: S.of(context).notifications_medicineReminder,
                  onTap: () => _navigateTo(context, const NotificationSettingsScreen()),
                ),
                ProfileMenuItem(
                  icon: Icons.palette_outlined,
                  title: S.of(context).settings_title,
                  subtitle: S.of(context).settings_appearance,
                  onTap: () => _navigateTo(context, const AppSettingsScreen()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProfileSection(
              title: S.of(context).profile_helpSupport,
              children: [
                ProfileMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: S.of(context).profile_about,
                  subtitle: S.of(context).profile_about,
                  onTap: () => _showAboutDialog(context),
                ),
                ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: S.of(context).profile_helpSupport,
                  subtitle: S.of(context).profile_helpSupport,
                  onTap: () => _showHelpDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProfileSection(
              title: S.of(context).common_logout,
              children: [
                ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  title: S.of(context).profile_logoutButton,
                  subtitle: S.of(context).common_logoutConfirm,
                  iconColor: AppColors.warning,
                  onTap: () => _showLogoutDialog(context, provider),
                ),
                ProfileMenuItem(
                  icon: Icons.delete_outline_rounded,
                  title: S.of(context).common_delete,
                  subtitle: S.of(context).common_delete,
                  iconColor: AppColors.error,
                  onTap: () => _showDeleteAccountDialog(context, provider),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ProfileProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'حدث خطأ',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    HapticFeedback.lightImpact();
    final provider = context.read<ProfileProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: screen,
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.favorite_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text('عن التطبيق'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical Care App',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'نظام السجلات الصحية السحابي',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'الإصدار: 2.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'مشروع تخرج - 2025',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.help_outline_rounded, color: AppColors.info),
            ),
            const SizedBox(width: 12),
            const Text('المساعدة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('كيف أضيف قراءة صحية؟', 'اذهب لتبويب القراءات واضغط على زر الإضافة'),
            const SizedBox(height: 12),
            _buildHelpItem('كيف أضيف دواء؟', 'اذهب لتبويب الأدوية واضغط على زر الإضافة'),
            const SizedBox(height: 12),
            _buildHelpItem('كيف أشارك بياناتي مع الطبيب؟', 'استخدم QR Code من الملف الشخصي'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }




  void _showLogoutDialog(BuildContext context, ProfileProvider provider) {
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
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout_rounded, color: AppColors.warning),
            ),
            const SizedBox(width: 12),
            const Text('تسجيل الخروج'),
          ],
        ),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, ProfileProvider provider) {
    HapticFeedback.heavyImpact();
    final passwordController = TextEditingController();

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
              child: Icon(Icons.delete_forever_rounded, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text('حذف الحساب'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تحذير: هذا الإجراء لا يمكن التراجع عنه!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('سيتم حذف جميع بياناتك بشكل نهائي.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'أدخل كلمة المرور للتأكيد',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('يرجى إدخال كلمة المرور'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              final success = await provider.deleteAccount(
                password: passwordController.text,
              );
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'حدث خطأ'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
  }
}

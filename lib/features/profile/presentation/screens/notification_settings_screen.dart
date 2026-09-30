import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;

  bool _medicineReminders = true;
  bool _readingReminders = true;
  bool _doctorNotifications = true;
  bool _healthTips = true;
  bool _appUpdates = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _medicineReminders = prefs.getBool('notif_medicine') ?? true;
        _readingReminders = prefs.getBool('notif_readings') ?? true;
        _doctorNotifications = prefs.getBool('notif_doctor') ?? true;
        _healthTips = prefs.getBool('notif_health_tips') ?? true;
        _appUpdates = prefs.getBool('notif_app_updates') ?? false;
        _soundEnabled = prefs.getBool('notif_sound') ?? true;
        _vibrationEnabled = prefs.getBool('notif_vibration') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving setting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          title: 'التذكيرات',
                          icon: Icons.alarm_rounded,
                          children: [
                            _buildSwitchTile(
                              title: 'تذكيرات الأدوية',
                              subtitle: 'تنبيهات مواعيد تناول الأدوية',
                              icon: Icons.medication_rounded,
                              value: _medicineReminders,
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                setState(() => _medicineReminders = value);
                                _saveSetting('notif_medicine', value);
                              },
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: 'تذكيرات القراءات',
                              subtitle: 'تنبيهات لتسجيل القراءات الصحية',
                              icon: Icons.monitor_heart_rounded,
                              value: _readingReminders,
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                setState(() => _readingReminders = value);
                                _saveSetting('notif_readings', value);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          title: 'الإشعارات',
                          icon: Icons.notifications_rounded,
                          children: [
                            _buildSwitchTile(
                              title: 'إشعارات الطبيب',
                              subtitle: 'رسائل وتحديثات من طبيبك',
                              icon: Icons.medical_services_rounded,
                              value: _doctorNotifications,
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                setState(() => _doctorNotifications = value);
                                _saveSetting('notif_doctor', value);
                              },
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: 'نصائح صحية',
                              subtitle: 'نصائح وإرشادات صحية يومية',
                              icon: Icons.lightbulb_rounded,
                              value: _healthTips,
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                setState(() => _healthTips = value);
                                _saveSetting('notif_health_tips', value);
                              },
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: 'تحديثات التطبيق',
                              subtitle: 'إشعارات بالميزات والتحديثات الجديدة',
                              icon: Icons.system_update_rounded,
                              value: _appUpdates,
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                setState(() => _appUpdates = value);
                                _saveSetting('notif_app_updates', value);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          title: 'الصوت والاهتزاز',
                          icon: Icons.volume_up_rounded,
                          children: [
                            _buildSwitchTile(
                              title: 'الصوت',
                              subtitle: 'تشغيل صوت عند وصول الإشعارات',
                              icon: Icons.music_note_rounded,
                              value: _soundEnabled,
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                setState(() => _soundEnabled = value);
                                _saveSetting('notif_sound', value);
                              },
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              title: 'الاهتزاز',
                              subtitle: 'اهتزاز الجهاز عند وصول الإشعارات',
                              icon: Icons.vibration_rounded,
                              value: _vibrationEnabled,
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                setState(() => _vibrationEnabled = value);
                                _saveSetting('notif_vibration', value);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoCard(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Row(
        children: [
          _buildBackButton(context),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعدادات الإشعارات',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تحكم في التنبيهات والتذكيرات',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(right: 74),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.border.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.info,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملاحظة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تأكد من تفعيل الإشعارات في إعدادات جهازك للحصول على التنبيهات.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

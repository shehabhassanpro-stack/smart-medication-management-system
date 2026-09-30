import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../core/services/notification_scheduler.dart';
import '../../../../providers/auth_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔔 NOTIFICATION SETTINGS SCREEN - With Live Scheduler Integration
// ═══════════════════════════════════════════════════════════════════════════════
//
// Updated to integrate with NotificationScheduler for real-time changes:
// • When medicine reminders are disabled → Cancel all scheduled notifications
// • When medicine reminders are enabled → Reschedule all notifications
// • Sound/Vibration changes take effect on next notification
//
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;

  // Notification Settings
  bool _medicineReminders = true;
  bool _readingReminders = true;
  bool _doctorNotifications = true;
  bool _healthTips = true;
  bool _appUpdates = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Services
  final NotificationScheduler _scheduler = NotificationScheduler.instance;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOAD SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════

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
      debugPrint('❌ Error loading settings: $e');
      setState(() => _isLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SAVE SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      debugPrint('✅ Setting saved: $key = $value');
    } catch (e) {
      debugPrint('❌ Error saving setting: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MEDICINE REMINDERS TOGGLE - WITH SCHEDULER INTEGRATION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _handleMedicineRemindersToggle(bool value) async {
    HapticFeedback.lightImpact();
    
    // Update UI immediately
    setState(() {
      _medicineReminders = value;
      _isProcessing = true;
    });

    // Save setting
    await _saveSetting('notif_medicine', value);

    // Handle scheduler
    try {
      if (value) {
        // Enabled - Reschedule all notifications
        debugPrint('📅 Medicine reminders enabled - Rescheduling...');
        final userId = _getUserId();
        if (userId != null) {
          final result = await _scheduler.rescheduleAllMedicines(userId);
          _showFeedback(
            result.success 
                ? 'تم تفعيل تذكيرات الأدوية (${result.scheduledCount} تذكير)'
                : 'تم تفعيل التذكيرات',
          );
        }
      } else {
        // Disabled - Cancel all notifications
        debugPrint('🚫 Medicine reminders disabled - Cancelling...');
        await _scheduler.cancelAllMedicineNotifications();
        _showFeedback('تم إيقاف تذكيرات الأدوية');
      }
    } catch (e) {
      debugPrint('❌ Error handling medicine reminders toggle: $e');
    }

    setState(() => _isProcessing = false);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OTHER TOGGLES
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleReadingRemindersToggle(bool value) {
    HapticFeedback.lightImpact();
    setState(() => _readingReminders = value);
    _saveSetting('notif_readings', value);
    
    // Reading reminders use different channel - no scheduler action needed
    // The setting is read by LocalNotificationService when scheduling
  }

  void _handleDoctorNotificationsToggle(bool value) {
    HapticFeedback.lightImpact();
    setState(() => _doctorNotifications = value);
    _saveSetting('notif_doctor', value);
  }

  void _handleHealthTipsToggle(bool value) {
    HapticFeedback.lightImpact();
    setState(() => _healthTips = value);
    _saveSetting('notif_health_tips', value);
  }

  void _handleAppUpdatesToggle(bool value) {
    HapticFeedback.lightImpact();
    setState(() => _appUpdates = value);
    _saveSetting('notif_app_updates', value);
  }

  void _handleSoundToggle(bool value) {
    HapticFeedback.lightImpact();
    setState(() => _soundEnabled = value);
    _saveSetting('notif_sound', value);
    // Sound setting takes effect on next notification
  }

  void _handleVibrationToggle(bool value) {
    HapticFeedback.lightImpact();
    setState(() => _vibrationEnabled = value);
    _saveSetting('notif_vibration', value);
    // Vibration setting takes effect on next notification
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  String? _getUserId() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      return authProvider.user?.uid;
    } catch (e) {
      debugPrint('⚠️ Could not get user ID: $e');
      return null;
    }
  }

  void _showFeedback(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // التذكيرات
                            _buildSection(
                              title: 'التذكيرات',
                              icon: Icons.alarm_rounded,
                              children: [
                                _buildSwitchTile(
                                  title: 'تذكيرات الأدوية',
                                  subtitle: 'تنبيهات مواعيد تناول الأدوية',
                                  icon: Icons.medication_rounded,
                                  value: _medicineReminders,
                                  isImportant: true,
                                  onChanged: _handleMedicineRemindersToggle,
                                ),
                                _buildDivider(),
                                _buildSwitchTile(
                                  title: 'تذكيرات القراءات',
                                  subtitle: 'تنبيهات لتسجيل القراءات الصحية',
                                  icon: Icons.monitor_heart_rounded,
                                  value: _readingReminders,
                                  onChanged: _handleReadingRemindersToggle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // الإشعارات
                            _buildSection(
                              title: 'الإشعارات',
                              icon: Icons.notifications_rounded,
                              children: [
                                _buildSwitchTile(
                                  title: 'إشعارات الطبيب',
                                  subtitle: 'رسائل وتحديثات من طبيبك',
                                  icon: Icons.medical_services_rounded,
                                  value: _doctorNotifications,
                                  onChanged: _handleDoctorNotificationsToggle,
                                ),
                                _buildDivider(),
                                _buildSwitchTile(
                                  title: 'نصائح صحية',
                                  subtitle: 'نصائح وإرشادات صحية يومية',
                                  icon: Icons.lightbulb_rounded,
                                  value: _healthTips,
                                  onChanged: _handleHealthTipsToggle,
                                ),
                                _buildDivider(),
                                _buildSwitchTile(
                                  title: 'تحديثات التطبيق',
                                  subtitle: 'إشعارات بالميزات والتحديثات الجديدة',
                                  icon: Icons.system_update_rounded,
                                  value: _appUpdates,
                                  onChanged: _handleAppUpdatesToggle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // الصوت والاهتزاز
                            _buildSection(
                              title: 'الصوت والاهتزاز',
                              icon: Icons.volume_up_rounded,
                              children: [
                                _buildSwitchTile(
                                  title: 'الصوت',
                                  subtitle: 'تشغيل صوت عند وصول الإشعارات',
                                  icon: Icons.music_note_rounded,
                                  value: _soundEnabled,
                                  onChanged: _handleSoundToggle,
                                ),
                                _buildDivider(),
                                _buildSwitchTile(
                                  title: 'الاهتزاز',
                                  subtitle: 'اهتزاز الجهاز عند وصول الإشعارات',
                                  icon: Icons.vibration_rounded,
                                  value: _vibrationEnabled,
                                  onChanged: _handleVibrationToggle,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // معلومات
                            _buildInfoCard(),
                            
                            // إحصائيات (إذا كانت تذكيرات الأدوية مفعلة)
                            if (_medicineReminders) ...[
                              const SizedBox(height: 20),
                              _buildStatsCard(),
                            ],
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                      
                      // Processing overlay
                      if (_isProcessing)
                        Container(
                          color: Colors.black26,
                          child: const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 16),
                                    Text('جاري التحديث...'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION
  // ═══════════════════════════════════════════════════════════════════════════

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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // SWITCH TILE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    bool isImportant = false,
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
                  ? (isImportant ? AppColors.success : AppColors.primary).withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value 
                  ? (isImportant ? AppColors.success : AppColors.primary) 
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (isImportant) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'مهم',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) => onChanged(v),
            activeThumbColor: isImportant ? AppColors.success : AppColors.primary,
            activeTrackColor: (isImportant ? AppColors.success : AppColors.primary).withValues(alpha: 0.3),
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
        color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INFO CARD
  // ═══════════════════════════════════════════════════════════════════════════

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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATS CARD (NEW)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStatsCard() {
    return FutureBuilder<int>(
      future: _scheduler.getPendingNotificationsCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التذكيرات المجدولة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snapshot.connectionState == ConnectionState.waiting
                          ? 'جاري التحميل...'
                          : 'لديك $count تذكير مجدول',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

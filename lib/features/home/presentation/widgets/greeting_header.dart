import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

class GreetingHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  const GreetingHeader({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final greetingData = _getGreetingData();

    return Semantics(
      label: '${greetingData.greeting}، $userName. ${greetingData.motivation}',
      child: Container(
        padding: tokens.paddingAllMedium,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryContainer.withValues(alpha: 0.5),
              AppColors.primaryContainer.withValues(alpha: 0.2),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: tokens.borderRadiusLarge,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _AvatarSection(
              userName: userName,
              avatarUrl: avatarUrl,
              onTap: onAvatarTap,
              greetingIcon: greetingData.icon,
              iconColor: greetingData.iconColor,
            ),
            tokens.hSpacerMedium,
            Expanded(
              child: _TextSection(
                greeting: greetingData.greeting,
                userName: userName,
                motivation: greetingData.motivation,
              ),
            ),
            _TimeIcon(
              icon: greetingData.icon,
              color: greetingData.iconColor,
              backgroundColor: greetingData.iconBackgroundColor,
            ),
          ],
        ),
      ),
    );
  }

  _GreetingData _getGreetingData() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return _GreetingData(
        greeting: 'صباح الخير',
        motivation: _getMorningMotivation(),
        icon: Icons.wb_sunny_rounded,
        iconColor: AppColors.warning,
        iconBackgroundColor: AppColors.warning.withValues(alpha: 0.15),
      );
    } else if (hour >= 12 && hour < 17) {
      return _GreetingData(
        greeting: 'مساء الخير',
        motivation: _getAfternoonMotivation(),
        icon: Icons.wb_cloudy_rounded,
        iconColor: AppColors.info,
        iconBackgroundColor: AppColors.info.withValues(alpha: 0.15),
      );
    } else if (hour >= 17 && hour < 21) {
      return _GreetingData(
        greeting: 'مساء الخير',
        motivation: _getEveningMotivation(),
        icon: Icons.nights_stay_rounded,
        iconColor: AppColors.secondary,
        iconBackgroundColor: AppColors.secondary.withValues(alpha: 0.15),
      );
    } else {
      return _GreetingData(
        greeting: 'مساء الخير',
        motivation: _getNightMotivation(),
        icon: Icons.nightlight_round,
        iconColor: AppColors.primary,
        iconBackgroundColor: AppColors.primary.withValues(alpha: 0.15),
      );
    }
  }

  String _getMorningMotivation() {
    final motivations = [
      'ابدأ يومك بنشاط وحيوية! 💪',
      'صحتك أولوية، اعتنِ بها اليوم',
      'يوم جديد، فرصة جديدة للصحة',
    ];
    return motivations[DateTime.now().day % motivations.length];
  }

  String _getAfternoonMotivation() {
    final motivations = [
      'لا تنسَ شرب الماء! 💧',
      'خذ استراحة قصيرة للتجدد',
      'حافظ على نشاطك وطاقتك',
    ];
    return motivations[DateTime.now().day % motivations.length];
  }

  String _getEveningMotivation() {
    final motivations = [
      'وقت الاسترخاء والراحة 🌅',
      'راجع أدويتك المسائية',
      'استعد لنوم هادئ وصحي',
    ];
    return motivations[DateTime.now().day % motivations.length];
  }

  String _getNightMotivation() {
    final motivations = [
      'نوم هانئ وأحلام سعيدة 🌙',
      'الراحة الجيدة سر الصحة',
      'غداً يوم جديد مليء بالأمل',
    ];
    return motivations[DateTime.now().day % motivations.length];
  }
}

class _AvatarSection extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final IconData greetingIcon;
  final Color iconColor;

  const _AvatarSection({
    required this.userName,
    this.avatarUrl,
    this.onTap,
    required this.greetingIcon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final initials = _getInitials(userName);

    return GestureDetector(
      onTap: onTap != null
          ? () {
        HapticFeedback.lightImpact();
        onTap!();
      }
          : null,
      child: Stack(
        children: [
          Container(
            width: tokens.responsive.scale(56),
            height: tokens.responsive.scale(56),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: tokens.responsive.scale(12),
                  offset: Offset(0, tokens.responsive.scale(4)),
                ),
              ],
            ),
            child: avatarUrl != null
                ? ClipOval(
              child: Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(initials, tokens),
              ),
            )
                : _buildInitials(initials, tokens),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(tokens.spacing2XS),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                greetingIcon,
                size: tokens.responsive.scale(12),
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(String initials, DesignTokens tokens) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: tokens.fontTitle,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

class _TextSection extends StatelessWidget {
  final String greeting;
  final String userName;
  final String motivation;

  const _TextSection({
    required this.greeting,
    required this.userName,
    required this.motivation,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: tokens.fontSmall,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: tokens.spacing2XS),
        Text(
          userName,
          style: TextStyle(
            fontSize: tokens.fontSubtitle,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: tokens.spacingXS),
        Text(
          motivation,
          style: TextStyle(
            fontSize: tokens.fontCaption,
            color: AppColors.textTertiary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TimeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _TimeIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: tokens.paddingAllSmall,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: tokens.borderRadiusMedium,
      ),
      child: Icon(
        icon,
        color: color,
        size: tokens.iconMedium,
      ),
    );
  }
}

class _GreetingData {
  final String greeting;
  final String motivation;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  const _GreetingData({
    required this.greeting,
    required this.motivation,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });
}
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
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
            child: Column(
              children: _buildChildrenWithDividers(context),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildrenWithDividers(BuildContext context) {
    final List<Widget> items = [];

    for (int i = 0; i < children.length; i++) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            top: i == 0 ? 8 : 0,
            bottom: i == children.length - 1 ? 8 : 0,
            right: 12,
            left: 12,
          ),
          child: children[i],
        ),
      );

      if (i < children.length - 1) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(right: 74),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
        );
      }
    }

    return items;
  }
}

import 'package:flutter/material.dart';
import '../core/design_tokens.dart';
import '../core/utils/responsive_utils.dart';
import '../core/widgets/responsive_card.dart';
import '../core/app_colors.dart';

class ResponsiveDemoScreen extends StatelessWidget {
  const ResponsiveDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 3 - Responsive Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: tokens.paddingAllMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceInfo(context, responsive),
            tokens.spacerLarge,
            _buildResponsiveCards(context, tokens),
            tokens.spacerLarge,
            _buildResponsiveGrid(context, tokens),
            tokens.spacerLarge,
            _buildTypographyDemo(context, tokens),
            tokens.spacerLarge,
            _buildSpacingDemo(context, tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo(BuildContext context, ResponsiveUtils responsive) {
    return ResponsiveCard(
      backgroundColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Info',
            style: TextStyle(
              fontSize: context.tokens.fontTitle,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: context.tokens.spacingSmall),
          _infoRow('Screen Size', responsive.screenSizeType.name),
          _infoRow('Device Type', responsive.deviceType.name),
          _infoRow('Orientation', responsive.orientation.name),
          _infoRow('Width', '${responsive.width.toInt()}px'),
          _infoRow('Height', '${responsive.height.toInt()}px'),
          _infoRow('Has Notch', responsive.hasNotch ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveCards(BuildContext context, DesignTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Responsive Cards',
          style: TextStyle(
            fontSize: tokens.fontTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        tokens.spacerMedium,
        Row(
          children: [
            Expanded(
              child: ResponsiveCard(
                backgroundColor: AppColors.success,
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: tokens.iconLarge,
                      color: Colors.white,
                    ),
                    tokens.spacerSmall,
                    Text(
                      'Success',
                      style: TextStyle(
                        fontSize: tokens.fontBody,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: tokens.spacingMedium),
            Expanded(
              child: ResponsiveCard(
                backgroundColor: AppColors.error,
                child: Column(
                  children: [
                    Icon(
                      Icons.error,
                      size: tokens.iconLarge,
                      color: Colors.white,
                    ),
                    tokens.spacerSmall,
                    Text(
                      'Error',
                      style: TextStyle(
                        fontSize: tokens.fontBody,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, DesignTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Responsive Grid',
          style: TextStyle(
            fontSize: tokens.fontTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        tokens.spacerMedium,
        ResponsiveGridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mobileColumns: 2,
          tabletColumns: 3,
          desktopColumns: 4,
          mobileAspectRatio: 1.0,
          tabletAspectRatio: 1.1,
          desktopAspectRatio: 1.2,
          children: List.generate(
            8,
                (index) => ResponsiveCard(
              backgroundColor: AppColors.primaryLight,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grid_on,
                      size: tokens.iconLarge,
                      color: AppColors.primary,
                    ),
                    tokens.spacerSmall,
                    Text(
                      'Item ${index + 1}',
                      style: TextStyle(
                        fontSize: tokens.fontBody,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypographyDemo(BuildContext context, DesignTokens tokens) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Typography Scale',
            style: TextStyle(
              fontSize: tokens.fontTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
          tokens.spacerMedium,
          _textSample('Display', tokens.fontDisplay),
          _textSample('Headline', tokens.fontHeadline),
          _textSample('Title', tokens.fontTitle),
          _textSample('Subtitle', tokens.fontSubtitle),
          _textSample('Body Large', tokens.fontBodyLarge),
          _textSample('Body', tokens.fontBody),
          _textSample('Small', tokens.fontSmall),
          _textSample('Caption', tokens.fontCaption),
        ],
      ),
    );
  }

  Widget _textSample(String label, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Sample Text',
              style: TextStyle(fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${fontSize.toInt()}px',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingDemo(BuildContext context, DesignTokens tokens) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spacing & Icons',
            style: TextStyle(
              fontSize: tokens.fontTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
          tokens.spacerMedium,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _iconSample(Icons.star, tokens.iconTiny, 'Tiny'),
              _iconSample(Icons.star, tokens.iconSmall, 'Small'),
              _iconSample(Icons.star, tokens.iconMedium, 'Medium'),
              _iconSample(Icons.star, tokens.iconLarge, 'Large'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconSample(IconData icon, double size, String label) {
    return Column(
      children: [
        Icon(icon, size: size, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          '${size.toInt()}',
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
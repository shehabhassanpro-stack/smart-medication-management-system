import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';

class MedicinesErrorState extends StatefulWidget {
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onRetry;
  final ErrorStateType type;
  final String? errorCode;

  const MedicinesErrorState({
    super.key,
    this.title = 'حدث خطأ',
    this.description = 'حدث خطأ أثناء تحميل البيانات.\nيرجى المحاولة مرة أخرى.',
    this.buttonText = 'إعادة المحاولة',
    this.onRetry,
    this.type = ErrorStateType.general,
    this.errorCode,
  });

  @override
  State<MedicinesErrorState> createState() => _MedicinesErrorStateState();
}

class _MedicinesErrorStateState extends State<MedicinesErrorState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(tokens),
            SizedBox(height: tokens.spacingLG),
            _buildTitle(tokens),
            SizedBox(height: tokens.spacingSM),
            _buildDescription(tokens),
            if (widget.errorCode != null) ...[
              SizedBox(height: tokens.spacingSM),
              _buildErrorCode(tokens),
            ],
            if (widget.onRetry != null) ...[
              SizedBox(height: tokens.spacingXL),
              _buildRetryButton(tokens),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(DesignTokens tokens) {
    final iconData = widget.type.icon;
    final color = widget.type.color;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shake = _shakeAnimation.value * 0.05;
        return Transform.rotate(
          angle: shake * (1 - _shakeAnimation.value),
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.all(tokens.paddingXL),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Container(
          padding: EdgeInsets.all(tokens.paddingLG),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            color: color,
            size: tokens.responsive.scale(48),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(DesignTokens tokens) {
    return Text(
      widget.title,
      style: TextStyle(
        fontSize: tokens.fontXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(DesignTokens tokens) {
    return Text(
      widget.description,
      style: TextStyle(
        fontSize: tokens.fontMD,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorCode(DesignTokens tokens) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.paddingSM,
        vertical: tokens.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: tokens.borderRadiusSM,
      ),
      child: Text(
        'رمز الخطأ: ${widget.errorCode}',
        style: TextStyle(
          fontSize: tokens.fontXS,
          color: AppColors.textTertiary,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildRetryButton(DesignTokens tokens) {
    return ElevatedButton.icon(
      onPressed: widget.onRetry,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.type.color,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.paddingXL,
          vertical: tokens.paddingMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: tokens.borderRadiusFull,
        ),
        elevation: 0,
      ),
      icon: const Icon(Icons.refresh_rounded),
      label: Text(
        widget.buttonText!,
        style: TextStyle(
          fontSize: tokens.fontMD,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum ErrorStateType {
  general,
  network,
  server,
  timeout,
  permission,
  notFound,
}

extension ErrorStateTypeExtension on ErrorStateType {
  IconData get icon {
    switch (this) {
      case ErrorStateType.general:
        return Icons.error_outline_rounded;
      case ErrorStateType.network:
        return Icons.wifi_off_rounded;
      case ErrorStateType.server:
        return Icons.cloud_off_rounded;
      case ErrorStateType.timeout:
        return Icons.hourglass_empty_rounded;
      case ErrorStateType.permission:
        return Icons.lock_outline_rounded;
      case ErrorStateType.notFound:
        return Icons.search_off_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ErrorStateType.general:
        return AppColors.error;
      case ErrorStateType.network:
        return AppColors.warning;
      case ErrorStateType.server:
        return AppColors.error;
      case ErrorStateType.timeout:
        return AppColors.warning;
      case ErrorStateType.permission:
        return AppColors.error;
      case ErrorStateType.notFound:
        return AppColors.textSecondary;
    }
  }

  String get defaultTitle {
    switch (this) {
      case ErrorStateType.general:
        return 'حدث خطأ';
      case ErrorStateType.network:
        return 'لا يوجد اتصال';
      case ErrorStateType.server:
        return 'خطأ في الخادم';
      case ErrorStateType.timeout:
        return 'انتهت المهلة';
      case ErrorStateType.permission:
        return 'غير مصرح';
      case ErrorStateType.notFound:
        return 'غير موجود';
    }
  }

  String get defaultDescription {
    switch (this) {
      case ErrorStateType.general:
        return 'حدث خطأ أثناء تحميل البيانات.\nيرجى المحاولة مرة أخرى.';
      case ErrorStateType.network:
        return 'تحقق من اتصالك بالإنترنت\nوحاول مرة أخرى.';
      case ErrorStateType.server:
        return 'حدث خطأ في الخادم.\nيرجى المحاولة لاحقاً.';
      case ErrorStateType.timeout:
        return 'استغرق الطلب وقتاً طويلاً.\nيرجى المحاولة مرة أخرى.';
      case ErrorStateType.permission:
        return 'ليس لديك صلاحية للوصول.\nيرجى التواصل مع الدعم.';
      case ErrorStateType.notFound:
        return 'لم يتم العثور على البيانات المطلوبة.';
    }
  }
}

class MedicinesNetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const MedicinesNetworkErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MedicinesErrorState(
      type: ErrorStateType.network,
      title: ErrorStateType.network.defaultTitle,
      description: ErrorStateType.network.defaultDescription,
      onRetry: onRetry,
    );
  }
}

class MedicinesServerErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? errorCode;

  const MedicinesServerErrorState({
    super.key,
    this.onRetry,
    this.errorCode,
  });

  @override
  Widget build(BuildContext context) {
    return MedicinesErrorState(
      type: ErrorStateType.server,
      title: ErrorStateType.server.defaultTitle,
      description: ErrorStateType.server.defaultDescription,
      onRetry: onRetry,
      errorCode: errorCode,
    );
  }
}

class MedicinesTimeoutErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const MedicinesTimeoutErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MedicinesErrorState(
      type: ErrorStateType.timeout,
      title: ErrorStateType.timeout.defaultTitle,
      description: ErrorStateType.timeout.defaultDescription,
      onRetry: onRetry,
    );
  }
}
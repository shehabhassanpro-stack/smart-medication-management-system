import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_shadows.dart';
import '../../../../core/design_tokens.dart';

class MedicinesSearchBar extends StatefulWidget {
  final String? initialValue;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;
  final bool autofocus;
  final bool enabled;
  final Duration debounceDuration;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const MedicinesSearchBar({
    super.key,
    this.initialValue,
    this.hintText = 'ابحث عن دواء...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onFilterTap,
    this.showFilterButton = true,
    this.autofocus = false,
    this.enabled = true,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.controller,
    this.focusNode,
  });

  @override
  State<MedicinesSearchBar> createState() => _MedicinesSearchBarState();
}

class _MedicinesSearchBarState extends State<MedicinesSearchBar>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounceTimer;
  bool _isFocused = false;
  bool _hasText = false;

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _hasText = _controller.text.isNotEmpty;

    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);

    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(_controller.text);
    });
  }

  void _onClear() {
    HapticFeedback.lightImpact();
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  void _onSubmit(String value) {
    _debounceTimer?.cancel();
    widget.onSubmitted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: tokens.borderRadiusLG,
          border: Border.all(
            color: _isFocused ? AppColors.primary : AppColors.border,
            width: _isFocused ? 1.5 : 1,
          ),
          boxShadow: _isFocused ? AppShadows.md : AppShadows.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(tokens),
            ),
            if (_hasText)
              _buildClearButton(tokens),
            if (widget.showFilterButton)
              _buildFilterButton(tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(DesignTokens tokens) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      textInputAction: TextInputAction.search,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontSize: tokens.fontMD,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: tokens.fontMD,
          color: AppColors.textHint,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            right: tokens.paddingSM,
            left: tokens.paddingMD,
          ),
          child: Icon(
            Icons.search_rounded,
            color: _isFocused ? AppColors.primary : AppColors.textSecondary,
            size: tokens.iconMD,
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: tokens.iconLG + tokens.paddingLG,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.paddingMD,
          vertical: tokens.paddingMD,
        ),
      ),
      onSubmitted: _onSubmit,
    );
  }

  Widget _buildClearButton(DesignTokens tokens) {
    return Semantics(
      button: true,
      label: 'مسح البحث',
      child: GestureDetector(
        onTap: _onClear,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.paddingSM),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: tokens.paddingAllXS,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: tokens.iconSM,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(DesignTokens tokens) {
    return Semantics(
      button: true,
      label: 'فلتر البحث',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onFilterTap?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.paddingMD,
            vertical: tokens.paddingMD,
          ),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: Icon(
            Icons.tune_rounded,
            color: AppColors.textSecondary,
            size: tokens.iconMD,
          ),
        ),
      ),
    );
  }
}

class MedicinesSearchBarCompact extends StatelessWidget {
  final VoidCallback onTap;
  final String hintText;
  final int? resultsCount;

  const MedicinesSearchBarCompact({
    super.key,
    required this.onTap,
    this.hintText = 'ابحث عن دواء...',
    this.resultsCount,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      button: true,
      label: 'فتح البحث',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.paddingMD,
            vertical: tokens.paddingSM,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: tokens.borderRadiusLG,
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: tokens.iconMD,
              ),
              SizedBox(width: tokens.spacingSM),
              Expanded(
                child: Text(
                  hintText,
                  style: TextStyle(
                    fontSize: tokens.fontMD,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (resultsCount != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.paddingSM,
                    vertical: tokens.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: tokens.borderRadiusSM,
                  ),
                  child: Text(
                    '$resultsCount',
                    style: TextStyle(
                      fontSize: tokens.fontSM,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
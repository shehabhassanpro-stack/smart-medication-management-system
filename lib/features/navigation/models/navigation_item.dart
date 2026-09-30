import 'package:flutter/material.dart';

class NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Widget screen;
  final String? semanticLabel;

  const NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.screen,
    this.semanticLabel,
  });

  IconData get displayIcon => activeIcon ?? icon;
  String get accessibilityLabel => semanticLabel ?? label;
}

enum NavigationType {
  patient,
  doctor,
}

extension NavigationTypeExtension on NavigationType {
  bool get isPatient => this == NavigationType.patient;
  bool get isDoctor => this == NavigationType.doctor;
}
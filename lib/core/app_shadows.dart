import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 10),
      blurRadius: 10,
      spreadRadius: -5,
    ),
  ];

  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 25),
      blurRadius: 50,
      spreadRadius: -12,
    ),
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 16),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> input = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 11),
      blurRadius: 15,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 9),
      blurRadius: 46,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> dropdown = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 6),
      blurRadius: 10,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 3),
      blurRadius: 5,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> hover = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> pressed = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get focus => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.15),
      offset: const Offset(0, 0),
      blurRadius: 0,
      spreadRadius: 3,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get success => [
    BoxShadow(
      color: AppColors.success.withValues(alpha: 0.15),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get error => [
    BoxShadow(
      color: AppColors.error.withValues(alpha: 0.15),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get warning => [
    BoxShadow(
      color: AppColors.warning.withValues(alpha: 0.15),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get info => [
    BoxShadow(
      color: AppColors.info.withValues(alpha: 0.15),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get bloodPressure => [
    BoxShadow(
      color: AppColors.bloodPressure.withValues(alpha: 0.12),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get bloodSugar => [
    BoxShadow(
      color: AppColors.bloodSugar.withValues(alpha: 0.12),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get weight => [
    BoxShadow(
      color: AppColors.weight.withValues(alpha: 0.12),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get temperature => [
    BoxShadow(
      color: AppColors.temperature.withValues(alpha: 0.12),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get heartRate => [
    BoxShadow(
      color: AppColors.heartRate.withValues(alpha: 0.12),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get oxygen => [
    BoxShadow(
      color: AppColors.oxygen.withValues(alpha: 0.12),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> top = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, -4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, -2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> bottom = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> left = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(-4, 0),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> right = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(4, 0),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> elevation(int level) {
    switch (level) {
      case 0:
        return none;
      case 1:
        return xs;
      case 2:
        return sm;
      case 3:
        return md;
      case 4:
        return lg;
      case 5:
        return xl;
      case 6:
        return xxl;
      default:
        return md;
    }
  }

  static List<BoxShadow> colored(
    Color color, {
    double intensity = 0.15,
    double blur = 8,
    Offset offset = const Offset(0, 2),
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        offset: offset,
        blurRadius: blur,
        spreadRadius: 0,
      ),
      const BoxShadow(
        color: Color(0x0A000000),
        offset: Offset(0, 1),
        blurRadius: 3,
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> forReadingType(String type) {
    switch (type.toLowerCase()) {
      case 'blood_pressure':
      case 'bloodpressure':
        return bloodPressure;
      case 'blood_sugar':
      case 'bloodsugar':
      case 'glucose':
        return bloodSugar;
      case 'weight':
        return weight;
      case 'temperature':
        return temperature;
      case 'heart_rate':
      case 'heartrate':
        return heartRate;
      case 'oxygen':
      case 'spo2':
        return oxygen;
      default:
        return card;
    }
  }

  static List<BoxShadow> forStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return success;
      case 'error':
      case 'danger':
        return error;
      case 'warning':
        return warning;
      case 'info':
        return info;
      default:
        return card;
    }
  }

  static List<BoxShadow> lerp(
    List<BoxShadow> a,
    List<BoxShadow> b,
    double t,
  ) {
    if (a.isEmpty && b.isEmpty) return [];
    if (a.isEmpty) return b.map((s) => s.scale(t)).toList();
    if (b.isEmpty) return a.map((s) => s.scale(1 - t)).toList();

    final maxLength = a.length > b.length ? a.length : b.length;
    final result = <BoxShadow>[];

    for (int i = 0; i < maxLength; i++) {
      final shadowA = i < a.length ? a[i] : a.last;
      final shadowB = i < b.length ? b[i] : b.last;
      result.add(BoxShadow.lerp(shadowA, shadowB, t)!);
    }

    return result;
  }
}

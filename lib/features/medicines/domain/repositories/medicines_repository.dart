import 'package:dartz/dartz.dart';
import '../entities/medicine_entity.dart';
import '../failures/medicine_failures.dart';

abstract class MedicinesRepository {
  /// جلب جميع الأدوية للمستخدم
  Future<Either<MedicineFailure, List<MedicineEntity>>> getMedicines({
    required String userId,
    MedicineFilter? filter,
    MedicineSort? sort,
  });

  /// جلب دواء واحد بالـ ID
  Future<Either<MedicineFailure, MedicineEntity>> getMedicineById({
    required String medicineId,
  });

  /// جلب الأدوية النشطة فقط
  Future<Either<MedicineFailure, List<MedicineEntity>>> getActiveMedicines({
    required String userId,
  });

  /// جلب الأدوية المجدولة لتاريخ معين
  Future<Either<MedicineFailure, List<MedicineEntity>>> getMedicinesForDate({
    required String userId,
    required DateTime date,
  });

  /// إضافة دواء جديد
  Future<Either<MedicineFailure, MedicineEntity>> addMedicine({
    required MedicineEntity medicine,
  });

  /// تحديث دواء موجود
  Future<Either<MedicineFailure, MedicineEntity>> updateMedicine({
    required MedicineEntity medicine,
  });

  /// حذف دواء
  Future<Either<MedicineFailure, Unit>> deleteMedicine({
    required String medicineId,
  });

  /// حذف أدوية متعددة
  Future<Either<MedicineFailure, Unit>> deleteMedicines({
    required List<String> medicineIds,
  });

  /// تفعيل/إيقاف دواء
  Future<Either<MedicineFailure, MedicineEntity>> toggleMedicineStatus({
    required String medicineId,
    required bool isActive,
  });

  /// تحديث المخزون
  Future<Either<MedicineFailure, MedicineEntity>> updateStock({
    required String medicineId,
    required int newStock,
  });

  /// البحث في الأدوية
  Future<Either<MedicineFailure, List<MedicineEntity>>> searchMedicines({
    required String userId,
    required String query,
  });

  /// جلب سجلات الجرعات لدواء معين
  Future<Either<MedicineFailure, List<DoseLogEntity>>> getDoseLogs({
    required String medicineId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// جلب جرعات اليوم
  Future<Either<MedicineFailure, List<DoseLogEntity>>> getTodayDoses({
    required String userId,
  });

  /// تسجيل جرعة (تم تناولها / تم تخطيها)
  Future<Either<MedicineFailure, DoseLogEntity>> logDose({
    required DoseLogEntity doseLog,
  });

  /// تحديث حالة جرعة
  Future<Either<MedicineFailure, DoseLogEntity>> updateDoseStatus({
    required String doseLogId,
    required DoseStatus status,
    DateTime? takenTime,
    String? notes,
  });

  /// جلب ملخص الالتزام لدواء معين
  Future<Either<MedicineFailure, AdherenceSummaryEntity>> getAdherenceSummary({
    required String userId,
    required String medicineId,
    String? month,
  });

  /// جلب ملخص الالتزام الشامل للمستخدم
  Future<Either<MedicineFailure, AdherenceSummaryEntity>> getOverallAdherence({
    required String userId,
    String? month,
  });

  /// جلب إحصائيات الالتزام الأسبوعية
  Future<Either<MedicineFailure, Map<String, double>>> getWeeklyAdherence({
    required String userId,
    String? medicineId,
  });

  /// مراقبة تغييرات الأدوية (Stream)
  Stream<Either<MedicineFailure, List<MedicineEntity>>> watchMedicines({
    required String userId,
  });

  /// مراقبة تغييرات دواء واحد
  Stream<Either<MedicineFailure, MedicineEntity>> watchMedicine({
    required String medicineId,
  });

  /// مراقبة جرعات اليوم
  Stream<Either<MedicineFailure, List<DoseLogEntity>>> watchTodayDoses({
    required String userId,
  });

  /// التحقق من وجود أدوية تحتاج إعادة تعبئة
  Future<Either<MedicineFailure, List<MedicineEntity>>> getMedicinesNeedingRefill({
    required String userId,
  });

  /// جلب عدد الأدوية
  Future<Either<MedicineFailure, MedicinesCount>> getMedicinesCount({
    required String userId,
  });
}

class MedicineFilter {
  final bool? isActive;
  final bool? isCritical;
  final DosageForm? dosageForm;
  final DayPeriod? dayPeriod;
  final List<String>? medicineIds;

  const MedicineFilter({
    this.isActive,
    this.isCritical,
    this.dosageForm,
    this.dayPeriod,
    this.medicineIds,
  });

  MedicineFilter copyWith({
    bool? isActive,
    bool? isCritical,
    DosageForm? dosageForm,
    DayPeriod? dayPeriod,
    List<String>? medicineIds,
  }) {
    return MedicineFilter(
      isActive: isActive ?? this.isActive,
      isCritical: isCritical ?? this.isCritical,
      dosageForm: dosageForm ?? this.dosageForm,
      dayPeriod: dayPeriod ?? this.dayPeriod,
      medicineIds: medicineIds ?? this.medicineIds,
    );
  }

  bool get hasFilters {
    return isActive != null ||
        isCritical != null ||
        dosageForm != null ||
        dayPeriod != null ||
        (medicineIds != null && medicineIds!.isNotEmpty);
  }

  static const MedicineFilter none = MedicineFilter();

  static const MedicineFilter activeOnly = MedicineFilter(isActive: true);

  static const MedicineFilter criticalOnly = MedicineFilter(isCritical: true);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicineFilter &&
        other.isActive == isActive &&
        other.isCritical == isCritical &&
        other.dosageForm == dosageForm &&
        other.dayPeriod == dayPeriod;
  }

  @override
  int get hashCode => Object.hash(isActive, isCritical, dosageForm, dayPeriod);
}

enum DayPeriod {
  morning,
  afternoon,
  evening,
  night,
}

extension DayPeriodExtension on DayPeriod {
  String get arabicName {
    switch (this) {
      case DayPeriod.morning:
        return 'صباحاً';
      case DayPeriod.afternoon:
        return 'ظهراً';
      case DayPeriod.evening:
        return 'مساءً';
      case DayPeriod.night:
        return 'ليلاً';
    }
  }

  int get startHour {
    switch (this) {
      case DayPeriod.morning:
        return 5;
      case DayPeriod.afternoon:
        return 12;
      case DayPeriod.evening:
        return 17;
      case DayPeriod.night:
        return 21;
    }
  }

  int get endHour {
    switch (this) {
      case DayPeriod.morning:
        return 11;
      case DayPeriod.afternoon:
        return 16;
      case DayPeriod.evening:
        return 20;
      case DayPeriod.night:
        return 4;
    }
  }

  static DayPeriod fromHour(int hour) {
    if (hour >= 5 && hour < 12) return DayPeriod.morning;
    if (hour >= 12 && hour < 17) return DayPeriod.afternoon;
    if (hour >= 17 && hour < 21) return DayPeriod.evening;
    return DayPeriod.night;
  }
}

enum MedicineSort {
  nameAsc,
  nameDesc,
  createdAtAsc,
  createdAtDesc,
  updatedAtAsc,
  updatedAtDesc,
  timeAsc,
  timeDesc,
}

extension MedicineSortExtension on MedicineSort {
  String get arabicName {
    switch (this) {
      case MedicineSort.nameAsc:
        return 'الاسم (أ-ي)';
      case MedicineSort.nameDesc:
        return 'الاسم (ي-أ)';
      case MedicineSort.createdAtAsc:
        return 'تاريخ الإضافة (الأقدم)';
      case MedicineSort.createdAtDesc:
        return 'تاريخ الإضافة (الأحدث)';
      case MedicineSort.updatedAtAsc:
        return 'آخر تحديث (الأقدم)';
      case MedicineSort.updatedAtDesc:
        return 'آخر تحديث (الأحدث)';
      case MedicineSort.timeAsc:
        return 'الوقت (الأول)';
      case MedicineSort.timeDesc:
        return 'الوقت (الأخير)';
    }
  }

  String get field {
    switch (this) {
      case MedicineSort.nameAsc:
      case MedicineSort.nameDesc:
        return 'name';
      case MedicineSort.createdAtAsc:
      case MedicineSort.createdAtDesc:
        return 'createdAt';
      case MedicineSort.updatedAtAsc:
      case MedicineSort.updatedAtDesc:
        return 'updatedAt';
      case MedicineSort.timeAsc:
      case MedicineSort.timeDesc:
        return 'times';
    }
  }

  bool get isDescending {
    switch (this) {
      case MedicineSort.nameDesc:
      case MedicineSort.createdAtDesc:
      case MedicineSort.updatedAtDesc:
      case MedicineSort.timeDesc:
        return true;
      default:
        return false;
    }
  }
}

class MedicinesCount {
  final int total;
  final int active;
  final int inactive;
  final int critical;

  const MedicinesCount({
    required this.total,
    required this.active,
    required this.inactive,
    required this.critical,
  });

  factory MedicinesCount.zero() {
    return const MedicinesCount(
      total: 0,
      active: 0,
      inactive: 0,
      critical: 0,
    );
  }

  factory MedicinesCount.fromMedicines(List<MedicineEntity> medicines) {
    return MedicinesCount(
      total: medicines.length,
      active: medicines.where((m) => m.isActive).length,
      inactive: medicines.where((m) => !m.isActive).length,
      critical: medicines.where((m) => m.isCritical).length,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicinesCount &&
        other.total == total &&
        other.active == active &&
        other.inactive == inactive &&
        other.critical == critical;
  }

  @override
  int get hashCode => Object.hash(total, active, inactive, critical);

  @override
  String toString() {
    return 'MedicinesCount(total: $total, active: $active, '
        'inactive: $inactive, critical: $critical)';
  }
}
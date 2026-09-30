import 'package:flutter/foundation.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 💊 MEDICINE ENTITY - Domain Layer
// ═══════════════════════════════════════════════════════════════════════════════
//
// Updated Features:
// • Grace Period Support (30 minutes default)
// • DoseTimeStatus enum for UI states
// • Enhanced time status helpers
// • Improved isOverdue logic
//
// ═══════════════════════════════════════════════════════════════════════════════

@immutable
class MedicineEntity {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final DosageForm dosageForm;
  final List<String> times;
  final Frequency frequency;
  final bool isActive;
  final bool isCritical;
  final String? instructions;
  final String? notes;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? stockCount;
  final int? refillReminder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicineEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.dosageForm,
    required this.times,
    required this.frequency,
    this.isActive = true,
    this.isCritical = false,
    this.instructions,
    this.notes,
    this.startDate,
    this.endDate,
    this.stockCount,
    this.refillReminder,
    required this.createdAt,
    required this.updatedAt,
  });

  int get dailyDosesCount => times.length;

  bool get hasStock => stockCount != null && stockCount! > 0;

  bool get needsRefill {
    if (stockCount == null || refillReminder == null) return false;
    return stockCount! <= refillReminder!;
  }

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  bool get isScheduledToday {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  int? get remainingDays {
    if (endDate == null) return null;
    final difference = endDate!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  int? get daysOnMedicine {
    if (startDate == null) return null;
    return DateTime.now().difference(startDate!).inDays;
  }

  MedicineEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    DosageForm? dosageForm,
    List<String>? times,
    Frequency? frequency,
    bool? isActive,
    bool? isCritical,
    String? instructions,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    int? stockCount,
    int? refillReminder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicineEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      dosageForm: dosageForm ?? this.dosageForm,
      times: times ?? this.times,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      isCritical: isCritical ?? this.isCritical,
      instructions: instructions ?? this.instructions,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      stockCount: stockCount ?? this.stockCount,
      refillReminder: refillReminder ?? this.refillReminder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicineEntity &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.dosage == dosage &&
        other.dosageForm == dosageForm &&
        listEquals(other.times, times) &&
        other.frequency == frequency &&
        other.isActive == isActive &&
        other.isCritical == isCritical &&
        other.instructions == instructions &&
        other.notes == notes &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.stockCount == stockCount &&
        other.refillReminder == refillReminder;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      name,
      dosage,
      dosageForm,
      Object.hashAll(times),
      frequency,
      isActive,
      isCritical,
      instructions,
      notes,
      startDate,
      endDate,
      stockCount,
      refillReminder,
    );
  }

  @override
  String toString() {
    return 'MedicineEntity(id: $id, name: $name, dosage: $dosage, '
        'dosageForm: ${dosageForm.name}, times: $times, '
        'frequency: ${frequency.name}, isActive: $isActive)';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOSAGE FORM ENUM
// ═══════════════════════════════════════════════════════════════════════════════

enum DosageForm {
  tablet,
  capsule,
  syrup,
  injection,
  drops,
  inhaler,
  cream,
  patch,
  suppository,
  other,
}

extension DosageFormExtension on DosageForm {
  String get arabicName {
    switch (this) {
      case DosageForm.tablet:
        return 'أقراص';
      case DosageForm.capsule:
        return 'كبسولات';
      case DosageForm.syrup:
        return 'شراب';
      case DosageForm.injection:
        return 'حقن';
      case DosageForm.drops:
        return 'قطرات';
      case DosageForm.inhaler:
        return 'بخاخ';
      case DosageForm.cream:
        return 'كريم';
      case DosageForm.patch:
        return 'لصقة';
      case DosageForm.suppository:
        return 'تحاميل';
      case DosageForm.other:
        return 'أخرى';
    }
  }

  String get englishName {
    switch (this) {
      case DosageForm.tablet:
        return 'Tablet';
      case DosageForm.capsule:
        return 'Capsule';
      case DosageForm.syrup:
        return 'Syrup';
      case DosageForm.injection:
        return 'Injection';
      case DosageForm.drops:
        return 'Drops';
      case DosageForm.inhaler:
        return 'Inhaler';
      case DosageForm.cream:
        return 'Cream';
      case DosageForm.patch:
        return 'Patch';
      case DosageForm.suppository:
        return 'Suppository';
      case DosageForm.other:
        return 'Other';
    }
  }

  static DosageForm fromString(String value) {
    switch (value.toLowerCase()) {
      case 'tablet':
      case 'أقراص':
      case 'حبوب':
        return DosageForm.tablet;
      case 'capsule':
      case 'كبسولات':
      case 'كبسولة':
        return DosageForm.capsule;
      case 'syrup':
      case 'شراب':
      case 'محلول':
        return DosageForm.syrup;
      case 'injection':
      case 'حقن':
      case 'إبر':
      case 'إبرة':
        return DosageForm.injection;
      case 'drops':
      case 'قطرات':
      case 'قطرة':
        return DosageForm.drops;
      case 'inhaler':
      case 'بخاخ':
        return DosageForm.inhaler;
      case 'cream':
      case 'كريم':
      case 'مرهم':
        return DosageForm.cream;
      case 'patch':
      case 'لصقة':
        return DosageForm.patch;
      case 'suppository':
      case 'تحاميل':
      case 'تحميلة':
        return DosageForm.suppository;
      default:
        return DosageForm.other;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FREQUENCY ENUM
// ═══════════════════════════════════════════════════════════════════════════════

enum Frequency {
  onceDaily,
  twiceDaily,
  thriceDaily,
  fourTimesDaily,
  everyOtherDay,
  weekly,
  asNeeded,
  custom,
}

extension FrequencyExtension on Frequency {
  String get arabicName {
    switch (this) {
      case Frequency.onceDaily:
        return 'مرة يومياً';
      case Frequency.twiceDaily:
        return 'مرتين يومياً';
      case Frequency.thriceDaily:
        return '3 مرات يومياً';
      case Frequency.fourTimesDaily:
        return '4 مرات يومياً';
      case Frequency.everyOtherDay:
        return 'يوم بعد يوم';
      case Frequency.weekly:
        return 'أسبوعياً';
      case Frequency.asNeeded:
        return 'عند الحاجة';
      case Frequency.custom:
        return 'مخصص';
    }
  }

  String get englishName {
    switch (this) {
      case Frequency.onceDaily:
        return 'Once daily';
      case Frequency.twiceDaily:
        return 'Twice daily';
      case Frequency.thriceDaily:
        return 'Three times daily';
      case Frequency.fourTimesDaily:
        return 'Four times daily';
      case Frequency.everyOtherDay:
        return 'Every other day';
      case Frequency.weekly:
        return 'Weekly';
      case Frequency.asNeeded:
        return 'As needed';
      case Frequency.custom:
        return 'Custom';
    }
  }

  int get expectedDailyDoses {
    switch (this) {
      case Frequency.onceDaily:
        return 1;
      case Frequency.twiceDaily:
        return 2;
      case Frequency.thriceDaily:
        return 3;
      case Frequency.fourTimesDaily:
        return 4;
      case Frequency.everyOtherDay:
        return 1;
      case Frequency.weekly:
        return 1;
      case Frequency.asNeeded:
        return 0;
      case Frequency.custom:
        return 0;
    }
  }

  static Frequency fromString(String value) {
    switch (value.toLowerCase()) {
      case 'oncedaily':
      case 'once_daily':
      case 'مرة يومياً':
        return Frequency.onceDaily;
      case 'twicedaily':
      case 'twice_daily':
      case 'مرتين يومياً':
        return Frequency.twiceDaily;
      case 'thricedaily':
      case 'thrice_daily':
      case '3 مرات يومياً':
        return Frequency.thriceDaily;
      case 'fourtimesdaily':
      case 'four_times_daily':
      case '4 مرات يومياً':
        return Frequency.fourTimesDaily;
      case 'everyotherday':
      case 'every_other_day':
      case 'يوم بعد يوم':
        return Frequency.everyOtherDay;
      case 'weekly':
      case 'أسبوعياً':
        return Frequency.weekly;
      case 'asneeded':
      case 'as_needed':
      case 'عند الحاجة':
        return Frequency.asNeeded;
      default:
        return Frequency.custom;
    }
  }

  static Frequency fromTimesCount(int count) {
    switch (count) {
      case 1:
        return Frequency.onceDaily;
      case 2:
        return Frequency.twiceDaily;
      case 3:
        return Frequency.thriceDaily;
      case 4:
        return Frequency.fourTimesDaily;
      default:
        return Frequency.custom;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOSE TIME STATUS - NEW! 🆕
// ═══════════════════════════════════════════════════════════════════════════════
//
// States:
// • upcoming:      > 5 min before scheduled    → "متبقي X دقيقة"
// • due:           0-5 min before scheduled    → "حان الموعد!"
// • inGracePeriod: 0-30 min after scheduled    → "يمكنك تناوله الآن"
// • overdue:       > 30 min after scheduled    → "فات الموعد"
//
// ═══════════════════════════════════════════════════════════════════════════════

enum DoseTimeStatus {
  upcoming,
  due,
  inGracePeriod,
  overdue,
}

extension DoseTimeStatusExtension on DoseTimeStatus {
  String get arabicName {
    switch (this) {
      case DoseTimeStatus.upcoming:
        return 'قادم';
      case DoseTimeStatus.due:
        return 'حان الموعد';
      case DoseTimeStatus.inGracePeriod:
        return 'يمكنك تناوله الآن';
      case DoseTimeStatus.overdue:
        return 'فات الموعد';
    }
  }

  String get englishName {
    switch (this) {
      case DoseTimeStatus.upcoming:
        return 'Upcoming';
      case DoseTimeStatus.due:
        return 'Due Now';
      case DoseTimeStatus.inGracePeriod:
        return 'In Grace Period';
      case DoseTimeStatus.overdue:
        return 'Overdue';
    }
  }

  bool get canTakeDose {
    return this == DoseTimeStatus.due || this == DoseTimeStatus.inGracePeriod;
  }

  bool get isUrgent {
    return this == DoseTimeStatus.due || this == DoseTimeStatus.overdue;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOSE LOG ENTITY - UPDATED! 🔧
// ═══════════════════════════════════════════════════════════════════════════════

@immutable
class DoseLogEntity {
  final String id;
  final String medicineId;
  final String odId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final DoseStatus status;
  final String? notes;
  final DateTime createdAt;

  const DoseLogEntity({
    required this.id,
    required this.medicineId,
    required this.odId,
    required this.scheduledTime,
    this.takenTime,
    this.status = DoseStatus.pending,
    this.notes,
    required this.createdAt,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GRACE PERIOD CONSTANTS - NEW! 🆕
  // ═══════════════════════════════════════════════════════════════════════════

  /// Grace period in minutes after scheduled time before marking as overdue
  static const int gracePeriodMinutes = 30;

  /// Early reminder window in minutes before scheduled time
  static const int earlyReminderMinutes = 5;

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME STATUS HELPERS - UPDATED! 🔧
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if dose is overdue (past grace period)
  /// Now respects 30-minute grace period instead of immediate
  bool get isOverdue {
    if (status != DoseStatus.pending) return false;
    final graceEnd = scheduledTime.add(const Duration(minutes: gracePeriodMinutes));
    return DateTime.now().isAfter(graceEnd);
  }

  /// Check if dose is currently in grace period
  /// NEW! 🆕
  bool get isInGracePeriod {
    if (status != DoseStatus.pending) return false;
    final now = DateTime.now();
    final graceEnd = scheduledTime.add(const Duration(minutes: gracePeriodMinutes));
    return now.isAfter(scheduledTime) && now.isBefore(graceEnd);
  }

  /// Check if dose is due now (within early reminder window)
  /// NEW! 🆕
  bool get isDueNow {
    if (status != DoseStatus.pending) return false;
    final now = DateTime.now();
    final earlyStart = scheduledTime.subtract(const Duration(minutes: earlyReminderMinutes));
    return now.isAfter(earlyStart) && now.isBefore(scheduledTime);
  }

  /// Check if dose is upcoming (more than early reminder window away)
  /// NEW! 🆕
  bool get isUpcoming {
    if (status != DoseStatus.pending) return false;
    final earlyStart = scheduledTime.subtract(const Duration(minutes: earlyReminderMinutes));
    return DateTime.now().isBefore(earlyStart);
  }

  /// Get current time status
  /// NEW! 🆕
  DoseTimeStatus get timeStatus {
    if (status != DoseStatus.pending) {
      // Already handled (taken, skipped, missed)
      return DoseTimeStatus.upcoming; // Default, won't be shown
    }

    if (isOverdue) return DoseTimeStatus.overdue;
    if (isInGracePeriod) return DoseTimeStatus.inGracePeriod;
    if (isDueNow) return DoseTimeStatus.due;
    return DoseTimeStatus.upcoming;
  }

  /// Get minutes until scheduled time (negative if past)
  /// NEW! 🆕
  int get minutesUntilDue {
    return scheduledTime.difference(DateTime.now()).inMinutes;
  }

  /// Get minutes since scheduled time (negative if before)
  /// NEW! 🆕
  int get minutesSinceDue {
    return DateTime.now().difference(scheduledTime).inMinutes;
  }

  /// Get remaining grace period minutes
  /// NEW! 🆕
  int get remainingGraceMinutes {
    if (!isInGracePeriod) return 0;
    final graceEnd = scheduledTime.add(const Duration(minutes: gracePeriodMinutes));
    return graceEnd.difference(DateTime.now()).inMinutes;
  }

  /// Get human-readable time status message in Arabic
  /// NEW! 🆕
  String get timeStatusMessage {
    switch (timeStatus) {
      case DoseTimeStatus.upcoming:
        final mins = minutesUntilDue;
        if (mins > 60) {
          final hours = mins ~/ 60;
          return 'متبقي $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
        }
        return 'متبقي $mins دقيقة';
      case DoseTimeStatus.due:
        return 'حان موعد الدواء الآن!';
      case DoseTimeStatus.inGracePeriod:
        final remaining = remainingGraceMinutes;
        return 'تناوله الآن (متبقي $remaining دقيقة)';
      case DoseTimeStatus.overdue:
        final mins = minutesSinceDue;
        if (mins > 60) {
          final hours = mins ~/ 60;
          return 'فات الموعد منذ $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
        }
        return 'فات الموعد منذ $mins دقيقة';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXISTING METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  int? get delayMinutes {
    if (takenTime == null) return null;
    return takenTime!.difference(scheduledTime).inMinutes;
  }

  DoseLogEntity copyWith({
    String? id,
    String? medicineId,
    String? odId,
    DateTime? scheduledTime,
    DateTime? takenTime,
    DoseStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return DoseLogEntity(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      odId: odId ?? this.odId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoseLogEntity &&
        other.id == id &&
        other.medicineId == medicineId &&
        other.scheduledTime == scheduledTime &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(id, medicineId, scheduledTime, status);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOSE STATUS ENUM
// ═══════════════════════════════════════════════════════════════════════════════

enum DoseStatus {
  pending,
  taken,
  skipped,
  missed,
}

extension DoseStatusExtension on DoseStatus {
  String get arabicName {
    switch (this) {
      case DoseStatus.pending:
        return 'قيد الانتظار';
      case DoseStatus.taken:
        return 'تم التناول';
      case DoseStatus.skipped:
        return 'تم التخطي';
      case DoseStatus.missed:
        return 'فائتة';
    }
  }

  String get englishName {
    switch (this) {
      case DoseStatus.pending:
        return 'Pending';
      case DoseStatus.taken:
        return 'Taken';
      case DoseStatus.skipped:
        return 'Skipped';
      case DoseStatus.missed:
        return 'Missed';
    }
  }

  static DoseStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'taken':
      case 'تم التناول':
        return DoseStatus.taken;
      case 'skipped':
      case 'تم التخطي':
        return DoseStatus.skipped;
      case 'missed':
      case 'فائتة':
        return DoseStatus.missed;
      default:
        return DoseStatus.pending;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADHERENCE SUMMARY ENTITY
// ═══════════════════════════════════════════════════════════════════════════════

@immutable
class AdherenceSummaryEntity {
  final String odId;
  final String odMonth;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final int skippedDoses;
  final double adherenceRate;
  final int currentStreak;
  final int bestStreak;
  final double avgDelayMinutes;
  final DateTime updatedAt;

  const AdherenceSummaryEntity({
    required this.odId,
    required this.odMonth,
    required this.totalDoses,
    required this.takenDoses,
    this.missedDoses = 0,
    this.skippedDoses = 0,
    required this.adherenceRate,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.avgDelayMinutes = 0,
    required this.updatedAt,
  });

  double get pdcRate {
    if (totalDoses == 0) return 0;
    return (takenDoses / totalDoses) * 100;
  }

  bool get isGoodAdherence => adherenceRate >= 80;

  bool get needsImprovement => adherenceRate < 60;

  AdherenceSummaryEntity copyWith({
    String? odId,
    String? odMonth,
    int? totalDoses,
    int? takenDoses,
    int? missedDoses,
    int? skippedDoses,
    double? adherenceRate,
    int? currentStreak,
    int? bestStreak,
    double? avgDelayMinutes,
    DateTime? updatedAt,
  }) {
    return AdherenceSummaryEntity(
      odId: odId ?? this.odId,
      odMonth: odMonth ?? this.odMonth,
      totalDoses: totalDoses ?? this.totalDoses,
      takenDoses: takenDoses ?? this.takenDoses,
      missedDoses: missedDoses ?? this.missedDoses,
      skippedDoses: skippedDoses ?? this.skippedDoses,
      adherenceRate: adherenceRate ?? this.adherenceRate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      avgDelayMinutes: avgDelayMinutes ?? this.avgDelayMinutes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdherenceSummaryEntity &&
        other.odId == odId &&
        other.odMonth == odMonth &&
        other.totalDoses == totalDoses &&
        other.takenDoses == takenDoses;
  }

  @override
  int get hashCode {
    return Object.hash(odId, odMonth, totalDoses, takenDoses);
  }
}

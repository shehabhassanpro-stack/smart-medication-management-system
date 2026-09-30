import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medicine_entity.dart';

class MedicineModel {
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

  const MedicineModel({
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

  factory MedicineModel.fromEntity(MedicineEntity entity) {
    return MedicineModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      dosage: entity.dosage,
      dosageForm: entity.dosageForm,
      times: entity.times,
      frequency: entity.frequency,
      isActive: entity.isActive,
      isCritical: entity.isCritical,
      instructions: entity.instructions,
      notes: entity.notes,
      startDate: entity.startDate,
      endDate: entity.endDate,
      stockCount: entity.stockCount,
      refillReminder: entity.refillReminder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      dosageForm: DosageFormExtension.fromString(json['dosageForm'] as String? ?? ''),
      times: _parseStringList(json['times']),
      frequency: FrequencyExtension.fromString(json['frequency'] as String? ?? ''),
      isActive: json['isActive'] as bool? ?? true,
      isCritical: json['isCritical'] as bool? ?? false,
      instructions: json['instructions'] as String?,
      notes: json['notes'] as String?,
      startDate: _parseDateTime(json['startDate']),
      endDate: _parseDateTime(json['endDate']),
      stockCount: json['stockCount'] as int?,
      refillReminder: json['refillReminder'] as int?,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
    );
  }

  factory MedicineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MedicineModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'dosageForm': dosageForm.name,
      'times': times,
      'frequency': frequency.name,
      'isActive': isActive,
      'isCritical': isCritical,
      'instructions': instructions,
      'notes': notes,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'stockCount': stockCount,
      'refillReminder': refillReminder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'dosageForm': dosageForm.name,
      'times': times,
      'frequency': frequency.name,
      'isActive': isActive,
      'isCritical': isCritical,
      'instructions': instructions,
      'notes': notes,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'stockCount': stockCount,
      'refillReminder': refillReminder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MedicineEntity toEntity() {
    return MedicineEntity(
      id: id,
      userId: userId,
      name: name,
      dosage: dosage,
      dosageForm: dosageForm,
      times: times,
      frequency: frequency,
      isActive: isActive,
      isCritical: isCritical,
      instructions: instructions,
      notes: notes,
      startDate: startDate,
      endDate: endDate,
      stockCount: stockCount,
      refillReminder: refillReminder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class DoseLogModel {
  final String id;
  final String medicineId;
  final String odId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final DoseStatus status;
  final String? notes;
  final DateTime createdAt;

  const DoseLogModel({
    required this.id,
    required this.medicineId,
    required this.odId,
    required this.scheduledTime,
    this.takenTime,
    this.status = DoseStatus.pending,
    this.notes,
    required this.createdAt,
  });

  factory DoseLogModel.fromEntity(DoseLogEntity entity) {
    return DoseLogModel(
      id: entity.id,
      medicineId: entity.medicineId,
      odId: entity.odId,
      scheduledTime: entity.scheduledTime,
      takenTime: entity.takenTime,
      status: entity.status,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  factory DoseLogModel.fromJson(Map<String, dynamic> json) {
    return DoseLogModel(
      id: json['id'] as String? ?? '',
      medicineId: json['medicineId'] as String? ?? '',
      odId: json['odId'] as String? ?? json['userId'] as String? ?? '',
      scheduledTime: _parseDateTime(json['scheduledTime']) ?? DateTime.now(),
      takenTime: _parseDateTime(json['takenTime']),
      status: DoseStatusExtension.fromString(json['status'] as String? ?? ''),
      notes: json['notes'] as String?,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  factory DoseLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DoseLogModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'odId': odId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'medicineId': medicineId,
      'odId': odId,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'status': status.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DoseLogEntity toEntity() {
    return DoseLogEntity(
      id: id,
      medicineId: medicineId,
      odId: odId,
      scheduledTime: scheduledTime,
      takenTime: takenTime,
      status: status,
      notes: notes,
      createdAt: createdAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class AdherenceSummaryModel {
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

  const AdherenceSummaryModel({
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

  factory AdherenceSummaryModel.fromEntity(AdherenceSummaryEntity entity) {
    return AdherenceSummaryModel(
      odId: entity.odId,
      odMonth: entity.odMonth,
      totalDoses: entity.totalDoses,
      takenDoses: entity.takenDoses,
      missedDoses: entity.missedDoses,
      skippedDoses: entity.skippedDoses,
      adherenceRate: entity.adherenceRate,
      currentStreak: entity.currentStreak,
      bestStreak: entity.bestStreak,
      avgDelayMinutes: entity.avgDelayMinutes,
      updatedAt: entity.updatedAt,
    );
  }

  factory AdherenceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdherenceSummaryModel(
      odId: json['odId'] as String? ?? json['userId'] as String? ?? '',
      odMonth: json['odMonth'] as String? ?? json['month'] as String? ?? '',
      totalDoses: json['totalDoses'] as int? ?? 0,
      takenDoses: json['takenDoses'] as int? ?? 0,
      missedDoses: json['missedDoses'] as int? ?? 0,
      skippedDoses: json['skippedDoses'] as int? ?? 0,
      adherenceRate: (json['adherenceRate'] as num?)?.toDouble() ?? 0.0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      avgDelayMinutes: (json['avgDelayMinutes'] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
    );
  }

  factory AdherenceSummaryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AdherenceSummaryModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'odId': odId,
      'odMonth': odMonth,
      'totalDoses': totalDoses,
      'takenDoses': takenDoses,
      'missedDoses': missedDoses,
      'skippedDoses': skippedDoses,
      'adherenceRate': adherenceRate,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'avgDelayMinutes': avgDelayMinutes,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'odId': odId,
      'odMonth': odMonth,
      'totalDoses': totalDoses,
      'takenDoses': takenDoses,
      'missedDoses': missedDoses,
      'skippedDoses': skippedDoses,
      'adherenceRate': adherenceRate,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'avgDelayMinutes': avgDelayMinutes,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AdherenceSummaryEntity toEntity() {
    return AdherenceSummaryEntity(
      odId: odId,
      odMonth: odMonth,
      totalDoses: totalDoses,
      takenDoses: takenDoses,
      missedDoses: missedDoses,
      skippedDoses: skippedDoses,
      adherenceRate: adherenceRate,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      avgDelayMinutes: avgDelayMinutes,
      updatedAt: updatedAt,
    );
  }

  factory AdherenceSummaryModel.empty({
    required String odId,
    String? odMonth,
  }) {
    final now = DateTime.now();
    return AdherenceSummaryModel(
      odId: odId,
      odMonth: odMonth ?? '${now.year}-${now.month.toString().padLeft(2, '0')}',
      totalDoses: 0,
      takenDoses: 0,
      missedDoses: 0,
      skippedDoses: 0,
      adherenceRate: 0.0,
      currentStreak: 0,
      bestStreak: 0,
      avgDelayMinutes: 0.0,
      updatedAt: now,
    );
  }

  factory AdherenceSummaryModel.calculate({
    required String odId,
    required String odMonth,
    required List<DoseLogEntity> doseLogs,
  }) {
    final totalDoses = doseLogs.length;
    final takenDoses = doseLogs.where((d) => d.status == DoseStatus.taken).length;
    final missedDoses = doseLogs.where((d) => d.status == DoseStatus.missed).length;
    final skippedDoses = doseLogs.where((d) => d.status == DoseStatus.skipped).length;

    final adherenceRate = totalDoses > 0 ? (takenDoses / totalDoses) * 100 : 0.0;

    final takenLogs = doseLogs.where((d) => d.status == DoseStatus.taken).toList();
    double avgDelay = 0.0;
    if (takenLogs.isNotEmpty) {
      int totalDelay = 0;
      for (final log in takenLogs) {
        final delay = log.delayMinutes;
        if (delay != null) {
          totalDelay += delay;
        }
      }
      avgDelay = totalDelay / takenLogs.length;
    }

    final streaks = _calculateStreaks(doseLogs);

    return AdherenceSummaryModel(
      odId: odId,
      odMonth: odMonth,
      totalDoses: totalDoses,
      takenDoses: takenDoses,
      missedDoses: missedDoses,
      skippedDoses: skippedDoses,
      adherenceRate: adherenceRate,
      currentStreak: streaks['current'] ?? 0,
      bestStreak: streaks['best'] ?? 0,
      avgDelayMinutes: avgDelay,
      updatedAt: DateTime.now(),
    );
  }

  static Map<String, int> _calculateStreaks(List<DoseLogEntity> doseLogs) {
    if (doseLogs.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    final sortedLogs = List<DoseLogEntity>.from(doseLogs)
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    int currentStreak = 0;
    int bestStreak = 0;
    int tempStreak = 0;

    for (final log in sortedLogs) {
      if (log.status == DoseStatus.taken) {
        tempStreak++;
        if (tempStreak > bestStreak) {
          bestStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
    }

    for (int i = sortedLogs.length - 1; i >= 0; i--) {
      if (sortedLogs[i].status == DoseStatus.taken) {
        currentStreak++;
      } else {
        break;
      }
    }

    return {'current': currentStreak, 'best': bestStreak};
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
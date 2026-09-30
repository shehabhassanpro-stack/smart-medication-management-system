import 'package:dartz/dartz.dart';
import '../entities/medicine_entity.dart';
import '../failures/medicine_failures.dart';
import '../repositories/medicines_repository.dart';

class GetTodayDosesUseCase {
  final MedicinesRepository repository;

  const GetTodayDosesUseCase(this.repository);

  Future<Either<MedicineFailure, List<DoseLogEntity>>> call(String userId) async {
    if (userId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف المستخدم مطلوب',
      ));
    }

    return await repository.getTodayDoses(userId: userId);
  }
}

class GetDoseLogsUseCase {
  final MedicinesRepository repository;

  const GetDoseLogsUseCase(this.repository);

  Future<Either<MedicineFailure, List<DoseLogEntity>>> call(
      GetDoseLogsParams params,
      ) async {
    if (params.medicineId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف الدواء مطلوب',
      ));
    }

    if (params.startDate != null && params.endDate != null) {
      if (params.endDate!.isBefore(params.startDate!)) {
        return Left(MedicineValidationFailure(
          message: 'تاريخ النهاية يجب أن يكون بعد تاريخ البداية',
        ));
      }
    }

    return await repository.getDoseLogs(
      medicineId: params.medicineId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetDoseLogsParams {
  final String medicineId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetDoseLogsParams({
    required this.medicineId,
    this.startDate,
    this.endDate,
  });

  factory GetDoseLogsParams.lastWeek(String medicineId) {
    final now = DateTime.now();
    return GetDoseLogsParams(
      medicineId: medicineId,
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now,
    );
  }

  factory GetDoseLogsParams.lastMonth(String medicineId) {
    final now = DateTime.now();
    return GetDoseLogsParams(
      medicineId: medicineId,
      startDate: DateTime(now.year, now.month - 1, now.day),
      endDate: now,
    );
  }

  factory GetDoseLogsParams.thisMonth(String medicineId) {
    final now = DateTime.now();
    return GetDoseLogsParams(
      medicineId: medicineId,
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetDoseLogsParams && other.medicineId == medicineId;
  }

  @override
  int get hashCode => medicineId.hashCode;
}

class LogDoseUseCase {
  final MedicinesRepository repository;

  const LogDoseUseCase(this.repository);

  Future<Either<MedicineFailure, DoseLogEntity>> call(LogDoseParams params) async {
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    final doseLog = DoseLogEntity(
      id: params.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      medicineId: params.medicineId,
      odId: params.userId,
      scheduledTime: params.scheduledTime,
      takenTime: params.status == DoseStatus.taken ? (params.takenTime ?? DateTime.now()) : null,
      status: params.status,
      notes: params.notes?.trim(),
      createdAt: DateTime.now(),
    );

    return await repository.logDose(doseLog: doseLog);
  }

  MedicineFailure? _validateParams(LogDoseParams params) {
    if (params.medicineId.isEmpty) {
      return MedicineValidationFailure(
        message: 'معرف الدواء مطلوب',
      );
    }

    if (params.userId.isEmpty) {
      return MedicineValidationFailure(
        message: 'معرف المستخدم مطلوب',
      );
    }

    return null;
  }
}

class LogDoseParams {
  final String? id;
  final String medicineId;
  final String userId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final DoseStatus status;
  final String? notes;

  const LogDoseParams({
    this.id,
    required this.medicineId,
    required this.userId,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.notes,
  });

  factory LogDoseParams.taken({
    required String medicineId,
    required String userId,
    required DateTime scheduledTime,
    DateTime? takenTime,
    String? notes,
  }) {
    return LogDoseParams(
      medicineId: medicineId,
      userId: userId,
      scheduledTime: scheduledTime,
      takenTime: takenTime ?? DateTime.now(),
      status: DoseStatus.taken,
      notes: notes,
    );
  }

  factory LogDoseParams.skipped({
    required String medicineId,
    required String userId,
    required DateTime scheduledTime,
    String? notes,
  }) {
    return LogDoseParams(
      medicineId: medicineId,
      userId: userId,
      scheduledTime: scheduledTime,
      status: DoseStatus.skipped,
      notes: notes,
    );
  }

  factory LogDoseParams.missed({
    required String medicineId,
    required String userId,
    required DateTime scheduledTime,
  }) {
    return LogDoseParams(
      medicineId: medicineId,
      userId: userId,
      scheduledTime: scheduledTime,
      status: DoseStatus.missed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogDoseParams &&
        other.medicineId == medicineId &&
        other.scheduledTime == scheduledTime;
  }

  @override
  int get hashCode => Object.hash(medicineId, scheduledTime);
}

class UpdateDoseStatusUseCase {
  final MedicinesRepository repository;

  const UpdateDoseStatusUseCase(this.repository);

  Future<Either<MedicineFailure, DoseLogEntity>> call(
      UpdateDoseStatusParams params,
      ) async {
    if (params.doseLogId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف سجل الجرعة مطلوب',
      ));
    }

    return await repository.updateDoseStatus(
      doseLogId: params.doseLogId,
      status: params.status,
      takenTime: params.takenTime,
      notes: params.notes,
    );
  }
}

class UpdateDoseStatusParams {
  final String doseLogId;
  final DoseStatus status;
  final DateTime? takenTime;
  final String? notes;

  const UpdateDoseStatusParams({
    required this.doseLogId,
    required this.status,
    this.takenTime,
    this.notes,
  });

  factory UpdateDoseStatusParams.markTaken(String doseLogId, {String? notes}) {
    return UpdateDoseStatusParams(
      doseLogId: doseLogId,
      status: DoseStatus.taken,
      takenTime: DateTime.now(),
      notes: notes,
    );
  }

  factory UpdateDoseStatusParams.markSkipped(String doseLogId, {String? notes}) {
    return UpdateDoseStatusParams(
      doseLogId: doseLogId,
      status: DoseStatus.skipped,
      notes: notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateDoseStatusParams && other.doseLogId == doseLogId;
  }

  @override
  int get hashCode => doseLogId.hashCode;
}

class GetAdherenceSummaryUseCase {
  final MedicinesRepository repository;

  const GetAdherenceSummaryUseCase(this.repository);

  Future<Either<MedicineFailure, AdherenceSummaryEntity>> call(
      GetAdherenceParams params,
      ) async {
    if (params.userId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف المستخدم مطلوب',
      ));
    }

    if (params.medicineId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف الدواء مطلوب',
      ));
    }

    return await repository.getAdherenceSummary(
      userId: params.userId,
      medicineId: params.medicineId,
      month: params.month,
    );
  }
}

class GetAdherenceParams {
  final String userId;
  final String medicineId;
  final String? month;

  const GetAdherenceParams({
    required this.userId,
    required this.medicineId,
    this.month,
  });

  factory GetAdherenceParams.currentMonth({
    required String userId,
    required String medicineId,
  }) {
    final now = DateTime.now();
    return GetAdherenceParams(
      userId: userId,
      medicineId: medicineId,
      month: '${now.year}-${now.month.toString().padLeft(2, '0')}',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetAdherenceParams &&
        other.userId == userId &&
        other.medicineId == medicineId;
  }

  @override
  int get hashCode => Object.hash(userId, medicineId);
}

class GetOverallAdherenceUseCase {
  final MedicinesRepository repository;

  const GetOverallAdherenceUseCase(this.repository);

  Future<Either<MedicineFailure, AdherenceSummaryEntity>> call(
      GetOverallAdherenceParams params,
      ) async {
    if (params.userId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف المستخدم مطلوب',
      ));
    }

    return await repository.getOverallAdherence(
      userId: params.userId,
      month: params.month,
    );
  }
}

class GetOverallAdherenceParams {
  final String userId;
  final String? month;

  const GetOverallAdherenceParams({
    required this.userId,
    this.month,
  });

  factory GetOverallAdherenceParams.currentMonth(String userId) {
    final now = DateTime.now();
    return GetOverallAdherenceParams(
      userId: userId,
      month: '${now.year}-${now.month.toString().padLeft(2, '0')}',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetOverallAdherenceParams && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

class GetWeeklyAdherenceUseCase {
  final MedicinesRepository repository;

  const GetWeeklyAdherenceUseCase(this.repository);

  Future<Either<MedicineFailure, Map<String, double>>> call(
      GetWeeklyAdherenceParams params,
      ) async {
    if (params.userId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف المستخدم مطلوب',
      ));
    }

    return await repository.getWeeklyAdherence(
      userId: params.userId,
      medicineId: params.medicineId,
    );
  }
}

class GetWeeklyAdherenceParams {
  final String userId;
  final String? medicineId;

  const GetWeeklyAdherenceParams({
    required this.userId,
    this.medicineId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetWeeklyAdherenceParams && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

class WatchTodayDosesUseCase {
  final MedicinesRepository repository;

  const WatchTodayDosesUseCase(this.repository);

  Stream<Either<MedicineFailure, List<DoseLogEntity>>> call(String userId) {
    return repository.watchTodayDoses(userId: userId);
  }
}
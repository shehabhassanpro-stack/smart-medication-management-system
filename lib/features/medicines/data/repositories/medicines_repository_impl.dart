import 'package:dartz/dartz.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/failures/medicine_failures.dart';
import '../../domain/repositories/medicines_repository.dart';
import '../datasources/medicines_remote_datasource.dart';
import '../models/medicine_model.dart';

class MedicinesRepositoryImpl implements MedicinesRepository {
  final MedicinesRemoteDataSource _remoteDataSource;

  MedicinesRepositoryImpl({
    required MedicinesRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<MedicineFailure, List<MedicineEntity>>> getMedicines({
    required String userId,
    MedicineFilter? filter,
    MedicineSort? sort,
  }) async {
    try {
      final models = await _remoteDataSource.getMedicines(
        userId: userId,
        filter: filter,
        sort: sort,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on MedicineNotFoundException catch (e) {
      return Left(MedicineNotFoundFailure(medicineId: e.medicineId));
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, MedicineEntity>> getMedicineById({
    required String medicineId,
  }) async {
    try {
      final model = await _remoteDataSource.getMedicineById(
        medicineId: medicineId,
      );
      return Right(model.toEntity());
    } on MedicineNotFoundException catch (e) {
      return Left(MedicineNotFoundFailure(medicineId: e.medicineId));
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, List<MedicineEntity>>> getActiveMedicines({
    required String userId,
  }) async {
    try {
      final models = await _remoteDataSource.getActiveMedicines(
        userId: userId,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, List<MedicineEntity>>> getMedicinesForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final models = await _remoteDataSource.getMedicinesForDate(
        userId: userId,
        date: date,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, MedicineEntity>> addMedicine({
    required MedicineEntity medicine,
  }) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      final result = await _remoteDataSource.addMedicine(medicine: model);
      return Right(result.toEntity());
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, MedicineEntity>> updateMedicine({
    required MedicineEntity medicine,
  }) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      final result = await _remoteDataSource.updateMedicine(medicine: model);
      return Right(result.toEntity());
    } on MedicineNotFoundException catch (e) {
      return Left(MedicineNotFoundFailure(medicineId: e.medicineId));
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, Unit>> deleteMedicine({
    required String medicineId,
  }) async {
    try {
      await _remoteDataSource.deleteMedicine(medicineId: medicineId);
      return const Right(unit);
    } on MedicineNotFoundException catch (e) {
      return Left(MedicineNotFoundFailure(medicineId: e.medicineId));
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, Unit>> deleteMedicines({
    required List<String> medicineIds,
  }) async {
    try {
      await _remoteDataSource.deleteMedicines(medicineIds: medicineIds);
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, MedicineEntity>> toggleMedicineStatus({
    required String medicineId,
    required bool isActive,
  }) async {
    try {
      final result = await _remoteDataSource.toggleMedicineStatus(
        medicineId: medicineId,
        isActive: isActive,
      );
      return Right(result.toEntity());
    } on MedicineNotFoundException catch (e) {
      return Left(MedicineNotFoundFailure(medicineId: e.medicineId));
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, MedicineEntity>> updateStock({
    required String medicineId,
    required int newStock,
  }) async {
    try {
      final result = await _remoteDataSource.updateStock(
        medicineId: medicineId,
        newStock: newStock,
      );
      return Right(result.toEntity());
    } on MedicineNotFoundException catch (e) {
      return Left(MedicineNotFoundFailure(medicineId: e.medicineId));
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, List<MedicineEntity>>> searchMedicines({
    required String userId,
    required String query,
  }) async {
    try {
      final models = await _remoteDataSource.searchMedicines(
        userId: userId,
        query: query,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, List<DoseLogEntity>>> getDoseLogs({
    required String medicineId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await _remoteDataSource.getDoseLogs(
        medicineId: medicineId,
        startDate: startDate,
        endDate: endDate,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, List<DoseLogEntity>>> getTodayDoses({
    required String userId,
  }) async {
    try {
      final models = await _remoteDataSource.getTodayDoses(userId: userId);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, DoseLogEntity>> logDose({
    required DoseLogEntity doseLog,
  }) async {
    try {
      final model = DoseLogModel.fromEntity(doseLog);
      final result = await _remoteDataSource.logDose(doseLog: model);
      return Right(result.toEntity());
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, DoseLogEntity>> updateDoseStatus({
    required String doseLogId,
    required DoseStatus status,
    DateTime? takenTime,
    String? notes,
  }) async {
    try {
      final result = await _remoteDataSource.updateDoseStatus(
        doseLogId: doseLogId,
        status: status,
        takenTime: takenTime,
        notes: notes,
      );
      return Right(result.toEntity());
    } on DoseLogNotFoundException catch (e) {
      return Left(DoseLogNotFoundFailure(doseLogId: e.doseLogId));
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, AdherenceSummaryEntity>> getAdherenceSummary({
    required String userId,
    required String medicineId,
    String? month,
  }) async {
    try {
      final model = await _remoteDataSource.getAdherenceSummary(
        userId: userId,
        medicineId: medicineId,
        month: month,
      );
      return Right(model.toEntity());
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, AdherenceSummaryEntity>> getOverallAdherence({
    required String userId,
    String? month,
  }) async {
    try {
      final model = await _remoteDataSource.getOverallAdherence(
        userId: userId,
        month: month,
      );
      return Right(model.toEntity());
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, Map<String, double>>> getWeeklyAdherence({
    required String userId,
    String? medicineId,
  }) async {
    try {
      final result = await _remoteDataSource.getWeeklyAdherence(
        userId: userId,
        medicineId: medicineId,
      );
      return Right(result);
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Stream<Either<MedicineFailure, List<MedicineEntity>>> watchMedicines({
    required String userId,
  }) {
    return _remoteDataSource.watchMedicines(userId: userId).map((models) {
      try {
        final entities = models.map((m) => m.toEntity()).toList();
        return Right<MedicineFailure, List<MedicineEntity>>(entities);
      } catch (e, stackTrace) {
        return Left<MedicineFailure, List<MedicineEntity>>(
          _handleException(e, stackTrace),
        );
      }
    }).handleError((e, stackTrace) {
      return Left<MedicineFailure, List<MedicineEntity>>(
        _handleException(e, stackTrace),
      );
    });
  }

  @override
  Stream<Either<MedicineFailure, MedicineEntity>> watchMedicine({
    required String medicineId,
  }) {
    return _remoteDataSource.watchMedicine(medicineId: medicineId).map((model) {
      try {
        return Right<MedicineFailure, MedicineEntity>(model.toEntity());
      } catch (e, stackTrace) {
        return Left<MedicineFailure, MedicineEntity>(
          _handleException(e, stackTrace),
        );
      }
    }).handleError((e, stackTrace) {
      if (e is MedicineNotFoundException) {
        return Left<MedicineFailure, MedicineEntity>(
          MedicineNotFoundFailure(medicineId: e.medicineId),
        );
      }
      return Left<MedicineFailure, MedicineEntity>(
        _handleException(e, stackTrace),
      );
    });
  }

  @override
  Stream<Either<MedicineFailure, List<DoseLogEntity>>> watchTodayDoses({
    required String userId,
  }) {
    return _remoteDataSource.watchTodayDoses(userId: userId).map((models) {
      try {
        final entities = models.map((m) => m.toEntity()).toList();
        return Right<MedicineFailure, List<DoseLogEntity>>(entities);
      } catch (e, stackTrace) {
        return Left<MedicineFailure, List<DoseLogEntity>>(
          _handleException(e, stackTrace),
        );
      }
    }).handleError((e, stackTrace) {
      return Left<MedicineFailure, List<DoseLogEntity>>(
        _handleException(e, stackTrace),
      );
    });
  }

  @override
  Future<Either<MedicineFailure, List<MedicineEntity>>> getMedicinesNeedingRefill({
    required String userId,
  }) async {
    try {
      final models = await _remoteDataSource.getMedicinesNeedingRefill(
        userId: userId,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<MedicineFailure, MedicinesCount>> getMedicinesCount({
    required String userId,
  }) async {
    try {
      final result = await _remoteDataSource.getMedicinesCount(userId: userId);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(_handleException(e, stackTrace));
    }
  }

  MedicineFailure _handleException(dynamic exception, StackTrace stackTrace) {
    if (exception is MedicineNotFoundException) {
      return MedicineNotFoundFailure(
        medicineId: exception.medicineId,
        stackTrace: stackTrace,
      );
    }

    if (exception is DoseLogNotFoundException) {
      return DoseLogNotFoundFailure(
        doseLogId: exception.doseLogId,
        stackTrace: stackTrace,
      );
    }

    final exceptionString = exception.toString().toLowerCase();

    if (exceptionString.contains('network') ||
        exceptionString.contains('socket') ||
        exceptionString.contains('connection') ||
        exceptionString.contains('unreachable')) {
      return MedicineNetworkFailure(stackTrace: stackTrace);
    }

    if (exceptionString.contains('timeout') ||
        exceptionString.contains('timed out')) {
      return MedicineTimeoutFailure(stackTrace: stackTrace);
    }

    if (exceptionString.contains('permission') ||
        exceptionString.contains('denied') ||
        exceptionString.contains('forbidden')) {
      return MedicinePermissionFailure(stackTrace: stackTrace);
    }

    if (exceptionString.contains('unauthenticated') ||
        exceptionString.contains('unauthorized') ||
        exceptionString.contains('not authenticated')) {
      return MedicineUnauthorizedFailure(stackTrace: stackTrace);
    }

    if (exceptionString.contains('not found') ||
        exceptionString.contains('does not exist')) {
      return MedicineNotFoundFailure(stackTrace: stackTrace);
    }

    if (exceptionString.contains('already exists') ||
        exceptionString.contains('duplicate')) {
      return DuplicateMedicineFailure(stackTrace: stackTrace);
    }

    if (exceptionString.contains('server') ||
        exceptionString.contains('internal') ||
        exceptionString.contains('500')) {
      return MedicineServerFailure(stackTrace: stackTrace);
    }

    return MedicineUnexpectedFailure(
      message: exception.toString(),
      stackTrace: stackTrace,
    );
  }
}
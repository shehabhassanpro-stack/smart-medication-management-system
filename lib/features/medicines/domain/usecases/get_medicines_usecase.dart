import 'package:dartz/dartz.dart';
import '../entities/medicine_entity.dart';
import '../failures/medicine_failures.dart';
import '../repositories/medicines_repository.dart';

abstract class UseCase<Type, Params> {
  Future<Either<MedicineFailure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

class GetMedicinesUseCase implements UseCase<List<MedicineEntity>, GetMedicinesParams> {
  final MedicinesRepository repository;

  const GetMedicinesUseCase(this.repository);

  @override
  Future<Either<MedicineFailure, List<MedicineEntity>>> call(GetMedicinesParams params) async {
    return await repository.getMedicines(
      userId: params.userId,
      filter: params.filter,
      sort: params.sort,
    );
  }
}

class GetMedicinesParams {
  final String userId;
  final MedicineFilter? filter;
  final MedicineSort? sort;

  const GetMedicinesParams({
    required this.userId,
    this.filter,
    this.sort,
  });

  GetMedicinesParams copyWith({
    String? userId,
    MedicineFilter? filter,
    MedicineSort? sort,
  }) {
    return GetMedicinesParams(
      userId: userId ?? this.userId,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetMedicinesParams &&
        other.userId == userId &&
        other.filter == filter &&
        other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(userId, filter, sort);
}

class GetMedicineByIdUseCase implements UseCase<MedicineEntity, String> {
  final MedicinesRepository repository;

  const GetMedicineByIdUseCase(this.repository);

  @override
  Future<Either<MedicineFailure, MedicineEntity>> call(String medicineId) async {
    return await repository.getMedicineById(medicineId: medicineId);
  }
}

class GetActiveMedicinesUseCase implements UseCase<List<MedicineEntity>, String> {
  final MedicinesRepository repository;

  const GetActiveMedicinesUseCase(this.repository);

  @override
  Future<Either<MedicineFailure, List<MedicineEntity>>> call(String userId) async {
    return await repository.getActiveMedicines(userId: userId);
  }
}

class GetMedicinesForDateUseCase implements UseCase<List<MedicineEntity>, GetMedicinesForDateParams> {
  final MedicinesRepository repository;

  const GetMedicinesForDateUseCase(this.repository);

  @override
  Future<Either<MedicineFailure, List<MedicineEntity>>> call(GetMedicinesForDateParams params) async {
    return await repository.getMedicinesForDate(
      userId: params.userId,
      date: params.date,
    );
  }
}

class GetMedicinesForDateParams {
  final String userId;
  final DateTime date;

  const GetMedicinesForDateParams({
    required this.userId,
    required this.date,
  });

  factory GetMedicinesForDateParams.today(String userId) {
    return GetMedicinesForDateParams(
      userId: userId,
      date: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GetMedicinesForDateParams &&
        other.userId == userId &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day;
  }

  @override
  int get hashCode => Object.hash(userId, date.year, date.month, date.day);
}

class SearchMedicinesUseCase implements UseCase<List<MedicineEntity>, SearchMedicinesParams> {
  final MedicinesRepository repository;

  const SearchMedicinesUseCase(this.repository);

  @override
  Future<Either<MedicineFailure, List<MedicineEntity>>> call(SearchMedicinesParams params) async {
    if (params.query.trim().isEmpty) {
      return const Right([]);
    }
    return await repository.searchMedicines(
      userId: params.userId,
      query: params.query.trim(),
    );
  }
}

class SearchMedicinesParams {
  final String userId;
  final String query;

  const SearchMedicinesParams({
    required this.userId,
    required this.query,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchMedicinesParams &&
        other.userId == userId &&
        other.query == query;
  }

  @override
  int get hashCode => Object.hash(userId, query);
}

class GetMedicinesCountUseCase implements UseCase<MedicinesCount, String> {
  final MedicinesRepository repository;

  const GetMedicinesCountUseCase(this.repository);

  @override
  Future<Either<MedicineFailure, MedicinesCount>> call(String userId) async {
    return await repository.getMedicinesCount(userId: userId);
  }
}

class GetMedicinesNeedingRefillUseCase implements UseCase<List<MedicineEntity>, String> {
  final MedicinesRepository repository;

  const GetMedicinesNeedingRefillUseCase(this.repository);

  @override
  Future<Either<MedicineFailure, List<MedicineEntity>>> call(String userId) async {
    return await repository.getMedicinesNeedingRefill(userId: userId);
  }
}

class WatchMedicinesUseCase {
  final MedicinesRepository repository;

  const WatchMedicinesUseCase(this.repository);

  Stream<Either<MedicineFailure, List<MedicineEntity>>> call(String userId) {
    return repository.watchMedicines(userId: userId);
  }
}

class WatchMedicineUseCase {
  final MedicinesRepository repository;

  const WatchMedicineUseCase(this.repository);

  Stream<Either<MedicineFailure, MedicineEntity>> call(String medicineId) {
    return repository.watchMedicine(medicineId: medicineId);
  }
}
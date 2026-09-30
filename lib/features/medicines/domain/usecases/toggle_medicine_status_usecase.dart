import 'package:dartz/dartz.dart';
import '../entities/medicine_entity.dart';
import '../failures/medicine_failures.dart';
import '../repositories/medicines_repository.dart';

class ToggleMedicineStatusUseCase {
  final MedicinesRepository repository;

  const ToggleMedicineStatusUseCase(this.repository);

  Future<Either<MedicineFailure, MedicineEntity>> call(
      ToggleMedicineStatusParams params,
      ) async {
    if (params.medicineId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف الدواء مطلوب',
      ));
    }

    return await repository.toggleMedicineStatus(
      medicineId: params.medicineId,
      isActive: params.isActive,
    );
  }
}

class ToggleMedicineStatusParams {
  final String medicineId;
  final bool isActive;

  const ToggleMedicineStatusParams({
    required this.medicineId,
    required this.isActive,
  });

  factory ToggleMedicineStatusParams.activate(String medicineId) {
    return ToggleMedicineStatusParams(
      medicineId: medicineId,
      isActive: true,
    );
  }

  factory ToggleMedicineStatusParams.deactivate(String medicineId) {
    return ToggleMedicineStatusParams(
      medicineId: medicineId,
      isActive: false,
    );
  }

  ToggleMedicineStatusParams toggle() {
    return ToggleMedicineStatusParams(
      medicineId: medicineId,
      isActive: !isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToggleMedicineStatusParams &&
        other.medicineId == medicineId &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(medicineId, isActive);
}

class ActivateMedicineUseCase {
  final MedicinesRepository repository;

  const ActivateMedicineUseCase(this.repository);

  Future<Either<MedicineFailure, MedicineEntity>> call(String medicineId) async {
    if (medicineId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف الدواء مطلوب',
      ));
    }

    return await repository.toggleMedicineStatus(
      medicineId: medicineId,
      isActive: true,
    );
  }
}

class DeactivateMedicineUseCase {
  final MedicinesRepository repository;

  const DeactivateMedicineUseCase(this.repository);

  Future<Either<MedicineFailure, MedicineEntity>> call(String medicineId) async {
    if (medicineId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف الدواء مطلوب',
      ));
    }

    return await repository.toggleMedicineStatus(
      medicineId: medicineId,
      isActive: false,
    );
  }
}

class ToggleMedicineCriticalUseCase {
  final MedicinesRepository repository;

  const ToggleMedicineCriticalUseCase(this.repository);

  Future<Either<MedicineFailure, MedicineEntity>> call(
      ToggleCriticalParams params,
      ) async {
    if (params.medicineId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف الدواء مطلوب',
      ));
    }

    final existingResult = await repository.getMedicineById(
      medicineId: params.medicineId,
    );

    return existingResult.fold(
          (failure) => Left(failure),
          (medicine) async {
        final updatedMedicine = medicine.copyWith(
          isCritical: params.isCritical,
          updatedAt: DateTime.now(),
        );
        return await repository.updateMedicine(medicine: updatedMedicine);
      },
    );
  }
}

class ToggleCriticalParams {
  final String medicineId;
  final bool isCritical;

  const ToggleCriticalParams({
    required this.medicineId,
    required this.isCritical,
  });

  factory ToggleCriticalParams.markCritical(String medicineId) {
    return ToggleCriticalParams(
      medicineId: medicineId,
      isCritical: true,
    );
  }

  factory ToggleCriticalParams.unmarkCritical(String medicineId) {
    return ToggleCriticalParams(
      medicineId: medicineId,
      isCritical: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToggleCriticalParams &&
        other.medicineId == medicineId &&
        other.isCritical == isCritical;
  }

  @override
  int get hashCode => Object.hash(medicineId, isCritical);
}
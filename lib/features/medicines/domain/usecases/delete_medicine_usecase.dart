import 'package:dartz/dartz.dart';
import '../failures/medicine_failures.dart';
import '../repositories/medicines_repository.dart';

class DeleteMedicineUseCase {
  final MedicinesRepository repository;

  const DeleteMedicineUseCase(this.repository);

  Future<Either<MedicineFailure, Unit>> call(String medicineId) async {
    if (medicineId.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'معرف الدواء مطلوب',
      ));
    }

    final existingResult = await repository.getMedicineById(
      medicineId: medicineId,
    );

    return existingResult.fold(
          (failure) => Left(failure),
          (medicine) async {
        return await repository.deleteMedicine(medicineId: medicineId);
      },
    );
  }
}

class DeleteMedicinesUseCase {
  final MedicinesRepository repository;

  const DeleteMedicinesUseCase(this.repository);

  Future<Either<MedicineFailure, Unit>> call(List<String> medicineIds) async {
    if (medicineIds.isEmpty) {
      return Left(MedicineValidationFailure(
        message: 'يجب تحديد دواء واحد على الأقل للحذف',
      ));
    }

    final invalidIds = medicineIds.where((id) => id.isEmpty).toList();
    if (invalidIds.isNotEmpty) {
      return Left(MedicineValidationFailure(
        message: 'بعض معرفات الأدوية غير صالحة',
      ));
    }

    return await repository.deleteMedicines(medicineIds: medicineIds);
  }
}

class DeleteMedicineWithConfirmationUseCase {
  final MedicinesRepository repository;

  const DeleteMedicineWithConfirmationUseCase(this.repository);

  Future<Either<MedicineFailure, DeleteMedicineResult>> call(
      DeleteWithConfirmationParams params,
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
        if (!params.isConfirmed) {
          return Right(DeleteMedicineResult(
            isDeleted: false,
            requiresConfirmation: true,
            medicineName: medicine.name,
            hasDoseLogs: params.hasDoseLogs,
          ));
        }

        final deleteResult = await repository.deleteMedicine(
          medicineId: params.medicineId,
        );

        return deleteResult.fold(
              (failure) => Left(failure),
              (_) => Right(DeleteMedicineResult(
            isDeleted: true,
            requiresConfirmation: false,
            medicineName: medicine.name,
            hasDoseLogs: params.hasDoseLogs,
          )),
        );
      },
    );
  }
}

class DeleteWithConfirmationParams {
  final String medicineId;
  final bool isConfirmed;
  final bool hasDoseLogs;

  const DeleteWithConfirmationParams({
    required this.medicineId,
    this.isConfirmed = false,
    this.hasDoseLogs = false,
  });

  DeleteWithConfirmationParams copyWith({
    String? medicineId,
    bool? isConfirmed,
    bool? hasDoseLogs,
  }) {
    return DeleteWithConfirmationParams(
      medicineId: medicineId ?? this.medicineId,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      hasDoseLogs: hasDoseLogs ?? this.hasDoseLogs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteWithConfirmationParams &&
        other.medicineId == medicineId &&
        other.isConfirmed == isConfirmed;
  }

  @override
  int get hashCode => Object.hash(medicineId, isConfirmed);
}

class DeleteMedicineResult {
  final bool isDeleted;
  final bool requiresConfirmation;
  final String medicineName;
  final bool hasDoseLogs;

  const DeleteMedicineResult({
    required this.isDeleted,
    required this.requiresConfirmation,
    required this.medicineName,
    this.hasDoseLogs = false,
  });

  String get confirmationMessage {
    if (hasDoseLogs) {
      return 'سيتم حذف "$medicineName" وجميع سجلات الجرعات المرتبطة به. هل أنت متأكد؟';
    }
    return 'هل أنت متأكد من حذف "$medicineName"؟';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteMedicineResult &&
        other.isDeleted == isDeleted &&
        other.medicineName == medicineName;
  }

  @override
  int get hashCode => Object.hash(isDeleted, medicineName);
}
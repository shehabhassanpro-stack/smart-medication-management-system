import 'package:dartz/dartz.dart';
import '../entities/medicine_entity.dart';
import '../failures/medicine_failures.dart';
import '../repositories/medicines_repository.dart';

class UpdateMedicineUseCase {
  final MedicinesRepository repository;

  const UpdateMedicineUseCase(this.repository);

  Future<Either<MedicineFailure, MedicineEntity>> call(UpdateMedicineParams params) async {
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    final existingResult = await repository.getMedicineById(
      medicineId: params.medicineId,
    );

    return existingResult.fold(
          (failure) => Left(failure),
          (existingMedicine) async {
        final updatedMedicine = existingMedicine.copyWith(
          name: params.name?.trim() ?? existingMedicine.name,
          dosage: params.dosage?.trim() ?? existingMedicine.dosage,
          dosageForm: params.dosageForm ?? existingMedicine.dosageForm,
          times: params.times ?? existingMedicine.times,
          frequency: params.frequency ?? existingMedicine.frequency,
          isActive: params.isActive ?? existingMedicine.isActive,
          isCritical: params.isCritical ?? existingMedicine.isCritical,
          instructions: params.instructions ?? existingMedicine.instructions,
          notes: params.notes ?? existingMedicine.notes,
          startDate: params.startDate ?? existingMedicine.startDate,
          endDate: params.endDate ?? existingMedicine.endDate,
          stockCount: params.stockCount ?? existingMedicine.stockCount,
          refillReminder: params.refillReminder ?? existingMedicine.refillReminder,
          updatedAt: DateTime.now(),
        );

        return await repository.updateMedicine(medicine: updatedMedicine);
      },
    );
  }

  MedicineFailure? _validateParams(UpdateMedicineParams params) {
    if (params.medicineId.isEmpty) {
      return MedicineValidationFailure(
        message: 'معرف الدواء مطلوب',
      );
    }

    if (params.name != null && params.name!.trim().isEmpty) {
      return InvalidMedicineNameFailure();
    }

    if (params.name != null && params.name!.trim().length < 2) {
      return InvalidMedicineNameFailure();
    }

    if (params.dosage != null && params.dosage!.trim().isEmpty) {
      return InvalidMedicineDosageFailure();
    }

    if (params.times != null && params.times!.isEmpty) {
      return InvalidMedicineTimesFailure();
    }

    if (params.times != null) {
      for (final time in params.times!) {
        if (!_isValidTimeFormat(time)) {
          return MedicineValidationFailure(
            message: 'صيغة الوقت غير صحيحة: $time',
          );
        }
      }
    }

    if (params.startDate != null && params.endDate != null) {
      if (params.endDate!.isBefore(params.startDate!)) {
        return MedicineValidationFailure(
          message: 'تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية',
        );
      }
    }

    if (params.stockCount != null && params.stockCount! < 0) {
      return MedicineValidationFailure(
        message: 'كمية المخزون لا يمكن أن تكون سالبة',
      );
    }

    return null;
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):([0-5][0-9])$');
    return regex.hasMatch(time);
  }
}

class UpdateMedicineParams {
  final String medicineId;
  final String? name;
  final String? dosage;
  final DosageForm? dosageForm;
  final List<String>? times;
  final Frequency? frequency;
  final bool? isActive;
  final bool? isCritical;
  final String? instructions;
  final String? notes;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? stockCount;
  final int? refillReminder;

  const UpdateMedicineParams({
    required this.medicineId,
    this.name,
    this.dosage,
    this.dosageForm,
    this.times,
    this.frequency,
    this.isActive,
    this.isCritical,
    this.instructions,
    this.notes,
    this.startDate,
    this.endDate,
    this.stockCount,
    this.refillReminder,
  });

  factory UpdateMedicineParams.fromEntity(MedicineEntity entity) {
    return UpdateMedicineParams(
      medicineId: entity.id,
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
    );
  }

  UpdateMedicineParams copyWith({
    String? medicineId,
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
  }) {
    return UpdateMedicineParams(
      medicineId: medicineId ?? this.medicineId,
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateMedicineParams && other.medicineId == medicineId;
  }

  @override
  int get hashCode => medicineId.hashCode;
}

class UpdateMedicineStockUseCase {
  final MedicinesRepository repository;

  const UpdateMedicineStockUseCase(this.repository);

  Future<Either<MedicineFailure, MedicineEntity>> call(UpdateStockParams params) async {
    if (params.newStock < 0) {
      return Left(MedicineValidationFailure(
        message: 'كمية المخزون لا يمكن أن تكون سالبة',
      ));
    }

    return await repository.updateStock(
      medicineId: params.medicineId,
      newStock: params.newStock,
    );
  }
}

class UpdateStockParams {
  final String medicineId;
  final int newStock;

  const UpdateStockParams({
    required this.medicineId,
    required this.newStock,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateStockParams &&
        other.medicineId == medicineId &&
        other.newStock == newStock;
  }

  @override
  int get hashCode => Object.hash(medicineId, newStock);
}
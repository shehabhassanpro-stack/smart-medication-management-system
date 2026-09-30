import 'package:dartz/dartz.dart';
import '../entities/medicine_entity.dart';
import '../failures/medicine_failures.dart';
import '../repositories/medicines_repository.dart';

class AddMedicineUseCase {
  final MedicinesRepository repository;

  const AddMedicineUseCase(this.repository);

  Future<Either<MedicineFailure, MedicineEntity>> call(AddMedicineParams params) async {
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    final medicine = MedicineEntity(
      id: params.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: params.userId,
      name: params.name.trim(),
      dosage: params.dosage.trim(),
      dosageForm: params.dosageForm,
      times: params.times,
      frequency: params.frequency,
      isActive: params.isActive,
      isCritical: params.isCritical,
      instructions: params.instructions?.trim(),
      notes: params.notes?.trim(),
      startDate: params.startDate,
      endDate: params.endDate,
      stockCount: params.stockCount,
      refillReminder: params.refillReminder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.addMedicine(medicine: medicine);
  }

  MedicineFailure? _validateParams(AddMedicineParams params) {
    if (params.name.trim().isEmpty) {
      return InvalidMedicineNameFailure();
    }

    if (params.name.trim().length < 2) {
      return InvalidMedicineNameFailure();
    }

    if (params.dosage.trim().isEmpty) {
      return InvalidMedicineDosageFailure();
    }

    if (params.times.isEmpty) {
      return InvalidMedicineTimesFailure();
    }

    for (final time in params.times) {
      if (!_isValidTimeFormat(time)) {
        return MedicineValidationFailure(
          message: 'صيغة الوقت غير صحيحة: $time',
        );
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

    if (params.refillReminder != null && params.refillReminder! < 0) {
      return MedicineValidationFailure(
        message: 'تنبيه إعادة التعبئة لا يمكن أن يكون سالباً',
      );
    }

    return null;
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):([0-5][0-9])$');
    return regex.hasMatch(time);
  }
}

class AddMedicineParams {
  final String? id;
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

  const AddMedicineParams({
    this.id,
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
  });

  AddMedicineParams copyWith({
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
  }) {
    return AddMedicineParams(
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddMedicineParams &&
        other.userId == userId &&
        other.name == name &&
        other.dosage == dosage;
  }

  @override
  int get hashCode => Object.hash(userId, name, dosage);
}
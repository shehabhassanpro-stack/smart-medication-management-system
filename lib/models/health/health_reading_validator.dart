import 'reading_type.dart';

sealed class ValidationResult {
  const ValidationResult();
}

class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();
}

class ValidationFailure extends ValidationResult {
  final String message;
  final String? field;
  final ValidationErrorType errorType;

  const ValidationFailure({
    required this.message,
    this.field,
    this.errorType = ValidationErrorType.invalid,
  });
}

enum ValidationErrorType {
  required,
  invalid,
  outOfRange,
  tooLow,
  tooHigh,
  invalidFormat,
  logicalError,
}

class BloodPressureValidationRanges {
  static const int minSystolic = 40;
  static const int maxSystolic = 300;
  static const int minDiastolic = 20;
  static const int maxDiastolic = 200;
  static const int minDifference = 10;
  static const int maxDifference = 150;
}

class HealthReadingValidator {
  const HealthReadingValidator._();

  static ValidationResult validate({
    required ReadingType type,
    double? value,
    int? systolic,
    int? diastolic,
    String? notes,
  }) {
    switch (type) {
      case ReadingType.bloodPressure:
        return validateBloodPressure(systolic: systolic, diastolic: diastolic);
      case ReadingType.bloodSugar:
        return validateBloodSugar(value);
      case ReadingType.weight:
        return validateWeight(value);
      case ReadingType.temperature:
        return validateTemperature(value);
    }
  }

  static ValidationResult validateBloodPressure({
    int? systolic,
    int? diastolic,
  }) {
    if (systolic == null) {
      return const ValidationFailure(
        message: 'يرجى إدخال قيمة الضغط الانقباضي',
        field: 'systolic',
        errorType: ValidationErrorType.required,
      );
    }

    if (diastolic == null) {
      return const ValidationFailure(
        message: 'يرجى إدخال قيمة الضغط الانبساطي',
        field: 'diastolic',
        errorType: ValidationErrorType.required,
      );
    }

    if (systolic < BloodPressureValidationRanges.minSystolic) {
      return ValidationFailure(
        message: 'الضغط الانقباضي منخفض جداً (الحد الأدنى ${BloodPressureValidationRanges.minSystolic})',
        field: 'systolic',
        errorType: ValidationErrorType.tooLow,
      );
    }

    if (systolic > BloodPressureValidationRanges.maxSystolic) {
      return ValidationFailure(
        message: 'الضغط الانقباضي مرتفع جداً (الحد الأقصى ${BloodPressureValidationRanges.maxSystolic})',
        field: 'systolic',
        errorType: ValidationErrorType.tooHigh,
      );
    }

    if (diastolic < BloodPressureValidationRanges.minDiastolic) {
      return ValidationFailure(
        message: 'الضغط الانبساطي منخفض جداً (الحد الأدنى ${BloodPressureValidationRanges.minDiastolic})',
        field: 'diastolic',
        errorType: ValidationErrorType.tooLow,
      );
    }

    if (diastolic > BloodPressureValidationRanges.maxDiastolic) {
      return ValidationFailure(
        message: 'الضغط الانبساطي مرتفع جداً (الحد الأقصى ${BloodPressureValidationRanges.maxDiastolic})',
        field: 'diastolic',
        errorType: ValidationErrorType.tooHigh,
      );
    }

    if (systolic <= diastolic) {
      return const ValidationFailure(
        message: 'الضغط الانقباضي يجب أن يكون أكبر من الانبساطي',
        field: 'systolic',
        errorType: ValidationErrorType.logicalError,
      );
    }

    final difference = systolic - diastolic;

    if (difference < BloodPressureValidationRanges.minDifference) {
      return ValidationFailure(
        message: 'الفرق بين الانقباضي والانبساطي صغير جداً (الحد الأدنى ${BloodPressureValidationRanges.minDifference})',
        errorType: ValidationErrorType.logicalError,
      );
    }

    if (difference > BloodPressureValidationRanges.maxDifference) {
      return ValidationFailure(
        message: 'الفرق بين الانقباضي والانبساطي كبير جداً (الحد الأقصى ${BloodPressureValidationRanges.maxDifference})',
        errorType: ValidationErrorType.logicalError,
      );
    }

    return const ValidationSuccess();
  }

  static ValidationResult validateBloodSugar(double? value) {
    return _validateNumericValue(
      value: value,
      type: ReadingType.bloodSugar,
      fieldName: 'مستوى السكر',
    );
  }

  static ValidationResult validateWeight(double? value) {
    return _validateNumericValue(
      value: value,
      type: ReadingType.weight,
      fieldName: 'الوزن',
    );
  }

  static ValidationResult validateTemperature(double? value) {
    return _validateNumericValue(
      value: value,
      type: ReadingType.temperature,
      fieldName: 'درجة الحرارة',
    );
  }

  static ValidationResult _validateNumericValue({
    required double? value,
    required ReadingType type,
    required String fieldName,
  }) {
    if (value == null) {
      return ValidationFailure(
        message: 'يرجى إدخال قيمة $fieldName',
        field: 'value',
        errorType: ValidationErrorType.required,
      );
    }

    if (value < type.minValue) {
      return ValidationFailure(
        message: '$fieldName منخفض جداً (الحد الأدنى ${type.minValue.toInt()} ${type.unit})',
        field: 'value',
        errorType: ValidationErrorType.tooLow,
      );
    }

    if (value > type.maxValue) {
      return ValidationFailure(
        message: '$fieldName مرتفع جداً (الحد الأقصى ${type.maxValue.toInt()} ${type.unit})',
        field: 'value',
        errorType: ValidationErrorType.tooHigh,
      );
    }

    return const ValidationSuccess();
  }

  static ValidationResult validateNotes(String? notes, {int maxLength = 500}) {
    if (notes == null || notes.trim().isEmpty) {
      return const ValidationSuccess();
    }

    if (notes.length > maxLength) {
      return ValidationFailure(
        message: 'الملاحظات طويلة جداً (الحد الأقصى $maxLength حرف)',
        field: 'notes',
        errorType: ValidationErrorType.tooHigh,
      );
    }

    final hasHtml = RegExp(r'<[^>]*>').hasMatch(notes);
    if (hasHtml) {
      return const ValidationFailure(
        message: 'الملاحظات تحتوي على محتوى غير مسموح',
        field: 'notes',
        errorType: ValidationErrorType.invalid,
      );
    }

    return const ValidationSuccess();
  }

  static String? getErrorMessage(ValidationResult result) {
    if (result is ValidationFailure) {
      return result.message;
    }
    return null;
  }

  static bool isValid(ValidationResult result) {
    return result is ValidationSuccess;
  }
}

class InputSanitizer {
  const InputSanitizer._();

  static const int defaultMaxNotesLength = 500;

  static String? sanitizeNotes(String? input, {int maxLength = defaultMaxNotesLength}) {
    if (input == null || input.trim().isEmpty) return null;

    String sanitized = input;
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');
    sanitized = sanitized.replaceAll(RegExp(r'javascript:', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'[<>]'), '');
    sanitized = sanitized.trim();
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized.isEmpty ? null : sanitized;
  }

  static String sanitizeNumericInput(String input) {
    return input.replaceAll(RegExp(r'[^\d.]'), '');
  }

  static int? parseIntSafe(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final sanitized = sanitizeNumericInput(input);
    return int.tryParse(sanitized);
  }

  static double? parseDoubleSafe(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final sanitized = sanitizeNumericInput(input);
    return double.tryParse(sanitized);
  }
}

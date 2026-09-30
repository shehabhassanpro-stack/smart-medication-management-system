abstract class MedicineFailure {
  MedicineFailure({
    DateTime? timestamp,
    this.stackTrace,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  final DateTime timestamp;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  String get code;
  int get statusCode;
  String get userMessage;
  String get technicalMessage;
  bool get isRetryable;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'statusCode': statusCode,
      'userMessage': userMessage,
      'technicalMessage': technicalMessage,
      'isRetryable': isRetryable,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
  }

  @override
  String toString() => '$runtimeType(code: $code, message: $technicalMessage)';
}

class MedicineNetworkFailure extends MedicineFailure {
  MedicineNetworkFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'MEDICINE_NETWORK_ERROR';

  @override
  int get statusCode => 503;

  @override
  String get userMessage => 'لا يوجد اتصال بالإنترنت. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get technicalMessage => 'Network connection unavailable';

  @override
  bool get isRetryable => true;
}

class MedicineServerFailure extends MedicineFailure {
  MedicineServerFailure({
    this.serverCode,
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  final String? serverCode;

  @override
  String get code => 'MEDICINE_SERVER_ERROR';

  @override
  int get statusCode => 500;

  @override
  String get userMessage => 'حدث خطأ في الخادم. حاول مرة أخرى لاحقاً.';

  @override
  String get technicalMessage => 'Server error: ${serverCode ?? 'unknown'}';

  @override
  bool get isRetryable => true;
}

class MedicineTimeoutFailure extends MedicineFailure {
  MedicineTimeoutFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'MEDICINE_TIMEOUT';

  @override
  int get statusCode => 408;

  @override
  String get userMessage => 'انتهت مهلة الطلب. حاول مرة أخرى.';

  @override
  String get technicalMessage => 'Request timeout';

  @override
  bool get isRetryable => true;
}

class MedicineCacheFailure extends MedicineFailure {
  MedicineCacheFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'MEDICINE_CACHE_ERROR';

  @override
  int get statusCode => 500;

  @override
  String get userMessage => 'حدث خطأ في التخزين المحلي.';

  @override
  String get technicalMessage => 'Local cache error';

  @override
  bool get isRetryable => false;
}

class MedicineNotFoundFailure extends MedicineFailure {
  MedicineNotFoundFailure({
    this.medicineId,
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  final String? medicineId;

  @override
  String get code => 'MEDICINE_NOT_FOUND';

  @override
  int get statusCode => 404;

  @override
  String get userMessage => 'الدواء غير موجود.';

  @override
  String get technicalMessage => 'Medicine not found: ${medicineId ?? 'unknown'}';

  @override
  bool get isRetryable => false;
}

class DoseLogNotFoundFailure extends MedicineFailure {
  DoseLogNotFoundFailure({
    this.doseLogId,
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  final String? doseLogId;

  @override
  String get code => 'DOSE_LOG_NOT_FOUND';

  @override
  int get statusCode => 404;

  @override
  String get userMessage => 'سجل الجرعة غير موجود.';

  @override
  String get technicalMessage => 'Dose log not found: ${doseLogId ?? 'unknown'}';

  @override
  bool get isRetryable => false;
}

class MedicineValidationFailure extends MedicineFailure {
  MedicineValidationFailure({
    required this.message,
    this.fieldErrors,
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  final String message;
  final Map<String, String>? fieldErrors;

  @override
  String get code => 'MEDICINE_VALIDATION_ERROR';

  @override
  int get statusCode => 400;

  @override
  String get userMessage => message;

  @override
  String get technicalMessage => 'Validation error: $message';

  @override
  bool get isRetryable => false;
}

class InvalidMedicineNameFailure extends MedicineValidationFailure {
  InvalidMedicineNameFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  }) : super(message: 'اسم الدواء غير صالح. يجب أن يكون حرفين على الأقل.');
}

class InvalidMedicineDosageFailure extends MedicineValidationFailure {
  InvalidMedicineDosageFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  }) : super(message: 'الجرعة غير صالحة.');
}

class InvalidMedicineTimesFailure extends MedicineValidationFailure {
  InvalidMedicineTimesFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  }) : super(message: 'يجب تحديد وقت واحد على الأقل.');
}

class DuplicateMedicineFailure extends MedicineFailure {
  DuplicateMedicineFailure({
    this.medicineName,
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  final String? medicineName;

  @override
  String get code => 'DUPLICATE_MEDICINE';

  @override
  int get statusCode => 409;

  @override
  String get userMessage => 'يوجد دواء بنفس الاسم "${medicineName ?? ''}" بالفعل.';

  @override
  String get technicalMessage => 'Duplicate medicine: ${medicineName ?? 'unknown'}';

  @override
  bool get isRetryable => false;
}

class MedicinePermissionFailure extends MedicineFailure {
  MedicinePermissionFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'MEDICINE_PERMISSION_DENIED';

  @override
  int get statusCode => 403;

  @override
  String get userMessage => 'ليس لديك صلاحية للقيام بهذا الإجراء.';

  @override
  String get technicalMessage => 'Permission denied';

  @override
  bool get isRetryable => false;
}

class MedicineUnauthorizedFailure extends MedicineFailure {
  MedicineUnauthorizedFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'MEDICINE_UNAUTHORIZED';

  @override
  int get statusCode => 401;

  @override
  String get userMessage => 'يرجى تسجيل الدخول للمتابعة.';

  @override
  String get technicalMessage => 'User not authenticated';

  @override
  bool get isRetryable => false;
}

class MedicineUnexpectedFailure extends MedicineFailure {
  MedicineUnexpectedFailure({
    this.message,
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  final String? message;

  @override
  String get code => 'MEDICINE_UNEXPECTED_ERROR';

  @override
  int get statusCode => 500;

  @override
  String get userMessage => message ?? 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get technicalMessage => 'Unexpected error: ${message ?? 'unknown'}';

  @override
  bool get isRetryable => false;
}
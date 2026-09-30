import 'package:firebase_auth/firebase_auth.dart';

enum ErrorSeverity {
  info,
  warning,
  error,
  critical;

  String get label {
    switch (this) {
      case ErrorSeverity.info:
        return 'معلومة';
      case ErrorSeverity.warning:
        return 'تحذير';
      case ErrorSeverity.error:
        return 'خطأ';
      case ErrorSeverity.critical:
        return 'حرج';
    }
  }

  int get level {
    switch (this) {
      case ErrorSeverity.info:
        return 1;
      case ErrorSeverity.warning:
        return 2;
      case ErrorSeverity.error:
        return 3;
      case ErrorSeverity.critical:
        return 4;
    }
  }
}

enum ErrorCategory {
  authentication,
  network,
  validation,
  database,
  permission,
  unknown;

  String get label {
    switch (this) {
      case ErrorCategory.authentication:
        return 'مصادقة';
      case ErrorCategory.network:
        return 'شبكة';
      case ErrorCategory.validation:
        return 'تحقق';
      case ErrorCategory.database:
        return 'قاعدة بيانات';
      case ErrorCategory.permission:
        return 'صلاحيات';
      case ErrorCategory.unknown:
        return 'غير معروف';
    }
  }
}

sealed class AuthFailure {
  AuthFailure({
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
  ErrorSeverity get severity;
  ErrorCategory get category;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'statusCode': statusCode,
      'userMessage': userMessage,
      'technicalMessage': technicalMessage,
      'isRetryable': isRetryable,
      'severity': severity.name,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
  }

  Map<String, dynamic> toAnalyticsEvent() {
    return {
      'error_code': code,
      'error_category': category.name,
      'error_severity': severity.name,
      'is_retryable': isRetryable,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return '$runtimeType(code: $code, message: $technicalMessage)';
  }
}

class NetworkFailure extends AuthFailure {
  NetworkFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'NETWORK_ERROR';

  @override
  int get statusCode => 503;

  @override
  String get userMessage => 'لا يوجد اتصال بالإنترنت. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get technicalMessage => 'Network connection unavailable';

  @override
  bool get isRetryable => true;

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;

  @override
  ErrorCategory get category => ErrorCategory.network;
}

class TimeoutFailure extends AuthFailure {
  TimeoutFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'REQUEST_TIMEOUT';

  @override
  int get statusCode => 408;

  @override
  String get userMessage => 'انتهى وقت الاتصال. حاول مرة أخرى.';

  @override
  String get technicalMessage => 'Request timeout';

  @override
  bool get isRetryable => true;

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;

  @override
  ErrorCategory get category => ErrorCategory.network;
}

class ServerUnavailableFailure extends AuthFailure {
  ServerUnavailableFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'SERVICE_UNAVAILABLE';

  @override
  int get statusCode => 503;

  @override
  String get userMessage => 'الخدمة غير متاحة حالياً. حاول مرة أخرى بعد قليل.';

  @override
  String get technicalMessage => 'Server unavailable';

  @override
  bool get isRetryable => true;

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.network;
}

class InvalidEmailFailure extends AuthFailure {
  InvalidEmailFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'INVALID_EMAIL';

  @override
  int get statusCode => 400;

  @override
  String get userMessage => 'البريد الإلكتروني غير صالح. أدخل بريداً صحيحاً.';

  @override
  String get technicalMessage => 'Invalid email format';

  @override
  bool get isRetryable => false;

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.validation;
}

class WeakPasswordFailure extends AuthFailure {
  WeakPasswordFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'WEAK_PASSWORD';

  @override
  int get statusCode => 400;

  @override
  String get userMessage => 'كلمة المرور ضعيفة. يجب أن تكون 6 أحرف على الأقل.';

  @override
  String get technicalMessage => 'Password is too weak';

  @override
  bool get isRetryable => false;

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.validation;
}

class InvalidNameFailure extends AuthFailure {
  InvalidNameFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'INVALID_NAME';

  @override
  int get statusCode => 400;

  @override
  String get userMessage => 'الاسم غير صالح. يجب أن يكون حرفين على الأقل.';

  @override
  String get technicalMessage => 'Name is too short';

  @override
  bool get isRetryable => false;

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.validation;
}

class EmailAlreadyInUseFailure extends AuthFailure {
  EmailAlreadyInUseFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'EMAIL_ALREADY_IN_USE';

  @override
  int get statusCode => 409;

  @override
  String get userMessage => 'البريد الإلكتروني مستخدم بالفعل. جرب تسجيل الدخول.';

  @override
  String get technicalMessage => 'Email already registered';

  @override
  bool get isRetryable => false;

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.authentication;
}

class UserNotFoundFailure extends AuthFailure {
  UserNotFoundFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'USER_NOT_FOUND';

  @override
  int get statusCode => 404;

  @override
  String get userMessage => 'البريد الإلكتروني غير مسجل. قم بإنشاء حساب جديد.';

  @override
  String get technicalMessage => 'User not found';

  @override
  bool get isRetryable => false;

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.authentication;
}

class WrongPasswordFailure extends AuthFailure {
  WrongPasswordFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'WRONG_PASSWORD';

  @override
  int get statusCode => 401;

  @override
  String get userMessage => 'كلمة المرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get technicalMessage => 'Wrong password';

  @override
  bool get isRetryable => false;

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.authentication;
}

class UserDisabledFailure extends AuthFailure {
  UserDisabledFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'USER_DISABLED';

  @override
  int get statusCode => 403;

  @override
  String get userMessage => 'هذا الحساب معطل. تواصل مع الدعم الفني.';

  @override
  String get technicalMessage => 'User account disabled';

  @override
  bool get isRetryable => false;

  @override
  ErrorSeverity get severity => ErrorSeverity.critical;

  @override
  ErrorCategory get category => ErrorCategory.authentication;
}

class EmailNotVerifiedFailure extends AuthFailure {
  EmailNotVerifiedFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'EMAIL_NOT_VERIFIED';

  @override
  int get statusCode => 403;

  @override
  String get userMessage => 'يرجى تفعيل بريدك الإلكتروني أولاً. تحقق من صندوق الوارد أو مجلد الرسائل غير المرغوب فيها.';

  @override
  String get technicalMessage => 'Email not verified';

  @override
  bool get isRetryable => true;

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;

  @override
  ErrorCategory get category => ErrorCategory.authentication;
}

class TooManyRequestsFailure extends AuthFailure {
  TooManyRequestsFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'TOO_MANY_REQUESTS';

  @override
  int get statusCode => 429;

  @override
  String get userMessage => 'محاولات كثيرة. حاول مرة أخرى بعد قليل.';

  @override
  String get technicalMessage => 'Too many requests';

  @override
  bool get isRetryable => true;

  @override
  ErrorSeverity get severity => ErrorSeverity.warning;

  @override
  ErrorCategory get category => ErrorCategory.authentication;
}

class PermissionDeniedFailure extends AuthFailure {
  PermissionDeniedFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'PERMISSION_DENIED';

  @override
  int get statusCode => 403;

  @override
  String get userMessage => 'فشل حفظ البيانات. حاول مرة أخرى.';

  @override
  String get technicalMessage => 'Firestore permission denied';

  @override
  bool get isRetryable => false;

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.permission;
}

class DataNotFoundFailure extends AuthFailure {
  DataNotFoundFailure({
    super.timestamp,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get code => 'DATA_NOT_FOUND';

  @override
  int get statusCode => 404;

  @override
  String get userMessage => 'بيانات المستخدم غير موجودة.';

  @override
  String get technicalMessage => 'User document not found';

  @override
  bool get isRetryable => false;

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.database;
}

class FirestoreWriteFailure extends AuthFailure {
  FirestoreWriteFailure(
      this.firebaseCode, {
        super.timestamp,
        super.stackTrace,
        super.metadata,
      });

  final String firebaseCode;

  @override
  String get code => 'FIRESTORE_WRITE_ERROR';

  @override
  int get statusCode => 500;

  @override
  String get userMessage => 'فشل حفظ البيانات. حاول مرة أخرى.';

  @override
  String get technicalMessage => 'Firestore write failed: $firebaseCode';

  @override
  bool get isRetryable => _isRetryableFirestoreError(firebaseCode);

  @override
  ErrorSeverity get severity => isRetryable ? ErrorSeverity.warning : ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.database;

  bool _isRetryableFirestoreError(String code) {
    return [
      'unavailable',
      'deadline-exceeded',
      'resource-exhausted',
      'aborted',
    ].contains(code);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['firebaseCode'] = firebaseCode;
    return json;
  }
}

class UnexpectedFailure extends AuthFailure {
  UnexpectedFailure(
      this.message, {
        super.timestamp,
        super.stackTrace,
        super.metadata,
      });

  final String message;

  @override
  String get code => 'UNEXPECTED_ERROR';

  @override
  int get statusCode => 500;

  @override
  String get userMessage => message.isEmpty ? 'حدث خطأ غير متوقع' : message;

  @override
  String get technicalMessage => 'Unexpected error: $message';

  @override
  bool get isRetryable => false;

  @override
  ErrorSeverity get severity => ErrorSeverity.error;

  @override
  ErrorCategory get category => ErrorCategory.unknown;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['originalMessage'] = message;
    return json;
  }
}

AuthFailure authFailureFromFirebaseAuth(
    FirebaseAuthException e, {
      StackTrace? stackTrace,
      Map<String, dynamic>? metadata,
    }) {
  final timestamp = DateTime.now();

  switch (e.code) {
    case 'email-already-in-use':
      return EmailAlreadyInUseFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'user-not-found':
      return UserNotFoundFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'wrong-password':
      return WrongPasswordFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'invalid-email':
      return InvalidEmailFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'weak-password':
      return WeakPasswordFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'user-disabled':
      return UserDisabledFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'too-many-requests':
      return TooManyRequestsFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'network-request-failed':
      return NetworkFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'invalid-credential':
      return WrongPasswordFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    default:
      return UnexpectedFailure(
        'Firebase Auth: ${e.message ?? e.code}',
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: {
          ...?metadata,
          'firebase_code': e.code,
          'firebase_message': e.message,
        },
      );
  }
}

AuthFailure authFailureFromFirestore(
    FirebaseException e, {
      StackTrace? stackTrace,
      Map<String, dynamic>? metadata,
    }) {
  final timestamp = DateTime.now();

  switch (e.code) {
    case 'permission-denied':
      return PermissionDeniedFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'not-found':
      return DataNotFoundFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'unavailable':
      return ServerUnavailableFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    case 'deadline-exceeded':
      return TimeoutFailure(
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: metadata,
      );
    default:
      return FirestoreWriteFailure(
        e.code,
        timestamp: timestamp,
        stackTrace: stackTrace,
        metadata: {
          ...?metadata,
          'firebase_message': e.message,
        },
      );
  }
}

AuthFailure authFailureFromException(
    Object e, {
      StackTrace? stackTrace,
      Map<String, dynamic>? metadata,
    }) {
  if (e is FirebaseAuthException) {
    return authFailureFromFirebaseAuth(
      e,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  } else if (e is FirebaseException) {
    return authFailureFromFirestore(
      e,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  } else if (e is AuthFailure) {
    return e;
  } else {
    return UnexpectedFailure(
      e.toString(),
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }
}
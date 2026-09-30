import 'package:cloud_firestore/cloud_firestore.dart';

import 'reading_type.dart';
import 'reading_status.dart';
import 'measurement_time.dart';

class HealthReading {
  final String id;
  final String userId;
  final ReadingType type;
  final double value;
  final int? systolic;
  final int? diastolic;
  final DateTime timestamp;
  final String? notes;
  final MeasurementTime? measurementTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  static const int maxNotesLength = 500;

  const HealthReading({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    this.systolic,
    this.diastolic,
    required this.timestamp,
    this.notes,
    this.measurementTime,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  factory HealthReading.create({
    required String userId,
    required ReadingType type,
    required double value,
    int? systolic,
    int? diastolic,
    DateTime? timestamp,
    String? notes,
    MeasurementTime? measurementTime,
  }) {
    final now = DateTime.now();
    
    String? sanitizedNotes = notes?.trim();
    if (sanitizedNotes?.isEmpty == true) {
      sanitizedNotes = null;
    } else if (sanitizedNotes != null && sanitizedNotes.length > maxNotesLength) {
      sanitizedNotes = sanitizedNotes.substring(0, maxNotesLength);
    }

    return HealthReading(
      id: '',
      userId: userId,
      type: type,
      value: _clampValue(value, type),
      systolic: systolic != null ? _clampInt(systolic, 40, 300) : null,
      diastolic: diastolic != null ? _clampInt(diastolic, 20, 200) : null,
      timestamp: timestamp ?? now,
      notes: sanitizedNotes,
      measurementTime: measurementTime,
      createdAt: now,
      updatedAt: null,
      isDeleted: false,
    );
  }

  static double _clampValue(double value, ReadingType type) {
    if (value < type.minValue) return type.minValue;
    if (value > type.maxValue) return type.maxValue;
    return value;
  }

  static int _clampInt(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  bool get isValid {
    if (userId.isEmpty) return false;
    if (!type.isValidValue(value)) return false;
    if (type == ReadingType.bloodPressure) {
      if (systolic == null || diastolic == null) return false;
      if (systolic! < 40 || systolic! > 300) return false;
      if (diastolic! < 20 || diastolic! > 200) return false;
    }
    if (notes != null && notes!.length > maxNotesLength) return false;
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.id,
      'value': value,
      'systolic': systolic,
      'diastolic': diastolic,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
      'measurementTime': measurementTime?.id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isDeleted': isDeleted,
    };
  }

  factory HealthReading.fromMap(Map<String, dynamic> map, String documentId) {
    return HealthReading(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      type: ReadingType.fromId(map['type'] as String? ?? 'bloodPressure'),
      value: (map['value'] as num?)?.toDouble() ?? 0.0,
      systolic: map['systolic'] as int?,
      diastolic: map['diastolic'] as int?,
      timestamp: _parseDateTime(map['timestamp']) ?? DateTime.now(),
      notes: map['notes'] as String?,
      measurementTime: MeasurementTime.tryFromId(map['measurementTime'] as String?),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']),
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  static DateTime? _parseDateTime(dynamic field) {
    if (field == null) return null;
    if (field is Timestamp) return field.toDate();
    if (field is DateTime) return field;
    if (field is String) return DateTime.tryParse(field);
    if (field is int) return DateTime.fromMillisecondsSinceEpoch(field);
    return null;
  }

  HealthReading copyWith({
    String? id,
    String? userId,
    ReadingType? type,
    double? value,
    int? systolic,
    int? diastolic,
    DateTime? timestamp,
    String? notes,
    MeasurementTime? measurementTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return HealthReading(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      value: value ?? this.value,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      measurementTime: measurementTime ?? this.measurementTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  HealthReading markAsDeleted() {
    return copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    );
  }

  String get displayValue {
    if (type == ReadingType.bloodPressure && systolic != null && diastolic != null) {
      return '$systolic/$diastolic';
    }
    return type.decimalPlaces == 0 
        ? value.toStringAsFixed(0) 
        : value.toStringAsFixed(type.decimalPlaces);
  }

  String get displayValueWithUnit => '$displayValue ${type.unit}';

  String get systolicDisplay => systolic?.toString() ?? value.toStringAsFixed(0);

  String get diastolicDisplay => diastolic?.toString() ?? '80';

  ReadingStatus get status {
    switch (type) {
      case ReadingType.bloodPressure:
        return _calculateBloodPressureStatus();
      case ReadingType.bloodSugar:
        return _calculateBloodSugarStatus();
      case ReadingType.temperature:
        return _calculateTemperatureStatus();
      case ReadingType.weight:
        return ReadingStatus.normal;
    }
  }

  ReadingStatus _calculateBloodPressureStatus() {
    final sys = systolic ?? value.toInt();
    final dia = diastolic ?? 80;

    if (sys >= 180 || dia >= 120) return ReadingStatus.critical;
    if (sys >= 140 || dia >= 90) return ReadingStatus.high;
    if (sys >= 120 || dia >= 80) return ReadingStatus.borderline;
    if (sys < 90 || dia < 60) return ReadingStatus.low;
    return ReadingStatus.normal;
  }

  ReadingStatus _calculateBloodSugarStatus() {
    final isFasting = measurementTime?.isFasting ?? false;

    if (value < 54) return ReadingStatus.critical;
    if (value < 70) return ReadingStatus.low;

    if (isFasting) {
      if (value > 126) return ReadingStatus.high;
      if (value > 100) return ReadingStatus.borderline;
    } else {
      if (value > 200) return ReadingStatus.high;
      if (value > 140) return ReadingStatus.borderline;
    }

    return ReadingStatus.normal;
  }

  ReadingStatus _calculateTemperatureStatus() {
    if (value >= 39.5 || value < 35.0) return ReadingStatus.critical;
    if (value >= 38.0) return ReadingStatus.high;
    if (value >= 37.5) return ReadingStatus.borderline;
    if (value < 36.0) return ReadingStatus.low;
    return ReadingStatus.normal;
  }

  String get advice {
    switch (type) {
      case ReadingType.bloodPressure:
        return _getBloodPressureAdvice();
      case ReadingType.bloodSugar:
        return _getBloodSugarAdvice();
      case ReadingType.temperature:
        return _getTemperatureAdvice();
      case ReadingType.weight:
        return 'استمر في متابعة وزنك بانتظام للحفاظ على صحتك.';
    }
  }

  String _getBloodPressureAdvice() {
    switch (status) {
      case ReadingStatus.critical:
        return '⚠️ ضغط الدم مرتفع جداً! راجع الطبيب فوراً.';
      case ReadingStatus.high:
        return 'القراءة مرتفعة. ننصح باستشارة الطبيب وتقليل الملح.';
      case ReadingStatus.borderline:
        return 'القراءة حدّية. راقب ضغطك بانتظام ومارس الرياضة.';
      case ReadingStatus.low:
        return 'ضغط الدم منخفض. اشرب سوائل واسترح.';
      case ReadingStatus.normal:
        return 'القراءة طبيعية. استمر في نمط حياتك الصحي! 💪';
    }
  }

  String _getBloodSugarAdvice() {
    switch (status) {
      case ReadingStatus.critical:
        return '⚠️ السكر منخفض جداً! تناول سكر فوراً واطلب المساعدة.';
      case ReadingStatus.high:
        return 'السكر مرتفع. تجنب السكريات واستشر الطبيب.';
      case ReadingStatus.borderline:
        return 'السكر حدّي. راقب نظامك الغذائي وقلل الكربوهيدرات.';
      case ReadingStatus.low:
        return 'السكر منخفض. تناول شيئاً حلواً وراقب حالتك.';
      case ReadingStatus.normal:
        return 'السكر طبيعي. ممتاز! حافظ على نظامك الغذائي. 🌟';
    }
  }

  String _getTemperatureAdvice() {
    switch (status) {
      case ReadingStatus.critical:
        return '⚠️ حرارة مرتفعة جداً! راجع الطبيب فوراً.';
      case ReadingStatus.high:
        return 'حرارة مرتفعة. استرح واشرب سوائل وتناول خافض للحرارة.';
      case ReadingStatus.borderline:
        return 'حرارة مرتفعة قليلاً. راقب حالتك واسترح.';
      case ReadingStatus.low:
        return 'حرارة منخفضة. دفئ نفسك واشرب مشروبات دافئة.';
      case ReadingStatus.normal:
        return 'درجة الحرارة طبيعية. صحتك جيدة! ✨';
    }
  }

  bool get isNormal => status.isNormal;

  bool get needsAttention => status.requiresAttention;

  bool get isCritical => status.isCritical;

  bool get isBloodPressure => type == ReadingType.bloodPressure;

  bool get hasBloodPressureValues => systolic != null && diastolic != null;

  double differenceFrom(HealthReading other) {
    if (type != other.type) return 0;
    
    if (type == ReadingType.bloodPressure) {
      final current = (systolic ?? value.toInt()).toDouble();
      final otherVal = (other.systolic ?? other.value.toInt()).toDouble();
      return current - otherVal;
    }
    return value - other.value;
  }

  double percentageChangeFrom(HealthReading other) {
    if (type != other.type) return 0;

    final otherValue = type == ReadingType.bloodPressure
        ? (other.systolic ?? other.value).toDouble()
        : other.value;

    if (otherValue == 0) return 0;

    final currentValue = type == ReadingType.bloodPressure
        ? (systolic ?? value).toDouble()
        : value;

    return ((currentValue - otherValue) / otherValue) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HealthReading) return false;
    if (id.isNotEmpty && other.id.isNotEmpty) return id == other.id;
    return userId == other.userId &&
        type == other.type &&
        value == other.value &&
        timestamp == other.timestamp;
  }

  @override
  int get hashCode {
    if (id.isNotEmpty) return id.hashCode;
    return Object.hash(userId, type, value, timestamp);
  }

  @override
  String toString() {
    return 'HealthReading(id: $id, type: ${type.nameAr}, value: $displayValue, status: ${status.nameAr}, isDeleted: $isDeleted)';
  }
}

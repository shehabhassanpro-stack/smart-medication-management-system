import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String userId;
  final String medicineName;
  final String scientificName;
  final String dosage;
  final String dosageForm;
  final String frequency;
  final List<String> times;
  final String timingWithMeal;
  final DateTime startDate;
  final DateTime? endDate;
  final int? durationInDays;
  final String doctorName;
  final String medicalReason;
  final String? sideEffects;
  final String? warnings;
  final String? additionalNotes;
  final bool isActive;
  final bool isCritical;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  static const int maxTimesPerDay = 24;
  static const int maxNotesLength = 500;
  static const int maxNameLength = 100;
  static const int maxDosageLength = 50;

  Medicine({
    this.id = '',
    required this.userId,
    required this.medicineName,
    this.scientificName = '',
    required this.dosage,
    this.dosageForm = 'حبوب',
    required this.frequency,
    required this.times,
    this.timingWithMeal = 'بعد الأكل',
    required this.startDate,
    this.endDate,
    this.durationInDays,
    this.doctorName = '',
    this.medicalReason = '',
    this.sideEffects,
    this.warnings,
    this.additionalNotes,
    this.isActive = true,
    this.isCritical = false,
    this.imageUrl,
    DateTime? createdAt,
    this.updatedAt,
    this.isDeleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Medicine.create({
    required String userId,
    required String medicineName,
    String scientificName = '',
    required String dosage,
    String dosageForm = 'حبوب',
    required String frequency,
    required List<String> times,
    String timingWithMeal = 'بعد الأكل',
    required DateTime startDate,
    DateTime? endDate,
    int? durationInDays,
    String doctorName = '',
    String medicalReason = '',
    String? sideEffects,
    String? warnings,
    String? additionalNotes,
    bool isActive = true,
    bool isCritical = false,
    String? imageUrl,
  }) {
    return Medicine(
      userId: userId,
      medicineName: _sanitizeString(medicineName, maxNameLength),
      scientificName: _sanitizeString(scientificName, maxNameLength),
      dosage: _sanitizeString(dosage, maxDosageLength),
      dosageForm: dosageForm,
      frequency: frequency,
      times: times.take(maxTimesPerDay).toList(),
      timingWithMeal: timingWithMeal,
      startDate: startDate,
      endDate: endDate,
      durationInDays: durationInDays,
      doctorName: _sanitizeString(doctorName, maxNameLength),
      medicalReason: _sanitizeString(medicalReason, maxNotesLength),
      sideEffects: sideEffects != null ? _sanitizeString(sideEffects, maxNotesLength) : null,
      warnings: warnings != null ? _sanitizeString(warnings, maxNotesLength) : null,
      additionalNotes: additionalNotes != null ? _sanitizeString(additionalNotes, maxNotesLength) : null,
      isActive: isActive,
      isCritical: isCritical,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      isDeleted: false,
    );
  }

  static String _sanitizeString(String value, int maxLength) {
    final trimmed = value.trim();
    if (trimmed.length > maxLength) {
      return trimmed.substring(0, maxLength);
    }
    return trimmed;
  }

  bool get isValid {
    if (userId.isEmpty) return false;
    if (medicineName.isEmpty || medicineName.length > maxNameLength) return false;
    if (dosage.isEmpty || dosage.length > maxDosageLength) return false;
    if (frequency.isEmpty) return false;
    if (times.isEmpty || times.length > maxTimesPerDay) return false;
    return true;
  }

  String get name => medicineName;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicineName': medicineName,
      'scientificName': scientificName,
      'dosage': dosage,
      'dosageForm': dosageForm,
      'frequency': frequency,
      'times': times,
      'timingWithMeal': timingWithMeal,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'durationInDays': durationInDays,
      'doctorName': doctorName,
      'medicalReason': medicalReason,
      'sideEffects': sideEffects,
      'warnings': warnings,
      'additionalNotes': additionalNotes,
      'isActive': isActive,
      'isCritical': isCritical,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isDeleted': isDeleted,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String documentId) {
    final timesData = map['times'];
    List<String> timesList;

    if (timesData is String) {
      timesList = timesData.split(',').where((t) => t.isNotEmpty).toList();
    } else if (timesData is List) {
      timesList = timesData.map((t) => t.toString()).toList();
    } else {
      timesList = [];
    }

    return Medicine(
      id: documentId,
      userId: (map['userId'] ?? '') as String,
      medicineName: (map['medicineName'] ?? map['medicine_name'] ?? '') as String,
      scientificName: (map['scientificName'] ?? map['scientific_name'] ?? '') as String,
      dosage: (map['dosage'] ?? '') as String,
      dosageForm: (map['dosageForm'] ?? map['dosage_form'] ?? 'حبوب') as String,
      frequency: (map['frequency'] ?? '') as String,
      times: timesList,
      timingWithMeal: (map['timingWithMeal'] ?? map['timing_with_meal'] ?? 'بعد الأكل') as String,
      startDate: _parseDateTime(map['startDate'] ?? map['start_date']) ?? DateTime.now(),
      endDate: _parseDateTime(map['endDate'] ?? map['end_date']),
      durationInDays: (map['durationInDays'] ?? map['duration_in_days']) as int?,
      doctorName: (map['doctorName'] ?? map['doctor_name'] ?? '') as String,
      medicalReason: (map['medicalReason'] ?? map['medical_reason'] ?? '') as String,
      sideEffects: (map['sideEffects'] ?? map['side_effects']) as String?,
      warnings: map['warnings'] as String?,
      additionalNotes: (map['additionalNotes'] ?? map['additional_notes']) as String?,
      isActive: _parseBool(map['isActive'] ?? map['is_active']),
      isCritical: _parseBool(map['isCritical'] ?? map['is_critical']),
      imageUrl: (map['imageUrl'] ?? map['image_url']) as String?,
      createdAt: _parseDateTime(map['createdAt'] ?? map['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt'] ?? map['updated_at']),
      isDeleted: _parseBool(map['isDeleted'] ?? map['is_deleted']),
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

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicine.fromMap(data, doc.id);
  }

  Medicine copyWith({
    String? id,
    String? userId,
    String? medicineName,
    String? scientificName,
    String? dosage,
    String? dosageForm,
    String? frequency,
    List<String>? times,
    String? timingWithMeal,
    DateTime? startDate,
    DateTime? endDate,
    int? durationInDays,
    String? doctorName,
    String? medicalReason,
    String? sideEffects,
    String? warnings,
    String? additionalNotes,
    bool? isActive,
    bool? isCritical,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Medicine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicineName: medicineName ?? this.medicineName,
      scientificName: scientificName ?? this.scientificName,
      dosage: dosage ?? this.dosage,
      dosageForm: dosageForm ?? this.dosageForm,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      timingWithMeal: timingWithMeal ?? this.timingWithMeal,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationInDays: durationInDays ?? this.durationInDays,
      doctorName: doctorName ?? this.doctorName,
      medicalReason: medicalReason ?? this.medicalReason,
      sideEffects: sideEffects ?? this.sideEffects,
      warnings: warnings ?? this.warnings,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      isActive: isActive ?? this.isActive,
      isCritical: isCritical ?? this.isCritical,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Medicine markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  Medicine deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  Medicine activate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  int? getDaysRemaining() {
    if (endDate == null) return null;
    final diff = endDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  bool isExpired() {
    if (endDate == null) return false;
    return endDate!.isBefore(DateTime.now());
  }

  int get daysSinceStart {
    return DateTime.now().difference(startDate).inDays;
  }

  bool get isLongTerm => durationInDays == null || durationInDays! > 90;

  bool get needsRefill {
    final remaining = getDaysRemaining();
    if (remaining == null) return false;
    return remaining <= 7;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Medicine(id: $id, name: $medicineName, userId: $userId, isActive: $isActive, isDeleted: $isDeleted)';
  }
}

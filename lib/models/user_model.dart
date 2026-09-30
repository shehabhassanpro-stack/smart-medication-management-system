import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  patient,
  doctor,
}

extension UserRoleExtension on UserRole {
  String toArabic() {
    switch (this) {
      case UserRole.patient:
        return 'مريض';
      case UserRole.doctor:
        return 'دكتور';
    }
  }

  String toEnglish() {
    switch (this) {
      case UserRole.patient:
        return 'patient';
      case UserRole.doctor:
        return 'doctor';
    }
  }
}

/// Main User Model
class UserModel {

  final String uid;              // Firebase Auth UID
  final String name;             // User's full name
  final String email;            // User's email
  final UserRole role;           // Patient or Doctor
  final DateTime createdAt;      // Account creation timestamp

  // ═══════════════════════════════════════════════════════════════
  // 📱 OPTIONAL COMMON FIELDS
  // ═══════════════════════════════════════════════════════════════
  final String? phone;            // Phone number (optional)
  final String? photoUrl;         // Profile picture URL (optional)
  final DateTime? updatedAt;      // Last update timestamp (optional)
  final String? gender;           // Gender: male, female (NEW)

  // ═══════════════════════════════════════════════════════════════
  // 🏥 PATIENT-SPECIFIC FIELDS (Only for patients)
  // ═══════════════════════════════════════════════════════════════
  final String? bloodType;            // Blood type (A+, O-, etc.)
  final DateTime? dateOfBirth;        // Date of birth
  final String? emergencyContact;     // Emergency contact name
  final String? emergencyPhone;       // Emergency contact phone (NEW)
  final String? address;              // Home address
  final String? nationalId;           // National ID number
  final double? height;               // Height in cm
  final double? weight;               // Weight in kg
  final List<String>? chronicDiseases; // Chronic diseases list (NEW)
  final List<String>? allergies;       // Allergies list (NEW)

  // ═══════════════════════════════════════════════════════════════
  // 👨‍⚕️ DOCTOR-SPECIFIC FIELDS (Only for doctors)
  // ═══════════════════════════════════════════════════════════════
  final String? specialty;        // Medical specialty
  final String? licenseNumber;    // Medical license number
  final String? hospital;         // Current hospital/clinic
  final String? clinicAddress;    // Clinic address
  final int? experienceYears;     // Years of experience
  final List<String>? workingDays; // Working days (Mon, Tue, etc.)
  final String? workingHours;     // Working hours (9AM-5PM)
  final String? doctorCode;       // Unique doctor code (for patient access)

  // ═══════════════════════════════════════════════════════════════
  // 🔒 CONSTRUCTOR
  // ═══════════════════════════════════════════════════════════════
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.phone,
    this.photoUrl,
    this.updatedAt,
    this.gender,
    // Patient fields
    this.bloodType,
    this.dateOfBirth,
    this.emergencyContact,
    this.emergencyPhone,
    this.address,
    this.nationalId,
    this.height,
    this.weight,
    this.chronicDiseases,
    this.allergies,
    // Doctor fields
    this.specialty,
    this.licenseNumber,
    this.hospital,
    this.clinicAddress,
    this.experienceYears,
    this.workingDays,
    this.workingHours,
    this.doctorCode,
  });

  // ═══════════════════════════════════════════════════════════════
  // 📤 TO MAP (For saving to Firestore)
  // ═══════════════════════════════════════════════════════════════
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.toEnglish(),
      'createdAt': Timestamp.fromDate(createdAt),
    };

    // Add optional common fields
    if (phone != null) map['phone'] = phone;
    if (photoUrl != null) map['photoUrl'] = photoUrl;
    if (updatedAt != null) map['updatedAt'] = Timestamp.fromDate(updatedAt!);
    if (gender != null) map['gender'] = gender;

    // Add patient-specific fields
    if (role == UserRole.patient) {
      if (bloodType != null) map['bloodType'] = bloodType;
      if (dateOfBirth != null) {
        map['dateOfBirth'] = Timestamp.fromDate(dateOfBirth!);
      }
      if (emergencyContact != null) map['emergencyContact'] = emergencyContact;
      if (emergencyPhone != null) map['emergencyPhone'] = emergencyPhone;
      if (address != null) map['address'] = address;
      if (nationalId != null) map['nationalId'] = nationalId;
      if (height != null) map['height'] = height;
      if (weight != null) map['weight'] = weight;
      if (chronicDiseases != null) map['chronicDiseases'] = chronicDiseases;
      if (allergies != null) map['allergies'] = allergies;
    }

    // Add doctor-specific fields
    if (role == UserRole.doctor) {
      if (specialty != null) map['specialty'] = specialty;
      if (licenseNumber != null) map['licenseNumber'] = licenseNumber;
      if (hospital != null) map['hospital'] = hospital;
      if (clinicAddress != null) map['clinicAddress'] = clinicAddress;
      if (experienceYears != null) map['experienceYears'] = experienceYears;
      if (workingDays != null) map['workingDays'] = workingDays;
      if (workingHours != null) map['workingHours'] = workingHours;
      if (doctorCode != null) map['doctorCode'] = doctorCode;
    }

    return map;
  }

  // ═══════════════════════════════════════════════════════════════
  // 📥 FROM FIRESTORE (For reading from Firestore)
  // ═══════════════════════════════════════════════════════════════
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse role
    final roleString = data['role'] as String? ?? 'patient';
    final role = roleString == 'doctor' ? UserRole.doctor : UserRole.patient;

    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: role,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Optional common fields
      phone: data['phone'] as String?,
      photoUrl: data['photoUrl'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      gender: data['gender'] as String?,
      // Patient fields
      bloodType: data['bloodType'] as String?,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      emergencyContact: data['emergencyContact'] as String?,
      emergencyPhone: data['emergencyPhone'] as String?,
      address: data['address'] as String?,
      nationalId: data['nationalId'] as String?,
      height: (data['height'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      chronicDiseases: (data['chronicDiseases'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      allergies: (data['allergies'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      // Doctor fields
      specialty: data['specialty'] as String?,
      licenseNumber: data['licenseNumber'] as String?,
      hospital: data['hospital'] as String?,
      clinicAddress: data['clinicAddress'] as String?,
      experienceYears: data['experienceYears'] as int?,
      workingDays: (data['workingDays'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      workingHours: data['workingHours'] as String?,
      doctorCode: data['doctorCode'] as String?,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📥 FROM MAP (Alternative constructor)
  // ═══════════════════════════════════════════════════════════════
  factory UserModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final roleString = map['role'] as String? ?? 'patient';
    final role = roleString == 'doctor' ? UserRole.doctor : UserRole.patient;

    // Handle createdAt - can be Timestamp or null
    DateTime createdAt;
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    return UserModel(
      uid: docId ?? map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: role,
      createdAt: createdAt,
      phone: map['phone'] as String?,
      photoUrl: map['photoUrl'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      gender: map['gender'] as String?,
      // Patient fields
      bloodType: map['bloodType'] as String?,
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate(),
      emergencyContact: map['emergencyContact'] as String?,
      emergencyPhone: map['emergencyPhone'] as String?,
      address: map['address'] as String?,
      nationalId: map['nationalId'] as String?,
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      chronicDiseases: (map['chronicDiseases'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      allergies: (map['allergies'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      // Doctor fields
      specialty: map['specialty'] as String?,
      licenseNumber: map['licenseNumber'] as String?,
      hospital: map['hospital'] as String?,
      clinicAddress: map['clinicAddress'] as String?,
      experienceYears: map['experienceYears'] as int?,
      workingDays: (map['workingDays'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      workingHours: map['workingHours'] as String?,
      doctorCode: map['doctorCode'] as String?,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 COPY WITH (For updating user data)
  // ═══════════════════════════════════════════════════════════════
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    DateTime? createdAt,
    String? phone,
    String? photoUrl,
    DateTime? updatedAt,
    String? gender,
    // Patient fields
    String? bloodType,
    DateTime? dateOfBirth,
    String? emergencyContact,
    String? emergencyPhone,
    String? address,
    String? nationalId,
    double? height,
    double? weight,
    List<String>? chronicDiseases,
    List<String>? allergies,
    // Doctor fields
    String? specialty,
    String? licenseNumber,
    String? hospital,
    String? clinicAddress,
    int? experienceYears,
    List<String>? workingDays,
    String? workingHours,
    String? doctorCode,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender,
      // Patient fields
      bloodType: bloodType ?? this.bloodType,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      address: address ?? this.address,
      nationalId: nationalId ?? this.nationalId,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      allergies: allergies ?? this.allergies,
      // Doctor fields
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      hospital: hospital ?? this.hospital,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      experienceYears: experienceYears ?? this.experienceYears,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      doctorCode: doctorCode ?? this.doctorCode,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔍 HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Check if user is a patient
  bool get isPatient => role == UserRole.patient;

  /// Check if user is a doctor
  bool get isDoctor => role == UserRole.doctor;

  /// Get age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int calculatedAge = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  /// Get gender in Arabic
  String? get genderArabic {
    if (gender == null) return null;
    switch (gender!.toLowerCase()) {
      case 'male':
        return 'ذكر';
      case 'female':
        return 'أنثى';
      default:
        return gender;
    }
  }

  /// Get display name with role
  String get displayNameWithRole {
    final roleText = role.toArabic();
    return '$name ($roleText)';
  }

  /// Check if has chronic diseases
  bool get hasChronicDiseases =>
      chronicDiseases != null && chronicDiseases!.isNotEmpty;

  /// Check if has allergies
  bool get hasAllergies =>
      allergies != null && allergies!.isNotEmpty;

  /// Get profile completeness percentage
  int get profileCompleteness {
    int filledFields = 5; // uid, name, email, role, createdAt are always filled
    int totalFields = 5;

    // Common fields
    if (phone != null && phone!.isNotEmpty) filledFields++;
    totalFields++;

    if (photoUrl != null && photoUrl!.isNotEmpty) filledFields++;
    totalFields++;

    if (gender != null && gender!.isNotEmpty) filledFields++;
    totalFields++;

    if (role == UserRole.patient) {
      // Patient fields
      totalFields += 10;
      if (bloodType != null && bloodType!.isNotEmpty) filledFields++;
      if (dateOfBirth != null) filledFields++;
      if (emergencyContact != null && emergencyContact!.isNotEmpty) filledFields++;
      if (emergencyPhone != null && emergencyPhone!.isNotEmpty) filledFields++;
      if (address != null && address!.isNotEmpty) filledFields++;
      if (nationalId != null && nationalId!.isNotEmpty) filledFields++;
      if (height != null) filledFields++;
      if (weight != null) filledFields++;
      if (chronicDiseases != null && chronicDiseases!.isNotEmpty) filledFields++;
      if (allergies != null && allergies!.isNotEmpty) filledFields++;
    } else if (role == UserRole.doctor) {
      // Doctor fields
      totalFields += 8;
      if (specialty != null && specialty!.isNotEmpty) filledFields++;
      if (licenseNumber != null && licenseNumber!.isNotEmpty) filledFields++;
      if (hospital != null && hospital!.isNotEmpty) filledFields++;
      if (clinicAddress != null && clinicAddress!.isNotEmpty) filledFields++;
      if (experienceYears != null) filledFields++;
      if (workingDays != null && workingDays!.isNotEmpty) filledFields++;
      if (workingHours != null && workingHours!.isNotEmpty) filledFields++;
      if (doctorCode != null && doctorCode!.isNotEmpty) filledFields++;
    }

    return ((filledFields / totalFields) * 100).round();
  }

  // ═══════════════════════════════════════════════════════════════
  // 🖨️ TO STRING (For debugging)
  // ═══════════════════════════════════════════════════════════════
  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, role: ${role.toEnglish()})';
  }

  // ═══════════════════════════════════════════════════════════════
  // ⚖️ EQUALITY & HASH CODE
  // ═══════════════════════════════════════════════════════════════
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;
}
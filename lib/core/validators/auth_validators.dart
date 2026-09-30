import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';

class AuthValidators {
  static final AuthValidators _instance = AuthValidators._internal();
  factory AuthValidators() => _instance;
  AuthValidators._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int minSpecialtyLength = 2;
  static const int maxSpecialtyLength = 100;
  static const int minLicenseLength = 3;
  static const int maxLicenseLength = 50;
  static const int strongPasswordLength = 8;
  static const int veryStrongPasswordLength = 12;
  static const int minAgeYears = 0;
  static const int maxAgeYears = 150;

  static const int minBloodTypeLength = 2;
  static const int maxBloodTypeLength = 5;
  static const int minAddressLength = 5;
  static const int maxAddressLength = 500;
  static const int minNationalIdLength = 10;
  static const int maxNationalIdLength = 20;
  static const double minHeight = 30.0;
  static const double maxHeight = 300.0;
  static const double minWeight = 1.0;
  static const double maxWeight = 500.0;
  static const int minExperienceYears = 0;
  static const int maxExperienceYears = 70;
  static const int minHospitalLength = 2;
  static const int maxHospitalLength = 200;
  static const int minClinicAddressLength = 5;
  static const int maxClinicAddressLength = 500;

  static const Duration firestoreTimeout = Duration(seconds: 30);

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _nameRegex = RegExp(
    r"^[\u0621-\u064Aa-zA-Z\s'-]+$",
  );

  static final RegExp _phoneRegex = RegExp(
    r'^\+?[0-9]+$',
  );

  static final RegExp _bloodTypeRegex = RegExp(
    r'^(A|B|AB|O)[+-]$',
    caseSensitive: false,
  );

  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');
  static final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  static final RegExp _whitespaceRegex = RegExp(r'\s+');
  static final RegExp _phoneCleanRegex = RegExp(r'[\s\-()]');

  void validateRegistrationInput({
    required String name,
    required String email,
    required String password,
    String? phone,
    DateTime? dateOfBirth,
  }) {
    _validateName(name);
    _validateEmail(email);
    _validatePassword(password);

    if (phone != null && phone.isNotEmpty) {
      _validatePhone(phone);
    }

    if (dateOfBirth != null) {
      validateDateOfBirth(dateOfBirth);
    }
  }

  void validateLoginInput({
    required String email,
    required String password,
  }) {
    final cleanEmail = sanitizeEmail(email);

    if (cleanEmail.isEmpty) {
      throw InvalidEmailFailure();
    }

    if (!_isValidEmailFormat(cleanEmail)) {
      throw InvalidEmailFailure();
    }

    if (password.isEmpty) {
      throw WeakPasswordFailure();
    }
  }

  void validateDoctorFields({
    required String? specialty,
    required String? licenseNumber,
  }) {
    if (specialty == null || specialty.trim().isEmpty) {
      throw UnexpectedFailure('التخصص مطلوب للأطباء');
    }

    final cleanSpecialty = specialty.trim();

    if (cleanSpecialty.length < minSpecialtyLength) {
      throw UnexpectedFailure('التخصص قصير جداً (الحد الأدنى $minSpecialtyLength أحرف)');
    }

    if (cleanSpecialty.length > maxSpecialtyLength) {
      throw UnexpectedFailure('التخصص طويل جداً (الحد الأقصى $maxSpecialtyLength حرف)');
    }

    if (licenseNumber == null || licenseNumber.trim().isEmpty) {
      throw UnexpectedFailure('رقم الترخيص مطلوب للأطباء');
    }

    final cleanLicense = licenseNumber.trim();

    if (cleanLicense.length < minLicenseLength) {
      throw UnexpectedFailure('رقم الترخيص قصير جداً (الحد الأدنى $minLicenseLength أحرف)');
    }

    if (cleanLicense.length > maxLicenseLength) {
      throw UnexpectedFailure('رقم الترخيص طويل جداً (الحد الأقصى $maxLicenseLength حرف)');
    }
  }

  void validatePasswordChange({
    required String currentPassword,
    required String newPassword,
  }) {
    if (currentPassword.isEmpty) {
      throw WeakPasswordFailure();
    }

    if (newPassword.isEmpty) {
      throw WeakPasswordFailure();
    }

    if (newPassword.length < minPasswordLength) {
      throw WeakPasswordFailure();
    }

    if (newPassword.length > maxPasswordLength) {
      throw UnexpectedFailure('كلمة المرور الجديدة طويلة جداً (الحد الأقصى $maxPasswordLength حرف)');
    }

    if (currentPassword == newPassword) {
      throw UnexpectedFailure('كلمة المرور الجديدة يجب أن تكون مختلفة');
    }
  }

  void validateProfileUpdate({
    String? name,
    String? phone,
  }) {
    if (name != null && name.isNotEmpty) {
      _validateName(name);
    }

    if (phone != null && phone.isNotEmpty) {
      _validatePhone(phone);
    }
  }

  void validateBloodType(String? bloodType) {
    if (bloodType == null || bloodType.trim().isEmpty) {
      return;
    }

    final cleaned = bloodType.trim().toUpperCase();

    if (cleaned.length < minBloodTypeLength || cleaned.length > maxBloodTypeLength) {
      throw UnexpectedFailure('فصيلة الدم غير صالحة (يجب أن تكون بين $minBloodTypeLength-$maxBloodTypeLength أحرف)');
    }

    if (!_bloodTypeRegex.hasMatch(cleaned)) {
      throw UnexpectedFailure('فصيلة الدم غير صالحة (مثال: A+, B-, O+, AB-)');
    }
  }

  void validateAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return;
    }

    final cleaned = address.trim();

    if (cleaned.length < minAddressLength) {
      throw UnexpectedFailure('العنوان قصير جداً (الحد الأدنى $minAddressLength أحرف)');
    }

    if (cleaned.length > maxAddressLength) {
      throw UnexpectedFailure('العنوان طويل جداً (الحد الأقصى $maxAddressLength حرف)');
    }
  }

  void validateNationalId(String? nationalId) {
    if (nationalId == null || nationalId.trim().isEmpty) {
      return;
    }

    final cleaned = nationalId.trim();

    if (cleaned.length < minNationalIdLength) {
      throw UnexpectedFailure('الرقم القومي قصير جداً (الحد الأدنى $minNationalIdLength أرقام)');
    }

    if (cleaned.length > maxNationalIdLength) {
      throw UnexpectedFailure('الرقم القومي طويل جداً (الحد الأقصى $maxNationalIdLength رقم)');
    }
  }

  void validateHeight(double? height) {
    if (height == null) {
      return;
    }

    if (height < minHeight || height > maxHeight) {
      throw UnexpectedFailure('الطول غير صالح (يجب أن يكون بين $minHeight-$maxHeight سم)');
    }
  }

  void validateWeight(double? weight) {
    if (weight == null) {
      return;
    }

    if (weight < minWeight || weight > maxWeight) {
      throw UnexpectedFailure('الوزن غير صالح (يجب أن يكون بين $minWeight-$maxWeight كجم)');
    }
  }

  void validateExperienceYears(int? years) {
    if (years == null) {
      return;
    }

    if (years < minExperienceYears || years > maxExperienceYears) {
      throw UnexpectedFailure('سنوات الخبرة غير صالحة (يجب أن تكون بين $minExperienceYears-$maxExperienceYears سنة)');
    }
  }

  void validateHospital(String? hospital) {
    if (hospital == null || hospital.trim().isEmpty) {
      return;
    }

    final cleaned = hospital.trim();

    if (cleaned.length < minHospitalLength) {
      throw UnexpectedFailure('اسم المستشفى قصير جداً (الحد الأدنى $minHospitalLength أحرف)');
    }

    if (cleaned.length > maxHospitalLength) {
      throw UnexpectedFailure('اسم المستشفى طويل جداً (الحد الأقصى $maxHospitalLength حرف)');
    }
  }

  void validateClinicAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return;
    }

    final cleaned = address.trim();

    if (cleaned.length < minClinicAddressLength) {
      throw UnexpectedFailure('عنوان العيادة قصير جداً (الحد الأدنى $minClinicAddressLength أحرف)');
    }

    if (cleaned.length > maxClinicAddressLength) {
      throw UnexpectedFailure('عنوان العيادة طويل جداً (الحد الأقصى $maxClinicAddressLength حرف)');
    }
  }

  void validateDateOfBirth(DateTime? dateOfBirth) {
    if (dateOfBirth == null) {
      return;
    }

    final now = DateTime.now();

    if (dateOfBirth.isAfter(now)) {
      throw UnexpectedFailure('تاريخ الميلاد لا يمكن أن يكون في المستقبل');
    }

    final age = now.year - dateOfBirth.year -
        ((now.month < dateOfBirth.month ||
            (now.month == dateOfBirth.month && now.day < dateOfBirth.day))
            ? 1 : 0);

    if (age < minAgeYears) {
      throw UnexpectedFailure('العمر غير صالح (الحد الأدنى $minAgeYears سنة)');
    }

    if (age > maxAgeYears) {
      throw UnexpectedFailure('العمر غير صالح (الحد الأقصى $maxAgeYears سنة)');
    }
  }

  void _validateName(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw InvalidNameFailure();
    }

    if (trimmedName.length < minNameLength) {
      throw InvalidNameFailure();
    }

    if (trimmedName.length > maxNameLength) {
      throw UnexpectedFailure('الاسم طويل جداً (الحد الأقصى $maxNameLength حرف)');
    }

    if (!_isValidNameFormat(trimmedName)) {
      throw UnexpectedFailure('الاسم يحتوي على أحرف غير صالحة');
    }
  }

  void _validateEmail(String email) {
    final cleanEmail = sanitizeEmail(email);

    if (cleanEmail.isEmpty) {
      throw InvalidEmailFailure();
    }

    if (!_isValidEmailFormat(cleanEmail)) {
      throw InvalidEmailFailure();
    }

    if (cleanEmail.length > 254) {
      throw UnexpectedFailure('البريد الإلكتروني طويل جداً (الحد الأقصى 254 حرف)');
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw WeakPasswordFailure();
    }

    if (password.length < minPasswordLength) {
      throw WeakPasswordFailure();
    }

    if (password.length > maxPasswordLength) {
      throw UnexpectedFailure('كلمة المرور طويلة جداً (الحد الأقصى $maxPasswordLength حرف)');
    }
  }

  void _validatePhone(String phone) {
    final cleanPhone = _cleanPhoneNumber(phone);

    if (cleanPhone.isEmpty) {
      throw UnexpectedFailure('رقم الهاتف غير صالح');
    }

    if (cleanPhone.length < minPhoneLength || cleanPhone.length > maxPhoneLength) {
      throw UnexpectedFailure('رقم الهاتف غير صالح (يجب أن يكون بين $minPhoneLength-$maxPhoneLength رقم)');
    }

    if (!_phoneRegex.hasMatch(cleanPhone)) {
      throw UnexpectedFailure('رقم الهاتف يحتوي على أحرف غير صالحة');
    }
  }

  bool isValidEmail(String email) {
    final cleanEmail = sanitizeEmail(email);
    return _isValidEmailFormat(cleanEmail);
  }

  bool _isValidEmailFormat(String email) {
    if (email.isEmpty) return false;
    if (email.length > 254) return false;
    return _emailRegex.hasMatch(email);
  }

  bool _isValidNameFormat(String name) {
    if (name.isEmpty) return false;

    final hasOnlySpaces = name.trim().isEmpty;
    if (hasOnlySpaces) return false;

    return _nameRegex.hasMatch(name);
  }

  String sanitizeName(String name) {
    if (name.isEmpty) return '';

    String sanitized = name.trim();

    sanitized = sanitized.replaceAll(_whitespaceRegex, ' ');

    if (sanitized.isEmpty) return '';

    final words = sanitized.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() +
          (word.length > 1 ? word.substring(1).toLowerCase() : '');
    }).toList();

    return capitalizedWords.join(' ');
  }

  String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  String? sanitizePhone(String? phone) {
    if (phone == null || phone.isEmpty) return null;

    final cleaned = _cleanPhoneNumber(phone);

    return cleaned.isEmpty ? null : cleaned;
  }

  String sanitizeBloodType(String? bloodType) {
    if (bloodType == null || bloodType.isEmpty) return '';
    return bloodType.trim().toUpperCase();
  }

  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(_phoneCleanRegex, '');
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      debugPrint('🔍 Checking if email exists: $email');

      final normalizedEmail = sanitizeEmail(email);

      if (!_isValidEmailFormat(normalizedEmail)) {
        return false;
      }

      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get()
          .timeout(firestoreTimeout);

      final exists = querySnapshot.docs.isNotEmpty;

      debugPrint(exists ? '✅ Email exists' : 'ℹ️ Email does not exist');

      return exists;
    } on FirebaseException catch (e) {
      debugPrint('⚠️ Firestore error checking email: ${e.code}');
      throw authFailureFromFirestore(e);
    } on TimeoutException {
      debugPrint('⚠️ Timeout checking email');
      throw TimeoutFailure();
    } catch (e) {
      debugPrint('⚠️ Unexpected error checking email: $e');
      throw authFailureFromException(e);
    }
  }

  bool isStrongPassword(String password) {
    if (password.length < strongPasswordLength) return false;

    final hasUpperCase = _uppercaseRegex.hasMatch(password);
    final hasLowerCase = _lowercaseRegex.hasMatch(password);
    final hasDigits = _digitRegex.hasMatch(password);
    final hasSpecialCharacters = _specialCharRegex.hasMatch(password);

    int strength = 0;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialCharacters) strength++;

    return strength >= 3;
  }

  PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.empty;
    }

    if (password.length < minPasswordLength) {
      return PasswordStrength.veryWeak;
    }

    if (password.length < strongPasswordLength) {
      return PasswordStrength.weak;
    }

    final hasUpperCase = _uppercaseRegex.hasMatch(password);
    final hasLowerCase = _lowercaseRegex.hasMatch(password);
    final hasDigits = _digitRegex.hasMatch(password);
    final hasSpecialCharacters = _specialCharRegex.hasMatch(password);

    int strength = 0;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialCharacters) strength++;

    if (strength >= 4 && password.length >= veryStrongPasswordLength) {
      return PasswordStrength.veryStrong;
    }

    if (strength >= 3) {
      return PasswordStrength.strong;
    }

    if (strength >= 2) {
      return PasswordStrength.medium;
    }

    return PasswordStrength.weak;
  }

  int calculatePasswordScore(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    if (password.length >= minPasswordLength) score += 10;
    if (password.length >= strongPasswordLength) score += 10;
    if (password.length >= veryStrongPasswordLength) score += 10;
    if (password.length >= 16) score += 10;

    if (_uppercaseRegex.hasMatch(password)) score += 15;
    if (_lowercaseRegex.hasMatch(password)) score += 15;
    if (_digitRegex.hasMatch(password)) score += 15;
    if (_specialCharRegex.hasMatch(password)) score += 15;

    return score > 100 ? 100 : score;
  }

  bool isValidDateOfBirth(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return true;

    final now = DateTime.now();

    if (dateOfBirth.isAfter(now)) return false;

    final age = now.year - dateOfBirth.year -
        ((now.month < dateOfBirth.month ||
            (now.month == dateOfBirth.month && now.day < dateOfBirth.day))
            ? 1 : 0);

    if (age < minAgeYears || age > maxAgeYears) return false;

    return true;
  }
}

enum PasswordStrength {
  empty,
  veryWeak,
  weak,
  medium,
  strong,
  veryStrong;

  String get arabicLabel {
    switch (this) {
      case PasswordStrength.empty:
        return 'فارغة';
      case PasswordStrength.veryWeak:
        return 'ضعيفة جداً';
      case PasswordStrength.weak:
        return 'ضعيفة';
      case PasswordStrength.medium:
        return 'متوسطة';
      case PasswordStrength.strong:
        return 'قوية';
      case PasswordStrength.veryStrong:
        return 'قوية جداً';
    }
  }

  String get englishLabel {
    switch (this) {
      case PasswordStrength.empty:
        return 'Empty';
      case PasswordStrength.veryWeak:
        return 'Very Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  double get percentage {
    switch (this) {
      case PasswordStrength.empty:
        return 0.0;
      case PasswordStrength.veryWeak:
        return 0.2;
      case PasswordStrength.weak:
        return 0.4;
      case PasswordStrength.medium:
        return 0.6;
      case PasswordStrength.strong:
        return 0.8;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}
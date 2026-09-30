import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../core/errors/failures.dart';
import '../../core/validators/auth_validators.dart';
import '../../models/user_model.dart';

class AuthProfileService {
  static final AuthProfileService _instance = AuthProfileService._internal();
  factory AuthProfileService() => _instance;
  AuthProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthValidators _validators = AuthValidators();

  static const Duration authTimeout = Duration(seconds: 30);
  static const Duration firestoreTimeout = Duration(seconds: 30);
  static const Duration emailVerificationCooldown = Duration(minutes: 2);

  static const String usersCollection = 'users';
  static const String auditLogsCollection = 'audit_logs';

  DateTime? _lastEmailVerificationSent;

  Future<UserModel?> getUserData(String uid) async {
    try {
      debugPrint('📖 ProfileService: Fetching user data for: $uid');

      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .get()
          .timeout(firestoreTimeout);

      if (!doc.exists) {
        debugPrint('⚠️ User document not found: $uid');
        return null;
      }

      final userData = doc.data();
      if (userData == null) {
        debugPrint('⚠️ User data is null: $uid');
        return null;
      }

      final userModel = UserModel.fromFirestore(doc);
      debugPrint('✅ User data fetched successfully');

      return userModel;
    } on FirebaseException catch (e) {
      debugPrint('❌ Firestore error fetching user: ${e.code}');
      throw authFailureFromFirestore(e);
    } on TimeoutException {
      debugPrint('⏰ Timeout fetching user data');
      throw TimeoutFailure();
    } catch (e) {
      debugPrint('❌ Unexpected error fetching user: $e');
      throw authFailureFromException(e);
    }
  }

  Future<void> updateUserData({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      debugPrint('📝 ProfileService: Updating user data...');
      debugPrint('   UID: $uid');
      debugPrint('   Fields: ${data.keys.join(", ")}');

      if (data.isEmpty) {
        throw UnexpectedFailure('لا توجد بيانات للتحديث');
      }

      _validateUpdateData(data);

      final updateData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(usersCollection)
          .doc(uid)
          .update(updateData)
          .timeout(firestoreTimeout);

      await _logAuditEvent(
        userId: uid,
        action: 'profile_updated',
        details: {'fields': data.keys.toList()},
      );

      debugPrint('✅ User data updated successfully');
    } on FirebaseException catch (e) {
      debugPrint('❌ Firestore error updating user: ${e.code}');

      if (e.code == 'not-found') {
        throw DataNotFoundFailure();
      }

      throw authFailureFromFirestore(e);
    } on TimeoutException {
      debugPrint('⏰ Timeout updating user data');
      throw TimeoutFailure();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error updating user: $e');
      throw authFailureFromException(e);
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    Map<String, dynamic>? firestoreSnapshot;

    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw UnexpectedFailure('لا يوجد مستخدم مسجل دخول');
      }

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('👤 ProfileService: Updating user profile...');
      debugPrint('═══════════════════════════════════════════════════════');

      _validators.validateProfileUpdate(name: name, phone: phone);

      final doc = await _firestore
          .collection(usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        firestoreSnapshot = doc.data();
      }

      final updateData = <String, dynamic>{};

      if (name != null) {
        final sanitizedName = _validators.sanitizeName(name);
        updateData['name'] = sanitizedName;
        debugPrint('📝 Name: $sanitizedName');
      }

      if (phone != null) {
        final sanitizedPhone = _validators.sanitizePhone(phone);
        if (sanitizedPhone != null) {
          updateData['phone'] = sanitizedPhone;
          debugPrint('📱 Phone: $sanitizedPhone');
        }
      }

      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
        debugPrint('🖼️ Photo URL updated');
      }

      if (updateData.isEmpty) {
        debugPrint('ℹ️ No changes to update');
        return;
      }

      await updateUserData(uid: user.uid, data: updateData);

      bool authUpdateFailed = false;

      if (name != null) {
        try {
          await user.updateDisplayName(name).timeout(authTimeout);
          debugPrint('✅ Firebase Auth display name updated');
        } catch (e) {
          debugPrint('⚠️ Failed to update Auth display name: $e');
          authUpdateFailed = true;
        }
      }

      if (photoUrl != null) {
        try {
          await user.updatePhotoURL(photoUrl).timeout(authTimeout);
          debugPrint('✅ Firebase Auth photo URL updated');
        } catch (e) {
          debugPrint('⚠️ Failed to update Auth photo URL: $e');
          authUpdateFailed = true;
        }
      }

      if (authUpdateFailed && firestoreSnapshot != null) {
        debugPrint('⚠️ Rolling back Firestore changes due to Auth update failure...');
        try {
          await _firestore
              .collection(usersCollection)
              .doc(user.uid)
              .set(firestoreSnapshot, SetOptions(merge: true))
              .timeout(firestoreTimeout);
          debugPrint('✅ Rollback completed');
          throw UnexpectedFailure('فشل تحديث الملف الشخصي - تم التراجع عن التغييرات');
        } catch (e) {
          debugPrint('❌ Rollback failed: $e');
          throw UnexpectedFailure('حدث خطأ في تحديث الملف الشخصي');
        }
      }

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('✅ Profile updated successfully');
      debugPrint('═══════════════════════════════════════════════════════');
    } on AuthFailure {
      rethrow;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      throw authFailureFromException(e);
    }
  }

  Future<void> updatePatientProfile({
    String? bloodType,
    DateTime? dateOfBirth,
    String? emergencyContact,
    String? address,
    String? nationalId,
    double? height,
    double? weight,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw UnexpectedFailure('لا يوجد مستخدم مسجل دخول');
      }

      debugPrint('🏥 ProfileService: Updating patient profile...');

      final userData = await getUserData(user.uid);

      if (userData == null) {
        throw DataNotFoundFailure();
      }

      if (userData.role != UserRole.patient) {
        throw UnexpectedFailure('هذه الدالة للمرضى فقط');
      }

      _validators.validateBloodType(bloodType);
      _validators.validateDateOfBirth(dateOfBirth);
      _validators.validateAddress(address);
      _validators.validateNationalId(nationalId);
      _validators.validateHeight(height);
      _validators.validateWeight(weight);

      if (emergencyContact != null && emergencyContact.isNotEmpty) {
        final sanitizedContact = _validators.sanitizePhone(emergencyContact);
        if (sanitizedContact == null) {
          throw UnexpectedFailure('رقم الطوارئ غير صالح');
        }
      }

      final updateData = <String, dynamic>{};

      if (bloodType != null) {
        updateData['bloodType'] = _validators.sanitizeBloodType(bloodType);
      }
      if (dateOfBirth != null) {
        updateData['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
      }
      if (emergencyContact != null) {
        updateData['emergencyContact'] = emergencyContact.trim();
      }
      if (address != null) updateData['address'] = address.trim();
      if (nationalId != null) updateData['nationalId'] = nationalId.trim();
      if (height != null) updateData['height'] = height;
      if (weight != null) updateData['weight'] = weight;

      if (updateData.isEmpty) {
        debugPrint('ℹ️ No patient data to update');
        return;
      }

      await updateUserData(uid: user.uid, data: updateData);

      await _logAuditEvent(
        userId: user.uid,
        action: 'patient_profile_updated',
        details: {'fields': updateData.keys.toList()},
      );

      debugPrint('✅ Patient profile updated successfully');
    } on AuthFailure {
      rethrow;
    } catch (e) {
      debugPrint('❌ Error updating patient profile: $e');
      throw authFailureFromException(e);
    }
  }

  Future<void> updateDoctorProfile({
    String? specialty,
    String? hospital,
    String? clinicAddress,
    int? experienceYears,
    List<String>? workingDays,
    String? workingHours,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw UnexpectedFailure('لا يوجد مستخدم مسجل دخول');
      }

      debugPrint('👨‍⚕️ ProfileService: Updating doctor profile...');

      final userData = await getUserData(user.uid);

      if (userData == null) {
        throw DataNotFoundFailure();
      }

      if (userData.role != UserRole.doctor) {
        throw UnexpectedFailure('هذه الدالة للأطباء فقط');
      }

      _validators.validateExperienceYears(experienceYears);
      _validators.validateHospital(hospital);
      _validators.validateClinicAddress(clinicAddress);

      final updateData = <String, dynamic>{};

      if (specialty != null) updateData['specialty'] = specialty.trim();
      if (hospital != null) updateData['hospital'] = hospital.trim();
      if (clinicAddress != null) updateData['clinicAddress'] = clinicAddress.trim();
      if (experienceYears != null) updateData['experienceYears'] = experienceYears;
      if (workingDays != null) updateData['workingDays'] = workingDays;
      if (workingHours != null) updateData['workingHours'] = workingHours.trim();

      if (updateData.isEmpty) {
        debugPrint('ℹ️ No doctor data to update');
        return;
      }

      await updateUserData(uid: user.uid, data: updateData);

      await _logAuditEvent(
        userId: user.uid,
        action: 'doctor_profile_updated',
        details: {'fields': updateData.keys.toList()},
      );

      debugPrint('✅ Doctor profile updated successfully');
    } on AuthFailure {
      rethrow;
    } catch (e) {
      debugPrint('❌ Error updating doctor profile: $e');
      throw authFailureFromException(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw UnexpectedFailure('لا يوجد مستخدم مسجل دخول');
      }

      if (user.email == null) {
        throw UnexpectedFailure('البريد الإلكتروني غير موجود');
      }

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔐 ProfileService: Changing password...');
      debugPrint('═══════════════════════════════════════════════════════');

      _validators.validatePasswordChange(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      debugPrint('🔑 Re-authenticating user...');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential).timeout(authTimeout);
        debugPrint('✅ Re-authentication successful');
      } on FirebaseAuthException catch (e) {
        debugPrint('❌ Re-authentication failed: ${e.code}');

        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          throw WrongPasswordFailure();
        }

        throw authFailureFromFirebaseAuth(e);
      }

      debugPrint('🔄 Updating password...');

      await user.updatePassword(newPassword).timeout(authTimeout);

      await _logAuditEvent(
        userId: user.uid,
        action: 'password_changed',
        details: {'timestamp': DateTime.now().toIso8601String()},
      );

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('✅ Password changed successfully');
      debugPrint('═══════════════════════════════════════════════════════');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error: ${e.code}');
      throw authFailureFromFirebaseAuth(e);
    } on TimeoutException {
      debugPrint('⏰ Timeout changing password');
      throw TimeoutFailure();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error changing password: $e');
      throw authFailureFromException(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw UnexpectedFailure('لا يوجد مستخدم مسجل دخول');
      }

      if (user.emailVerified) {
        debugPrint('ℹ️ Email already verified');
        return;
      }

      if (_lastEmailVerificationSent != null) {
        final timeSinceLastSent = DateTime.now().difference(_lastEmailVerificationSent!);

        if (timeSinceLastSent < emailVerificationCooldown) {
          final remainingSeconds = emailVerificationCooldown.inSeconds - timeSinceLastSent.inSeconds;
          throw UnexpectedFailure(
            'يرجى الانتظار $remainingSeconds ثانية قبل إرسال رسالة جديدة',
          );
        }
      }

      debugPrint('📧 ProfileService: Sending verification email...');

      await user.sendEmailVerification().timeout(authTimeout);

      _lastEmailVerificationSent = DateTime.now();

      await _logAuditEvent(
        userId: user.uid,
        action: 'email_verification_sent',
        details: {'timestamp': DateTime.now().toIso8601String()},
      );

      debugPrint('✅ Verification email sent');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error: ${e.code}');

      if (e.code == 'too-many-requests') {
        throw TooManyRequestsFailure();
      }

      throw authFailureFromFirebaseAuth(e);
    } on TimeoutException {
      debugPrint('⏰ Timeout sending verification email');
      throw TimeoutFailure();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      debugPrint('❌ Error sending verification email: $e');
      throw authFailureFromException(e);
    }
  }

  Future<bool> reloadUser() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        debugPrint('⚠️ No user to reload');
        return false;
      }

      debugPrint('🔄 ProfileService: Reloading user...');

      await user.reload().timeout(authTimeout);

      final freshUser = _auth.currentUser;
      final isVerified = freshUser?.emailVerified ?? false;

      debugPrint('✅ User reloaded - Email verified: $isVerified');

      return isVerified;
    } catch (e) {
      debugPrint('❌ Error reloading user: $e');
      return false;
    }
  }

  Future<void> _logAuditEvent({
    required String userId,
    required String action,
    Map<String, dynamic>? details,
  }) async {
    try {
      final auditData = {
        'userId': userId,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
        if (details != null) 'details': details,
      };

      await _firestore
          .collection(auditLogsCollection)
          .add(auditData)
          .timeout(firestoreTimeout);

      debugPrint('📝 Audit log created: $action');
    } catch (e) {
      debugPrint('⚠️ Failed to create audit log: $e');
    }
  }

  void _validateUpdateData(Map<String, dynamic> data) {
    if (data.containsKey('name')) {
      final name = data['name'];
      if (name is String) {
        _validators.validateProfileUpdate(name: name);
      }
    }

    if (data.containsKey('phone')) {
      final phone = data['phone'];
      if (phone is String) {
        _validators.validateProfileUpdate(phone: phone);
      }
    }

    if (data.containsKey('email')) {
      throw UnexpectedFailure('لا يمكن تغيير البريد الإلكتروني');
    }

    if (data.containsKey('uid')) {
      throw UnexpectedFailure('لا يمكن تغيير معرف المستخدم');
    }

    if (data.containsKey('role')) {
      throw UnexpectedFailure('لا يمكن تغيير دور المستخدم');
    }

    if (data.containsKey('createdAt')) {
      throw UnexpectedFailure('لا يمكن تغيير تاريخ الإنشاء');
    }

    if (data.containsKey('doctorCode')) {
      throw UnexpectedFailure('لا يمكن تغيير كود الطبيب');
    }

    if (data.containsKey('licenseNumber')) {
      throw UnexpectedFailure('لا يمكن تغيير رقم الترخيص');
    }
  }

  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> refreshUserToken() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        debugPrint('⚠️ No user to refresh token');
        return;
      }

      debugPrint('🔄 ProfileService: Refreshing user token...');

      await user.getIdToken(true);

      debugPrint('✅ Token refreshed successfully');
    } catch (e) {
      debugPrint('⚠️ Error refreshing token: $e');
    }
  }
}
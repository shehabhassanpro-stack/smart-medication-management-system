import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DoctorPatientService {
  final FirebaseFirestore _firestore;

  DoctorPatientService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionName = 'doctor_patients';

  /// Links a patient to a doctor.
  ///
  /// Architecture notes:
  /// - Patient data (name, phone) is DENORMALIZED into the link document.
  ///   This avoids a chicken-and-egg problem with Firestore Security Rules:
  ///   the doctor can't read users/{patientId} because the link doesn't
  ///   exist yet, and isDoctorForPatient() returns false.
  /// - The deterministic ID (doctorId_patientId) guarantees idempotency.
  Future<(bool, String)> linkPatient({
    required String doctorId,
    required String patientId,
    required String patientName,
  }) async {
    try {
      debugPrint('🔗 linkPatient: doctor=$doctorId, patient=$patientId, name=$patientName');

      final linkId = '${doctorId}_$patientId';
      await _firestore.collection(_collectionName).doc(linkId).set({
        'doctorId': doctorId,
        'patientId': patientId,
        'patientName': patientName,
        'linkedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      debugPrint('🔗 linkPatient: SUCCESS ✅');
      return (true, 'تم ربط المريض بنجاح');
    } catch (e, stackTrace) {
      debugPrint('❌ linkPatient error: $e');
      debugPrint('❌ Stack: $stackTrace');
      return (false, 'خطأ: ${e.runtimeType}. تأكد من اتصالك بالإنترنت.');
    }
  }

  /// Get a stream of patients for a given doctor.
  ///
  /// Patient data is read directly from link documents (denormalized).
  /// No join with the 'users' collection is needed, avoiding both
  /// the N+1 query problem and Firestore Security Rules issues.
  Stream<List<Map<String, dynamic>>> getDoctorPatients(String doctorId) {
    return _firestore
        .collection(_collectionName)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      debugPrint('📊 getDoctorPatients: ${snapshot.docs.length} active links for $doctorId');

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'linkId': doc.id,
          'patientId': data['patientId'] ?? '',
          'name': data['patientName'] ?? 'مريض',
          'phone': data['phone'] ?? '',
          'linkedAt': data['linkedAt'],
        };
      }).toList();
    });
  }

  /// Safely unlinks a patient from a doctor using a soft-delete strategy.
  /// The link document is NOT deleted — it is marked as 'revoked'
  /// to maintain a full audit trail for healthcare compliance.
  Future<(bool, String)> unlinkPatient({
    required String doctorId,
    required String patientId,
  }) async {
    try {
      final linkId = '${doctorId}_$patientId';

      await _firestore.collection(_collectionName).doc(linkId).update({
        'status': 'revoked',
        'revokedAt': FieldValue.serverTimestamp(),
        'revokedBy': doctorId,
      });

      return (true, 'تم إلغاء ارتباط المريض بنجاح');
    } catch (e, stackTrace) {
      debugPrint('❌ unlinkPatient error: $e');
      debugPrint('❌ Stack: $stackTrace');
      return (false, 'خطأ: ${e.runtimeType}. تأكد من اتصالك بالإنترنت.');
    }
  }
}

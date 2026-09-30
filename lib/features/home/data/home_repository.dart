import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../models/health/health_reading.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🏠 HOME REPOSITORY - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Version: 2.0.0
// Architecture: Data Layer (Clean Architecture)
//
// Features:
// • Fixed isTaken check from medicine_logs ✅
// • skipMedicine() method
// • snoozeMedicine() method
// • getUnreadNotificationsCount()
// • getTodayMedicineLogs() helper
// • Improved _getNextScheduledTime() logic
// • 🆕 Prevents duplicate notifications on updates
// • 🆕 Idempotent medicine logging
//
// Updates v2.0:
// • _logMedicineAction now tracks if action is new or update
// • _saveNotificationToFirestore only called for NEW actions
// • Added _isExistingLogWithSameStatus check
//
// ═══════════════════════════════════════════════════════════════════════════════

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, [this.error]);
}

class LatestReadings {
  final HealthReading? bloodPressure;
  final HealthReading? bloodSugar;
  final HealthReading? weight;

  const LatestReadings({
    this.bloodPressure,
    this.bloodSugar,
    this.weight,
  });

  factory LatestReadings.empty() => const LatestReadings();

  bool get hasAnyReading =>
      bloodPressure != null || bloodSugar != null || weight != null;

  bool get hasAllReadings =>
      bloodPressure != null && bloodSugar != null && weight != null;

  int get readingsCount {
    int count = 0;
    if (bloodPressure != null) count++;
    if (bloodSugar != null) count++;
    if (weight != null) count++;
    return count;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MEDICINE LOG STATUS
// ═══════════════════════════════════════════════════════════════════════════════

enum MedicineLogStatus {
  taken,
  skipped,
  snoozed,
}

extension MedicineLogStatusExtension on MedicineLogStatus {
  String get value {
    switch (this) {
      case MedicineLogStatus.taken:
        return 'taken';
      case MedicineLogStatus.skipped:
        return 'skipped';
      case MedicineLogStatus.snoozed:
        return 'snoozed';
    }
  }

  static MedicineLogStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'taken':
        return MedicineLogStatus.taken;
      case 'skipped':
        return MedicineLogStatus.skipped;
      case 'snoozed':
        return MedicineLogStatus.snoozed;
      default:
        return MedicineLogStatus.taken;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🆕 EXISTING LOG INFO - Tracks both ID and current status
// ═══════════════════════════════════════════════════════════════════════════════

class _ExistingLogInfo {
  final String id;
  final String? currentStatus;

  const _ExistingLogInfo({
    required this.id,
    this.currentStatus,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════════

class HomeRepository {
  final FirebaseFirestore _firestore;

  static const String _healthReadingsCollection = 'health_readings';
  static const String _medicinesCollection = 'medicines';
  static const String _usersCollection = 'users';
  static const String _medicineLogsCollection = 'medicine_logs';
  static const String _notificationsCollection = 'notifications';
  static const Duration _timeout = Duration(seconds: 10);

  HomeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // USER DATA
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Result<Map<String, dynamic>>> getUserData(String userId) async {
    if (userId.isEmpty) {
      return const Failure('معرف المستخدم فارغ');
    }

    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get()
          .timeout(_timeout);

      if (!doc.exists || doc.data() == null) {
        return const Failure('بيانات المستخدم غير موجودة');
      }

      return Success(doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error fetching user data: ${e.message}');
      return Failure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return Failure('خطأ غير متوقع', e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEALTH READINGS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Result<HealthReading?>> getLatestBloodPressure(String userId) async {
    return _getLatestReading(userId, 'bloodPressure');
  }

  Future<Result<HealthReading?>> getLatestBloodSugar(String userId) async {
    return _getLatestReading(userId, 'bloodSugar');
  }

  Future<Result<HealthReading?>> getLatestWeight(String userId) async {
    return _getLatestReading(userId, 'weight');
  }

  Future<Result<HealthReading?>> _getLatestReading(String userId, String type) async {
    if (userId.isEmpty) {
      return const Failure('معرف المستخدم فارغ');
    }

    try {
      final snapshot = await _firestore
          .collection(_healthReadingsCollection)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .where('isDeleted', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get()
          .timeout(_timeout);

      if (snapshot.docs.isEmpty) {
        return const Success(null);
      }

      final reading = HealthReading.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );

      return Success(reading);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error fetching $type: ${e.message}');
      return Failure('خطأ في جلب $type', e);
    } catch (e) {
      debugPrint('Error fetching $type reading: $e');
      return Failure('خطأ غير متوقع', e);
    }
  }

  Future<Result<LatestReadings>> getLatestReadings(String userId) async {
    if (userId.isEmpty) {
      return const Failure('معرف المستخدم فارغ');
    }

    try {
      final results = await Future.wait([
        _getLatestReadingDirect(userId, 'bloodPressure'),
        _getLatestReadingDirect(userId, 'bloodSugar'),
        _getLatestReadingDirect(userId, 'weight'),
      ]);

      return Success(LatestReadings(
        bloodPressure: results[0],
        bloodSugar: results[1],
        weight: results[2],
      ));
    } catch (e) {
      debugPrint('Error fetching latest readings: $e');
      return Failure('خطأ في جلب القراءات', e);
    }
  }

  Future<HealthReading?> _getLatestReadingDirect(String userId, String type) async {
    try {
      final snapshot = await _firestore
          .collection(_healthReadingsCollection)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .where('isDeleted', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get()
          .timeout(_timeout);

      if (snapshot.docs.isEmpty) return null;

      return HealthReading.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      debugPrint('Error fetching $type: $e');
      return null;
    }
  }

  Stream<Result<List<HealthReading>>> watchHealthReadings(String userId, {int limit = 10}) {
    if (userId.isEmpty) {
      return Stream.value(const Failure('معرف المستخدم فارغ'));
    }

    return _firestore
        .collection(_healthReadingsCollection)
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      try {
        final readings = snapshot.docs
            .map((doc) => HealthReading.fromMap(doc.data(), doc.id))
            .toList();
        return Success(readings);
      } catch (e) {
        return Failure<List<HealthReading>>('خطأ في تحويل البيانات', e);
      }
    })
        .handleError((e) => Failure<List<HealthReading>>('خطأ في المراقبة', e));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MEDICINES
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<Result<List<Map<String, dynamic>>>> watchActiveMedicines(String userId) {
    if (userId.isEmpty) {
      return Stream.value(const Failure('معرف المستخدم فارغ'));
    }

    return _firestore
        .collection(_medicinesCollection)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      try {
        final medicines = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        return Success(medicines);
      } catch (e) {
        return Failure<List<Map<String, dynamic>>>('خطأ في تحويل البيانات', e);
      }
    })
        .handleError((e) => Failure<List<Map<String, dynamic>>>('خطأ في المراقبة', e));
  }

  Future<Result<int>> getActiveMedicinesCount(String userId) async {
    if (userId.isEmpty) {
      return const Failure('معرف المستخدم فارغ');
    }

    try {
      final snapshot = await _firestore
          .collection(_medicinesCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .count()
          .get()
          .timeout(_timeout);

      return Success(snapshot.count ?? 0);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error fetching medicines count: ${e.message}');
      return Failure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error fetching medicines count: $e');
      return Failure('خطأ غير متوقع', e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TODAY'S MEDICINES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Result<List<Map<String, dynamic>>>> getTodayMedicines(String userId) async {
    if (userId.isEmpty) {
      return const Failure('معرف المستخدم فارغ');
    }

    try {
      final medicinesSnapshot = await _firestore
          .collection(_medicinesCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get()
          .timeout(_timeout);

      final todayLogs = await _getTodayMedicineLogs(userId);

      final medicines = medicinesSnapshot.docs.map((doc) {
        final data = doc.data();
        final medicineId = doc.id;
        final times = data['times'] as List<dynamic>? ?? [];

        final nextTime = _getNextScheduledTime(data);
        final logKey = _buildLogKey(medicineId, nextTime);
        final logStatus = todayLogs[logKey];

        return {
          'id': medicineId,
          'name': data['name'] ?? 'دواء',
          'dosage': _formatDosage(data),
          'scheduledTime': nextTime,
          'times': times,
          'isTaken': logStatus == MedicineLogStatus.taken,
          'isSkipped': logStatus == MedicineLogStatus.skipped,
          'isSnoozed': logStatus == MedicineLogStatus.snoozed,
          'status': logStatus?.value ?? 'pending',
          ...data,
        };
      }).toList();

      return Success(medicines);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error fetching today medicines: ${e.message}');
      return Failure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error fetching today medicines: $e');
      return Failure('خطأ غير متوقع', e);
    }
  }

  Future<Map<String, MedicineLogStatus>> _getTodayMedicineLogs(String userId) async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final snapshot = await _firestore
          .collection(_medicineLogsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: todayString)
          .get()
          .timeout(_timeout);

      final logs = <String, MedicineLogStatus>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final medicineId = data['medicineId'] as String?;
        final scheduledTime = data['scheduledTime'] as String?;
        final status = data['status'] as String? ?? 'taken';

        if (medicineId != null) {
          final key = _buildLogKey(medicineId, scheduledTime ?? '');
          logs[key] = MedicineLogStatusExtension.fromString(status);
        }
      }

      return logs;
    } catch (e) {
      debugPrint('Error fetching today medicine logs: $e');
      return {};
    }
  }

  String _buildLogKey(String medicineId, String scheduledTime) {
    return '${medicineId}_$scheduledTime';
  }

  String _formatDosage(Map<String, dynamic> data) {
    final dosageAmount = data['dosageAmount'] ?? data['dosage'] ?? '';
    final dosageUnit = data['dosageUnit'] ?? '';
    final frequency = data['frequency'] ?? '';

    if (dosageAmount.toString().isNotEmpty) {
      return '$dosageAmount $dosageUnit'.trim();
    }
    return frequency.toString();
  }

  String _getNextScheduledTime(Map<String, dynamic> data) {
    final times = data['times'] as List<dynamic>?;
    if (times == null || times.isEmpty) {
      return '08:00';
    }

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    String? nextTime;
    int? smallestDiff;

    for (final time in times) {
      final timeStr = time.toString();
      final parsed = _parseTime(timeStr);
      if (parsed == null) continue;

      final timeMinutes = parsed.$1 * 60 + parsed.$2;
      final diff = timeMinutes - currentMinutes;

      if (diff > -30) {
        if (smallestDiff == null || diff < smallestDiff) {
          smallestDiff = diff;
          nextTime = timeStr;
        }
      }
    }

    return nextTime ?? times.first.toString();
  }

  (int, int)? _parseTime(String timeString) {
    try {
      final parts = timeString.trim().split(':');
      if (parts.length != 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return (hour, minute);
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MEDICINE ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Result<void>> markMedicineTaken({
    required String userId,
    required String medicineId,
    String? scheduledTime,
    String? notes,
    String? medicineName,
  }) async {
    return _logMedicineAction(
      userId: userId,
      medicineId: medicineId,
      status: MedicineLogStatus.taken,
      scheduledTime: scheduledTime,
      notes: notes,
      medicineName: medicineName,
    );
  }

  Future<Result<void>> skipMedicine({
    required String userId,
    required String medicineId,
    String? scheduledTime,
    String? reason,
    String? medicineName,
  }) async {
    return _logMedicineAction(
      userId: userId,
      medicineId: medicineId,
      status: MedicineLogStatus.skipped,
      scheduledTime: scheduledTime,
      notes: reason,
      medicineName: medicineName,
    );
  }

  Future<Result<void>> snoozeMedicine({
    required String userId,
    required String medicineId,
    String? scheduledTime,
    int snoozeMinutes = 15,
    String? medicineName,
  }) async {
    return _logMedicineAction(
      userId: userId,
      medicineId: medicineId,
      status: MedicineLogStatus.snoozed,
      scheduledTime: scheduledTime,
      notes: 'Snoozed for $snoozeMinutes minutes',
      extra: {'snoozeMinutes': snoozeMinutes},
      medicineName: medicineName,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 UPDATED: GENERIC MEDICINE ACTION LOGGER - Prevents duplicate notifications
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Result<void>> _logMedicineAction({
    required String userId,
    required String medicineId,
    required MedicineLogStatus status,
    String? scheduledTime,
    String? notes,
    Map<String, dynamic>? extra,
    String? medicineName,
  }) async {
    if (userId.isEmpty || medicineId.isEmpty) {
      return const Failure('بيانات غير صحيحة');
    }

    try {
      final now = DateTime.now();
      final todayString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final logData = {
        'userId': userId,
        'medicineId': medicineId,
        'status': status.value,
        'date': todayString,
        'scheduledTime': scheduledTime ?? '',
        'actionTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        if (notes != null) 'notes': notes,
        if (extra != null) ...extra,
      };

      // 🆕 Check if log already exists AND get current status
      final existingLogInfo = await _findExistingLogWithStatus(
        userId: userId,
        medicineId: medicineId,
        date: todayString,
        scheduledTime: scheduledTime,
      );

      bool isNewAction = false;
      bool statusChanged = false;

      if (existingLogInfo != null) {
        // Check if status is actually changing
        statusChanged = existingLogInfo.currentStatus != status.value;
        
        if (!statusChanged) {
          // 🆕 Same status - skip update entirely (idempotent)
          debugPrint('⏭️ Medicine action unchanged: ${status.value} for $medicineId');
          return const Success(null);
        }

        // Update existing log with new status
        await _firestore
            .collection(_medicineLogsCollection)
            .doc(existingLogInfo.id)
            .update({
          'status': status.value,
          'actionTime': FieldValue.serverTimestamp(),
          if (notes != null) 'notes': notes,
          if (extra != null) ...extra,
        }).timeout(_timeout);
        
        debugPrint('🔄 Updated existing log: ${existingLogInfo.id} to ${status.value}');
      } else {
        // Create new log
        isNewAction = true;
        await _firestore
            .collection(_medicineLogsCollection)
            .add(logData)
            .timeout(_timeout);
        
        debugPrint('✅ Created new medicine log: ${status.value} for $medicineId');
      }

      // 🆕 ONLY save notification for NEW actions, not updates
      if (isNewAction) {
        await _saveNotificationToFirestore(
          userId: userId,
          medicineId: medicineId,
          medicineName: medicineName ?? 'دواء',
          status: status.value,
          scheduledTime: scheduledTime,
        );
      } else if (statusChanged) {
        // Optionally: update existing notification or create new one for status change
        debugPrint('📝 Status changed but not creating new notification');
      }

      debugPrint('✅ Medicine ${status.value}: $medicineId (new: $isNewAction)');
      return const Success(null);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error logging medicine action: ${e.message}');
      return Failure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error logging medicine action: $e');
      return Failure('خطأ غير متوقع', e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🆕 FIND EXISTING LOG WITH STATUS - Returns both ID and current status
  // ═══════════════════════════════════════════════════════════════════════════

  Future<_ExistingLogInfo?> _findExistingLogWithStatus({
    required String userId,
    required String medicineId,
    required String date,
    String? scheduledTime,
  }) async {
    try {
      var query = _firestore
          .collection(_medicineLogsCollection)
          .where('userId', isEqualTo: userId)
          .where('medicineId', isEqualTo: medicineId)
          .where('date', isEqualTo: date);

      if (scheduledTime != null && scheduledTime.isNotEmpty) {
        query = query.where('scheduledTime', isEqualTo: scheduledTime);
      }

      final snapshot = await query.limit(1).get().timeout(_timeout);

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        return _ExistingLogInfo(
          id: doc.id,
          currentStatus: data['status'] as String?,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error finding existing log: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SAVE NOTIFICATION TO FIRESTORE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _saveNotificationToFirestore({
    required String userId,
    required String medicineId,
    required String medicineName,
    required String status,
    String? scheduledTime,
  }) async {
    try {
      String title;
      String body;
      String type;

      switch (status) {
        case 'taken':
          title = 'تم تناول الدواء ✓';
          body = 'لقد تناولت $medicineName';
          type = 'medicine_taken';
          break;
        case 'skipped':
          title = 'تم تخطي الدواء';
          body = 'لقد تخطيت $medicineName';
          type = 'medicine_skipped';
          break;
        case 'snoozed':
          title = 'تم تأجيل الدواء';
          body = 'سيتم تذكيرك بـ $medicineName لاحقاً';
          type = 'medicine_snoozed';
          break;
        default:
          title = 'تذكير دواء';
          body = medicineName;
          type = 'medicine_reminder';
      }

      DateTime scheduledDateTime = DateTime.now();
      if (scheduledTime != null && scheduledTime.isNotEmpty) {
        try {
          final parts = scheduledTime.split(':');
          if (parts.length >= 2) {
            final now = DateTime.now();
            scheduledDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
          }
        } catch (_) {}
      }

      final notificationRef = _firestore.collection(_notificationsCollection).doc();

      final notification = {
        'id': notificationRef.id,
        'userId': userId,
        'medicineId': medicineId,
        'medicineName': medicineName,
        'title': title,
        'body': body,
        'type': type,
        'status': status,
        'scheduledTime': Timestamp.fromDate(scheduledDateTime),
        'actionTime': FieldValue.serverTimestamp(),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await notificationRef.set(notification);
      debugPrint('✅ Notification saved to Firestore: $type for $medicineName');
    } catch (e) {
      debugPrint('⚠️ Failed to save notification to Firestore: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Result<int>> getUnreadNotificationsCount(String userId) async {
    if (userId.isEmpty) {
      return const Failure('معرف المستخدم فارغ');
    }

    try {
      final snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get()
          .timeout(_timeout);

      return Success(snapshot.count ?? 0);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error fetching unread count: ${e.message}');
      return Failure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
      return Failure('خطأ غير متوقع', e);
    }
  }

  Stream<int> watchUnreadNotificationsCount(String userId) {
    if (userId.isEmpty) {
      return Stream.value(0);
    }

    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((e) {
          debugPrint('Error watching unread count: $e');
          return 0;
        });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // READINGS COUNT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Result<int>> getReadingsCount(String userId) async {
    if (userId.isEmpty) {
      return const Failure('معرف المستخدم فارغ');
    }

    try {
      final snapshot = await _firestore
          .collection(_healthReadingsCollection)
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .count()
          .get()
          .timeout(_timeout);

      return Success(snapshot.count ?? 0);
    } on FirebaseException catch (e) {
      debugPrint('Firebase error fetching readings count: ${e.message}');
      return Failure('خطأ في قاعدة البيانات', e);
    } catch (e) {
      debugPrint('Error fetching readings count: $e');
      return Failure('خطأ غير متوقع', e);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RESULT EXTENSION
// ═══════════════════════════════════════════════════════════════════════════════

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  String? get errorMessage => isFailure ? (this as Failure<T>).message : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Object? error) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      final f = this as Failure<T>;
      return failure(f.message, f.error);
    }
  }

  Result<R> map<R>(R Function(T data) transform) {
    if (this is Success<T>) {
      return Success(transform((this as Success<T>).data));
    }
    return Failure((this as Failure<T>).message, (this as Failure<T>).error);
  }
}

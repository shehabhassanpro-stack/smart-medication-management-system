import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicines_repository.dart';
import '../models/medicine_model.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 💊 MEDICINES REMOTE DATA SOURCE - Enterprise Grade Implementation
// ═══════════════════════════════════════════════════════════════════════════════
//
// Version: 2.1.0
// 
// Critical Fix Applied:
// ✓ Fixed getOverallAdherence() to use correct collection and fields
// ✓ Changed from 'dose_logs' to 'medicine_logs' collection
// ✓ Changed from 'odId' to 'userId' field
// ✓ Changed date filtering from Timestamp to String format
// ✓ Synchronized adherence calculation with HomeRepository
//
// ═══════════════════════════════════════════════════════════════════════════════

abstract class MedicinesRemoteDataSource {
  Future<List<MedicineModel>> getMedicines({
    required String userId,
    MedicineFilter? filter,
    MedicineSort? sort,
  });

  Future<MedicineModel> getMedicineById({
    required String medicineId,
  });

  Future<List<MedicineModel>> getActiveMedicines({
    required String userId,
  });

  Future<List<MedicineModel>> getMedicinesForDate({
    required String userId,
    required DateTime date,
  });

  Future<MedicineModel> addMedicine({
    required MedicineModel medicine,
  });

  Future<MedicineModel> updateMedicine({
    required MedicineModel medicine,
  });

  Future<void> deleteMedicine({
    required String medicineId,
  });

  Future<void> deleteMedicines({
    required List<String> medicineIds,
  });

  Future<MedicineModel> toggleMedicineStatus({
    required String medicineId,
    required bool isActive,
  });

  Future<MedicineModel> updateStock({
    required String medicineId,
    required int newStock,
  });

  Future<List<MedicineModel>> searchMedicines({
    required String userId,
    required String query,
  });

  Future<List<DoseLogModel>> getDoseLogs({
    required String medicineId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<DoseLogModel>> getTodayDoses({
    required String userId,
  });

  Future<DoseLogModel> logDose({
    required DoseLogModel doseLog,
  });

  Future<DoseLogModel> updateDoseStatus({
    required String doseLogId,
    required DoseStatus status,
    DateTime? takenTime,
    String? notes,
  });

  Future<AdherenceSummaryModel> getAdherenceSummary({
    required String userId,
    required String medicineId,
    String? month,
  });

  Future<AdherenceSummaryModel> getOverallAdherence({
    required String userId,
    String? month,
  });

  Future<Map<String, double>> getWeeklyAdherence({
    required String userId,
    String? medicineId,
  });

  Stream<List<MedicineModel>> watchMedicines({
    required String userId,
  });

  Stream<MedicineModel> watchMedicine({
    required String medicineId,
  });

  Stream<List<DoseLogModel>> watchTodayDoses({
    required String userId,
  });

  Future<List<MedicineModel>> getMedicinesNeedingRefill({
    required String userId,
  });

  Future<MedicinesCount> getMedicinesCount({
    required String userId,
  });
}

class MedicinesRemoteDataSourceImpl implements MedicinesRemoteDataSource {
  final FirebaseFirestore _firestore;

  MedicinesRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // COLLECTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _medicinesCollection =>
      _firestore.collection('medicines');

  /// ✅ FIXED: Use 'medicine_logs' instead of 'dose_logs'
  /// This collection is shared with HomeRepository for consistent data
  CollectionReference<Map<String, dynamic>> get _medicineLogsCollection =>
      _firestore.collection('medicine_logs');

  // ═══════════════════════════════════════════════════════════════════════════
  // GET MEDICINES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<MedicineModel>> getMedicines({
    required String userId,
    MedicineFilter? filter,
    MedicineSort? sort,
  }) async {
    Query<Map<String, dynamic>> query = _medicinesCollection.where('userId', isEqualTo: userId);

    if (filter != null) {
      if (filter.isActive != null) {
        query = query.where('isActive', isEqualTo: filter.isActive);
      }
      if (filter.isCritical != null) {
        query = query.where('isCritical', isEqualTo: filter.isCritical);
      }
      if (filter.dosageForm != null) {
        query = query.where('dosageForm', isEqualTo: filter.dosageForm!.name);
      }
    }

    if (sort != null) {
      query = query.orderBy(sort.field, descending: sort.isDescending);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    final snapshot = await query.get();

    List<MedicineModel> medicines = snapshot.docs
        .map((doc) => MedicineModel.fromFirestore(doc))
        .toList();

    if (filter?.dayPeriod != null) {
      medicines = medicines.where((m) {
        return m.times.any((time) {
          final hour = int.tryParse(time.split(':').first) ?? 0;
          return DayPeriodExtension.fromHour(hour) == filter!.dayPeriod;
        });
      }).toList();
    }

    if (filter?.medicineIds != null && filter!.medicineIds!.isNotEmpty) {
      medicines = medicines.where((m) => filter.medicineIds!.contains(m.id)).toList();
    }

    return medicines;
  }

  @override
  Future<MedicineModel> getMedicineById({
    required String medicineId,
  }) async {
    final doc = await _medicinesCollection.doc(medicineId).get();

    if (!doc.exists) {
      throw MedicineNotFoundException(medicineId: medicineId);
    }

    return MedicineModel.fromFirestore(doc);
  }

  @override
  Future<List<MedicineModel>> getActiveMedicines({
    required String userId,
  }) async {
    final snapshot = await _medicinesCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => MedicineModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<MedicineModel>> getMedicinesForDate({
    required String userId,
    required DateTime date,
  }) async {
    final medicines = await getActiveMedicines(userId: userId);

    return medicines.where((medicine) {
      if (medicine.startDate != null && date.isBefore(medicine.startDate!)) {
        return false;
      }
      if (medicine.endDate != null && date.isAfter(medicine.endDate!)) {
        return false;
      }

      switch (medicine.frequency) {
        case Frequency.onceDaily:
        case Frequency.twiceDaily:
        case Frequency.thriceDaily:
        case Frequency.fourTimesDaily:
        case Frequency.asNeeded:
        case Frequency.custom:
          return true;
        case Frequency.everyOtherDay:
          if (medicine.startDate == null) return true;
          final daysDiff = date.difference(medicine.startDate!).inDays;
          return daysDiff % 2 == 0;
        case Frequency.weekly:
          if (medicine.startDate == null) return true;
          return date.weekday == medicine.startDate!.weekday;
      }
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADD / UPDATE / DELETE MEDICINES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<MedicineModel> addMedicine({
    required MedicineModel medicine,
  }) async {
    final docRef = _medicinesCollection.doc();
    final newMedicine = MedicineModel(
      id: docRef.id,
      userId: medicine.userId,
      name: medicine.name,
      dosage: medicine.dosage,
      dosageForm: medicine.dosageForm,
      times: medicine.times,
      frequency: medicine.frequency,
      isActive: medicine.isActive,
      isCritical: medicine.isCritical,
      instructions: medicine.instructions,
      notes: medicine.notes,
      startDate: medicine.startDate,
      endDate: medicine.endDate,
      stockCount: medicine.stockCount,
      refillReminder: medicine.refillReminder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(newMedicine.toFirestore());

    return newMedicine;
  }

  @override
  Future<MedicineModel> updateMedicine({
    required MedicineModel medicine,
  }) async {
    final docRef = _medicinesCollection.doc(medicine.id);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw MedicineNotFoundException(medicineId: medicine.id);
    }

    final updatedMedicine = MedicineModel(
      id: medicine.id,
      userId: medicine.userId,
      name: medicine.name,
      dosage: medicine.dosage,
      dosageForm: medicine.dosageForm,
      times: medicine.times,
      frequency: medicine.frequency,
      isActive: medicine.isActive,
      isCritical: medicine.isCritical,
      instructions: medicine.instructions,
      notes: medicine.notes,
      startDate: medicine.startDate,
      endDate: medicine.endDate,
      stockCount: medicine.stockCount,
      refillReminder: medicine.refillReminder,
      createdAt: medicine.createdAt,
      updatedAt: DateTime.now(),
    );

    await docRef.update(updatedMedicine.toFirestore());

    return updatedMedicine;
  }

  @override
  Future<void> deleteMedicine({
    required String medicineId,
  }) async {
    final docRef = _medicinesCollection.doc(medicineId);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw MedicineNotFoundException(medicineId: medicineId);
    }

    final batch = _firestore.batch();

    batch.delete(docRef);

    // ✅ FIXED: Delete from medicine_logs instead of dose_logs
    final medicineLogsSnapshot = await _medicineLogsCollection
        .where('medicineId', isEqualTo: medicineId)
        .get();

    for (final logDoc in medicineLogsSnapshot.docs) {
      batch.delete(logDoc.reference);
    }

    await batch.commit();
  }

  @override
  Future<void> deleteMedicines({
    required List<String> medicineIds,
  }) async {
    final batch = _firestore.batch();

    for (final medicineId in medicineIds) {
      final docRef = _medicinesCollection.doc(medicineId);
      batch.delete(docRef);

      // ✅ FIXED: Delete from medicine_logs instead of dose_logs
      final medicineLogsSnapshot = await _medicineLogsCollection
          .where('medicineId', isEqualTo: medicineId)
          .get();

      for (final logDoc in medicineLogsSnapshot.docs) {
        batch.delete(logDoc.reference);
      }
    }

    await batch.commit();
  }

  @override
  Future<MedicineModel> toggleMedicineStatus({
    required String medicineId,
    required bool isActive,
  }) async {
    final docRef = _medicinesCollection.doc(medicineId);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw MedicineNotFoundException(medicineId: medicineId);
    }

    await docRef.update({
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    final updatedDoc = await docRef.get();
    return MedicineModel.fromFirestore(updatedDoc);
  }

  @override
  Future<MedicineModel> updateStock({
    required String medicineId,
    required int newStock,
  }) async {
    final docRef = _medicinesCollection.doc(medicineId);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw MedicineNotFoundException(medicineId: medicineId);
    }

    await docRef.update({
      'stockCount': newStock,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    final updatedDoc = await docRef.get();
    return MedicineModel.fromFirestore(updatedDoc);
  }

  @override
  Future<List<MedicineModel>> searchMedicines({
    required String userId,
    required String query,
  }) async {
    final lowerQuery = query.toLowerCase();

    final snapshot = await _medicinesCollection
        .where('userId', isEqualTo: userId)
        .get();

    final medicines = snapshot.docs
        .map((doc) => MedicineModel.fromFirestore(doc))
        .where((medicine) {
      return medicine.name.toLowerCase().contains(lowerQuery) ||
          medicine.dosage.toLowerCase().contains(lowerQuery) ||
          (medicine.instructions?.toLowerCase().contains(lowerQuery) ?? false) ||
          (medicine.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    return medicines;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DOSE LOGS - Using medicine_logs collection
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<DoseLogModel>> getDoseLogs({
    required String medicineId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query<Map<String, dynamic>> query = _medicineLogsCollection
        .where('medicineId', isEqualTo: medicineId);

    // ✅ FIXED: Use date string format instead of Timestamp
    if (startDate != null) {
      final startDateString = _formatDateString(startDate);
      query = query.where('date', isGreaterThanOrEqualTo: startDateString);
    }

    if (endDate != null) {
      final endDateString = _formatDateString(endDate);
      query = query.where('date', isLessThanOrEqualTo: endDateString);
    }

    query = query.orderBy('date', descending: true);

    final snapshot = await query.get();

    return snapshot.docs.map((doc) => _doseLogFromMedicineLog(doc)).toList();
  }

  @override
  Future<List<DoseLogModel>> getTodayDoses({
    required String userId,
  }) async {
    final todayString = _getTodayDateString();

    // ✅ FIXED: Use 'userId' instead of 'odId'
    final snapshot = await _medicineLogsCollection
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: todayString)
        .get();

    return snapshot.docs.map((doc) => _doseLogFromMedicineLog(doc)).toList();
  }

  @override
  Future<DoseLogModel> logDose({
    required DoseLogModel doseLog,
  }) async {
    final docRef = _medicineLogsCollection.doc();
    final todayString = _getTodayDateString();
    final scheduledTimeString = _formatTimeString(doseLog.scheduledTime);
    
    final logData = {
      'odId': doseLog.odId,
      'medicineId': doseLog.medicineId,
      'userId': doseLog.odId, // ✅ Add userId field for consistency
      'date': todayString,
      'scheduledTime': scheduledTimeString,
      'status': doseLog.status.name,
      'actionTime': FieldValue.serverTimestamp(),
      'notes': doseLog.notes,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(logData);

    return DoseLogModel(
      id: docRef.id,
      medicineId: doseLog.medicineId,
      odId: doseLog.odId,
      scheduledTime: doseLog.scheduledTime,
      takenTime: DateTime.now(),
      status: doseLog.status,
      notes: doseLog.notes,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<DoseLogModel> updateDoseStatus({
    required String doseLogId,
    required DoseStatus status,
    DateTime? takenTime,
    String? notes,
  }) async {
    final docRef = _medicineLogsCollection.doc(doseLogId);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw DoseLogNotFoundException(doseLogId: doseLogId);
    }

    final updates = <String, dynamic>{
      'status': status.name,
      'actionTime': FieldValue.serverTimestamp(),
    };

    if (notes != null) {
      updates['notes'] = notes;
    }

    await docRef.update(updates);

    final updatedDoc = await docRef.get();
    return _doseLogFromMedicineLog(updatedDoc);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ FIXED: ADHERENCE CALCULATION - Now uses medicine_logs with correct fields
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<AdherenceSummaryModel> getAdherenceSummary({
    required String userId,
    required String medicineId,
    String? month,
  }) async {
    final todayString = _getTodayDateString();

    // Get medicine to count scheduled doses
    final medicineDoc = await _medicinesCollection.doc(medicineId).get();
    int totalScheduledDoses = 0;
    
    if (medicineDoc.exists) {
      final times = medicineDoc.data()?['times'] as List<dynamic>? ?? [];
      totalScheduledDoses = times.length;
    }

    // ✅ FIXED: Get today's logs using 'userId' instead of 'odId'
    final logsSnapshot = await _medicineLogsCollection
        .where('userId', isEqualTo: userId)
        .where('medicineId', isEqualTo: medicineId)
        .where('date', isEqualTo: todayString)
        .get();

    int takenDoses = 0;
    int skippedDoses = 0;

    for (final doc in logsSnapshot.docs) {
      final status = doc.data()['status'] as String? ?? '';
      if (status == 'taken') {
        takenDoses++;
      } else if (status == 'skipped') {
        skippedDoses++;
      }
    }

    final missedDoses = (totalScheduledDoses - takenDoses - skippedDoses).clamp(0, totalScheduledDoses);
    final adherenceRate = totalScheduledDoses > 0 
        ? (takenDoses / totalScheduledDoses) * 100 
        : 0.0;

    return AdherenceSummaryModel(
      odId: userId,
      odMonth: todayString,
      totalDoses: totalScheduledDoses,
      takenDoses: takenDoses,
      missedDoses: missedDoses,
      skippedDoses: skippedDoses,
      adherenceRate: adherenceRate,
      updatedAt: DateTime.now(),
    );
  }

  /// ✅ FIXED: getOverallAdherence now uses correct collection and fields
  /// 
  /// Previous issues:
  /// - Was using 'dose_logs' collection (doesn't exist or empty)
  /// - Was using 'odId' field (should be 'userId')
  /// - Was using Timestamp for date filtering (should be String)
  /// 
  /// Now synchronized with HomeRepository for consistent data
  @override
  Future<AdherenceSummaryModel> getOverallAdherence({
    required String userId,
    String? month,
  }) async {
    final todayString = _getTodayDateString();

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 1: Calculate total scheduled doses from active medicines
    // ═══════════════════════════════════════════════════════════════════════
    
    final medicinesSnapshot = await _medicinesCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();

    int totalScheduledDoses = 0;
    
    for (final doc in medicinesSnapshot.docs) {
      final data = doc.data();
      final times = data['times'] as List<dynamic>? ?? [];
      
      // Check if medicine is valid for today
      // ✅ FIXED: Safe type checking before casting
      DateTime? startDate;
      DateTime? endDate;
      
      final startDateData = data['startDate'];
      final endDateData = data['endDate'];
      
      if (startDateData is Timestamp) {
        startDate = startDateData.toDate();
      }
      if (endDateData is Timestamp) {
        endDate = endDateData.toDate();
      }
      
      final today = DateTime.now();
      
      // Skip if medicine hasn't started yet
      if (startDate != null && today.isBefore(startDate)) continue;
      
      // Skip if medicine has ended
      if (endDate != null && today.isAfter(endDate)) continue;
      
      // Add times count for this medicine
      totalScheduledDoses += times.length;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 2: Get today's medicine logs
    // ✅ FIXED: Use 'userId' and 'date' string format
    // ═══════════════════════════════════════════════════════════════════════
    
    final logsSnapshot = await _medicineLogsCollection
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: todayString)
        .get();

    int takenDoses = 0;
    int skippedDoses = 0;
    int snoozedDoses = 0;

    for (final doc in logsSnapshot.docs) {
      final status = doc.data()['status'] as String? ?? '';
      
      switch (status.toLowerCase()) {
        case 'taken':
          takenDoses++;
          break;
        case 'skipped':
          skippedDoses++;
          break;
        case 'snoozed':
          snoozedDoses++;
          break;
      }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // STEP 3: Calculate adherence rate
    // ═══════════════════════════════════════════════════════════════════════
    
    // Missed = Total scheduled - Taken - Skipped - Snoozed (still pending)
    final missedDoses = (totalScheduledDoses - takenDoses - skippedDoses - snoozedDoses)
        .clamp(0, totalScheduledDoses);
    
    // Adherence Rate = (Taken / Total) * 100
    // If no doses scheduled, rate is 0 (not 100)
    final adherenceRate = totalScheduledDoses > 0 
        ? (takenDoses / totalScheduledDoses) * 100 
        : 0.0;

    return AdherenceSummaryModel(
      odId: userId,
      odMonth: todayString,
      totalDoses: totalScheduledDoses,
      takenDoses: takenDoses,
      missedDoses: missedDoses,
      skippedDoses: skippedDoses,
      adherenceRate: adherenceRate,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Map<String, double>> getWeeklyAdherence({
    required String userId,
    String? medicineId,
  }) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final result = <String, double>{};

    for (int i = 0; i < 7; i++) {
      final day = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      final dayString = _formatDateString(day);

      // Get medicines for this day
      final medicines = await getMedicinesForDate(userId: userId, date: day);
      int totalDoses = 0;
      
      for (final medicine in medicines) {
        if (medicineId != null && medicine.id != medicineId) continue;
        totalDoses += medicine.times.length;
      }

      // ✅ FIXED: Get logs using 'userId' and date string
      Query<Map<String, dynamic>> query = _medicineLogsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: dayString);

      if (medicineId != null) {
        query = query.where('medicineId', isEqualTo: medicineId);
      }

      final snapshot = await query.get();
      
      int takenDoses = 0;
      for (final doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? '';
        if (status == 'taken') {
          takenDoses++;
        }
      }

      final rate = totalDoses > 0 ? (takenDoses / totalDoses) * 100 : 0.0;
      final dayName = _getArabicDayName(day.weekday);
      result[dayName] = rate;
    }

    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STREAMS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Stream<List<MedicineModel>> watchMedicines({
    required String userId,
  }) {
    return _medicinesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MedicineModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<MedicineModel> watchMedicine({
    required String medicineId,
  }) {
    return _medicinesCollection
        .doc(medicineId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw MedicineNotFoundException(medicineId: medicineId);
      }
      return MedicineModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<DoseLogModel>> watchTodayDoses({
    required String userId,
  }) {
    final todayString = _getTodayDateString();

    // ✅ FIXED: Use 'userId' instead of 'odId'
    return _medicineLogsCollection
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: todayString)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => _doseLogFromMedicineLog(doc)).toList());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OTHER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<MedicineModel>> getMedicinesNeedingRefill({
    required String userId,
  }) async {
    final medicines = await getActiveMedicines(userId: userId);

    return medicines.where((medicine) {
      if (medicine.stockCount == null || medicine.refillReminder == null) {
        return false;
      }
      return medicine.stockCount! <= medicine.refillReminder!;
    }).toList();
  }

  @override
  Future<MedicinesCount> getMedicinesCount({
    required String userId,
  }) async {
    final snapshot = await _medicinesCollection
        .where('userId', isEqualTo: userId)
        .get();

    final medicines = snapshot.docs.map((doc) => MedicineModel.fromFirestore(doc)).toList();

    return MedicinesCount(
      total: medicines.length,
      active: medicines.where((m) => m.isActive).length,
      inactive: medicines.where((m) => !m.isActive).length,
      critical: medicines.where((m) => m.isCritical).length,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// ✅ Convert medicine_logs document to DoseLogModel
  DoseLogModel _doseLogFromMedicineLog(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    // Parse scheduledTime from string "HH:mm" to DateTime
    DateTime scheduledDateTime = DateTime.now();
    final scheduledTimeStr = data['scheduledTime'] as String?;
    if (scheduledTimeStr != null && scheduledTimeStr.isNotEmpty) {
      final parts = scheduledTimeStr.split(':');
      if (parts.length >= 2) {
        final now = DateTime.now();
        scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.tryParse(parts[0]) ?? 0,
          int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    // Parse actionTime
    DateTime? takenTime;
    if (data['actionTime'] != null) {
      if (data['actionTime'] is Timestamp) {
        takenTime = (data['actionTime'] as Timestamp).toDate();
      }
    }

    // Parse createdAt
    DateTime createdAt = DateTime.now();
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      }
    }

    // Parse status using the existing extension
    final statusStr = data['status'] as String? ?? '';
    final status = DoseStatusExtension.fromString(statusStr);

    return DoseLogModel(
      id: doc.id,
      medicineId: data['medicineId'] as String? ?? '',
      odId: data['userId'] as String? ?? data['odId'] as String? ?? '',
      scheduledTime: scheduledDateTime,
      takenTime: takenTime,
      status: status,
      notes: data['notes'] as String?,
      createdAt: createdAt,
    );
  }

  /// Get today's date as string in format: "YYYY-MM-DD"
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Format DateTime to string in format: "YYYY-MM-DD"
  String _formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format DateTime to time string in format: "HH:mm"
  String _formatTimeString(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getArabicDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'الإثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      default:
        return '';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EXCEPTIONS
// ═══════════════════════════════════════════════════════════════════════════════

class MedicineNotFoundException implements Exception {
  final String medicineId;

  MedicineNotFoundException({required this.medicineId});

  @override
  String toString() => 'Medicine not found: $medicineId';
}

class DoseLogNotFoundException implements Exception {
  final String doseLogId;

  DoseLogNotFoundException({required this.doseLogId});

  @override
  String toString() => 'Dose log not found: $doseLogId';
}
